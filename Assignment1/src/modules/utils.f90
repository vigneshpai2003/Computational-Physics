module utils
    use, intrinsic :: iso_fortran_env, only: real32, real64

    implicit none

    private
    public avg, write_array, write_hist, read_array
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

    subroutine write_hist(name, x, a, b, step, density)
        character(*), intent(in) :: name
        real(real64), intent(in) :: x(:), a, b, step
        logical, intent(in) :: density
        
        integer :: io, nbins, i, bin

        real(real64), allocatable :: bin_mid(:), count(:)

        nbins = (b - a) / step

        allocate(bin_mid(nbins))
        allocate(count(nbins))

        bin_mid = (/(a + step * (i - 0.5), i = 1, nbins)/)

        count(:) = 0.0d0

        do i = 1, size(x)
            bin = (x(i) - a) / step + 1
            if ((1 <= bin) .and. (bin <= nbins)) then
                count(bin) = count(bin) + 1.0d0
            end if
        end do

        if (density) then
            count(:) = count(:) / (size(x) * step)
        end if

        call execute_command_line('mkdir -p data/'//name)

        open(newunit=io, file="data/"//name//"/x.dat")
        call write_array(io, "", bin_mid)
        close(io)

        open(newunit=io, file="data/"//name//"/y.dat")
        call write_array(io, "", count)
        close(io)

        deallocate(bin_mid)
        deallocate(count)
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
