function f(d, t, y) result(dy_dt)
    integer, intent(in) :: d
    real(8), intent(in) :: t, y(d)
    real(8) :: dy_dt(d)

    dy_dt(1) = y(51)
    dy_dt(51) = y(2) + y(50) - 2 * y(1)
    
    do i = 2, 49
        dy_dt(i) = y(50 + i)
        dy_dt(50 + i) = y(i + 1) + y(i - 1) - 2 * y(i)
    end do

    dy_dt(50) = y(100)
    dy_dt(100) = y(1) + y(49) - 2 * y(50)

end function

program scratch
    use ode
    implicit none

    procedure(integrable_function) f
    real(8), allocatable :: t(:), y(:, :)
    real(8) :: y_0(100)
    integer :: io, i

    y_0(:) = 0
    y_0(1) = 0.8d0
    y_0(26) = 0.8d0

    call RK4(100, f, 0.0d0, y_0, 0.02d0, 2001, t, y)
    
    open(newunit=io, file="data/8.dat")
    do i = 1, size(t)
        write(io, *) t(i), y(i, 1:50)
    end do
    close(io)

    deallocate(t)
    deallocate(y)

end program scratch
