.. _adjustedheight:

=======================
Compute adjusted height
=======================

This variable transform takes the height from observation space and adjusts it based on the station elevation. The transform is activated in the YAML with the following:

``` yaml
obs filters:
- filter: Variable Transforms
  Transform: AdjustedHeight
```

**Inputs**

The transform requires the following inputs:

- `GeoVaLs/surface_geometric_height`
- `MetaData/height`
- `MetaData/stationElevation`

**Outputs**

The transform produces the following outputs:

- `DerivedVariables/adjustedHeight`
