program assignment
    use, intrinsic :: iso_fortran_env, only: real32, real64
    use utils

    implicit none

    ! DECLARE VARIABLE
    real(real64) :: x(10), xe2(100), xe3(1000), xe4(10000), xe5(100000), xe6(1000000), A(10, 10)

    integer, allocatable :: seed(:)
    integer :: seed_size, io, i

    character(len=*), parameter :: myformat = "(F12.10)"

    call execute_command_line('mkdir -p data')

    ! GET SEED SIZE AND SET A SEED
    call random_seed(seed_size)
    allocate(seed(seed_size))
    seed(:) = 1
    call random_seed(put=seed)

    ! ==> a) print 10 random numbers
    call random_number(x)
    print *, x

    ! ==> b) save the numbers to a file
    open(newunit=io, file="data/test_ran.dat")
    call write_array(io, myformat, x)

    ! ==> c) writing a comment
    write(io, "(A)") "Changing seed and generating 10 new random numbers"

    ! ==> d) new random numbers
    seed(:) = 2
    call random_seed(put=seed)
    call random_number(x)

    call write_array(io, myformat, x)

    close(io)

    ! ==> d) test_ran_10_seeds.dat
    do i = 1, 10
        seed(:) = i
        call random_seed(put=seed)
        call random_number(A(:, i))
    end do

    open(newunit=io, file="data/test_ran_10_seeds.dat")
    do i = 1, 10
        write(io,'(10(F12.10, " "))') A(i, :)
    end do
    close(io)

    ! ==> e) calculating average
    open(newunit=io, file="data/test_ran.dat", position="append", status="old", action="write")

    ! ==> e), f)
    call random_seed() ! reset to a random seed

    call random_number(x)
    call random_number(xe2)
    call random_number(xe3)
    call random_number(xe4)
    call random_number(xe5)
    call random_number(xe6)

    write(io, "(A)") "NOW calculating average of 10 random numbers"
    write(io, myformat) avg(x)
    write(io, "(A)") "NOW calculating average of 100 random numbers"
    write(io, myformat) avg(xe2)
    write(io, "(A)") "NOW calculating average of 10000 random numbers"
    write(io, myformat) avg(xe4)
    write(io, "(A)") "NOW calculating average of 1000000 random numbers"
    write(io, myformat) avg(xe6)

    close(io)

    ! ==> g)
    print *, "Delta for 100 random numbers" , abs(0.50d0 - avg(xe2))
    print *, "Delta for 10000 random numbers" , abs(0.50d0 - avg(xe4))
    print *, "Delta for 1000000 random numbers" , abs(0.50d0 - avg(xe6))

    ! store these in a file for analysis
    open(newunit=io, file="data/averages.dat")
    write(io, *) abs(0.50d0 - avg(xe2))
    write(io, *) abs(0.50d0 - avg(xe3))
    write(io, *) abs(0.50d0 - avg(xe4))
    write(io, *) abs(0.50d0 - avg(xe5))
    write(io, *) abs(0.50d0 - avg(xe6))
    close(io)

    ! ==> h)
    ! sum of random numbers between 0 and 1
    open(newunit=io, file="data/sumofrandnum1.dat")
    do i = 1, 10000
        call random_number(xe4)
        write(io, *) sum(xe4)
    end do
    close(io)

    ! sum of random numbers between -1 and 1
    open(newunit=io, file="data/sumofrandnum2.dat")
    do i = 1, 10000
        call random_number(xe4)
        write(io, *) sum(xe4 * 2 - 1)
    end do
    close(io)

    open(newunit=io, file="data/sumofrandnum3.dat")
    do i = 1, 100000
        call random_number(xe4)
        write(io, *) sum(xe4 * 2 - 1)
    end do
    close(io)

    ! ==> i) random walks
    open(newunit=io, file="data/randomwalk1.dat")
    do i = 1, 10000
        call random_number(xe4)
        write(io, *) sum(sign(1.0d0, xe4 - 0.5))
    end do
    close(io)

    ! ==> j) more random walks
    open(newunit=io, file="data/randomwalk2.dat")
    do i = 1, 100000
        call random_number(xe4)
        write(io, *) sum(sign(1.0d0, xe4 - 0.5))
    end do
    close(io)

    ! ==> l) larger random walks
    open(newunit=io, file="data/randomwalk3.dat")
    do i = 1, 100000
        call random_number(xe5)
        write(io, *) sum(sign(1.0d0, xe5 - 0.5))
    end do
    close(io)

    deallocate(seed)
end program assignment
