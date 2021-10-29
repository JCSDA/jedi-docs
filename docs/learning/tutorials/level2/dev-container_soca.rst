.. _top-tut-dev-container-soca:

Tutorial: Build and Test the MOM6 interface to JEDI (SOCA)
==========================================================

Learning Goals:
 - How to download and run/enter a JEDI development container
 - How to build the JEDI code from source
 - How to run the JEDI unit test suite

Prerequisites:
 - read the :doc:`tutorial overview <../index>`

Follow the instructions provided in :ref:`Building SOCA in Singularity` but
before proceeding, you may wish to take a few moments to :ref:`get to know the container <meet-the-container>`.

From the build directory, run the SOCA test suite

.. code-block:: console

   cd soca
   ctest

you should see an output similar to this one:

.. code-block:: console

  Test project /home/gvernier/sandboxes/SOCA-1.0.0/build.soca/soca
        Start  1: soca_coding_norms
   1/62 Test  #1: soca_coding_norms .......................   Passed    1.12 sec
        Start  2: test_soca_subsample_netcdf
   2/62 Test  #2: test_soca_subsample_netcdf ..............   Passed    4.45 sec
        Start  3: test_soca_gridgen_small
   3/62 Test  #3: test_soca_gridgen_small .................   Passed    0.44 sec
        Start  4: test_soca_gridgen
   4/62 Test  #4: test_soca_gridgen .......................   Passed    0.48 sec
        Start  5: test_soca_convertstate
   5/62 Test  #5: test_soca_convertstate ..................   Passed    0.37 sec
        Start  6: test_soca_convertstate_changevar
   6/62 Test  #6: test_soca_convertstate_changevar ........   Passed    0.34 sec
        Start  7: test_soca_forecast_identity
   7/62 Test  #7: test_soca_forecast_identity .............   Passed    0.56 sec
        Start  8: test_soca_forecast_mom6
   8/62 Test  #8: test_soca_forecast_mom6 .................   Passed    1.45 sec
        Start  9: test_soca_forecast_mom6_bgc
   9/62 Test  #9: test_soca_forecast_mom6_bgc .............   Passed    1.83 sec
        Start 10: test_soca_forecast_pseudo
  10/62 Test #10: test_soca_forecast_pseudo ...............   Passed    0.30 sec
        Start 11: test_soca_static_socaerror_init
  11/62 Test #11: test_soca_static_socaerror_init .........   Passed    2.47 sec
        Start 12: test_soca_static_socaerrorlowres_init
  12/62 Test #12: test_soca_static_socaerrorlowres_init ...   Passed    0.60 sec
        Start 13: test_soca_balance_mask
  13/62 Test #13: test_soca_balance_mask ..................   Passed    0.30 sec
        Start 14: test_soca_create_kmask
  14/62 Test #14: test_soca_create_kmask ..................   Passed    0.17 sec
        Start 15: test_soca_enspert
  15/62 Test #15: test_soca_enspert .......................   Passed    4.64 sec
        Start 16: test_soca_makeobs
  16/62 Test #16: test_soca_makeobs .......................   Passed    1.22 sec
        Start 17: test_soca_geometry
  17/62 Test #17: test_soca_geometry ......................   Passed    0.19 sec
        Start 18: test_soca_geometry_iterator
  18/62 Test #18: test_soca_geometry_iterator .............   Passed    0.19 sec
        Start 19: test_soca_geometryatm
  19/62 Test #19: test_soca_geometryatm ...................   Passed    0.17 sec
        Start 20: test_soca_state
  20/62 Test #20: test_soca_state .........................   Passed    1.04 sec
        Start 21: test_soca_getvalues
  21/62 Test #21: test_soca_getvalues .....................   Passed    0.35 sec
        Start 22: test_soca_model
  22/62 Test #22: test_soca_model .........................   Passed    1.86 sec
        Start 23: test_soca_modelaux
  23/62 Test #23: test_soca_modelaux ......................   Passed    0.17 sec
        Start 24: test_soca_increment
  24/62 Test #24: test_soca_increment .....................   Passed    0.28 sec
        Start 25: test_soca_lineargetvalues
  25/62 Test #25: test_soca_lineargetvalues ...............   Passed    0.29 sec
        Start 26: test_soca_errorcovariance
  26/62 Test #26: test_soca_errorcovariance ...............   Passed    0.30 sec
        Start 27: test_soca_linearmodel
  27/62 Test #27: test_soca_linearmodel ...................   Passed    1.18 sec
        Start 28: test_soca_varchange_ana2model
  28/62 Test #28: test_soca_varchange_ana2model ...........   Passed    0.25 sec
        Start 29: test_soca_varchange_balance
  29/62 Test #29: test_soca_varchange_balance .............   Passed    0.34 sec
        Start 30: test_soca_varchange_balance_TSSSH
  30/62 Test #30: test_soca_varchange_balance_TSSSH .......   Passed    0.33 sec
        Start 31: test_soca_varchange_bkgerrfilt
  31/62 Test #31: test_soca_varchange_bkgerrfilt ..........   Passed    0.23 sec
        Start 32: test_soca_varchange_horizfilt
  32/62 Test #32: test_soca_varchange_horizfilt ...........   Passed    0.27 sec
        Start 33: test_soca_varchange_bkgerrsoca
  33/62 Test #33: test_soca_varchange_bkgerrsoca ..........   Passed    0.39 sec
        Start 34: test_soca_varchange_bkgerrgodas
  34/62 Test #34: test_soca_varchange_bkgerrgodas .........   Passed    2.71 sec
        Start 35: test_soca_varchange_vertconv
  35/62 Test #35: test_soca_varchange_vertconv ............   Passed    0.32 sec
        Start 36: test_soca_obslocalization
  36/62 Test #36: test_soca_obslocalization ...............   Passed    0.23 sec
        Start 37: test_soca_ensvariance
  37/62 Test #37: test_soca_ensvariance ...................   Passed    0.60 sec
        Start 38: test_soca_parameters_bump_loc
  38/62 Test #38: test_soca_parameters_bump_loc ...........   Passed    0.69 sec
        Start 39: test_soca_ensrecenter
  39/62 Test #39: test_soca_ensrecenter ...................   Passed    0.66 sec
        Start 40: test_soca_hybridgain
  40/62 Test #40: test_soca_hybridgain ....................   Passed    0.53 sec
        Start 41: test_soca_parameters_bump_cor_nicas
  41/62 Test #41: test_soca_parameters_bump_cor_nicas .....   Passed    1.46 sec
        Start 42: test_soca_dirac_soca_cov
  42/62 Test #42: test_soca_dirac_soca_cov ................   Passed    1.26 sec
        Start 43: test_soca_dirac_socahyb_cov
  43/62 Test #43: test_soca_dirac_socahyb_cov .............   Passed    1.54 sec
        Start 44: test_soca_dirac_horizfilt
  44/62 Test #44: test_soca_dirac_horizfilt ...............   Passed    0.35 sec
        Start 45: test_soca_hofx_3d
  45/62 Test #45: test_soca_hofx_3d .......................   Passed    0.78 sec
        Start 46: test_soca_hofx_4d
  46/62 Test #46: test_soca_hofx_4d .......................   Passed    1.31 sec
        Start 47: test_soca_hofx_4d_pseudo
  47/62 Test #47: test_soca_hofx_4d_pseudo ................   Passed    0.54 sec
        Start 48: test_soca_enshofx
  48/62 Test #48: test_soca_enshofx .......................   Passed    1.28 sec
        Start 49: test_soca_3dvar_soca
  49/62 Test #49: test_soca_3dvar_soca ....................   Passed    6.44 sec
        Start 50: test_soca_3dvarbump
  50/62 Test #50: test_soca_3dvarbump .....................   Passed    4.04 sec
        Start 51: test_soca_3dvar_godas
  51/62 Test #51: test_soca_3dvar_godas ...................   Passed    5.18 sec
        Start 52: test_soca_addincrement
  52/62 Test #52: test_soca_addincrement ..................   Passed    0.28 sec
        Start 53: test_soca_3dvarlowres_soca
  53/62 Test #53: test_soca_3dvarlowres_soca ..............   Passed    4.69 sec
        Start 54: test_soca_diffstates
  54/62 Test #54: test_soca_diffstates ....................   Passed    0.34 sec
        Start 55: test_soca_3dvarfgat
  55/62 Test #55: test_soca_3dvarfgat .....................   Passed    5.97 sec
        Start 56: test_soca_3dvarfgat_pseudo
  56/62 Test #56: test_soca_3dvarfgat_pseudo ..............   Passed    3.34 sec
        Start 57: test_soca_3dhyb
  57/62 Test #57: test_soca_3dhyb .........................   Passed    2.80 sec
        Start 58: test_soca_3dhybfgat
  58/62 Test #58: test_soca_3dhybfgat .....................   Passed    4.81 sec
        Start 59: test_soca_letkf_observer
  59/62 Test #59: test_soca_letkf_observer ................   Passed    1.84 sec
        Start 60: letkf_observer_post
  60/62 Test #60: letkf_observer_post .....................   Passed    0.47 sec
        Start 61: test_soca_letkf_solver
  61/62 Test #61: test_soca_letkf_solver ..................   Passed    0.58 sec
        Start 62: test_soca_checkpointmodel
  62/62 Test #62: test_soca_checkpointmodel ...............   Passed    0.52 sec

  100% tests passed, 0 tests failed out of 62

  Label Time Summary:
  executable    =  11.10 sec*proc (20 tests)
  mpi           =  11.10 sec*proc (20 tests)
  script        =  68.43 sec*proc (40 tests)
  soca          =  79.53 sec*proc (60 tests)

  Total Test time (real) =  84.20 sec

Each of the ctest run multiple unit tests covering more than 90% of the SOCA code.
If you get test failures you may wish to consult the :doc:`FAQ <../../../FAQ/FAQ>`.
