.. _top-ufo-qc:

Quality Control in UFO
======================

OOPS Observation Processing Flow
--------------------------------

Observations can be used in different ways in OOPS-JEDI. In variational data assimilation,
the initial computation of the observation term of the cost function (J\ :sub:`o`) is where
most of the quality control takes place.

The flow of this computation in OOPS is as follows::

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

This filter checks for distance between observation value and model simulated value (y-H(x)) and rejects obs where the absolute difference is larger than abs_threshold or threshold * sigma_o.

.. code:: yaml

    - Filter: Background Check
      variables: [air_temperature]
      threshold: 2.0
      absolute threshold: 1.0
    - Filter: Background Check
      variables: [eastward_wind, northward_wind]
      threshold: 2.0

The first filter would reject all temperature observations where abs(y-H(x)) > min ( absolute_threshold, threshold * sigma_o). The seconf filter will reject wind component observation where abs(y-H(x)) > threshold * sigma_o.

where statement
-------------------

Where statement can be used with Background Check and Bounds Check above, and is also a main part of Domain Check and Blacklist described below.

It can use: minvalue, maxvalue, is_defined, is_not_defined, and is_in, is_not_in for integer values:

.. code:: yaml

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

In the example above where statement would mean that the filter is applied for all observed variables in the following situations: sea_surface_temperature from the model is between [200, 300], height from the observation metadata has a valid number, station_id is 3, 6, or between 11 and 120, and something@MetaData doesn't have a valid value.

If where is applied in BackgroundCheck or BoundsCheck, then those filters are only applied when all the where statements are valid.

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

This filter thins observations to a two- or three-dimensional equidistant grid.  This is horizontally defined in kilometers (the mesh is generated relative to the mean radius of the earth) and vertically in pressure (Pa).  For 2D thinning, simply specify a horizontal_mesh:  

.. code:: yaml

    - Filter: Gaussian_Thinning
      horizontal_mesh:   1111.949266 #km = 10 deg at equator

The observation nearest to each thinning centroid will be retained, while all others within the thinning mesh will be excluded.  

For a 3D mesh, specify a vertical_mesh in addition to a horizontal_mesh:

.. code:: yaml

    - Filter: Gaussian_Thinning
      horizontal_mesh:   1111.949266 #km = 10 deg at equator
      vertical_mesh:     10000 #Pa

In a 3D mesh, the observation nearest the horizontal centroid in each vertical bin will be retained.  There is no weighting towards the vertical midpoint of the bin.

=======
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
