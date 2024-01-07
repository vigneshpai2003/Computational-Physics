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
