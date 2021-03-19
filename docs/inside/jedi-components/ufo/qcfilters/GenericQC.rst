Generic QC Filters
==================

This section describes how to configure each of the existing QC filters in UFO. All filters can also use the :ref:`"where" statement <where-statement>` to act only on observations meeting certain conditions. By default, each filter acts on all the variables marked as *simulated variables* in the ObsSpace. The :code:`filter variables` keyword can be used to limit the action of the filter to a subset of these variables or to specific channels, as shown in the examples from the :ref:`Bounds Check Filter <bounds-check-filter>` section below.

.. _bounds-check-filter:

Bounds Check Filter
-------------------

This filter rejects observations whose values (:code:`@ObsValue` in the ioda files) lie outside specified limits:

.. code-block:: yaml

   - filter: Bounds Check
     filter variables:
     - name: brightness_temperature
       channels: 4-6
     minvalue: 240.0
     maxvalue: 300.0

In the above example the filter checks if brightness temperature for channels 4, 5 and 6 is outside of the [240, 300] range. Suppose we have the following observation data with 3 locations and 4 channels:

* channel 3: [100, 250, 450]
* channel 4: [250, 260, 270]
* channel 5: [200, 250, 270]
* channel 6: [340, 200, 250]

In this example, all observations from channel 3 will pass QC because the filter isn't configured to act on this channel. All observations for channel 4 will pass QC because they are within [minvalue, maxvalue]. 1st observation in channel 5, and first and second observations in channel 6 will be rejected.

.. code-block:: yaml

   - filter: Bounds Check
     filter variables:
     - name: air_temperature
     minvalue: 230
   - filter: Bounds Check
     filter variables:
     - name: eastward_wind
     - name: northward_wind
     minvalue: -40
     maxvalue:  40

In the above example two filters are configured, one testing temperature, and the other testing wind components. The first filter would reject all temperature observations that are below 230. The second, all wind component observations whose magnitude is above 40.

In practice, one would be more likely to want to filter out wind component observations based on the value of the wind speed :code:`sqrt(eastward_wind**2 + northward_wind**2)`. This can be done using the :code:`test variables` keyword, which rejects observations of a variable if the value of *another* lies outside specified bounds. The "test variable" does not need to be a simulated variable; in particular, it can be an :ref:`ObsFunction <obs-function-and-obs-diagnostic-suffixes>`, i.e. a quantity derived from simulated variables. For example, the following snippet filters out wind component observations if the wind speed is above 40:

.. code-block:: yaml

   - filter: Bounds Check
     filter variables:
     - name: eastward_wind
     - name: northward_wind
     test variables:
     - name: Velocity@ObsFunction
     maxvalue: 40

If there is only one entry in the :code:`test variables` list, the same criterion is applied to all filter variables. Otherwise the number of test variables needs to match that of filter variables, and each filter variable is filtered according to the values of the corresponding test variable.

Background Check Filter
-----------------------

This filter checks for bias corrected distance between observation value and model simulated value (:math:`y-H(x)`) and rejects obs where the absolute difference is larger than :code:`absolute threshold` or :code:`threshold` * sigma_o when the filter action is set to :code:`reject`. This filter can also adjust observation error through a constant inflation factor when the filter action is set to :code:`inflate error`. If no action section is included in the yaml, the filter is set to reject the flagged observations.

.. code-block:: yaml

   - filter: Background Check
     filter variables:
     - name: air_temperature
     threshold: 2.0
     absolute threshold: 1.0
     action:
       name: reject
   - filter: Background Check
     filter variables:
     - name: eastward_wind
     - name: northward_wind
     threshold: 2.0
     where:
     - variable:
         name: latitude@MetaData
       minvalue: -60.0
       maxvalue: 60.0
     action:
       name: inflate error
       inflation: 2.0

The first filter would flag temperature observations where abs((y+bias)-H(x)) > min ( absolute_threshold, threshold * sigma_o), and
then the flagged data are rejected due to filter action is set to reject.

The second filter would flag wind component observations where abs((y+bias)-H(x)) > threshold * sigma_o and latitude of the observation location are within 60 degree. The flagged data will then be inflated with a factor 2.0.

Please see the :ref:`Filter Actions <filter-actions>` section for more detail.

Domain Check Filter
-------------------

