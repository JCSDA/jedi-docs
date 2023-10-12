.. _surfacewindscalingpressure:


Compute Surface Wind Scaling for Pressure Coordinate
====================================================

This variable transform produces a near surface wind scaling factor for a pressure based coordinate. The transform is activated in the YAML with the following:

.. code:: yaml

  obs filters:
  - filter: Variable Transforms
    Transform: SurfaceWindScalingPressure


**Inputs**

The transform requires the following inputs:

- `GeoVaLs/air_pressure`
- `GeoVaLs/wind_reduction_factor_at_10m`
- `GeoVaLs/virtual_temperature`
- `GeoVaLs/surface_pressure`
- `MetaData/pressure`

**Outputs**

The transform produces the following outputs:

- `DerivedVariables/SurfaceWindScalingPressure`
