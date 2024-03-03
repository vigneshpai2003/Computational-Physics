program scratch
    implicit none
    
    integer :: N, i, io
    logical :: break
    real(8) :: dx, a, b, ya, yb, y_old, limit
    real(8), allocatable :: y(:), x(:)

    N = 100
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

    break = .false.

    do while (.not. break)
        break = .true.
        do i = 2, N - 1
            y_old = y(i)
            y(i) = ((1 - 5 * dx / 2) * y(i + 1) &
                + (1 + 5 * dx / 2) * y(i - 1) &
                - 10 * dx**2 * x(i)) / (2 - 10 * dx**2)
            
            break = abs(y(i) - y_old) < limit
        end do

        print *, "h"
    end do

    open(newunit=io, file="data/9.dat")
    do i = 1, N
        write(io, *) x(i), y(i)
    end do
    close(io)

    deallocate(x)
    deallocate(y)

end program scratch