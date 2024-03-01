function f(d, t, y) result(dy_dt)
    integer, intent(in) :: d
    real(8), intent(in) :: t, y(d)
    real(8) :: dy_dt(d)

    dy_dt = y**2 + 1.0d0
end function

program scratch
    use ode
    implicit none

    procedure(integrable_function) f
    real(8), allocatable :: t(:), y(:, :)

    call euler(1, f, 0.0d0, [0.0d0], 0.001d0, 1551, t, y)

    deallocate(t)
    deallocate(y)

    call modified_euler(1, f, 0.0d0, [0.0d0], 0.001d0, 1551, t, y)
    
    deallocate(t)
    deallocate(y)
    
    call improved_euler(1, f, 0.0d0, [0.0d0], 0.001d0, 1551, t, y)
    
    deallocate(t)
    deallocate(y)
        
    call RK4(1, f, 0.0d0, [0.0d0], 0.01d0, 156, t, y)
   
    deallocate(t)
    deallocate(y)
    
























    
end program scratch
