.. _top-tut-hofx-mpas:

Tutorial: Simulating Observations with a JEDI-MPAS Application
=======================================================================

Learning Goals:
 - Create simulated observations with the mpas-jedi HofX application from a JEDI-MPAS build

..
 - Acquaint yourself with the rich variety of observation operators now available in :doc:`UFO <../../../inside/jedi-components/ufo/index>`

Prerequisites:
 - :doc:`Build and test JEDI-MPAS <dev-container_mpas_jedi>`

.. _hofxmpas-overview:

Notes:
 - This tutorial is modeled after the separate :doc:`Simulating Observations with UFO <../level1/hofx_nrt>`
   tutorial, with some specific content related to JEDI-MPAS


Overview
--------

The comparison between observations and forecasts is an essential component of any data assimilation (DA) system and is critical for accurate Earth System Prediction.  It is common practice to do this comparison in observation space.  In JEDI, this is achieved through the Unified Forward Operator (:doc:`UFO <../../../inside/jedi-components/ufo/index>`).  The principle job of UFO is to start from a model background state and to then simulate what that state would look like from the perspective of different observational instruments and measurements.

In the data assimilation literature, this procedure is often represented by the expression :math:`H({\bf x})`.  Here :math:`{\bf x}` represents prognostic variables -- plus dependent diagnostic variables -- on the model grid, typically obtained from a forecast, and :math:`H` represents the *observation operator* that generates simulated observations from that model state.  The sophistication of observation operators varies widely, from in situ measurements where it may just involve interpolation and possibly a change of variables (e.g. radiosondes), to remote sensing measurements that require physical modeling to produce a meaningful result (e.g. radiance, GNSSRO).

In this tutorial we will run an application called :math:`H({\bf x})`, which is often denoted in program and function names as ``HofX``.  This tutorial will highlight some of the capabilities of JEDI's Unified Forward Operator (:doc:`UFO <../../../inside/jedi-components/ufo/index>`) in the context of the MPAS interface to JEDI, :doc:`mpas-jedi <../../../inside/jedi-components/mpas-jedi/index>`.

With that aim, we will repurpose the description of mpas-jedi's ``hofx3d`` ctest that was executed in the :doc:`Build and test JEDI-MPAS <dev-container_mpas_jedi>` tutorial.  We will use the quasi-uniform MPAS-Model 480km global mesh and the same observations as were simulated in that ctest.  After completion of the simulation, we will analyze the observation-space results using post-processing tools available in the mpas-jedi repository.


Step 1: Setup
-------------

Now that you have finished the :doc:`Build and test JEDI-MPAS <dev-container_mpas_jedi>` tutorial, you have a containerized version of ``mpas-bundle`` ready to go.  So, if you are not there already, re-enter the container:

.. code-block::

   singularity shell -e jedi-tutorial_latest.sif

The description in the previous section gives us a good idea of what we need to run :math:`H({\bf x})`.  First, the locations of observations and real or pseudo observed quantities, :math:`y`, are needed in order to simulate the observations and to verify the simulation. Second, we need :math:`{\bf x}` - the model state.  Lastly, we need the descriptions of the observation operators :math:`H`.


First we define a few base directories that we use throughout the tutorial.  For the sake of making command line entries easier going forward, we first establish the ``mpas-bundle`` ``BUILD`` and ``CODE`` directories as environment variables to make directory references easier:

.. code-block:: bash

    export CODE=$HOME/jedi/mpas-bundle
    export BUILD=$HOME/jedi/mpas-build

The ``mpas-bundle`` ``BUILD`` and ``CODE`` directories can be thought of as resources to be used for prototyping a new use-case for JEDI applications, but not as a place to add new use-cases.  Therefore, you'll need to copy the files used in this tutorial over to a new directory that is dedicated to running the examples. 
 
You have some freedom in setting the ``RUN`` directory where we will run this tutorial example.  If you are working in Vagrant, it is convenient to work in a directory that is accesible from outside the container, e.g.,

.. code-block:: bash

    export RUN=$HOME/vagrant_data/tutorials/hofx-mpas

Otherwise, you might elect to simply use 

.. code-block:: bash

    export RUN=$HOME/tutorials/hofx-mpas

Once you decide, create the ``RUN`` directory, then navigate to it.

.. code-block:: bash

   mkdir -p $RUN
   cd $RUN


Now we are ready to collect the data and application configuration files through copying and linking, and place it in the ``RUN`` directory.  Much of this procedure is identical to what is automatically encoded into the ctest setup.  We are repeating the process here on the command-line for transparency.  First, let us create a ``Data`` directory where input data can be linked.

