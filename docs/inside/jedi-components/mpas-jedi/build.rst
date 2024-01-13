.. warning::
    This section is out of date!! A further review will be completed in the near future. Sorry for the inconvenience.

.. _top-mpas-jedi-build:

Building and Testing MPAS-JEDI
==============================

This section describes how to build MPAS-JEDI using CMake, then confirm that your build is working
properly with CTest.  Usage of CMake and CTest are described in the :doc:`JEDI CMake, CTest, and
ecbuild </inside/developer_tools/cmake>` documentation.

MPAS-BUNDLE
-----------

In order to build MPAS-JEDI and its dependencies, it is recommended to use MPAS-BUNDLE, available at
https://github.com/JCSDA/mpas-bundle.  Within MPAS-BUNDLE, the file named :code:`CMakeLists.txt`
controls the dependency chain of components that are either essential (e.g., OOPS, IODA, UFO, SABER,
and CRTM) or optional (e.g., RTTOV) to the procedure that eventually generates MPAS-JEDI
executables.  MPAS-BUNDLE is built using :code:`ecbuild`. Full details on how to build any JEDI
bundle are provided :doc:`elsewhere </using/building_and_running/building_jedi>`, and it is
recommended to familiarize yourself with those instructions before continuing here.

.. _build-test-mpas-derecho:

Building and testing MPAS-BUNDLE on Derecho
--------------------------------------------

Most development and testing of MPAS-JEDI has been performed on NCAR's Derecho HPC
system. Custom scripts for creating the required build environment on Derecho are provided
in MPAS-BUNDLE. After cloning MPAS-BUNDLE from Github, you can find these scripts in
:code:`mpas-bundle/env-setup`.  Before executing the :code:`ecbuild` command, :code:`source`
the script appropriate for your choice of compiler, MPI implementation, and shell (e.g.,
gnu-openmpi-derecho.sh). The commands in the environment script are consistent with the
instructions for Derecho under :ref:`top-modules`.

After building MPAS-BUNDLE, it is recommended to run the ctests. Passing this suite of tests
confirms that your build is working as expected.

Starting from a project directory such as :code:`$HOME/jedi`, the entire build and test workflow
on Derecho would look like:

.. code-block:: bash

    git clone https://github.com/JCSDA/mpas-bundle.git     # this creates the 'mpas-bundle' directory
    source mpas-bundle/env-setup/<desired environment script>
    mkdir ./<build-directory>
    cd ./<build-directory>
    ecbuild  ../mpas-bundle
    make update
    make -j4
    cd mpas-jedi
    ctest

Notes about building on Derecho:
  - The :code:`gnu-openmpi` environment has been more extensively tested than the :code:`intel-impi`
    environment on Derecho
  - The :code:`<build-directory>` cannot be the directory named :code:`mpas-bundle`, where the
    repository is cloned, because doing so will create conflict between the source code
    directory and the CMake-generated build sub-directories
  - Users can expect the above build and test procedure to take approximately 45 minutes. For some
    speedup, it is recommended to execute the :code:`make` step in a job script with :code:`-j16`
    instead of :code:`-j4`, which will use 16 processors instead of 4 in the parallel build. Much of
    the total time spent is during the :code:`ecbuild` step, which downloads the code for the first
    time.

Building MPAS-BUNDLE in Singularity
-----------------------------------

MPAS-BUNDLE can also be built and tested in the `JEDI development Singularity container
<https://jointcenterforsatellitedataassimilation-jedi-docs.readthedocs-hosted.com/en/1.3.0/using/jedi_environment/singularity.html>`_.  
Detailed instructions are provided at that link.  If you
do not plan to or are unable to install Singularity natively, you may be interested to learn
`how to launch a Singularity container in a Vagrant Virtual Machine
<https://jointcenterforsatellitedataassimilation-jedi-docs.readthedocs-hosted.com/en/1.3.0/using/jedi_environment/vagrant.html>`_.
When working in the Singularity container, the main difference
from the instructions provided above for Derecho is that the environment is already set up properly
within the container. Thus there is no need to :code:`source` an environment setup file.

.. _controltesting-mpas:


Built executables
-----------------

After completing the MPAS-BUNDLE build, users have access to many executables under
:code:`<build-directory>/bin`, many of which are generated when building the projects on which
MPAS-JEDI is dependent (OOPS, UFO, SABER).  The executables that are relevant to MPAS are as
follows, grouped separately for MPAS-A and MPAS-JEDI.

