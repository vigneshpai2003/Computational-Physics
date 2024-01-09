function f(x) result(y)
    real(8), intent(in) :: x
    real(8) :: y

    y = 4 / (1 + x**2)
end function

function fsin(x) result(y)
    real(8), intent(in) :: x
    real(8) :: y

    y = sin(x)
end function

function fgauss(x) result(y)
    use utils

    real(8), intent(in) :: x
    real(8) :: y

    y = exp(-0.5 * x**2) / sqrt(2 * pi)
end function

function g(x) result(z)
    real(8), intent(in) :: x(6)
    real(8) :: z

    z = exp(- norm2(x)**2 - 0.5 * ((x(1) - x(4))**2 + (x(2) - x(5))**2 + (x(3) - x(6))**2))
end function

program hello
    use utils

    implicit none

    real(8) :: err, dx
    integer :: i, io1, io2

    procedure(integrable_function) :: f, fsin, fgauss
    procedure(integrable_function_ndim) :: g

    call execute_command_line('mkdir -p data')

    ! 1a
    open(newunit=io1, file='data/1a.dat')
    write(io1, *) trapezoidal(f, 0.0d0, 1.0d0, N=500)
    close(io1)

    ! 1b
    open(newunit=io1, file='data/1b_dx.dat')
    open(newunit=io2, file='data/1b_err.dat')
    do i = 2, 5
        dx = 10.0d0 ** (-i)
        err = abs(pi - trapezoidal(f, 0.0d0, 1.0d0, dx=dx))
        write(io1, *) dx
        write(io2, *) err
    end do
    close(io1)
    close(io2)

    ! 1c
    open(newunit=io1, file='data/1c.dat')
    write(io1, *) trapezoidal(fsin, 0.0d0, pi, N=500)
    close(io1)

    ! 1d
    open(newunit=io1, file='data/1d.dat')
    write(io1, *) trapezoidal(fgauss, -3.0d0, 3.0d0, N=500)
    close(io1)

end program hello
