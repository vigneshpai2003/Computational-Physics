program scratch
    use md
    implicit none

    integer, parameter :: N = 1200
    integer :: N_t, t_thermostat, t_neighbors
    real(8) :: dt

    integer :: i
    real(8) :: x(3 * N), v(3 * N), F(3 * N), F_new(3 * N), KE, PE
    
    real(8) :: R
    integer :: neighbors_size(N), neighbors(N, N)
    
    real(8) :: dr, r_max
    real(8), allocatable :: n_r(:)

    call execute_command_line('mkdir -p data')

    ! force parameters
    L = 20
    m = 1
    r_c = 2.5d0
    epsilon = 1
    sigma = 1
    kBT = 1

    ! simulation parameters
    N_t = 1000
    dt = 0.005d0
    t_thermostat = 100
    t_neighbors = 50
    R = 2 * 5 * sqrt(8 * kBT / (3 * m)) * t_neighbors * dt

    ! pair correlation parameters
    dr = 0.05d0
    r_max = 10
    allocate(n_r(nint(r_max / dr)))

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

    call calc_neighbors_multi(N, x, neighbors_size, neighbors, R)

    call force_multi(N, x, F, neighbors_size, neighbors, PE)

    do i = 1, N_t
        call update_position(N, x, v, F, dt)

        call force_multi(N, x, F_new, neighbors_size, neighbors, PE)

        call update_velocity(N, v, F, F_new, dt)

        F = F_new

        if (mod(i, t_thermostat) == 0) then
            call thermostat(N, v, kBT)
            print *, "Thermostat"
        end if

        if (mod(i, t_neighbors) == 0) then
            call calc_neighbors_multi(N, x, neighbors_size, neighbors, R)
            print *, "Neighbors", sum(neighbors_size) / N, maxval(neighbors_size), minval(neighbors_size)
        end if

        KE = calc_KE(N, v)

        ! print *, i, KE + PE, KE / N, PE / N, sum(v(1:3*N:3))
    end do

    call radial_count(N, x, dr, n_r)
    
    call n_r_to_pair_correlation(N, dr, n_r)

    do i = 1, size(n_r)
        print *, dr * (i - 0.5d0), n_r(i)
    end do

end program scratch
