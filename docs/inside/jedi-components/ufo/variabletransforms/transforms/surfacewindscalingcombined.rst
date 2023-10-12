.. _surfacewindscalingcombined:

Compute Surface Wind Scaling for Combined Height and Pressure Coordinate
========================================================================

This variable transform produces a near surface wind scaling factor for a combined height and pressure based coordinate. It uses the scaling for height, unless height is missing, in which case it uses pressure. The transform is activated in the YAML with the following:

.. code:: yaml

  obs filters:
  - filter: Variable Transforms
    Transform: SurfaceWindScalingCombined

**Inputs**

The transform requires the following inputs:

- `MetaData/height`
- `DerivedVariables/SurfaceWindScalingHeight`
- `DerivedVariables/SurfaceWindScalingPressure`

**Outputs**

The transform produces the following outputs:

- `DerivedVariables/SurfaceWindScalingCombined`
