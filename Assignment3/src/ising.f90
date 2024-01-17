module ising
    implicit none

contains

    subroutine randomize_spins(lattice)
        real(8), intent(out) :: lattice(:, :, :)
        call random_number(lattice)
        lattice = sign(1.0d0, lattice - 0.5d0)    
    end subroutine

    function energy(lattice, L) result(E)
        real(8), intent(in) :: lattice(:, :, :)
        integer, intent(in) :: L
        real(8) :: E

        real(8) :: s
        integer :: i, j, k

        E = 0.0d0

        do i=1, L
            do j=1, L
                do k=1, L
                    s = 0.0d0
                    
                    if (i == L) then
                        s = s + lattice(1, j, k)
                    else
                        s = s + lattice(i + 1, j, k)
                    end if

                    if (j == L) then
                        s = s + lattice(i, 1, k)
                    else
                        s = s + lattice(i, j + 1, k)
                    end if
                    
                    if (k == L) then
                        s = s + lattice(i, j, 1)
                    else
                        s = s + lattice(i, j, k + 1)
                    end if

                    E = E - lattice(i, j, k) * s
                end do
            end do
        end do
    end function

    subroutine metropolis(lattice, L, kbT)
        real(8), intent(inout) :: lattice(:, :, :)
        integer, intent(in) :: L
        real(8), intent(in) :: kbT

        integer :: i, j, k
        real(8) :: s, r, E

        call random_site(L, i, j, k)
        
        s = 0.0d0

        if (i == 1) then
            s = s + lattice(L, j, k)
        else
            s = s + lattice(i - 1, j, k)
        end if
        
        if (i == L) then
            s = s + lattice(1, j, k)
        else
            s = s + lattice(i + 1, j, k)
        end if

        if (j == 1) then
            s = s + lattice(i, L, k)
        else
            s = s + lattice(i, j - 1, k)
        end if
        
        if (j == L) then
            s = s + lattice(i, 1, k)
        else
            s = s + lattice(i, j + 1, k)
        end if

        if (k == 1) then
            s = s + lattice(i, j, L)
        else
            s = s + lattice(i, j, k - 1)
        end if
        
        if (k == L) then
            s = s + lattice(i, j, 1)
        else
            s = s + lattice(i, j, k + 1)
        end if

        E = - s * lattice(i, j, k)

        if (E > 0.0d0) then
            lattice(i, j, k) = - lattice(i, j, k)
        else
            call random_number(r)
            if (r < exp(-E/kbT)) then
                lattice(i, j, k) = - lattice(i, j, k)
            end if
        end if
    end subroutine

    subroutine random_site(L, i, j, k)
        integer, intent(in) :: L
        integer, intent(out) :: i, j, k
        real(8) :: r

        call random_number(r)
        i = int(1 + L * r)
        
        call random_number(r)
        j = int(1 + L * r)
        
        call random_number(r)
        k = int(1 + L * r)
    end subroutine

end module ising