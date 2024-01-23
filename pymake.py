"""
pymake.py is a module for automation of tasks, with support for fortran builds, in python
"""
from __future__ import annotations
from typing import Any, List, Union, Dict
import subprocess
from pathlib import Path
import argparse


timer = '/usr/bin/time --format="\\n Executed in %e seconds with %P CPU"'


class Bool:
    never = "never"
    maybe = False
    always = True


def run_arg(arg_map, arg, ignore):
    if callable(arg):
        if isinstance(arg, Command):
            arg(ignore=ignore)
        else:
            arg()
        return

    command = arg_map[arg]

    if isinstance(command, (list, tuple)):
        for i in command:
            run_arg(arg_map, i, ignore)
    else:
        run_arg(arg_map, command, ignore)


def make_shell_parser(arg_map: Dict[str, Any]):
    """
    Converts the python file into a terminal application with the commands in arg_map
    """
    parser = argparse.ArgumentParser()
    parser.add_argument("commands", help="list of commands to execute",
                        nargs='+', choices=sorted(arg_map.keys()))
    parser.add_argument(
        '-i', '--ignore', help="ignore prerequisites", action='store_true')

    args = parser.parse_args()

    for i in args.commands:
        run_arg(arg_map, i, args.ignore)


def sh(command: str, show=False):
    """
    runs a shell command using subprocess
    - show: whether to print the command
    """
    if show:
        print(command)
    subprocess.run([command], shell=True, check=True)


def last_modified(path: Path) -> float:
    """
    returns when the file was last modified
    """
    return path.stat().st_mtime


def needs_rebuild(out_files: List[Path], in_files: List[Path]) -> bool:
    """
    returns if any of the in_files were modified after the out_files and thus the out_files need to be rebuilt
    """
    # return True if any 'out' file does not exist or any 'in' file was made after an outfile

    # if 'out' file does not exist

    if not list(out_files):
        return True

    for out_file in out_files:
        if not out_file.is_file():
            return True

    # if any 'in' file was modified after the 'out' file was made
    for in_file in in_files:
        for out_file in out_files:
            if last_modified(in_file) > last_modified(out_file):
                return True
    return False


def mkdir(*folders: str):
    """
    makes folders
    """
    folders = [folder for folder in folders if folder.strip()]

    if folders:
        sh(f"mkdir -p {' '.join(folders)}")


def mkdirof(path: str):
    """
    makes the containing folder of a file
    """
    mkdir('/'.join(path.split('/')[:-1]))


def files_in(folder: Union[str, Path], recursive=False):
    """
    returns all files in the folder
    """
    if recursive:
        return [x for x in Path(folder).glob('**/*') if x.is_file()]
    else:
        return list(Path(folder).iterdir())


class Logger:
    arrow = f"==>"

    def _ANSI(n): return "\033[" + str(n) + 'm'

    RED = _ANSI(31)
    GREEN = _ANSI(32)
    BLUE = _ANSI(34)

    RESET = _ANSI(0)
    DIM = _ANSI(2)

    @classmethod
    def fortran_compile_start(cls, compiler: FortranCompiler):
        print(
            f"🛠️  Compiling: {cls.DIM}{compiler.source}{cls.RESET} {cls.arrow} {cls.BLUE}{compiler.obj}{cls.RESET}\n")

    @classmethod
    def fortran_linker_start(cls, linker: FortranLinker):
        print(
            f"⛓️  Linking: {cls.BLUE}{' '.join(linker.objs)}{cls.RESET} {cls.arrow} {cls.RED}{linker.bin}{cls.RESET}\n")

    @classmethod
    def fortran_execute_start(cls, executor: FortranExecutor):
        print(
            f'\033[92m ▶\033[00m Running: {cls.RED}{executor.bin}{cls.RESET}\n')

    @classmethod
    def latex_compiler_start(cls, compiler: LaTeXCompiler):
        print(
            f"📜 Compiling LaTeX: {cls.DIM}{compiler.filename}{cls.RESET} {cls.arrow} {cls.GREEN}{compiler.pdfname}{cls.RESET}\n")

    @classmethod
    def python_start(cls, script: PythonScript):
        print(
            f"🐍 Running Python Script: {cls.DIM}{script.source}{cls.RESET}\n")


class Command:
    def __init__(self):
        """
        Command is specified by three features:

        - action: the function the command is meant to execute
        - dependencies: the function(s)/command(s) that must be executed before the action, this is always run
        - prerequisites: boolean function(s) that specify whether action actually needs to be run
        - preruns: similar to dependencies, but only run upon satisfying prerequisites
        - postruns: the function(s)/command(s) that are executed after the action

        Note: the prerequisites are checked after the dependencies are executed
        """
        self.dependencies = []
        self.prerequisites = []
        self.preruns = []
        self.postruns = []
        self.add_postruns(lambda: print(''))

    def add_prerequisites(self, *prerequisites):
        self.prerequisites.extend(prerequisites)

    def add_dependencies(self, *dependencies):
        self.dependencies.extend(dependencies)

    def add_preruns(self, *preruns):
        self.preruns.extend(preruns)

    def add_postruns(self, *postruns):
        self.postruns.extend(postruns)

    def action(self):
        return

    def run(self, ignore=False):
        for command in self.dependencies:
            command()

        if not ignore and self.prerequisites:
            try:
                for prerequisite in self.prerequisites:
                    val = prerequisite()
                    if val is Bool.never:
                        return
                    elif val is Bool.maybe:
                        continue
                    elif val is Bool.always:
                        break  # if any prerequisite satisfied
                else:
                    return  # if all maybe
            except:  # error in evaluation any prerequisites
                pass

        for command in self.preruns:
            command()

        self.action()

        for command in self.postruns:
            command()

    def __call__(self, *args: Any, **kwds: Any) -> Any:
        self.run(*args, **kwds)


