program scratch
    implicit none
    
    integer :: N, i, io, iter
    logical :: break
    real(8) :: dx, a, b, ya, yb, y_old, limit
    real(8) :: d0, d1, d2, d3
    real(8), allocatable :: y(:), x(:)

    call execute_command_line("mkdir -p data/arrays")

    N = 101
    a = 0.0d0
    b = 1.0d0
    ya = 0.0d0
    yb = 2.0d0
    limit = 0.0001d0
    dx = (b - a) / (N - 1)

    allocate(x(N))
    allocate(y(N))

    ! initial state
    do i = 1, N
        x(i) = a + dx * (i - 1)
        y(i) = ya + (yb - ya) * (i - 1) / (N - 1)
    end do
    y(1) = ya
    y(N) = yb

    open(newunit=io, file="data/arrays/9i.dat")
    do i = 1, N
        write(io, *) x(i), y(i)
    end do
    close(io)

    break = .false.

    iter = 0

    d0 = 2.0d0 - 10.0d0 * dx**2
    d1 = 1.0d0 - 2.50d0 * dx
    d2 = 1.0d0 + 2.50d0 * dx
    d3 = -10.0d0 * dx**2

    do while (.not. break)
        break = .true.
        do i = 2, N - 1
            y_old = y(i)
            
            y(i) = (d1 * y(i + 1) + d2 * y(i - 1) + d3 * x(i)) / d0
            
            break = break .and. (abs(y(i) - y_old) < limit)
        end do
        iter = iter + 1
    end do

    print *, "Completed in ", iter, " iterations."

    open(newunit=io, file="data/arrays/9f.dat")
    do i = 1, N
        write(io, *) x(i), y(i)
    end do
    close(io)

    open(newunit=io, file="data/q9.dat")
    write(io, *) y(81)
    close(io)

    deallocate(x)
    deallocate(y)

end program scratch