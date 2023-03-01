.. _DrawValueFromFile:

DrawValueFromFile
=================
The purpose of this obsfunction is to produce values by interpolating an array loaded from a file,
indexed by coordinates whose names correspond to ObsSpace variables.

Values produced by this ObsFunction must be `float`, `int` or `std::string`, though coordinates
themselves can be defined as `float`, `int`, `std::string` or `util::DateTime`.

Note that the return type of the obsfunction is specified in the group name::

    DrawValueFromFile@ObsFunction -> Float return
    DrawValueFromFile@IntObsFunction -> Integer return
    DrawValueFromFile@StringObsFunction -> String return

Example 1 (minimal)
...................
Here is an illustrative example where we derive some new variable in ObsSpace by
extracting data from a CSV file column identified by the :code:`group` option (`DerivedObsValue`
is chosen in the examples below).

.. code-block:: yaml

     - filter: Variable Assignment
       assignments:
       - name: <some-new-variable-name>
         function:
           name: DrawValueFromFile@ObsFunction
           options:
             file: <path-to-input>    # path to the CSV/NetCDF file
             group: DerivedObsValue   # group with the payload variable
             interpolation:
             - name: satellite_id@MetaData
               method: exact

and the CSV file, located at :code:`<path-to-input>`, might look like this:

.. code-block::

   station_id@MetaData,air_temperature@DerivedObsValue
   string,float
   ABC,0.1
   DEF,0.2
   GHI,0.3

The input file is loaded and at each location, the value of `air_temperature@DerivedObsValue` is extracted by

* selecting the row of the CSV file in which the value in the :code:`station_id@MetaData` column
  matches exactly the value of the :code:`station_id@MetaData` ObsSpace variable at that location and
* taking the value of the :code:`air_temperature@DerivedObsValue` column from the selected row.

It is possible to customize this process in several ways by

* making the `air_temperature@DerivedObsValue` dependent on more than one variable (see :ref:`interpolate example 2` below).
* using other interpolation methods than exact match (for example nearest-neighbor match or linear interpolation).
* using a NetCDF rather than a CSV input file via the :code:`file` option.

:code:`options`
...............

* :code:`group`: Group to identify the payload array (array being extracted/interpolated).
  This allows us to hold more than 1 payload per file if we were so inclined as long as each belongs to a different group.
* :code:`channels`: (Optional) List of channel numbers to match from our payload variable.  See :ref:`interpolate example 2` below.
* :code:`file`: Path to an input NetCDF or CSV file. The input file formats are described in more detail below.
* :code:`interpolation`: A list of one or more elements indicating how to map specific ObsSpace
  variables to slices of arrays loaded from the input file. This list is described in more detail below.

.. _DataExtractorInputFileFormats:

Input file formats
..................
Supported file formats (backends) include NetCDF and CSV.  Here we go into a little detail about these
formats, described in detail below.

CSV
!!!

An input CSV file should have the following structure:

* First line: comma-separated column names in ioda-v1 style (:code:`var@Group`) or ioda-v2 style
  (:code:`Group/var`)
* Second line: comma-separated column data types (datetime, float, int or string)
* Further lines: comma-separated data entries.

The number of entries in each line should be the same. The column order does not matter. One of the
columns should belong to the group specified in the :code:`group` option, indicating the payload array.
Its data type should be a :code:`float`, :code:`int`, or :code:`std::string`.
The values from the other columns (sometimes called `coordinates` below) are compared against ObsSpace
variables with the same names to determine the row or rows from which the payload is
extracted at each location. The details of this comparison (e.g. whether an exact match is
required, the nearest match is used, or piecewise linear interpolation is performed) depend on the
:code:`interpolation` option described below.

Notes:

