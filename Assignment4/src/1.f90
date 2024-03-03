function f(d, t, y) result(dy_dt)
    integer, intent(in) :: d
    real(8), intent(in) :: t, y(d)
    real(8) :: dy_dt(d)

    dy_dt = y**2 + 1.0d0
end function

program scratch
    use ode
    implicit none

    procedure(integrable_function) f
    real(8), allocatable :: t(:), y(:, :)
    integer :: io, i

    call euler(1, f, 0.0d0, [0.0d0], 0.001d0, 1551, t, y)

    call execute_command_line("mkdir -p data")

    open(newunit=io, file="data/1ye.dat")
    do i = 1, size(t)
        write(io, *) t(i), y(i, 1)
    end do
    close(io)

    deallocate(t)
    deallocate(y)

    call modified_euler(1, f, 0.0d0, [0.0d0], 0.001d0, 1551, t, y)
    
    open(newunit=io, file="data/1yme.dat")
    do i = 1, size(t)
        write(io, *) t(i), y(i, 1)
    end do
    close(io)

    deallocate(t)
    deallocate(y)
    
    call improved_euler(1, f, 0.0d0, [0.0d0], 0.001d0, 1551, t, y)
    
    open(newunit=io, file="data/1yie.dat")
    do i = 1, size(t)
        write(io, *) t(i), y(i, 1)
    end do
    close(io)

    deallocate(t)
    deallocate(y)
        
    call RK4(1, f, 0.0d0, [0.0d0], 0.01d0, 156, t, y)
   
    open(newunit=io, file="data/1yrk.dat")
    do i = 1, size(t)
        write(io, *) t(i), y(i, 1)
    end do
    close(io)

    deallocate(t)
    deallocate(y)
        
end program scratch
