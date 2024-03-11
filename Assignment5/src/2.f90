program scratch
    implicit none
    
    real(8) :: lattice(34, 34), old_lattice(34, 34), limit, A, B, C, D
    integer :: N, i, j, iter

    N = size(lattice, 1)

    A = -70.0d0
    B = -40.0d0
    C = 20.0d0
    D = -10.0d0

    limit = 0.00001d0

    ! initial state
    lattice = 0.0d0

    iter = 0

    do
        old_lattice = lattice

        ! boundary conditions

        ! corners
        lattice(1, 1) = 0.5d0 * (old_lattice(2, 1) - A + old_lattice(1, 2) - C)
        lattice(N, 1) = 0.5d0 * (old_lattice(N - 1, 1) + B + old_lattice(N, 2) - C)
        lattice(1, N) = 0.5d0 * (old_lattice(1, N - 1) + D + old_lattice(2, N) - A)
        lattice(N, N) = 0.5d0 * (old_lattice(N, N - 1) + D + old_lattice(N - 1, N) + B)

        ! edges
        do i = 2, N - 1
            lattice(1, i) = 0.25d0 * (2 * old_lattice(2, i) - 2 * A &
                                      + old_lattice(1, i + 1) + old_lattice(1, i - 1))
            lattice(N, i) = 0.25d0 * (2 * old_lattice(N - 1, i) + 2 * B &
                                      + old_lattice(N, i + 1) + old_lattice(N, i - 1))
            
            lattice(i, 1) = 0.25d0 * (2 * old_lattice(i, 2) - 2 * C &
                                      + old_lattice(i + 1, 1) + old_lattice(i - 1, 1))
            lattice(i, N) = 0.25d0 * (2 * old_lattice(i, N - 1) + 2 * D &
                                      + old_lattice(i + 1, N) + old_lattice(i - 1, N))
        end do

        ! interior
        do i = 2, N - 1
            do j = 2, N - 1
                lattice(i, j) = 0.25d0 * (old_lattice(i + 1, j) + old_lattice(i - 1, j) &
                                          + old_lattice(i, j + 1) + old_lattice(i, j - 1))
            end do
        end do

        iter = iter + 1

        if (all(abs(lattice - old_lattice) < limit)) exit
    end do

    lattice = lattice + (2000.0d0 - lattice(1, 1))

    print *, iter, lattice(10, 10)

end program scratch
