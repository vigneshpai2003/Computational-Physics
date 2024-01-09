#!/usr/bin/env python3
from pymake import *

#  compilers and linkers
utils = Compiler('src/modules/utils.f90', 'obj/modules/utils.o')
hist = Compiler('src/modules/hist.f90', 'obj/modules/hist.o')
hist.add_modules(utils)

f0 = Compiler('src/0.f90', 'obj/0.o')
f1 = Compiler('src/1.f90', 'obj/1.o')
f1.add_modules(utils)

l0 = Linker('bin/q0.bin', f0)
l1 = Linker('bin/q1.bin', f1, utils)

# post processing with fortran
fp = Compiler('src/processing.f90', 'obj/processing.o')
fp.add_modules(hist)

f_postprocessor = Executor(Linker('bin/processing.bin', fp, hist, utils))
f_postprocessor.add_prerequisites(lambda: needs_rebuild(
    files_in('data/figure_data', True),
    files_in('data')
))

# post processing with python
py_postprocessor = PythonScript('plot.py', '../venv/bin/python3')
py_postprocessor.add_prerequisites(lambda: needs_rebuild(
    files_in('figures', True),
    [Path(py_postprocessor.source)] + files_in('data', True)
))
py_postprocessor.add_preruns(
    lambda: sh('mkdir -p figures')
)

# latex compiler
latex = LaTeXCompiler('tex', 'submission.tex')
latex.add_prerequisites(lambda: needs_rebuild(
    [Path(latex.pdfname)],
    [Path(latex.filename)] + files_in('figures', True)
))

arg_map = {
    'build': lambda: (l0(), l1()),
    'run': lambda: (Executor(l0)(), Executor(l1)()),
    'process': f_postprocessor,
    'plot': py_postprocessor,
    'latex': latex,
    'clean': lambda: (
        print("🔥 CLEANING"),
        sh(f'rm -rf obj bin modules'),
        sh(f'cd tex && rm -rf *.pdf *.aux *.fdb_latexmk *.fls *.log *.gz'),
        sh(f'rm -rf data'),
        sh(f'rm -rf figures'),
        print('')
    ),
}

arg_map['all'] = lambda: (
    arg_map['run'](),
    arg_map['process'](),
    arg_map['plot'](),
    arg_map['latex']()
)

make_shell_parser(arg_map)
