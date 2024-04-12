#!/usr/bin/env python3
import sys; sys.path.append('../')
from pymake import *
from pymake import FortranCompiler as Compiler, FortranLinker as Linker

md = Compiler('src/md.f90', 'default')
md.add_flags('-O2', '-fopenmp')

c = {
    'test' : Compiler('src/test.f90', 'default', md),
}

l = dict((name, Linker(f'default:{name}', compiler)) for name, compiler in c.items())

for compiler in [*c.values()]:
    compiler.add_flags('-O2')

for linker in [*l.values()]:
    linker.add_flags('-O2')

commands = {
    'all': ['test'],
    'test': l['test'].binary,
    'clean': lambda : (
        print('🔥 CLEANING'),
        sh(f'rm -rf build data'),
        print('')
    )
}

make_shell_parser(commands)
