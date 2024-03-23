function f(x) result(y)
    real(8), intent(in) :: x(:)
    real(8) :: y

    y = 4 / (1 + (x(1))**2)
end function

function fsin(x) result(y)
    real(8), intent(in) :: x(:)
    real(8) :: y

    y = sin(x(1))
end function

function fgauss(x) result(y)
    use integrate, only: pi

    real(8), intent(in) :: x(:)
    real(8) :: y

    y = exp(-0.5 * x(1)**2) / sqrt(2 * pi)
end function

program assignment
    use integrate

    implicit none

    real(8) :: err, dx, res
    integer :: i, io1, io2

    procedure(integrable_function) :: f, fsin, fgauss

    call execute_command_line('mkdir -p data')

    ! 1a
    open(newunit=io1, file='data/1a.dat')
    res = trapezoidal(1, f, [0.0d0], [1.0d0], N=[500])
    write(io1, *) res
    close(io1)

    ! 1b
    open(newunit=io1, file='data/1b_dx.dat')
    open(newunit=io2, file='data/1b_err.dat')
    do i = 2, 5
        dx = 10.0d0 ** (-i)
        err = abs(pi - trapezoidal(1, f, [0.0d0], [1.0d0], dx=[dx]))
        write(io1, *) dx
        write(io2, *) err
    end do
    close(io1)
    close(io2)

    ! 1c
    open(newunit=io1, file='data/1c.dat')
    write(io1, *) trapezoidal(1, fsin, [0.0d0], [pi], N=[500])
    close(io1)

    ! 1d
    open(newunit=io1, file='data/1d.dat')
    write(io1, *) trapezoidal(1, fgauss, [-3.0d0], [3.0d0], N=[500])
    close(io1)

end program assignment
