#!/usr/bin/env python3
import sys; sys.path.append('../')
from pymake import *
from pymake import FortranCompiler as Compiler, FortranLinker as Linker

md = Compiler('src/md.f90', 'default')
md.add_flags('-O2', '-fopenmp')

c = {
    'test' : Compiler('src/test.f90', 'default', md),
    '2' : Compiler('src/2.f90', 'default', md),
    '3' : Compiler('src/3.f90', 'default', md),
    '4' : Compiler('src/4.f90', 'default', md),
    '6' : Compiler('src/6.f90', 'default', md),
    '7' : Compiler('src/7.f90', 'default', md),
}

l = dict((name, Linker(f'default:{name}', compiler)) for name, compiler in c.items())

for compiler in [*c.values()]:
    compiler.add_flags('-O2')

for linker in [*l.values()]:
    linker.add_flags('-O2', '-fopenmp')

commands = {
    'all': ['test'],
    'test': l['test'].binary,
    '2': l['2'].binary,
    '3': l['3'].binary,
    '4': l['4'].binary,
    '6': l['6'].binary,
    '7': l['7'].binary,
    'clean': lambda : (
        print('🔥 CLEANING'),
        sh(f'rm -rf build data'),
        print('')
    )
}

make_shell_parser(commands)
