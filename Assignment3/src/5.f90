program scratch
    use ising
    implicit none

    real(8) :: lattice(10, 10, 10)
    real(8) :: kbT, J_ising
    integer :: L, i, j, niter, io1, io2

    L = size(lattice, 1)
    J_ising = 1.0d0
    kbT = 4.05d0
    niter = 50000
    
    call randomize_spins(lattice)

    call execute_command_line('mkdir -p data')
    
    open(newunit=io1, file='data/5m.dat')
    open(newunit=io2, file='data/5e.dat')

    do i=1, niter
        do j=1, L**3
            call metropolis(lattice, L, J_ising, kbT)
        end do

        write(io1, *) avg_magnetization(lattice, L)
        write(io2, *) avg_energy(lattice, L, J_ising)
    end do

    close(io1)
    close(io2)
end program scratch
