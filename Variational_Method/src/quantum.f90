module quantum
    implicit none

    ! Interface block for LAPACK subroutines
    interface
        subroutine dsyev(jobz, uplo, n, a, lda, w, work, lwork, info)
            character(1), intent(in) :: jobz, uplo
            integer, intent(in) :: n, lda, lwork
            real(8), intent(inout) :: a(lda,*), w(n), work(*)
            integer, intent(out) :: info
        end subroutine dsyev
    end interface

contains

    subroutine H_matrix(H, n, a, b, V)
        real(8), allocatable, intent(out) :: H(:, :)
        integer, intent(in) :: n
        real(8), intent(in) :: a, b, V

        integer :: i, j

        allocate(H(n, n))

        do i = 1, n
            do j = 1, n
                H(i, j) = 1
            end do
        end do
    end subroutine

end module quantum
