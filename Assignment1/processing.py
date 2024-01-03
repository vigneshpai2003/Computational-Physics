import matplotlib.pyplot as plt
import numpy as np

# Plotting 1h

with open("data/sumofrandnum1.dat") as f:
    x1 = [float(i) for i in f.readlines()[:-1]]

plt.hist(x1, np.arange(min(x1), max(x1), 0.5), density=True)
plt.xlabel('Sum of 10000 random numbers in [0, 1]')
plt.ylabel('Normalized count')
plt.title('Bin Size = 0.5')
plt.savefig('figures/1h_dx_0_5.png')
plt.clf()

plt.hist(x1, np.arange(min(x1), max(x1), 1), density=True)
plt.xlabel('Sum of 10000 random numbers in [0, 1]')
plt.ylabel('Normalized count')
plt.title('Bin Size = 1')
plt.savefig('figures/1h_dx_1.png')
plt.clf()

plt.hist(x1, np.arange(min(x1), max(x1), 2), density=True)
plt.xlabel('Sum of 10000 random numbers in [0, 1]')
plt.ylabel('Normalized count')
plt.title('Bin Size = 2')
plt.savefig('figures/1h_dx_2.png')
plt.clf()


with open("data/sumofrandnum2.dat") as f:
    x2 = [float(i) for i in f.readlines()[:-1]]

with open("data/sumofrandnum3.dat") as f:
    x3 = [float(i) for i in f.readlines()[:-1]]

plt.hist(x2, np.arange(min(x2), max(x2), 1), density=True, alpha=0.5)
plt.hist(x3, np.arange(min(x3), max(x3), 1), density=True, alpha=0.5)
plt.xlabel('Sum of 10000 random numbers in [-1, 1]')
plt.ylabel('Normalized count')
plt.title('Distributions of different sample sizes')
plt.legend(['Sample Size = $10^4$', 'Sample Size = $10^5$'])
plt.savefig('figures/1h_sample.png')
