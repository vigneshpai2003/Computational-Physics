#!/usr/bin/env python3
from __future__ import annotations
from typing import Any, List
import subprocess
from pathlib import Path
import argparse


OBJ_DIR = 'obj'
SRC_DIR = 'src'
BIN_DIR = 'bin'
TEX_DIR = 'tex'
DATA_DIR = 'data'
FIG_DIR = 'figures'

OBJ_EXT = 'o'

timer = '/usr/bin/time --format="\\n Executed in %e seconds with %P CPU"'


def run_shell(command: str, show=False):
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
    run_shell(f"mkdir -p {'/'.join(path.split('/')[:-1])}")


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
            if not ignore and self.prerequisite():
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
        run_shell(f"gfortran -J{OBJ_DIR} -o {self.obj} -c {self.source}")

    def prerequisite(self):
        return needs_rebuild([Path(self.obj)], [Path(self.source)])


class Linker(Command):
    def __init__(self, bin, *compilers: List[Compiler]):
        super().__init__()
        self.dependencies = compilers
        self.objs = [compiler.obj for compiler in compilers]
        self.bin = f'{BIN_DIR}/{bin}'

    def action(self):
        print(f"⛓️  Linking: {' '.join(self.objs)}")
        make_containing_folder(self.bin)
        run_shell(f"gfortran -o {self.bin} {' '.join(self.objs)}")

    def prerequisite(self):
        return needs_rebuild([Path(self.bin)], [Path(obj) for obj in self.objs])


class Executor(Command):
    def __init__(self, linker):
        super().__init__()
        self.dependencies = [linker]
        self.bin = linker.bin

    def action(self):
        print(f'\033[92m ▶\033[00m Running: {self.bin}')
        run_shell(f"mkdir -p {DATA_DIR}")
        run_shell(f"{timer} ./{self.bin}")


class DataProcessor(Command):
    def __init__(self, source: str):
        super().__init__()
        self.source = source

    def action(self):
        run_shell(f'mkdir -p {FIG_DIR}')
        print(f"🌊 Processing Data: {self.source}")
        run_shell(f'{timer} ../venv/bin/python3 {self.source}')

    def prerequisite(self) -> bool:
        return needs_rebuild(Path(FIG_DIR).iterdir(), Path(DATA_DIR).iterdir())


class LaTeXCompiler(Command):
    def __init__(self, source: str):
        super().__init__()
        self.source = source

    def action(self):
        print(f"📜 Compiling LaTeX: {self.source}.tex")
        run_shell(
            f'cd {TEX_DIR} && pdflatex -halt-on-error -interaction=nonstopmode -file-line-error {self.source}.tex 1>/dev/null')

    def prerequisite(self) -> bool:
        return needs_rebuild([Path(f'{TEX_DIR}/{self.source}.pdf')], [Path(f'{TEX_DIR}/{self.source}.tex'), *Path(FIG_DIR).iterdir()])


class Cleaner:
    def clean_build():
        run_shell(f'rm -rf {OBJ_DIR} {BIN_DIR}')

    def clean_latex():
        run_shell(
            f'cd {TEX_DIR} && rm -rf *.pdf *.aux *.fdb_latexmk *.fls *.log *.gz')

    def clean_data():
        run_shell(f'rm -rf {DATA_DIR}')

    def clean_figures():
        run_shell(f'rm -rf figures')

    def clean():
        print("🔥 CLEANING")
        Cleaner.clean_build()
        Cleaner.clean_data()
        Cleaner.clean_figures()
        Cleaner.clean_latex()
        print('')


def make_shell_parser(arg_map):
    parser = argparse.ArgumentParser()
    parser.add_argument("commands", help="list of commands to execute",
                        nargs='+', choices=sorted(arg_map.keys()))
    for i in parser.parse_args().commands:
        arg_map[i]()


utils = Compiler('modules/utils.f90')

l0 = Linker('q0.bin', Compiler('0.f90'))
l1 = Linker('q1.bin', utils, Compiler('1.f90'))

arg_map = {
    'build': lambda: (l0(), l1()),
    'run': lambda: (Executor(l0)(), Executor(l1)()),
    'process': DataProcessor('processing.py'),
    'latex': LaTeXCompiler('submission'),
    'clean': Cleaner.clean,
}

arg_map['all'] = lambda: (
    arg_map['run'](),
    arg_map['process'](),
    arg_map['latex']()
)

make_shell_parser(arg_map)
