.. _top-ioda-file-formats:

IODA File Formats
=================

Overview
--------

IODA can read files in the following formats:

* HDF5
* ODB

and write files in the following formats:

* HDF5

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

Only one ``obs space`` specification is accepted by the standalone application since it is expected that the workflow will submit separate jobs in parallel for each of the target ObsSpace objects, whereas allowing for multilple ``obs space`` specifications in one execution of the standalone application will force serial execution for those ObsSpace targets.

----

**DA Job Configuration**

The configuration for the subsequent DA job needs to be consistent with the configuration given to the standalone application.
This configuration needs to specify the "SinglePool" reader name, along with a new ``obsdatain.file preparation type`` specification to tell the IODA reader that the input file set was created by the standalone application.
Here is the YAML configuration for the DA job that goes with the example standalone application YAML example above.

.. code-block:: YAML

   obs space:
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

----

The following sections describe how the specific file formats are handled from the user's point of view.

HDF5
----

Reading HDF5 files
^^^^^^^^^^^^^^^^^^

To read an HDF5 file into an ``ObsSpace``, it is enough to set the ``obs space.obsdatain.engine`` option in the YAML configuration file to the HDF5 file path. For example,

.. code-block:: YAML

    obs space:
      obsdatain:
        engine:
          type: H5File
          obsfile: Data/testinput_tier_1/sondes_obs_2018041500_m.nc4

Note that the HDF5 file type is explicitly specified using the ``obs space.obsdatain.engine.type`` keyword with the value of ``H5File``.

Writing HDF5 files
^^^^^^^^^^^^^^^^^^

To write the contents of an ``ObsSpace`` to an HDF5 file at the end of the observation processing pipeline, use the ``obs space.obsdataout.engine`` option:

.. code-block:: YAML

    obs space:
      obsdataout:
        engine:
          type: H5File
          obsfile: Data/sondes_obs_2018041500_m_out.nc4

Again, note the explicit specification of an HDF5 output file using the ``obs space.obsdataout.engine.type`` keyword.

ODB
---

.. note::

   To be able to read ODB files, ``ioda`` needs to be built in an environment providing access to ECMWF's ``odc`` library. All of the development containers (Intel, GNU and Clang) include this library.

To read an ODB file into an ``ObsSpace``, four options need to be set in the ``obs space.obsdatain.engine`` section of the YAML configuration file:

* ``type``: ODB
* ``obsfile``: the path to the ODB file;
* ``mapping file``: the path to a YAML file mapping ODB column names and units to IODA variable names;
* ``query file``: the path to a YAML file defining the parameters of an SQL query selecting the required data from the ODB file.
* ``max number channels``: The `max number channels` option is intended for use with GNSSRO data where it is desired to treat these observations as profiles (thus altering how tangent-point drift is accounted for).
  This parameter must be set to zero (the default) if the data are read into a 1D variable, and a number greater than zero if the data are read into a 2D variable.
  In the 2D case, any profiles which are not a multiple of `max number channels` in length will be padded with missing data.   Unless the typical length of a profile is known, fewer missing values will be used when the value of `max number channels` is smaller.
  However, using `max number channels` greater than one decreases the number of locations in the data, which decreases the number of geovals used.  Since geovals typically dominate the memory used by JEDI decreasing the number of locations decreases the overall amount of memory used.
  On the other hand, those geovals will not be at the correct location for all the observations, so this decreases the accuracy of the calculated `H(x)`.  Therefore choosing an appropriate value for `max number channels` will be a balance between accuracy and memory usage.
* ``time window extended lower bound``: Extended lower bound of time window (datetime in ISO-8601 format).
  This is an optional parameter which, if set, must be a dateTime equal to or earlier than the start of the assimilation window.
  Observations which lie between this lower bound and the start of the assimilation window have their dateTime set
  equal to the start of the assimilation window. This ensures that the observation will be accepted by the time
  window cutoff that is applied in oops. The original value of the datetime is stored in :code:`MetaData/initialDateTime` if
  the unmodified dateTime needs to be accessed.

The syntax of the mapping and query files is described in the subsections below. The ``ioda`` repository contains sample mapping and query files that should be sufficient for most needs. There is a single mapping file, ``test/testinput/odb_default_name_map.yml``, and one query file per observation type, e.g. ``test/testinput/iodatest_odb_aircraft.yml`` for aircraft observations and ``test/testinput/iodatest_odb_atms.yml`` for ATMS observations. For example, a YAML file used for aircraft data processing could contain the following ``obs space.obsdatain`` section:

.. code-block:: YAML

    obs space:
      obsdatain:
        engine:
          type: ODB
          obsfile: Data/testinput_tier_1/aircraft.odb
          mapping file: testinput/odb_default_name_map.yml
          query file: testinput/iodatest_odb_aircraft.yml

Mapping Files
^^^^^^^^^^^^^

