.. _top-tut-envar-mpas:

Tutorial: Running the JEDI-MPAS Variational Application
====================================================================

Learning Goals:
 - Perform EnVar data assimilation with the JEDI-MPAS Variational application from a JEDI-MPAS build

Prerequisites:
 - :doc:`Build and test JEDI-MPAS <dev-container_mpas_jedi>`

Notes:
 - There are many common preparations in configuring the JEDI-MPAS application between
   :doc:`Tutorial: Simulating Observations with a JEDI-MPAS Application <hofx-mpas>` and this tutorial.

Overview
--------

In this tutorial we will be running an EnVar application with the global MPAS model
using a low-resolution (480 km) quasi-uniform mesh.
We will run the 3DEnVar data assimilation with :doc:`MPAS-JEDI <../../../inside/jedi-components/mpas-jedi/index>`
and check the results, following steps 1-3 below.
Though not necessary for a basic introduction to JEDI-MPAS, some users may wish to try step 4, which describes how to run 4DEnVar with multiple time slots, and
step 5, which describes how to generate the file specifying the covariance localization used in EnVar.

Step 1: Setup
-------------

Let's define the following directories. We will link or copy the necessary files from the ``CODE``
and ``BUILD`` directories to the ``RUN`` directory to configure the EnVar application.

.. code-block:: bash

    export CODE=$HOME/jedi/mpas-bundle
    export BUILD=$HOME/jedi/mpas-build

If you are using a Vagrant container, it is convenient to work in a directory that is accesible from outside the container, e.g.,

.. code-block:: bash

    export RUN=$HOME/vagrant_data/tutorials/envar-mpas

Otherwise, you might elect to simply use

.. code-block:: bash

    export RUN=$HOME/tutorials/envar-mpas

Let's create ``RUN`` directory and collect the necessary files.

.. code-block:: bash

    mkdir -p $RUN
    cd $RUN

    # Data directory will contain the input data.
    mkdir Data
    cd Data

    # Link the observation files and CRTM coefficient files.
    ln -sf $BUILD/mpas-jedi/test/Data/ufo ./
    ln -sf $BUILD/mpas-jedi/test/Data/UFOCoeff ./

    # Link the background state and ensemble files.
    mkdir -p 480km
    cd 480km
    ln -sf $BUILD/mpas-jedi/test/Data/480km/bg ./
    cd .. # return to Data directory

    # Copy the pre-generated localization file.
    mkdir -p bump
    cd bump
    cp $BUILD/mpas-jedi/test/Data/bump/mpas_parametersbump_loc_nicas* ./
    cd .. # return to Data directory

    # Link the configuration files for MPAS Model.
    cp $CODE/mpas-jedi/test/testinput/namelists/480km/streams.atmosphere ./480km/
    cp $CODE/mpas-jedi/test/testinput/namelists/480km/namelist.atmosphere_2018041500 ./480km/
    cd .. # return to RUN directory
    cp $CODE/mpas-jedi/test/testinput/namelists/stream_list.atmosphere.output ./
    cp $CODE/mpas-jedi/test/testinput/namelists/stream_list.atmosphere.diagnostics ./
    cp $CODE/mpas-jedi/test/testinput/namelists/stream_list.atmosphere.surface ./

As we follow the EnVar example from ctest, we also follow its directory structure. For a user's own experiments,
that structure can be simplified as desired.

.. code-block:: bash

    # Link the geovars.yaml file, which is used to template the fields for UFO GeoVaLs.
    cp $CODE/mpas-jedi/test/testinput/namelists/geovars.yaml ./

    # Link the 3denvar_bumploc_bumpinterp.yaml file.
    cp $CODE/mpas-jedi/test/testinput/3denvar_bumploc_bumpinterp.yaml ./

In ``3denvar_bumploc_bumpinterp.yaml``, the directories to write out the observation feedback files and
analysis file are specified with ``obsdataout`` and ``output`` keys. Let's create that directory to avoid a fatal error.

.. code-block:: bash

    # while in RUN directory
    mkdir -p Data/os
    mkdir -p Data/states

We're starting from the yaml file for the ``3denvar`` ctest, which includes a comparison of log messages to a reference output.  To omit those comparisons,  let's comment out all of the lines in the ``test`` section at the top of
``3denvar_bumploc_bumpinterp.yaml`` by adding a # at the beginning of each line as follows:

