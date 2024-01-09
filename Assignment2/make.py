#!/usr/bin/env python3
import sys; sys.path.append('../')
from pymake import *

FortranCompiler.MOD_DIR = 'jetharam'

utils = FortranCompiler('src/modules/utils.f90', 'obj/modules/utils.o')

a = FortranCompiler('src/a.f90', 'obj/a.o')
a.add_modules(utils)

l = FortranLinker('bin/a.bin', a, utils)

arg_map = {
    'all': FortranExecutor(l),
    'clean': lambda : (
        print('🔥 CLEANING'),
        sh(f'rm -rf bin obj modules jetharam'),
        print('')
    ),
}

make_shell_parser(arg_map)
