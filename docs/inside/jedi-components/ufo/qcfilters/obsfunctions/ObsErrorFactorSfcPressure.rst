.. _ObsErrorFactorSfcPressure:

ObsErrorFactorSfcPressure
=====================================================================================

This obsfunction was designed to mimic the GSI Observer code (i.e., setupps.f90) to inflate
the observation error for surface pressure.  The purpose of the function is to inflate the
observational error from its initial value to a larger value based on large discrepancies
between model and observations that would be expected when the model terrain (pressure)
differs from the observed terrain, which is likely in coarse resolution model simulations.
The filter variable must be :code:`stationPressure` since this function is designed solely
to affect the assignment of ObsError on this variable alone.

The following observed variables are required inside the code: station height (set by :code:`station_altitude`),
:code:`stationPressure`, :code:`airTemperatureAt2M` and :code:`specificHumidityAt2M`, although these may
contain missing data at some locations. The function computes the observed virtual temperature from
the air temperature and specific humidity. Where specific humidity is missing, it uses the air
temperature in place of the virtual temperature.  In addition, the required model 
GeoVaLs variables are: :code:`surface_altitude`,
:code:`surface_pressure`, and vertical profiles of :code:`air_pressure` and :code:`air_temperature`.
Since some model interfaces may supply different variable names for :code:`surface_altitude` or
temperature, there are yaml parameters to override the defaults.

Required Parameters
^^^^^^^^^^^^^^^^^^^

:code:`error_min` and :code:`error_max`
  specify the min and max
  ObsError which will be used within the function as limits on the output.

Optional Parameters
^^^^^^^^^^^^^^^^^^^

:code:`geovar_sfc_geomz`
  name of the model elevation variable. Default is :code:`height_above_mean_sea_level_at_surface`.
 
 :code:`geovar_geomz` name of the model elevation at bottom level. Default is :code:`height_above_mean_sea_level`.
 
 :code:`original_obserr` name of the un-inflated group of obserror. Default is :code:`ObsErrorData`
  in the event the model variable name is different (example would be :code:`surface_geopotential_height`).


:code:`observed temperature variable`
  name of the observed air temperature variable (ObsValue group). Default is :code:`airTemperatureAt2M`.

:code:`observed specific humidity variable`
  name of the observed specific humidity variable (ObsValue group). Default is :code:`specificHumidityAt2M`.

:code:`station_altitude`
  name of the station height variable (MetaData group). Default is :code:`height`.

:code:`original_obserr`
  an optional group name to override the default of :code:`ObsErrorData`
  in the event the input dataset already has a pre-determined value of ObsError.

Example
^^^^^^^

.. code-block:: yaml

     - filter: Perform Action
       filter variables:
       - name: stationPressure
       action:
         name: inflate error
         inflation variable:
           name: ObsFunction/ObsErrorFactorSfcPressure
           options:
             error_min: 100         # 1 mb
             error_max: 300         # 3 mb
             geovar_sfc_geomz: surface_geopotential_height   # Optional, default is surface_altitude
             geovar_temp: air_temperature                    # Optional, default is virtual_temperature
             temperature_name: airTemperatureAt2M            # Optional, default is airTemperatureAt2M
             specific_humidity_name: specificHumidityAt2M    # Optional, default is specificHumidityAt2M
             station_altitude: stationElevation              # Optional, default is height
             original_obserr: ObsError                       # Optional, default is ObsErrorData

