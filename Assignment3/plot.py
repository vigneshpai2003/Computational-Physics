import matplotlib.pyplot as plt
import numpy as np

def savefig(filename):
    plt.savefig(f'figures/{filename}', bbox_inches='tight', dpi=500)
    plt.clf()

with open('data/3.dat') as f:
    y = np.float_(f.readlines())

plt.scatter(np.arange(len(y)) + 1, y, s=1)
plt.xlabel('Iteration Number')
plt.ylabel('Average Magnetization')
savefig('3.png')
