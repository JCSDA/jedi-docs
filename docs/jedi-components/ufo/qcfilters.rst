.. _top-ufo-qc:

Quality Control in UFO
======================

OOPS Observation Processing Flow
--------------------------------

Observations can be used in different ways in OOPS-JEDI. In variational data assimilation,
the initial computation of the observation term of the cost function (J\ :sub:`o`) is where
most of the quality control takes place.

The flow of this computation in OOPS is as follows:

.. code:: yaml  
  
  CostFunction::evaluate
    CostJo::initialize
      ObsFilters::ObsFilters
      Observer::Observer
        ObsOperator::variables
        ObsFilters::requiredGeoVaLs
    CostFunction::runNL
      Model::forecast
        Observer::initialize
          GeoVaLs::GeoVaLs
        loop over time steps
          Observer::process
            State::getValues
        end loop over time steps
        Observer::finalize
          ObsFilters::priorFilter
          ObsOperator::simulateObs
          ObsFilters::postFilter
    CostJo::finalize
      ObsErrors::ObsErrors
      ydep=ysimul-yobs

This needs more explanation here. Just before and just after calling the :code:`simulateObs`
method, the :code:`Observer` calls the :code:`ObsFilters` :code:`priorFilter` and
:code:`postFilter` methods. The observation filters are very generic and can perform a
number of tasks, but mostly they are used for quality control.

Observation Filters
-------------------

Observation filters are generic and have access to:
 - Observation values and metadata
 - Model values at observations locations (GeoVaLs)
 - Simulated observation value (for post-filter)
 - Their own private data

Filters are written once and used with many observation types
Several generic filters already exist
Entirely controlled from yaml configuration file(s)
More generic filters will be developed to cover most needs

Creating a new Filter
---------------------

If your observation operator is different from the above, you may need to create a new
filter. Typically, all the files for a new filter are in :code:`ufo/src/ufo/filters`.

When writing a new filter, consider using the :code:`Parameter` and :code:`OptionalParameter` 
class templates to automate extraction of filter parameters from YAML files. See the
:ref:`Parameter-classes` section for more information.

Filter tests
------------

All observation filters tests in UFO use the OOPS ObsFilters test from
:code:`oops/src/test/base/ObsFilters.h`.

Generic QC Filters implemented in UFO
=====================================

There are a number of exisiting generic filters in the UFO.
Below is the description of how to configure each of the existing QC filters in UFO. All filters also can use "where" statement, with syntax described in the last section on this page.

Bounds Check Filter
------------------------------

This filter checks if the observation values (@ObsValue in the ioda files) is within specified limits and rejects observations outside of this limit (only for the specified observations):

.. code:: yaml

   - Filter: Bounds Check
     variables: [brightness_temperature]
     channels: 4-6
     minvalue: 240.0
     maxvalue: 300.0

In the above example the filter checks if brightness temperature for channels 4, 5 and 6 is outside of [240, 300] range. Suppose we have the following observation data with 3 locations and 4 channels:
channel 3: [100, 250, 450]
channel 4: [250, 260, 270]
channel 5: [200, 250, 270]
channel 6: [340, 200, 250]
In this example, all observations from channel 3 will pass QC because channel 3 isn't configured in this filter. All observations for channel 4 will pass QC because they are within [minvalue, maxvalue]. 1st observation in channel 5, and first and second observations in channel 6 will be rejected.

.. code:: yaml

   - Filter: Bounds Check
     variables: [air_temperature]
     minvalue: 230
   - Filter: Bounds Check
     variables: [eastward_wind, northward_wind]
     maxvalue: 40

In the above example two filters are configured, one testing temperature, and the other testing wind components. The first filter would reject all temperature observations that are below 230. The second filter would reject wind component observation when it's above 40.

Background Check Filter
------------------------

This filter checks for bias corrected distance between observation value and model simulated value (y-H(x)) and rejects obs where the absolute difference is larger than abs_threshold or threshold * sigma_o when the filter action is set to "reject". This filter can also adjust observation error through a constant inflation factor when the filter action is set to "inflate error". If no action section is included in the yaml, the filter is set to reject the flagged observations.

.. code:: yaml

   ObsFilters:
   - Filter: Background Check
     variables: [air_temperature]
     threshold: 2.0
     absolute threshold: 1.0
     action:
       name: reject
   - Filter: Background Check
     variables: [eastward_wind, northward_wind]
     threshold: 2.0
     where:
     - variable: latitude@MetaData
       minvalue: -60.0
       maxvalue: 60.0
     action:
       name: inflate error
       inflation: 2.0

