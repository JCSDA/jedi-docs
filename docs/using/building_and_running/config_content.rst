JEDI Configuration Files: Content
=================================

This document describes some of the items included in JEDI configuration (config) files and how to use them.  **It is not intended to be complete**.  Different models and observation types have different implementations of these basic elements, often with different parameters and variable names.

Users and developers are welcome to add their own items and the accompanying code to process them.  We recommend using the JEDI repositories **saber**, **ioda**, **ufo**, and **fv3-jedi** as prototypes for the structure, content, and naming conventions in the config files.

This document is intended only as a guide to help users interpret and customize JEDI configuration files in order to run applications.   Developers may also use this information to write new tests.  For practical information on how to modify the JEDI code to read and process the information contained in the configuration files see: :doc:`JEDI Configuration Files: Implementation </inside/jedi-components/configuration/index>`.

The sections of this document refer to the top-level items in the :ref:`YAML/JSON configuration files <config-format>` and how each of these top-level items are used.

geometry
^^^^^^^^

JEDI config files use **geometry** to define the model grid (both horizontal and vertical) and its parallelization across compute nodes.

Sometimes, as is the case with FV3, grid information is read from data files that are provided with the model repository via :doc:`git LFS </inside/developer_tools/gitlfs>`.  This entry may also include one or more Fortran namelist files that are read by the model to set up the grid and its parallel partitioning.

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

.. _observations:

observations
^^^^^^^^^^^^

This section, which is often the largest section of the configuration file, describes the observations to be generated in an HofX application or to be assimilated in a DA cycle.  Observation perturbation settings are also prescribed here.  At the top level of this section, the YAML key :code:`obs perturbations` controls whether the observations are perturbed.  Its default value is :code:`false`.

The YAML key :code:`observers` is a list containing the details of each observation type.  Commonly used components within each item of this list include:

* **obs space**: describes observation space-related configuration (required)

  * **name**: descriptive name, used in logs (required)
  * **obsdatain** (required)

    * **engine:** (required)

      * **type**: type of backend (HDF5 file, ODB file, etc.)
      * **obsfile**: input filename

  * **obsdataout** (optional)

    * **engine:** (required, if obsdataout used)

      * **type**: type of backend (HDF5 file, eg)
      * **obsfile**: output filename

  * **observed variables**: list of variables to be processed using ufo filters whose observed values can be loaded from the input file (optional, may be an empty list if derived variables present). If not specified all ObsValue variables in the input are used to populate this list; if **channels** has been specified then this list is used for both the **observed variables** and **simulated variables**.
  * **derived variables**: list of variables to be processed using ufo filters whose observed values cannot be loaded from the input file and need to be created by a filter (optional).
  * **simulated variables**: list of variables that need to be simulated by the observation operator (required, though may be an empty list).

Example:

.. code-block:: yaml

   # Example 1: radiosonde
   obs space:
     name: Radiosonde
     obsdatain:
       engine:
         type: H5File
         obsfile: Data/sondes_obs_2018041500.nc4
     simulated variables: [airTemperature, windEastward, windNorthward]
   # Example 2: radiances (note channels specification)
   obs space:
     name: amsua_n19
     obsdatain:
       engine:
         type: H5File
         obsfile: Data/amsua_n19_obs_2018041500.nc4
     obsdataout:
       engine:
         type: H5File
         obsfile: Data/amsua_n19_obs_2018041500_out.nc4
     simulated variables: [brightnessTemperature]
     channels: 1-10,15
   # Example 3: derived variables. Suppose the input file contains wind speeds and directions,
   # but we want to assimilate the eastward and northward wind velocity components (which could
   # be derived from the speeds and directions using the Variable Transforms filter)
   obs space:
     name: Radiosonde
     obsdatain:
       engine:
         type: H5File
         obsfile: Data/sondes_obs_2018041500.nc4
     simulated variables: [airTemperature, windEastward, windNorthward]
     derived variables: [windEastward, windNorthward]
   # Example 4: observed and derived variables. Suppose the input file contains station_pressure  
   # and mean_sea_level_pressure which need to be quality controlled before being used to derive 
   # stationPressure which is the variable to be assimialted. 
   obs space:
     name: Surface
     obsdatain:
       engine:
         type: H5File
         obsfile: Data/ufo/testinput_tier_1/PStar_obs_20210521T1200Z.nc4
     observed variables: [station_pressure, mean_sea_level_pressure]
     derived variables: [stationPressure]
     simulated variables: [stationPressure]

If the observations have been divided into records then it is possible to extend the observation space such that a companion record is produced for each original record in the data set. The companion records are all produced with a (configurable) fixed number of levels. This can be invoked as follows in the configuration file:

