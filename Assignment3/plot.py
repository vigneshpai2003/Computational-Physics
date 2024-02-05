import matplotlib.pyplot as plt
import numpy as np

def savefig(filename):
    plt.savefig(f'figures/{filename}', bbox_inches='tight', dpi=500)
    plt.clf()

def calc_eq_val(array, percentage=1):
    n = int(len(array) * (1 - percentage))
    return np.average(array[n:])

def read_array(filename):
    with open(filename) as f:
        return np.float_(f.readlines())


# 3
y = read_array('data/3.dat')

plt.scatter(np.arange(len(y)) + 1, y, s=1)
plt.xlabel('Iteration Number')
plt.ylabel('Magnetization per Spin')
plt.title(f'$k_BT$ = 4.9\nEquilibrium Magnetization: {round(calc_eq_val(y), 6)}')
savefig('3.png')

# 4
y = read_array('data/4.dat')

plt.scatter(np.arange(len(y)) + 1, y, s=1)
plt.xlabel('Iteration Number')
plt.ylabel('Energy per Spin')
plt.title(f'$k_BT$ = 3.9\nEquilibrium Energy: {round(calc_eq_val(y), 6)}')
savefig('4.png')

# 5
y_m = read_array('data/5/M.dat')
y_e = read_array('data/5/E.dat')

plt.scatter(np.arange(len(y_m)) + 1, y_m, s=1)
plt.scatter(np.arange(len(y_e)) + 1, y_e, s=1)
plt.xlabel('Iteration Number')
legend = plt.legend(['Magnetization per Spin', 'Energy per Spin'])
legend.legend_handles[0]._sizes = [30]
legend.legend_handles[1]._sizes = [30]
plt.title(f'$k_BT$ = 4.05\nEquilibrium Magnetization: {round(calc_eq_val(y_m), 6)}\nEquilibrium Energy: {round(calc_eq_val(y_e), 6)}')
savefig('5.png')

# 6
y_m_1 = read_array('data/6/M1.dat')
y_m_2 = read_array('data/6/M2.dat')
y_m_3 = read_array('data/6/M3.dat')

plt.scatter(np.arange(len(y_m_1)) + 1, abs(y_m_1), s=.1)
plt.scatter(np.arange(len(y_m_2)) + 1, abs(y_m_2), s=.1)
plt.scatter(np.arange(len(y_m_3)) + 1, abs(y_m_3), s=.1)
plt.xlabel('Iteration Number')
plt.ylabel('Magnitude of Magnetization per Spin')
legend = plt.legend([
    f'L = 8, $\mu = {round(np.average(abs(y_m_1)), 4)}$, $\sigma = {round(np.std(abs(y_m_1)), 4)}$',
    f'L = 9, $\mu = {round(np.average(abs(y_m_2)), 4)}$, $\sigma = {round(np.std(abs(y_m_2)), 4)}$',
    f'L = 10, $\mu = {round(np.average(abs(y_m_3)), 4)}$, $\sigma = {round(np.std(abs(y_m_3)), 4)}$'
])
legend.legend_handles[0]._sizes = [30]
legend.legend_handles[1]._sizes = [30]
legend.legend_handles[2]._sizes = [30]
plt.title(f'$k_BT$ = 3.9')
savefig('6M.png')

y_e_1 = read_array('data/6/E1.dat')
y_e_2 = read_array('data/6/E2.dat')
y_e_3 = read_array('data/6/E3.dat')

plt.scatter(np.arange(len(y_e_1)) + 1, y_e_1, s=.1)
plt.scatter(np.arange(len(y_e_2)) + 1, y_e_2, s=.1)
plt.scatter(np.arange(len(y_e_3)) + 1, y_e_3, s=.1)
plt.xlabel('Iteration Number')
plt.ylabel('Energy per Spin')
legend = plt.legend([
    f'L = 8, $\mu = {round(np.average(abs(y_e_1)), 4)}$, $\sigma = {round(np.std(abs(y_e_1)), 4)}$',
    f'L = 9, $\mu = {round(np.average(abs(y_e_2)), 4)}$, $\sigma = {round(np.std(abs(y_e_2)), 4)}$',
    f'L = 10, $\mu = {round(np.average(abs(y_e_3)), 4)}$, $\sigma = {round(np.std(abs(y_e_3)), 4)}$'
])
legend.legend_handles[0]._sizes = [30]
legend.legend_handles[1]._sizes = [30]
legend.legend_handles[2]._sizes = [30]
plt.title(f'$k_BT$ = 3.9')
savefig('6E.png')

# figures
Ta = read_array('data/fa/kBT.dat')
Tb = read_array('data/fa/kBT.dat')
Tc = read_array('data/fa/kBT.dat')

Ma = read_array('data/fa/M.dat')
Mb = read_array('data/fb/M.dat')
Mc = read_array('data/fc/M.dat')

Ea = read_array('data/fa/E.dat')
Eb = read_array('data/fb/E.dat')
Ec = read_array('data/fc/E.dat')

chia = read_array('data/fa/chi.dat')
chib = read_array('data/fb/chi.dat')
chic = read_array('data/fc/chi.dat')

Cva = read_array('data/fa/Cv.dat')
Cvb = read_array('data/fb/Cv.dat')
Cvc = read_array('data/fc/Cv.dat')

plt.plot(Ta, Ma)
plt.plot(Tb, Mb)
plt.plot(Tc, Mc)
plt.xlabel('$k_B T$')
plt.ylabel('Magnetization per Spin')
plt.legend(['L = 7', 'L = 8', 'L = 9'])
savefig('fM.png')

plt.plot(Ta, Ea)
plt.plot(Tb, Eb)
plt.plot(Tc, Ec)
plt.xlabel('$k_B T$')
plt.ylabel('Energy per Spin')
plt.legend(['L = 7', 'L = 8', 'L = 9'])
savefig('fE.png')

plt.plot(Ta, chia)
plt.plot(Tb, chib)
plt.plot(Tc, chic)
plt.xlabel('$k_B T$')
plt.ylabel('Susceptibility')
plt.legend(['L = 7', 'L = 8', 'L = 9'])
savefig('fchi.png')

plt.plot(Ta, Cva)
plt.plot(Tb, Cvb)
plt.plot(Tc, Cvc)
plt.xlabel('$k_B T$')
plt.ylabel('Heat Capacity')
plt.legend(['L = 7', 'L = 8', 'L = 9'])
savefig('fCv.png')

# 7
i = 35
with open('data/7.dat', 'w+') as f:
    f.write(f"{round(chia[i], 2)}, {round(chib[i], 2)}, {round(chic[i], 2)}")

# 8
with open('data/8.dat', 'w+') as f:
    f.write(str(round(max(Cvb), 2)))

# 9
with open('data/9.dat', 'w+') as f:
    f.write(str(round(max(Cvc), 2)))

# 10
with open('data/10.dat', 'w+') as f:
    f.write(str(round(Ma[0], 2)))

# 11
BCa = read_array('data/fa/BC.dat')
BCb = read_array('data/fb/BC.dat')
BCc = read_array('data/fc/BC.dat')

plt.plot(Ta, BCa)
plt.plot(Ta, BCb)
plt.plot(Ta, BCc)
plt.xlabel('$k_B T$')
plt.ylabel('$U_L$')
plt.title("Binder's Cumulant Plot")
savefig('BC.png')
