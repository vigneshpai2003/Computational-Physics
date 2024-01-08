import matplotlib.pyplot as plt
import numpy as np
from scipy.stats import norm, linregress


def fit_on_plot(a):
    mu, sigma = norm.fit(a)
    x = np.arange(min(a), max(a), 0.5)
    y = norm.pdf(x, mu, sigma)
    plt.plot(x, y, c='black')
    return mu, sigma


def add_plot_labels(xlabel, ylabel, title, fitx=None):
    if fitx:
        mu, sigma = fit_on_plot(fitx)
        plt.title(
            title + f'\n$\mu={round(mu, 2)}$, $\sigma={round(sigma, 2)}$, $\sigma^2={round(sigma**2, 2)}$')
    else:
        plt.title(title)
    plt.xlabel(xlabel)
    plt.ylabel(ylabel)


def savefig(filename):
    plt.savefig(f'figures/{filename}', bbox_inches='tight', dpi=500)
    plt.clf()


def read_array(filename):
    with open(f'data/{filename}') as f:
        return [float(i) for i in f.readlines()]


def read_hist(foldername):
    return read_array(f"{foldername}/x.dat"), read_array(f"{foldername}/y.dat")


# Plotting 1g
y = read_array("averages.dat")
x = [10, 100, 1000, 10000, 100000, 1000000]
plt.scatter(x, y)
plt.xscale('log')
plt.yscale('log')
slope, *_ = linregress(np.log(x), np.log(y))
add_plot_labels(
    xlabel='Sample Size',
    ylabel='Deviation from 0.5',
    title=f'slope = ${round(slope, 4)}$'
)
savefig('1g.png')

# Plotting 1h
raw = read_array('sumofrandnum1.dat')

for bin_size in [0.5, 1, 2]:
    bin_size_str = str(bin_size).replace(".", "_")

    plt.scatter(*read_hist(f'1h_dx_{bin_size_str}'))
    add_plot_labels(
        xlabel='Sum of 10000 random numbers in [0, 1]',
        ylabel='Normalized count',
        title=f'Bin Size = {bin_size}',
        fitx=raw
    )
    savefig(f'1h_dx_{bin_size_str}.png')

raw = read_array('sumofrandnum3.dat')

plt.scatter(*read_hist('1h_sample_a'))
plt.scatter(*read_hist('1h_sample_b'))
add_plot_labels(
    xlabel='Sum of 10000 random numbers in [-1, 1]',
    ylabel='Normalized count',
    title='Distributions of different sample sizes',
    fitx=raw
)
plt.legend(['Sample Size = $10^4$', 'Sample Size = $10^5$'])
savefig('1h_sample.png')

# Plotting 1i, 1j
raw = read_array('randomwalk1.dat')

for bin_size in [1, 2, 5, 10]:
    plt.scatter(*read_hist(f'1ij_dx_{bin_size}'))
    add_plot_labels(
        xlabel='Random walk of $10^4$ steps',
        ylabel='Normalized count ($10^4$ walks)',
        title=f'Bin Size = {bin_size}',
        fitx=raw
    )
    savefig(f'1ij_dx_{bin_size}.png')

plt.scatter(*read_hist('1ij_shifted_a'), alpha=0.5)
plt.scatter(*read_hist('1ij_shifted_b'), alpha=0.5)
add_plot_labels(
    xlabel='Random walk of $10^4$ steps',
    ylabel='Normalized count ($10^4$ walks)',
    title='Bin Size = 2'
)
plt.legend(['bins starting at 0', 'bins starting at 1'])
savefig(f'1ij_shifted.png')

# Plotting 1k
raw = read_array('randomwalk2.dat')
plt.scatter(*read_hist('1k'))
add_plot_labels(
    xlabel='Random walk of $10^4$ steps',
    ylabel='Normalized count ($10^5$ walks)',
    title='Bin Size = 2',
    fitx=raw
)
savefig('1k.png')

# Plotting 1l
raw = read_array('randomwalk3.dat')
plt.scatter(*read_hist('1l'))
add_plot_labels(
    xlabel='Random walk of $10^5$ steps',
    ylabel='Normalized count ($10^5$ walks)',
    title='Bin Size = 2',
    fitx=raw
)
savefig('1l.png')
