import numpy as np
import matplotlib.pyplot as plt

def savefig(filename):
    plt.savefig(f'figures/{filename}', bbox_inches='tight', dpi=500)
    plt.clf()

data_dir = "data/arrays"

T = np.loadtxt("data/T1i.dat").T

plt.pcolormesh(np.arange(1, 35), np.arange(1, 35), T, cmap='rainbow')
plt.colorbar()
plt.xlabel("$x$")
plt.ylabel("$y$")
plt.title("Initial State\n$\\bigtriangledown^2 T = 0$ (Dirichlet Boundary Conditions)")
savefig("1i.png")

T = np.loadtxt("data/T1.dat").T

plt.pcolormesh(np.arange(1, 35), np.arange(1, 35), T, cmap='rainbow')
plt.colorbar()
plt.xlabel("$x$")
plt.ylabel("$y$")
plt.title("Steady State\n$\\bigtriangledown^2 T = 0$ (Dirichlet Boundary Conditions)")
savefig("1.png")

T = np.loadtxt("data/T2.dat").T

plt.pcolormesh(np.arange(1, 35), np.arange(1, 35), T, cmap='rainbow')
plt.colorbar()
plt.xlabel("$x$")
plt.ylabel("$y$")
plt.title("Steady State\n$\\bigtriangledown^2 T = 0$ (von Neumann Boundary Conditions)")
savefig("2.png")
