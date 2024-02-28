module ode
    implicit none
    
    abstract interface
        function integrable_function(d, t, y) result(f)
            integer, intent(in) :: d
            real(8), intent(in) :: t, y(d)
            real(8) :: f(d)
        end function
    end interface
contains

    subroutine euler(d, f, t_0, y_0, step, N, t, y)
        integer, intent(in) :: d, N
        procedure(integrable_function) :: f
        real(8), intent(in) :: t_0, y_0(d), step
        real(8), allocatable, intent(out) :: t(:), y(:, :)
        
        integer :: i

        allocate(t(N))
        allocate(y(N, d))

        t(1) = t_0
        y(1, :) = y_0

        do i = 2, N
            t(i) = t(i - 1) + step
            y(i, :) = y(i - 1, :) + step * f(d, t(i - 1), y(i - 1, :))
        end do
    end subroutine

    subroutine modified_euler(d, f, t_0, y_0, step, N, t, y)
        integer, intent(in) :: d, N
        procedure(integrable_function) :: f
        real(8), intent(in) :: t_0, y_0(d), step
        real(8), allocatable, intent(out) :: t(:), y(:, :)
        
        integer :: i

        allocate(t(N))
        allocate(y(N, d))

        t(1) = t_0
        y(1, :) = y_0

        do i = 2, N
            t(i) = t(i - 1) + step
            y(i, :) = y(i - 1, :) + step * f(d, t(i - 1) + step / 2, y(i - 1, :) + step / 2 * f(d, t(i - 1), y(i - 1, :)))
        end do
    end subroutine

    subroutine improved_euler(d, f, t_0, y_0, step, N, t, y)
        integer, intent(in) :: d, N
        procedure(integrable_function) :: f
        real(8), intent(in) :: t_0, y_0(d), step
        real(8), allocatable, intent(out) :: t(:), y(:, :)
        
        integer :: i

        allocate(t(N))
        allocate(y(N, d))

        t(1) = t_0
        y(1, :) = y_0

        do i = 2, N
            t(i) = t(i - 1) + step
            y(i, :) = y(i - 1, :) + 0.5 * step * ( &
                f(d, t(i - 1), y(i - 1, :)) + &
                f(d, t(i - 1) + step, y(i - 1, :) + step * f(d, t(i - 1), y(i - 1, :))))
        end do
    end subroutine

    subroutine RK4(d, f, t_0, y_0, step, N, t, y)
        integer, intent(in) :: d, N
        procedure(integrable_function) :: f
        real(8), intent(in) :: t_0, y_0(d), step
        real(8), allocatable, intent(out) :: t(:), y(:, :)
        
        integer :: i

        allocate(t(N))
        allocate(y(N, d))

        t(1) = t_0
        y(1, :) = y_0

        do i = 2, N
            t(i) = t(i - 1) + step
            y(i, :) = y(i - 1, :) + 0.5 * step * ( &
                f(d, t(i - 1), y(i - 1, :)) + &
                f(d, t(i - 1) + step, y(i - 1, :) + step * f(d, t(i - 1), y(i - 1, :))))
        end do
    end subroutine
end module ode