module quantum
    implicit none
    
    real(8), parameter :: pi = 2 * asin(1.0d0)

contains

    subroutine H_matrix(H, a, b, V)
        real(8), intent(out) :: H(:, :)
        real(8), intent(in) :: a, b, V

        integer :: n, dim, i, j
        real(8), allocatable :: k(:)

        dim = size(H, 1)
        n = (dim - 1) / 2

        allocate(k(dim))

        do i = -n, n
            k(n + i + 1) = 2 * pi * i / a
        end do

        do i = 1, dim
            H(i, i) = k(i)**2/2 - V * b / a
            do j = i + 1, dim
                H(i, j) = - 2 * V / a * sin((k(j) - k(i)) * b / 2) / (k(j) - k(i))
            end do
        end do

        deallocate(k)
    end subroutine

    function find_lwork(jobz, uplo, n, a, lda, w) result(lwork)
        character(1), intent(in) :: jobz, uplo
        integer, intent(in) :: n, lda
        real(8), intent(inout) :: a(lda,*), w(n)

        integer :: lwork, info
        real(8) :: work(1)

        lwork = -1

        call dsyev(jobz, uplo, n, a, lda, w, work, lwork, info)

        lwork = nint(work(1))

    end function

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

end module quantum
