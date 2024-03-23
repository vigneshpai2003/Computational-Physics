#!/usr/bin/env python3
import sys; sys.path.append('../')
from pymake import *
from pymake import FortranCompiler as Compiler, FortranLinker as Linker

quantum = Compiler('src/quantum.f90', 'default')

c = {
    'v' : Compiler('src/variational.f90', 'default', quantum),
}

l = dict((name, Linker(f'default:{name}', compiler)) for name, compiler in c.items())

for compiler in [quantum, *c.values()]:
    compiler.add_flags('-O2')

for linker in [*l.values()]:
    linker.add_flags('-O2', '-llapack')

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
    'all': ['v', 'plot', 'latex'],
    'v': l['v'].binary,
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
