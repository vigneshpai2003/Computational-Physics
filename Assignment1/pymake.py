from __future__ import annotations
from typing import Any, List, Union
import subprocess
from pathlib import Path
import argparse


MOD_DIR = 'modules'

timer = '/usr/bin/time --format="\\n Executed in %e seconds with %P CPU"'


def make_shell_parser(arg_map):
    parser = argparse.ArgumentParser()
    parser.add_argument("commands", help="list of commands to execute",
                        nargs='+', choices=sorted(arg_map.keys()))
    parser.add_argument(
        '-i', '--ignore', help="ignore prerequisites", action='store_true')

    args = parser.parse_args()

    for i in args.commands:
        if isinstance(arg_map[i], Command):
            arg_map[i](ignore=args.ignore)
        else:
            arg_map[i]()


def sh(command: str, show=False):
    """
    runs a shell command using subprocess
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


def make_containing_folder(path: str):
    """
    makes the containing folder of a file
    """
    sh(f"mkdir -p {'/'.join(path.split('/')[:-1])}")


def files_in(folder: Union[str, Path], recursive=False):
    """
    returns all files in the folder
    """
    if recursive:
        return [x for x in Path(folder).glob('**/*') if x.is_file()]
    else:
        return list(Path(folder).iterdir())


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

        if not ignore:
            try:
                for prerequisite in self.prerequisites:
                    if not prerequisite():
                        return  # if any prerequisite not satisfied
            except:  # error in evaluation any prerequisites
                pass

        for command in self.preruns:
            command()

        self.action()

        for command in self.postruns:
            command()

    def __call__(self, *args: Any, **kwds: Any) -> Any:
        self.run(*args, **kwds)


class Compiler(Command):
    def __init__(self, source: str, obj: str, MOD_DIR=MOD_DIR):
        """
        Command to compile a source file into an object file
        - source: the file to compile
        - obj: the file to store the compiled object
        - MOD_DIR: the folder to store .mod files
        """
        super().__init__()
        self.source = source
        self.obj = obj
        self.MOD_DIR = MOD_DIR
        self.add_prerequisites(lambda: needs_rebuild(
            [Path(self.obj)],
            [Path(self.source)]
        ))
        self.add_preruns(
            lambda: print(f"🛠️  Compiling: {self.source}"),
            lambda: make_containing_folder(self.obj),
            lambda: sh(f'mkdir -p {self.MOD_DIR}')
        )

    def action(self):
        sh(f"gfortran -J{self.MOD_DIR} -o {self.obj} -c {self.source}")


class Linker(Command):
    def __init__(self, bin, *compilers: List[Compiler]):
        """
        Command to link object files made by compilers into a binary
        - bin: the binary file to make
        - *compilers: a sequence of compilers
        """
        super().__init__()
        self.add_dependencies(*compilers)
        self.objs = [compiler.obj for compiler in compilers]
        self.bin = bin
        self.add_prerequisites(lambda: needs_rebuild(
            [Path(self.bin)],
            [Path(obj) for obj in self.objs]
        ))
        self.add_preruns(
            lambda: print(f"⛓️  Linking: {' '.join(self.objs)}"),
            lambda: make_containing_folder(self.bin)
        )

    def action(self):
        sh(f"gfortran -o {self.bin} {' '.join(self.objs)}")


class Executor(Command):
    def __init__(self, linker):
        """
        Executes the binary made by 'linker'
        """
        super().__init__()
        self.add_dependencies(linker)
        self.bin = linker.bin
        self.add_preruns(
            lambda: print(f'\033[92m ▶\033[00m Running: {self.bin}')
        )

    def action(self):
        sh(f"{timer} ./{self.bin}")


class LaTeXCompiler(Command):
    def __init__(self, folder: str, filename: str):
        """
        Compiles a LaTeX file with folder as the working directory
        - folder: the folder containg the LaTeX document
        - filename: the name of the LaTeX document with .tex extension
        """
        super().__init__()
        self.folder = folder
        self.filename = filename
        self.pdfname = filename.replace('tex', 'pdf')
        self.latex_command = 'pdflatex -halt-on-error -interaction=nonstopmode -file-line-error'
        self.add_preruns(
            lambda: print(f"📜 Compiling LaTeX: {self.filename}")
        )

    def action(self):
        sh(f'cd {self.folder} && {self.latex_command} {self.filename} 1>/dev/null')


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
            lambda: print(f"🐍 Running Python Script: {self.source}")
        )

    def action(self):
        sh(f'{timer} {self.python} {self.source}')
