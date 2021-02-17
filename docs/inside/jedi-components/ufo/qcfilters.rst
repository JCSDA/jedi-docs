.. _top-ufo-qc:

Quality Control in UFO
======================

OOPS Observation Processing Flow
--------------------------------

Observations can be used in different ways in OOPS-JEDI. In variational data assimilation,
the initial computation of the observation term of the cost function (J\ :sub:`o`) is where
most of the quality control takes place.

The flow of this computation in OOPS is as follows:

.. code-block:: yaml  
  
  CostFunction::evaluate
    CostJo::initialize
      ObsFilters::ObsFilters
      Observer::Observer
        ObsOperator::requiredVars
        ObsFilters::requiredVars
    CostFunction::runNL
      Model::forecast
        Observer::initialize
          ObsFilters::preProcess
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

The :code:`Observer` calls the :code:`preProcess` method of :code:`ObsFilters` before the loop over time steps. After the loop, it calls the :code:`priorFilter` and :code:`postFilter` methods just before and just after calling the :code:`simulateObs` method of :code:`ObsOperator`. The observation filters are very generic and can perform a number of tasks, but mostly they are used for quality control.

Observation Filters
-------------------

Observation filters have access to:
 - Observation values and metadata
 - Model values at observations locations (GeoVaLs)
 - Simulated observation value (for post-filter)
 - Their own private data

Most filters are written once and used with many observation types; several such generic filters already exist and are decribed below. Filters applied to observations from a specific ObsSpace need to be listed in the :code:`observations.obs filters` section of the input YAML configuration file, together with any options controlling their behavior. Example:

.. code-block:: yaml
      
  observations:    
  - obs space:
      name: AMSUA-NOAA19
      obsdatain:
        obsfile: Data/obs/testinput_tier_1/amsua_n19_obs_2018041500_m.nc4
      simulated variables: [brightness_temperature]
      channels: 1-15
    obs filters:
    - filter: Bounds Check
      filter variables:
      - name: brightness_temperature
        channels: 1-15
      minvalue: 100.0
      maxvalue: 500.0
    - filter: Background Check
      filter variables:
      - name: brightness_temperature
        channels: 1-15
      threshold: 3.0

Generic QC Filters Implemented in UFO
=====================================

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

Profile Consistency Checks
--------------------------

.. _profconcheck_overview:

Overview
^^^^^^^^

This filter comprises several QC checks that can be applied to atmospheric profile data (e.g. as measured by radiosondes) whose observations lie at particular pressure levels.
These checks have been ported from UK Met Office observation processing system (OPS).
The following checks are available:

- **Basic**: These checks ensure the profile pressures lie in a reasonable range and are in the correct order.
  :ref:`Click here for more details <profconcheck_basic>`.

- **SamePDiffT**: If two levels have the same pressure, but their temperature difference is larger than a threshold, reject one of the levels.
  :ref:`Click here for more details <profconcheck_samepdifft>`.

- **Sign**: This check determines whether an observed temperature may have had its sign (in degrees Celsius) recorded incorrectly.
  To do this the temperature is compared to the model background value.
  If the check is failed a temperature correction is calculated.
  :ref:`Click here for more details <profconcheck_sign>`.

- **UnstableLayer**: The temperature in a particular level is used to compute the expected temperature in the level above given the dry adiabatic lapse rate.
  If the measured temperature in the level above is lower than its expected value by a certain threshold then both levels are flagged.
  :ref:`Click here for more details <profconcheck_unstablelayer>`.

- **Interpolation**: The temperature between adjacent significant pressure levels is interpolated onto any encompassed standard pressure levels.
  If the interpolated temperature differs from the observed value by more than a particular threshold then the relevant standard and significant levels are flagged.
  (Further information on standard and significant levels can be found :ref:`here <profconcheck_standardlevels>`.)
  :ref:`Click here for more details <profconcheck_interpolation>`.

- **Hydrostatic**: This is a check of the consistency between the observed values of temperature and geopotential height at each pressure level.
  The check relies on the hydrostatic equation and has a complicated decision-making algorithm.
  If a particular level fails this check then a height correction is (sometimes) computed.
  :ref:`Click here for more details <profconcheck_hydrostatic>`.

- **UInterp**: The wind speed between adjacent significant pressure levels is interpolated onto any encompassed standard pressure levels.
  If the vector difference of the interpolated and measured wind speeds is larger than a certain threshold then the relevant standard and significant levels are flagged.
  :ref:`Click here for more details <profconcheck_uinterp>`.

- **RH**: This check detects relative humidity errors at the top of cloud layers and at high altitudes.
  :ref:`Click here for more details <profconcheck_rh>`.

- **Time**: This check flags any observations whose time of measurement lies outside the assimilation window. It also optionally rejects wind values for a certain period after launch.
  :ref:`Click here for more details <profconcheck_time>`.

- **BackgroundX**: These checks use a Bayesian approach to modify the probability of gross error for several variables (**X** can be **GeopotentialHeight**, **RelativeHumidity**, **Temperature** or **WindSpeed**). The use of such an approach distinguishes these checks from the Background Check filter introduced above.
  :ref:`Click here for more details <profconcheck_background>`.

- **PermanentReject**: This check permanently rejects observations that have previously been flagged as failing by another check.
  :ref:`Click here for more details <profconcheck_permrej>`.

- **SondeFlags**: This check accounts for any QC flags that were assigned to the sonde data prior to UFO being run.
  :ref:`Click here for more details <profconcheck_sondeflags>`.

- **WindProfilerFlags**: This check accounts for any QC flags that were assigned to the wind profiler data prior to UFO being run.
  :ref:`Click here for more details <profconcheck_winproflags>`.

