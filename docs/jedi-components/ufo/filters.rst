.. _top-ufo-newobsop:

ObsFilters implemented in UFO
========================================

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

.. code:: yaml

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

