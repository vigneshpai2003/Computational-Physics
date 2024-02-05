#!/usr/bin/env python3
import sys; sys.path.append('../')
from pymake import *
from pymake import FortranCompiler as Compiler, FortranLinker as Linker

ising = Compiler('src/ising.f90', 'default')
ising.add_flags('-O2')

scratch = Compiler('src/scratch.f90', 'default', ising)
lscratch = Linker('default:scratch', scratch)

test = Compiler('src/test.f90', 'default', ising)
ltest = Linker('default:test', test)

c3 = Compiler('src/3.f90', 'default', ising)
c4 = Compiler('src/4.f90', 'default', ising)
c5 = Compiler('src/5.f90', 'default', ising)
c6 = Compiler('src/6.f90', 'default', ising)
cf = Compiler('src/f.f90', 'default', ising)
cf.add_flags('-O2', '-fopenmp')

l3 = Linker('default:3', c3)
l4 = Linker('default:4', c4)
l5 = Linker('default:5', c5)
l6 = Linker('default:6', c6)
lf = Linker('default:f', cf)
lf.add_flags('-O2', '-fopenmp')

# python plotting
plotter = PythonScript('plot.py', '../venv/bin/python3')
plotter.add_prerequisites(lambda: needs_rebuild(
    files_in('figures', True),
    [Path(plotter.source)] + files_in('data', True)
))
plotter.add_preruns(
    lambda: mkdir('figures')
)

plotter_test = PythonScript('plot-test.py', '../venv/bin/python3')
plotter_test.add_prerequisites(lambda: needs_rebuild(
    files_in('figures', True),
    [Path(plotter.source)] + files_in('data/test', True)
))
plotter_test.add_preruns(
    lambda: mkdir('figures')
)

# latex compiler
latex = LaTeXCompiler('tex', 'submission.tex')
latex.add_prerequisites(lambda: needs_rebuild(
    [Path(latex.pdf)],
    files_in('figures', True) + files_in('data', True)
))

commands = {
    'all': ['3', '4', '5', '6', 'f', 'plot', 'latex'],
    '3': l3.binary,
    '4': l4.binary,
    '5': l5.binary,
    '6': l6.binary,
    'f': lf.binary,
    'scratch': lscratch.binary,
    'test': ltest.binary,
    'clean': lambda : (
        print('🔥 CLEANING'),
        sh(f'rm -rf build data figures'),
        LaTeXCompiler.clean('tex'),
        print('')
    ),
    'plot': plotter,
    'plot-test': plotter_test,
    'latex': latex
}

make_shell_parser(commands)
