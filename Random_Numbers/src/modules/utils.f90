module utils
    use, intrinsic :: iso_fortran_env, only: real32, real64

    implicit none

    private
    public avg, write_array, read_array
contains

    function avg(arr) result(average)
        real(real64), intent(in) :: arr(:)
        real(real64) :: average

        average = sum(arr) / size(arr)
    end function avg

    subroutine write_array(target, format, arr)
        integer, intent(in) :: target
        character(*), intent(in) :: format
        real(real64), intent(in) :: arr(:)

        integer :: i

        do i = 1, size(arr)
            if (format /= "") then
                write(target, format) arr(i)
            else
                write(target, *) arr(i)
            end if
        end do
    end subroutine


    subroutine read_array(xfile, x)
        character(*), intent(in) :: xfile
        real(real64), allocatable, intent(out) :: x(:)

        integer :: io, nlines, iostat, i

        ! calculate number of lines in file
        nlines = 0
        open(newunit=io, file='data/'//xfile, status="old")
        do
            read(io, *, iostat=iostat)
            if (iostat/=0) exit
            nlines = nlines + 1
        end do
        close(io)

        allocate(x(nlines))

        ! read into x
        open(newunit=io, file="data/"//xfile, status="old")
        do i = 1, nlines
            read(io, *) x(i)
        end do
        close(io)
    end subroutine
end module utils
