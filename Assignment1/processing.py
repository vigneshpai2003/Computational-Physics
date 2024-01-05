import matplotlib.pyplot as plt
import numpy as np


def q_random():
    # Plotting 1h
    with open("data/sumofrandnum1.dat") as f:
        x1 = [float(i) for i in f.readlines()[:-1]]

    for bin_size in [0.5, 1, 2]:
        plt.hist(x1, np.arange(min(x1), max(x1), bin_size), density=True)
        plt.xlabel('Sum of 10000 random numbers in [0, 1]')
        plt.ylabel('Normalized count')
        plt.title(f'Bin Size = {bin_size}')
        plt.savefig(f'figures/1h_dx_{str(bin_size).replace(".", "_")}.png', bbox_inches='tight', dpi=500)
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
    plt.savefig('figures/1h_sample.png', bbox_inches='tight', dpi=500)
    plt.clf()


def q_random_walks():
    # Plotting 1i, 1j
    with open('data/randomwalk1.dat') as f:
        x1 = [round(float(i)) for i in f.readlines()]

    for bin_size in [1, 2, 5, 10]:
        plt.hist(x1, np.arange(min(x1), max(x1), bin_size), density=True)
        plt.xlabel('Random walk of $10^4$ steps')
        plt.ylabel('Normalized count ($10^4$ walks)')
        plt.title(f'Bin Size = {bin_size}')
        plt.savefig(f'figures/1ij_dx_{bin_size}.png', bbox_inches='tight', dpi=500)
        plt.clf()

    plt.hist(x1, np.arange(min(x1) - min(x1) %
             2, max(x1), 2), density=True, alpha=0.5)
    plt.hist(x1, np.arange(min(x1) - min(x1) %
             2 - 1, max(x1), 2), density=True, alpha=0.5)
    plt.xlabel('Random walk of $10^4$ steps')
    plt.ylabel('Normalized count ($10^4$ walks)')
    plt.title(f'Bin Size = 2')
    plt.legend(['bins starting at 0', 'bins starting at 1'])
    plt.savefig(f'figures/1ij_shifted.png', bbox_inches='tight', dpi=500)
    plt.clf()

    # Plotting 1k
    with open('data/randomwalk2.dat') as f:
        x2 = [round(float(i)) for i in f.readlines()]

    plt.hist(x2, np.arange(min(x2), max(x2), 2), density=True)
    plt.xlabel('Random walk of $10^4$ steps')
    plt.ylabel('Normalized count ($10^5$ walks)')
    plt.title(f'Bin Size = 2')
    plt.savefig(f'figures/1k.png', bbox_inches='tight', dpi=500)
    plt.clf()


q_random()
q_random_walks()
