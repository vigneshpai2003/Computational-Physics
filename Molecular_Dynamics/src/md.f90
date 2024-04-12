module md
    implicit none

    real(8) :: L, m, r_c, epsilon, sigma, kBT

contains
    subroutine periodic_distance(dx, r)
        real(8), intent(inout) :: dx(3)
        real(8), intent(out) :: r

        integer :: k

        do k = 1, 3
            if (abs(dx(k)) > L / 2) dx(k) = dx(k) - sign(L, dx(k))
        end do

        r = norm2(dx)
    end subroutine

    subroutine calc_neighbors(N, x, neighbors, R)
        integer, intent(in) :: N
        real(8), intent(in) :: x(3 * N)
        logical, intent(out) :: neighbors(N, N)
        real(8), intent(in) :: R

        integer :: i, j
        real(8) :: dx(3), d

        neighbors = .false.

        do i = 1, N - 1
            do j = i + 1, N
                dx = x(3 * i - 2 : 3 * i) - x(3 * j - 2 : 3 * j)
                call periodic_distance(dx, d)

                neighbors(i, j) = (d < r_c + R)
                neighbors(j, i) = neighbors(i, j)
            end do
        end do
    end subroutine

    subroutine update_x(N, x, v, F, dt)
        integer, intent(in) :: N
        real(8), intent(in) :: v(3 * N), F(3 * N), dt
        real(8), intent(inout) :: x(3 * N)

        x = x + v * dt + 0.5d0 * F * dt**2 / m
        x = mod(x, L) + merge(L, 0.0d0, x < 0.0d0)
    end subroutine

    subroutine update_v(N, v, F, F_new, dt)
        integer, intent(in) :: N
        real(8), intent(in) :: F(3 * N), F_new(3 * N), dt
        real(8), intent(inout) :: v(3 * N)
        
        v = v + 0.5d0 * (F + F_new) * dt / m
    end subroutine

    subroutine force(N, x, F, PE, neighbors)
        integer, intent(in) :: N
        real(8), intent(in) :: x(3 * N)
        real(8), intent(out) :: F(3 * N), PE
        logical, intent(in) :: neighbors(N, N)

        integer :: i, j
        real(8) :: dx(3), r, F_r, F_c, V_c

        F_c = 12 * sigma**12 / r_c**13 - 6 * sigma**6 / r_c**7
        V_c = ((sigma / r_c)**12 - (sigma / r_c)**6) + F_c * r_c

        F = 0
        PE = 0

        do i = 1, 3 * N - 3, 3
            do j = i + 3, 3 * N, 3
                if (.not. neighbors((i + 2) / 3, (j + 2)/ 3)) cycle

                dx = x(i : i + 2) - x(j : j + 2)

                call periodic_distance(dx, r)

                if (r < r_c) then
                    F_r = 12 * sigma**12 / r**13 - 6 * sigma**6 / r**7 - F_c
                    F(i : i + 2) = F(i : i + 2) + F_r * dx / r
                    F(j : j + 2) = F(j : j + 2) - F_r * dx / r

                    PE = PE + (sigma / r)**12 - (sigma / r)**6 + F_c * r - V_c
                end if
            end do
        end do

        F = F * 4 * epsilon
        PE = PE * 4 * epsilon
    end subroutine

    function calc_KE(N, v) result(E)
        integer, intent(in) :: N
        real(8), intent(in) :: v(3 * N)
        real(8) :: E

        E = 0.5d0 * m * sum(v * v)
    end function

    function calc_PE(N, x, neighbors) result(E)
        integer, intent(in) :: N
        real(8), intent(in) :: x(3 * N)
        logical, intent(in) :: neighbors(N, N)

        real(8) :: E

        integer :: i, j
        real(8) :: dx(3), r, F_c, V_c

        F_c = 12 * sigma**12 / r_c**13 - 6 * sigma**6 / r_c**7
        V_c = ((sigma / r_c)**12 - (sigma / r_c)**6) + F_c * r_c

        E = 0

        do i = 1, 3 * N - 3, 3
            do j = i + 3, 3 * N, 3
                if (.not. neighbors((i + 2) / 3, (j + 2)/ 3)) cycle

                dx = x(i : i + 2) - x(j : j + 2)

                call periodic_distance(dx, r)

                if (r < r_c) then
                    E = E + (sigma / r)**12 - (sigma / r)**6 + F_c * r - V_c
                end if
            end do
        end do

        E = E * 4 * epsilon
    end function

    subroutine thermostat(N, v, new_kBT)
        integer, intent(in) :: N
        real(8), intent(inout) :: v(3 * N), new_kBT

        v = v * sqrt(3 * new_kBT * N / (2 * calc_KE(N, v)))
    end subroutine

    subroutine write_array(file, arr)
        character(*), intent(in) :: file
        real*8, intent(in) :: arr(:)

        integer :: i, io

        open(newunit=io, file=file)
        do i = 1, size(arr, 1)
            write(io, *) arr(i)
        end do
        close(io)
    end subroutine

    subroutine write_matrix(file, mat)
        character(*), intent(in) :: file
        real*8, intent(in) :: mat(:, :)

        integer :: i, io

        open(newunit=io, file=file)
        do i = 1, size(mat, 1)
            write(io, *) mat(i, :)
        end do
        close(io)
    end subroutine

    function str(k) result(string)
        integer, intent(in) :: k
        character(20) :: string

        write(string, *) k

        string = adjustl(string)
    end function str
end module md
