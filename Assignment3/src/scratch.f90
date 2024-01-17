program scratch
    use ising
    implicit none

    real(8) :: lattice(10, 10, 10), kbT, E
    integer :: L, i

    L = size(lattice, 1)
    kbT = 3.9d0
    
    call randomize_spins(lattice)

    do i=1, 100000 * L**3
        call metropolis(lattice, L, kbT)
    end do

    E = 0.0d0

    do i=1, L**3
        call metropolis(lattice, L, kbT)
        E = E + energy(lattice, L)
    end do

    E = E / L**3

    print *, E

end program scratch
