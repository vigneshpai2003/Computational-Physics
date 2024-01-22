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
y_m = read_array('data/5m.dat')
y_e = read_array('data/5e.dat')

plt.scatter(np.arange(len(y_m)) + 1, y_m, s=1)
plt.scatter(np.arange(len(y_e)) + 1, y_e, s=1)
plt.xlabel('Iteration Number')
plt.legend(['Magnetization per Spin', 'Energy per Spin'])
plt.title(f'$k_BT$ = 4.05\nEquilibrium Magnetization: {round(calc_eq_val(y_m), 6)}\nEquilibrium Energy: {round(calc_eq_val(y_e), 6)}')
savefig('5.png')

# 6
y_m_1 = read_array('data/6m1.dat')
y_m_2 = read_array('data/6m2.dat')
y_m_3 = read_array('data/6m3.dat')

plt.scatter(np.arange(len(y_m_1)) + 1, abs(y_m_1), s=.1)
plt.scatter(np.arange(len(y_m_2)) + 1, abs(y_m_2), s=.1)
plt.scatter(np.arange(len(y_m_3)) + 1, abs(y_m_3), s=.1)
plt.xlabel('Iteration Number')
plt.ylabel('Magnitude of Magnetization per Spin')
plt.legend(['L = 8', 'L = 9', 'L = 10'])
plt.title(f'$k_BT$ = 3.9')
savefig('6m.png')

y_e_1 = read_array('data/6e1.dat')
y_e_2 = read_array('data/6e2.dat')
y_e_3 = read_array('data/6e3.dat')

plt.scatter(np.arange(len(y_e_1)) + 1, y_e_1, s=.1)
plt.scatter(np.arange(len(y_e_2)) + 1, y_e_2, s=.1)
plt.scatter(np.arange(len(y_e_3)) + 1, y_e_3, s=.1)
plt.xlabel('Iteration Number')
plt.ylabel('Energy per Spin')
plt.legend(['L = 8', 'L = 9', 'L = 10'])
plt.title(f'$k_BT$ = 3.9')
savefig('6e.png')