The first filter would flag temperature observations where abs((y+bias)-H(x)) > min ( absolute_threshold, threshold * sigma_o), and
then the flagged data are rejected due to filter action is set to reject.

The second filter would flag wind component observations where abs((y+bias)-H(x)) > threshold * sigma_o and latitude of the observation location are within 60 degree. The flagged data will then be inflated with a factor 2.0.

Please see the "Filter Action" for more detail.

Domain Check Filter
--------------------

The syntax of this ObsFilter is identical to that of "where" statement. For example, if we wanted a filter that kept all observations that satisfy the example on where statement above, and reject everything else, we can have:

.. code:: yaml

   - Domain Check:
     where:
     - variable: sea_surface_temperature@GeoVaLs
       minvalue: 200
       maxvalue: 300
    - variable: height@MetaData
       is_defined
     - variable: station_id@MetaData
       is_in: 3, 6, 11-120
     - variable: something@MetaData
       is_not_defined

Blacklist filter
-----------------

The syntax of this ObsFilter is also identical to that of "where" statement, but this filter behaves the exact opposite of Domain Check: everything that satisfies all where statements will be rejected:

.. code:: yaml

   - Blacklist:
     where:
     - variable: sea_surface_temperature@GeoVaLs
       minvalue: 200
       maxvalue: 300
    - variable: height@MetaData
       is_defined
     - variable: station_id@MetaData
       is_in: 3, 6, 11-120
     - variable: something@MetaData
       is_not_defined

Gaussian Thinning Filter
-------------------------

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

.. code:: yaml

    - Filter: Gaussian_Thinning
      horizontal_mesh:   1111.949266 #km = 10 deg at equator

Example 2 (thinning observations from multiple categories and with non-equal priorities by their horizontal position, pressure and time):

.. code:: yaml

    - Filter: Gaussian_Thinning
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

TemporalThinning Filter
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

.. code:: yaml

    - Filter: TemporalThinning
      min_spacing: PT01H30M
      seed_time: 2018-04-15T00:00:00Z
      category_variable:
        name: call_sign@MetaData

Example 2 (selecting at most one observation taken by each station per 1 h, 
starting from the earliest observation, and allowing the filter to retain an observation 
taken up to 20 min after the first qualifying observation if its quality score is higher):

.. code:: yaml

    - Filter: TemporalThinning
      min_spacing: PT01H
      tolerance: PT20M
      category_variable:
        name: call_sign@MetaData
      priority_variable:
        name: score@MetaData

Difference filter
-----------------

This filter will compare the difference between a reference variable and a second variable and assign a QC flag if the difference is outside of a prescribed range.

For example:

.. code:: yaml

   ObsFilters:
   - Filter: Difference Check
     reference: brightness_temperature_8@ObsValue
     value: brightness_temperature_9@ObsValue
     minvalue: 0
   passedBenchmark:  540      # number of passed obs


The above YAML is checking the difference between :code:`brightness_temperature_9@ObsValue` and :code:`brightness_temperature_8@ObsValue` and rejecting negative values.

In psuedo-code form:
:code:`if (brightness_temperature_9@ObsValue - brightness_temperature_8@ObsValue < minvalue) reject_obs()`

The options for YAML include:
 - :code:`minvalue`: the minimum value the difference :code:`value - reference` can be. Set this to 0, for example, and all negative differences will be rejected.
 - :code:`maxvalue`: the maximum value the difference :code:`value - reference` can be. Set this to 0, for example, and all positive differences will be rejected.
 - :code:`threshold`: the absolute value the difference :code:`value - reference` can be (sign independent). Set this to 10, for example, and all differences outside of the range from -10 to 10 will be rejected.

Note that :code:`threshold` supersedes :code:`minvalue` and :code:`maxvalue` in the filter.

Derivative filter
-----------------

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

.. code:: yaml

   ObsFilters:
   - Filter: Derivative Check
     independent: datetime
     dependent: air_pressure
     minvalue: -50
     maxvalue: 0
     passedBenchmark:  238      # number of passed obs

The above YAML is checking the derivative of :code:`air_pressure` with respect to :code:`datetime` for a radiosonde profile and rejecting observations where the derivative is positive and less than -50 Pa/sec.

