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
    use integrate, only: integrable_function, trapezoidal
    use mc

    implicit none

    real(8), parameter :: integral_val = 10.962374249993158057378737258690728183574403397727972963531570721d0
    procedure(integrable_function) :: g, g2

    real(8) :: a(6), b(6)
    integer :: N(6), io

    character(len=*), parameter :: f = "(F12.7)"

    real(8) :: integral, error

    a = -5
    b = 5

    call mc_brute_rectangle(6, g, 1000000, a, b, integral, error)

    open(newunit=io, file='data/5a_val.dat')
    write(io, f) integral
    close(io)

    open(newunit=io, file='data/5a_error_mc.dat')
    write(io, f) error
    close(io)

    open(newunit=io, file='data/5a_error_actual.dat')
    write(io, f) abs(integral_val - integral)
    close(io)

    a = 0
    b = 1

    call mc_gaussian(6, g, 1000000, a, b, integral, error)

    open(newunit=io, file='data/5b_val.dat')
    write(io, f) integral
    close(io)

    open(newunit=io, file='data/5b_error_mc.dat')
    write(io, f) error
    close(io)

    open(newunit=io, file='data/5b_error_actual.dat')
    write(io, f) abs(integral_val - integral)
    close(io)

    a = -pi/2
    b = pi/2

    call mc_brute_rectangle(6, g2, 1000000, a, b, integral, error)

    open(newunit=io, file='data/5c_val.dat')
    write(io, f) integral
    close(io)

    open(newunit=io, file='data/5c_error_mc.dat')
    write(io, f) error
    close(io)

    open(newunit=io, file='data/5c_error_actual.dat')
    write(io, f) abs(integral_val - integral)
    close(io)

end program assignment