.. code-block:: bash

    #test:
    #  float relative tolerance: 0.00000001
    #  integer tolerance: 0
    #  reference filename: testoutput/3denvar_bumploc_bumpinterp.ref
    #  log output filename: testoutput/3denvar_bumploc_bumpinterp.run
    #  test output filename: testoutput/3denvar_bumploc_bumpinterp.run.ref

We'll also need various static files related to MPAS-Model.

.. code-block:: bash

    # while in RUN directory, link the static lookup tables of MPAS-Model
    export StaticDir=$BUILD/_deps/mpas_data-src/atmosphere/physics_wrf/files
    ln -sf $StaticDir/CAM_ABS_DATA.DBL ./
    ln -sf $StaticDir/CAM_AEROPT_DATA.DBL ./
    ln -sf $StaticDir/GENPARM.TBL ./
    ln -sf $StaticDir/LANDUSE.TBL ./
    ln -sf $StaticDir/OZONE_DAT.TBL ./
    ln -sf $StaticDir/OZONE_LAT.TBL ./
    ln -sf $StaticDir/OZONE_PLEV.TBL ./
    ln -sf $StaticDir/RRTMG_LW_DATA ./
    ln -sf $StaticDir/RRTMG_LW_DATA.DBL ./
    ln -sf $StaticDir/RRTMG_SW_DATA ./
    ln -sf $StaticDir/RRTMG_SW_DATA.DBL ./
    ln -sf $StaticDir/SOILPARM.TBL ./
    ln -sf $StaticDir/VEGPARM.TBL ./

Let's link the executable from the build directory.

.. code-block:: bash

    # while in RUN directory, link the executable
    ln -sf $BUILD/bin/mpasjedi_variational.x ./

Finally we set some environment variables to ensure the application will run successfully.

.. code-block:: bash

    # final environment variable setting
    ulimit -s unlimited
    export GFORTRAN_CONVERT_UNIT='big_endian:101-200'

Step 2: Run the 3DEnVar application
-----------------------------------

Now we are ready to run the ``mpasjedi_variational.x`` executable. Issue the ``mpiexec`` command as follows

.. code-block:: bash

    # while in RUN directory
    mpiexec -n 1 mpasjedi_variational.x 3denvar_bumploc_bumpinterp.yaml

    # Or
    mpiexec -n 1 mpasjedi_variational.x 3denvar_bumploc_bumpinterp.yaml run.log

    # Or
    mpiexec -n 1 mpasjedi_variational.x 3denvar_bumploc_bumpinterp.yaml >& run.log

Step 3: View the analysis increment fields
------------------------------------------

We will plot the horizontal distribution of analysis increment fields using the mpas-jedi diagnostic package.

Let's create the graphics working directory, then link the script that we will be using.

.. code-block:: bash

    # while in RUN directory
    mkdir -p graphics
    ln -sf $CODE/mpas-jedi/graphics/plot_inc.py ./graphics

Although ``plot_inc.py`` is written in a generic way, it still assumes a specific directory structure. For this, let's link
the background file and the analysis file into ``RUN`` directory.

.. code-block:: bash

    # while in RUN directory
    ln -sf Data/480km/bg/restart.2018-04-15_00.00.00.nc ./
    ln -sf Data/states/mpas.3denvar_bump.2018-04-15_00.00.00.nc ./

Now execute the script with python.

.. code-block:: bash

    # while in RUN directory
    cd graphics
    python plot_inc.py 2018041500 3denvar_bump uReconstructZonal 1 False

This will generate plots of the background forecast (with suffix ``MPASBAK``), the analysis (with suffix ``MPASANA``),
and the analysis increment (with suffix ``MPASAMB``) for the variable ``uReconstructZonal``, which is the zonal component of
horizontal velocity at the center of MPAS mesh cells. Please see the :ref:`analysis-inc-diag-mpas` section of the mpas-jedi :doc:`Diagnostics <../../../inside/jedi-components/mpas-jedi/diagnostics>` documentation for further information on the ``plot_inc.py`` script.

If you are using a Vagrant container, then you can view the files on your local system under the ``vagrant_data`` directory.  Or, you can view the files from within the container using the linux ``feh`` program, provided your ``DISPLAY`` environment variable is set up correctly (see comments in Step 4 of the :doc:`Run JEDI-FV3 in a Container<../level1/run-jedi>` tutorial).

Users may want to try plotting other variables, such as ``uReconstructMeridional``, ``theta``, ``qv``, or ``surface_pressure``.


Step 4: Run the 4DEnVar application
-----------------------------------

