program test
    use ising

    implicit none
    
    real(8) :: lattice(10, 10, 10)
    real(8) :: kBT, J_ising
    integer :: L, i, niter, io1, io2

    L = size(lattice, 1)
    J_ising = 1.0d0
    kBT = 4.0d0
    niter = 100000
    
    call randomize_spins(lattice)

    call execute_command_line('mkdir -p data/test')
    
    open(newunit=io1, file='data/test/E.dat')
    open(newunit=io2, file='data/test/M.dat')

    do i=1, niter
        call metropolis(lattice, L, J_ising, kBT)

        write(io1, *) energy(lattice, L, J_ising)
        write(io2, *) avg_magnetization(lattice, L)
    end do

    close(io1)
    close(io2)
end program test