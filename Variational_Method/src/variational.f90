program scratch
    use quantum
    implicit none

    integer :: n, dim, info, lwork, i
    real(8) :: a, b, V
    real(8), allocatable :: H(:, :), eigenvalues(:), work(:)

    call execute_command_line("mkdir -p data/n/e data/n/v data/a/e data/a/v")

    ! potential parameters
    b = 2.0d0
    V = 1.0d0

    ! vary n
    a = 25.0d0
    do n = 10, 100, 5

        dim = 2 * n + 1

        allocate(H(dim, dim), eigenvalues(dim))

        call H_matrix(H, a, b, V)

        lwork = find_lwork('V', 'U', dim, H, dim, eigenvalues)
        allocate(work(lwork))

        call dsyev('V', 'U', dim, H, dim, eigenvalues, work, lwork, info)

        if (info /= 0) then
            print *, "Error Code: ", info
            stop
        end if

        call write_array("data/n/e/"//trim(str(n))//".dat", eigenvalues)
        call write_matrix("data/n/v/"//trim(str(n))//".dat", H)

        deallocate(work, eigenvalues, H)
    end do

    ! vary a
    n = 100
    dim = 2 * n + 1
    allocate(H(dim, dim), eigenvalues(dim))

    do i = 5, 50, 5
        a = i

        call H_matrix(H, a, b, V)

        lwork = find_lwork('V', 'U', dim, H, dim, eigenvalues)
        allocate(work(lwork))
    
        call dsyev('V', 'U', dim, H, dim, eigenvalues, work, lwork, info)
    
        if (info /= 0) then
            print *, "Error Code: ", info
            stop
        end if
   
        call write_array("data/a/e/"//trim(str(nint(a)))//".dat", eigenvalues)
        call write_matrix("data/a/v/"//trim(str(nint(a)))//".dat", H)

        deallocate(work)
    end do

    deallocate(eigenvalues, H)

end program scratch
