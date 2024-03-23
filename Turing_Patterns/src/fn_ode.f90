function f1(d, t, y) result(dy_dt)
    integer, intent(in) :: d
    real(8), intent(in) :: t, y(d)
    real(8) :: dy_dt(d)
    real(8) :: alpha, beta

    alpha = 0.05d0
    beta = 10.0d0

    dy_dt(1) = y(1) - y(1) ** 3 - y(2) + alpha
    dy_dt(2) = beta * (y(1) - y(2))
end function

function f2(d, t, y) result(dy_dt)
    integer, intent(in) :: d
    real(8), intent(in) :: t, y(d)
    real(8) :: dy_dt(d)
    real(8) :: alpha, beta

    alpha = 0.05d0
    beta = 1.0d0

    dy_dt(1) = y(1) - y(1) ** 3 - y(2) + alpha
    dy_dt(2) = beta * (y(1) - y(2))
end function

function f3(d, t, y) result(dy_dt)
    integer, intent(in) :: d
    real(8), intent(in) :: t, y(d)
    real(8) :: dy_dt(d)
    real(8) :: alpha, beta

    alpha = 0.05d0
    beta = 0.1d0

    dy_dt(1) = y(1) - y(1) ** 3 - y(2) + alpha
    dy_dt(2) = beta * (y(1) - y(2))
end function

program scratch
    use utils
    use ode

    implicit none

    procedure(integrable_function) :: f1, f2, f3
    real(8) :: a_0, b_0
    real(8), allocatable :: t(:), y(:, :)

    a_0 = 0.35d0
    b_0 = 0.0d0

    call RK4(2, f1, 0.0d0, [a_0, b_0], 0.001d0, 100000, t, y)

    call execute_command_line("mkdir -p data/fn1")

    call write_array("data/fn1/t.dat", t)
    call write_array("data/fn1/a.dat", y(:, 1))
    call write_array("data/fn1/b.dat", y(:, 2))
    
    deallocate(t)
    deallocate(y)

    a_0 = 0.35d0
    b_0 = 0.0d0

    call RK4(2, f2, 0.0d0, [a_0, b_0], 0.001d0, 100000, t, y)

    call execute_command_line("mkdir -p data/fn2")

    call write_array("data/fn2/t.dat", t)
    call write_array("data/fn2/a.dat", y(:, 1))
    call write_array("data/fn2/b.dat", y(:, 2))
    
    deallocate(t)
    deallocate(y)

    a_0 = 0.35d0
    b_0 = 0.0d0

    call RK4(2, f3, 0.0d0, [a_0, b_0], 0.001d0, 100000, t, y)

    call execute_command_line("mkdir -p data/fn3")

    call write_array("data/fn3/t.dat", t)
    call write_array("data/fn3/a.dat", y(:, 1))
    call write_array("data/fn3/b.dat", y(:, 2))
    
    deallocate(t)
    deallocate(y)

end program scratch
