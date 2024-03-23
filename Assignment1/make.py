#!/usr/bin/env python3
import sys; sys.path.append('../')
from pymake import *

#  compilers and linkers
utils = FortranCompiler('src/modules/utils.f90', 'default')
hist = FortranCompiler('src/modules/hist.f90', 'default', utils)

f0 = FortranCompiler('src/0.f90', 'default')
f1 = FortranCompiler('src/1.f90', 'default', utils)

l0 = FortranLinker('default:q0', f0)
l1 = FortranLinker('default:q1', f1)

# post processing with fortran
fp = FortranCompiler('src/processing.f90', 'default', hist)

f_postprocessor = FortranLinker('default:processing', fp, hist, utils).binary
f_postprocessor.add_prerequisites(lambda: needs_rebuild(
    files_in('data/figure_data', True),
    files_in('data')
))

# post processing with python
py_postprocessor = PythonScript('plot.py', 'python3')
py_postprocessor.add_prerequisites(lambda: needs_rebuild(
    files_in('figures', True),
    [Path(py_postprocessor.source)] + files_in('data', True)
))
py_postprocessor.add_preruns(
    lambda: mkdir('figures')
)

# latex compiler
latex = LaTeXCompiler('tex', 'submission.tex')
latex.add_prerequisites(lambda: needs_rebuild(
    [Path(latex.pdf)],
    files_in('figures', True)
))

arg_map = {
    'all': ('run', 'process', 'plot', 'latex'),
    'build': (l0, l1),
    'run': (l0.binary, l1.binary),
    'process': f_postprocessor,
    'plot': py_postprocessor,
    'latex': latex,
    'clean': lambda: (
        print("🔥 CLEANING"),
        sh(f'rm -rf build data figures'),
        LaTeXCompiler.clean('tex'),
        print('')
    ),
}

make_shell_parser(arg_map)
