module ising
    implicit none

contains

    subroutine randomize_spins(lattice)
        real(8), intent(out) :: lattice(:, :, :)
        call random_number(lattice)
        lattice = sign(1.0d0, lattice - 0.5d0)
    end subroutine

    function energy(lattice, L, J_ising) result(E)
        real(8), intent(in) :: lattice(:, :, :)
        integer, intent(in) :: L
        real(8), intent(in) :: J_ising
        real(8) :: E

        real(8) :: s
        integer :: i, j, k

        E = 0.0d0

        do i=1, L
            do j=1, L
                do k=1, L
                    s = 0.0d0

                    if (i == L) then
                        s = s + lattice(1, j, k)
                    else
                        s = s + lattice(i + 1, j, k)
                    end if

                    if (j == L) then
                        s = s + lattice(i, 1, k)
                    else
                        s = s + lattice(i, j + 1, k)
                    end if

                    if (k == L) then
                        s = s + lattice(i, j, 1)
                    else
                        s = s + lattice(i, j, k + 1)
                    end if

                    E = E - lattice(i, j, k) * s
                end do
            end do
        end do

        E = E * J_ising
    end function

    function magnetization(lattice) result(M)
        real(8), intent(in) :: lattice(:, :, :)
        real(8) :: M

        M = sum(lattice)
    end function

    function avg_energy(lattice, L, J_ising) result(E)
        real(8), intent(in) :: lattice(:, :, :)
        integer, intent(in) :: L
        real(8), intent(in) :: J_ising
        real(8) :: E

        E = energy(lattice, L, J_ising) / L**3
    end function

    function avg_magnetization(lattice, L) result(M)
        real(8), intent(in) :: lattice(:, :, :)
        integer, intent(in) :: L
        real(8) :: M

        M = magnetization(lattice) / L**3
    end function

    subroutine metropolis(lattice, L, J_ising, kbT)
        real(8), intent(inout) :: lattice(:, :, :)
        integer, intent(in) :: L
        real(8), intent(in) :: J_ising, kbT

        integer :: i, j, k, n, iter
        real(8) :: s, r, E

        do iter = 1, L**3
            call random_number(r)
            n = int(L**3 * r)

            i = 1 + n / (L*L)
            j = 1 + mod(n / L, L)
            k = 1 + mod(n, L)

            s = 0.0d0

            if (i == 1) then
                s = s + lattice(L, j, k)
            else
                s = s + lattice(i - 1, j, k)
            end if

            if (i == L) then
                s = s + lattice(1, j, k)
            else
                s = s + lattice(i + 1, j, k)
            end if

            if (j == 1) then
                s = s + lattice(i, L, k)
            else
                s = s + lattice(i, j - 1, k)
            end if

            if (j == L) then
                s = s + lattice(i, 1, k)
            else
                s = s + lattice(i, j + 1, k)
            end if

            if (k == 1) then
                s = s + lattice(i, j, L)
            else
                s = s + lattice(i, j, k - 1)
            end if

            if (k == L) then
                s = s + lattice(i, j, 1)
            else
                s = s + lattice(i, j, k + 1)
            end if

            E = - J_ising * s * lattice(i, j, k)

            if (E > 0.0d0) then
                lattice(i, j, k) = - lattice(i, j, k)
            else
                call random_number(r)
                if (r < exp(2 * E/kbT)) then
                    lattice(i, j, k) = - lattice(i, j, k)
                end if
            end if
        end do
    end subroutine

end module ising
