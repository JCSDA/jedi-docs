.. _ioda-format-bufr:

BUFR
----

The BUFR backend provides a simple way to extract data from BUFR files (both WMO and NCEP) via simple
queries that point to the specific data elements you might wish to retrieve.

Here is an example of how to define the backend in the IODA YAML configuration file:

.. code-block:: yaml

  time window:
    begin: "2018-04-14T21:00:00Z"
    end: "2023-12-15T03:00:00Z"

  observations:
  - obs space:
      name: "MHS"
      simulated variables: ['radiance']
      obsdatain:
        engine:
          type: bufr
          obsfile: "Data/testinput_tier_1/gdas.t12z.mtiasi.tm00.bufr_d"
          mapping file: "testinput/iodatest_bufr_mtiasi_mapping.yaml"
          table path: "Data/testinput_tier_1/bufr_tables"  # optional (used with WMO BUFR files)
          category: ["metop-c"]  # optional (needed if the BUFR mapping defines splits)
          cache categories:    # optional
            - ["metop-a"]
            - ["metop-b"]
            - ["metop-c"]
      obsdataout:
        engine:
          type: H5File
          obsfile: "testoutput/iodatest_bufr_mtiasi_metop_c.nc"

.. list-table:: BUFR Backend Parameters
   :widths: 20 80
   :header-rows: 1

   * - Parameter
     - Description
   * - **type**
     - The engine type. Must be set to ``bufr``.
   * - **obsfile**
     - Path to the BUFR source file.
   * - **mapping file**
     - Path to the YAML file that defines the mapping between the BUFR file and the IODA ObsGroup.
   * - **table path** (optional)
     - Required if the BUFR file is a WMO file. Path to the directory containing the WMO BUFR tables.
   * - **category** (optional)
     - Required if the BUFR mapping defines splits (multiple categories). The mapping can be split on several elements (not common), so this parameter is a list of strings.
   * - **cache categories** (optional)
     - Used if the BUFR mapping defines splits and you want to cache the data for each category to avoid reading the BUFR file multiple times (which is time consuming). This parameter must include each category you intend to read from the BUFR file, but not more (otherwise you will leak the cache). It is recommended to put it in each ObsSpace that is relevant (copy-paste), though in practice only the first one is used.

BUFR Mapping
~~~~~~~~~~~~

The BUFR mapping file format is defined in the
`BUFR Query <https://bufr-query.readthedocs.io/en/latest/index.html>`_ documentation.
Here is a simple example of a BUFR mapping file for MHS data:

.. code-block:: yaml

   bufr:
     variables:
       timestamp:
         datetime:
           year: "*/YEAR"
           month: "*/MNTH"
           day: "*/DAYS"
           hour: "*/HOUR"
           minute: "*/MINU"
           second: "*/SECO"
       latitude:
         query: "*/CLAT"
       longitude:
         query: "*/CLON"
       brightnessTemp:
         query: "*/BRITCSTC/TMBR"

   encoder:
     dimensions:
       - name: Channel
         paths:
           - "*/BRITCSTC"

     variables:
       - name: "MetaData/dateTime"
         source: variables/timestamp
         longName: "dateTime"
         units: "seconds since 1970-01-01T00:00:00Z"

       - name: "MetaData/latitude"
         source: variables/latitude
         longName: "Latitude"
         units: "degrees_north"
         range: [-90, 90]

       - name: "MetaData/longitude"
         source: variables/longitude
         longName: "Longitude"
         units: "degrees_east"
         range: [-180, 180]

       - name: "ObsValue/brightnessTemperature"
         coordinates: "longitude latitude Channel"
         source: variables/brightnessTemp
         longName: "Brightness Temperature"
         units: "K"

   # ... end of example mapping ...

This example covers only a subset of available mapping options.
For full details, see the BUFR Query documentation:

.. seealso::
   `BUFR Query <https://bufr-query.readthedocs.io/en/latest/index.html>`_


Script Mapping
~~~~~~~~~~~~~~

Another common use case is to read the BUFR files via the script backend. This allows you to modify
the data before it is written to the IODA ObsSpace.

.. seealso::
   `Script Backend <format-script.html>`_
