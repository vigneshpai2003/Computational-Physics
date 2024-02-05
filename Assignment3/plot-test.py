import matplotlib.pyplot as plt
import numpy as np

def savefig(filename):
    plt.savefig(f'figures/{filename}', bbox_inches='tight', dpi=500)
    plt.clf()

def calc_eq_val(array, percentage=1):
    n = int(len(array) * (1 - percentage))
    return np.average(array[n:])

def read_array(filename):
    with open(filename) as f:
        return np.float_(f.readlines())

E = read_array('data/test/E.dat')
M = read_array('data/test/M.dat')

plt.scatter(np.arange(len(M)) + 1, M, s=1)
plt.scatter(np.arange(len(E)) + 1, E, s=1)
plt.show()