- **Pressure**: This routine calculates profile pressures if they have not been measured (or were measured but are potentially inaccurate). This is achieved by vertical interpolation and extrapolation using the observed height and model values of height and pressure.
  :ref:`Click here for more details <profconcheck_pressure>`.

This filter can apply more than one check in turn. Please note the following:

- The total number of errors that have occurred is recorded as the filter proceeds through each check.
  If this number exceeds a threshold (set by defining the parameter :code:`nErrorsFail`) then the entire profile is rejected.

- The basic checks are always performed unless they are specifically disabled (by setting the parameter :code:`flagBasicChecksFail` to true).

..
  (Commented out for now - will be revisited once all of the filters are in place)
  The checks must be performed in a particular order if it is desired to exactly reproduce the operation of the OPS code.
  This is because the QC flags (and values of temperature or height) that are modified in one routine may then be read by a subsequent routine.
  To achieve the same outcome as in the OPS code the following order must be used:
  Basic, SamePDiffT, Sign, UnstableLayer, Interpolation, Hydrostatic, UInterp, RH.

.. _profconcheck_filtervars:

Filter variables
^^^^^^^^^^^^^^^^

The QC checks rely on a variety of physical observables. The value of :code:`filter variables` for each check should be:

- Basic, SamePDiffT, Sign, UnstableLayer, Interpolation, Hydrostatic: :code:`air_temperature`, :code:`geopotential_height`.

- UInterp: :code:`eastward_wind`, :code:`northward_wind`.

- RH: :code:`air_temperature`, :code:`relative_humidity`.

- BackgroundX: :code:`air_temperature`, :code:`relative_humidity`, :code:`eastward_wind`, :code:`northward_wind`, :code:`geopotential_height` depending on the value of X.

- Pressure: :code:`geopotential_height`.

- Time, PermanentReject, SondeFlags, WindProfilerFlags: these routines act on QC flags so must be supplied with a dummy filter variable. Any variable that exists in the data set is acceptable; :code:`eastward_wind` would be a good choice.

The :code:`obsgrouping` category should be set up in one of two ways. The first applies a descending sort to the air pressures:

.. code-block:: yaml

        obsgrouping:
          group variable: "station_id"
          sort variable: "air_pressure"
          sort order: "descending"

The second does not sort the air pressures:

.. code-block:: yaml

        obsgrouping:
          group variable: "station_id"

The second formulation could be used if the pressures have been sorted prior to applying this filter.
An ascending sort order is not valid; if this is selected the checks will throw an error.
In both cases the station ID is used to discriminate between different sonde profiles.

:ref:`Back to overview of profile consistency checks <profconcheck_overview>`

.. _profconcheck_generic:

Filter configuration
^^^^^^^^^^^^^^^^^^^^

The following yaml parameters can be used to configure the filter itself:

- :code:`Checks`: List of checks to perform. The checks will be performed in the specified order.  Examples: ["Basic"], ["Basic", "Hydrostatic", "UInterp"].

- :code:`nErrorsFail`: Total number of errors at which an entire profile is rejected (default 1).

- :code:`flagBasicChecksFail`: Reject a profile if it fails the basic checks (default true). This should only be set to false for testing purposes.

- :code:`compareWithOPS`: Compare values obtained in these checks with the equivalent values produced in the OPS code (default false).
  This is set to true for certain unit tests (named :code:`*OPScomparison*`) for which the relevant quantities are present in the input files.

- :code:`Comparison_Tol`: Tolerance for comparisons with OPS, enabling rounding errors to be accommodated (default 0.1).

:ref:`Back to overview of profile consistency checks <profconcheck_overview>`

.. _profconcheck_standardlevels:

Standard and significant levels
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

**Definitions**

Standard, or mandatory, levels are values of pressure at which it has been internationally agreed that complete measurements of the physical observables should ideally be recorded.
Significant levels correspond to other pressure values at which the physical observables should be recorded to get an accurate picture of the sonde ascent.

Each profile is checked for the presence of both standard and significant levels.

**Summary of yaml parameters:**

- :code:`FS_MinP`: Minimum pressure for including a level in standard level finding routine (default 0.0 Pa).

- :code:`StandardLevels`: list of standard levels (default [1000, 925, 850, 700, 500, 400, 300, 250, 200, 150, 100, 70, 50, 30, 20, 10, 7, 3, 2, 1] hPa). These are internationally-agreed values and should usually not be changed.

:ref:`Back to overview of profile consistency checks <profconcheck_overview>`

.. _profconcheck_basic:

Basic check
^^^^^^^^^^^

**Operation**

The following basic checks are applied to each profile:

- There is at least one pressure level present,

- The pressures lie between minimum and maximum values (\ :code:`BChecks_minValidP` and :code:`BChecks_maxValidP`),

- The pressures are in descending order.

Any profiles that do not meet these criteria are rejected.

**Summary of yaml parameters**

- :code:`BChecks_minValidP`: Minimum pressure in profile (default 0.0 Pa).

- :code:`BChecks_maxValidP`: Maximum pressure in profile (default 110.0e3 Pa).

- :code:`BChecks_Skip`: Do not perform the basic checks (default false). Only set to true for unit tests in which the input sample consists of pressures that should not be sorted.

:ref:`Back to overview of profile consistency checks <profconcheck_overview>`

.. _profconcheck_samepdifft:

SamePDiffT check
^^^^^^^^^^^^^^^^

**Operation**

This check searches for pairs of levels that have identical pressures but for which the absolute difference between their temperatures is larger than a particular threshold (\ :code:`SPDTCheck_TThresh`).
The level with the larger absolute difference between the observed and model background temperature is rejected.

**Summary of yaml parameters**

- :code:`SPDTCheck_TThresh`: Absolute temperature difference threshold (default 0.0 K).

