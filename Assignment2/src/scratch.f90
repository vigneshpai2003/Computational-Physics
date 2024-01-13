function f(x) result(y)
    real(8), intent(in) :: x(:)
    real(8) :: y

    y = x(1)**3
end function

program scratch
    use integrate
    use mc
    
    implicit none

    procedure(integrable_function) :: f
    real(8) :: integral, error

    call mc_brute(1, f, 10, integral, error)

    print *, integral, error, error / integral * 100

end program scratch
