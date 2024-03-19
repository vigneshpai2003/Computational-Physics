#!/usr/bin/env python3
import sys; sys.path.append('../')
from pymake import *
from pymake import FortranCompiler as Compiler, FortranLinker as Linker

utils = Compiler('src/modules/utils.f90', 'default')
ode = Compiler('src/modules/ode.f90', 'default')

c = {
    'rd1' : Compiler('src/rd1.f90', 'default', utils),
    'rd2' : Compiler('src/rd2.f90', 'default', utils),
    'rd3' : Compiler('src/rd3.f90', 'default', utils),
    'd1' : Compiler('src/diffusion1.f90', 'default', utils),
    'd2' : Compiler('src/diffusion2.f90', 'default', utils),
    'fn' : Compiler('src/fn_ode.f90', 'default', utils, ode),
}

for compiler in [utils, ode, *c.values()]:
    compiler.add_flags('-O2')

l = dict((name, Linker(f'default:{name}', compiler)) for name, compiler in c.items())

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
    'all': ['fn', 'd1', 'd2', 'rd1', 'rd2', 'rd3', 'plot', 'latex'],
    'rd1': l['rd1'].binary,
    'rd2': l['rd2'].binary,
    'rd3': l['rd3'].binary,
    'fn': l['fn'].binary,
    'd1': l['d1'].binary,
    'd2': l['d2'].binary,
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