:ref:`Back to overview of profile consistency checks <profconcheck_overview>`

.. _profconcheck_sign:

Sign check
^^^^^^^^^^

**Operation**

The sign check for a particular level is failed in the following case:

- The absolute difference between the observed and model background temperature is larger than a threshold (\ :code:`SCheck_tObstBkgThresh`),

- Changing the sign (in degrees C) of the observed temperature causes its absolute difference relative to the model background temperature (also in degrees C) to be smaller than a threshold (\ :code:`SCheck_ProfileSignTol`),

- The level pressure is lower by more than a certain amount (\ :code:`SCheck_PstarThresh`) than the model surface pressure.

**Summary of yaml parameters**

- :code:`SCheck_tObstBkgThresh`: Threshold for absolute temperature difference between observation and background (default 5.0 K).

- :code:`SCheck_ProfileSignTol`: Threshold for absolute temperature difference between observation and background after the observation sign has been changed (default 100.0 degrees C).

- :code:`SCheck_PstarThresh`: Threshold for difference between observed pressure and model surface pressure (default 1000.0 Pa).

- :code:`SCheck_PrintLargeTThresh`: Pressure threshold above which large temperature differences are printed (default 1000.0 Pa).

- :code:`SCheck_CorrectT`: Compute correction to temperature (default true).

:ref:`Back to overview of profile consistency checks <profconcheck_overview>`

.. _profconcheck_unstablelayer:

UnstableLayer check
^^^^^^^^^^^^^^^^^^^

**Operation**

The temperature at a particular level is used to compute the temperature at the adjacent level (upwards) in the profile.
The calculation assumes that the temperature-pressure relationship follows the dry adiabatic lapse rate.
If the observed temperature at the adjacent level is lower than the calculated temperature by more than a particular amount (\ :code:`ULCheck_SuperadiabatTol`) the level is flagged.
This check is only applied to levels whose pressure is larger than a minimum threshold (\ :code:`ULCheck_MinP`) and lower by a certain amount (\ :code:`ULCheck_PBThresh`) than the surface pressure.

**Summary of yaml parameters**

- :code:`ULCheck_SuperadiabatTol`: Temperature difference threshold between observed temperature and temperature computed assuming dry adiabatic lapse rate (default -1.0 K).

- :code:`ULCheck_PBThresh`: Threshold on difference between level pressure and 'bottom' pressure (which can change during the routine) (default 10000.0 Pa).

- :code:`ULCheck_MinP`: Minimum pressure at which the checks are performed (default 0.0 Pa).

:ref:`Back to overview of profile consistency checks <profconcheck_overview>`

.. _profconcheck_interpolation:

Interpolation check
^^^^^^^^^^^^^^^^^^^

**Operation**

The temperature is interpolated from significant levels onto any encompassed standard levels.
If the absolute difference between the standard level temperature and the interpolated value is more than a particular threshold (\ :code:`ICheck_TInterpTol`) then the level in question, together with the relevant significant levels,
are all flagged.
Below a particular pressure (\ :code:`ICheck_TolRelaxPThresh`) the threshold is relaxed by multiplying it by the factor :code:`ICheck_TolRelax`.

This check is only performed if the pressure difference between the standard and significant levels is not too large.
The difference, known loosely as a 'big gap', depends upon the pressure of the standard level.
As the standard level pressure decreases, the big gaps also decrease in size
according to the list in :code:`ICheck_BigGaps`; the smallest big gap is defined as :code:`ICheck_BigGapInit`.

**Summary of yaml parameters**

- :code:`ICheck_TInterpTol`: Threshold for temperature difference between observed and interpolated value (default 1.0 K).

- :code:`ICheck_TolRelaxPThresh`: Pressure below which temperature difference threshold is relaxed (default 50000.0 Pa).

- :code:`ICheck_TolRelax`: Multiplicative factor for temperature difference threshold, used if pressure is lower than :code:`ICheck_TolRelaxPThresh` (default 1.0).

- :code:`ICheck_BigGaps`: 'Big gaps' for use in this check (default [500, 500, 500, 500, 100, 100, 100, 100, 50, 50, 50, 50, 10, 10, 10, 10, 10, 10, 10, 10] hPa).

- :code:`ICheck_BigGapInit`: Smallest value of 'big gap' (default 1000.0 Pa).

:ref:`Back to overview of profile consistency checks <profconcheck_overview>`

.. _profconcheck_hydrostatic:

Hydrostatic check
^^^^^^^^^^^^^^^^^

**Operation**

The hydrostatic check is used to check the consistency of the standard levels. The thickness between two standard levels is computed according to the hydrostatic equation.

If this thickness differs from the measured value by more than a particular amount then the associated levels may be flagged.
A decision-making algorithm is used to classify the levels as having height or temperature errors.

**Summary of yaml parameters**

- :code:`HCheck_CorrectZ`: Compute correction to Z (default true).

- :code:`HydDesc`: Text description of hydrostatic errors.

- There are a large number of thresholds used in the decision-making algorithm. Their default values are listed here:

  - :code:`HCheck_SurfacePThresh`: 10000.0 Pa

  - :code:`HCheck_ETolMult`: 0.5

  - :code:`HCheck_ETolMax`: 1.0 m

  - :code:`HCheck_ETolMaxPThresh`: 50000.0 Pa

  - :code:`HCheck_ETolMaxLarger`: 1.0 m

  - :code:`HCheck_ETolMin`: 1.0 m

  - :code:`HCheck_EThresh`: 100.0 m

  - :code:`HCheck_EThreshB`: 100.0 m

  - :code:`HCheck_ESumThresh`: 50.0 m

  - :code:`HCheck_MinAbsEThresh`: 10.0 m

  - :code:`HCheck_ESumThreshLarger`: 100.0 m

  - :code:`HCheck_MinAbsEThreshLarger`: 100.0 m

  - :code:`HCheck_CorrThresh`: 5.0 m

  - :code:`HCheck_ESumNextThresh`: 50.0 m

  - :code:`HCheck_MinAbsEThreshT`: 10.0 m

  - :code:`HCheck_CorrDiffThresh`: 10.0

  - :code:`HCheck_CorrMinThresh`: 1.0

