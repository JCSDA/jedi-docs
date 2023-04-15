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

The following observed variables are required inside the code: :code:`stationElevation`,
:code:`stationPressure`, and :code:`airTemperature`, although this may contain missing data
at some locations.  In addition, the required model GeoVaLs variables are: :code:`surface_altitude`,
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
  an optional variable name to override the default of :code:`surface_altitude`
  in the event the model variable name is different (example would be :code:`surface_geopotential_height`).

:code:`geovar_temp`
  an optional variable name to override the default of :code:`virtual_temperature`
  in the event the model variable name is different (example would be :code:`air_temperature`).

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
             original_obserr: ObsError                       # Optional, default is ObsErrorData

