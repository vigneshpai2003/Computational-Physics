import matplotlib.pyplot as plt
import numpy as np
from scipy.stats import norm, linregress


def fit_on_plot(a):
    mu, sigma = norm.fit(a)
    x = np.arange(min(a), max(a), 0.5)
    y = norm.pdf(x, mu, sigma)
    plt.plot(x, y, c='black')
    return mu, sigma


def make_bins(x, size):
    return np.arange(min(x), max(x) + size, size)


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
    plt.savefig(filename, bbox_inches='tight', dpi=500)
    plt.clf()


def q_random():
    # Plotting 1g
    with open("data/averages.dat") as f:
        a = [float(i) for i in f.readlines()]

    s = [10, 100, 10000, 1000000]
    plt.scatter(s, a)
    plt.xscale('log')
    plt.yscale('log')
    slope, *_ = linregress(np.log(s), np.log(a))
    add_plot_labels('Sample Size',
                    'Deviation from 0.5',
                    f'slope = ${round(slope, 4)}$')
    savefig('figures/1g.png')

    # Plotting 1h
    with open("data/sumofrandnum1.dat") as f:
        x1 = [float(i) for i in f.readlines()]

    for bin_size in [0.5, 1, 2]:
        plt.hist(x1, make_bins(x1, bin_size), density=True)
        add_plot_labels('Sum of 10000 random numbers in [0, 1]',
                        'Normalized count',
                        f'Bin Size = {bin_size}', x1)
        savefig(f'figures/1h_dx_{str(bin_size).replace(".", "_")}.png')

    with open("data/sumofrandnum2.dat") as f:
        x2 = [float(i) for i in f.readlines()]

    with open("data/sumofrandnum3.dat") as f:
        x3 = [float(i) for i in f.readlines()]

    plt.hist(x2, make_bins(x2, 1), density=True, alpha=0.5)
    plt.hist(x3, make_bins(x3, 1), density=True, alpha=0.5)
    add_plot_labels('Sum of 10000 random numbers in [-1, 1]',
                    'Normalized count',
                    'Distributions of different sample sizes')
    plt.legend(['Sample Size = $10^4$', 'Sample Size = $10^5$'])
    savefig('figures/1h_sample.png')


def q_random_walks():
    # Plotting 1i, 1j
    with open('data/randomwalk1.dat') as f:
        x1 = [round(float(i)) for i in f.readlines()]

    for bin_size in [1, 2, 5, 10]:
        plt.hist(x1, make_bins(x1, bin_size), density=True)
        add_plot_labels('Random walk of $10^4$ steps',
                        'Normalized count ($10^4$ walks)',
                        f'Bin Size = {bin_size}', x1)
        savefig(f'figures/1ij_dx_{bin_size}.png')

    plt.hist(x1, np.arange(min(x1) - min(x1) %
             2, max(x1) + 2, 2), density=True, alpha=0.5)
    plt.hist(x1, np.arange(min(x1) - min(x1) %
             2 - 1, max(x1) + 2, 2), density=True, alpha=0.5)
    add_plot_labels('Random walk of $10^4$ steps',
                    'Normalized count ($10^4$ walks)',
                    f'Bin Size = 2')
    plt.legend(['bins starting at 0', 'bins starting at 1'])
    savefig(f'figures/1ij_shifted.png')

    # Plotting 1k
    with open('data/randomwalk2.dat') as f:
        x2 = [round(float(i)) for i in f.readlines()]

    plt.hist(x2, make_bins(x2, 2), density=True)
    add_plot_labels('Random walk of $10^4$ steps',
                    'Normalized count ($10^5$ walks)',
                    'Bin Size = 2', x2)
    savefig('figures/1k.png')

    # Plotting 1l
    with open('data/randomwalk3.dat') as f:
        x3 = [round(float(i)) for i in f.readlines()]

    plt.hist(x3, make_bins(x3, 2), density=True)
    add_plot_labels('Random walk of $10^5$ steps',
                    'Normalized count ($10^5$ walks)',
                    'Bin Size = 2', x3)
    savefig('figures/1l.png')


q_random()
q_random_walks()
