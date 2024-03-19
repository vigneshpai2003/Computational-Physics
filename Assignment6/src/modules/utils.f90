module utils

contains
    subroutine write_array(file, arr)
        character(*), intent(in) :: file
        real*8, intent(in) :: arr(:)

        integer :: i, io

        open(newunit=io, file=file)
        do i = 1, size(arr, 1)
            write(io, *) arr(i)
        end do
        close(io)
    end subroutine

    subroutine write_matrix(file, mat)
        character(*), intent(in) :: file
        real*8, intent(in) :: mat(:, :)

        integer :: i, io

        open(newunit=io, file=file)
        do i = 1, size(mat, 1)
            write(io, *) mat(i, :)
        end do
        close(io)
    end subroutine

    function str(k) result(string)
        integer, intent(in) :: k
        character(20) :: string

        write(string, *) k

        string = adjustl(string)
    end function str

end module
    