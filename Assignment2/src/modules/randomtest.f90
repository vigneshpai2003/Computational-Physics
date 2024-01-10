module randomtest
    implicit none

contains

    function moment(array, k, a, b) result(m)
        real(8), intent(in) :: array(:)
        integer, intent(in) :: k
        real(8), optional, value :: a, b

        real(8) :: m

        if (.not. present(a)) then
            a = 0.0d0
        else if (.not. present(b)) then
            b = 1.0d0
        end if

        m = sum(array ** k) / size(array)
    end function

    function autocorrelation(array, k) result(c)
        real(8), intent(in) :: array(:)
        integer, intent(in) :: k

        real(8) :: c, cik, ci, ci2
        integer :: N

        N = size(array)

        cik = sum(array(1 : N - k) * array(1 + k : N)) / (N - k)
        ci = sum(array) / N
        ci2 = sum(array ** 2) / N

        c = (cik - ci**2) / (ci2 - ci**2)
    end function

end module randomtest
