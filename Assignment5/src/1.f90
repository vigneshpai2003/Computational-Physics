program scratch
    implicit none
    
    real(8) :: lattice(34, 34), old_lattice(34, 34), limit
    integer :: N, i, j, iter

    N = size(lattice, 1)

    limit = 0.0001d0

    ! initial state
    lattice = 0.0d0

    lattice(:, 1) = 3.7d0
    lattice(:, N) = 0.4d0
    
    do i = 1, N
        lattice(1, i) = 3.7d0 + (0.4d0 - 3.7d0) * (i - 1) / (N - 1)
        lattice(N, i) = 3.7d0 + (0.4d0 - 3.7d0) * (i - 1) / (N - 1)
    end do

    iter = 0

    do
        old_lattice = lattice

        do i = 2, N - 1
            do j = 2, N - 1
                lattice(i, j) = 0.25d0 * (old_lattice(i + 1, j) + old_lattice(i - 1, j) &
                                + old_lattice(i, j + 1) + old_lattice(i, j - 1))
            end do
        end do

        iter = iter + 1

        if (all(abs(lattice - old_lattice) < limit)) exit
    end do

    print *, iter, lattice(20, 20)

end program scratch
