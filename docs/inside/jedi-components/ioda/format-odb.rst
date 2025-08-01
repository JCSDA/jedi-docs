.. _ioda-format-odb:

ODB
---

.. note::

   To be able to read ODB files, ``ioda`` needs to be built in an environment providing access to ECMWF's ``odc`` library. All of the development containers (Intel, GNU and Clang) include this library.

Reading ODB files
^^^^^^^^^^^^^^^^^^

To read an ODB file into an ``ObsSpace``, four options need to be set in the ``obs space.obsdatain.engine`` section of the YAML configuration file:

* ``type``: ODB
* ``obsfile``: the path to the ODB file;
* ``mapping file``: the path to a YAML file mapping ODB column names and units to IODA variable names;
* ``query file``: the path to a YAML file defining the parameters of an SQL query selecting the required data from the ODB file.
* ``time window extended lower bound``: Extended lower bound of time window (datetime in ISO-8601 format).
  This is an optional parameter which, if set, must be a dateTime equal to or earlier than the start of the assimilation window.
  Observations which lie between this lower bound and the start of the assimilation window have their dateTime set
  equal to the start of the assimilation window. This ensures that the observation will be accepted by the time
  window cutoff that is applied in oops. The original value of the datetime is stored in :code:`MetaData/initialDateTime` if
  the unmodified dateTime needs to be accessed.

The syntax of the mapping and query files is described in the subsections below. The ``ioda`` repository contains sample mapping and query files that should be sufficient for most needs. The mapping file ``test/testinput/odb_default_name_map.yml`` is used when reading most observation types; a small number of observation types, such as radiosonde observations, need to be processed with separate mapping files, e.g. ``test/testinput/odb_sonde_name_map.yml``. There is also one query file per observation type, e.g. ``test/testinput/iodatest_odb_aircraft.yml`` for aircraft observations and ``test/testinput/iodatest_odb_atms.yml`` for ATMS observations. For example, a YAML file used for aircraft data processing could contain the following ``obs space.obsdatain`` section:

.. code-block:: YAML

    obs space:
      obsdatain:
        engine:
          type: ODB
          obsfile: Data/testinput_tier_1/aircraft.odb
          mapping file: testinput/odb_aircraft_name_map.yaml
          query file: testinput/iodatest_odb_aircraft.yaml

Writing ODB files
^^^^^^^^^^^^^^^^^^

To write an ``ObsSpace`` into an ODB file, four options need to be set in the ``obs space.obsdataout.engine`` section of the YAML configuration file.
These are the same four options as the read method, namely ``type``, ``obsfile``, ``mapping file`` and ``query file`` which are detailed in the read section. The ``type`` will
be ``ODB`` and the obsfile specifies the path to the output file. The ODB file produced is a series of columns all of length ``Location`` multiplied by the number of varno's.
For varno's with a channel dimension this is multiplied by the length of ``Channel``. As an example if varno 119 and 110 are requested then there would be ``Location`` multiplied by
``Channel`` rows for varno 119, which is ``brightnessTemperature``, and an additional ``Location`` number of rows for varno 110, which is ``surfacePressure``. If there were 10 locations
and varno 119 had 7 channels the total length of each column would be :math:`\left ( 10\times7 \right ) + 10 = 80`.

The mapping file provides the mapping between the ODB column name and the variable name in the ``ObsSpace``. The mapping file also specifies whether the variable is varno dependent or not.
A varno dependent variable will provide the group which the data is stored in e.g. ``ObsValue`` and the varno specifies what name the variable has e.g. varno 119 maps to an ioda variable
name of ``brightnessTemperature``. For a varno independent variable the full path e.g. ``MetaData/stationIdentifier`` will be specified in the mapping file. The query file lists the
ODB column names that are to be written out to the file. This will be a subset of the data in the ``ObsSpace`` and all variables that the user wishes to output are required
in the query file. If a variable is requested in the ``query file`` but it is not in the ``ObsSpace`` a message is written to the log but the code does not fail. If a query variable
is requested and there is no variable matching that name in the ``mapping file`` the code will throw an exception.