:ref:`Back to overview of profile consistency checks <profconcheck_overview>`

.. _profconcheck_uinterp:

UInterp check
^^^^^^^^^^^^^

**Operation**

This check is used to detect two types of error in the observed wind speed.
The first occurs when two levels have identical pressures but a large vector difference between their measured wind speeds.
If the squared difference between the measured wind speeds is larger than a threshold (\ :code:`UICheck_TInterpIdenticalPTolSq`) then both levels are flagged.

The second type of error is detected by interpolating the significant level wind speeds onto any encompassed standard levels,
as is done for temperature in the Interpolation check (\ :ref:`see here <profconcheck_interpolation>`).
If the squared difference between the interpolated and measured wind speeds is larger than a certain amount (\ :code:`UICheck_TinterpTolSq`) then
both levels are flagged.

Similarly to the interpolation check, the second type of error is only searched for if the pressure difference between the adjacent standard levels is not too large.
The maximum permitted difference is referred to as a 'big gap'. The value of the big gap depends on the pressure of the standard level in question;
as this pressure reduces (and passes thresholds defined in :code:`UICheck_BigGapsPThresh`), the value of the big gap also reduces
(according to the values in :code:`UICheck_BigGaps`),
down to a minimum value given by the value of :code:`UICheck_BigGapLowP`.

**Summary of yaml parameters**

- :code:`UICheck_TInterpIdenticalPTolSq`: threshold for squared difference between observed wind speeds for levels with identical pressures (default 0.0 m\ :sup:`2` s\ :sup:`-2`).

- :code:`UICheck_TInterpTolSq`: threshold for squared difference between observed and interpolated wind speeds (default 0.0 m\ :sup:`2` s\ :sup:`-2`).

- :code:`UICheck_BigGapsPThresh`: Maximum pressure thresholds corresponding to the big gaps as defined in :code:`UICheck_BigGaps` (default [50000.0, 10000.0, 5000.0, 1000.0] Pa).

- :code:`UICheck_BigGaps`: Big gaps corresponding to the pressure thresholds defined in :code:`UICheck_BigGapsPThresh` (default [100000.0, 50000.0, 10000.0, 5000.0] Pa).

- :code:`UICheck_BigGapLowP`: Minimum 'big gap' in pressure (default 500.0 Pa).

:ref:`Back to overview of profile consistency checks <profconcheck_overview>`

.. _profconcheck_rh:

RH check
^^^^^^^^

**Operation**

The RH check is designed to detect errors in relative humidity that may be caused by ascents through clouds. Two checks are employed:

- Transient humidity error at the cloud top,

- Persistent humidity error at high altitude (low pressure) levels after passing through a cloud.

The following conditions must be met in order for a level to fail the cloud top check:

- The level pressure must be larger than a particular value (\ :code:`RHCheck_PressThresh`),

- The pressure difference between the present level and the lowest level must be larger than a particular threshold (\ :code:`RHCheck_PressDiff0Thresh`),

- The dew point temperature difference between the present level and the level below must be larger than the threshold :code:`RHCheck_tdDiffThresh`,

- The level relative humidity must be larger than the threshold :code:`RHCheck_RHThresh`,

