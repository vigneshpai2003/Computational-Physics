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

y = read_array('data/scratch.dat')

plt.scatter(np.arange(len(y)) + 1, y, s=1)
plt.show()
