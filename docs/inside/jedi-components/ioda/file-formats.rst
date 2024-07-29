.. _top-ioda-file-formats:

IODA File Formats
=================

Overview
--------

IODA can read files in the following formats:

* HDF5
* ODB
* BUFR
* Script

and write files in the following formats:

* HDF5
* ODB

IODA currently provides two reader implementations: the original reader (which is not io pool based) and a new io pool based reader.
The plan is to phase out the original (non io pool based) reader and replace it with the io pool based reader.

IODA provides one writer implementation which is io pool based.

Io pool based reading and writing means that a small number of tasks in the ObsSpace main communicator group are designated as io pool members and only these tasks handle file IO operations.
All of the data belonging to non io pool members is handled with MPI data transfers.

The flow of the io pool reader is show in :numref:`ioda-io-pool-based-reader` below.

.. _ioda-io-pool-based-reader:
.. figure:: images/IODA_IoPoolBasedReader.png
   :height: 400px
   :align: center

   Data flow for the IODA io pool based reader

The steps moving from left to right are to prepare a set of input files from the original file, read those files into corresponding io pool ranks, and then distribute to the remaining ranks using MPI data transfers.
The prepared file set is constructed with the locations rearranged for streamlining the subsequent MPI data transfers.
Each file in the prepared file set contains only the locations destined for the given io pool rank and its assigned non io pool ranks.
In addition, the locations are grouped in contiguous blocks where each block represents the locations that get distributed to each rank (i.e., the io pool rank and its assigned non io pool ranks).

Note that the io pool based writer data flow essentially is the reverse of that shown in :numref:`ioda-io-pool-based-reader`, with the exception that the output file is directly written by the io pool ranks since there is no need to rearrange the locations in the writer flow.

Io Pool Configuration
^^^^^^^^^^^^^^^^^^^^^

Controls for the io pool feature are grouped into the ``obs space.io pool`` YAML configuration section, and apply to any of the specific file types.
Note that there is only one io pool specification for a given ``obs space`` configuration meaning that the configuration is shared by the reader and writer.

With the io pool a maximum size is specified (default is 4 tasks) using the ``obs space.io pool.maximum pool size`` specfication.
The io pool size is set to the minumum of the communicator group size and the specified maximum pool size.
Here is an example showing how to change the maximum pool size from the default of 4 to 6.

.. code-block:: YAML

    obs space:
      io pool:
        max pool size: 6

Non Io Pool Based Reading
^^^^^^^^^^^^^^^^^^^^^^^^^

Currently, the original reader is selected by default so no change is needed in the YAML to select this reader.
Therefore, no need to add an ``obs space.io pool`` configuration section in the YAML for the reader.

Io Pool Based Reading
^^^^^^^^^^^^^^^^^^^^^

The ``obs space.io pool.reader name`` YAML specification allows the user to select the io pool based reader by setting the reader name to "SinglePool" as shown below.

.. code-block:: YAML

    obs space:
      io pool:
        reader name: SinglePool

The io pool based reader can operate in two modes denoted "internal" and "external".
"Internal" refers to having the IODA reader create the prepared file set during its initialization step.
In other words, the prepared input file set is created on the fly during the execution of the DA job.
"External" refers to having an external process, run prior to the DA job, create the prepared file set, and is accomplished using the ``ioda-buildInputFileSet.x`` application.

Internal mode
.............

Internal mode is the default so it is not required to specify this in the YAML configuration.
However, the internal mode requires a work directory that is expected to be provided, and specified in the YAML, from external (to the DA job) means such as the workflow.
The IODA reader expects the work directory to exist, and expects the external means to clean up the work directory (i.e., remove the intermediate input file set) if that is desired.
Here is an example configuration:

.. code-block:: YAML

    obs space:
      obsdatain:
        engine:
          type: H5File
          obsfile: Data/testinput_tier_1/sondes_obs_2018041500_m.nc4
      io pool:
        reader name: SinglePool
        work directory: path/to/the/work/directory

Let's say that a workflow is being used.
Then the workflow is expected to create the work directory (path/to/the/work/directory), give it the proper write permissions so that the reader can create the input file set, and optionally clean up after the DA job finishes.
The IODA reader will check for the existence of the work directory, and if it is missing will throw an exception and quit.

The IODA reader will name the input file set files based on the file name given in the ``obsdatain.engine.obsfile`` specification.
In this example with an io pool size of 4, the input file set will be created as:

- path/to/the/work/directory/sondes_obs_2018041500_m_0000.nc4
- path/to/the/work/directory/sondes_obs_2018041500_m_0001.nc4
- path/to/the/work/directory/sondes_obs_2018041500_m_0002.nc4
- path/to/the/work/directory/sondes_obs_2018041500_m_0003.nc4

Note that the work directory and input file set organization and naming is under the control of the workflow, and it is therefore the responsibility of the workflow to prevent file name collisions.
This can be accomplished by either using unique names in all of the ``obsdatain.engine.obsfile`` specifications, or by using unique work directory paths for each of the different ``obs space`` specifications.
The former is typically the situation for a workflow, whereas the latter is being used to prevent collisions in the IODA tests (which share common input files).

