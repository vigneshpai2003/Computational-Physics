module utils
    implicit none
    private
    public :: simpson, integrable_function

    abstract interface
        function integrable_function(x) result(func)
            real*8, intent(in) :: x
            real*8 :: func
        end function
    end interface

contains

    function simpson(f, a, b) result(s)
        real*8, intent(in) :: a, b
        procedure(integrable_function) :: f
        real*8 :: s

        s = (b-a) / 6 * (f(a) + 4*f((a+b)/2) + f(b))
    end function simpson

end module utils
