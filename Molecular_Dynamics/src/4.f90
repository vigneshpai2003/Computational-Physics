program scratch
    use md
    implicit none

    integer, parameter :: N = 1200
    integer :: N_t, t_thermostat, t_neighbors, t_eq, t_data, data_counter
    real(8) :: dt

    integer :: i
    real(8) :: x(3 * N), v(3 * N), F(3 * N), F_new(3 * N)
    
    real(8) :: R
    integer :: neighbors_size(N), neighbors(N, N)
    
    real(8) :: dr, r_max
    real(8), allocatable :: n_r(:), n_r_temp(:)

    integer :: io
    character(len=*), parameter :: data_folder = "data/4"

    call execute_command_line('mkdir -p '//data_folder)

    ! force parameters
    L = 20
    m = 1
    r_c = 2.5d0
    epsilon = 1
    sigma = 1
    kBT = 1

    ! simulation parameters
    N_t = 5000
    t_eq = 1000
    dt = 0.0025d0
    t_thermostat = 100
    t_neighbors = 40
    t_data = 100
    R = 2 * 5 * sqrt(8 * kBT / (3 * m)) * t_neighbors * dt
    R = 2

    ! pair correlation parameters
    dr = 0.05d0
    r_max = 10
    allocate(n_r(nint(r_max / dr)))
    allocate(n_r_temp(nint(r_max / dr)))

    call lattice_positions(N, x)
    call random_velocities(N, v, kBT)

    call calc_neighbors_multi(N, x, neighbors_size, neighbors, R)

    call force_only_multi(N, x, F, neighbors_size, neighbors)

    open(newunit=io, file=data_folder//"/n_max.dat")

    data_counter = 0

    do i = 1, N_t
        call update_position(N, x, v, F, dt)

        call force_only_multi(N, x, F_new, neighbors_size, neighbors)

        call update_velocity(N, v, F, F_new, dt)

        F = F_new

        if (mod(i, t_thermostat) == 0) then
            call thermostat(N, v, kBT)
        end if

        if (mod(i, t_neighbors) == 0) then
            call calc_neighbors_multi(N, x, neighbors_size, neighbors, R)
            write(io, *) maxval(neighbors_size)
        end if

        if(i > t_eq .and. mod(i, t_data) == 0) then
            data_counter = data_counter + 1
            call radial_count(N, x, dr, n_r_temp)
            n_r = n_r + n_r_temp
        end if
    end do

    close(io)

    n_r = n_r / data_counter

    call n_r_to_pair_correlation(N, dr, n_r)

    call write_array(data_folder//"/g.dat", n_r)

    deallocate(n_r)
    deallocate(n_r_temp)

end program scratch
