module simulator
    implicit none

    real(8), parameter :: J_ising = 1.0d0, kBT_start = 3.8d0, kBT_end = 4.7d0, kBT_step = 0.02d0
    integer, parameter :: niter_eq = 10000, niter = 10000
    integer, parameter :: n_temp = nint((kBT_end - kBT_start) / kBT_step)

contains
    subroutine simulate(lattice)
        use ising

        real(8), intent(out) :: lattice(:, :, :)

        real(8), allocatable :: storage(:)
        real(8) :: kBT, M
        integer :: L, i, j, k

        L = size(lattice, 1)

        allocate(storage(n_temp + 1))

        !$omp parallel do private(kBT, lattice, M)
        do k = 0, n_temp
            !$omp critical
            kBT = kBT_start + k * kBT_step
            !$omp end critical

            call randomize_spins(lattice)

            ! equilibriate
            do i=1, niter_eq
                do j=1, L**3
                    call metropolis(lattice, L, J_ising, kBT)
                end do
            end do

            ! compute thermodynamic quantities
            M = 0.0d0

            do i=1, niter
                do j = 1, L**3
                    call metropolis(lattice, L, J_ising, kBT)
                end do

                M = M + avg_magnetization(lattice, L)
            end do

            M = M / niter

            storage(1 + nint((kBT - kBT_start) / kBT_step)) = M

            print *, k, kBT
        end do
        !$omp end parallel do

        do i = 1, n_temp + 1
            print *, kBT_start + (i - 1) * kBT_step, storage(i)
        end do

        deallocate(storage)
    end subroutine

end module simulator

program scratch
    use omp_lib
    use simulator

    implicit none

    real(8) :: lattice1(7, 7, 7)
    real(8) :: lattice2(8, 8, 8)
    real(8) :: lattice3(9, 9, 9)

    call execute_command_line('mkdir -p data')

    call simulate(lattice1)
    call simulate(lattice2)
    call simulate(lattice3)

end program scratch
