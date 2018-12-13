JEDI Configuration Files
========================

Overview and Format
---------------------

Configuration files are files that control the execution of specific applications.  They specify input parameters, control flags, file names, tolerance thresholds, and other configuration details that are used by JEDI to run tests, forecasts, DA, and other applications.

Configuration files for most JEDI tests are located in the :code:`test/testinput` directory of each JEDI repository.  The configuration files in the :code:`ufo`, :code:`ioda`, and :code:`fv3-jedi` repositories are particularly useful as illustrative examples for constructing configuration files in other repositories.

Configuration (often abbreviated as config) files in JEDI may be written either in `YAML <https://yaml.org>`_ or in `JSON <https://www.json.org>`_;  JEDI uses the parser from ECMWF's `eckit library <https://github.com/ecmwf/eckit>`_ to read these files and this parser can process both formats.  However, we recommend using **YAML** because it is generally more user-friendly; YAML is easier to read and, unlike JSON, it allows the user to include comments.

As an example, consider the configuration file for the :code:`test_ufo_radiosonde_opr` unit test (also used for several other tests), which is located in the :code:`ufo` repository as :code:`test/testinput/radiosonde.yaml`:

.. code:: yaml

    ---
    test_framework_runtime_config: "--log_level=test_suite"
    window_begin: '2018-04-14T21:00:00Z'
    window_end: '2018-04-15T03:00:00Z'
    LinearObsOpTest:
      testiterTL: 12
      toleranceTL: 1.0e-9
      toleranceAD: 1.0e-11
    Observations:
      ObsTypes:
      - ObsType: Radiosonde
        ObsData:
          ObsDataIn:
            obsfile: Data/sondes_obs_2018041500_m.nc4
          ObsDataOut:
            obsfile: Data/sondes_obs_2018041500_m_out.nc4
        variables:
        - air_temperature
        - eastward_wind
        - northward_wind
        GeoVaLs:
          norm: 8471.883687854357
          random: 0
          filename: Data/sondes_geoval_2018041500_m.nc4
          window_begin: '2018-04-14T21:00:00Z'
          window_end: '2018-04-15T03:00:00Z'
        ObsFilters:
        - Filter: Background Check
          variable: air_temperature
          threshold: 3.0
        rmsequiv: 118.81431
        tolerance: 1.0e-03  # in % so that corresponds to 10^-5
        ObsBias: {}

We refer the user to the `YAML Documentation <https://yaml.org/spec/1.2/spec.html>`_ for a comprehensive description of the syntax but we'll give a brief overview here.

The first thing to note is that indentation matters.  Items are organized into a heirarchy, with the top-level objects beginning in the leftmost column and subsidiary components of these objects indented accordingly.  The number of spaces is not important; two is sufficient to define the scope of an item and its contents.

The beginning of a YAML document is indicated by three dashes :code:`---`, which may or may not be preceded by directives.  Each line typically contains a key-value pair separated by a colon and a space.  The key is generally a string and the value may be either a string or a number.  This is used to assign values to variables.  For example, the **window_begin** object is set to a value of '2018-04-14T21:00:00Z' and the **LinearObsOpTest.toleranceTL** variable is set to a value of 1.0e-9.  Note that we have used a period to represent the heirarchy of items; **toleranceTL** is a component of **LinearObsOpTest**.  Note also that the values may be interpreted in different ways.  For example, the **window_begin** value is written as a string in the yaml file but it is interpreted as a :code:`util::DateTime` object when it is read into JEDI.

Objects with muliple values (sequences in YAML) are indicated as indended lists with one item per line and each item delineated by a dash.  For example, **Observations.ObsTypes.Radiosonde.variables** is equated to a list of items, namely ["air_temperature", "eastward_wind", "northward_wind"].  Comments are preceded by a :code:`#` sign as seen for **Observations.ObsTypes.Radiosonde.tolerance**.

Lists or sequences may also be identified with brackets :code:`{}`.  This is illustrated in the above file with the example of **Observations.ObsTypes.Radiosonde.ObsBias**, which is here identified as a list, albeit an empty one.

C++ Usage
-----------

As noted above, JEDI configuration files are read by means of the `eckit C++ library <https://github.com/ecmwf/eckit>`_ developed and distributed by the European Centre for Medium Range Weather Forecasting (ECMWF).  ECMWF also offers a Fotran interface to eckit called `fckit <https://github.com/ecmwf/fckit>`_.

Configuration files are read into JEDI as :code:`eckit::Configuration` objects.  The :code:`eckit::Configuration` class includes a number of public methods that can be used to query config files and access their contents.

To illustrate how this occurs, let's return to our :code:`test_ufo_radiosonde_opr` example introduced in the previous section.

Fortran Usage
---------------

`fckit <https://github.com/ecmwf/fckit>`_ offers much of the same functionality for accessing configuration files and objects as eckit.  It accomplishes this by means of Fortran interfaces to public C++ methods of :code:`eckit::Configuration` and :code:`eckit::LocalConfiguration` objects.

