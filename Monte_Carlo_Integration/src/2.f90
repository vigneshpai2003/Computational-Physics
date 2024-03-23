program assignment
    use random

    implicit none

    real(8) :: random_array(1000000)
    integer :: io, i

    call random_number(random_array)

    call execute_command_line('mkdir -p data')


    open(newunit=io, file='data/2_array.dat')
    do i = 1, size(random_array)
        write(io, *) random_array(i)
    end do
    close(io)

    open(newunit=io, file='data/2_correlation.dat')
    do i = 0, 1000
        write(io, *) autocorrelation(random_array, i)
    end do
    close(io)

    open(newunit=io, file='data/2_moments.dat')
    do i = 0, 100
        write(io, *) moment(random_array, i)
    end do
    close(io)

end program assignment
