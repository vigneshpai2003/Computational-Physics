program scratch
    use utils
    
    implicit none
    
    integer, parameter :: N = 60, niter = 100000, save_iter = 1000

    real(8) :: old_a(N, N), old_b(N, N), a(N, N), b(N, N), conv_a(niter), conv_b(niter)
    real(8) :: alpha, beta, Da, Db, dt, s
    integer :: i, x, y, xm, xp, ym, yp
    character(*), parameter :: dir = "data/rd1"

    alpha = 0.05d0
    beta = 1.0d0
    Da = 1.0d0
    Db = 100.0d0
    dt = 0.001d0
    s = 0.1d0

    call execute_command_line("mkdir -p "//dir//"/a "//dir//"/b")

    ! initial state
    call random_number(a)
    call random_number(b)

    a = s * (a - 0.5d0) + sign(1.0d0, alpha) * abs(alpha)**(1.0d0/3)
    b = s * (b - 0.5d0) + sign(1.0d0, alpha) * abs(alpha)**(1.0d0/3)

    call write_matrix(dir//"/a/0.dat", a)
    call write_matrix(dir//"/b/0.dat", b)

    do i = 1, niter
        old_a = a
        old_b = b

        do x = 1, N
            do y = 1, N
                xm = x - 1
                xp = x + 1
                ym = y - 1
                yp = y + 1
                
                if (x == 1) xm = N
                if (x == N) xp = 1
                if (y == 1) ym = N
                if (y == N) yp = 1
                
                a(x, y) = old_a(x, y) + dt * (Da * (old_a(xp, y) + old_a(x, yp) + old_a(xm, y) + old_a(x, ym) - 4 * old_a(x, y)) &
                        + old_a(x, y) - old_a(x, y)**3 - old_b(x, y) + alpha)                
                b(x, y) = old_b(x, y) + dt * (Db * (old_b(xp, y) + old_b(x, yp) + old_b(xm, y) + old_b(x, ym) - 4 * old_b(x, y)) &
                        + beta * (old_a(x, y) - old_b(x, y)))
            end do
        end do

        if (mod(i, save_iter) == 0) then
            call write_matrix(dir//"/a/"//trim(str(i))//".dat", a)
            call write_matrix(dir//"/b/"//trim(str(i))//".dat", b)
        end if

        conv_a(i) = norm2(abs(a - old_a))
        conv_b(i) = norm2(abs(b - old_b))
    end do

    call write_array(dir//"/a/conv.dat", conv_a)
    call write_array(dir//"/b/conv.dat", conv_b)

end program scratch
