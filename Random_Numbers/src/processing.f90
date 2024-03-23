program process
    use, intrinsic :: iso_fortran_env, only: real32, real64
    use hist, only: write_hist
    use utils, only: read_array
    implicit none

    real(real64), allocatable :: x(:)

    call read_array('sumofrandnum1.dat', x)
    call write_hist('1h_dx_0_5', x, minval(x), maxval(x) + 0.5d0, 0.5d0, .true.)
    call write_hist('1h_dx_1', x, minval(x), maxval(x) + 1.0d0, 1.0d0, .true.)
    call write_hist('1h_dx_2', x, minval(x), maxval(x) + 2.0d0, 2.0d0, .true.)
    deallocate(x)

    call read_array('sumofrandnum2.dat', x)
    call write_hist('1h_sample_a', x, minval(x), maxval(x) + 1.0d0, 1.0d0, .true.)
    deallocate(x)

    call read_array('sumofrandnum3.dat', x)
    call write_hist('1h_sample_b', x, minval(x), maxval(x) + 1.0d0, 1.0d0, .true.)
    deallocate(x)

    call read_array('randomwalk1.dat', x)
    call write_hist('1ij_dx_1', x, minval(x), maxval(x) + 1.0d0, 1.0d0, .true.)
    call write_hist('1ij_dx_2', x, minval(x), maxval(x) + 2.0d0, 2.0d0, .true.)
    call write_hist('1ij_dx_5', x, minval(x), maxval(x) + 5.0d0, 5.0d0, .true.)
    call write_hist('1ij_dx_10', x, minval(x), maxval(x) + 10.0d0, 10.0d0, .true.)

    call write_hist('1ij_shifted_a', x, 0.0d0, 101.0d0, 2.0d0, .true.)
    call write_hist('1ij_shifted_b', x, 1.0d0, 102.0d0, 2.0d0, .true.)
    deallocate(x)

    call read_array('randomwalk2.dat', x)
    call write_hist('1k', x, minval(x), maxval(x) + 2.0d0, 2.0d0, .true.)
    deallocate(x)

    call read_array('randomwalk3.dat', x)
    call write_hist('1l', x, minval(x), maxval(x) + 2.0d0, 2.0d0, .true.)
    deallocate(x)

end program process