MPAS-A
""""""
 - :code:`mpas_atmosphere`: can be used interchangeably with the :code:`atmosphere_model` executable
   that would normally be built using the non-JEDI (standalone) MPAS-Model build mechanism for
   the :code:`atmosphere` core.  Its purpose is to integrate the model forward in time from an
   initial time to a final time with periodic IO of model fields of importance.
 - :code:`mpas_init_atmosphere`: can be used interchangeably with the :code:`init_atmosphere_model`    executable that would normally be built using the non-JEDI (standalone) MPAS-Model build
   mechanism for the :code:`init_atmosphere` core.  Its purpose is to generate cold-start initial
   condition and surface input files.

MPAS-JEDI
"""""""""
Each of these executables are model-specific implementations of generic applications that
are derived from the :code:`oops::Application` class, i.e.,
:code:`oops/src/oops/runs/Application.h`. Descriptions of the generic applications are located under
the :doc:`OOPS Applications </inside/jedi-components/oops/applications/index>` documentation. Here
we give short synopses of a few specific MPAS-JEDI implementations.

 - Applications with one initial state

   - :code:`mpasjedi_convertstate.x` (:code:`oops::ConvertState`)
   - :code:`mpasjedi_dirac.x` (:code:`oops::Dirac`)
   - :code:`mpasjedi_forecast.x` (:code:`oops::Forecast`): essentially does the same as the
     :code:`mpas_atmosphere` executable, but through the JEDI generic framework via the MPAS-JEDI
     interface.  There is more overhead than when running the non-JEDI exectuable, and this
     requires a YAML file in addition to the standard :code:`namelist.atmosphere` used to configure
     :code:`mpas_atmosphere`.
   - :code:`mpasjedi_gen_ens_pert_B.x` (:doc:`oops::GenEnsPertB <../oops/applications/genenspertb>`)
   - :code:`mpasjedi_hofx.x` (:code:`oops::HofX4D`)
   - :code:`mpasjedi_hofx3d.x` (:code:`oops::HofX3D`)
   - :code:`mpasjedi_parameters.x` (:code:`saber::EstimateParams`): used to estimate static
     background error covariance and localization matrices
   - :code:`mpasjedi_staticbinit.x` (:code:`oops::StaticBInit`)
   - :code:`mpasjedi_variational.x` (:code:`oops::Variational`): carries out many different
     flavors of variational data assimilation (3DVar, 3DEnVar, 3DFGAT, 4DEnVar) with a variety of
     incremental minimization algorithms

 - Applications with multiple initial states

   - :code:`mpasjedi_eda.x` (:code:`oops::EnsembleApplication<oops::Variational>`)
   - :code:`mpasjedi_enshofx.x` (:code:`oops::EnsembleApplication<oops::HofX4D>`)
   - :code:`mpasjedi_rtpp.x` (:code:`oops::RTPP`): standalone application that carries out
     Relaxation to Prior Perturbation, as introduced by Zhang et al. (2004).  The intended purpose
     is to inflate the analysis ensemble spread after running the EDA application.



Most of the MPAS-JEDI executables are exercised in ctests.  As users learn how to use MPAS-JEDI for
larger-scale applications, it is useful to consider the ctests as examples and templates. For more
information on the individual ctests, see :doc:`the documentation for their yaml configuration files
</inside/jedi-components/mpas-jedi/data>`.



Controlling the testing
-----------------------

In addition to the basic :code:`ctest` command shown in :ref:`build-test-mpas-derecho`, which runs
all of the available tests for MPAS-JEDI, :code:`ctest` has basic flags and arguments available for
selecting a subset of tests.  :code:`ctest` also automatically provides some logging functionality
that is useful for reviewing passing and failing test cases.  Both of those aspects of
:code:`ctest` are described in more detail within the :doc:`JEDI Developer Tools
</inside/developer_tools/cmake>` and :doc:`JEDI Testing </inside/testing/unit_testing>`
documentations.

References
----------
Zhang, F., C. Snyder, and J. Sun (2004): Impacts of initial estimate and observation availability on convective-scale data assimilation with an ensemble Kalman filter. Mon. Wea. Rev., 132, 1238–1253
