.. _ObsErrorFactorLatRad:

ObsErrorFactorLatRad
======================================================================

This obsfunction gives the maximum error bound reduction at equator and decreasing
towards higher latitudes.
Users need to specify four parameters using the "latitude_parameters" (see the example below).

Params[0]
  the latitude bound for which this error function applies.

Params[1-3]
  determine the error function within the latitude bound given by params[0].

The error function gives the maximum error bound reduction at equator and decreasing
towards params[0].

The function:
---------------
Error Function = :math:`params[1] * ( \left| latitude \right| * params[2] + params[3] )`

Example:
--------

.. code-block:: yaml

  - filter: Background Check
    filter variables:
    - name: brightness_temperature
      channels: *all_channels
    function absolute threshold:
    - name: ObsErrorBoundIR@ObsFunction
      channels: *all_channels
      options:
        channels: *all_channels
        obserr_bound_latitude:
          name: ObsErrorFactorLatRad@ObsFunction
          options:
            latitude_parameters: [25.0, 0.5, 0.04, 1.0]
