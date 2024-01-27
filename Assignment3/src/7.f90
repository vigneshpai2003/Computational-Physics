module simulator
    implicit none

    real(8), parameter :: J_ising = 1.0d0
    real(8), parameter :: kBT_start = 3.8d0, kBT_end = 4.7d0, kBT_step = 0.02d0
    integer, parameter :: niter_eq = 10000, niter = 1000000
    integer, parameter :: n_temp = nint((kBT_end - kBT_start) / kBT_step) + 1

contains
    subroutine simulate(lattice, data_folder)
        use ising

        real(8), intent(out) :: lattice(:, :, :)
        character(*), intent(in) :: data_folder

        real(8) :: M_arr(n_temp), E_arr(n_temp), chi_arr(n_temp), Cv_arr(n_temp)
        real(8) :: M, M2, M_t, E, E2, E_t

        real(8) :: kBT
        integer :: L, i, j, k
        integer :: io

        L = size(lattice, 1)

        !$omp parallel do private(kBT, lattice, M, M2, E, E2, M_t, E_t)
        do k = 1, n_temp
            !$omp critical
            kBT = kBT_start + (k - 1) * kBT_step
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
            M2 = 0.0d0
            E = 0.0d0
            E2 = 0.0d0

            do i=1, niter
                do j = 1, L**3
                    call metropolis(lattice, L, J_ising, kBT)
                end do

                M_t = abs(magnetization(lattice))
                E_t = energy(lattice, L, J_ising)

                M = M + M_t
                M2 = M2 + M_t*M_t
                E = E + E_t
                E2 = E2 + E_t*E_t
            end do

            M = M / niter
            M2 = M2 / niter
            E = E / niter
            E2 = E2 / niter

            M_arr(k) = M
            E_arr(k) = E

            chi_arr(k) = (M2 - M*M) / kBT
            Cv_arr(k) = (E2 - E*E) / (kBT*kBT)

        end do
        !$omp end parallel do

        M_arr = M_arr / L**3
        E_arr = E_arr / L**3
        chi_arr = chi_arr / L**3
        Cv_arr = Cv_arr / L**3

        open(newunit=io, file=data_folder//"kBT.dat")
        do i = 1, n_temp
            write(io, *) kBT_start + (i - 1) * kBT_step
        end do
        close(io)

        open(newunit=io, file=data_folder//"M.dat")
        do i = 1, n_temp
            write(io, *) M_arr(i)
        end do
        close(io)

        open(newunit=io, file=data_folder//"E.dat")
        do i = 1, n_temp
            write(io, *) E_arr(i)
        end do
        close(io)

        open(newunit=io, file=data_folder//"chi.dat")
        do i = 1, n_temp
            write(io, *) chi_arr(i)
        end do
        close(io)

        open(newunit=io, file=data_folder//"Cv.dat")
        do i = 1, n_temp
            write(io, *) Cv_arr(i)
        end do
        close(io)

    end subroutine

end module simulator

program scratch
    use omp_lib
    use simulator

    implicit none

    real(8) :: lattice1(7, 7, 7)
    real(8) :: lattice2(8, 8, 8)
    real(8) :: lattice3(9, 9, 9)

    call execute_command_line('mkdir -p data/7a data/7b data/7c')

    call simulate(lattice1, "data/7a/")
    call simulate(lattice2, "data/7b/")
    call simulate(lattice3, "data/7c/")

end program scratch
