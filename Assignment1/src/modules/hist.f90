module hist
    use, intrinsic :: iso_fortran_env, only: real32, real64
    use utils, only: write_array
    implicit none

    private
    public write_hist, read_array
contains

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

        call execute_command_line('mkdir -p data/figure_data/'//name)

        open(newunit=io, file="data/figure_data/"//name//"/x.dat")
        call write_array(io, "", bin_mid)
        close(io)

        open(newunit=io, file="data/figure_data/"//name//"/y.dat")
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

end module hist
