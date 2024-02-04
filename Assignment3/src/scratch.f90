program scratch
    use ising
    implicit none

    real(8) :: lattice(10, 10, 10)
    real(8) :: kBT, J_ising
    integer :: L, i, j, niter, io

    L = size(lattice, 1)
    J_ising = 1.0d0
    kBT = 3.9d0
    niter = 100
    
    call randomize_spins(lattice)

    call execute_command_line('mkdir -p data')
    
    open(newunit=io, file='data/scratch.dat')

    do i=1, niter
        do j=1, L**3
            call metropolis(lattice, L, J_ising, kBT)
        end do

        write(io, *) avg_magnetization(lattice, L)
    end do

    close(io)
end program scratch
