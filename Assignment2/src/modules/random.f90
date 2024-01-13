module random
    implicit none

    real(8), parameter :: pi = 2 * asin(1.0d0)

contains

    function moment(array, k, a, b) result(m)
        real(8), intent(in) :: array(:)
        integer, intent(in) :: k
        real(8), optional, value :: a, b

        real(8) :: m

        if (.not. present(a)) then
            a = 0.0d0
        else if (.not. present(b)) then
            b = 1.0d0
        end if

        m = sum(array ** k) / size(array)
    end function

    function autocorrelation(array, k) result(c)
        real(8), intent(in) :: array(:)
        integer, intent(in) :: k

        real(8) :: c, cik, ci, ci2
        integer :: N

        N = size(array)

        cik = sum(array(1 : N - k) * array(1 + k : N)) / (N - k)
        ci = sum(array) / N
        ci2 = sum(array ** 2) / N

        c = (cik - ci**2) / (ci2 - ci**2)
    end function

    ! Marsaglia polar method
    subroutine box_muller(array, sigma, mu)
        ! array size must be even
        real(8), intent(out) :: array(:)
        real(8), optional, value :: sigma, mu
        
        integer :: N, i
        real(8) :: u, v, s, t

        if (.not. present(sigma)) then
            sigma = 1.0d0
        else if (.not. present(mu)) then
            mu = 1.0d0
        end if

        N = size(array) / 2

        do i = 1, N
            s = 2.0d0
            do while (s > 1)
                call random_number(u)
                call random_number(v)
                u = 2 * u - 1
                v = 2 * v - 1
                s = u*u + v*v
            end do

            t = sigma * sqrt(-(2 * log(s)) / s)
            
            array(i) = t * u + mu
            array(N + i) = t * v + mu
        end do
    end subroutine

    ! basic method using exp
    subroutine box_muller2(array, sigma, mu)
        ! array size must be even
        real(8), intent(out) :: array(:)
        real(8), optional, value :: sigma, mu
        
        integer :: N
        real(8), allocatable :: U(:), V(:)
        complex(8), allocatable :: z(:)
        complex(8) :: twopi_i

        twopi_i = (0.0d0, 2)

        if (.not. present(sigma)) then
            sigma = 1.0d0
        else if (.not. present(mu)) then
            mu = 1.0d0
        end if

        N = size(array) / 2

        allocate(U(N))
        allocate(V(N))
        allocate(z(N))

        call random_number(U)
        call random_number(V)

        z = sigma * sqrt(- 2 * log(U)) * exp(twopi_i * V) + mu

        array(1:N) = real(z)
        array(N+1:2*N) = imag(z)

        deallocate(U)
        deallocate(V)
        deallocate(z)
    end subroutine

end module random
