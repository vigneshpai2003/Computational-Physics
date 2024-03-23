program scratch
    use quantum
    implicit none

    integer :: n
    real(8) :: a, b, V
    real(8), allocatable :: H(:, :)

    n = 10
    a = 10.0d0
    b = 2.0d0
    V = 1.0d0

    call H_matrix(H, n, a, b, V)

    deallocate(H)

end program scratch