This filter retains all observations selected by the :ref:`"where" statement <where-statement>` and rejects all others. Below, the filter is configured to retain only observations
* taken at locations where the sea surface temperature retrieved from the model is between 200 and 300 K (inclusive)
* with valid :code:`height` metadata (not set to "missing value")
* taken by stations with IDs 3, 6 or belonging to the range 11-120
* without valid :code:`air_pressure` metadata.

.. code-block:: yaml

   - filter: Domain Check
     where:
     - variable:
         name: sea_surface_temperature@GeoVaLs
       minvalue: 200
       maxvalue: 300
     - variable:
         name: height@MetaData
       is_defined:
     - variable:
         name: station_id@MetaData
       is_in: 3, 6, 11-120
     - variable:
         name: air_pressure@MetaData
       is_not_defined:

BlackList Filter
----------------

This filter behaves like the exact opposite of Domain Check: it rejects all observations selected by the :ref:`"where" statement <where-statement>` statement and retains all others. Below, the filter is configured to reject observations taken by stations with IDs 1, 7 or belonging to the range 100-199:

.. code-block:: yaml

   - filter: BlackList
     where:
     - variable:
         name: station_id@MetaData
       is_in: 1, 7, 100-199

Thinning Filter
---------------

This filter rejects a specified fraction of observations, selected at random. It supports the following YAML parameters:

- :code:`amount`: the fraction of observations to reject (a number between 0 and 1).
- :code:`random seed` (optional): an integer used to initialize a random number generator if it has not been initialized yet. If not set, the seed is derived from the calendar time.

Note: because of how this filter is implemented, the fraction of rejected observations may not be exactly equal to :code:`amount`, especially if the total number of observations is small.

Example:

.. code-block:: yaml

  - filter: Thinning
    amount: 0.75
    random seed: 125

Gaussian Thinning Filter
------------------------

This filter thins observations by preserving only one observation in each cell of a grid. Cell assignment can be based on an arbitrary combination of:

- horizontal position
- vertical position (in terms of air pressure)
- time
- category (arbitrary integer associated with each observation).

Selection of the observation to preserve in each cell is based on

- its position in the cell
- optionally, its priority.

The following YAML parameters are supported:

- Horizontal grid:

  * :code:`horizontal_mesh`: Approximate width (in km) of zonal bands into which the
    Earth's surface is split. Thinning in the horizontal direction is disabled if
    this parameter is negative. Default: approx. 111 km (= 1 deg of latitude).

  * :code:`use_reduced_horizontal_grid`: True to use a reduced grid, with high-latitude
    zonal bands split into fewer cells than low-latitude bands to keep cell size nearly uniform.
    False to use a regular grid, with the same number of cells at all latitudes. Default: :code:`true`.

  * :code:`round_horizontal_bin_count_to_nearest`:
    True to set the number of zonal bands so that the band width is as close as possible to
    :code:`horizontal_mesh`, and the number of cells ("bins") in each zonal band so that the
    cell width in the zonal direction is as close as possible to that in the meridional direction.
    False to set the number of zonal bands so that the band width is as small as possible, but
    no smaller than :code:`horizontal_mesh`, and the cell width in the zonal direction is as small as
    possible, but no smaller than in the meridional direction. Default: :code:`false`.

- Vertical grid:

  * :code:`vertical_mesh`: Cell size (in Pa) in the vertical direction.
    Thinning in the vertical direction is disabled
    if this parameter is not specified or negative.

  * :code:`vertical_min`: Lower bound of the pressure interval split into cells of size
    :code:`vertical_mesh`. Default: 100 Pa.

  * :code:`vertical_max`: Upper bound of the pressure interval split into cells of size
    :code:`vertical_mesh`. This parameter is rounded upwards to the nearest multiple of
    :code:`vertical_mesh` starting from :code:`vertical_min`. Default: 110,000 Pa.

- Temporal grid:

  * :code:`time_mesh`: Cell size in the temporal direction.
    Temporal thinning is disabled if this this parameter is not specified or set to 0.

  * :code:`time_min`: Lower bound of the time interval split into cells of size :code:`time_mesh`.
    Temporal thinning is disabled if this parameter is not specified.

  * :code:`time_max`: Upper bound of the time interval split into cells of size :code:`time_mesh`.
    This parameter is rounded upwards to the nearest multiple of :code:`time_mesh` starting from
    :code:`time_min`. Temporal thinning is disabled if this parameter is not specified.

