module integrate  
    implicit none

    real(8), parameter :: pi = 2 * asin(1.0d0)

    abstract interface
        function integrable_function(x) result(func)
            real(8), intent(in) :: x(:)
            real(8) :: func
        end function
    end interface

contains

    ! trapezoidal rule (linear interpolation)
    ! error = O(1/prod(N)^2)
    function trapezoidal(d, f, a, b, dx, N) result(integral)
        integer, intent(in) :: d
        procedure(integrable_function) :: f
        real(8), intent(in) :: a(d), b(d)

        ! exactly one of dx or N is expected to be given
        real(8), optional :: dx(d)
        integer, optional :: N(d)

        real(8) :: integral, dx_(d)
        integer :: i, j, lattice(d), N_(d)

        if (present(dx)) then
            dx_ = dx
            N_ = nint((b - a) / dx_)
        else if (present(N)) then
            N_ = N
            dx_ = (b - a) / N_
        end if

        integral = 0

        lattice(:) = 0

        do i = 1, product(N_ + 1)
            ! go to next lattice point
            do j = 1, d
                lattice(j) = lattice(j) + 1
                if (lattice(j) > N_(j)) then
                    lattice(j) = mod(lattice(j), N_(j) + 1)
                else
                    exit
                end if
            end do

            integral = integral + f(a + lattice * dx_) / (2.0d0 ** count(mod(lattice, N_)==0))
        end do

        integral = integral * product(dx_)
    end function

    ! Simpson's 1/3 rule (quadratic interpolation)
    ! N must be multiple of 2
    ! error = O(1/prod(N)^4)
    function simpson(d, f, a, b, dx, N) result(integral)
        integer, intent(in) :: d
        procedure(integrable_function) :: f
        real(8), intent(in) :: a(d), b(d)

        ! exactly one of dx or N is expected to be given
        real(8), optional :: dx(d)
        integer, optional :: N(d)

        real(8) :: integral, dx_(d), weight
        integer :: i, j, lattice(d), N_(d)

        if (present(dx)) then
            dx_ = dx
            N_ = nint((b - a) / dx_)
        else if (present(N)) then
            N_ = N
            dx_ = (b - a) / N_
        end if

        integral = 0

        lattice(:) = 0

        do i = 1, product(N_ + 1)
            ! go to next lattice point
            do j = 1, d
                lattice(j) = lattice(j) + 1
                if (lattice(j) > N_(j)) then
                    lattice(j) = mod(lattice(j), N_(j) + 1)
                else
                    exit
                end if
            end do

            weight = 2.0d0 ** (count(mod(lattice, 2)==1) - count(mod(lattice, N_)==0))

            integral = integral + f(a + lattice * dx_) * weight
        end do

        integral = integral * product(dx_) * ((2.0d0 / 3.0d0) ** d)
    end function

    ! Simpson's 3/8 rule (cubic interpolation)
    ! N must be multiple of 3
    ! error = O(1/prod(N)^4)
    function simpson2(d, f, a, b, dx, N) result(integral)
        integer, intent(in) :: d
        procedure(integrable_function) :: f
        real(8), intent(in) :: a(d), b(d)

        ! exactly one of dx or N is expected to be given
        real(8), optional :: dx(d)
        integer, optional :: N(d)

        real(8) :: integral, dx_(d), weight
        integer :: i, j, lattice(d), N_(d)

        if (present(dx)) then
            dx_ = dx
            N_ = nint((b - a) / dx_)
        else if (present(N)) then
            N_ = N
            dx_ = (b - a) / N_
        end if

        integral = 0

        lattice(:) = 0

        do i = 1, product(N_ + 1)
            ! go to next lattice point
            do j = 1, d
                lattice(j) = lattice(j) + 1
                if (lattice(j) > N_(j)) then
                    lattice(j) = mod(lattice(j), N_(j) + 1)
                else
                    exit
                end if
            end do

            weight = 1.50d0 ** count(mod(lattice, 3)/=0) / 2.0d0 ** count(mod(lattice, N_)==0)

            integral = integral + f(a + lattice * dx_) * weight
        end do

        integral = integral * product(dx_) * ((3.0d0 / 4.0d0) ** d)
    end function

    ! Boole's rule (biquadratic interpolation)
    ! N must be multiple of 5
    ! error = O(1/prod(N)^7)
    function boole(d, f, a, b, dx, N) result(integral)
        integer, intent(in) :: d
        procedure(integrable_function) :: f
        real(8), intent(in) :: a(d), b(d)

        ! exactly one of dx or N is expected to be given
        real(8), optional :: dx(d)
        integer, optional :: N(d)

        real(8) :: integral, dx_(d), weight
        integer :: i, j, lattice(d), N_(d)

        if (present(dx)) then
            dx_ = dx
            N_ = nint((b - a) / dx_)
        else if (present(N)) then
            N_ = N
            dx_ = (b - a) / N_
        end if

        integral = 0

        lattice(:) = 0

        do i = 1, product(N_ + 1)
            ! go to next lattice point
            do j = 1, d
                lattice(j) = lattice(j) + 1
                if (lattice(j) > N_(j)) then
                    lattice(j) = mod(lattice(j), N_(j) + 1)
                else
                    exit
                end if
            end do

            weight = (6.0d0 / 7.0d0) ** (count(mod(lattice, 4)==2)) &
                * (16.0d0 / 7.0d0) ** (count(mod(lattice, 2)==1)) &
                / 2.0d0 ** (count(mod(lattice, N_)==0))

            integral = integral + f(a + lattice * dx_) * weight
        end do

        integral = integral * product(dx_) * ((28.0d0 / 45.0d0) ** d)
    end function

end module integrate
