import numpy as np
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation, FFMpegWriter

def savefig(filename):
    plt.savefig(f'figures/{filename}', bbox_inches='tight', dpi=500)
    plt.clf()

data_dir = "data/arrays"

# 1, 2, 3, 4
dat_ye = np.loadtxt(f"{data_dir}/ye.dat")
dat_yme = np.loadtxt(f"{data_dir}/yme.dat")
dat_yie = np.loadtxt(f"{data_dir}/yie.dat")
dat_yrk = np.loadtxt(f"{data_dir}/yrk.dat")

for y in [dat_ye, dat_yme, dat_yie, dat_yrk]:
    plt.plot(y[:, 0], y[:, 1], marker='o', ms=4)

plt.xlim(1.45, 1.56)
plt.ylim(8, 50)
plt.xlabel("$x$")
plt.ylabel("$y$")
plt.title("$\dot{y} = y^2 + 1$")
plt.legend(["Euler", "Modified Euler", "Improved Euler", "RK4"])
savefig("1a.png")

# errors
for y in [dat_ye, dat_yme, dat_yie, dat_yrk]:
    plt.plot(y[:, 0], abs(np.tan(y[:, 0]) - y[:, 1]), marker='o', ms=4)

plt.xlabel("$x$")
plt.ylabel("$|y - \\tan x|$")
plt.title("Errors in Different Methods\n$\dot{y} = y^2 + 1$")
plt.legend(["Euler", "Modified Euler", "Improved Euler", "RK4"])
plt.yscale('log')
savefig("1b.png")

# 5, 6, 7
dat5 = np.loadtxt(f"{data_dir}/5.dat")
dat6 = np.loadtxt(f"{data_dir}/6.dat")
dat7 = np.loadtxt(f"{data_dir}/7.dat")

# positions
for y in [dat5, dat6, dat7]:
    plt.plot(y[:, 0], y[:, 1], marker='o', ms=1)

plt.legend(["$v_0 = 1.9$", "$v_0 = 1.999$", "$v_0 = 2.01$"])
plt.xlabel("$t$")
plt.ylabel("$x(t)$")
plt.title("Position\\n$\ddot{x} = - \sin x $")
savefig("7x.png")

# velocities
for y in [dat5, dat6, dat7]:
    plt.plot(y[:, 0], y[:, 2], marker='o', ms=1)

plt.legend(["$v_0 = 1.9$", "$v_0 = 1.999$", "$v_0 = 2.01$"])
plt.xlabel("$t$")
plt.ylabel("$v(t)$")
plt.title("Velocity\\n$\ddot{x} = - \sin x $")
savefig("7v.png")

# energy
for y in [dat5, dat6, dat7]:
    plt.plot(y[1:, 0], abs(- 2 * np.cos(y[:, 1]) + y[:, 2]**2 - (- 2 * np.cos(y[0, 1]) + y[0, 2]**2))[1:], marker='o', ms=1)

plt.xlabel("$t$")
plt.ylabel("Deviation in Energy")
plt.title("Energy")
plt.yscale("log")
savefig("7E.png")

# 8
dat8 = np.loadtxt(f"{data_dir}/8.dat")
t = dat8[:, 0]
y = dat8[:, 1:51]

fig, ax = plt.subplots()
ln, = ax.plot(np.arange(1, 51), y[0, :], marker='o')
ax.set_ylim(-0.8, 0.8)
plt.xlabel("Particle Number")
plt.ylabel("Particle Displacement")

def update(frame):
    plt.title(f"$t = {round(t[frame], 2)}$")
    ln.set_data(np.arange(1, 51), y[frame, :])
    return ln,

# ani = FuncAnimation(fig, update, frames=len(t), blit=True, interval=1)
# ani.save('animation.mp4', writer = FFMpegWriter(fps=60))
plt.clf()

# 9
dat_i = np.loadtxt(f'{data_dir}/9i.dat')
dat_f = np.loadtxt(f'{data_dir}/9f.dat')

plt.plot(dat_i[:, 0], dat_i[:, 1], marker='o', ms=5)
plt.plot(dat_f[:, 0], dat_f[:, 1], marker='o', ms=5)

plt.legend(["Initial State", "Final State"])
plt.xlabel("$x$")
plt.ylabel("$y$")
plt.title("$\ddot{y} - 5 \dot{y} + 10 y = 10 x$, $y(0)=0$, $y(1)=2$")
savefig("9.png")