- Observation categories:

  * :code:`category_variable`: Variable storing integer-valued IDs associated with observations.
    Observations belonging to different categories are thinned separately.

- Selection of observations to retain:

  * :code:`priority_variable`: Variable storing observation priorities.
    Among all observations in a cell, only those with the highest priority are considered
    as candidates for retaining. If not specified, all observations are assumed to have equal priority.

  * :code:`distance_norm`: Determines which of the highest-priority observations lying in a cell
    is retained. Allowed values:

    + :code:`geodesic`: retain the observation closest to the cell center in the horizontal direction
      (air pressure and time are ignored when selecting the observation to retain)

    + :code:`maximum`: retain the observation lying furthest from the cell's bounding box in the
      system of coordinates in which the cell is a unit cube (all dimensions along which thinning
      is enabled are taken into account).

    Default: :code:`geodesic`.

Example 1 (thinning by the horizontal position only):

.. code-block:: yaml

    - filter: Gaussian Thinning
      horizontal_mesh:   1111.949266 #km = 10 deg at equator

Example 2 (thinning observations from multiple categories and with non-equal priorities by their horizontal position, pressure and time):

.. code-block:: yaml

    - filter: Gaussian Thinning
      distance_norm:     maximum
      horizontal_mesh:   5000
      vertical_mesh:    10000
      time_mesh: PT01H
      time_min: 2018-04-14T21:00:00Z
      time_max: 2018-04-15T03:00:00Z
      category_variable:
        name: instrument_id@MetaData
      priority_variable:
        name: priority@MetaData

Temporal Thinning Filter
------------------------

This filter thins observations so that the retained ones are sufficiently separated in time. It supports
the following YAML parameters:

* :code:`min_spacing`:  Minimum spacing between two successive retained observations. Default: :code:`PT1H`.

* :code:`seed_time`: If not set, the thinning filter will consider observations as candidates for retaining
  in chronological order.

  If set, the filter will start from the observation taken as close as possible to :code:`seed_time`,
  then consider all successive observations in chronological order, and finally all preceding
  observations in reverse chronological order.

* :code:`category_variable`: Variable storing integer-valued IDs associated with observations.
  Observations belonging to different categories are thinned separately. If not specified, all
  observations are thinned together.

* :code:`priority_variable`: Variable storing integer-valued observation priorities.
  If not specified, all observations are assumed to have equal priority.

* :code:`tolerance`: Only relevant if :code:`priority_variable` is set.

  If set to a nonzero duration, then whenever an observation *O* lying at least :code:`min_spacing`
  from the previous retained observation *O'* is found, the filter will inspect all observations
  lying no more than :code:`tolerance` further from *O'* and retain the one with the highest priority.
  In case of ties, observations closer to *O'* are preferred.

Example 1 (selecting at most one observation taken by each station per 1.5 h,
starting from the observation closest to seed time):

.. code-block:: yaml

    - filter: Temporal Thinning
      min_spacing: PT01H30M
      seed_time: 2018-04-15T00:00:00Z
      category_variable:
        name: call_sign@MetaData

Example 2 (selecting at most one observation taken by each station per 1 h,
starting from the earliest observation, and allowing the filter to retain an observation
taken up to 20 min after the first qualifying observation if its quality score is higher):

.. code-block:: yaml

    - filter: Temporal Thinning
      min_spacing: PT01H
      tolerance: PT20M
      category_variable:
        name: call_sign@MetaData
      priority_variable:
        name: score@MetaData

Difference Check Filter
-----------------------

This filter will compare the difference between a reference variable and a second variable and assign a QC flag if the difference is outside of a prescribed range.

For example:

.. code-block:: yaml

   - filter: Difference Check
     reference: brightness_temperature_8@ObsValue
     value: brightness_temperature_9@ObsValue
     minvalue: 0

The above YAML is checking the difference between :code:`brightness_temperature_9@ObsValue` and :code:`brightness_temperature_8@ObsValue` and rejecting negative values.

In psuedo-code form:
:code:`if (brightness_temperature_9@ObsValue - brightness_temperature_8@ObsValue < minvalue) reject_obs()`

The options for YAML include:
 - :code:`minvalue`: the minimum value the difference :code:`value - reference` can be. Set this to 0, for example, and all negative differences will be rejected.
 - :code:`maxvalue`: the maximum value the difference :code:`value - reference` can be. Set this to 0, for example, and all positive differences will be rejected.
 - :code:`threshold`: the absolute value the difference :code:`value - reference` can be (sign independent). Set this to 10, for example, and all differences outside of the range from -10 to 10 will be rejected.