The syntax of the mapping and query files is described in the subsections below. The ``ioda`` repository contains sample mapping and query files that should be
sufficient for most needs. Most observation types use the default name map, ``..share/test/testinput/odb_default_name_map.yaml``. There are separate query files for each observation type,
e.g. ``..share/test/testinput/iodatest_odb_aircraft.yaml`` for aircraft observations and ``..share/test/testinput/iodatest_odb_atms.yaml`` for ATMS observations.
For example, a YAML file used for aircraft data processing could contain the following ``obs space.obsdataout`` section:

.. code-block:: YAML

    obs space:
      obsdataout:
        engine:
          type: ODB
          obsfile: testoutput/aircraft_out.odb
          mapping file: ..share/test/testinput/odb_default_name_map.yaml
          query file: ..share/test/testinput/iodatest_odb_aircraft.yaml

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

A mapping file may contain up to two top-level sections: ``varno-independent columns``, ``varno-dependent columns``. Both are optional but will typically be present. The syntax of each section is described below, followed by a detailed explanation of the mappings defined in the above YAML file.

The ``varno-independent columns`` Section
.........................................

This section contains a list of items defining the mapping of individual varno-independent ODB columns to ``ioda`` variables. Varno-independent columns are those storing values dependent on the observation location, but not on the observed variable (identified by its *varno*). They include most metadata, such as latitude, longitude or station ID. Each item in this list may contain the following keys:

* ``source`` (required): name of the mapped ODB column (e.g. ``lat``) or a member of a bitfield column (e.g. ``level.surface``, indicating the ``surface`` member of the ``level`` column of type *bitfield*).

* ``name`` (required): full name of the corresponding ``ioda`` variable (e.g. ``MetaData/latitude``).

.. _varno-independent columns.unit:

* ``unit`` (optional): name of the unit used in the ODB file. If specified, values loaded from the ODB file will be converted to the unit used in ``ioda`` (typically a basic SI unit). Currently the following units are supported: ``celsius``, ``knot``, ``percentage`` (converted to a fraction), ``okta`` (1/8 -- converted to a fraction), ``degree`` (converted to radians) and ``hectopascal`` (converted to pascals).

* ``bit index`` (optional): 0-based index of the bit within a bitfield column that should store the values of the mapped member. Will be used by the ODB file writer, currently in development.

  .. note::
  
     Bitfield ODB columns can either be mapped in their entirety to a single integer ``ioda`` variable  or be split into multiple Boolean ``ioda`` variables, each storing the value of a single member. In the latter case, it is not necessary to map each member to a ``ioda`` variable: some may be omitted, as illustrated for the ``level`` column in the YAML snippet above, which contains no mapping for the ``standard_level`` member stored in bit 1.

* ``multichannel`` (optional): true if the ``ioda`` variable should have a channel dimension, false (default) otherwise.

* ``mode`` (optional): ``read`` or ``write`` for mappings relevant only when reading or writing ODB files. By default, mappings are used both when reading and writing ODB files.

.. _varno-independent columns.reader:

* ``reader`` (optional): the value of the ``type`` key in this YAML section influences which ODB rows associated with a given location serve as the source of values stored at the corresponding location in the ``ioda`` variable specified in the ``name`` key. The ``type`` key can be set to 

  - ``from rows with non-missing values`` if the values stored in the variable at each location should be taken from the first *n* ODB rows associated with that location and containing non-missing values, where *n* is the number of channels for variables with a channel dimension and 1 for ones without. If at a given location there are less than *n* such rows, the unfilled channels are set to the missing value indicator.
 
  - ``from rows with matching varnos`` if the values stored in the variable at each location should be taken successively from ODB rows associated with that location and containing the first varno in the list assigned to the ``varnos`` key in the ``reader`` section, then ones containing the second varno in the list, and so on. If the total number of rows with these varnos is less than the number of channels (or 1 for variables without a channel dimension), the unfilled channels are set to the missing value indicator.

  If the ``reader`` section is missing, the reader specified in the ``default reader`` key in the query file is used; and if that key is missing as well, the ``from rows with non-missing values`` strategy is used.
  
  Example:
  
  .. code-block:: YAML
  
     varno-independent columns:
     - name: "OneDVar/emissivity"
       source: "emissivity_onedvar"
       multichannel: true
       reader:
         type: from rows with matching varnos
         varnos: [119]
   
  .. note::
  
     The set of reader types is extensible. New readers can be added by subclassing the  ``ioda::Engines::ODC::VariableReaderBase`` interface and registering the subclass in the ``VariableReaderBaseFactory``.
  
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

  - ``auxiliary varnos`` (optional): a list of varnos that should be mapped to the specified ``ioda`` variable in addition to the one assigned to the ``varno`` key. This is used, for instance, for AMSR, for which the ``brightnessTemperature`` ``ioda`` variable receives values loaded both from rows with varno 119 (``rawbt``, i.e. *brightness temperature*) and 267 (``rawbt_amsr_89ghz``, i.e. *brightness temperature specific to AMSR 89GHz channels*).

.. note:: 
   
   Variables created from varno-dependent columns are always filled with values extracted from rows selected with the ``from rows with matching varnos`` strategy (see :ref:`above <varno-independent columns.reader>` for more details).
  
Example Mapping File: Detailed Discussion
.........................................

The example YAML file shown above defines the following mappings:

* The ``lat`` and ``lon`` ODB columns are mapped to the ``MetaData/latitude`` and ``MetaData/longitude`` ``ioda`` variables, respectively. For each column, the value of only one row per location is transferred to the corresponding ``ioda`` variable. (The columns are declared to be varno-independent, so by definition it should not matter which of these rows is used.)

* The ``surface`` and ``tropopause_level`` members of the ``level`` bitfield column are mapped to the ``MetaData/surface_level`` and ``MetaData/tropopause_level`` Boolean ``ioda`` variables, respectively. In each case, the value of only one row per location is transferred to the corresponding ``ioda`` variable.

* Elements of the ``initial_obsvalue`` column located in rows storing observations of varnos 29 and 110 are transferred to the ``ObsValue/relative_humidity`` and ``ObsValue/surface_pressure`` ``ioda`` variables. In each case, a unit conversion takes place.

* Elements of the ``initial_obsvalue`` column located in rows storing observations of varno 235 are transferred to the ``MetaData/air_pressure`` ``ioda`` variable.

* Elements of the ``obs_error`` column located in rows storing observations of varnos 29 and 110 are transferred to the ``ObsError/relative_humidity`` and ``ObsError/surface_pressure`` ``ioda`` variables. In each case, a unit conversion takes place.

* Elements of the ``duplicate`` member of the ``datum_event1`` bitfield column located in rows storing observations of varnos 29 and 110 are transferred to the ``DiagnosticFlags/Duplicate/relative_humidity`` and ``DiagnosticFlags/Duplicate/surface_pressure`` Boolean ``ioda`` variables.

.. note::

   Certain variables are handled in a special way.  Columns for date and time (``date``, ``time``, ``receipt_date``, ``receipt_time``) are not specified in the mapping file; instead they are converted into the date/time representations used by ``ioda`` and stored in ``ioda`` variables ``MetaData/dateTime`` and ``MetaData/receiptdateTime``.  They still need to be provided in the ``variables`` list in the query file.

.. note:: 

   Entries of ODB text columns are limited to 8 characters each; longer strings need to be split across multiple *complementary columns*. By convention, their names are constructed by appending an underscore and a numeric suffix to the column name that would be used if all strings were at most 8 characters in length; for example, ``site_name_1``, ``site_name_2`` and so on. The ODB writer automatically stores the contents of ``ioda`` variables of type ``string`` in as many complementary columns as necessary; likewise, the ODB reader automatically identifies complementary columns and concatenates their contents into individual ``ioda`` variables. This process is transparent to the user and does not need to be configured explicitly in mapping or query YAML files.

