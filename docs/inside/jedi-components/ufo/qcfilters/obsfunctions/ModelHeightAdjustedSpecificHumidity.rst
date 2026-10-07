.. _ModelHeightAdjustedSpecificHumidity:

ModelHeightAdjustedSpecificHumidity
===================================

This ObsFunction adjusts an observed specific humidity value to preserve relative humidity
when temperature has been height-adjusted from station elevation to model height.

The algorithm:

1. Compute RH at station height: :math:`RH = q_{obs} / q_{sat}(T_{obs}, P_{station})`
2. Compute adjusted q at model surface: :math:`q_{adj} = RH \cdot q_{sat}(T_{adj}, P_{model\_surface})`

where :math:`T_{adj}` is the height-adjusted temperature from a prior Variable Assignment
(e.g., using ``ModelHeightAdjustedAirTemperature``).

If station pressure is missing for a location, model surface pressure is used as fallback
for both saturation calculations. Since :math:`q_{sat} \propto e_{sat}(T)/P`, when the same
pressure is used in both steps the effect largely cancels, making the adjustment primarily
driven by the temperature difference.

The saturation vapor pressure uses the Sonntag formulation, and the saturated specific
humidity uses the Gill/UKMO formulation:
:math:`q_{sat} = \varepsilon \cdot e_{sat} / (P - (1-\varepsilon) \cdot e_{sat})`.


Parameters
==========

All parameters are optional and have sensible defaults for typical surface obs processing.

- :code:`observed specific humidity variable`: [optional, default ``ObsValue/specificHumidityAt2M``]
  The observed specific humidity variable to adjust.

- :code:`observed temperature variable`: [optional, default ``ObsValue/airTemperatureAt2M``]
  The original observed temperature at station height, used to compute RH from :math:`q_{obs}`.

- :code:`adjusted temperature variable`: [optional, default ``DerivedObsValue/airTemperatureAt2M``]
  The height-adjusted temperature (from a prior Variable Assignment).

- :code:`station pressure variable`: [optional, default ``ObsValue/stationPressure``]
  Observed station pressure for computing :math:`q_{sat}` at station height.
  Falls back to model surface pressure if missing.

- :code:`model surface pressure variable`: [optional, default ``GeoVaLs/air_pressure_at_surface``]
  Model surface pressure for computing :math:`q_{sat}` at model surface height.


Example yaml
============

This ObsFunction is designed to be used in a chain after temperature adjustment:

.. code-block:: yaml

  obs filters:
  # Step 1: Height-adjust temperature
  - filter: Variable Assignment
    assignments:
    - name: DerivedObsValue/airTemperatureAt2M
      function:
        name: ObsFunction/ModelHeightAdjustedAirTemperature
        options:
          elevation:
            name: MetaData/stationElevation
          model height:
            from: terrain
          temperature lapse rate in K/km:
            scheme: constant
            value: 6.5

  # Step 2: Height-adjust specific humidity preserving RH
  - filter: Variable Assignment
    assignments:
    - name: DerivedObsValue/specificHumidityAt2M
      function:
        name: ObsFunction/ModelHeightAdjustedSpecificHumidity
