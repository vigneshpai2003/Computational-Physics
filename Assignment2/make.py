#!/usr/bin/env python3
import sys; sys.path.append('../')
from pymake import *

integrate = FortranCompiler('src/modules/integrate.f90', 'obj/modules/integrate.o')

# assignment questions
q1 = FortranCompiler('src/1.f90', 'obj/1.o')
q1.add_modules(integrate)

q5 = FortranCompiler('src/5.f90', 'obj/5.o')
q5.add_modules(integrate)

l1 = FortranLinker('bin/1.bin', q1, integrate)
l5 = FortranLinker('bin/5.bin', q5, integrate)

# fortran file to run random stuff
scratch = FortranCompiler('src/scratch.f90', 'obj/scratch.o')
lscratch = FortranLinker('bin/scratch.bin', scratch)

commands = {
    '1': FortranExecutor(l1),
    '5': FortranExecutor(l5),
    'scratch': FortranExecutor(lscratch),
    'clean': lambda : (
        print('🔥 CLEANING'),
        sh(f'rm -rf bin obj {FortranCompiler.MOD_DIR} data'),
        print('')
    ),
}

make_shell_parser(commands)
