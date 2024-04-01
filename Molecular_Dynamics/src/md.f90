module md
    implicit none

    real(8) :: L = 10, m = 1, r_c = 2.5, epsilon = 1, sigma = 1, kBT = 100

contains

    subroutine force(N, x, F)
        integer, intent(in) :: N
        real(8), intent(in) :: x(3 * N)
        real(8), intent(out) :: F(3 * N)

        integer :: i, j, k
        real(8) :: dx(3), r, F_r, F_c

        F_c = 4 * epsilon * (12 * sigma**12 / r_c**13 - 6 * sigma**6 / r_c**7)

        F = 0

        do i = 1, 3 * N, 3
            do j = i + 3, 3 * N, 3

                dx = x(i : i + 2) - x(j : j + 2)
                do k = 1, 3
                    if (abs(dx(k)) > L / 2) dx(k) = dx(k) - sign(L, dx(k))
                end do

                r = norm2(dx)

                if (r < r_c) then
                    F_r = 4 * epsilon * (12 * sigma**12 / r**13 - 6 * sigma**6 / r**7) - F_c
                    F(i : i + 2) = F(i : i + 2) + F_r * dx
                    F(j : j + 2) = F(j : j + 2) - F_r * dx
                end if
            end do
        end do
    end subroutine
    
end module md

program scratch
    use md
    implicit none

    integer, parameter :: N = 10, N_t = 100
    real(8), parameter :: dt = 0.01d0

    integer :: t
    real(8) :: x(3 * N), v(3 * N), F(3 * N)
    real(8) :: x_new(3 * N), v_new(3 * N), F_new(3 * N)

    call random_number(x)
    x = x * L

    call random_number(v)
    v = sqrt(12 * kBT / m) * (v - 0.5d0)
    
    call force(N, x, F)

    do t = 1, N_t
        x_new = x + v * dt + 0.5d0 * F * dt**2 / m

        x_new = mod(x_new, L) + merge(L, 0.0d0, x_new < 0.0d0)

        call force(N, x_new, F_new)

        v_new = v + 0.25d0 * (F + F_new) * dt / m

        x = x_new
        F = F_new
        v = v_new

        print *, x
    end do

end program scratch