Note that :code:`threshold` supersedes :code:`minvalue` and :code:`maxvalue` in the filter.

Derivative Check Filter
-----------------------

This filter will compute a local derivative over each observation record and assign a QC flag if the derivative is outside of a prescribed range.

By default, this filter will compute the local derivative at each point in a record.
 - For the first location (1) in a record:
   :code:`dy/dx = (y(2)-y(1))/(x(2)-x(1))`
 - For the last location (n) in a record:
   :code:`dy/dx = (y(n)-y(n-1))/(x(n)-x(n-1))`
 - For all other locations (i):
   :code:`dy/dx = (y(i+1)-y(i-1))/(x(i+1)-x(i-1))`

Alternatively if one wishes to use a specific range/slope for the entire observation record, :code:`i1` and :code:`i2` can be defined in the YAML.
For this case, For all locations in the record:
:code:`dy/dx = (y(i2)-y(i1))/(x(i2)-x(i1))`

Note that this filter really only works/makes sense for observations that have been sorted by the independent variable and grouped by some other field.

An example:

.. code-block:: yaml

   - filter: Derivative Check
     independent: datetime
     dependent: air_pressure
     minvalue: -50
     maxvalue: 0
     passedBenchmark:  238      # number of passed obs

The above YAML is checking the derivative of :code:`air_pressure` with respect to :code:`datetime` for a radiosonde profile and rejecting observations where the derivative is positive or less than -50 Pa/sec.

The options for YAML include:
 - :code:`independent`: the name of the independent variable (:code:`dx`)
 - :code:`dependent`: the name of the dependent variable (:code:`dy`)
 - :code:`minvalue`: the minimum value the derivative can be without the observations being rejected
 - :code:`maxvalue`: the maximum value the derivative can be without the observations being rejected
 - :code:`i1`: the index of the first observation location in the record to use
 - :code:`i2`: the index of the last observation location in the record to use

A special case exists for when the independent variable is 'distance', meaning the dx is computed from the difference of latitude/longitude pairs converted to distance.
 Additionally, when the independent variable is 'datetime' and the dependent variable is set to 'distance', the derivative filter becomes a speed filter, removing moving observations when the horizontal speed is outside of some range.

Track Check Filter
------------------

This filter checks tracks of mobile weather stations, rejecting observations inconsistent with the
rest of the track.

Each track is checked separately. The algorithm performs a series of sweeps over the
observations from each track. For each observation, multiple estimates of the instantaneous
speed and (optionally) ascent/descent rate are obtained by comparing the reported position with the
positions reported during a number a nearby (earlier and later) observations that haven't been
rejected in previous sweeps. An observation is rejected if a certain fraction of these
estimates lie outside the valid range. Sweeps continue until one of them fails to reject any
observations, i.e. the set of retained observations is self-consistent.

Note that this filter was originally written with aircraft observations in mind. However, it can
potentially be useful also for other observation types.

The following YAML parameters are supported:

- :code:`temporal_resolution`: Assumed temporal resolution of the observations,
  i.e. absolute accuracy of the reported observation times. Default: PT1M.

- :code:`spatial_resolution`: Assumed spatial resolution of the observations (in km),
  i.e. absolute accuracy of the reported positions.

  Instantaneous speeds are estimated conservatively with the formula

  speed_estimate = (reported_distance - spatial_resolution) / (reported_time + temporal_resolution).

  The default spatial resolution is 1 km.

- :code:`num_distinct_buddies_per_direction`, :code:`distinct_buddy_resolution_multiplier`:
  Control the size of the set of observations against which each observation is compared.

  Let O_i (i = 1, ..., N) be the observations from a particular track ordered chronologically.
  Each observation O_i is compared against *m* observations immediately preceding it and
  *n* observations immediately following it. The number *m* is chosen so that
  {O_{i-m}, ..., O_{i-1}} is the shortest sequence of observations preceding O_i that contains
  :code:`num_distinct_buddies_per_direction` observations *distinct* from O_i that have not yet
  been rejected. Two observations taken at times *t* and *t*' and locations *x* and *x*'
  are deemed to be distinct if the following conditions are met:

  - \|t' - t| > :code:`distinct_buddy_resolution_multiplier` * :code:`temporal_resolution`

  - \|x' - x| > :code:`distinct_buddy_resolution_multiplier` * :code:`spatial_resolution`

  Similarly, the number *n* is chosen so that {O_{i+1}, ..., O_{i+n)} is the shortest sequence
  of observations following O_i that contains :code:`num_distinct_buddies_per_direction`
  observations distinct from O_i that have not yet been rejected.

  Both parameters default to 3.

