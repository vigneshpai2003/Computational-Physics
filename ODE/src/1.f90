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
    real(8) :: ya
    real(8), allocatable :: t(:), y(:, :)
    integer :: io, i

    ya = tan(1.55)

    call euler(1, f, 0.0d0, [0.0d0], 0.001d0, 1551, t, y)

    call execute_command_line("mkdir -p data/arrays")

    open(newunit=io, file="data/arrays/ye.dat")
    do i = 1, size(t)
        write(io, *) t(i), y(i, 1)
    end do
    close(io)

    open(newunit=io, file="data/q1.dat")
    write(io, *) ya - y(size(t), 1)
    close(io)

    deallocate(t)
    deallocate(y)

    call modified_euler(1, f, 0.0d0, [0.0d0], 0.001d0, 1551, t, y)
    
    open(newunit=io, file="data/arrays/yme.dat")
    do i = 1, size(t)
        write(io, *) t(i), y(i, 1)
    end do
    close(io)

    open(newunit=io, file="data/q2.dat")
    write(io, *) ya - y(size(t), 1)
    close(io)

    deallocate(t)
    deallocate(y)
    
    call improved_euler(1, f, 0.0d0, [0.0d0], 0.001d0, 1551, t, y)
    
    open(newunit=io, file="data/arrays/yie.dat")
    do i = 1, size(t)
        write(io, *) t(i), y(i, 1)
    end do
    close(io)

    open(newunit=io, file="data/q3.dat")
    write(io, *) ya - y(size(t), 1)
    close(io)

    deallocate(t)
    deallocate(y)
        
    call RK4(1, f, 0.0d0, [0.0d0], 0.01d0, 156, t, y)
   
    open(newunit=io, file="data/arrays/yrk.dat")
    do i = 1, size(t)
        write(io, *) t(i), y(i, 1)
    end do
    close(io)

    open(newunit=io, file="data/q4.dat")
    write(io, *) ya - y(size(t), 1)
    close(io)

    deallocate(t)
    deallocate(y)
        
end program scratch
