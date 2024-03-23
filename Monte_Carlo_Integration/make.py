#!/usr/bin/env python3
import sys; sys.path.append('../')
from pymake import *
from pymake import FortranCompiler as Compiler, FortranLinker as Linker

integrate = Compiler('src/modules/integrate.f90', 'default')
random = Compiler('src/modules/random.f90', 'default')
mc = Compiler('src/modules/mc.f90', 'default', random)

# assignment questions
q1 = Compiler('src/1.f90', 'default', integrate)
q2 = Compiler('src/2.f90', 'default', random)
q4 = Compiler('src/4.f90', 'default', random)
q5 = Compiler('src/5.f90', 'default', integrate, mc)

l1 = Linker('default:1', q1)
l2 = Linker('default:2', q2)
l4 = Linker('default:4', q4)
l5 = Linker('default:5', q5)

# fortran file to run random stuff
scratch = Compiler('src/scratch.f90', 'default', integrate)
lscratch = Linker('default:scratch', scratch)

# python plotting
plotter = PythonScript('plot.py', 'python3')
plotter.add_prerequisites(lambda: needs_rebuild(
    files_in('figures', True),
    [Path(plotter.source)] + files_in('data', True)
))
plotter.add_preruns(
    lambda: mkdir('figures')
)

# latex compiler
latex = LaTeXCompiler('tex', 'submission.tex')
latex.add_prerequisites(lambda: needs_rebuild(
    [Path(latex.pdf)],
    files_in('figures', True) + files_in('data', True)
))

commands = {
    '1': l1.binary,
    '2': l2.binary,
    '4': l4.binary,
    '5': l5.binary,
    'quantum': Linker('default:quantum', Compiler('src/quantum.f90', 'default', mc)).binary,
    'plot': plotter,
    'latex': latex,
    'build': ('1', '2', '4', '5', 'quantum'),
    'all': ('build', 'plot', 'latex'),
    'scratch': lscratch.binary,
    'clean': lambda : (
        print('🔥 CLEANING'),
        sh(f'rm -rf build data figures'),
        LaTeXCompiler.clean('tex'),
        print('')
    ),
    'theory': LaTeXCompiler('tex', 'theory.tex'),
}

make_shell_parser(commands)