- :code:`max_climb_rate`: Maximum allowed rate of ascent and descent (in Pa/s).
  If not specified, climb rate checks are disabled.

- :code:`max_speed_interpolation_points`: Encoding of the function mapping air pressure
  (in Pa) to the maximum speed (in m/s) considered to be realistic.

  The function is taken to be a linear interpolation of a series of (pressure, speed) points.
  The pressures and speeds at these points should be specified as keys and values of a
  JSON-style map. Owing to a bug in the eckit YAML parser, the keys must be enclosed in quotes.
  For example,
  ::

    max_speed_interpolation_points: { "0": 900, "100000": 100 }

  encodes a linear function equal to 900 m/s at 0 Pa and 100 m/s at 100000 Pa.

- :code:`rejection_threshold`: Maximum fraction of climb rate or speed estimates obtained by
  comparison with other observations that are allowed to fall outside the allowed ranges before
  an observation is rejected. Default: 0.5.

- :code:`station_id_variable`: Variable storing string- or integer-valued station IDs.
  Observations taken by each station are checked separately.

  If not set and observations were grouped into records when the observation space was
  constructed, each record is assumed to consist of observations taken by a separate
  station. If not set and observations were not grouped into records, all observations are
  assumed to have been taken by a single station.

  Note: the variable used to group observations into records can be set with the
  :code:`ObsSpace.ObsDataIn.obsgrouping.group_variable` YAML option.

Example:

.. code-block:: yaml

   - filter: Track Check
     temporal_resolution: PT30S
     spatial_resolution: 20 # km
     num_distinct_buddies_per_direction: 3
     distinct_buddy_resolution_multiplier: 3
     max_climb_rate: 200 # Pa/s
     max_speed_interpolation_points: {"0": 1000, "20000": 400, "110000": 200} # Pa: m/s
     rejection_threshold: 0.5
     station_id_variable: station_id@MetaData
  


Met Office Buddy Check Filter
-----------------------------

This filter cross-checks observations taken at nearby locations against each other, updating their gross error probabilities (PGEs) and rejecting observations whose PGE exceeds a threshold specified in the filter parameters. For example, if an observation has a very different value than several other observations taken at nearby locations and times, it is likely to be grossly in error, so its PGE is increased. PGEs obtained in this way can be taken into account during variational data assimilation to reduce the weight attached to unreliable observations without necessarily rejecting them outright.

The YAML parameters supported by this filter are listed below.

- General parameters:

  - :code:`filter variables` (a standard parameter supported by all filters): List of the variables to be checked. Currently only surface (single-level) variables are supported. Variables can be either scalar or vector (with two Cartesian components, such as the eastward and northward wind components). In the latter case the two components need to be specified one after the other in the :code:`filter variables` list, with the first component having the :code:`first_component_of_two` option set to true. Example:

    .. code:: yaml

      filter variables:
      - name: air_temperature
      - name: eastward_wind
        options:
          first_component_of_two: true
      - name: northward_wind

  - :code:`rejection_threshold`: Observations will be rejected if the gross error probability lies at or above this threshold. Default: 0.5.

  - :code:`traced_boxes`: A list of quadrangles bounded by two meridians and two parallels. Tracing information (potentially useful for debugging) will be output for observations lying within any of these quadrangles. Example:

    .. code:: yaml

      traced_boxes:
        - min_latitude: 30
          max_latitude: 45
          min_longitude: -180
          max_longitude: -150
        - min_latitude: -45
          max_latitude: -30
          min_longitude: -180
          max_longitude: -150

    Default: empty list.

