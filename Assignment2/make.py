#!/usr/bin/env python3
import sys; sys.path.append('../')
from pymake import *

integrate = FortranCompiler('src/modules/integrate.f90', 'obj/modules/integrate.o')
randomtest = FortranCompiler('src/modules/randomtest.f90', 'obj/modules/randomtest.o')

# assignment questions
q1 = FortranCompiler('src/1.f90', 'obj/1.o')
q1.add_modules(integrate)

q2 = FortranCompiler('src/2.f90', 'obj/2.o')
q2.add_modules(randomtest)

q5 = FortranCompiler('src/5.f90', 'obj/5.o')
q5.add_modules(integrate)

l1 = FortranLinker('bin/1.bin', q1)
l2 = FortranLinker('bin/2.bin', q2)
l5 = FortranLinker('bin/5.bin', q5)

# fortran file to run random stuff
scratch = FortranCompiler('src/scratch.f90', 'obj/scratch.o')
scratch.add_modules(integrate)

lscratch = FortranLinker('bin/scratch.bin', scratch, integrate)

commands = {
    '1': FortranExecutor(l1),
    '2': FortranExecutor(l2),
    '5': FortranExecutor(l5),
    'scratch': FortranExecutor(lscratch),
    'clean': lambda : (
        print('🔥 CLEANING'),
        sh(f'rm -rf bin obj {FortranCompiler.MOD_DIR} data'),
        print('')
    ),
}

make_shell_parser(commands)