Users can also run 4DEnVar with JEDI-MPAS. We can still use the same ``RUN`` directory with 3DEnVar case. Note that
the 4-dimensional background and ensemble files are already linked into ``RUN/Data`` directory in step 1. Let's copy the
4DEnVar yaml file from ``CODE`` directory.

.. code-block:: bash

    cd $RUN
    cp $CODE/mpas-jedi/test/testinput/4denvar_bumploc.yaml ./

Like 3DEnVar, comment out the ``test`` section of ``4denvar_bumploc.yaml`` to prevent the comparisons that ctest usually performs, by adding a # at the
beginning of each line as follows.

.. code-block:: bash

    #test:
    #  float relative tolerance: 0.00000001
    #  integer tolerance: 0
    #  reference filename: testoutput/4denvar_bumploc.ref
    #  log output filename: testoutput/4denvar_bumploc.run
    #  test output filename: testoutput/4denvar_bumploc.run.ref

``4denvar_bumploc.yaml`` contains three 3-hour time slots centered at [-3, 0, +3 hr] relative to the analysis time. As
OOPS parallelizes the time dimension of the 4DEnVar application, the total number of processors should be a multiple of the number of time slots.
Here, ``3`` processors are used with ``mpiexec`` command as follows.

.. code-block:: bash

    # while in RUN directory
    mpiexec -n 3 mpasjedi_variational.x 4denvar_bumploc.yaml

    # Or
    mpiexec -n 3 mpasjedi_variational.x 4denvar_bumploc.yaml run.log

    # Or
    mpiexec -n 3 mpasjedi_variational.x 4denvar_bumploc.yaml >& run.log

As in step 3, users can plot the horizontal distribution of analysis increment fields.

.. code-block:: bash

    # while in RUN directory
    ln -sf Data/480km/bg/restart.2018-04-*.nc ./
    ln -sf Data/states/mpas.4denvar_bump.2018-04-*.nc ./

    # move into the graphics directory and execute the python script
    cd graphics

    python plot_inc.py 2018041421 4denvar_bump uReconstructZonal 1 False

    # Or
    python plot_inc.py 2018041500 4denvar_bump uReconstructZonal 1 False

    # Or
    python plot_inc.py 2018041503 4denvar_bump uReconstructZonal 1 False


Step 5: Generate a localization file (optional)
-------------------------------------------------

We have used a pre-generated localization file when running the 3DEnVar and 4DEnVar applications above. In this optional tutorial,
we will explore how the localization files are generated with executable ``mpasjedi_parameters.x``, which estimates various
background error statistics using ``SABER`` repository.


In the ``RUN`` directory, remove the existing localization files.

.. code-block:: bash

    cd $RUN
    rm Data/bump/mpas_parametersbump_loc_nicas*.nc # remove the existing bumploc files.

Then, copy the ``parameters_bumploc.yaml`` file from ``CODE`` and link the executable from ``BUILD`` directory.

.. code-block:: bash

    cp $CODE/mpas-jedi/test/testinput/parameters_bumploc.yaml ./
    ln -sf $BUILD/bin/mpasjedi_parameters.x ./

Like 3DEnVar and 4DEnVar, comment out the top lines of ``parameters_bumploc.yaml`` to prevent the comparisons normally performed by ctests.

.. code-block:: bash

    #test:
    #  float relative tolerance: 0.00000001
    #  integer tolerance: 0
    #  reference filename: testoutput/parameters_bumploc.ref
    #  log output filename: testoutput/parameters_bumploc.run
    #  test output filename: testoutput/parameters_bumploc.run.ref

``parameters_bumploc.yaml`` specifies that the localization length will be estimated based on 5 ensemble members, then writes out
the localization files in NetCDF format. The important configurations are set under ``bump`` yaml key, and please see
``Operators generation`` section of the the SABER :doc:`Getting started <../../../inside/jedi-components/saber/getting_started>` documentation for further information. Note that the current yaml file requests
estimates only for the horizontal localization length scale and specifies no vertical localization
because the 480 km test data has only six vertical levels. Let's issue the ``mpiexec`` command as follows.

.. code-block:: bash

    # while in RUN directory
    mpiexec -n 1 mpasjedi_parameters.x parameters_bumploc.yaml

    # Or
    mpiexec -n 1 mpasjedi_parameters.x parameters_bumploc.yaml run.log

    # Or
    mpiexec -n 1 mpasjedi_parameters.x parameters_bumploc.yaml >& run.log

Users can find the NetCDF outputs under ``Data/bump`` directory.