Query files
^^^^^^^^^^^

Query files serve two purposes. First, they define the query used to retrieve data from an input ODB file, or the list of columns to be written back to an output ODB file. Second, they make it possible to customize some observation-type-specific aspects of the conversion between ODB columns and ``ioda`` variables.

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

This is the query used to retrieve data from the input ODB file. The names of the specified columns (or bitfield column members) are converted to ``ioda`` variable names when the ObsSpace object is constructed.

In general, a query file must contain a ``where`` section with the ``varno`` key set to the list of identifiers of the geophysical variables of interest (see https://apps.ecmwf.int/odbgov/varno for the full list). In addition, it needs to contain a ``variables`` list; the ``name`` key in each item in this list is the name of a column or a bitfield column member to be retrieved from the ODB file. If the mapping file defines mappings for individual members of a bitfield column and the ``variables`` list contains just the name of this column (rather than names of specific members), all members for which mappings exist are retrieved.

The ``where`` section may contain an optional ``query`` key whose value will be appended to the SQL query. The example below shows how this can be used to filter out rows containing invalid dates:

.. code-block:: YAML

   where:
     varno: [1,2,224]
     query: (year(date) != 0) AND (month(date) != 0) AND (day(date) != 0)

The ``where`` and ``variables`` sections may be complemented by a number of optional sections and keywords described below.

Rows to locations mapping
.........................

The ``method`` key in the ``rows into locations split`` section specifies the method used to split the data loaded from the input ODB file into groups of rows associated with distinct JEDI locations. The following methods are currently available:

* ``by seqno`` (suitable for most observation types and used by default, i.e. when the ``rows into locations split`` section is absent): The data are split into groups of consecutive rows with the same value in the ``seqno`` column. Optionally, if the ``maximum number of channels`` key in the ``rows into locations split`` section is set to a positive value, these groups are split further until none of them contains more than ``maximum number of channels`` rows with the same ``varno``. Each of the resulting groups of rows is associated with a different location.

  For example, if the following data are loaded from an ODB file,
 
  === ===== =====
  row seqno varno
  === ===== =====
  0   1     2
  1   1     6
  2   1     2
  3   1     6
  4   2     6
  5   2     6
  6   2     6
  7   2     2
  8   2     2
  9   2     2
  === ===== =====
 
  and the ``maximum number of channels`` option is not set, the rows will be assigned to the following locations:

  === ========
  row location
  === ========
  0   0
  1   0
  2   0
  3   0
  4   1
  5   1
  6   1
  7   1
  8   1
  9   1
  === ======== 
  
  If the ``maximum number of channels`` option is set to 2, the assignment will be different:
 
  === ========
  row location
  === ========
  0   0
  1   0
  2   0
  3   0
  4   1
  5   1
  6   2
  7   1
  8   1
  9   2
  === ========    
  
  .. note::
  
     The ``maximum number of channels`` option is intended for use with GNSSRO data where it is desired to treat these observations as profiles (thus altering how tangent-point drift is accounted for).
     This parameter must be set to zero (the default) if the data are read into a 1D variable, and a number greater than zero if the data are read into a 2D variable.
     In the 2D case, any profiles which are not a multiple of ``maximum number of channels`` in length will be padded with missing data.   Unless the typical length of a profile is known, fewer missing values will be used when the value of ``maximum number of channels`` is smaller.
     However, using ``maximum number of channels`` greater than one decreases the number of locations in the data, which decreases the number of geovals used.  Since geovals typically dominate the memory used by JEDI decreasing the number of locations decreases the overall amount of memory used.
     On the other hand, those geovals will not be at the correct location for all the observations, so this decreases the accuracy of the calculated `H(x)`.  Therefore choosing an appropriate value for ``maximum number of channels`` will be a balance between accuracy and memory usage.

* ``by seqno, then by the counter of rows with a given varno`` (suitable for data divided into records, such as radiosonde, ocean sound and GNSS-RO profiles): The data are first split into groups of consecutive rows with the same value in the ``seqno`` column. Then all rows in which a particular varno occurs for the nth time in a given group are put in a separate subgroup, and each of these subgroups of rows is associated with a different location.

  For example, given the following data loaded from an ODB file,

  === ===== =====
  row seqno varno
  === ===== =====
  0   1     2
  1   1     6
  2   1     2
  3   1     6
  4   2     6
  5   2     6
  6   2     6
  7   2     2
  8   2     2
  9   2     2
  === ===== =====  
    
  the rows will be assigned to the following locations:
  
  === ========
  row location
  === ========
  0   0
  1   0
  2   1
  3   1
  4   2
  5   3
  6   4
  7   2
  8   3
  9   4
  === ========
  
  Optionally, if the ``keep only reported levels`` key in the ``rows into locations split`` section is set to true and the number of locations associated with a group of consecutive rows with the same ``seqno`` exceeds the number *n* read from the ``numlev`` column in the first row in that group, only the first *n* locations will be kept, and the rest will be discarded.

  Example:

  .. code-block:: YAML

      rows into locations split:
        method: by seqno, then by the counter of rows with a given varno
        keep only reported levels: true

.. note::
  
  The set of methods that can be used to map rows to locations is extensible. New methods can be added by subclassing the  ``ioda::Engines::ODC::RowsIntoLocationsSplitterBase`` interface and registering the subclass in the ``RowsIntoLocationsSplitterBaseFactory``.
  
.. _ioda-format-odb-channel-indices:

Channel indices  
...............

If the data associated with any varnos should be extracted into variables with a channel dimension, the ``multichannel varnos`` key needs to be set to the list of these varnos.

In that case the ``channel indexing`` section must also be present. The ``method`` key in that section specifies the method used to assign channel indices. 

The following methods are currently available:


* ``sequential``: Assign sequential channel indices starting from the number specified in the ``first channel index`` key (by default, 1). By default, the number of channels is determined by counting rows associated with the first location and containing any of the varnos specified in the ``varnos`` key or, if that key is absent, the varno read from the first row associated with that location. Alternatively, if the number of channels is fixed and known in advance, it can be specified in the ``number of channels`` key. Example:
    
  .. code-block:: YAML

     # AMSR: varnos 119 and 267 combined into a single 'brightnessTemperature' variable
     multichannel varnos: [119, 267]
     # Sequential channel indices starting from the default value of 1, with the number 
     # of channels equal to the number of rows with varno 119 or 267 at the first location
     channel indexing:
       method: sequential
       varnos: [119, 267]
     
* ``read from first location``: Read channel indices from the column specified in the ``column`` key (by default, ``initial_vertco_reference``) and rows associated with the first location and containing the varno specified in the ``varno`` key or, if that key is absent, the varno read from the first row associated with that location. Example:

  .. code-block:: YAML

    multichannel varnos: [119, 233]
    channel indexing:
      method: read from first location      
      column: vertco_reference_1
      varno: 119
    
* ``constant``: Assign the same index to all channels. By default, the index is 0; this can be overridden through the ``channel index`` key. The number of channels is determined by counting rows associated with the first location and containing any of the varnos specified in the ``varnos`` key or, if that key is absent, the varno read from the first row associated with that location. Example: 
  
  .. code-block:: YAML

     multichannel varnos: [266]
     channel indexing:
         method: constant
         channel index: 1
         varnos: [266]
         
* ``read from yaml``: Read channel indices from a comma-separated string ``channel numbers`` passed in from the odb query file, ``channel numbers`` is a required parameter of this method. Hyphens may be used to denote a channel range. The channel dimension is created under the DerivedObsValue group from a string independent of the input data (in order to index ObsValue by channel, ``multichannel varnos`` is required). Example: 
  
  .. code-block:: YAML
  
     where:
         varno: [233]
     channel indexing:
         method: read from yaml
         channel numbers: 1, 3, 97, 156-159, 230

  
.. note::
  
  The set of channel indexing methods is extensible. New methods can be added by subclassing the ``ioda::Engines::ODC::ChannelIndexerBase`` interface and registering the subclass in the ``ChannelIndexerFactory``.
    
Post-read transforms
....................

The ``post-read transforms`` option may be set to a list of items defining transforms to be applied to variables read from an ODB file before passing them to an ObsSpace. Such transforms are typically used to combine multiple ``ioda`` variables storing data loaded from individual ODB columns into a single variable.

A single transform is currently available:

* ``create stationIdentification``: Fills an existing ``ioda`` variable (by default, ``MetaData/stationIdentification``, but this can be overridden in the ``destination`` key) with station IDs extracted from one of the sources listed in the ``sources`` key. At each location, the sources are inspected in order and the station ID is constructed from the first source that contains non-missing values. Three kinds of sources are supported:

  - ``ioda`` variables of type ``string``

  - ``ioda`` variables of type ``int``; these are converted into strings and optionally padded from the left with zeros or spaces to a specified width
  
  - pairs of ``ioda`` variables of type ``int`` containing WMO block and station numbers; these are converted into 5-digit WMO identifiers.  
  
  If at a given location all sources contains missing values, but the destination variable is non-empty, its value is preserved. If it is empty, it is set to the missing-value indicator for strings, i.e. ``MISSING*``.
  
  The following example illustrates how this transform is used to construct station IDs for surface observations:

  .. code-block:: YAML
  
    post-read transforms:
    - name: create stationIdentification
        sources:
        # If the MetaData/buoyIdentifier variable exists and contains a non-missing value, 
        # convert its value to a string and pad with zeros from the left to the width of 
        # 7 characters.
        - variable:
            name: MetaData/buoyIdentifier
            width: 7
            pad with zeros: true  # the default is padding with spaces
        # Otherwise, if the MetaData/wmoBlockNumber and MetaData/wmoStationNumber variables
        # exist and contain non-missing values, build a station ID of the form BBSSS, where 
        # BB is the two-digit block number and SSS the three-digit station number.
        - wmo id:
            block number: MetaData/wmoBlockNumber
            station number: MetaData/wmoStationNumber
        # Otherwise, if the initial value stored in MetaData/stationIdentification is non-empty,
        # preserve it. Otherwise, set the station ID to 'MISSING*'.
  
.. note::
  
  The set of post-read transforms is extensible. New transforms can be added by subclassing the ``ioda::Engines::ODC::ObsGroupTransformBase`` interface and registering the subclass in the ``ObsGroupTransformFactory``.

.. note::

  Variables whose names start with a double underscore are automatically deleted after applying the post-read transforms. Therefore if a transform's input variables are not needed after that transform has been applied, it is recommended to prefix their names with a double underscore to reduce the amount of memory taken by the ObsSpace.
  
Miscellaneous options
.....................

There are a few other options that can be set in the query file:

* ``epoch``: the epoch to use for DateTime variables; by default, ``seconds since 1970-01-01T00:00:00Z``.

* ``missingInt64``: the missing value indicator used for variables of type ``int64``; by default, ``-9223372036854775806``.

* ``time displacement variable``: the name of an ODB column (typically ``initial_level_time``) which is added on to the station launch time to produce a dateTime that varies along a profile. If ``time displacement variable`` is empty (the default) then the dateTimes are not changed in this way.

* ``default reader``: configuration of the default method of selecting rows from which values of variables mapped to varno-independent columns should be extracted. See :ref:`above <varno-independent columns.reader>` for more details. If this option is not set, the ``from rows with non-missing values`` strategy is used.

* ``skip variables corresponding to missing varnos``: should be set to ``false`` if variables should be created also for varnos present in the query but absent from the ODB file. By default such variables are not created.

* ``record grouping columns``: the list of ODB columns used to group consecutive rows into records that should not be split across multiple MPI processes if the ODB file is read in parallel. See :ref:`reading_odb_files_in_parallel` for more details and an example.
