program scratch
    implicit none

    integer :: x(3), n(3)

    x = [1, 2, 1]
    n = [3, 3, 3]

    print *, count(mod(x, n)==0)

end program scratch