.. _VT-radarbeamgeom:

===================
Radar beam geometry
===================

Given values of radar beam tilt [deg] and azimuth [deg], gate range [m] and station elevation [m], compute the following quantities:

- sin(tilt)
- cos(azimuth) * cos(tilt)
- sin(azimuth) * cos(tilt)
- gate height [m]

These quantities are required in the radar Doppler winds observation operator.
Gate height is also required in the radar reflectivity operator.
In the context of radar observations, a gate represents a volume over which the observation sample is taken.
The gate range is the distance along the beam from the radar to the centre of the gate, and
the gate height is the height above sea level of the observation.

Please note that tilt is what is known in Europe (in the OPERA standard) as elevation angle. Tilt is defined as the angle above the horizontal plane of the surface, and azimuth is measured clockwise with zero degrees representing due North.

The calculations use an effective value of the Earth's radius in order to account for refraction of the radar beam as it travels through the atmosphere. The effective value is equal to approximately 4/3 times the actual value.

--------------
Variables used
--------------

- :code:`MetaData/beamTiltAngle`: initial value of beam tilt angle relative to the horizontal [deg].
- :code:`MetaData/beamAzimuthAngle`: beam azimuth angle [deg].
- :code:`MetaData/gateRange`: gate range [m].
- :code:`MetaData/stationElevation`: station elevation above mean sea level [m].

----------
Parameters
----------

- ``OPS compatibility mode``: [default :code:`false`] If :code:`true`, use slightly different values of the effective Earth radius at different points in the calculation. If :code:`false`, use a consistent value.

------------------
Example yaml block
------------------

.. code-block:: yaml

    obs filters:
    - filter: Variable Transforms
      Transform: RadarBeamGeometry

------
Method
------

The height of each radar gate (:math:`z`) is computed accounting for the effective radius of curvature of the Earth:

.. math::
   z = \sqrt{r^{2} + 2 R_{\text{eff}} r \sin{\theta_{0}} + R_{\text{eff}}^2} - R_{\text{eff}} + z_{\text{station}}

where :math:`r` is the gate range, :math:`R_{\text{eff}}` is the Earth's effective radius, :math:`\theta_{0}` is the initial beam tilt angle, and :math:`z_{\text{station}}` is the station altitude above mean sea level.

The beam tilt angle is also corrected to account for the Earth's curvature. A correction is computed as follows:

.. math::

   \theta_{\text{corr}} = \tan^{-1} \Bigg(\frac{r\cos\theta_{0}}{r\sin\theta_{0} + R_{\text{eff}} + z_{\text{station}}}\Bigg)

This correction is added to the initial tilt angle :math:`\theta_{0}` in order to produce the final tilt angle :math:`\theta`.
The trigonometric quantities listed above are computed using the beam azimuth and :math:`\theta`.
