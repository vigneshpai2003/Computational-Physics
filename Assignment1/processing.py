import matplotlib.pyplot as plt
import numpy as np

with open("sumofrandnum.dat") as f:
    x = [float(i) for i in f.read().split('\n')[:-1]]
    plt.hist(x, np.arange(min(x), max(x), 2), density=True)
    plt.show()
