#!/usr/bin/env python3
import sys; sys.path.append('../')
from pymake import *
from pymake import FortranCompiler as Compiler, FortranLinker as Linker

c = {
    1 : Compiler('src/1.f90', 'default'),
    2 : Compiler('src/2.f90', 'default'),
}

l = dict()

for name, compiler in c.items():
    l[name] = Linker(f'default:{name}', compiler)

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
    'all': ['1', '2', 'plot', 'latex'],
    '1': l[1].binary,
    '2': l[2].binary,
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
