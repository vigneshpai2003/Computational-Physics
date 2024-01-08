from __future__ import annotations
from typing import Any, List, Union
import subprocess
from pathlib import Path
import argparse


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


OBJ_DIR = 'obj'
SRC_DIR = 'src'
BIN_DIR = 'bin'
TEX_DIR = 'tex'
DATA_DIR = 'data'
FIG_DIR = 'figures'

OBJ_EXT = 'o'

timer = '/usr/bin/time --format="\\n Executed in %e seconds with %P CPU"'

VIRTUAL_ENV = 'venv/bin/python3'


def sh(command: str, show=False):
    if show:
        print(command)
    subprocess.run([command], shell=True)


def last_modified(path: Path) -> float:
    return path.stat().st_mtime


def needs_rebuild(out_files: List[Path], in_files: List[Path]) -> bool:
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
    sh(f"mkdir -p {'/'.join(path.split('/')[:-1])}")


def files_in(folder: Union[str, Path], recursive=False):
    if recursive:
        return [x for x in Path(folder).glob('**/*') if x.is_file()]
    else:
        return list(Path(folder).iterdir())


class Command:
    def __init__(self):
        self.dependencies = []

    def prerequisite(self) -> bool:
        return True

    def action(self):
        return

    def run(self, ignore=False):
        for command in self.dependencies:
            command.run()

        try:
            if ignore or (not ignore and self.prerequisite()):
                self.action()
                print('')
        except:
            self.action()
            print('')

    def __call__(self, *args: Any, **kwds: Any) -> Any:
        self.run(*args, **kwds)


class Compiler(Command):
    def __init__(self, source: str):
        super().__init__()
        self.source = f'{SRC_DIR}/{source}'
        self.obj = f'{OBJ_DIR}/{source.replace("f90", OBJ_EXT)}'

    def action(self):
        print(f"🛠️  Compiling: {self.source}")
        make_containing_folder(self.obj)
        sh(f"gfortran -J{OBJ_DIR} -o {self.obj} -c {self.source}")

    def prerequisite(self):
        return needs_rebuild(
            [Path(self.obj)],
            [Path(self.source)]
        )


class Linker(Command):
    def __init__(self, bin, *compilers: List[Compiler]):
        super().__init__()
        self.dependencies = compilers
        self.objs = [compiler.obj for compiler in compilers]
        self.bin = f'{BIN_DIR}/{bin}'

    def action(self):
        print(f"⛓️  Linking: {' '.join(self.objs)}")
        make_containing_folder(self.bin)
        sh(f"gfortran -o {self.bin} {' '.join(self.objs)}")

    def prerequisite(self):
        return needs_rebuild(
            [Path(self.bin)],
            [Path(obj) for obj in self.objs]
        )


class Executor(Command):
    def __init__(self, linker):
        super().__init__()
        self.dependencies = [linker]
        self.bin = linker.bin

    def action(self):
        print(f'\033[92m ▶\033[00m Running: {self.bin}')
        sh(f"mkdir -p {DATA_DIR}")
        sh(f"{timer} ./{self.bin}")


class DataProcessor(Command):
    def __init__(self, source: str):
        super().__init__()
        self.source = source

    def action(self):
        sh(f'mkdir -p {FIG_DIR}')
        print(f"🌊 Processing Data: {self.source}")
        sh(f'{timer} ../{VIRTUAL_ENV} {self.source}')

    def prerequisite(self) -> bool:
        return needs_rebuild(
            files_in(FIG_DIR, True),
            [Path(self.source)] + files_in(DATA_DIR, True)
        )


class LaTeXCompiler(Command):
    def __init__(self, name: str):
        super().__init__()
        self.name = name
        self.latex_command = 'pdflatex -halt-on-error -interaction=nonstopmode -file-line-error'

    def action(self):
        print(f"📜 Compiling LaTeX: {self.name}.tex")
        sh(f'cd {TEX_DIR} && {self.latex_command} {self.name}.tex 1>/dev/null')

    def prerequisite(self) -> bool:
        return needs_rebuild([Path(f'{TEX_DIR}/{self.name}.pdf')],
                             [Path(f'{TEX_DIR}/{self.name}.tex')] + files_in(FIG_DIR, True))


class Cleaner:
    def clean_build():
        sh(f'rm -rf {OBJ_DIR} {BIN_DIR}')

    def clean_latex():
        sh(f'cd {TEX_DIR} && rm -rf *.pdf *.aux *.fdb_latexmk *.fls *.log *.gz')

    def clean_data():
        sh(f'rm -rf {DATA_DIR}')

    def clean_figures():
        sh(f'rm -rf figures')

    def clean():
        print("🔥 CLEANING")
        Cleaner.clean_build()
        Cleaner.clean_data()
        Cleaner.clean_figures()
        Cleaner.clean_latex()
        print('')
