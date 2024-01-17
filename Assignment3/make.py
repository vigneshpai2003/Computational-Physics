#!/usr/bin/env python3
import sys; sys.path.append('../')
from pymake import *
from pymake import FortranCompiler as Compiler, FortranLinker as Linker


ising = Compiler('src/ising.f90', 'default')

scratch = Compiler('src/scratch.f90', 'default', ising)
lscratch = Linker('default:scratch', scratch)


commands = {
    'scratch': lscratch.binary,
    'clean': lambda : (
        print('🔥 CLEANING'),
        sh(f'rm -rf build'),
        LaTeXCompiler.clean('tex'),
        print('')
    ),
}

make_shell_parser(commands)
