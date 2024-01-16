#!/usr/bin/env python3
import sys; sys.path.append('../')
from pymake import *
from pymake import FortranCompiler as Compiler, FortranLinker as Linker


commands = {
    'clean': lambda : (
        print('🔥 CLEANING'),
        sh(f'rm -rf build'),
        LaTeXCompiler.clean('tex'),
        print('')
    ),
}

make_shell_parser(commands)