.. code-block:: bash

    mkdir Data
    cd Data

:math:`y`, observations
"""""""""""""""""""""""

Link the observation files and CRTM coefficient files.  These are stored in the ufo-data and crtm-data repositories.

.. code-block:: bash

    # while in Data directory
    ln -sf $BUILD/mpas-jedi/test/Data/ufo ./
    ln -sf $BUILD/mpas-jedi/test/Data/UFOCoeff ./

The example observations used in this tutorial include:

* Aircraft
* Sonde
* GnssroRef
* SfcPCorrected
* Clear-sky AMSUA-NOAA19
* All-sky AMSUA-NOAA19
* CRIS-NPP
* AIRS-AQUA

Additional observation test files are available in the ufo-data repository, which is now linked to ``ufo`` in your ``Data`` directory. See the :doc:`UFO documentation <../../../inside/jedi-components/ufo/index>` or the `JCSDA NRT website <http://nrt.jcsda.org>`_ for an explanation of acronyms and of additional observation types that can be handled in UFO.


:math:`{\bf x}`, background state
"""""""""""""""""""""""""""""""""


Link the background state directory, which includes the single 480km global background file that is used in this application

.. code-block:: bash

    # while in Data directory
    mkdir 480km
    cd 480km
    ln -sf $BUILD/mpas-jedi/test/Data/480km/bg ./
    cd .. # return to Data directory

