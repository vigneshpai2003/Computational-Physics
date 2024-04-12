module md_alt
    use md
    implicit none

contains
    ! calculates the neighbor matrix with particles within distance r_c + R
    subroutine calc_neighbors_alt(N, x, neighbors_size, neighbors, R)
        use md

        integer, intent(in) :: N
        real(8), intent(in) :: x(3 * N)
        integer, intent(out) :: neighbors_size(N), neighbors(N, N)
        real(8), intent(in) :: R

        integer :: i, j
        real(8) :: dx(3), d

        neighbors_size = 0

        do i = 1, N - 1
            do j = i + 1, N
                dx = x(3 * i - 2 : 3 * i) - x(3 * j - 2 : 3 * j)
                call periodic_distance(dx, d)

                if (d < r_c + R) then
                    neighbors_size(i) = neighbors_size(i) + 1
                    neighbors_size(j) = neighbors_size(j) + 1

                    neighbors(i, neighbors_size(i)) = j
                    neighbors(j, neighbors_size(j)) = i
                end if
            end do
        end do
    end subroutine

    ! calculates force and potential energy using multiple cores
    subroutine force_multi_alt(N, x, F, neighbors_size, neighbors, PE)
        use md

        integer, intent(in) :: N
        real(8), intent(in) :: x(3 * N)
        real(8), intent(out) :: F(3 * N), PE
        integer, intent(in) :: neighbors_size(N), neighbors(N, N)

        integer :: i, j, k
        real(8) :: dx(3), r, F_r, F_c, V_c, PE_array(N)

        F_c = 12 * sigma**12 / r_c**13 - 6 * sigma**6 / r_c**7
        V_c = ((sigma / r_c)**12 - (sigma / r_c)**6) + F_c * r_c

        F = 0
        PE_array = 0

        !$omp parallel do default(shared) private(i, j, k, dx, r, F_r)
        do i = 1, N
            do k = 1, neighbors_size(i)
                j = neighbors(i, k)

                dx = x(3 * i - 2 : 3 * i) - x(3 * j - 2 : 3 * j)
                call periodic_distance(dx, r)

                if (r < r_c) then
                    F_r = 12 * sigma**12 / r**13 - 6 * sigma**6 / r**7 - F_c
                    F(3 * i - 2: 3 * i) = F(3 * i - 2 : 3 * i) + F_r * dx / r

                    PE_array(i) = PE_array(i) + (sigma / r)**12 - (sigma / r)**6 + F_c * r - V_c
                end if
            end do
        end do
        !$omp end parallel do

        F = F * 4 * epsilon
        PE = sum(PE_array) * 4 * epsilon / 2
    end subroutine

end module