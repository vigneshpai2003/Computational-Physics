program scratch
    use ising
    use omp_lib
    implicit none

    real(8) :: lattice1(7, 7, 7)
    real(8) :: lattice2(8, 8, 8)
    real(8) :: lattice3(9, 9, 9)
    real(8) :: kBT_start, kBT_end, kBT_step, kBT, kBT_loop, J_ising
    integer :: L1, L2, L3, i, j, k, niter, niter_eq, n_temp
    integer :: io1, io2

    ! call omp_set_num_threads(6)

    J_ising = 1.0d0
    niter_eq = 10000
    niter = 10000
    kBT_start = 3.8d0
    kBT_end = 4.7d0
    kBT_step = 0.02d0

    call execute_command_line('mkdir -p data')
    
    call randomize_spins(lattice1)
    call randomize_spins(lattice2)
    call randomize_spins(lattice3)

    L1 = size(lattice1, 1)
    L2 = size(lattice2, 1)
    L3 = size(lattice3, 1)

    kBT = kBT_start

    n_temp = nint((kBT_end - kBT_start) / kBT_step)

    !$omp parallel do shared(kBT) private(kBT_loop, lattice1, lattice2, lattice3)
    do k = 0, n_temp
        !$omp critical
        kBT = kBT + kBT_step
        kBT_loop = kBT
        !$omp end critical

        ! equilibriate
        do i=1, niter_eq
            do j=1, L1**3
                call metropolis(lattice1, L1, J_ising, kBT_loop)
            end do
            
            do j=1, L2**3
                call metropolis(lattice2, L2, J_ising, kBT_loop)
            end do

            do j=1, L3**3
                call metropolis(lattice1, L3, J_ising, kBT_loop)
            end do
        end do
        
        ! compute thermodynamic quantities
        !$omp parallel do
        do i=1, niter
            do j=1, L1**3
                call metropolis(lattice1, L1, J_ising, kBT_loop)
            end do

            do j=1, L2**3
                call metropolis(lattice1, L2, J_ising, kBT_loop)
            end do
            
            do j=1, L3**3
                call metropolis(lattice1, L3, J_ising, kBT_loop)
            end do
        end do
        !$omp end parallel do

        print *, kBT_loop, omp_get_thread_num()
    end do
    !$omp end parallel do

end program scratch
