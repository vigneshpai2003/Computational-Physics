program assignment
    use random

    implicit none
    
    real(8) :: random_array(1000000), lambda
    integer :: io, i

    call execute_command_line('mkdir -p data')

    ! 4a
    call random_number(random_array)
    lambda = 2.0d0
    random_array = - log(lambda * (1.0d0 - random_array)) / lambda

    open(newunit=io, file='data/4a.dat')
    do i = 1, size(random_array)
        write(io, *) random_array(i)
    end do
    close(io)

    !4b
    call box_muller(random_array, 2.0d0)
    open(newunit=io, file='data/4b.dat')
    do i = 1, size(random_array)
        write(io, *) random_array(i)
    end do
    close(io)

end program assignment
