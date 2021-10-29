.. _top-soca-build:

.. _Building SOCA in Singularity:

Building SOCA in Singularity
==============================

This section describes how to configure and compile SOCA inside of a Singularity container.
``ecbuild`` (a wrapper of ``cmake``) is used for the configuration of the build and ``ctest`` to
confirm that the compiled code is working properly. Usage of ``cmake`` and ``ctest`` are described
in the :doc:`JEDI CMake, CTest, and ecbuild </inside/developer_tools/cmake>` documentation.

While SOCA can be complied on various architectures (HPC, workstations, ...),
this section only describes how to compile SOCA inside of a Singularity container.
Instruction on how to install and run Singularity is provided in the :doc:`JEDI development Singularity container
</using/jedi_environment/singularity>`.

Download and run a shell inside of a Singularity container:

.. code-block:: bash

    singularity pull library://jcsda/public/jedi-gnu-openmpi-dev  # download the development container
    singularity shell -e jedi-gnu-openmpi-dev_latest.sif          # run a shell within a singularity container

Clone the `1.0.0` tag of the SOCA repository

.. code-block:: console

    git clone --branch 1.0.0 https://github.com/jcsda/soca.git

This will create a SOCA directory that contains the MOM6 interface to JEDI as well as the
necessary dependencies provided as an ``ecbuild`` bundle in ``soca/bundle/CMakeLists.txt``

Default configuration and build of SOCA
-----------------------------------------

.. code-block:: bash

    mkdir build
    cd build
    ecbuild ../soca/bundle  # configure the build
    make -j<nthreads>       # compile
    ctest                   # test all JEDI components including `soca`

Extra build configurations for SOCA
-------------------------------------

To enable the use of the `Community Radiative Transfer Model (CRTM) <https://github.com/jcsda/crtm>`_
set the build option ``BUILD_CRTM`` for the ``ecbuild`` step above:

.. code-block:: bash

     ecbuild -DBUILD_CRTM=ON ../soca/bundle

To enable the use of the biogeochemistry model
`BLING <https://www.gfdl.noaa.gov/simplified-ocean-biogeochemistry-bling/>`_ set the build
option ``ENABLE_OCEAN_BGC` for the ``ecbuild`` step above:

.. code-block:: bash

      ecbuild -DENABLE_OCEAN_BGC=ON ../soca/bundle

Built executables
-----------------

After completing the SOCA build, users have access to executables under
``build/bin``, many of which are generated when building the projects on which
SOCA is dependent (
:doc:`OOPS </inside/jedi-components/oops/index>`,
:doc:`UFO </inside/jedi-components/ufo/index>`,
:doc:`SABER </inside/jedi-components/saber/index>`).

Most of these executables are model-specific implementations of generic applications that
are derived from the :code:`oops::Application` class, i.e.,
:code:`oops/src/oops/runs/Application.h`. Descriptions of the generic applications are located under
the :doc:`OOPS Applications </inside/jedi-components/oops/applications/index>` documentation. Here
we give short synopses of a few specific SOCA implementations.

- Generic Applications

   - :code:`soca_convertstate.x` (:code:`oops::ConvertState`)
   - :code:`soca_dirac.x` (:code:`oops::Dirac`)
   - :code:`soca_forecast.x` (:code:`oops::Forecast`): similar to the
     :code:`mom6.x` executable, but through the JEDI generic framework via the SOCA interface.
   - :code:`soca_enspert.x` (:code:`oops::GenEnsPertB`)
   - :code:`soca_ensrecenter.x` (:code:`oops::EnsRecenter`)
   - :code:`soca_ensvariance` (:code:`oops::EnsVariance`)
   - :code:`soca_hofx.x` (:code:`oops::HofX4D`)
   - :code:`soca_hofx3d.x` (:code:`oops::HofX3D`)
   - :code:`soca_parameters.x` (:code:`saber::EstimateParams`): used to estimate static
     background error covariance and localization matrices
   - :code:`soca_staticbinit.x` (:code:`oops::StaticBInit`): used to initialize the covariance model
   - :code:`soca_var.x` (:code:`oops::Variational`): carries out many different
     flavors of variational data assimilation (3DVar, 3DEnVar, 3DFGAT, 4DEnVar) with a variety of
     incremental minimization algorithms
   - :code:`soca_letkf.x` (:code:`oops::LocalEnsembleDA`)
   - :code:`soca_hybridgain.x` (:code:`oops::HybridGain`)
   - :code:`soca_enshofx.x` (:code:`oops::EnsembleApplication<oops::HofX4D>`)

- SOCA specific Applications

   - :code:`soca_checkpoint_model.x` (:code:`soca::CheckpointModel`)
   - :code:`soca_gridgen.x` (:code:`soca::GridGen`)

Most of the SOCA executables are exercised in ctests.  As users learn how to use SOCA for
larger-scale applications, it is useful to consider the ctests as examples and templates.
