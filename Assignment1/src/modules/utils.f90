module utils
    use, intrinsic :: iso_fortran_env, only: real32, real64

    implicit none

    private
    public avg, write_array
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
end module utils
