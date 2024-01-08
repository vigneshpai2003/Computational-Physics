#!/usr/bin/env python3
from pymake import *

utils = Compiler('modules/utils.f90')

l0 = Linker('q0.bin', Compiler('0.f90'))
l1 = Linker('q1.bin', utils, Compiler('1.f90'))
lprocessing = Linker('processing.bin', utils, Compiler('processing.f90'))

arg_map = {
    'build': lambda: (l0(), l1()),
    'run': lambda: (Executor(l0)(), Executor(l1)()),
    'process': Executor(lprocessing),
    'plot': DataProcessor('plot.py'),
    'latex': LaTeXCompiler('submission'),
    'clean': Cleaner.clean,
}

arg_map['all'] = lambda: (
    arg_map['run'](),
    arg_map['process'](),
    arg_map['plot'](),
    arg_map['latex']()
)

make_shell_parser(arg_map)
