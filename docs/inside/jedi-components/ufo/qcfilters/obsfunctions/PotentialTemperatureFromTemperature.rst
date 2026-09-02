.. _PotentialTemperatureFromTemperature:

PotentialTemperatureFromTemperature
--------------------------------------------------------

It calculates air potential temperature at the surface, or retrieves air_potential_temperature in GeoVals at the nearest atmospheric model level to a pressure value (Pa). 

Required yaml parameters:
^^^^^^^^^^^^^^^^^^^^^^^^^

:code:`use surface pressure`
  A logical variable. This function calculates air potential temperature at the surface using "average_surface_temperature_within_field_of_view"
  if it is "true". It retrieves air potential temperature in GeoVaLs at the nearest atmospheric model level if the input is "false".
  
Optional yaml parameters:
^^^^^^^^^^^^^^^^^^^^^^^^^

:code:`pressure to evaluate potential temperature`
  An air pressure value (Pa) where air_potential_temperature is retrieved if "use surface pressure" is "false".

Example configuration:
~~~~~~~~~~~~~~~~~~~~~~~~

AMSU-A Example (amsua_qc_clwretmw.yaml):
  
.. code-block:: yaml

  - filter: Variable Assignment
    assignments:
    - name: DerivedMetaData/PotentialTemperatureSurface
      type: float
      function:
        name: PotentialTemperatureFromTemperature@ObsFunction
        options:
          use surface pressure: true
  - filter: Variable Assignment
    assignments:
    - name: DerivedMetaData/PotentialTemperatureAt700hPa
      type: float
      function:
        name: PotentialTemperatureFromTemperature@ObsFunction
        options:
          use surface pressure: false
          pressure to evaluate potential temperature: 70000.0
