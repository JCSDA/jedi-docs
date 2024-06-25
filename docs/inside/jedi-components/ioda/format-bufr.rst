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
          table path: "Data/testinput_tier_1/bufr_tables"  # optional (needed when reading WMO BUFR files)
          category: ["metop-c"]  # optional (needed if the BUFR mapping defines splits)
          cache categories:      # optional
            - ["metop-a"]
            - ["metop-b"]
            - ["metop-c"]
      obsdataout:
        engine:
          type: H5File
          obsfile: "testoutput/iodatest_bufr_mtiasi_metop_c.nc"

Here are the parameters needed to define the BUFR backend:

  * **type**: The engine type must be defined as **bufr**.
  * **obsFile**: The path to the BUFR source file.
  * **mapping file**: The path to the YAML file that defines the mapping between the BUFR file and the IODA ObsGroup.
  * **table path**: *(optional)* required if the BUFR file is a WMO file. The path to the directory that contains the
    WMO BUFR tables.
  * **category**: *(optional)* required if the BUFR mapping defines splits (multiple categories). The mapping can be
    split on several elements (not common) which is why the **category** parameter is a list of strings.
  * **cache categories**: *(optional)* Used if the BUFR mapping defines splits and you want to cache the data for each
    category so you don't end up reading the BUFR file multiple times (time consuming). The **cache categories**
    parameter must include each category you intend to read from the BUFR file but not more (otherwise you will leak the
    cache). It is recommended to put it in each ObsSpace that is relevant (copy paste) though in practice it only uses
    the first one it finds.

BUFR-Query
~~~~~~~~~~

Please refer to the following documentation to learn more about the BUFR backend:
`BUFR Query <https://bufr-query.readthedocs.io/en/latest/index.html>`_