The options for YAML include:
 - :code:`independent`: the name of the independent variable (:code:`dx`)
 - :code:`dependent`: the name of the dependent variable (:code:`dy`)
 - :code:`minvalue`: the minimum value the derivative can be without the observations being rejected
 - :code:`maxvalue`: the maximum value the derivative can be without the observations being rejected
 - :code:`i1`: the index of the first observation location in the record to use
 - :code:`i2`: the index of the last observation location in the record to use

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

.. code:: yaml

   - Filter: Track Check
     temporal_resolution: PT30S
     spatial_resolution: 20 # km
     num_distinct_buddies_per_direction: 3
     distinct_buddy_resolution_multiplier: 3
     max_climb_rate: 200 # Pa/s
     max_speed_interpolation_points: {"0": 1000, "20000": 400, "110000": 200} # Pa: m/s
     rejection_threshold: 0.5
     station_id_variable: station_id@MetaData

Filter actions
--------------
The action taken on filtered observations is configurable in the YAML.  So far this capability is only implemented for the background check through a FilterAction object, but the functionality is generic and can be extended to all other generic filters.  The two action options available now are rejection or inflating the ObsError, which are activated as follows:

.. code:: yaml

   - Filter: Background Check
     variables: [air_temperature]
     threshold: 2.0
     absolute threshold: 1.0
     action:
       name: reject
   - Filter: Background Check
     variables: [eastward_wind, northward_wind]
     threshold: 2.0
     where:
     - variable: latitude
       minvalue: -60.0
       maxvalue: 60.0
     action:
       name: inflate error
       inflation: 2.0

The default action (when the action section is omitted from the Filter) is to reject the filtered observations.

ObsFunction and ObsDiagnostic suffixes
--------------------------------------

In addition to, e.g., @GeoVaLs, @MetaData, @ObsValue, @HofX, there are two new suffixes that can be used.

- @ObsFunction requires that a particular variable is defined as an ObsFunction Class under ufo/src/ufo/obsfunctions.  One example of an ObsFunction is Velocity@ObsFunction, which uses the 2 wind components to produce windspeed and can be used as follows:

.. code:: yaml

    - Filter: Domain Check
      variables: [eastward_wind, northward_wind]
      where:
      - variable: Velocity@ObsFunction
        maxvalue: 20.0

So far, @ObsFunction variables can be used in where statements in any of the generic filters.  In the future, they may be used to inflate ObsError as an "action".

- @ObsDiagnostic will be used to store non-h(x) diagnostic values from the simulateObs function in individual ObsOperator classes.  The ObsDiagnostics interface class to OOPS is used to pass those diagnostics to the ObsFilters.  Because the diagnostics are provided by simulateObs, they can only be used in a PostFilter.  The generic filters will need to have PostFilter functions implemented (currently only Background Check) in order to use ObsDiagnostics.  The simulateObs interface to ObsDiagnostics will be first demonstrated in CRTM.

Where statement and processWhere function
------------------------------------------

The :code:`where` statement can be included in the yaml file in conjunction with observation filters as the condition for filtering. The :code:`processWhere` function takes the condition in the :code:`where` statement from yaml and creates a mask that restricts where the filter will apply. The default is true, so if there is no :code:`where`, the filter applies everywhere. Everywhere the condition is false, the filter will not be applied.

The following conditions are accepted by the :code:`where` statement:

- :code:`minvalue` and/or :code:`maxvalue` : filter applied if value is within the valid range
- :code:`is_defined`                       : filter applied if data has a valid value (not missing)
- :code:`is_not_defined`                   : filter applied if data is missing
- :code:`is_in`                            : filter applied if data is in the given whitelist
- :code:`is_not_in`                        : filter applied if data is not in the given blacklist

.. code:: yaml

   where:
   - variable: sea_surface_temperature@GeoVaLs
     minvalue: 200
     maxvalue: 300
   - variable: latitude@MetaData
     maxvalue: 60.
   - variable: height@MetaData
     is_defined
   - variable: station_id@MetaData
     is_in: 3, 6, 11-120

In the example above, four masks are created for radiosonde observation filtering. The filter will be applied in sequence at observation locations where the sea surface temperature is within the range of [200, 300] kelvin, the latitude is <= than 60 degrees, the height of the observation has a valid value (not missing), and the station id is one of the ids in the whitelist. 

The :code:`where` statement and :code:`processWhere` function are used in generic filters such as BackgroundCheck, DifferenceCheck, ObsBoundsCheck, ObsDomainCheck, and BlackList.
