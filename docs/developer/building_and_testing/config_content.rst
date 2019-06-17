JEDI Configuration Files: Content
=================================

This document describes some of the items included in JEDI configuration (config) files and how to use them.  **It is not intended to be complete**.  Different models and observation types have different implementations of these basic elements, often with different parameters and variable names.

Users and developers are welcome to add their own items and the accompanying code to process them.  We recommend using the JEDI repositories **ioda**, **ufo**, and **fv3-jedi** as prototypes for the structure, content, and naming conventions in the config files.

This document is intended only as a guide to help users interpret and customize JEDI configuration files in order to run applications.   Developers may also use this information to write new tests.  For practical information on how to modify the JEDI code to read and process the information contained in the configuration files see: :doc:`JEDI Configuration Files: Implementation <configuration>`.

The sections of this document refer to the top-level items in the :ref:`YAML/JSON configuration files <config-format>` and how each of these top-level items are used.  **This is a work in progress**.  There are plans to standardize the top-level contents of the JEDI config files and this document will be updated as this occurs.


resolution/Geometry
^^^^^^^^^^^^^^^^^^^

JEDI config files use both **resolution** and **Geometry** to define the model grid (both horizontal and vertical) and its parallelization across compute nodes.  The latter term, **Geometry** is commonly used for unit tests at the oops level while **resolution** is often used for applications such as 4DEnsVar where multiple grids may be used.  There are plans to standardize this terminology in the future but both terms are currently used.

Sometimes, as is the case with FV3, grid information is read from data files that are provided with the model repository via :doc:`git LFS <../developer_tools/gitlfs>`.  This entry may also include one or more Fortran namelist files that are read by the model to set up the grid and its parallel partitioning.

State
^^^^^

Used to define multiple unit tests for the model state, including file IO, interpolation, variable changes, increments, and computation of the background error covariance matrix.

Model, LinearModel
^^^^^^^^^^^^^^^^^^

Used to define model parameters, control flags, physics packages, and other options for the model and the linearized model respectively.  Items may also define Fortran namelist files to be used by the model.

Covariance
^^^^^^^^^^

Provides information and specifications for computing the background error covariance matrix, also known as the B matrix.  The first item in this section is often the variable **covariance**, which identifies the method by which the B matrix is computed.  A popular option here is **BUMP**, the `Background error covariance on an Unstructured Mesh Package <https://github.com/benjaminmenetrier/bump>`_ developed by Benjamin Menetrier (JCSDA/Meteo-France) and distributed as part of oops.  Alternatively, individual models may also offer a static B matrix.

ModelBias, ModelBiasCovariance
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Used to define the model bias and its associated error covariance matrix.


Initial Condition
^^^^^^^^^^^^^^^^^

This is used to define the initial condition of a forecast or DA cycle.  It often includes references to restart files and Fortran namelists to be used by the model upon startup.  Alternatively, it may specify one of several idealized analytic states that can be used to initialize models.  JEDI currently provides several options for analytic initialization based on the idealized benchmarks defined by the multi-institutional 2012 `Dynamical Core Intercomparison Project <https://earthsystemcog.org/projects/dcmip-2012>`_ sponsored by NOAA, NSF, DOE, NCAR, and the University of Michigan.  Other analytic models may be added in the future.

Observations
^^^^^^^^^^^^

Often the largest section of the configuration file, this describes one or more observation types (**ObsTypes**), each of which is a multi-level YAML/JSON object in its own right.  As described our :doc:`Configuration file implementation example <configuration>`, each of these **ObsTypes** are read into JEDI as an :code:`eckit::Configuration` object.  Commonly used components within each ObsType include

* **ObsType**: A name describing the observation type
* **ObsData**: Input and output file names that contain the data
* **variables**: Identifies variables required for the forward operator
* **Covariance**: Provides information and specifications for computing the observation error covariance matrix.
* **ObsFilters**: Used to define QC filters
* **ObsBias**: Used to specify the Bias correction
* **GeoVaLs**: Identifies simulated ufo output files and other parameters that are used for testing

Here is an :ref:`example YAML file <radiosonde_example_yaml>` showing how to specify the creation of an output file from IODA.

Assimilation Window
^^^^^^^^^^^^^^^^^^^

Used to define the assimilation window for many applications, such as MakeObs, HofX, and EnsHofX.

cost_function
^^^^^^^^^^^^^

Specifies parameters, variables, and control flags used to define how the cost function should be calculated.

minimizer
^^^^^^^^^

This tells oops which algorithm to use for minimizing the cost function, specified by the variable **algorithm**.  Valid options include DRGMRESR, DRIPCG, GMRESR, IPCG, SaddlePoint, RPCG, DRPCG, DRPFOM, LBGMRESR, DRPLanczos, PCG, PLanczos, RPLanczos, MINRES, and FGMRES.

Output
^^^^^^

Used to specify the name, path, format, frequency, and other attributes of any output files that the application may produce.

Top-Level Variables
^^^^^^^^^^^^^^^^^^^

Most of the content in the JEDI config files is contained in sections of the YAML/JSON hierarchy that :ref:`can themselves be treated as self-contained Configuration objects <config-cpp>`.  Some of the more commonly used sections are described above, throughout this document.  However, occasionally you will also find variables specified in the top level of the YAML/JSON hierarchy that are not part of a distinct section.  These are often concerned with high-level operations such as defining the test suite, parallel configuration, IO frequency and log verbosity.  In some cases, such as the ufo unit tests, this may also include high-level data assimilation parameters such as **window_begin** and **window_end**.  These are read in as :code:`util::DateTime` objects and are used to defined the assimilation window used for the tests.
