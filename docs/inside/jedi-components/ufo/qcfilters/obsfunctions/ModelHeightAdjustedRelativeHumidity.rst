.. _ModelHeightAdjustedRelativeHumidity:

ModelHeightAdjustedRelativeHumidity
===================================

The Met Office surface observation processing includes the correction of surface observation values so they are valid at the model
surface rather than at the observing station height. The relative humidity (:code:`relativeHumidityAt2M`) is adjusted from station level to model surface using an
empirical vertical gradient LRH = -0.01 %/m (-0.0001 fraction/m). The adjusted humidity value is then constrained to lie between
zero and supersaturation with respect to liquid water.


Parameters
==========

- :code:`elevation`: [required] Input station height variable to be used.

- :code:`temperature`: [required] Input temperature variable to be used.

- :code:`observation relative humidity units`: [required] Units of the observation relative humidity; valid values are :code:`percentage` or :code:`fraction`.


Example yaml
============

The following yaml block shows how the ObsFunction can be used.

.. code-block:: yaml

    - filter: Variable Assignment
      assignments:
      - name: DerivedObsValue/relative_humidity
        type: float
        function:
          name: ObsFunction/ModelHeightAdjustedRelativeHumidity
          options:
            elevation:
              name: MetaData/stationElevation
            temperature:
              name: TestReference/airTemperatureAt2M
            observation relative humidity units: percentage