- The minimum relative humidity of all levels above the present level must be less than a certain threshold (\ :code:`RHCheck_MinRHThresh`).
  Only levels whose pressure is close to that of the current level (with a difference threshold of (\ :code:`RHCheck_PressDiffAdjThresh`) are considered.

The following conditions must be met in order for a level to fail the high-altitude check:

- The minimum observed temperature in the profile must be less than a particular threshold (\ :code:`RHCheck_TminThresh`),

- At least one of the following is true:

  - The difference between the observed and model background (O-B) relative humidity in the present level must be larger than a particular threshold (\ :code:`RHCheck_SondeRHHiTol`),

  - The present level has a pressure lower than :code:`RHCheck_PressInitThresh` and the mean RH O-B, computed over all levels with a pressure lower than :code:`RHCheck_PressInitThresh`,
    is larger than :code:`RHCheck_SondeRHHiTol`.

**Summary of yaml parameters**

The following parameters are used in the cloud top check:

- :code:`RHCheck_PressThresh`: Pressure threshold for check at top of cloud layers (default 500.0 Pa).

- :code:`RHCheck_PressDiff0Thresh`: Threshold for difference between pressure at the present level and pressure at the lowest level (default 50.0 Pa).

- :code:`RHCheck_tdDiffThresh`: Threshold for difference in dew point temperature between the present level and the level below (default 5.0 K).

- :code:`RHCheck_RHThresh`: Threshold for relative humidity check to be applied (default 75.0%).

- :code:`RHCheck_MinRHThresh`: Threshold for minimum relative humidity at top of cloud layers (default 75.0%).

- :code:`RHCheck_PressDiffAdjThresh`: Pressure threshold for determining cloud layer minimum RH (default 50.0 Pa).

The following parameters are used in the high-altitude check:

- :code:`RHCheck_TminThresh`: Threshold value of minimum observed temperature in the profile (default 200.0 K).

- :code:`RHCheck_TminInit`: Initial value used in the algorithm that determines the minimum observed temperature (default 400.0 K).

- :code:`RHCheck_SondeRHHiTol`: Threshold for relative humidity O-B difference in sonde ascent check (default 0.0%).

- :code:`RHCheck_PressInitThresh`: Pressure below which O-B mean is calculated (default 500.0 Pa).

- :code:`RHCheck_TempThresh`: Minimum temperature threshold for accumulating an error counter (default 250.0 K).

:ref:`Back to overview of profile consistency checks <profconcheck_overview>`

.. _profconcheck_time:

Time check
^^^^^^^^^^

**Operation**

This check flags any observations whose time of measurement lies outside the assimilation window. The time check also optionally rejects wind values whose observation pressure is within :code:`TimeCheck_SondeLaunchWindRej` of the surface pressure.

**Summary of yaml parameters**

- :code:`ModelLevels`: Governs whether the observations have been averaged onto model levels.

- :code:`TimeCheck_SondeLaunchWindRej`: Observations are rejected if they differ from the surface pressure by less than this value. Assuming an ascent rate of 5 m/s, 10 hPa corresponds to around 20 s of flight time. Using a pressure difference enables all sonde reports to be dealt with. (Default: 0.0 hPa, i.e. no rejection is performed).

:ref:`Back to overview of profile consistency checks <profconcheck_overview>`

.. _profconcheck_background:

BackgroundX checks
^^^^^^^^^^^^^^^^^^

**Operation**

The BackgroundX checks, where X is GeopotentialHeight, RelativeHumidity, Temperature or WindSpeed, use a Bayesian method to update the probability of gross error (PGE) for the relevant set of observations. Each observation must have previously been assigned a value of PGE in order for these checks to be used; this value could, for example, be taken from a stationlist. This PGE is updated with the method detailed below and is used in further filters such as the Buddy check. In addition to updating the PGE, various QC flags are set by each check.

The Bayesian background checks all operate in a similar manner. Firstly, the probability density of 'bad' observations is set. Such observations are in gross error, and are assumed to have a uniform probability of taking any climatologically reasonable value. Secondly, for some variables, the observation and background errors are increased to reflect additional sources of error which may be present. Finally the PGE calculation routine is called. Some of the modifications to the errors, and to the PGE within the Bayesian calculation, are only performed if the values in a profile have been averaged onto model levels. This is signified by the filter parameter :code:`ModelLevels` being equal to true.

The errors and PGEs are modified as follows for each variable:

- Geopotential height: the background errors and probability density of bad observations are initialised from the arrays :code:`BkCheck_zBkgErrs` and :code:`BkCheck_zBadPGEs` respectively. The value taken from each array depends on where the observed pressure lies in the array :code:`BkCheck_PlevelThresholds`.
- Relative humidity: the probability density of bad observations is set to :code:`BkCheck_PdBad_rh`. The background and observation error values are multiplied by the square root of two in order to account for long-tailed error distributions. The maximum combined observation and background error variance passed to the Bayesian PGE update is set to the value :code:`BkCheck_ErrVarMax_rh`.
- Temperature: the probability density of bad observations is set to :code:`BkCheck_PdBad_t`. The observation errors above a certain pressure threshold ('Psplit') are scaled in order to account for extra representivity error. The value of Psplit depends on whether the observation is in the tropics, defined as the region with absolute latitude less than :code:`options_.BkCheck_Psplit_latitude_tropics` degrees. If the observation is in the tropics, Psplit is set to :code:`BkCheck_Psplit_tropics`; otherwise it is :code:`BkCheck_Psplit_extratropics`. The error inflation for pressures less than or equal to Psplit is set to :code:`BkCheck_ErrorInflationBelowPsplit` and :code:`BkCheck_ErrorInflationAbovePsplit` otherwise. The observation PGE is modified if the observation was previously flagged in the UnstableLayer, Interpolation or Hydrostatic checks.
- Wind speed: the probability density of bad observations is set to :code:`BkCheck_PdBad_uv`. The observation PGE is modified if observation was previously flagged in the Interpolation check.

The PGE update then proceeds as follows. Firstly the probability of the difference between the observed and background values is calculated, assuming the difference follows a normal distribution with variance equal to the combined observation and background error variance. The wind speed components (u and v) are treated together, so a two-dimensional probability density is formed in that case. The PGE is then weighted by this calculated probability and also by the probability that the observation is bad. The updated PGE can be passed to the Buddy check if desired.

The PGE update code is located in a UFO utility function, enabling it to be used by multiple UFO filters. All of the configurable parameters used in the utility function are prefixed with :code:`PGE_` and are defined in the section below. Further details of the Bayesian update method can be found in Ingleby, N.B. and Lorenc, A.C. (1993), Bayesian quality control using multivariate normal distributions. Q.J.R. Meteorol. Soc., 119: 1195-1225. https://doi.org/10.1002/qj.49711951316

**Summary of yaml parameters**

- :code:`ModelLevels`: Governs whether the observations have been averaged onto model levels.

- :code:`BkCheck_PdBad_t`: Probability density of bad observations for T (default: 0.05).

- :code:`BkCheck_PdBad_rh`: Probability density of bad observations for RH (default: 0.05).

- :code:`BkCheck_PdBad_uv`: Probability density of bad observations for u and v (default: 0.001).

- :code:`BkCheck_Psplit_latitude_tropics`: Observations with a latitude smaller than this value (both N and S) are taken to be in the tropics (default: 30 degrees).

- :code:`BkCheck_Psplit_extratropics`: Pressure threshold above which extra representivity error occurs in extratropics (default: 50000 Pa).

- :code:`BkCheck_Psplit_tropics`: Pressure threshold above which extra representivity error occurs in tropics (default: 10000 Pa).

- :code:`BkCheck_ErrorInflationBelowPsplit`: Error inflation factor below Psplit (default value: 1.0).

- :code:`BkCheck_ErrorInflationAbovePsplit`: Error inflation factor above Psplit (default value: 1.0).

- :code:`BkCheck_ErrVarMax_rh`: Maximum combined observation and background error variance for RH (default: 500.0 per 10000).

- :code:`BkCheck_PlevelThresholds`: Pressure thresholds for setting geopotential height background errors and bad observation PGE. This vector must be the same length as :code:`BkCheck_zBkgErrs` and :code:`BkCheck_zBadPGEs` (default: [1000.0, 500.0, 100.0, 50.0, 10.0, 5.0, 1.0, 0.0] hPa).

- :code:`BkCheck_zBkgErrs`: List of geopotential height background errors that are assigned based on pressure. This vector must be the same length as :code:`BkCheck_PlevelThresholds` and :code:`BkCheck_zBadPGEs` (default: [10.0, 10.0, 10.0, 10.0, 10.0, 10.0, 10.0, 10.0] m).

- :code:`BkCheck_zBadPGEs`: List of geopotential height PGEs for bad observations that are assigned based on pressure. This vector must be the same length as :code:`BkCheck_PlevelThresholds` and :code:`BkCheck_zBkgErrs` (default: [0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01]).

- :code:`PGE_ExpArgMax`: Maximum value of exponent in background QC (default 80.0). This could be changed depending upon the machine precision.

- :code:`PGE_PGECrit`: PGE rejection limit (default 0.1). Observations with values of PGE above this threshold are flagged.

- :code:`PGE_ObErrMult`: Multiplication factor for observation errors (default 1.0).

- :code:`PGE_BkgErrMult`: Multiplication factor for background errors (default 1.0).

- :code:`PGE_SDiffCrit`: Threshold for (squared observation minus background difference) / (error variance) (default 100.0). Observations with values larger than this threshold are flagged. This is only performed if the observations have been averaged onto model levels.

:ref:`Back to overview of profile consistency checks <profconcheck_overview>`

.. _profconcheck_permrej:

PermanentReject check
^^^^^^^^^^^^^^^^^^^^^

**Operation**

This check permanently rejects observations that have previously been flagged as failing by another check.

**Summary of yaml parameters**

- :code:`ModelLevels`: Governs whether the observations have been averaged onto model levels.

:ref:`Back to overview of profile consistency checks <profconcheck_overview>`

.. _profconcheck_sondeflags:

SondeFlags check
^^^^^^^^^^^^^^^^

**Operation**

This check accounts for any QC flags that were assigned to the sonde data prior to UFO being run. These QC flags may be (e.g.) standard WMO designations.

**Summary of yaml parameters**

There are no configurable parameters for this check.

:ref:`Back to overview of profile consistency checks <profconcheck_overview>`

.. _profconcheck_winproflags:

WindProfilerFlags check
^^^^^^^^^^^^^^^^^^^^^^^

**Operation**

This check accounts for any QC flags that were assigned to the wind profiler data prior to UFO being run.

**Summary of yaml parameters**

There are no configurable parameters for this check.

:ref:`Back to overview of profile consistency checks <profconcheck_overview>`

.. _profconcheck_pressure:

Pressure calculation
^^^^^^^^^^^^^^^^^^^^

**Operation**

This routine calculates profile pressures if they are have not been measured (or were measured but are potentially inaccurate). Firstly the model heights are computed from the orography and the terrain-following height coordinate. The model heights are used together with the observation heights and model pressures to interpolate (or extrapolate) values of the observed pressures.

**Summary of yaml parameters**

The default values of these parameters are suitable for the UM.

- :code:`zModelTop`: Height of the upper boundary of the highest model layer.

- :code:`firstConstantRhoLevel`: First model rho level at which there is no geographical variation in the height.

- :code:`etaTheta`: Values of terrain-following height coordinate (eta) on theta levels.

- :code:`etaRho`: Value of terrain-following height coordinate (eta) on rho levels.

:ref:`Back to overview of profile consistency checks <profconcheck_overview>`

.. _profconcheck_example:

Examples
^^^^^^^^

This example runs the basic checks on the input data:

.. code-block:: yaml

    - filter: Profile Consistency Checks
      filter variables:
      - name: air_temperature
      - name: geopotential_height
      Checks: ["Basic"]

This example runs the basic and SamePDiffT checks on the input data, using separate instances of the filter to do so:

.. code-block:: yaml

    - filter: Profile Consistency Checks
      filter variables:
      - name: air_temperature
      - name: geopotential_height
      Checks: ["Basic"]
    - filter: Profile Consistency Checks
      filter variables:
      - name: air_temperature
      - name: geopotential_height
      Checks: ["SamePDiffT"]
      SPDTCheck_TThresh: 30.0 # This is an example modification of a check parameter

This example runs the basic and SamePDiffT checks on the input data, using the same filter instance:

.. code-block:: yaml

    - filter: Profile Consistency Checks
      filter variables:
      - name: air_temperature
      - name: geopotential_height
      Checks: ["Basic", "SamePDiffT"]
      SPDTCheck_TThresh: 30.0 # This is an example modification of a check parameter

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

.. _filter-actions:

Filter Actions
--------------
The action taken on observations flagged by the filter can be adjusted using the :code:`action` option recognized by each filter.  So far, three actions have been implemented:

* :code:`reject`: observations flagged by the filter are marked as rejected.
* :code:`inflate error`: the error estimates of observations flagged by the filter are multiplied by a factor. This can be either a constant (specified using the :code:`inflation factor` option) or a variable (specified using the :code:`inflation variable` option).
* :code:`assign error`: the error estimates of observations flagged by the filter are set to a specified value. Again. this can be either a constant (specified using the :code:`error parameter` option) or a variable (specified using the :code:`error function` option).

The default action (taken when the :code:`action` keyword is omitted) is to reject the flagged observations.

Examples:

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
     - variable: latitude
       minvalue: -60.0
       maxvalue: 60.0
     action:
       name: inflate error
       inflation: 2.0
  - filter: BlackList
    filter variables:
    - name: brightness_temperature
      channels: *all_channels
    action:
      name: assign error
      error function:
        name: ObsErrorModelRamp@ObsFunction
        channels: *all_channels
        options:
          channels: *all_channels
          xvar:
            name: CLWRetSymmetricMW@ObsFunction
            options:
              clwret_ch238: 1
              clwret_ch314: 2
              clwret_types: [ObsValue, HofX]
          x0:    [ 0.050,  0.030,  0.030,  0.020,  0.000,
                   0.100,  0.000,  0.000,  0.000,  0.000,
                   0.000,  0.000,  0.000,  0.000,  0.030]
          x1:    [ 0.600,  0.450,  0.400,  0.450,  1.000,
                   1.500,  0.000,  0.000,  0.000,  0.000,
                   0.000,  0.000,  0.000,  0.000,  0.200]
          err0:  [ 2.500,  2.200,  2.000,  0.550,  0.300,
                   0.230,  0.230,  0.250,  0.250,  0.350,
                   0.400,  0.550,  0.800,  3.000,  3.500]
          err1:  [20.000, 18.000, 12.000,  3.000,  0.500,
                   0.300,  0.230,  0.250,  0.250,  0.350,
                   0.400,  0.550,  0.800,  3.000, 18.000]

.. _obs-function-and-obs-diagnostic-suffixes:

ObsFunction and ObsDiagnostic Suffixes
--------------------------------------

In addition to, e.g., :code:`@GeoVaLs`, :code:`@MetaData`, :code:`@ObsValue`, :code:`@HofX`, there are two new suffixes that can be used.

- :code:`@ObsFunction` indicates that a particular variable should be a registered :code:`ObsFunction` (:code:`ObsFunction` classes are defined in the :code:`ufo/src/ufo/filters/obsfunctions` folder).  One example of an :code:`ObsFunction` is :code:`Velocity@ObsFunction`, which uses the 2 wind components to produce wind speed and can be used as follows:

  .. code-block:: yaml

      - filter: Domain Check
        filter variables:
        - name: eastward_wind
        - name: northward_wind
        where:
        - variable: Velocity@ObsFunction
          maxvalue: 20.0

  Warning: ObsFunctions are evaluated for all observations, including those that have been unselected by previous elements of the :code:`where` list or rejected by filters run earlier. This can lead to problems if these ObsFunctions incorrectly assume they will always be given valid inputs.

- :code:`@ObsDiagnostic` will be used to store non-H(x) diagnostic values from the :code:`simulateObs` function in individual :code:`ObsOperator` classes.  The :code:`ObsDiagnostics` interface class in OOPS is used to pass those diagnostics to the :code:`ObsFilters`.  Because the diagnostics are provided by :code:`simulateObs`, they can only be used in filters that implement the :code:`postFilter` function (currently only Background Check and Met Office Buddy Check).  The :code:`simulateObs` interface to :code:`ObsDiagnostics` will be first demonstrated in CRTM.

.. _where-statement:

Where Statement
---------------

By default, filters are applied to all observations of the variables specified in the :code:`filter variables` list (or if this list is not present, all simulated variables). The :code:`where` keyword can be used to apply a filter only to observations meeting certain conditions.

Consider the following set of observations:

.. list-table:: 
   :header-rows: 1

   * - Obs. index 
     - latitude 
     - longitude 
     - air_temperature (K)
   * - 0
     - 0
     - 50
     - 300
   * - 1
     - 20
     - 60
     - 200
   * - 2
     - 40
     - 70
     - 290
   * - 3
     - 60
     - 80
     - 260
   * - 4
     - 80
     - 90
     - 220

and suppose that we want to reject air temperature observations below 230 K taken in the tropical zone (between 30°S and 30°N). We could do this using the Bounds Check filter with a :code:`where` statement:

.. code-block:: yaml

  - filter: Bounds Check
    filter variables: air_temperature
    minvalue: 230
    action: reject # this is the default action, specified explicitly for clarity
    where:
    - variable:
        name: latitude@MetaData
      minvalue: -30
      maxvalue:  30

This would cause the filter to be applied only to air temperature observations `selected` by the :code:`where` statement, i.e. meeting the specified condition :code:`-30 <= latitude@MetaData <= 30`. Please note this does not mean all these observations would be rejected; rather, it means the Bounds Check filter would inspect only these observations and apply its usual criteria (in this case, "is the air temperature below the minimum allowed value of 230 K?") to decide whether any of them should be rejected. In our example, only observation 1 would be rejected, since this is the only observation (a) taken in the range of latitudes selected by the :code:`where` statement and (b) with a value lying below the minimum value passed to the Bounds Check filter.

The list passed to the :code:`where` keyword can contain more than one item, each representing a separate condition imposed on a particular variable. The filter is applied only to observations meeting all of these conditions. The following kinds of conditions are accepted:

- :code:`minvalue` and/or :code:`maxvalue`: filter applied only to observations for which the condition variable lies in the specified range. The upper and lower bounds can be floating-point numbers or datetimes in the ISO 8601 format. If any date/time components are set to zero, they are disregarded. See :ref:`Example 2 <where-example-2>` below on where this can be useful.
- :code:`is_defined`: filter applied only to observations for which the condition variable has a valid value (not a missing data indicator).
- :code:`is_not_defined`: filter applied only to observations for which the condition variable is set to a missing data indicator.
- :code:`is_in`: filter applied only to observations for which the condition variable is set to a value belonging to the given whitelist.
- :code:`is_not_in`: filter applied only to observations for which the condition variable is set to a value not belonging to the given blacklist.
- :code:`any_bit_set_of`: filter applied only to observations for which the condition variable is an integer with at least one of the bits with specified indices set.
- :code:`any_bit_unset_of`: filter applied only to observations for which the condition variable is an integer with at least one of the bits with specified indices unset (i.e. zero).

The elements of both whitelists and blacklists can be strings, non-negative integers or ranges of non-negative integers. It is not necessary to put any value after the colon following :code:`is_defined` and :code:`is_not_defined`. Bits are numbered from zero starting from the least significant bit.

The following examples illustrate the use of these conditions.

Example 1
^^^^^^^^^

.. code-block:: yaml

   where:
   - variable:
       name: sea_surface_temperature@GeoVaLs
     minvalue: 200
     maxvalue: 300
   - variable: 
       name: latitude@MetaData
     maxvalue: 60.
   - variable: 
       name: height@MetaData
     is_defined:
   - variable: 
       name: station_id@MetaData
     is_in: 3, 6, 11-120

In this example, the filter will be applied only to observations for which all of the following four criteria are met:

- the sea surface temperature is within the range of [200, 300] K,
- the latitude is <= than 60°N,
- the observation location's altitude has a valid value (is not set to a missing data indicator), and 
- the station id is one of the ids in the whitelist. 

.. _where-example-2:

Example 2
^^^^^^^^^

.. code-block:: yaml

      where: 
      - variable:
          name:  datetime@MetaData
        minvalue: 0000-01-01T00:00:00Z
        maxvalue: 0000-25-05T00:00:00Z 
      - variable:
          name:  datetime@MetaData
        minvalue: 0000-00-00T09:00:00Z
        maxvalue: 0000-00-00T17:59:59Z

In this example, the filter will be applied only to observations taken between 09:00:00 and 17:59:59, between 1st January and 25th May of every year.

Example 3
^^^^^^^^^

.. code-block:: yaml

   where:
   - variable:
       name: mass_concentration_of_chlorophyll_in_sea_water@PreQC
     any_bit_set_of: 0, 1

In this example, the filter will be applied only to observations for which the :code:`mass_concentration_of_chlorophyll_in_sea_water@PreQC` variable is an integer whose binary representation has a 1 at position 0 and/or position 1. (Position 0 denotes the least significant bit -- in other words, bits are numbered "from right to left".)

Example 4
^^^^^^^^^

.. code-block:: yaml

   where:
   - variable:
       name: mass_concentration_of_chlorophyll_in_sea_water@PreQC
     any_bit_set_of: 4
   - variable:
       name: mass_concentration_of_chlorophyll_in_sea_water@PreQC
     any_bit_unset_of: 10-12

In this example, the filter will be applied only to observations for which the :code:`mass_concentration_of_chlorophyll_in_sea_water@PreQC` variable is an integer whose binary representation has a 1 at position 4 and a 0 at any of positions 10 to 12.

Outer Loop Iterations
---------------------

By default, filters are applied only before the first iteration of the outer loop of the data assimilation process. Use the :code:`apply at iterations` parameter to customize the set of iterations after which a particular filter is applied. In the example below, the Background Check filter will be run before the outer loop starts ("after the zeroth iteration") and after the first iteration:

.. code-block:: yaml

   - filter: Background Check
     apply at iterations: 0,1
     threshold: 0.25

Creating a New Filter
---------------------

If none of the filters described above meets your requirements, you may need to write a new one. If possible, make it generic (applicable to arbitrary observation types). The source code of UFO filters is stored in the :code:`ufo/src/ufo/filters` folder. You may find it useful to refer to the JEDI Academy tutorials on `writing <http://academy.jcsda.org/2020-02/pages/activities/day2b.html>`_ and `testing <http://academy.jcsda.org/2020-02/pages/activities/day4a.html>`_ a filter.

When writing a new filter, consider using the :ref:`Parameter-classes`
to automate extraction of filter parameters from YAML files.

Filter Tests
------------

All observation filters in UFO are tested with the :code:`ObsFilters` test from :code:`ufo/test/ufo/ObsFilters.h`. Each entry in the :code:`observations` list in a YAML file passed to this test should contain at least one of the following parameters:

- :code:`passedBenchmark`: Number of observations that should pass QC.
- :code:`passedObservationsBenchmark`: List of indices of observations that should pass QC.
- :code:`failedBenchmark`: Number of observations that should not pass QC.
- :code:`failedObservationsBenchmark`: List of indices of observations that should not pass QC.
- :code:`flaggedBenchmark`: Number of observations whose QC flag should be set to the value specified in the YAML option :code:`benchmarkFlag`. Useful to isolate the impact of a filter executed after other filters that also modify QC flags.
- :code:`failedObservationsBenchmark`: List of indices of observations whose QC flag should be set to the value specified in the YAML option :code:`benchmarkFlag`.
- :code:`compareVariables`: A list whose presence instructs the test to compare variables created by the filter with reference variables. Each element of the list should contain the following parameters:

  - :code:`test`: The variable to be tested.
  - :code:`reference`: The reference variable.

  By default, the comparison will succeed only if all entries in the compared variables are exactly equal. If the compared variables hold floating-point numbers and the :code:`absTol` option is set, the comparison will succeed if all entries differ by at most :code:`absTol`. Example:

  .. code-block:: yaml

    compareVariables:
      - test:
          name: eastward_wind@ObsValue
        reference:
          name: eastward_wind@TestReference
        absTol: 1e-5
      - test:
          name: northward_wind@ObsValue
        reference:
          name: northward_wind@TestReference
        absTol: 1e-5
