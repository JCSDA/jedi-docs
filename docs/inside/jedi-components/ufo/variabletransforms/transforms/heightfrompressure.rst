
.. _VT-heightfrompressure:

====================
Height from pressure
====================

This transform computes height from pressure.

--------------
Variables used
--------------

- Pressure (Pa)

----------
Parameters
----------

- ``height coordinate``: Height coordinate name.
- ``height group``: Height coordinate group.
- ``pressure coordinate``: Pressure coordinate name.
- ``pressure group``: Pressure coordinate group.

------------------
Example yaml block
------------------

.. code-block:: yaml

    obs filters:
    - filter: Variable Transforms
      Transform: HeightFromPressure
      Method: UKMO
      height coordinate: height
      height group: ObsValue
      pressure coordinate: air_pressure
      pressure group: MetaData

------
Method
------

Height :math:`z` (m) is computed from pressure :math:`p` (Pa). 
Two methods are available: ``UKMO`` and ``NCAR``.

The following constants are used in the calculations:

- :math:`g`: gravitational constant = 9.80665 m/s\ :sup:`2`
- :math:`r_d`: gas constant for dry air = 287.05 J/K/kg
- :math:`p_l`: ICAO lower tropopause pressure = 226.32 hPa
- :math:`p_u`: ICAO upper tropopause pressure = 54.7487 hPa
- :math:`z_l`: ICAO lower tropopause height = 11000.0 m
- :math:`z_u`: ICAO upper tropopause height = 20000.0 m
- :math:`L_l`: ICAO lower tropopause lapse rate: 0.0065 K/m
- :math:`L_u`: ICAO upper tropopause lapse rate: -0.001 K/m
- :math:`T_s`: ICAO surface temperature = 288.15 K
- :math:`T_i`: ICAO isothermal layer temperature = 216.65 K


**UKMO**

- :math:`p > p_l`:

.. math::
   z = [1.0 - (p / p_l)^{L_l / (g / r_d)}] \times T_s / L_l

- :math:`p_u < p < p_l`:

.. math::
   z = [\log(p_l) - \log(p)] \times T_i / (g / r_d) + z_l

- :math:`p < p_u`:

.. math::
   z = [1.0 - (p / p_u)^{L_u / (g / r_d)}] \times T_i / L_u + z_u

**NCAR**

The NCAR-RAL method: a fast approximation for pressures > 120 hPa.
Above 120hPa (~15km) use the ICAO atmosphere.

- :math:`p > 120` hPa:

.. math::
   z = 44307.692 \times (1.0 - (p / 101325)^{0.19})

- :math:`p_u < p < 120` hPa:

.. math::
   z = [\log(p_l) - \log(p)] \times T_i / (g / r_d) + z_l

- :math:`p < p_u`:

.. math::
   z = [1.0 - (p / p_u)^{L_u / (g / r_d)}] \times T_i / L_u + z_u