External mode
.............

In the external mode, two configurations need to be specified: one for the standalone application, and the other for the IODA reader during the DA run.
For the examples shown below, let's say that the DA run is planned to be run with 100 MPI tasks, and the io pool is to consist of 6 MPI tasks.
Note how these two configurations need to be consistent with respect to the planned MPI allocation (i.e, in this case 6 tasks in the io pool and 100 tasks overall).

----

**Standalone Application Configuration**

The standalone application is run using the ``ioda-buildInputFileSet.x`` application and takes the usual arguments for an oops::Application executable:

.. code-block:: bash

   # usage string is: ioda-buildInputFileSet.x config-file [output-file]
   # where config-file contains the YAML specifications, and output-file is an optional log file

   ioda-buildInputFileSet.x standalone-app-config.yaml

The standalone application will perform the usual time window filtering, obs grouping and generating the MPI routing (where each location goes, but without the actual distribution) that the original and internal mode of the io pool based readers do.
Because of this, the YAML configuration for the standalone application mimics the configuration for the IODA reader to keep things consistent and familiar.
The usual ``obs space.obdatain`` configuration and ``obs space.io pool`` configurations apply.

The standalone application is specified by setting the ``obs space.io pool.reader name`` configuration to "PrepInputFiles".
Some additional configuration is necessary to inform the standalone application of the planned target size (100 MPI tasks for this example) of the main ObsSpace communicator group in the subsequent DA job, and for the output file name.
As before, the output file name gets the io pool communicator rank numbers appended to create the unique names in the input file set.
Also, the directory portion of the output file name specification is expected to be managed by the workflow (or other external means).
Here is an example YAML configuration for the standalone application:

.. code-block:: YAML

   time window:
     begin: "2018-04-14T21:00:00Z"
     end: "2018-04-15T03:00:00Z"

   obs space:
     name: "AMSUA NOAA19"
     simulated variables: ['brightnessTemperature']
     channels: 1-15
     obsdatain:
       engine:
         type: H5File
         obsfile: "Data/testinput_tier_1/amsua_n19_obs_2018041500_m.nc4"
     io pool:
       reader name: PrepInputFiles
       max pool size: 6
       file preparation:
         output file: "path/to/work/directory/amsua_n19_obs_2018041500_m.nc4"
         mpi communicator size: 100

In this example, the communicator given to the ObsSpace constructor in the subsequent DA job is expected to contain 100 MPI tasks as mentioned above.
A work directory is implied by the directory portion of the ``io pool.file preparation.output file`` specification, and as in the internal mode case, the workflow is expected to manage that directory.

Note that the ``time window`` specification is required and must match that of the subsequent DA job. This is necessary for executing the time window filtering operation.

Only one ``obs space`` specification is accepted by the standalone application since it is expected that the workflow will submit separate jobs in parallel for each of the target ObsSpace objects, whereas allowing for multilple ``obs space`` specifications in one execution of the standalone application will force serial execution for those ObsSpace targets.

----

**DA Job Configuration**

The configuration for the subsequent DA job needs to be consistent with the configuration given to the standalone application.
This configuration needs to specify the "SinglePool" reader name, along with a new ``obsdatain.file preparation type`` specification to tell the IODA reader that the input file set was created by the standalone application.
Here is the YAML configuration for the DA job that goes with the example standalone application YAML example above.

.. code-block:: YAML

   time window:
     begin: "2018-04-14T21:00:00Z"
     end: "2018-04-15T03:00:00Z"
   ...
   observations:
   - obs space:
       name: "AMSUA NOAA19"
       simulated variables: ['brightnessTemperature']
       channels: 1-15
       obsdatain:
         engine:
           type: H5File
           obsfile: "path/to/work/directory/amsua_n19_obs_2018041500_m.nc4"
         file preparation type: "external"
       io pool:
         reader name: SinglePool
         max pool size: 6

Note that the ``io pool.max pool size`` specification (6) is in accordance with the planned DA run, which will use 100 total tasks, as noted above.
Also note that the ``obsdatain.engine.obsfile`` specification for the DA job YAML, matches the ``io pool.output file`` specification for the standalone application YAML.
This will allow for the file naming (i.e., the appending of the io pool rank number) to match up between the two steps.

This coordination between the standalone application YAML and the DA job YAML is a bit cumbersome, but it is expected to be automated in a workflow so hopefully this is not too troublesome.
To help with the setting up of these configurations, the standalone application creates an additional file in the input file set with a ``_prep_file_info`` suffix (``amsua_n19_obs_2018041500_m_prep_file_info.nc4`` in the examples above) that holds information about what the input file set "fits" with.
In these examples the ``prep_file_info`` file will contain attributes holding the expected io pool size (6) and the expected main communicator size (100), plus variables holding information describing the io pool configuration that the input file set was built for.
These values are checked by the IODA reader in the DA flow and if these do not match up an exception, with messages indicating what is wrong, is thrown and the job quits.