.. code-block:: YAML

  observations:
    observers:
    - obs space:
        name: Sonde
        obsdatain:
          engine:
            type: H5File
            obsfile: sonde.odb
          obsgrouping:
            group variables: [ "stationIdentification" ]
        extension:
          allocate companion records with length: 10
          variables filled with non-missing values:
          - "latitude"
          - "longitude"
          - "dateTime"
          - "pressure"
          - "air_pressure_levels"
          - "stationIdentification"

The number of locations allocated to each companion profile is governed by the :code:`allocate companion records with length` option. In the example this is set to 10, but any integer value greater than zero can be used. If an invalid number is selected then the extension is not performed. The companion records are only produced if the option :code:`obsdatain.obsgrouping.group variables` has been set.

Assume the original data set has :code:`nlocs` locations and :code:`nrecs` records and that we wish to add companion records with :code:`ncomplocs` locations each. The extension procedure will allocate space for the companion records by adding another :code:`ncomplocs` * :code:`nrecs` locations to the observation space. The companion records can be accessed in a predictable fashion in the C++ code; given an original record has index :code:`k`, the equivalent companion record will have index :code:`k + nrecs` on the same MPI processor as the original.

A subset of variables are copied from the original profiles into the companion profiles; all other variables are filled with missing values. The value at the first entry in each profile is copied to all of the entries in the companion profile. For example, if the first value of :code:`MetaData/pressure` in an original profile is 1000 hPa then each of the 10 entries in the companion profile will be assigned values of 1000 hPa. It is expected that the user will refine these values as necessary (e.g. with the :code:`FillAveragedProfileData` or :code:`ProfileAverageObsPressure` ObsFunctions).
The variables copied can be customised with the :code:`variables filled with non-missing values` option. All variables copied in this way must be in the :code:`MetaData` group.
The values shown in the example above are the defaults.

Extending the observation space automatically produces a variable called :code:`MetaData/extendedObsSpace`. That variable is equal to 0 for the original data and 1 for the extended data and can be used to classify records with the :code:`where` statement.

* **obs operator**: describes observation operator and its options (required)

  * **name**: name in the ObsOperator and LinearObsOperator factory, defined in the C++ code (required)
  * other options depend on observation operators (see :doc:`description of existing obs operators</inside/jedi-components/ufo/obsops>`).

* **obs error**: Provides information and specifications for computing the observation error covariance matrix (required for DA applications). The first item in this section is often the key **covariance model**, which identifies the method by which observation error covariances are constructed. The only option supported currently is **diagonal** for diagonal observation error covariances. This is also the default used when the **obs error** section is not present. The initial estimates of the standard deviations (square roots of variances) of observation errors of simulated variables are loaded from ObsSpace variables from the :code:`ObsError` group, if they exist. The observation errors of any simulated variables without a counterpart in the :code:`ObsError` group are initialized to missing value indicators; it is then the user's responsibility to provide valid error estimates using an observation filter (typically performing the :code:`assign error` action; see :ref:`filter-actions`) by the time they are needed. After the last filter has been executed, any observations that still have no valid error estimates are rejected.
* **obs filters**: Used to define QC filters (optional, see :doc:`description of existing QC filters</inside/jedi-components/ufo/qcfilters/index>`)
* **obs bias**: Used to specify the bias correction (optional)
* **geovals**: Identifies simulated ufo output files and other parameters that are used for testing (optional, only used for UFO tests)

Here is an :ref:`example YAML file <radiosonde_example_yaml>` showing how to specify the creation of an output file from IODA.

window begin, window length
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Used to define the assimilation window for many applications, such as Variational, EDA, LocalEnsembleDA, MakeObs, HofX, EnsHofX.

cost function
^^^^^^^^^^^^^

Specifies parameters, variables, and control flags used to define how the cost function should be calculated (read more on existing cost functions :doc:`here </inside/jedi-components/oops/applications/variational>`).

minimizer
^^^^^^^^^

This tells oops which algorithm to use for minimizing the cost function, specified by the key **algorithm**.  Valid options include DRGMRESR, DRIPCG, GMRESR, IPCG, SaddlePoint, RPCG, DRPCG, DRPFOM, LBGMRESR, DRPLanczos, PCG, PLanczos, RPLanczos, MINRES, and FGMRES (more on minimizers :doc:`here </inside/jedi-components/oops/applications/variational>`).

output
^^^^^^

Used to specify the name, path, format, frequency, and other attributes of any output files that the application may produce.

Top-Level Variables
^^^^^^^^^^^^^^^^^^^

Most of the content in the JEDI config files is contained in sections of the YAML/JSON hierarchy that :ref:`can themselves be treated as self-contained Configuration objects <config-cpp>`.  Some of the more commonly used sections are described above, throughout this document.
