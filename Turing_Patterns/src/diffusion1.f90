program scratch
    use utils
    
    implicit none
    
    integer, parameter :: N = 60, niter = 100000, save_iter = 1000

    real(8) :: old_a(N, N), a(N, N), conv_a(niter)
    real(8) :: Da, dt
    integer :: i, x, y, xm, xp, ym, yp
    character(*), parameter :: dir = "data/d1"

    Da = 1.0d0
    dt = 0.001d0

    call execute_command_line("mkdir -p "//dir)

    ! initial state
    a = 0.0d0
    a(N / 2, N / 2) = 1.0d0

    call write_matrix(dir//"/0.dat", a)

    do i = 1, niter
        old_a = a

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
                
                a(x, y) = old_a(x, y) + dt * Da * (old_a(xp, y) + old_a(x, yp) + old_a(xm, y) + old_a(x, ym) - 4 * old_a(x, y))
            end do
        end do

        if (mod(i, save_iter) == 0) then
            call write_matrix(dir//"/"//trim(str(i))//".dat", a)
        end if

        conv_a(i) = norm2(abs(a - old_a))
    end do

    call write_array(dir//"/conv.dat", conv_a)

end program scratch
