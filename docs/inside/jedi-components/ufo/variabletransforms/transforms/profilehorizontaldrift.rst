
.. _VT-profilehorizontaldrift:

========================
Profile horizontal drift
======================== 

This transform can be used to compute horizontal drift positions (and times)
for profiles that do not have 3D position measurements.

--------------
Variables used
--------------

- Latitude
- Longitude
- dateTime
- Height (m)
- Wind speed (m/s)
- Wind direction (degrees)

----------
Parameters
----------

- ``height coordinate``: height coordinate name.
- ``keep in window``: [optional, default :code:`false`] keep calculated dateTimes within the assimilation window.
- ``require descending pressure sort``: [optional, default :code:`true`] throw an exception if the pressures have not been sorted in descending order.

------------------
Example yaml block
------------------

.. code-block:: yaml

    obs filters:
    - filter: Variable Transforms
      Transform: ProfileHorizontalDrift
      height coordinate: height
      keep in window: true
      require descending pressure sort: true

------
Method
------

The method used follows that presented in Laroche and Sarrazin 2013 [1].
Each sonde is assumed to have a constant ascent speed of :math:`w = 5.16` m/s.
This is used together with observed values of height
(:math:`z`), wind speed (:math:`F`), and wind direction (:math:`\theta`)
to compute the changes in latitude (:math:`\lambda`) and longitude (:math:`\phi`)
during the ascent.

The transform loops over all levels in the ascent with valid wind speed and height data,
starting at the lowest level and terminating at the second-highest level.
Let :math:`k` be the index of the current level.
The calculation proceeds by computing the following quantities:

- Height difference :math:`\Delta z = z_{k + 1} - z_k`.
- Time difference :math:`\Delta t = \Delta z / w`.
- Average eastward wind :math:`u = 0.5 (F_k \sin\theta_k + F_{k + 1}\sin\theta_{k + 1})`.
- Average northward wind :math:`v = 0.5 (F_k \cos\theta_k + F_{k + 1}\cos\theta_{k + 1})`.
- Total height above the centre of the Earth :math:`Z = R + z`, where :math:`R` is the radius of the Earth.
- Change in latitude :math:`\Delta\lambda = v \Delta t / Z`.
- Change in longitude :math:`\Delta\phi = u \Delta t / (Z \cos\lambda)`.

The changes in latitude, longitude and time are added to the station latitude, longitude and time to produce the final ascent values.

For simplicity, conversions between degrees and radians were omitted in the above equations.

The calculation is not performed if :math:`|\lambda| \geq 89.0^\circ`.


[1] Laroche, S., & Sarrazin, R. (2013). Impact of Radiosonde Balloon Drift on Numerical Weather Prediction and Verification, Weather and Forecasting, 28(3), 772-782.
