.. _top-ioda-file-formats:

IODA File Formats
=================

Overview
--------

IODA can read files in the following formats:

* HDF5
* ODB

and write files in the following formats:

* HDF5.

The following sections describe how these formats are handled from the user's point of view.

HDF5
----

To read an HDF5 file into an ``ObsSpace``, it is enough to set the ``obs space.obsdatain.obsfile`` option in the YAML configuration file to the HDF5 file path. For example,

.. code-block:: YAML

    obs space:
      obsdatain:
        obsfile: Data/testinput_tier_1/sondes_obs_2018041500_m.nc4

Similarly, to write the contents of an ``ObsSpace`` to disk at the end of the observation processing pipeline, use the ``obs space.obsdataout.obsfile`` option:

.. code-block:: YAML

    obs space:
      obsdataout:
        obsfile: obsfile: Data/sondes_obs_2018041500_m_out.nc4

Each MPI rank will then write its observations to a separate file with the name obtained by inserting the rank before the extension of the file name taken from the ``obs space.obsdataout.obsfile`` option. In the example above, processes 0 and 1 would produce files called ``Data/sondes_obs_2018041500_m_out_0000.nc4`` and ``Data/sondes_obs_2018041500_m_out_0001.nc4``, respectively (assuming observations were split across ranks only in space; if they were split also in time, file names would have an extra suffix with the index of the time partition).

ODB
---

.. note::

   To be able to read ODB files, ``ioda`` needs to be built in an environment providing access to ECMWF's ``odc`` library. All of the development containers (Intel, GNU and Clang) include this library.

To read an ODB file into an ``ObsSpace``, three options need to be set in the ``obs space.obsdatain`` section of the YAML configuration file:

* ``obsfile``: the path to the ODB file;
* ``mapping file``: the path to a YAML file mapping ODB column names and units to IODA variable names;
* ``query file``: the path to a YAML file defining the parameters of an SQL query selecting the required data from the ODB file.

The syntax of the mapping and query files is described in the subsections below. The ``ioda`` repository contains sample mapping and query files that should be sufficient for most needs. There is a single mapping file, ``test/testinput/odb_default_name_map.yml``, and one query file per observation type, e.g. ``test/testinput/iodatest_odb_aircraft.yml`` for aircraft observations and ``test/testinput/iodatest_odb_atms.yml`` for ATMS observations. For example, a YAML file used for aircraft data processing could contain the following ``obs space.obsdatain`` section:

.. code-block:: YAML

    obs space:
      obsdatain:
        obsfile: Data/testinput_tier_1/aircraft.odb
        mapping file: testinput/odb_default_name_map.yml
        query file: testinput/iodatest_odb_aircraft.yml

Mapping files
"""""""""""""

Here's an example ODB mapping file:

.. code-block:: YAML

    ioda:
      variables:
      - name: MetaData/latitude
        source: lat
      - name: MetaData/longitude
        source: lon
      - name: ObsValue/relative_humidity
        source: 29
        unit: percentage
      - name: ObsValue/surface_pressure
        source: 110
        unit: hectopascal
      complementary variables:
      - input names: [site_name_1, site_name_2, site_name_3, site_name_4]
        output name: MetaData/station_id

The top-level section ``ioda`` is required. The ``ioda.variables`` section is optional (but typically needed); if present, it must be a list of items defining the mapping of individual ODB columns to ``ioda`` variables. Within each item, the following keys are recognized:

* ``source`` (required): name of an ODB column or numeric identifier of a geophysical variable (see https://apps.ecmwf.int/odbgov/varno for the full list);

* ``name`` (required): name of the corresponding ``ioda`` variable;

* ``unit`` (optional): name of the unit used in the ODB file. If specified, values loaded from the ODB file will be converted to the unit used in ``ioda`` (typically a basic SI unit). Currently the following units are supported: ``celsius``, ``knot``, ``percentage`` (converted to a fraction), ``okta`` (1/8 -- converted to a fraction), ``degree`` (converted to radians) and ``hectopascal`` (converted to pascals).

The ``ioda.complementary variables`` section is also optional; if present, it must be a list of items defining groups of ODB text columns that should be merged into single ``ioda`` variables. This merging is required because entries of ODB text columns are limited to 8 characters each. Within each item, the following keys are recognized:

* ``input names`` (required): ordered list of names of ODB columns that should be merged;
* ``output name`` (required): name of the ``ioda`` variable that will hold the contents of the merged columns;
* ``output variable data type`` (optional): if present, must be set to ``string``;
* ``merge method`` (optional): if present, must be set to ``concat``.

Certain variables are handled in a special way.  Columns for date and time (``date``, ``time``, ``receipt_date``, ``receipt_time``) are not specified in the mapping file; instead they are converted into the string date/time representations used by ``ioda`` and stored in ``ioda`` variables ``MetaData/datetime`` and ``MetaData/receiptdatetime``.  They still need to be provided in the ``variables`` list in the query file.

Query files
"""""""""""

The following ODB query file

.. code-block:: YAML

    variables:
    - name: lat
    - name: lon
    - name: flight_phase
    - name: initial_obsvalue
    - name: varno
    where:
      varno: [2,111,112]

corresponds to the following SQL query:

.. code-block:: SQL

    SELECT lat, lon, flight_phase, initial_obsvalue, varno 
    FROM <ODB file name> 
    WHERE (varno = 2 OR varno = 111 OR varno = 112);

This is the query used to retrieve data from the input ODB file. The names of the specified columns are converted to ``ioda`` variable names when the ObsSpace object is constructed.

In general, a query file must contain a ``where`` section with the ``varno`` key set to the list of identifiers of the geophysical variables of interest (see https://apps.ecmwf.int/odbgov/varno for the full list). In addition, it can contain an optional ``variables`` list; the ``name`` key in each item in this list is the name of a column to be retrieved from the ODB file.
