program scratch
    use md
    implicit none

    integer, parameter :: N = 1000
    integer :: N_t, t_thermostat, t_neighbors, t_eq, t_data, data_counter
    real(8) :: dt

    integer :: i
    real(8) :: x(3 * N), v(3 * N), F(3 * N), F_new(3 * N)
    
    real(8) :: R
    integer :: neighbors_size(N), neighbors(N, N)

    real(8) :: dv, v_max
    real(8), allocatable :: rho_v(:), rho_v_temp(:)

    character(len=*), parameter :: data_folder = "data/temp"

    call execute_command_line('mkdir -p '//data_folder)

    ! force parameters
    L = 20
    m = 1
    r_c = 2.5d0
    epsilon = 1
    sigma = 1
    kBT = 2

    ! simulation parameters
    N_t = 300000
    t_eq = 50000
    dt = 0.0025d0
    t_thermostat = 100
    t_neighbors = 40
    t_data = 10
    R = 2 * 5 * sqrt(8 * kBT / (3 * m)) * t_neighbors * dt
    R = 2

    ! velocity distribution parameters
    dv = 0.02d0
    v_max = 5
    allocate(rho_v(nint(v_max / dv)))
    allocate(rho_v_temp(nint(v_max / dv)))
    rho_v = 0

    call lattice_positions(N, x)
    call random_velocities(N, v, kBT)

    call calc_neighbors_single(N, x, neighbors_size, neighbors, R)

    call force_only_single(N, x, F, neighbors_size, neighbors)

    data_counter = 0

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

        if(i > t_eq .and. mod(i, t_data) == 0) then
            data_counter = data_counter + 1

            call velocity_dist(N, v, dv, rho_v_temp)
            rho_v = rho_v + rho_v_temp
        end if
    end do

    rho_v = rho_v / data_counter

    call write_array(data_folder//"/2.dat", rho_v)

    deallocate(rho_v, rho_v_temp)

end program scratch