Here is an example ODB mapping file:

.. code-block:: YAML

    varno-independent columns:
      - source: lat
        name: MetaData/latitude
      - source: lon
        name: MetaData/longitude
      - source: level.surface
        name: MetaData/surface_level
        bit index: 0
      - source: level.tropopause_level
        name: MetaData/tropopause_level
        bit index: 2
    varno-dependent columns:
      - source: initial_obsvalue
        group name: ObsValue
        varno-to-variable-name mapping: &obsvalue_varnos
          - varno: 29
            name: relative_humidity
            unit: percentage
          - varno: 110
            name: surface_pressure
            unit: hectopascal
      - source: initial_obsvalue
        group name: MetaData
        varno-to-variable-name mapping:
          - varno: 235
            name: air_pressure
      - source: obs_error
        group name: ObsError
        varno-to-variable-name mapping: *obsvalue_varnos
      - source: datum_event1.duplicate
        group name: DiagnosticFlags/Duplicate
        bit index: 17
        varno-to-variable-name mapping:
          - varno: 29
            name: relative_humidity
          - varno: 110
            name: surface_pressure
    complementary variables:
      - input names: [site_name_1, site_name_2, site_name_3, site_name_4]
        output name: MetaData/station_id

A mapping file may contain up to three top-level sections: ``varno-independent columns``, ``varno-dependent columns`` and ``complementary variables``. All of them are optional, but at least the first two will typically be present. The syntax of each section is described below, followed by a detailed explanation of the mappings defined in the above YAML file.

The ``varno-independent columns`` Section
.........................................

This section contains a list of items defining the mapping of individual varno-independent ODB columns to ``ioda`` variables. Varno-independent columns are those storing values dependent on the observation location, but not on the observed variable (identified by its *varno*). They include most metadata, such as latitude, longitude or station ID. Each item in this list may contain the following keys:

* ``source`` (required): name of the mapped ODB column (e.g. ``lat``) or a member of a bitfield column (e.g. ``level.surface``, indicating the ``surface`` member of the ``level`` column of type *bitfield*).

* ``name`` (required): full name of the corresponding ``ioda`` variable (e.g. ``MetaData/latitude``);

.. _varno-independent columns.unit:

* ``unit`` (optional): name of the unit used in the ODB file. If specified, values loaded from the ODB file will be converted to the unit used in ``ioda`` (typically a basic SI unit). Currently the following units are supported: ``celsius``, ``knot``, ``percentage`` (converted to a fraction), ``okta`` (1/8 -- converted to a fraction), ``degree`` (converted to radians) and ``hectopascal`` (converted to pascals).

* ``bit index`` (optional): 0-based index of the bit within a bitfield column that should store the values of the mapped member. Will be used by the ODB file writer, currently in development.

.. note::

   Bitfield ODB columns can either be mapped in their entirety to a single integer ``ioda`` variable  or be split into multiple Boolean ``ioda`` variables, each storing the value of a single member. In the latter case, it is not necessary to map each member to a ``ioda`` variable: some may be omitted, as illustrated for the ``level`` column in the YAML snippet above, which contains no mapping for the ``standard_level`` member stored in bit 1.

The ``varno-dependent columns`` Section
.......................................

This section contains a list of items defining the mapping of individual varno-dependent ODB columns to groups of ``ioda`` variables. Varno-dependent columns are those storing values dependent not only on the observation location, but also on the observed variable (identified by its *varno*). Typical examples are the columns storing the observed value or estimated observation error. Each item in this list may contain the following keys:

* ``source`` (required): name of the mapped ODB column (e.g. ``initial_obsvalue``) or a member of a bitfield column (e.g. ``datum_event1.duplicate``, indicating the ``duplicate`` member of the ``datum_event1`` column of type *bitfield*);

* ``group name`` (required): name of the group (e.g. ``ObsValue``) containing the ``ioda`` variables storing restrictions of the mapped ODB column to individual *varnos*;

* ``bit index`` (optional): 0-based index of the bit within a bitfield column that should store the values of the mapped member. Will be used by the ODB file writer, currently in development.

