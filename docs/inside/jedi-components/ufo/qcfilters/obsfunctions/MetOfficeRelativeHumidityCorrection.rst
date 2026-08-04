.. _MetOfficeRelativeHumidityCorrection:

MetOfficeRelativeHumidityCorrection
===================================

There are differences in values of relative humidity H(x) produced by the unified model (UM) interface and
the Met Office observation processing (OPS) system. The differences are caused by the order in which
(1) RH is computed from specific humidity (2) temporal and spatial interpolation are
performed. The computation of relative humidity from specific humidity is nonlinear,
which can lead to differences in H(x) of up to 5%.

This ObsFunction computes two values of relative humidity H(x). The first reproduces
what occurs in the UM interface, i.e. it vertically interpolates the relative humidity
GeoVaLs at each location. The second reproduces what occurs in OPS, i.e. it computes
relative humidity from GeoVaLs of specific humidity, temperature, and pressure and
then performs vertical interpolation. The output of the ObsFunction is the difference
between the two interpolated H(x) values.

The H(x) difference can be added to observed relative humidity (using an :code:`Arithmetic`
ObsFunction) prior to running QC filters that rely on relative humidity O-B such as the
Background Check. After those filters have run, the H(x) difference can be subtracted back off.


Parameters
==========

- :code:`observed pressure`: [required] Name of observed pressure.

- :code:`output relative humidity units`: [required] Desired units of the output correction, :code:`percentage` or :code:`fraction` are valid strings.

- :code:`capsupersat`: [optional, default :code:`false`] Cap relative humidity 1 for fraction and 100% for percentage. Default :code:`false`.


Example yaml
============

The following yaml block shows how the ObsFunction can be used.

.. code-block:: yaml

    - filter: Variable Assignment
      assignments:
      - name: HofXCorrection/relative_humidity
        type: float
        function:
          name: ObsFunction/MetOfficeRelativeHumidityCorrection
          options:
            observed pressure: MetaData/pressure
            output relative humidity units: percentage
            capsupersat: true

The correction variable, :code:`HofXCorrection/relative_humidity`, can be added to the RH observation
values prior to using other filters that use RH O-B.
(Adding the correction to the observation values is equivalent to subtracting it from the background values.)
The correction should be subtracted off afterwards.
