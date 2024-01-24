program scratch
    implicit none

    integer :: x(4), i

    x = [1, 3, 5, 6]

    do i=0, 8
        print *, x(i)
    end do

end program scratch