Io Pool Based Writing
^^^^^^^^^^^^^^^^^^^^^

In addition to specifying the maximum pool size, the writer pool can be configured to produce a single output file (default) or a set of output files that correspond to the number of tasks in the io pool. 
In the case of writing multiple files, each MPI rank in the io pool will write its observations, plus the observations of the non io pool ranks assigned to it, to a separate file with the name obtained by inserting the rank number before the extension of the file name taken from the ``obs space.obsdataout.engine.obsfile`` option.

.. code-block:: YAML

    obs space:
      ...
      obsdataout:
        engine:
          type: H5File
          obsfile: Data/sondes_obs_2018041500_m_out.nc4
      io pool:
        max pool size: 6
        write multiple files: true

In this example the writer is being told to form an io pool of no more than six pool members, and to write out multiple output files.
Note a setting of ``false`` for the ``write multiple files`` is the default and results in the writer producing a single output file containing all of the observations.
In this case, when there are 6 tasks in the io pool the output files that are created are:

- Data/sondes_obs_2018041500_m_out_0000.nc4
- Data/sondes_obs_2018041500_m_out_0001.nc4
- ...
- Data/sondes_obs_2018041500_m_out_0005.nc4

Specific File Formats
^^^^^^^^^^^^^^^^^^^^^

The following sections describe how the specific file formats are handled from the user's point of view.

.. toctree::
   :maxdepth: 2

   format-hdf5
   format-odb
   format-bufr
   format-script

Additional Reader Controls
--------------------------

Missing File Action
^^^^^^^^^^^^^^^^^^^

When a missing input file is encountered, the reader can be configured to take one of two actions:

1. Issue a warning, construct an empty ObsSpace object, and continue execution. This action is typically applicable to operations where you want the job to forge ahead despite a missing file.
2. Issue an error, throw an exception, and quit execution. This action is typically applicable to research and development where you want to be immediately notified when a file is missing.

The missing file action can be specified in the YAML configuration using the ``missing file action`` keyword.
The valid values are ``warn`` or ``error`` (default), where ``warn`` corresponds the the first action and ``error`` corresponds to the second action noted above.
Here is a sample YAML section that shows how to configure the missing file action to be an error.

.. code-block:: YAML

   time window:
     begin: "2018-04-14T21:00:00Z"
     end: "2018-04-15T03:00:00Z"
   ...
   observations:
   - obs space:
       name: "AMSUA NOAA19"
       simulated variables: ['brightnessTemperature']
       channels: 1-15
       obsdatain:
         engine:
           type: H5File
           obsfile: "Data/amsua_n19_obs_2018041500_m.nc4"
           missing file action: error

Note that the ``missing file action`` keyword is specified in the ``obs space.obsdatain.engine`` section.

Handling Multiple Input Files
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The IODA reader can handle multiple input files that are specified for the construction of a single ObsSpace object.
The files are appended along the Location dimension to form the data loaded into the ObsSpace object, and as such have the following constraints on their layout.

1. The files need to contain the same set of variables.
2. For multi-dimensioned variables (e.g., Location X Channel), the second and higher dimensions must be specified identically in each file. For the 2D, Location X Channel example, each file must have the same number of channels all specfied with matching channel numbers.
3. Variables that are not dimensioned by Location must be defined identically in each file. For example, if the files contain ``MetaData/channelFrequency`` (dimensioned by Channel), the corresponding variable in each file must be the same size and have the same values.
4. For the file formats (ODB, BUFR) that require additional configuration beyond the paths to the input files (e.g. ODB mapping file, BUFR table path, etc.), each file needs to be readable using the same set of additional configuration.

A new keyword named ``obsfiles`` (plural) has been added to the YAML configuration, and this keyword is placed in the ``obs space.obdatain.engine`` section.
The current ``obsfile`` (singluar) keyword will continue to be accepted.
Note that the existing YAML files will contiue to read in single files as before, thus there is no need to modify existing YAML (except to specify multiple input files).
One and only one of the ``obsfile`` or ``obsfiles`` keywords must be used for the reader backends that tie to files (eg, H5File, ODB, bufr).
Here is an example HDF5 file backend YAML configuration using multiple input files.

.. code-block:: YAML

   time window:
     begin: "2018-04-14T21:00:00Z"
     end: "2018-04-15T03:00:00Z"
   ...
   observations:
   - obs space:
       name: "AMSUA NOAA19"
       simulated variables: ['brightnessTemperature']
       channels: 1-15
       obsdatain:
         engine:
           type: H5File
           obsfiles:
           - "Data/amsua_n19_obs_2018041500_m_p1.nc4"
           - "Data/amsua_n19_obs_2018041500_m_p2.nc4"
           - "Data/amsua_n19_obs_2018041500_m_p3.nc4"

Note that the file data will be appended to the ObsSpace in the order of the list of files in the ``obsfiles`` specification.
