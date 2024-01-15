import matplotlib.pyplot as plt
import numpy as np
from scipy.stats import linregress

def myhist(arr, bins):
    count, bins = np.histogram(arr, bins, density=True)
    x = (bins[:-1] + bins[1:]) / 2
    plt.scatter(x, count)

def read_array(f):
    return [float(i) for i in f.readlines()]

def savefig(filename):
    plt.savefig(f'figures/{filename}', bbox_inches='tight', dpi=500)
    plt.clf()

# 1b
with open('data/1b_dx.dat') as f:
    x = read_array(f)
    x = [1/i for i in x]

with open('data/1b_err.dat') as f:
    y = read_array(f)

slope, *_ = linregress(np.log(x), np.log(y))
plt.scatter(x, y)
plt.xlabel('Number of Divisions of Domain')
plt.ylabel('Error in Trapezoidal Integration')
plt.title('$\int_0^1 \\frac{1}{1 + x^2}dx$\n')
plt.legend([f'slope={round(slope, 2)}'])
plt.xscale('log')
plt.yscale('log')
savefig('1b')

# 2
with open('data/2_array.dat') as f:
    array = read_array(f)

# 2a
myhist(array, 100)
plt.xlabel('Samples of Random Variable')
plt.ylabel('Normalized count')
plt.title('Distribution of Uniform Random Variable in $[0, 1]$')
savefig('2a')

# 2b
N = 100
plt.plot(array[:N-1], array[1:N])
plt.xlabel('$x_i$')
plt.ylabel('$x_{i+1}$')
savefig('2b')

with open('data/2_correlation.dat') as f:
    correlations = read_array(f)

# 2c
plt.plot(range(len(correlations)), correlations)
plt.xlabel('k')
plt.ylabel('Auto Correlation ($C_k$)')
plt.title('Correlation Function of Uniform Random Variable in [0, 1]')
savefig('2c')

with open('data/2_moments.dat') as f:
    moments = read_array(f)

# 2d
x = np.arange(1, len(moments) + 1)
mu = moments[1]
sd = np.sqrt(moments[2] - moments[1]**2)
plt.scatter(x, abs(np.array(moments) - 1 / x))
plt.xlabel('k')
plt.ylabel('Error in $k^{th}$ Moment')
plt.title('Moments of Uniform Random Variable in $[0, 1]$')
plt.legend([f'$\mu={round(mu, 4)}$\n$\sigma={round(sd, 4)}$'])
plt.ylim((10**(-8), 10**(-2)))
plt.yscale('log')
savefig('2d')

# 4a
with open('data/4a.dat') as f:
    array = np.array(read_array(f))

mu = sum(array) / len(array)
sigma = np.sqrt(sum(array**2) / len(array) - mu**2)

myhist(array, 1000)
plt.xlabel('Samples of Random Variable')
plt.ylabel('Normalized count')
plt.title(f'Distribution of Exponential Random Variable\n$\\mu={round(mu, 4)}$  $\\sigma={round(sigma, 4)}$')
plt.legend(["$\\rho(x)=2e^{-2x}$"])
savefig('4a')

# 4b
with open('data/4b.dat') as f:
    array = np.array(read_array(f))

mu = sum(array) / len(array)
sigma = np.sqrt(sum(array**2) / len(array) - mu**2)

myhist(array, 1000)
plt.xlabel('Samples of Random Variable')
plt.ylabel('Normalized count')
plt.title(f'Distribution of Gaussian Random Variable\n$\\mu={round(mu, 4)}$  $\\sigma={round(sigma, 4)}$')
plt.legend([r"$\rho(x)=\frac{1}{\sqrt{8\pi}} \exp\left(-\frac{x^2}{8}\right)$"])
savefig('4b')