- Buddy pair identification:

  - :code:`search_radius`: Maximum distance between two observations that may be classified as buddies, in km. Default: 100 km.

  - :code:`station_id_variable`: Variable storing string- or integer-valued station IDs.

    If not set and observations were grouped into records when the observation space was constructed, each record is assumed to consist of observations taken by a separate station. If not set and observations were not grouped into records, all observations are assumed to have been taken by a single station.

    Note: the variable used to group observations into records can be set with the
    :code:`obs space.obsdatain.obsgrouping.group_variable` YAML option. An example of its use can be found in the :ref:`Profile consistency checks <profconcheck_filtervars>` section above.

  - :code:`num_zonal_bands`: Number of zonal bands to split the Earth's surface into when building a search data structure.

    Note: Apart from the impact on the speed of buddy identification, both this parameter and :code:`sort_by_pressure` affect the order in which observations are processed and thus the final estimates of gross error probabilities, since the probability updates made when checking individual observation pairs are not commutative.

    Default: 24.

  - :code:`sort_by_pressure`: Whether to include pressure in the sorting criteria used when building a search data structure, in addition to longitude, latitude and time. See the note next to :code:`num_zonal_bands`. Default: false.

  - :code:`max_total_num_buddies`: Maximum total number of buddies of any observation.

    Note: In the context of this parameter, :code:`max_num_buddies_from_single_band` and :code:`max_num_buddies_with_same_station_id`, the number of buddies of any observation *O* is understood as the number of buddy pairs (*O*, *O*') where *O*' != *O*. This definition facilitates the buddy check implementation (and makes it compatible with the original version from the OPS system), but is an underestimate of the true number of buddies, since it doesn't take into account pairs of the form (*O*', *O*).

    Default: 15.

  - :code:`max_num_buddies_from_single_band`: Maximum number of buddies of any observation belonging to a single zonal band. See the note next to :code:`max_total_num_buddies`. Default: 10.

  - :code:`max_num_buddies_with_same_station_id`: Maximum number of buddies of any observation sharing that observation's station ID. See the note next to :code:`max_total_num_buddies`. Default: 5.

  - :code:`use_legacy_buddy_collector`: Set to true to identify pairs of buddy observations using an algorithm reproducing exactly the algorithm used in Met Office's OPS system, but potentially skipping some valid buddy pairs. Default: false.

