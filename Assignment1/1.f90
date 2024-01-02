module utils
    implicit none

    private
    public avg, write_array
contains

    function avg(arr) result(average)
        real, intent(in) :: arr(:)
        real :: average

        average = sum(arr) / size(arr)
    end function avg

    subroutine write_array(target, format, arr)
        integer, intent(in) :: target
        character(*), intent(in) :: format
        real, intent(in) :: arr(:)

        integer :: i

        do i = 1, size(arr)
            if (format /= "") then
             write(target, format) arr(i)
            else
                write(target, *) arr(i)
            end if
        end do
    end subroutine

end module utils

program assignment
    use utils
    implicit none

    ! DECLARE VARIABLE
    real :: x(10), xe2(100), xe4(10000), xe6(1000000), A(10, 10)

    integer, allocatable :: seed(:)
    integer :: seed_size, io, i

    character(len=*), parameter :: myformat = "(F12.10)"

    ! GET SEED SIZE AND SET A SEED
    call random_seed(seed_size)
    allocate(seed(seed_size))
    seed(:) = 1
    call random_seed(put=seed)

    ! a) print 10 random numbers
    call random_number(x)
    print *, x

    ! b) save the numbers to a file
    open(newunit=io, file="test_ran.dat")
    call write_array(io, myformat, x)

    ! c) writing a comment
    write(io, "(A)") "Changing seed and generating 10 new random numbers"

    ! d) new random numbers
    seed(:) = 2
    call random_seed(put=seed)
    call random_number(x)

    call write_array(io, myformat, x)

    close(io)

    ! d) test_ran_10_seeds.dat
    do i = 1, 10
        seed(:) = i
        call random_seed(put=seed)
        call random_number(A(:, i))
    end do

    open(newunit=io, file="test_ran_10_seeds.dat")
    do i = 1, 10
        write(io,'(10(F12.10, " "))') A(i, :)
    end do
    close(io)

    ! e) calculating average
    open(newunit=io, file="test_ran.dat", position="append", status="old", action="write")

    ! e), f)
    call random_seed() ! reset to a random seed
    
    call random_number(x)
    call random_number(xe2)
    call random_number(xe4)
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

    ! g)
    print *, "Delta for 100 random numbers" , abs(0.50d0 - avg(xe2))
    print *, "Delta for 10000 random numbers" , abs(0.50d0 - avg(xe4))
    print *, "Delta for 1000000 random numbers" , abs(0.50d0 - avg(xe6))

    ! h)
    open(newunit=io, file="sumofrandnum.dat")
    do i = 1, 10000
        call random_number(xe4)
        write(io, "(F10.5)") sum(xe4)
    end do
    close(io)

    deallocate(seed)
end program assignment