class FortranCompiler(Command):
    MOD_DIR = 'build/modules'

    def __init__(self, source: str, obj: str, *modules: FortranCompiler, remember=True, verbose=False):
        """
        Command to compile a source file into an object file
        - source: the file to compile
        - obj: the file to store the compiled object, use 'default' for default location
        - *modules (optional): sequence of modules this compiler should compile before this file
        - remember: whether to use the modules in linking
        """
        super().__init__()
        self.source = source
        self.obj = obj

        if self.obj.lower() == 'default':
            self.obj = f'build/obj/{self.source.replace(".f90", ".o")}'

        self.linker_modules = []

        self.add_modules(*modules, remember=remember)

        # rebuild obj only if source is changed
        self.add_prerequisites(lambda: needs_rebuild(
            [Path(self.obj)],
            [Path(self.source)]
        ))

        # precompile steps
        self.add_preruns(
            lambda: Logger.fortran_compile_start(self),
            lambda: mkdirof(self.obj),
            lambda: mkdir(self.MOD_DIR)
        )

        # flags
        self.flags = []
        self.add_flags(f'-J{self.MOD_DIR}')

        self.verbose = verbose

    def add_modules(self, *module_compilers: FortranCompiler, remember=True):
        """
        - module_compilers: sequence of compilers of modules that this fortran file uses, these modules are remembered when linking by default
        """
        self.add_dependencies(*module_compilers)
        if remember:
            self.linker_modules.extend(module_compilers)

    def add_flags(self, *flags: str):
        self.flags.extend(flags)

    def action(self):
        sh(f"gfortran {' '.join(self.flags)} -o {self.obj} -c {self.source}", self.verbose)


class FortranLinker(Command):
    def __init__(self, bin, *compilers: FortranCompiler, verbose=False):
        """
        Command to link object files made by compilers into a binary
        - bin: the binary file to make, use 'default:x' to store in default location with name x
        - *compilers: a sequence of compilers
        """
        super().__init__()
        self.add_dependencies(*compilers)

        all_compilers = [_ for _ in compilers]

        def find_compiler_recursive(compiler):
            for module in compiler.linker_modules:
                find_compiler_recursive(module)
            all_compilers.extend(compiler.linker_modules)

        for compiler in compilers:
            find_compiler_recursive(compiler)

        objs = [compiler.obj for compiler in all_compilers]

        # remove duplicate objs
        self.objs = []
        for obj in objs:
            if not obj in self.objs:
                self.objs.append(obj)

        self.bin = bin

        if self.bin.lower()[:len('default')] == 'default':
            self.bin = f'build/bin/{self.bin[len("default:"):]}.bin'

        # rebuild only if object files changed
        self.add_prerequisites(lambda: needs_rebuild(
            [Path(self.bin)],
            [Path(obj) for obj in self.objs]
        ))

        # prelink steps
        self.add_preruns(
            lambda: Logger.fortran_linker_start(self),
            lambda: mkdirof(self.bin)
        )

        # flags
        self.flags = []

        self.verbose = verbose

    def add_flags(self, *flags: str):
        self.flags.extend(flags)

    def action(self):
        sh(f"gfortran {' '.join(self.flags)} -o {self.bin} {' '.join(self.objs)}", self.verbose)

    @property
    def binary(self):
        """
        an object that can execute the binary made by linker
        """
        return FortranExecutor(self)


class FortranExecutor(Command):
    def __init__(self, linker):
        """
        Executes the binary made by 'linker'
        """
        super().__init__()
        self.add_dependencies(linker)
        self.bin = linker.bin
        self.add_preruns(
            lambda: Logger.fortran_execute_start(self)
        )

    def action(self):
        sh(f"{timer} ./{self.bin}")


class LaTeXCompiler(Command):
    def __init__(self, folder: str, filename: str, pdf_prereq=True):
        """
        Compiles a LaTeX file with folder as the working directory
        - folder: the folder containg the LaTeX document
        - filename: the name of the LaTeX document with .tex extension
        - pdf_prereq: whether to only build pdf when source file changes
        """
        super().__init__()
        self.folder = folder
        self.filename = filename
        self.pdfname = filename.replace('tex', 'pdf')

        self.file = f'{self.folder}/{self.filename}'
        self.pdf = f'{self.folder}/{self.pdfname}'

        self.add_preruns(
            lambda: Logger.latex_compiler_start(self)
        )

        # flags
        self.flags = []
        self.add_flags('-halt-on-error',
                       '-interaction=nonstopmode', '-file-line-error')

        if pdf_prereq:
            self.add_prerequisites(lambda: needs_rebuild(
                [Path(self.pdf)],
                [Path(self.file)]
            ))

    def add_flags(self, *flags: str):
        self.flags.extend(flags)

    def action(self):
        sh(f'cd {self.folder} && pdflatex {" ".join(self.flags)} {self.filename} 1>/dev/null')

    def clean(folder):
        sh(f'cd {folder} && rm -rf *.aux *.fdb_latexmk *.fls *.log *.gz')


class PythonScript(Command):
    def __init__(self, source: str, python='python3'):
        """
        Run a python script
        - source: the python file
        - python: the python interpreter
        """
        super().__init__()
        self.source = source
        self.python = python
        self.add_preruns(
            lambda: Logger.python_start(self)
        )

    def action(self):
        sh(f'{timer} {self.python} {self.source}')
