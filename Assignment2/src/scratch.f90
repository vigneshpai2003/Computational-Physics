function f(x) result(y)
    real(8), intent(in) :: x(:)
    real(8) :: y

    y = x(1)**5
end function


program scratch
    use integrate
    implicit none

    procedure(integrable_function) :: f
    real(8) :: s

    s = bode(1, f, [0.0d0], [1.0d0], N=[4])

    print *, simpson(1, f, [0.0d0], [1.0d0], N=[4])
    print *, simpson2(1, f, [0.0d0], [1.0d0], N=[4])
    print *, s

end program scratch