* ``varno-to-variable-name mapping`` (required): a list of items defining the mapping between varnos and ``ioda`` variables. Each item in the list may contain the following keys:

  - ``varno`` (required): numeric identifier of a geophysical variable (see https://apps.ecmwf.int/odbgov/varno for the full list);

  - ``name`` (required) name of the corresponding ``ioda`` variable;

  - ``unit`` (optional): name of the unit used in the ODB file; see :ref:`above <varno-independent columns.unit>` for more details.

The ``complementary variables`` section
............................................

This section contains a list of items defining groups of varno-independent ODB text columns that should be merged into single ``ioda`` variables. This merging is required because entries of ODB text columns are limited to 8 characters each. Within each item, the following keys are recognized:

* ``input names`` (required): ordered list of names of ODB columns that should be merged;
* ``output name`` (required): name of the ``ioda`` variable that will hold the contents of the merged columns;
* ``output variable data type`` (optional): if present, must be set to ``string``;
* ``merge method`` (optional): if present, must be set to ``concat``.

Example Mapping File: Detailed Discussion
.........................................

The example YAML file shown above defines the following mappings:

* The ``lat`` and ``lon`` ODB columns are mapped to the ``MetaData/latitude`` and ``MetaData/longitude`` ``ioda`` variables, respectively. For each column, the value of only one row per location is transferred to the corresponding ``ioda`` variable. (The columns are declared to be varno-independent, so by definition it should not matter which of these rows is used.)

* The ``surface`` and ``tropopause_level`` members of the ``level`` bitfield column are mapped to the ``MetaData/surface_level`` and ``MetaData/tropopause_level`` Boolean ``ioda`` variables, respectively. In each case, the value of only one row per location is transferred to the corresponding ``ioda`` variable.

* Elements of the ``initial_obsvalue`` column located in rows storing observations of varnos 29 and 110 are transferred to the ``ObsValue/relative_humidity`` and ``ObsValue/surface_pressure`` ``ioda`` variables. In each case, a unit conversion takes place.

* Elements of the ``initial_obsvalue`` column located in rows storing observations of varno 235 are transferred to the ``MetaData/air_pressure`` ``ioda`` variable.

* Elements of the ``obs_error`` column located in rows storing observations of varnos 29 and 110 are transferred to the ``ObsError/relative_humidity`` and ``ObsError/surface_pressure`` ``ioda`` variables. In each case, a unit conversion takes place.

* Elements of the ``duplicate`` member of the ``datum_event1`` bitfield column located in rows storing observations of varnos 29 and 110 are transferred to the ``DiagnosticFlags/Duplicate/relative_humidity`` and ``DiagnosticFlags/Duplicate/surface_pressure`` Boolean ``ioda`` variables.

* Strings from the ``site_name_1``, ``site_name_2``, ``site_name_3`` and ``site_name_4`` columns are concatenated and transferred to the ``MetaData/station_id`` ``ioda`` variable. Only one row per location is kept.

.. note::

   Certain variables are handled in a special way.  Columns for date and time (``date``, ``time``, ``receipt_date``, ``receipt_time``) are not specified in the mapping file; instead they are converted into the string date/time representations used by ``ioda`` and stored in ``ioda`` variables ``MetaData/datetime`` and ``MetaData/receiptdatetime``.  They still need to be provided in the ``variables`` list in the query file.

Query files
"""""""""""

The following ODB query file

.. code-block:: YAML

    variables:
    - name: date
    - name: time
    - name: receipt_date
    - name: receipt_time
    - name: lat
    - name: lon
    - name: flight_phase
    - name: level.surface_level
    - name: initial_obsvalue
    where:
      varno: [2,111,112]

corresponds to the following SQL query:

.. code-block:: SQL

    SELECT date, time, receipt_date, receipt_time, lat, lon, flight_phase, initial_obsvalue, level.surface_level
    FROM <ODB file name> 
    WHERE (varno = 2 OR varno = 111 OR varno = 112);

This is the query used to retrieve data from the input ODB file. The names of the specified columns are converted to ``ioda`` variable names when the ObsSpace object is constructed.

In general, a query file must contain a ``where`` section with the ``varno`` key set to the list of identifiers of the geophysical variables of interest (see https://apps.ecmwf.int/odbgov/varno for the full list). In addition, it can contain an optional ``variables`` list; the ``name`` key in each item in this list is the name of a column or a bitfield column member to be retrieved from the ODB file. If the mapping file defines mappings for individual members of a bitfield column and the ``variables`` list contains just the name of this column (rather than names of specific members), all members for which mappings exist are retrieved. Finally, an optional ``ignored names`` key can be set to a list of names of ODB columns that should not be mapped to ``ioda`` variables according to the rules defined in the mapping file even if they are loaded from the ODB file for other reasons. By default, this applies to the following columns: ``date``, ``time``, ``receipt_date``, ``receipt_time``, ``entryno``, ``seqno``, ``varno``, ``vertco_type`` and ``ops_obsgroup``.

There are two additional options which are specific to data that are divided into records (e.g. radiosonde and ocean profiles).
If the option ``truncate profiles to numlev`` is set to ``true``, each profile is shortened to have a number of levels equal to the ODB variable ``numlev``,
which varies from profile to profile. This avoids a large number of unnecessary levels being stored in memory. The default value of this parameter is ``false``.
The option ``time displacement variable`` can be used to define an ODB variable (typically ``initial_level_time``) which is added on to the station launch time
to produce a dateTime that varies along a profile. If ``time displacement variable`` is empty (the default) then the dateTimes are not changed in this way.
