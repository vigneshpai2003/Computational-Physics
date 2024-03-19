import random
import subprocess
import numpy as np
import matplotlib.pyplot as plt


def savefig(filename):
    plt.savefig(f'figures/{filename}', bbox_inches='tight', dpi=500)
    plt.clf()


def process_rd_data(dir, niter, step, dt):
    subprocess.run([f'mkdir -p figures/{dir}'], shell=True, check=True)

    def savefig_dir(f): return savefig(f"{dir}/{f}")

    cmap = 'turbo'

    # load data
    a = []
    b = []

    for i in range(0, niter + step, step):
        a.append(np.loadtxt(f"data/{dir}/a/{i}.dat"))
        b.append(np.loadtxt(f"data/{dir}/b/{i}.dat"))

    a = np.array(a)
    b = np.array(b)

    N = a.shape[1]

    conv_a = np.loadtxt(f"data/{dir}/a/conv.dat")
    conv_b = np.loadtxt(f"data/{dir}/b/conv.dat")

    # convergence plot
    plt.plot(np.arange(len(conv_a)) * dt, conv_a)
    plt.plot(np.arange(len(conv_b)) * dt, conv_b)
    plt.xlabel('Time ($t$)')
    plt.ylabel('$X_{t + 1} - X_{t}$')
    plt.yscale('log')
    plt.legend(['$X = a$', '$X = b$'])
    plt.title("Convergence of the Reaction Diffusion PDE")
    savefig_dir('conv.png')

    # line plot at random points

    t = np.arange(a.shape[0]) * dt * step

    for i in range(0, N):
        for j in range(0, N):
            if random.random() < 40 / N**2:
                plt.plot(t, a[:, i, j])

    plt.xlabel('Time ($t$)')
    plt.ylabel('$a(t)$')
    plt.title('$a(t)$ at some random points')
    savefig_dir('a_lines.png')

    for i in range(0, N):
        for j in range(0, N):
            if random.random() < 40 / N**2:
                plt.plot(t, b[:, i, j])

    plt.xlabel('Time ($t$)')
    plt.ylabel('$b(t)$')
    plt.title('$b(t)$ at some random points')
    savefig_dir('b_lines.png')

    # heat map
    plt.pcolormesh(np.arange(1, N + 1), np.arange(1, N + 1), a[-1].T, cmap=cmap)
    plt.colorbar()
    plt.xlabel("$x$")
    plt.ylabel("$y$")
    plt.title(f"a(t = {niter * dt})")
    savefig_dir("a_cmap.png")

    plt.pcolormesh(np.arange(1, 61), np.arange(1, 61), b[-1].T, cmap=cmap)
    plt.colorbar()
    plt.xlabel("$x$")
    plt.ylabel("$y$")
    plt.title(f"b(t = {niter * dt})")
    savefig_dir("b_cmap.png")


def process_fn_data(dir, a0, b0, alpha, beta):
    subprocess.run([f'mkdir -p figures/{dir}'], shell=True, check=True)

    def savefig_dir(f): return savefig(f"{dir}/{f}")

    t = np.loadtxt(f'data/{dir}/t.dat')
    a = np.loadtxt(f'data/{dir}/a.dat')
    b = np.loadtxt(f'data/{dir}/b.dat')

    plt.plot(t, a)
    plt.plot(t, b)
    plt.xlabel("Time ($t$)")
    plt.ylabel("$X(t)$")
    plt.legend(["$X = a$", "$X = b$"])
    plt.title(f"Solution of Fitzhugh Nagumo Equations using RK4\n$a(0) = {a0}$, $b(0) = {b0}$, $\\alpha={alpha}$, $\\beta={beta}$")
    savefig_dir('fn.png')


def process_diffusion_data(dir, niter, step, dt):
    subprocess.run([f'mkdir -p figures/{dir}'], shell=True, check=True)

    def savefig_dir(f): return savefig(f"{dir}/{f}")

    cmap = 'turbo'

    # load data
    a = []

    for i in range(0, niter + step, step):
        a.append(np.loadtxt(f"data/{dir}/{i}.dat"))

    a = np.array(a)

    N = a.shape[1]

    conv = np.loadtxt(f"data/{dir}/conv.dat")

    # convergence plot
    plt.plot(np.arange(len(conv)) * dt, conv)
    plt.xlabel('Time ($t$)')
    plt.ylabel('$X_{t + 1} - X_{t}$')
    plt.yscale('log')
    plt.title("Convergence of the Diffusion PDE")
    savefig_dir('conv.png')

    # heat map
    plt.pcolormesh(np.arange(1, N + 1), np.arange(1, N + 1), a[-1].T, cmap=cmap)
    plt.colorbar()
    plt.xlabel("$x$")
    plt.ylabel("$y$")
    plt.title(f"X(t = {niter * dt})")
    savefig_dir("cmap.png")

process_fn_data('fn1', 0.35, 0, 0.05, 10)
process_fn_data('fn2', 0.35, 0, 0.05, 1)
process_fn_data('fn3', 0.35, 0, 0.05, 0.1)
process_diffusion_data('d1', 100000, 1000, 0.001)
process_diffusion_data('d2', 100000, 1000, 0.001)
process_rd_data('rd1', 100000, 1000, 0.001)
process_rd_data('rd2', 100000, 1000, 0.001)
process_rd_data('rd3', 100000, 1000, 0.001)
