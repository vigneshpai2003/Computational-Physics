program scratch
    use ising
    implicit none

    real(8) :: lattice1(8, 8, 8)
    real(8) :: lattice2(9, 9, 9)
    real(8) :: lattice3(10, 10, 10)
    real(8) :: kBT, J_ising
    integer :: L, i, j, niter, io1, io2

    J_ising = 1.0d0
    kBT = 3.9d0
    niter = 50000

    call execute_command_line('mkdir -p data')

    ! L = 8
    L = size(lattice1, 1)
    
    call randomize_spins(lattice1)

    
    open(newunit=io1, file='data/6m1.dat')
    open(newunit=io2, file='data/6e1.dat')

    do i=1, niter
        do j=1, L**3
            call metropolis(lattice1, L, J_ising, kBT)
        end do

        write(io1, *) avg_magnetization(lattice1, L)
        write(io2, *) avg_energy(lattice1, L, J_ising)
    end do

    close(io1)
    close(io2)

    ! L = 9
    L = size(lattice2, 1)
    
    call randomize_spins(lattice2)

    
    open(newunit=io1, file='data/6m2.dat')
    open(newunit=io2, file='data/6e2.dat')

    do i=1, niter
        do j=1, L**3
            call metropolis(lattice2, L, J_ising, kBT)
        end do

        write(io1, *) avg_magnetization(lattice2, L)
        write(io2, *) avg_energy(lattice2, L, J_ising)
    end do

    close(io1)
    close(io2)

    ! L = 10
    L = size(lattice3, 1)
    
    call randomize_spins(lattice3)

    
    open(newunit=io1, file='data/6m3.dat')
    open(newunit=io2, file='data/6e3.dat')

    do i=1, niter
        do j=1, L**3
            call metropolis(lattice3, L, J_ising, kBT)
        end do

        write(io1, *) avg_magnetization(lattice3, L)
        write(io2, *) avg_energy(lattice3, L, J_ising)
    end do

    close(io1)
    close(io2)
end program scratch
