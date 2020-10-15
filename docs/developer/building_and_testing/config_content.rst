JEDI Configuration Files: Content
=================================

This document describes some of the items included in JEDI configuration (config) files and how to use them.  **It is not intended to be complete**.  Different models and observation types have different implementations of these basic elements, often with different parameters and variable names.

Users and developers are welcome to add their own items and the accompanying code to process them.  We recommend using the JEDI repositories **saber**, **ioda**, **ufo**, and **fv3-jedi** as prototypes for the structure, content, and naming conventions in the config files.

This document is intended only as a guide to help users interpret and customize JEDI configuration files in order to run applications.   Developers may also use this information to write new tests.  For practical information on how to modify the JEDI code to read and process the information contained in the configuration files see: :doc:`JEDI Configuration Files: Implementation <configuration>`.

The sections of this document refer to the top-level items in the :ref:`YAML/JSON configuration files <config-format>` and how each of these top-level items are used.

geometry
^^^^^^^^

JEDI config files use **geometry** to define the model grid (both horizontal and vertical) and its parallelization across compute nodes.

Sometimes, as is the case with FV3, grid information is read from data files that are provided with the model repository via :doc:`git LFS <../developer_tools/gitlfs>`.  This entry may also include one or more Fortran namelist files that are read by the model to set up the grid and its parallel partitioning.

state
^^^^^

Used to define multiple unit tests for the model state, including file IO, interpolation, variable changes, increments, and computation of the background error covariance matrix.

model, linear model
^^^^^^^^^^^^^^^^^^^

Used to define model parameters, control flags, physics packages, and other options for the model and the linearized model respectively.  Items may also define Fortran namelist files to be used by the model.

background error
^^^^^^^^^^^^^^^^

Provides information and specifications for computing the background error covariance matrix, also known as the B matrix.  The first item in this section is often the key **covariance model**, which identifies the method by which the B matrix is computed.  A popular option here is **BUMP**, the `Background error covariance on an Unstructured Mesh Package <https://github.com/benjaminmenetrier/bump>`_ developed by Benjamin Menetrier (JCSDA/Meteo-France) and distributed as part of saber.  Alternatively, individual models may also offer a static B matrix.

model aux control, model aux error
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Used to define the model bias and its associated error covariance matrix.


initial condition
^^^^^^^^^^^^^^^^^

This is used to define the initial condition of a forecast or DA cycle.  It often includes references to restart files and Fortran namelists to be used by the model upon startup.  Alternatively, it may specify one of several idealized analytic states that can be used to initialize models.  JEDI currently provides several options for analytic initialization based on the idealized benchmarks defined by the multi-institutional 2012 `Dynamical Core Intercomparison Project <https://earthsystemcog.org/projects/dcmip-2012>`_ sponsored by NOAA, NSF, DOE, NCAR, and the University of Michigan.  Other analytic models may be added in the future.

observations
^^^^^^^^^^^^

Often the largest section of the configuration file, this describes one or more observation types, each of which is a multi-level YAML/JSON object in its own right.  As described our :doc:`Configuration file implementation example <configuration>`, each of these observation types are read into JEDI as an :code:`eckit::Configuration` object.  Commonly used components within each observation type include

* **obs space**: describes observation space-related configuration (required)

  * **name**: descriptive name, used in logs (required)
  * **obsdatain.obsfile**: input filename (this or **generate** section is required)
  * **obsdataout.obsfile**: output filename (optional)
  * **simulated variables**: list of variables that need to be simulated by the observation operator (required).

Example:

.. code:: yaml

   # Example 1: radiosonde
   obs space:
     name: Radiosonde
     obsdatain:
       obsfile: Data/sondes_obs_2018041500.nc4
     simulated variables: [air_temperature, eastward_wind, northward_wind]
   # Example 2: radiances (note channels specification)
   obs space:
     name: amsua_n19
     obsdatain:
       obsfile: Data/amsua_n19_obs_2018041500.nc4
     obsdataout:
       obsfile: Data/amsua_n19_obs_2018041500_out.nc4
     simulated variables: [brightness_temperature]
     channels: 1-10,15


* **obs operator**: describes observation operator and its options (required)

  * **name**: name in the ObsOperator and LinearObsOperator factory, defined in the C++ code (required)
  * other options depend on observation operators (see :doc:`description of existing obs operators<../../jedi-components/ufo/obsops>`).

* **obs error**: Provides information and specifications for computing the observation error covariance matrix (required for DA applications). The first item in this section is often the key **covariance model**, which identifies the method by which observation error covariances are constructed. The only option supported currently is **diagonal** for diagonal observation error covariances.
* **obs filters**: Used to define QC filters (optional, see :doc:`description of existing QC filters<../../jedi-components/ufo/qcfilters>`)
* **obs bias**: Used to specify the bias correction (optional)
* **geovals**: Identifies simulated ufo output files and other parameters that are used for testing (optional, only used for UFO tests)

Here is an :ref:`example YAML file <radiosonde_example_yaml>` showing how to specify the creation of an output file from IODA.

window begin, window length
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Used to define the assimilation window for many applications, such as Variational, EDA, LocalEnsembleDA, MakeObs, HofX, EnsHofX.

cost function
^^^^^^^^^^^^^

Specifies parameters, variables, and control flags used to define how the cost function should be calculated (read more on existing cost functions :doc:`here <../../jedi-components/oops/applications/variational>`).

minimizer
^^^^^^^^^

This tells oops which algorithm to use for minimizing the cost function, specified by the key **algorithm**.  Valid options include DRGMRESR, DRIPCG, GMRESR, IPCG, SaddlePoint, RPCG, DRPCG, DRPFOM, LBGMRESR, DRPLanczos, PCG, PLanczos, RPLanczos, MINRES, and FGMRES (more on minimizers :doc:`here <../../jedi-components/oops/applications/variational>`).

output
^^^^^^

Used to specify the name, path, format, frequency, and other attributes of any output files that the application may produce.

Top-Level Variables
^^^^^^^^^^^^^^^^^^^

Most of the content in the JEDI config files is contained in sections of the YAML/JSON hierarchy that :ref:`can themselves be treated as self-contained Configuration objects <config-cpp>`.  Some of the more commonly used sections are described above, throughout this document.