* A column containing channel numbers (which aren't stored in a separate ObsSpace variable)
  should be labelled :code:`channel_number@MetaData` or :code:`MetaData/channel_number`.

* Single underscores serve as placeholders for missing values; for example, the following row

  .. code-block::

     ABC,_,_

  contains missing values in the second and third columns.

NetCDF
!!!!!!

ioda-v1 and ioda-v2-style NetCDF files are supported. ioda-v1-style files should have the
following structure:

* They contain a 1D, 2D or 3D payload array of type :code:`float` or :code:`int` or
  :code:`std::string` with unique group name (that is, a name ending with :code:`@<groupname>`).

* Each dimension of this array should be indexed by at least one 1D coordinate array. Coordinates
  can be of type :code:`float`, :code:`int` or :code:`string`. Datetimes should be represented as
  ISO-8601 strings (e.g. "2001-01-01T00:00:00Z"). Coordinate names should correspond to names of ObsSpace variables. Use the name
  :code:`channel_number@MetaData` for channel numbers (for which there is no dedicated ObsSpace
  variable).

ioda-v2-style files are similar except that

* Our payload array should be placed in the :code:`<groupname>` group (rather than
  with a :code:`@<groupname>` suffix).
* Coordinate variables should be placed in appropriate groups, e.g. :code:`MetaData`. Because
  of the limitations of the NetCDF file format, these variables can only be used as auxiliary
  coordinates of the payload variable (listed in its :code:`coordinates` attribute).


.. _DrawValueFromFileInterpolation:

The :code:`interpolation` option
................................

This list indicates which ObsSpace variables, and in which order, will be used as criteria for the extract step.

Each element of this list should have the following attributes:

* :code:`name`: Name of an ObsSpace variable (and of a coordinate present in the input CSV or NetCDF
  file).
* :code:`method`: Method used to map values of this variable at individual location to matching slices
  of the payload array loaded from the input file. This can be one of:

  - :code:`exact`: Selects slices where the coordinate matches exactly the value of the specified
    ObsSpace variable.

    If no match is found, an error is reported unless there are slices where the indexing
    coordinate is set to the missing value placeholder; in this case these slices are selected
    instead. This can be used to define a fallback value (used if there is no exact match).

    This is the only method that can be used for variables of type :code:`string`.

  - :code:`nearest`: Selects slices where the coordinate is closest to the value of the
    specified ObsSpace variable.

    In case of a tie (e.g. if the value of the ObsSpace variable is 3 and the coordinate contains
    values 2 and 4, but not 3), the smaller of the candidate coordinate values is used (in this
    example, 2).  This behaviour is arbitrarily chosen.

  - :code:`least upper bound`: Select slices corresponding to the least value of the coordinate
    greater than or equal to the value of the specified ObsSpace variable.

  - :code:`greatest upper bound`: Select slices corresponding to the greatest value of the coordinate
    less than or equal to the value of the specified ObsSpace variable.

  - :code:`linear`: Performs a piecewise linear interpolation along the dimension indexed by the
    specified ObsSpace variable.

    This method is supported only for the obs function producing a float (not an int or a string).
    It can only be used for the final indexing variable, since it does not select slices, but
    produces the final result (a single value).

  - :code:`bilinear`: Performs a bilinear interpolation along two dimensions indexed by the ObsSpace
    variables.

    This method is supported only for the obs function producing a float (not an int or a string).
    It can only be used for the final two indexing variables, since it does not select slices, but
    produces the final result (a single value).

  - :code:`trilinear`: Performs a trilinear interpolation along three dimensions indexed by the ObsSpace
    variables.

    This method is supported only for the obs function producing a float (not an int or a string).
    The three interpolation variables must also be floats.

    It is possible to specify log-linear interpolation along each dimension with the option :code:`coordinate transformation: loglinear`. For further context see example 5 below.

  * :code:`extrapolation mode`: Chosen behaviour in the case where an extraction step leads to extrapolation.

    By default (i.e. where no extrapolation is specified), no extrapolation is performed.  That is, an
    exception is thrown where the point being extracted lies beyond the coordinate value range for the
    chosen interpolation algorithm.
    Various extrapolation modes are available, detailed below.

    - :code:`error`: Throw an exception.  This is the default behaviour when extrapolation mode is undefined.

    - :code:`nearest`: Pick nearest index.

    - :code:`missing`: Return a missing value indicator.  Any subsequent extraction stages are then ignored.


At each location the criterion variables specified in the :code:`interpolation` list are inspected
in order, successively restricting the range of selected slices. An error is reported if the end
result is an empty range of slices or (unless linear interpolation is used for the last criterion
variable) a range containing more than one slice.

Note: If the :code:`channels` option has been specified, the channel number is implicitly used as the
first criterion variable and needs to match exactly a value from the :code:`channel_number@MetaData` coordinate.

The following examples illustrate more advanced usage of this obsfunction.

.. _interpolate example 2:

Example 2 (multi-channel)
.........................
Here we illustrate how we might extend our first example by having multiple
channels as well as additional variables over which the payload varies.

.. code-block:: yaml

     - filter: Variable Assignment
       assignments:
       - name: <some-new-variable-name>
         function:
           name: DrawValueFromFile@ObsFunction
           channels: &all_channels 1-3
           options:
             file: <path-to-input>    # path to the CSV/NetCDF file
             channels: *all_channels
             group: DerivedObsValue   # group with the payload variable
             interpolation:
             - name: satellite_id@MetaData
               method: exact
             - name: processing_center@MetaData
               method: exact
             - name: air_pressure@MetaData
               method: linear

Note the channel selection, using standard yaml syntax.  Internally, channel number
extraction is an 'exact' match step, done before any user defined interpolation takes place.
Since there is no channel number variable in ObsSpace, we instead expect input data containing
channel information to be described by the name `channel_number@MetaData` as mentioned in
:ref:`here <DataExtractorInputFileFormats>`.

This might be described by a CSV similar to: ::

    station_id@MetaData,air_pressure@MetaData,channel_number@MetaData,mydata@DerivedObsValue
    string,float,int,float
    ABC,30000,0, 0.1
    ABC,60000,0, 0.2
    ...

Our NetCDF might look something like: ::

    netcdf mydata {
    dimensions:
        index = 10 ;
    variables:
        float mydata@DerivedObsValue(index) ;
        int index(index) ;
        int channel_number@MetaData(index) ;
        int satellite_id@MetaData(index) ;
        float air_pressure@MetaData(index) ;
    ...
    }


Example 3 (extrapolation)
.........................
This time, we demonstrate utilising various extrapolation methods for our extract/interpolation
steps:

.. code-block:: yaml

     - filter: Variable Assignment
       assignments:
       - name: <some-new-variable-name>
         function:
           name: DrawValueFromFile@ObsFunction
           options:
             file: <path-to-input>    # path to the CSV/NetCDF file
             group: DerivedObsValue      # group with the payload variable
             interpolation:
             - name: satellite_id@MetaData
               method: exact
               extrapolation mode: error
             - name: longitude@MetaData
               method: nearest
               extrapolation mode: missing
             - name: latitude@MetaData
               method: nearest
               extrapolation mode: nearest

Example 4 (bilinear interpolation)
..................................
Next we demonstrate the use of bilinear interpolation of two variables:

.. code-block:: yaml

     - filter: Variable Assignment
       assignments:
       - name: <some-new-variable-name>
         function:
           name: DrawValueFromFile@ObsFunction
           options:
             file: <path-to-input>    # path to the CSV/NetCDF file
             group: DerivedObsValue      # group with the payload variable
             interpolation:
             - name: longitude@MetaData
               method: bilinear
             - name: latitude@MetaData
               method: bilinear

Example 5 (trilinear interpolation)
...................................
The following example shows the use of trilinear interpolation of three variables
(latitude, longitude and air pressure). The interpolation is performed log-linearly
in pressure. Any out-of-bounds values are set to the value of the relevant bound
prior to performing the interpolation.

.. code-block:: yaml

     - filter: Variable Assignment
       assignments:
       - name: <some-new-variable-name>
         function:
           name: ObsFunction/DrawValueFromFile
           options:
             file: <path-to-input>    # path to the CSV/NetCDF file
             group: DerivedObsValue      # group with the payload variable
             interpolation:
             - name: MetaData/longitude
               method: trilinear
               extrapolation mode: nearest
             - name: MetaData/latitude
               method: trilinear
               extrapolation mode: nearest
             - name: MetaData/pressure
               method: trilinear
               coordinate transformation: loglinear
               extrapolation mode: nearest
