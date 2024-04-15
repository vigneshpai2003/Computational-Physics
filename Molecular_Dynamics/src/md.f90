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
        outer: do i = 0, N_L
            do j = 0, N_L
                do k = 0, N_L
                    if (p > 3 * N - 2) exit outer
                    x(p: p + 2) = [i, j, k] * L / (N_L + 1)
                    p = p + 3
                end do
            end do
        end do outer
    end subroutine

    ! sets uniform random velocities scaled by specified temperature
    subroutine random_velocities(N, v, init_kBT)
        integer, intent(in) :: N
        real(8), intent(out) :: v(3 * N)
        real(8), intent(in) :: init_kBT
        
        call random_number(v)
        v = sqrt(12 * init_kBT / m) * (v - 0.5d0)

        v(1::3) = v(1::3) - sum(v(1::3)) / N
        v(2::3) = v(2::3) - sum(v(2::3)) / N
        v(3::3) = v(3::3) - sum(v(3::3)) / N
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

    function msd(N, x, x_0) result(ms)
        integer, intent(in) :: N
        real(8), intent(in) :: x(3 * N), x_0(3 * N)

        real(8) :: ms, dx(3 * N)
        integer :: i

        dx = x - x_0
        do i = 1, 3 * N
            if (abs(dx(i)) > L / 2) dx(i) = dx(i) - sign(L, dx(i))
        end do

        ms = sum(dx**2) / N
    end function

    ! calculates the neighbor matrix with particles within distance r_c + R
    subroutine calc_neighbors_single(N, x, neighbors_size, neighbors, R)
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
                    neighbors(i, neighbors_size(i)) = j
                end if
            end do
        end do
    end subroutine

    ! calculates the neighbor matrix with particles within distance r_c + R
    subroutine calc_neighbors_multi(N, x, neighbors_size, neighbors, R)
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
                    neighbors(i, neighbors_size(i)) = j

                    neighbors_size(j) = neighbors_size(j) + 1
                    neighbors(j, neighbors_size(j)) = i
                end if
            end do
        end do
    end subroutine

    ! updates positions using velocity verlet
    subroutine update_position(N, x, v, F, dt)
        integer, intent(in) :: N
        real(8), intent(in) :: v(3 * N), F(3 * N), dt
        real(8), intent(inout) :: x(3 * N)

        x = x + v * dt + 0.5d0 * F * dt**2 / m
        x = mod(x, L) + merge(L, 0.0d0, x < 0.0d0)
    end subroutine

    ! updates velocities using velocity verlet
    subroutine update_velocity(N, v, F, F_new, dt)
        integer, intent(in) :: N
        real(8), intent(in) :: F(3 * N), F_new(3 * N), dt
        real(8), intent(inout) :: v(3 * N)
        
        v = v + 0.5d0 * (F + F_new) * dt / m
    end subroutine

    ! calculates force and potential energy
    subroutine force_single(N, x, F, neighbors_size, neighbors, PE)
        integer, intent(in) :: N
        real(8), intent(in) :: x(3 * N)
        real(8), intent(out) :: F(3 * N), PE
        integer, intent(in) :: neighbors_size(N), neighbors(N, N)

        integer :: i, j, k
        real(8) :: dx(3), r, F_r, F_c, V_c

        F_c = 12 * sigma**12 / r_c**13 - 6 * sigma**6 / r_c**7
        V_c = ((sigma / r_c)**12 - (sigma / r_c)**6) + F_c * r_c

        F = 0
        PE = 0

        do i = 1, N - 1
            do k = 1, neighbors_size(i)
                j = neighbors(i, k)

                dx = x(3 * i - 2 : 3 * i) - x(3 * j - 2 : 3 * j)
                call periodic_distance(dx, r)

                if (r < r_c) then
                    F_r = 12 * sigma**12 / r**13 - 6 * sigma**6 / r**7 - F_c
                    F(3 * i - 2: 3 * i) = F(3 * i - 2 : 3 * i) + F_r * dx / r
                    F(3 * j - 2: 3 * j) = F(3 * j - 2 : 3 * j) - F_r * dx / r

                    PE = PE + (sigma / r)**12 - (sigma / r)**6 + F_c * r - V_c
                end if
            end do
        end do

        F = F * 4 * epsilon
        PE = PE * 4 * epsilon
    end subroutine

    ! does not calculate potential energy
    subroutine force_only_single(N, x, F, neighbors_size, neighbors)
        integer, intent(in) :: N
        real(8), intent(in) :: x(3 * N)
        real(8), intent(out) :: F(3 * N)
        integer, intent(in) :: neighbors_size(N), neighbors(N, N)

        integer :: i, j, k
        real(8) :: dx(3), r, F_r, F_c

        F_c = 12 * sigma**12 / r_c**13 - 6 * sigma**6 / r_c**7

        F = 0

        do i = 1, N - 1
            do k = 1, neighbors_size(i)
                j = neighbors(i, k)

                dx = x(3 * i - 2 : 3 * i) - x(3 * j - 2 : 3 * j)
                call periodic_distance(dx, r)

                if (r < r_c) then
                    F_r = 12 * sigma**12 / r**13 - 6 * sigma**6 / r**7 - F_c
                    F(3 * i - 2: 3 * i) = F(3 * i - 2 : 3 * i) + F_r * dx / r
                    F(3 * j - 2: 3 * j) = F(3 * j - 2 : 3 * j) - F_r * dx / r
                end if
            end do
        end do

        F = F * 4 * epsilon
    end subroutine

    ! calculates force and potential energy using multiple cores
    subroutine force_multi(N, x, F, neighbors_size, neighbors, PE)
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

    ! does not calculate potential energy
    subroutine force_only_multi(N, x, F, neighbors_size, neighbors)
        integer, intent(in) :: N
        real(8), intent(in) :: x(3 * N)
        real(8), intent(out) :: F(3 * N)
        integer, intent(in) :: neighbors_size(N), neighbors(N, N)

        integer :: i, j, k
        real(8) :: dx(3), r, F_r, F_c

        F_c = 12 * sigma**12 / r_c**13 - 6 * sigma**6 / r_c**7

        F = 0

        !$omp parallel do default(shared) private(i, j, k, dx, r, F_r)
        do i = 1, N
            do k = 1, neighbors_size(i)
                j = neighbors(i, k)

                dx = x(3 * i - 2 : 3 * i) - x(3 * j - 2 : 3 * j)
                call periodic_distance(dx, r)

                if (r < r_c) then
                    F_r = 12 * sigma**12 / r**13 - 6 * sigma**6 / r**7 - F_c
                    F(3 * i - 2: 3 * i) = F(3 * i - 2 : 3 * i) + F_r * dx / r
                end if
            end do
        end do
        !$omp end parallel do

        F = F * 4 * epsilon
    end subroutine

    ! calculates kinetic energy
    function calc_KE(N, v) result(E)
        integer, intent(in) :: N
        real(8), intent(in) :: v(3 * N)
        real(8) :: E

        E = 0.5d0 * m * sum(v * v)
    end function

    ! calculates potential energy
    function calc_PE_single(N, x, neighbors_size, neighbors) result(PE)
        integer, intent(in) :: N
        real(8), intent(in) :: x(3 * N)
        integer, intent(in) :: neighbors_size(N), neighbors(N, N)

        real(8) :: PE

        integer :: i, j, k
        real(8) :: dx(3), r, F_c, V_c

        F_c = 12 * sigma**12 / r_c**13 - 6 * sigma**6 / r_c**7
        V_c = ((sigma / r_c)**12 - (sigma / r_c)**6) + F_c * r_c

        PE = 0

        do i = 1, N - 1
            do k = 1, neighbors_size(i)
                j = neighbors(i, k)

                dx = x(3 * i - 2 : 3 * i) - x(3 * j - 2 : 3 * j)
                call periodic_distance(dx, r)

                if (r < r_c) then
                    PE = PE + (sigma / r)**12 - (sigma / r)**6 + F_c * r - V_c
                end if
            end do
        end do

        PE = PE * 4 * epsilon
    end function

    ! calculates potential energy using multiple cores
    function calc_PE_multi(N, x, neighbors_size, neighbors) result(PE)
        integer, intent(in) :: N
        real(8), intent(in) :: x(3 * N)
        integer, intent(in) :: neighbors_size(N), neighbors(N, N)
        
        real(8) :: PE

        integer :: i, j, k
        real(8) :: dx(3), r, F_c, V_c, PE_array(N)

        F_c = 12 * sigma**12 / r_c**13 - 6 * sigma**6 / r_c**7
        V_c = ((sigma / r_c)**12 - (sigma / r_c)**6) + F_c * r_c

        PE_array = 0

        !$omp parallel do default(shared) private(i, j, k, dx, r)
        do i = 1, N
            do k = 1, neighbors_size(i)
                j = neighbors(i, k)

                dx = x(3 * i - 2 : 3 * i) - x(3 * j - 2 : 3 * j)
                call periodic_distance(dx, r)

                if (r < r_c) then
                    PE_array(i) = PE_array(i) + (sigma / r)**12 - (sigma / r)**6 + F_c * r - V_c
                end if
            end do
        end do
        !$omp end parallel do

        PE = sum(PE_array) * 4 * epsilon / 2
    end function

    ! scales velocities to get a particular temperature
    subroutine thermostat(N, v, new_kBT)
        integer, intent(in) :: N
        real(8), intent(in) :: new_kBT
        real(8), intent(inout) :: v(3 * N)

        v = v * sqrt(3 * new_kBT * N / (2 * calc_KE(N, v)))
    end subroutine

    ! counts the average number of particles between distance r and r + dr
    subroutine radial_count(N, x, dr, n_r)
        integer, intent(in) :: N
        real(8), intent(in) :: x(3 * N), dr
        real(8), intent(out) :: n_r(:)

        integer :: i, j, k
        real(8) :: dx(3), r

        n_r = 0

        do i = 1, N - 1
            do j = i + 1, N
                dx = x(3 * i - 2 : 3 * i) - x(3 * j - 2 : 3 * j)
                call periodic_distance(dx, r)
    
                k = 1 + int(r / dr)
                if (k <= size(n_r)) n_r(k) = n_r(k) + 2
            end do
        end do

        n_r = n_r / N
    end subroutine

    ! converts radial count to pair correlation function
    subroutine n_r_to_pair_correlation(N, dr, n_r)
        integer, intent(in) :: N
        real(8), intent(in) :: dr
        real(8), intent(inout) :: n_r(:)

        integer :: i

        do i = 1, size(n_r)
            n_r(i) = n_r(i) / (dr * (i - 0.5d0))**2
        end do

        n_r = n_r / (4 * 3.1415d0 * dr * N / L**3)
    end subroutine

    ! calculates velocity distribution
    subroutine velocity_dist(N, v, dv, rho_v)
        integer, intent(in) :: N
        real(8), intent(in) :: dv, v(3 * N)
        real(8), intent(out) :: rho_v(:)

        integer :: i, k

        rho_v = 0

        do i = 1, N
            k = 1 + int(sqrt(sum(v(3 * i - 2: 3 * i)**2)) / dv)
            if (k <= size(rho_v)) rho_v(k) = rho_v(k) + 1
        end do

        rho_v = rho_v / N
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
