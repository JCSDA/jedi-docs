.. _surfacewindscalingheight:

=======================
Compute Surface Wind Scaling for Height Coordinate
=======================

This variable transform produces a near surface wind scaling factor for a height based coordinate. The transform is activated in the YAML with the following:

``` yaml
obs filters:
- filter: Variable Transforms
  Transform: SurfaceWindScalingHeight
  height variable group: <Name of group for height variable> (Default = `DerivedVariables`)
  height variable name: <Name of height variable> (Default = `adjustedHeight`)
```

**Inputs**

The transform requires the following inputs:

- `GeoVaLs/geopotential_height`
- `GeoVaLs/wind_reduction_factor_at_10m`
- `<Name of group for height variable>/<Name of height variable>`
- `MetaData/stationElevation`

**Outputs**

The transform produces the following outputs:

- `DerivedVariables/SurfaceWindScalingHeight`
