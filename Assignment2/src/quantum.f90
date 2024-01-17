function f(x) result(E)
    real(8), intent(in) :: x(:)
    real(8) :: E, r_1(3), r_2(3)

    r_1 = x(1:3)
    r_2 = x(4:6)
    E = exp(- 4 * (norm2(r_1) + norm2(r_2))) / norm2(r_1 - r_2)
end function

program quantum
    use mc
    implicit none

    procedure(mc_function) :: f
    real(8) :: integral, error, mu(6), sigma(6), c
    integer :: io

    mu = 0.0d0
    sigma = 0.4d0
    c = (1.609d0)/(4.0d0 * pi * 8.854d0) * (8.0d0/pi)**2 * 10**4 / 5.29d0

    call mc_gaussian(6, f, 100000, mu, sigma, integral, error)

    integral = integral * c
    error = error * c

    open(newunit=io, file="data/quantum.dat")
    write(io, *) integral - 108.8, '\pm', error
    close(io)
end program quantum
