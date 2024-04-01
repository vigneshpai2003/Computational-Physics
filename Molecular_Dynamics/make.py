#!/usr/bin/env python3
import sys; sys.path.append('../')
from pymake import *
from pymake import FortranCompiler as Compiler, FortranLinker as Linker

c = {
    'md' : Compiler('src/md.f90', 'default'),
}

l = dict((name, Linker(f'default:{name}', compiler)) for name, compiler in c.items())

for compiler in [*c.values()]:
    compiler.add_flags('-O2')

for linker in [*l.values()]:
    linker.add_flags('-O2')

commands = {
    'all': ['md'],
    'md': l['md'].binary,
    'clean': lambda : (
        print('🔥 CLEANING'),
        sh(f'rm -rf build data'),
        print('')
    )
}

make_shell_parser(commands)
