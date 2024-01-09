function f(x) result(y)
    real(8), intent(in) :: x
    real(8) :: y

    y = x**2
end function

program hello
    use utils

    implicit none

    procedure(integrable_function) :: f

    print *, simpson(f, 0.0d0, 1.0d0)

end program hello
