#!/usr/bin/env python3
from pymake import *

utils = Compiler('src/modules/utils.f90', 'obj/modules/utils.o')

a = Compiler('src/a.f90', 'obj/a.o')
a.add_modules(utils)

la = Linker('bin/a.bin', a, utils)

arg_map = {
    'a': Executor(la),
    'clean': lambda : (
        print('🔥 CLEANING'),
        sh('rm -rf bin obj modules', True)
    ),
}

make_shell_parser(arg_map)
