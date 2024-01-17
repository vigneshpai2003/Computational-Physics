#!/usr/bin/env python3
import sys; sys.path.append('../')
from pymake import *
from pymake import FortranCompiler as Compiler, FortranLinker as Linker

ising = Compiler('src/ising.f90', 'default')

scratch = Compiler('src/scratch.f90', 'default', ising)
lscratch = Linker('default:scratch', scratch)

c3 = Compiler('src/3.f90', 'default', ising)
l3 = Linker('default:3', c3)

plotter = PythonScript('plot.py', '../venv/bin/python3')
plotter.add_prerequisites(lambda: needs_rebuild(
    files_in('figures', True),
    [Path(plotter.source)] + files_in('data', True)
))
plotter.add_preruns(
    lambda: mkdir('figures')
)

commands = {
    '3': l3.binary,
    'scratch': lscratch.binary,
    'clean': lambda : (
        print('🔥 CLEANING'),
        sh(f'rm -rf build data figures'),
        LaTeXCompiler.clean('tex'),
        print('')
    ),
    'plot': plotter
}

make_shell_parser(commands)
