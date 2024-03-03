#!/usr/bin/env python3
import sys; sys.path.append('../')
from pymake import *
from pymake import FortranCompiler as Compiler, FortranLinker as Linker

ode = Compiler('src/ode.f90', 'default')

q1 = Compiler('src/1.f90', 'default', ode)
q5 = Compiler('src/5.f90', 'default', ode)
q8 = Compiler('src/8.f90', 'default', ode)
q8 = Compiler('src/9.f90', 'default')

lq1 = Linker('default:1', q1)
lq5 = Linker('default:5', q5)
lq8 = Linker('default:8', q8)
lq9 = Linker('default:9', q8)

# python plotting
plotter = PythonScript('plot.py', '../venv/bin/python3')
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
    '1': lq1.binary,
    '5': lq5.binary,
    '8': lq8.binary,
    '9': lq9.binary,
    'clean': lambda : (
        print('🔥 CLEANING'),
        sh(f'rm -rf build data figures'),
        LaTeXCompiler.clean('tex'),
        print('')
    ),
    'plot': plotter,
    'latex': latex
}

make_shell_parser(commands)
