module md
    implicit none

    real(8) :: L, m, r_c, epsilon, sigma, kBT

contains
    ! places the particles on a uniform lattice
    subroutine lattice_positions(N, x)
        integer, intent(in) :: N
        real(8), intent(out) :: x(3 * N)

        integer :: i, j, k, p, N_L

        N_L = nint(N**(1.0d0/3))

        p = 1
        do i = 0, N_L
            do j = 0, N_L
                do k = 0, N_L
                    if (p .le. 3 * N) x(p: p + 2) = [i, j, k] * L / (N_L + 1)
                    p = p + 3
                end do
            end do
        end do
    end subroutine

    ! sets uniform random velocities scaled by specified temperature
    subroutine random_velocities(N, v, init_kBT)
        integer, intent(in) :: N
        real(8), intent(out) :: v(3 * N)
        real(8), intent(in) :: init_kBT
        
        call random_number(v)
        v = sqrt(12 * init_kBT / m) * (v - 0.5d0)
    end subroutine

    ! computes the distance r in a periodic cubic volume given a displacement
    ! modifies dx according to the minimum r
    subroutine periodic_distance(dx, r)
        real(8), intent(inout) :: dx(3)
        real(8), intent(out) :: r

        integer :: k

        do k = 1, 3
            if (abs(dx(k)) > L / 2) dx(k) = dx(k) - sign(L, dx(k))
        end do

        r = norm2(dx)
    end subroutine

    ! calculates the neighbor matrix with particles within distance r_c + R
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

    ! updates positions using velocity verlet
    subroutine update_x(N, x, v, F, dt)
        integer, intent(in) :: N
        real(8), intent(in) :: v(3 * N), F(3 * N), dt
        real(8), intent(inout) :: x(3 * N)

        x = x + v * dt + 0.5d0 * F * dt**2 / m
        x = mod(x, L) + merge(L, 0.0d0, x < 0.0d0)
    end subroutine

    ! updates velocities using velocity verlet
    subroutine update_v(N, v, F, F_new, dt)
        integer, intent(in) :: N
        real(8), intent(in) :: F(3 * N), F_new(3 * N), dt
        real(8), intent(inout) :: v(3 * N)
        
        v = v + 0.5d0 * (F + F_new) * dt / m
    end subroutine

    ! calculates force and potential energy
    subroutine force(N, x, F, neighbors, PE)
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

    ! calculates force and potential energy using multiple cores
    subroutine force_multi(N, x, F, neighbors, PE)
        integer, intent(in) :: N
        real(8), intent(in) :: x(3 * N)
        real(8), intent(out) :: F(3 * N), PE
        logical, intent(in) :: neighbors(N, N)

        integer :: i, j
        real(8) :: dx(3), r, F_r, F_c, V_c, PE_array(N)

        F_c = 12 * sigma**12 / r_c**13 - 6 * sigma**6 / r_c**7
        V_c = ((sigma / r_c)**12 - (sigma / r_c)**6) + F_c * r_c

        F = 0
        PE_array = 0

        !$omp parallel do default(shared) private(i, j, dx, r, F_r)
        do i = 1, 3 * N, 3
            do j = 1, 3 * N, 3
                if ((i == j) .or. (.not. neighbors((i + 2) / 3, (j + 2) / 3))) cycle

                dx = x(i : i + 2) - x(j : j + 2)
                call periodic_distance(dx, r)

                if (r < r_c) then
                    F_r = 12 * sigma**12 / r**13 - 6 * sigma**6 / r**7 - F_c
                    F(i : i + 2) = F(i : i + 2) + F_r * dx / r

                    PE_array((i + 2) / 3) = PE_array((i + 2) / 3) &
                                          + (sigma / r)**12 - (sigma / r)**6 + F_c * r - V_c
                end if
            end do
        end do
        !$omp end parallel do

        F = F * 4 * epsilon
        PE = sum(PE_array) * 4 * epsilon / 2
    end subroutine

    ! calculates kinetic energy
    function calc_KE(N, v) result(E)
        integer, intent(in) :: N
        real(8), intent(in) :: v(3 * N)
        real(8) :: E

        E = 0.5d0 * m * sum(v * v)
    end function

    ! calculates potential energy
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

    ! calculates potential energy using multiple cores
    function calc_PE_multi(N, x, neighbors) result(PE)
        integer, intent(in) :: N
        real(8), intent(in) :: x(3 * N)
        logical, intent(in) :: neighbors(N, N)
        
        real(8) :: PE

        integer :: i, j
        real(8) :: dx(3), r, F_c, V_c, PE_array(N)

        F_c = 12 * sigma**12 / r_c**13 - 6 * sigma**6 / r_c**7
        V_c = ((sigma / r_c)**12 - (sigma / r_c)**6) + F_c * r_c

        PE_array = 0

        !$omp parallel do default(shared) private(i, j, dx, r)
        do i = 1, 3 * N, 3
            do j = 1, 3 * N, 3
                if ((i == j) .or. (.not. neighbors((i + 2) / 3, (j + 2) / 3))) cycle

                dx = x(i : i + 2) - x(j : j + 2)
                call periodic_distance(dx, r)

                if (r < r_c) then
                    PE_array((i + 2) / 3) = PE_array((i + 2) / 3) &
                                          + (sigma / r)**12 - (sigma / r)**6 + F_c * r - V_c
                end if
            end do
        end do
        !$omp end parallel do

        PE = sum(PE_array) * 4 * epsilon / 2
    end function

    ! scales velocities to get a particular temperature
    subroutine thermostat(N, v, new_kBT)
        integer, intent(in) :: N
        real(8), intent(inout) :: v(3 * N), new_kBT

        v = v * sqrt(3 * new_kBT * N / (2 * calc_KE(N, v)))
    end subroutine

    ! ----------------------------------------
    ! Some useful utilities
    ! ----------------------------------------

    ! write array to file
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

    ! write matrix to file
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

    ! integer to string
    function str(k) result(string)
        integer, intent(in) :: k
        character(20) :: string

        write(string, *) k

        string = adjustl(string)
    end function str
end module md
