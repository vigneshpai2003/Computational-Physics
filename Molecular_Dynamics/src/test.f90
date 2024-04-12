program scratch
    use md
    implicit none

    integer, parameter :: N = 2197
    integer, parameter :: N_t = 1000, t_thermostat = 100, t_neighbors = 50
    real(8), parameter :: dt = 0.005d0

    integer :: i, n_neighbors(N)
    real(8) :: x(3 * N), v(3 * N), F(3 * N), F_new(3 * N), KE, PE, R
    logical :: neighbors(N, N)

    call execute_command_line('mkdir -p data')

    L = 20
    m = 1
    r_c = 2.5d0
    epsilon = 1
    sigma = 1
    kBT = 1
    R = 2 * 5 * sqrt(8 * kBT / (3 * m)) * t_neighbors * dt

    print *, "Number of Particles =", N
    print *, "Size of Box =", L
    print *, "Radius Cutoff =", r_c
    print *, "Number of Iterations =", N_t
    print *, "Time Step =", dt
    print *, "Thermostat Every =", t_thermostat
    print *, "Neighbors Calculation Every =", t_neighbors
    print *, "Neighbor Radius =", r_c + R

    call lattice_positions(N, x)
    call random_velocities(N, v, kBT)

    call calc_neighbors(N, x, neighbors, R)

    call force_multi(N, x, F, neighbors, PE)

    do i = 1, N_t
        call update_x(N, x, v, F, dt)

        call force_multi(N, x, F_new, neighbors, PE)

        call update_v(N, v, F, F_new, dt)

        F = F_new

        if (mod(i, t_thermostat) == 0) then
            call thermostat(N, v, kBT)
            print *, "Thermostat"
        end if

        if (mod(i, t_neighbors) == 0) then
            call calc_neighbors(N, x, neighbors, R)
            n_neighbors = count(neighbors, 1)
            print *, "Neighbors", sum(n_neighbors) / N, maxval(n_neighbors), minval(n_neighbors)
        end if

        KE = calc_KE(N, v)

        ! print *, i, KE + PE, KE / N, PE / N, sum(v(1:3*N:3))
    end do

end program scratch
