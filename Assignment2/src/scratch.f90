program scratch
    implicit none

    real*8 :: U(10000), R(10000), pi
    integer :: i

    pi = 2 * asin(1.0d0)

    call random_number(U)

    R = sqrt(-2 * log(U))

    open(1, file="data/scratch.dat")
    do i = 1, size(R)
        write(1, *) R(i)
    end do
    close(1)

end program scratch