- Control of gross error probability updates:

  - :code:`horizontal_correlation_scale`: Encoding of the function that maps the latitude (in degrees) to the horizontal correlation scale (in km).

    The function is taken to be a piecewise linear interpolation of a series of (latitude, scale) points. The latitudes and scales at these points should be specified as keys and values of a JSON-style map. Owing to a limitation in the eckit YAML parser (https://github.com/ecmwf/eckit/pull/21), the keys must be enclosed in quotes. For example,

    .. code:: yaml

      horizontal_correlation_scale: { "-90": 200, "90": 100 }

    encodes a function varying linearly from 200 km at the south pole to 100 km at the north pole.

    Default: :code:`{ "-90": 100, "90": 100 }`, i.e. a constant function equal to 100 km everywhere.

  - :code:`temporal_correlation_scale`: Temporal correlation scale. Default: PT6H.

  - :code:`damping_factor_1` Parameter used to "damp" gross error probability updates using method 1 described in section 3.8 of the OPS Scientific Documentation Paper 2 to make the buddy check better-behaved in data-dense areas. See the reference above for the full description. Default: 1.0.

  - :code:`damping_factor_2` Parameter used to "damp" gross error probability updates using method 2 described in section 3.8 of the OPS Scientific Documentation Paper 2 to make the buddy check better-behaved in data-dense areas. See the reference above for the full description. Default: 1.0.

Example:

.. code:: yaml

  - filter: Met Office Buddy Check:
    filter variables:
    - name: eastward_wind
      options:
        first_component_of_two: true
    - name: northward_wind
    - name: air_temperature
    rejection_threshold: 0.5
    traced_boxes: # trace all observations
      - min_latitude: -90
        max_latitude:  90
        min_longitude: -180
        max_longitude:  180
    search_radius: 100 # km
    station_id_variable:
      name: station_id@MetaData
    num_zonal_bands: 24
    sort_by_pressure: false
    max_total_num_buddies: 15
    max_num_buddies_from_single_band: 10
    max_num_buddies_with_same_station_id: 5
    use_legacy_buddy_collector: false
    horizontal_correlation_scale: { "-90": 100, "90": 100 }
    temporal_correlation_scale: PT6H
    damping_factor_1: 1.0
    damping_factor_2: 1.0

Implementation Notes
^^^^^^^^^^^^^^^^^^^^

The implementation of this filter consists of four steps: sorting, buddy pair identification, PGE update and observation flagging. Observations are grouped into zonal bands and sorted by (a) band index, (b) longitude, (c) latitude, in descending order, (d) pressure (if the :code:`sort_by_pressure` option is on), and (e) datetime. Observations are then iterated over, and for each observation a number of nearby observations (lying no further than :code:`search_radius`) are identified as its buddies. The size and "diversity" of the list of buddy pairs can be controlled with the :code:`max_total_num_buddies`, :code:`max_num_buddies_from_single_band` and :code:`max_num_buddies_with_same_station_id` options. Subsequently, the PGEs of the observations forming each buddy pair are updated. Typically, the PGEs are decreased if the signs of the innovations agree and increased if they disagree. The magnitude of this change depends on the background error correlation between the two observation locations, the error estimates of the observations and background values, and the prior PGEs of the observations: the PGE change is the larger, the stronger the correlation between the background errors and the narrower the error margins. Once all buddy pairs have been processed, observations whose PGEs exceed the specified :code:`rejection_threshold` are flagged.


Variable Assignment Filter
--------------------------

This "filter" (it is not a true filter; rather, a "processing step") assigns specified values to
specified variables at locations selected by the :code:`where` statement, or at all locations if
the :code:`where` keyword is not present.

The values can be constants or vectors generated by ObsFunctions. If the variables don't exist
yet, they are created; in this case locations not selected by the :code:`where` statement are
initialized with missing-value markers.

The values assigned to individual variables are specified in the :code:`assignments` list in the
YAML file. Each element of this list can contain the following options:

- :code:`name`: Name of the variable to which new values should be assigned.

- :code:`channels`: (Optional) Set of channels to which new values should be assigned.

- :code:`value`: Value to be assigned to the specified variable. Either this option or
  :code:`function` (but not both) must be present.

- :code:`function`: Variable (typically an ObsFunction) that should be evaluated and assigned to
  the specified variable. Either this option or :code:`value` (but not both) must be present.

- :code:`type`: Type (:code:`int`, :code:`float`, :code:`string` or :code:`datetime`) of the
  variable to which new values should be assigned. This option only needs to be provided if the
  variable doesn't exist yet. If this option is provided and the variable already exists, its type
  must match the value of this option, otherwise an exception is thrown.

Example 1
^^^^^^^^^
    
Create new variables :code:`air_temperature@GrossErrorProbability` and
:code:`relative_humidity@GrossErrorProbability` and set them to 0.1 at all locations.

.. code:: yaml
    
    - filter: Variable Assignment
        assignments:
        - name: air_temperature@GrossErrorProbability
        type: float  # type must be specified if the variable doesn't already exist
        value: 0.1
        - name: relative_humidity@GrossErrorProbability
        type: float
        value: 0.1
    
Example 2
^^^^^^^^^

Set :code:`air_temperature@GrossErrorProbability` to 0.05 at all locations in the tropics.

.. code:: yaml
    
    - filter: Variable Assignment
        where:
        - variable:
            name: latitude@MetaData
        minvalue: -30
        maxvalue:  30
        assignments:
        - name: air_temperature@GrossErrorProbability
        value: 0.05
    
Example 3
^^^^^^^^^

Set :code:`relative_humidity@GrossErrorProbability` to values computed by an ObsFunction
(0.1 in the southern extratropics and 0.05 in the northern extratropics, with a linear
transition in between).

.. code:: yaml
    
    - filter: Variable Assignment
        assignments:
        - name: relative_humidity@GrossErrorProbability
        function:
            name: ObsErrorModelRamp@ObsFunction
            options:
            xvar:
                name: latitude@MetaData
            x0: [-30]
            x1: [30]
            err0: [0.1]
            err1: [0.05]
    
RTTOV 1D-Var Check (RTTOVOneDVar) Filter
----------------------------------------

This filter performs a 1-dimensional variational assimilation (1D-Var) that produces optimal retrievals of physical parameters that describe the atmosphere and surface and on which there is information in the measurement. It takes as input a set of observations (brightness temperatures) and model background fields which are used to initialise the retrieval profile.  A retrieval (or analysis) is performed using an iterative procedure that attempts to find the minimum of a cost function that represents the most likely profile vector given the error characteristics of the two data sources.

The elements contained in the retrieval profile depend on the sensitivity of the measuring instruments to atmospheric and surface properties and also what can be modelled with a relatively high degree of accuracy. Most retrieval profiles will consist of atmospheric temperature and humidity, and surface skin temperature, with other possible constituents being liquid and ice water or some other cloud parameter measure, and emissivity parameters.

The filter provides some retrieval parameters to the assimilation which may be missing in the background or insufficiently accurate, such as surface skin temperature, and to filter out observations for which a retrieval could not be performed and thus may be difficult to assimilate in the full variational assimilation.

The filter is a port of the Met Office OPS 1D-Var and makes use of the Fortran RTTOV interface within JEDI.  The code is written predominantly in Fortran.  Files containing the observation error covariance (R) and the background error covariance (B) are expected as inputs.

This filter requires the following YAML parameters:

* :code:`BMatrix`:  path to the b-matrix file.
* :code:`RMatrix`:  path to the r-matrix file.
* :code:`nlevels`:  the number of levels used in the retrieval profile.
* :code:`retrieval variables`:  list of retrieval variables (e.g. temperature etc) which form the 1D-Var retrieval vector (x).  This needs to match the b-matrix file.
* :code:`ModOptions`: options needed for the observation operator (RTTOV only at the moment).
* :code:`filter variables`:  list of variables (brightness_temperature) and channels which form the 1D-Var observation vector (y).

The following are optional YAML parameters with appropriate defaults:

* :code:`ModName`:  forward model name (only RTTOV at the moment). Default: :code:`RTTOV`.
* :code:`qtotal`:  flag for total humidity (qt = q + qclw + qi). If this is true the b-matrix must include qt or the code will abort. If this is false then the b-matrix must not contain qt or the code will abort. Default: :code:`false`.
* :code:`UseMLMinimization`:  flag to turn on Marquardt-Levenberg minimizer otherwise a Newton minimizer is used Default: :code:`false`.
* :code:`UseJforConvergence`:  flag to use J for the measure of convergence. Default is comparison of the profile absolute differences to background error multiplied by :code:`ConvergenceFactor`. Default: :code:`false`.
* :code:`UseRHwaterForQC`:  flag to use liquid water in the q saturation calculations. Default: :code:`true`.
* :code:`FullDiagnostics`:  flag to turn on full diagnostics. Default: :code:`false`.
* :code:`Max1DVarIterations`:  maximum number of iterations. Default: :code:`7`.
* :code:`JConvergenceOption`:  integer to select convergence option.  1 equals percentage change in cost tested between iterations.  Otherwise the absolute change in cost is tested between iterations. Default: :code:`1`.
* :code:`IterNumForLWPCheck`:  choose which iteration to start checking the liquid water path. Default: :code:`2`.
* :code:`MaxMLIterations`:  the maximum number of iterations for the internal Marquardt-Levenberg loop. Default: :code:`7`.
* :code:`ConvergenceFactor`:  cost factor used when the absolute difference in the profile is used to determine convergence. Default: :code:`0.4`.
* :code:`CostConvergenceFactor`:  the cost threshold used for convergence check when cost function value is used for convergence. Default: :code:`0.01`.
* :code:`EmissLandDefault`:  the default emissivity value to use over land. Default: :code:`0.95`.
* :code:`EmissSeaIceDefault`:  the default emissivity value to use over seaice. Default: :code:`0.92`.

Example:

.. code:: yaml
    
    - filter: RTTOV OneDVar Check
        BMatrix: ../resources/bmatrix/rttov/atms_bmatrix_70_test.dat
        RMatrix: ../resources/rmatrix/rttov/atms_noaa_20_rmatrix_test.nc4
        nlevels: 70
        retrieval variables:
        - air_temperature
        - specific_humidity
        - mass_content_of_cloud_liquid_water_in_atmosphere_layer
        - mass_content_of_cloud_ice_in_atmosphere_layer
        - surface_temperature
        - specific_humidity_at_two_meters_above_surface
        - skin_temperature
        - air_pressure_at_two_meters_above_surface
        ModOptions:
        Absorbers: [Water_vapour, CLW, CIW]
        obs options:
            RTTOV_default_opts: OPS
            SatRad_compatibility: false # done in filter
            Sensor_ID: noaa_20_atms
            CoefficientPath: Data/
        filter variables:
        - name: brightness_temperature
        channels: 1-22
        qtotal: true
    
    
   