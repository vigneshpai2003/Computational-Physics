function f(d, t, y) result(dy_dt)
    integer, intent(in) :: d
    real(8), intent(in) :: t, y(d)
    real(8) :: dy_dt(d)

    dy_dt(1) = y(2)
    dy_dt(2) = - sin(y(1))
end function

program scratch
    use ode
    implicit none

    procedure(integrable_function) f
    real(8), allocatable :: t(:), y(:, :)
    integer :: io, i

    call execute_command_line("mkdir -p data/arrays")

    call RK4(2, f, 0.0d0, [0.1d0, 1.9d0], 0.01d0, 5001, t, y)

    open(newunit=io, file="data/arrays/5.dat")
    do i = 1, size(t)
        write(io, *) t(i), y(i, :)
    end do
    close(io)

    open(newunit=io, file="data/q5.dat")
    write(io, *) y(size(t), 1)
    close(io)

    deallocate(t)
    deallocate(y)

    call RK4(2, f, 0.0d0, [0.0d0, 1.999d0], 0.01d0, 5001, t, y)
        
    open(newunit=io, file="data/arrays/6.dat")
    do i = 1, size(t)
        write(io, *) t(i), y(i, :)
    end do
    close(io)

    open(newunit=io, file="data/q6.dat")
    write(io, *) y(size(t), 1)
    close(io)

    deallocate(t)
    deallocate(y)

    call RK4(2, f, 0.0d0, [0.0d0, 2.01d0], 0.01d0, 5001, t, y)
        
    open(newunit=io, file="data/arrays/7.dat")
    do i = 1, size(t)
        write(io, *) t(i), y(i, :)
    end do
    close(io)

    open(newunit=io, file="data/q7.dat")
    write(io, *) y(size(t), 1)
    close(io)

    deallocate(t)
    deallocate(y)

end program scratch
