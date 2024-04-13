program scratch
    use md
    implicit none

    integer, parameter :: N = 2197
    integer :: N_t, t_neighbors
    real(8) :: dt

    integer :: i
    real(8) :: x(3 * N), v(3 * N), F(3 * N), F_new(3 * N), KE, PE
    
    real(8) :: R
    integer :: neighbors_size(N), neighbors(N, N)

    integer :: io1, io2, io3
    character(len=*), parameter :: data_folder = "data/2"
    
    call execute_command_line('mkdir -p '//data_folder)

    ! force parameters
    L = 20
    m = 1
    r_c = 2.5d0
    epsilon = 1
    sigma = 1
    kBT = 1

    ! simulation parameters
    N_t = 20000
    dt = 0.005d0
    t_neighbors = 50
    R = 2 * 5 * sqrt(8 * kBT / (3 * m)) * t_neighbors * dt

    call lattice_positions(N, x)
    call random_velocities(N, v, kBT)

    call calc_neighbors_multi(N, x, neighbors_size, neighbors, R)

    call force_multi(N, x, F, neighbors_size, neighbors, PE)

    open(newunit=io1, file=data_folder//"/PE.dat")
    open(newunit=io2, file=data_folder//"/KE.dat")
    open(newunit=io3, file=data_folder//"/momentum.dat")
    
    do i = 1, N_t
        call update_position(N, x, v, F, dt)

        call force_multi(N, x, F_new, neighbors_size, neighbors, PE)

        call update_velocity(N, v, F, F_new, dt)

        F = F_new

        if (mod(i, t_neighbors) == 0) then
            call calc_neighbors_multi(N, x, neighbors_size, neighbors, R)
        end if

        KE = calc_KE(N, v)

        write(io1, *) PE
        write(io2, *) KE
        write(io3, *) sum(v(1::3)), sum(v(2::3)), sum(v(3::3))
    end do
    
    close(io1)
    close(io2)
    close(io3)

end program scratch
