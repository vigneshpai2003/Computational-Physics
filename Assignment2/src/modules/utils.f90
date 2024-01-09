module utils
    implicit none

    real(8), parameter :: pi = 2 * asin(1.0d0)

    private
    public :: pi, integrable_function, integrable_function_ndim, trapezoidal

    abstract interface
        function integrable_function(x) result(func)
            real(8), intent(in) :: x
            real(8) :: func
        end function
    end interface

    abstract interface
        function integrable_function_ndim(x) result(func)
            real(8), intent(in) :: x(:)
            real(8) :: func
        end function
    end interface

contains

    function trapezoidal(f, a, b, dx, N) result(integral)
        procedure(integrable_function) :: f
        real(8), intent(in) :: a, b
        ! exactly one of step or N is expected to be given
        real(8), optional, value :: dx
        integer, optional, value :: N

        real(8) :: integral
        integer :: i

        if (present(dx)) then
            N = nint((b - a) / dx)
        else if (present(N)) then
            dx = (b - a) / N
        end if

        integral = 0.5 * (f(a) + f(b))

        do i = 1, N - 1
            integral = integral + f(a + i * dx)
        end do

        integral = integral * dx
    end function trapezoidal

end module utils
