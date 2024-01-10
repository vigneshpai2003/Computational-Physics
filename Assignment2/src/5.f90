function g(x) result(z)
    real(8), intent(in) :: x(:)
    real(8) :: z

    z = exp(- norm2(x)**2 - 0.5 * ((x(1) - x(4))**2 + (x(2) - x(5))**2 + (x(3) - x(6))**2))
end function

function g2(x) result(z)
    use integrate

    real(8), intent(in) :: x(:)
    real(8) :: z
    procedure(integrable_function) :: g

    z = g(tan(x)) / (product(cos(x))**2)
end function

program assignment
    use integrate

    implicit none
    
    procedure(integrable_function) :: g, g2
    
    real(8) :: a(6), b(6)
    integer :: N(6)

    a = - pi / 2 + 0.001
    b = pi / 2 - 0.001
    N = 20

    print *, trapezoidal(6, g2, a, b, N=N)
end program assignment
