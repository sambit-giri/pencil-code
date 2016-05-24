! $Id$
!
!  This module writes information about the local state of the gas at
!  the positions of a selected number of particles.
!
!** AUTOMATIC CPARAM.INC GENERATION ****************************
!
! Declare (for generation of cparam.inc) the number of f array
! variables and auxiliary variables added by this module
!
! CPARAM logical, parameter :: lparticles_lyapunov=.false.
!
!
!***************************************************************
module Particles_lyapunov
!
  use Cdata
  use Messages
  use Particles_cdata
  use Particles_map
  use Particles_mpicomm
!
  implicit none
!
  include 'particles_lyapunov.h'
!
  logical :: lnoise2pvector=.false.
  real :: fake_eta=0.,bamp=0.
!
  namelist /particles_lyapunov_init_pars/ & 
    bamp
!
  namelist /particles_lyapunov_run_pars/ &
  lnoise2pvector,fake_eta
!
  contains
!***********************************************************************
    subroutine register_particles_lyapunov()
!
!  Set up indices for access to the fp and dfp arrays
!
!  May-16/dhruba: coded
!
      use FArrayManager, only: farray_register_auxiliary
!
      if (lroot) call svn_id( &
          "$Id$")
!
    endsubroutine register_particles_lyapunov
!***********************************************************************
    subroutine initialize_particles_lyapunov(f)
!
!  Perform any post-parameter-read initialization i.e. calculate derived
!  parameters.
!
!  May-16/dhruba+nishant+akshay: coded
!
      use General, only: keep_compiler_quiet
      use FArrayManager
!
      real, dimension (mx,my,mz,mfarray) :: f
!
      call keep_compiler_quiet(f)
!
    endsubroutine initialize_particles_lyapunov
!***********************************************************************
    subroutine init_particles_lyapunov(f,fp)
!
      use Sub, only: kronecker_delta
      use General, only: keep_compiler_quiet,random_number_wrapper
      use Mpicomm, only: mpiallreduce_sum
      real, dimension (mx,my,mz,mfarray), intent (in) :: f
      real, dimension (mpar_loc,mparray), intent (out) :: fp
      real, dimension(nx,3:3) :: uij 
!
      call keep_compiler_quiet(f)
      call keep_compiler_quiet(fp)
!
    endsubroutine init_particles_lyapunov
!***********************************************************************
    subroutine dlyapunov_dt_pencil(f,df,fp,dfp,p,ineargrid)
!
      use Sub, only: linarray2matrix,matrix2linarray
!
      real, dimension (mx,my,mz,mfarray),intent(in) :: f
      real, dimension (mx,my,mz,mvar) :: df
      type (pencil_case) :: p
      real, dimension (mpar_loc,mparray), intent(in) :: fp
      real, dimension (mpar_loc,mpvar) :: dfp
      integer, dimension (mpar_loc,3) :: ineargrid
      intent (inout) :: df, dfp,ineargrid
      real, dimension(9) :: Sijp
!
      call keep_compiler_quiet(f)
      call keep_compiler_quiet(df)
      call keep_compiler_quiet(fp)
      call keep_compiler_quiet(dfp)
      call keep_compiler_quiet(p)
      call keep_compiler_quiet(ineargrid)     
!
    endsubroutine dlyapunov_dt_pencil
!***********************************************************************
    subroutine read_plyapunov_init_pars(iostat)
!
      use File_io, only: parallel_unit
!
      integer, intent(out) :: iostat
!
      read(parallel_unit, NML=particles_lyapunov_init_pars, IOSTAT=iostat)
!
    endsubroutine read_plyapunov_init_pars
!***********************************************************************
    subroutine write_plyapunov_init_pars(unit)
!
      integer, intent(in) :: unit
!
      write(unit, NML=particles_lyapunov_init_pars)
!
    endsubroutine write_plyapunov_init_pars
!***********************************************************************
    subroutine read_plyapunov_run_pars(iostat)
!
      use File_io, only: parallel_unit
!
      integer, intent(out) :: iostat
!
      read(parallel_unit, NML=particles_lyapunov_run_pars, IOSTAT=iostat)
!
    endsubroutine read_plyapunov_run_pars
!***********************************************************************
    subroutine write_plyapunov_run_pars(unit)
!
      integer, intent(in) :: unit
!
      write(unit, NML=particles_lyapunov_run_pars)
!
    endsubroutine write_plyapunov_run_pars
!***********************************************************************
    subroutine particles_stochastic_lyapunov(fp)
      real, dimension (mpar_loc,mparray), intent (out) :: fp
!
      call keep_compiler_quiet(fp)
!    
    endsubroutine particles_stochastic_lyapunov
!***********************************************************************
endmodule Particles_lyapunov
