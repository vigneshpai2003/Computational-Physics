program scratch
    use md
    implicit none

    integer, parameter :: N = 1000
    integer :: N_t, t_thermostat, t_neighbors, N_eq
    real(8) :: dt

    integer :: i
    real(8) :: x(3 * N), x_0(3 * N), v(3 * N), F(3 * N), F_new(3 * N)
    
    real(8) :: R
    integer :: neighbors_size(N), neighbors(N, N)

    integer :: io
    character(len=*), parameter :: data_folder = "data/diffusion"

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
    N_eq = 5000
    dt = 0.0025d0
    t_thermostat = 100
    t_neighbors = 40
    R = 2 * 5 * sqrt(8 * kBT / (3 * m)) * t_neighbors * dt

    call lattice_positions(N, x)
    call random_velocities(N, v, kBT)

    call calc_neighbors_single(N, x, neighbors_size, neighbors, R)

    call force_only_single(N, x, F, neighbors_size, neighbors)

    do i = 1, N_eq
        call update_position(N, x, v, F, dt)

        call force_only_single(N, x, F_new, neighbors_size, neighbors)

        call update_velocity(N, v, F, F_new, dt)

        F = F_new

        if (mod(i, t_thermostat) == 0) then
            call thermostat(N, v, kBT)
        end if

        if (mod(i, t_neighbors) == 0) then
            call calc_neighbors_single(N, x, neighbors_size, neighbors, R)
        end if

    end do

    open(newunit=io, file=data_folder//"/d.dat")

    x_0 = x

    do i = 1, N_t
        call update_position(N, x, v, F, dt)

        call force_only_single(N, x, F_new, neighbors_size, neighbors)

        call update_velocity(N, v, F, F_new, dt)

        F = F_new

        if (mod(i, t_thermostat) == 0) then
            call thermostat(N, v, kBT)
        end if

        if (mod(i, t_neighbors) == 0) then
            call calc_neighbors_single(N, x, neighbors_size, neighbors, R)
        end if
        
        write(io, *) msd(N, x, x_0)
    end do

    close(io)

end program scratch
