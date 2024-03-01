function f(d, t, y) result(dy_dt)
    integer, intent(in) :: d
    real(8), intent(in) :: t, y(d)
    real(8) :: dy_dt(d)

    dy_dt(1) = y(2)
    dy_dt(2) = - sin(y(1))
end function

program scratch
    use ode
    implicit none

    procedure(integrable_function) f
    real(8), allocatable :: t(:), y(:, :)

    call RK4(2, f, 0.0d0, [0.1d0, 1.9d0], 0.01d0, 5001, t, y)
    call RK4(2, f, 0.0d0, [0.1d0, 1.999d0], 0.01d0, 5001, t, y)
    call RK4(2, f, 0.0d0, [0.1d0, 2.1d0], 0.01d0, 5001, t, y)
    
    deallocate(t)
    deallocate(y)

end program scratch
