#!/usr/bin/env python3
import sys; sys.path.append('../')
from pymake import *

utils = FortranCompiler('src/modules/utils.f90', 'obj/modules/utils.o')

a = FortranCompiler('src/a.f90', 'obj/a.o')
a.add_modules(utils)

la = FortranLinker('bin/a.bin', a, utils)

arg_map = {
    'a': FortranExecutor(la),
    'clean': lambda : (
        print('🔥 CLEANING'),
        sh(f'rm -rf bin obj {FortranCompiler.MOD_DIR}', True)
    ),
}

make_shell_parser(arg_map)
