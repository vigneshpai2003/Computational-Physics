module mc
    use random, only: box_muller, pi

    implicit none

    abstract interface
        function mc_function(x) result(func)
            real(8), intent(in) :: x(:)
            real(8) :: func
        end function
    end interface

contains
    ! error = O(1/N^0.5)

    ! Monte Carlo with custom random number generator
    subroutine mc_custom(d, f, N, integral, rng, error)
        integer, intent(in) :: d, N
        procedure(mc_function) :: f
        real(8), intent(out) :: integral
        real(8), intent(out), optional :: error

        interface
            subroutine rng(harvest)
                real(8) :: harvest(:)
            end subroutine
        end interface

        real(8), allocatable :: x(:), avg_f2
        integer :: i
        logical :: calc_error

        calc_error = present(error)

        allocate(x(d))

        integral = 0

        if (calc_error) then
            avg_f2 = 0

            do i = 1, N
                call rng(x)
                integral = integral + f(x)
                avg_f2 = avg_f2 + f(x)**2
            end do

            avg_f2 = avg_f2 / N
        else
            do i = 1, N
                call rng(x)
                integral = integral + f(x)
            end do
        end if

        integral = integral / N

        if (calc_error) then
            error = sqrt((avg_f2 - integral**2)/N)
        end if

        deallocate(x)
    end subroutine

    ! Monte Carlo over unit hypercube with uniform sampling
    subroutine mc_brute(d, f, N, integral, error)
        integer, intent(in) :: d, N
        procedure(mc_function) :: f
        real(8), intent(out) :: integral
        real(8), intent(out), optional :: error

        call mc_custom(d, f, N, integral, rn_uniform, error)

    contains
        
        subroutine rn_uniform(harvest)
            real(8) :: harvest(:)
            call random_number(harvest)
        end subroutine
    end subroutine

    ! Monte Carlo over rectangle with uniform sampling
    subroutine mc_brute_rectangle(d, f, N, a, b, integral, error)
        integer, intent(in) :: d, N
        procedure(mc_function) :: f
        real(8), intent(in) :: a(:), b(:)
        real(8), intent(out) :: integral
        real(8), intent(out), optional :: error

        call mc_brute(d, f_tilde, N, integral, error)

    contains

        function f_tilde(x) result(y)
            real(8), intent(in) :: x(:)
            real(8) :: y

            y = f(a + (b - a) * x) * product(b - a)
        end function
    end subroutine

    ! Monte Carlo using Gaussian sampling
    subroutine mc_gaussian(d, f, N, mu, sigma, integral, error)
        integer, intent(in) :: d, N
        procedure(mc_function) :: f
        real(8), intent(in) :: mu(:), sigma(:)
        real(8), intent(out) :: integral
        real(8), intent(out), optional :: error

        call mc_custom(d, f_tilde, N, integral, rn_gaussian, error)

    contains

        function f_tilde(x_) result(y)
            real(8), intent(in) :: x_(:)
            real(8) :: y

            y = f(x_) * (2 * pi)**(d / 2) * product(sigma) * exp(sum((x_ - mu)**2 / (2 * sigma**2)))
        end function

        subroutine rn_gaussian(harvest)
            real(8) :: harvest(:)
            call box_muller(harvest)
            harvest = sigma * harvest + mu
        end subroutine
    end subroutine

end module mc