:math:`H`, model and application configurations
"""""""""""""""""""""""""""""""""""""""""""""""

Next we need to copy over files associated with configuring either MPAS-Model or the ``hofx3d`` application. The ``hofx3d.yaml`` file contains many observation space components that are described in the UFO sections of :doc:`yaml <../../../inside/jedi-components/configuration/configuration>`.  There are also sections that are specific to mpas-jedi.  The MPAS-Model configuration files, including fortran namelists and xml-based streams.atmosphere are described in the `MPAS-Atmosphere <https://mpas-dev.github.io/atmosphere/atmosphere_download.html>`_ documentation.  There are some entries in those files that are specific either to JEDI-MPAS applications or to this tutorial, such as directory structures.  Here we make brand new copies of all relevant files, because we will modify some of them in later parts of the tutorial, and we do not want to modify the settings that are carefully set up for the ctests.

.. code-block:: bash

    # while in Data directory
    cp $CODE/mpas-jedi/test/testinput/namelists/480km/streams.atmosphere ./480km/
    cp $CODE/mpas-jedi/test/testinput/namelists/480km/namelist.atmosphere_2018041500 ./480km/
    cd .. # return to RUN directory
    cp $CODE/mpas-jedi/test/testinput/namelists/geovars.yaml ./
    cp $CODE/mpas-jedi/test/testinput/namelists/stream_list.atmosphere.output ./
    cp $CODE/mpas-jedi/test/testinput/namelists/stream_list.atmosphere.diagnostics ./
    cp $CODE/mpas-jedi/test/testinput/namelists/stream_list.atmosphere.surface ./  
    cp $CODE/mpas-jedi/test/testinput/hofx3d.yaml ./

As you can see in the above line, we are repurposing the yaml from the ``hofx3d`` ctest. That yaml has several peculiarities specific to the ctest that we need to handle.

(1) If you look at ``obsdataout`` keys in ``hofx3d.yaml``, you will notice that they direct IODA to write the observation feedback files to a sub-directory, ``Data/os``. Let's create that directory to avoid a fatal error.

.. code-block:: bash

    # while in RUN directory
    mkdir -p Data/os

(2) the ``hofx3d`` ctest includes a comparison of log messages to a reference output, which is controlled with the ``test`` section at the top of ``hofx3d.yaml``.  Comment out all of those lines by adding a ``#`` at the beginning of each one as follows.

.. code-block:: yaml

    #test:
    #  float relative tolerance: 0.00000001
    #  integer tolerance: 0
    #  reference filename: testoutput/hofx3d.ref
    #  log output filename: testoutput/hofx3d.run
    #  test output filename: testoutput/hofx3d.run.ref


:math:`H`, static lookup tables
"""""""""""""""""""""""""""""""

The mpas-jedi interface code benefits from re-using model state initialization subroutines contained in the MPAS-Model code.  As such, mpas-jedi also re-uses the MPAS-Model static lookup tables to populate namelist-dependent constants.  Although not all of the static lookup tables are needed for each application, we link all of them to be sure:

.. code-block:: bash

    # while in RUN directory
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


:math:`H`, executable and environment
"""""""""""""""""""""""""""""""""""""

As stated already, this tutorial uses the mpas-jedi ``hofx3d`` application.  In other words, it uses the :code:`mpasjedi_hofx3d` excutable, which is a model-specific implementation of the OOPS generic :code:`HofX3D application<../../../inside/jedi-components/oops/applications/hofx>`. Let's link the executable from the build directory.

.. code-block:: bash

    # while in RUN directory
    ln -sf $BUILD/bin/mpasjedi_hofx3d.x ./

Finally we set some environment variables to ensure the application will run successfully.  It is beneficial to make the stack-size unlimited.  Also, some of the MPAS-Model lookup tables are stored as big-endian unformatted binary files.  There are 100 file units reserved in the MPAS-Atmosphere source code for such file I/O.  Setting the ``GFORTRAN_CONVERT_UNIT`` environment variable as shown below ensures the correct format is used in builds that use gfortran.

.. code-block:: bash

    ulimit -s unlimited
    export GFORTRAN_CONVERT_UNIT='big_endian:101-200'


Step 2: Run the HofX application
--------------------------------

Now we are ready to run the :code:`mpasjedi_hofx3d` executable in the same way it is exercised for the ``hofx3d`` ctest.  Issue the ``mpiexec`` command as follows

.. code-block:: bash

    # while in RUN directory
    mpiexec -n 1 mpasjedi_hofx3d.x hofx3d.yaml

The entire run log gets written to stdout, which will fill up your terminal window very quickly.  You can optionally have the main contents of the logging output tee'd to a particular file (e.g., run.log) by adding that file name as a second argument to the executable:

.. code-block:: bash

    mpiexec -n 1 mpasjedi_hofx3d.x hofx3d.yaml run.log


Or you may redirect the entire stdout and stderr streams to a file instead of having them print to your terminal:

.. code-block:: bash

    mpiexec -n 1 mpasjedi_hofx3d.x hofx3d.yaml >& run.log


When the log is specified as the second argument to the JEDI executable, each processor will write its own log file with a suffix indicating the processor number.  The exception is for the root processor, for which the log file name does not have a suffix.

If you are interested to run on multiple processors, you will need the MPAS-Model graph partition file that corresponds to the number of processors and mesh.  There are multiple such files available for the 480km mesh at ``$CODE/mpas-jedi/test/testinput/namelists/480km/x1.2562.graph.info.part.N``, where ``N`` is the number of processors. Simply link the applicable partition file into the ``RUN`` directory, then use ``-n N`` as the flag for ``mpiexec``.  You will need to choose ``N`` to be less than the number of virtual processors available in your container.  For example, the default maximum is ``vb.cpus = "12"`` in the ``Vagrantfile`` provided in the :doc:`Vagrant documentation <../../../using/jedi_environment/vagrant>`. Each platform has its own limits.

If you follow through with that modification, you will see that the ``OOPS_STATS`` section at the end of the log output now provides timing statistics for multiple MPI tasks instead of only 1 MPI task.  The ``OOPS_STATS`` output is very useful for high-level computational profiling.

Additionally, the ``hofx3d`` application logger provides information about individual observation operator performances, quality control (QC) if applicable, and the general flow of the program.  For additional information about the program flow, you may opt to use two more environment variables that turn on special logging modes, i.e.,

.. code-block:: bash

    export OOPS_TRACE=1 # default is 0
    export OOPS_DEBUG=1 # default is 0

The ``OOPS_TRACE`` option enables notifications upon entering and exiting some critical C++ class methods.  The ``OOPS_DEBUG`` option enables  more detailed debugging information.  It is recommended to only use those options during development and debugging, not for full-scale applications.  Try turning one of them on to see the difference it makes in the log output. Then turn it off by re-setting to 0.


Step 3: View the Simulated Observations
---------------------------------------

Next, let us analyze the results using one of the graphics scripts provided with mpas-jedi.  First, let's create a graphics working directory, then link the script that we will be using.

.. code-block:: bash

    # while in RUN directory
    mkdir graphics
    cd graphics
    ln -sf $CODE/mpas-jedi/graphics/plot_diag.py ./

Now execute the script with python.

.. code-block:: bash

    # while in graphics directory
    python plot_diag.py

There will be a stream of prints telling you the kinds of observations being processed and also the names of the figures generated. This plotting program was originally designed to analyze the output from an OOPS :doc:`Variational application<../../../inside/jedi-components/oops/applications/variational>`, which is why you will see quantities like observation-minus-background (OMB) and observation-minus-analysis (OMA).  There is no analysis state from an ``HofX`` application; thus, the plotting script uses identical simulated observation values for the background and analysis.

Now you can explore some of the figures. If you are using a Vagrant container, then you can view the files on your local system under the ``vagrant_data`` directory.  Otherwise, you can use ``feh`` to view the png files.

You may wish to display 2D maps of differences between simulated and observed conventional observation quantities, e.g.,

.. code-block:: bash

    feh distri_air_temperature_hofx3d_sondes_omb_allLevels.png
    feh distri_eastward_wind_hofx3d_sondes_omb_allLevels.png
    feh distri_eastward_wind_hofx3d_aircraft_omb_allLevels.png

or background, observed, and `omb` for clear-sky AMSU-A radiances,

.. code-block:: bash

    feh distri_BT9_hofx3d_amsua_n19--nohydro_obs.png
    feh distri_BT9_hofx3d_amsua_n19--nohydro_bkg.png
    feh distri_BT9_hofx3d_amsua_n19--nohydro_omb.png

Next, let's look at scatter plots of :math:`h({\bf x})` versus :math:`y` for the temperature-sounding channels of AMSU-A, which are simulated with the clear-sky CRTM operator.

.. code-block:: bash

    feh XB_XA_hofx3d_amsua_n19--nohydro.png

There are fairly large biases in the simulated observations, because bias correction is not applied to those observations.  Also look at the channels that are more sensitive to hydrometeors and are thus simulated with the all-sky CRTM operator.

.. code-block:: bash

    feh XB_XA_hofx3d_amsua_n19--hydro.png

Notice that the RMSE is much larger for the all-sky radiances than the clear-sky radiances.  You also might have noticed that channels 4 through 8 are missing for the clear-sky channels.  If you look for the `AMSUA-NOAA19--nohydro` :code:`obs space` in ``$RUN/hofx3d.yaml``, you will see that we are only simulating channels 9-14.  The cloud-sensitive channels, 1-3 and 15 are simulated in the `AMSUA-NOAA19--hydro` :code:`obs space`.  Let's add the remaining channels to `AMSUA-NOAA19--nohydro` by modifying the line in ``$RUN/hofx3d.yaml`` that reads

.. code-block:: yaml

    channels: 9-14

to be

.. code-block:: yaml

    channels: 4-14

Now, rerun the application and the plotting script

.. code-block:: bash

    cd $RUN
    mpiexec -n 1 mpasjedi_hofx3d.x hofx3d.yaml >& run.log
    cd graphics
    python plot_diag.py

If you want to save time in the plotting step, only the `amsua_n19--nohydro` observation type and the `radiance_group` need to be selected in :code:`plot_diag.py`.  You can comment out other lines by preceeding them with a `#`.

Continue to browse the figures as you like.  The vertical profile figures for aircraft, sondes, gnssroref, and satwind are useful.  However, it will become clear that we are only working with a small observation set.  Entire vertical extents are missing in the GNSSRO refractivity statistics (`*_hofx3d_gnssroref_refractivity.png`).  That is because we are working with the ctest data set, which often has fewer than 100 locations.  For example, explore the aircraft file we are using with `ncdump` or `h5dump`,

.. code-block:: bash

    ncdump -h ../Data/ufo/testinput_tier_1/aircraft_obs_2018041500_m.nc4 | less 

Now you are ready to learn how to process or download larger observation data sets and conduct your own observation simulation experiments!


Step 4: Introduction to 2-stream I/O
------------------------------------

This part of the tutorial is a bonus.  It will be useful to refer to the :doc:`MPAS-JEDI Classes documentation <../../../inside/jedi-components/mpas-jedi/classes>` for relevant terminology definitions.

Up until this point we have been using an MPAS-Model restart file to provide the 2D and 3D model background fields to mpas-jedi. It turns out that this is a resource intensive solution in terms of writing those files and storing them on an HPC, especially as the model grid-spacing is reduced. Here we will illustrate an alternative solution, tailored for mpas-jedi, called 2-stream I/O.

Some UFO operators and the conversion from model prognostic variables to background state variables requires the availability of fields that are not available by default in the defauly MPAS-Model output stream.  Using full restart files is an easy solution, but also an expensive one, requiring storing a restart file to disk whenever an mpas-jedi application needs information about the MPAS state.  In addition to background states, that includes extended forecasts for the purpose of verification.  To see why that might be a problem, consider how many fields are in a restart file, and compare it to the number of fields needed for mpas-jedi.

A first-order appoximation of the storage requirement of a model state is the number of floating-point 3D fields.  A quck way to check the number of floating-point 3D fields in an MPAS state file is through an ncdump command like the following:

.. code-block:: bash

    ncdump -h Data/480km/bg/restart.2018-04-15_00.00.00.nc | grep 'double.*nCells.*nVertLevels' | wc

Of the three output values, 54, 266, and 2419, the first one, 54, is the number of floating-point 3D fields.  Now have a look at ``stream_list.atmosphere.output`` in the ``RUN`` directory.  Those are all of the fields, 2D, 3D, and 4D (scalars is the 4D one in that list) that are read in the mpas-jedi :code:`State::read` method in order to derive the fields required for the ``hofx3d`` application.  Some additional time-variant fields are used to initialize MPAS-A model fields, and other time-invariant quantities are used to intialize the model mesh. Time-invariant or "static" fields need not be included in every mpas-jedi background state file.

The alternative solution, 2-stream I/O, writes only essential fields and separates the static and dynmically evolving fields into two separate input streams.  An example of 2-stream I/O is encoded in the mpas-jedi ctest, ``3denvar_2stream_bumploc_unsinterp``, which uses the :code:`mpasjedi_variational` excutable.  Here we will borrow some of the pieces of that ctest in order to accomplish the same goal with the :code:`mpasjedi_hofx3d` executable.  First, let's create a directory at ``Data/480km_2stream`` where we can store the files that are unique to this part of the tutorial.  Then we will link can copy the data and configuration files, respectively, just like we did in Step 2 of the tutorial.

.. code-block:: bash

    # while in RUN directory 
    mkdir Data/480km_2stream
    cd Data/480km_2stream
    ln -sf $BUILD/mpas-jedi/test/Data/480km_2stream/mpasout.2018-04-15_00.00.00.nc ./
    ln -sf $BUILD/mpas-jedi/test/Data/480km_2stream/static.nc
    cp $CODE/mpas-jedi/test/testinput/namelists/480km_2stream/namelist.atmosphere_2018041500 ./
    cp $CODE/mpas-jedi/test/testinput/namelists/480km_2stream/streams.atmosphere ./
    cd ../../ # return to RUN directory

You can see that we now have new input files and MPAS-Model configurations in the form of namelist and xml streams.atmosphere files.  Let's re-run the same ncdump command as before on the mpasout file:

.. code-block:: bash

    ncdump -h Data/480km_2stream/mpasout.2018-04-15_00.00.00.nc | grep 'double.*nCells.*nVertLevels' | wc

Now there are only 20 floating-point 3D fields.  If you follow the links all the way back to the source data, you will find that file sizes differ by a factor of 10, even better than the 54 to 20 ratio of 3D fields for this coarse mesh with only 6 vertical levels.  For larger meshes with more vertical levels, the gains are somewhat less (e.g., roughly a factor of 5-6 for the 120km mesh and 55 vertical levels), but still substantial. You can also inspect the ``streams.atmosphere`` and ``namelist.atmosphere`` files to see the new settings.  ``streams.atmosphere`` is now using an extra static stream.  In the namelist, the restart option is turned off.

In order to use the new model stream settings in the application, we need to modify ``hofx3d.yaml``.  Under the ``geometry`` section of the yaml, change the directory for the ``nml_file`` and ``streams_file`` as follows.

.. code-block:: yaml

  nml_file: "./Data/480km_2stream/namelist.atmosphere_2018041500"
  streams_file: "./Data/480km_2stream/streams.atmosphere"

Additionally, change the background state file from the 480km restart file,

.. code-block:: yaml

  filename: "./Data/480km/bg/restart.2018-04-15_00.00.00.nc"

to the new 480km_2stream mpasout file,

.. code-block:: yaml

  filename: "./Data/480km_2stream/mpasout.2018-04-15_00.00.00.nc"

Now try re-running the application

.. code-block:: bash

    # while in RUN directory
    mpiexec -n 1 mpasjedi_hofx3d.x hofx3d.yaml

If you completed all the steps correctly, the application should run to completion without error.  There will be some small differences in the :math:`H({\bf x})` values due to differences between the code versions used to generate ``mpasout.2018-04-15_00.00.00.nc`` and ``restart.2018-04-15_00.00.00.nc``, and also the parts of the log describing the :code:`State::read` method and configuration.  For all practical intents and purposes, however, the outputs are the same.


Step 5: Explore
---------------

For a tutorial with more kinds of observations and larger data sets, you are referred to the :doc:`Simulating Observations with UFO <../level1/hofx_nrt>`.  A creative explorer might even be able to re-use some of the observation files from that tutorial with the otherwise equivalent setup in this tutorial.  A good approach would be to copy the observation files over to your ``Data`` directory, then adjust the :code:`observations` section of ``hofx3d.yaml``.  This is only recommended as an advanced procedure, after the completion of the rest of this tutorial.
