program scratch
    use md
    implicit none

    integer, parameter :: N = 1000
    integer :: N_t, t_thermostat, t_neighbors, N_eq
    real(8) :: dt

    integer :: i, j
    real(8) :: x(3 * N), v(3 * N), F(3 * N), F_new(3 * N)

    integer :: t_dx, N_dx
    real(8) :: dx(3 * N), dx_sum(3 * N), msd
    real(8), allocatable :: dx_array(:, :), msd_array(:)
    
    real(8) :: R
    integer :: neighbors_size(N), neighbors(N, N)

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
    N_t = 400000
    N_eq = 20000
    dt = 0.0025d0
    t_thermostat = 100
    t_neighbors = 40
    R = 2 * 5 * sqrt(8 * kBT / (3 * m)) * t_neighbors * dt

    ! diffusion parameters
    t_dx = 10
    N_dx = 1 + N_t / t_dx
    allocate(dx_array(N_dx, 3 * N), msd_array(N_dx))

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

    dx_array = 0
    dx_sum = 0

    do i = 1, N_t
        call update_position_dx(N, x, v, F, dt, dx)
        dx_sum = dx_sum + dx

        call force_only_single(N, x, F_new, neighbors_size, neighbors)

        call update_velocity(N, v, F, F_new, dt)

        F = F_new

        if (mod(i, t_thermostat) == 0) then
            call thermostat(N, v, kBT)
        end if

        if (mod(i, t_neighbors) == 0) then
            call calc_neighbors_single(N, x, neighbors_size, neighbors, R)
        end if
        
        if (mod(i, t_dx) == 0) then
            dx_array(1 + i / t_dx, :) = dx_sum
        end if
    end do

    !$omp parallel do default(shared) private(i, j, msd)
    do i = 1, N_dx
        msd = 0
        do j = 1, N_dx - i
            msd = msd + sum((dx_array(j + i, :) - dx_array(j, :))**2) / N
        end do
        msd_array(i) = msd / (N_dx - i)
    end do
    !$omp end parallel do

    call write_array(data_folder//"/msd.dat", msd_array)

    deallocate(dx_array, msd_array)

end program scratch
