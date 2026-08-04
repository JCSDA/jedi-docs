.. _VT-Heights-to-pressure-ICAO:

================================================
Pressure from Height (using the ICAO atmosphere)
================================================
Converts heights to pressures using the ICAO atmosphere.
The newly calculated variable is included in the same
obs space.

:code:`Transform: PressureFromHeightForICAO`

.. code-block:: yaml

    obs filters:
    - filter: Variable Transforms
      Transform: PressureFromHeightForICAO
      height coordinate: geopotentialHeight
      pressure coordinate: pressure
      pressure group: MetaData

**Observation parameters needed** (JEDI name)

- geopotentialHeight (:math:`Z`), specified with the ``height coordinate`` parameter.

**Parameters**

- ``height coordinate`` [*Required*] Height coordinate variable name in group ``ObsValue`` (if a ``DerivedObsValue`` exists, it will be used instead).
- ``pressure coordinate`` [*Required*] Pressure coordinate variable name.
- ``pressure group`` [*Optional* | *default = ``ObsValue``*] Pressure coordinate group name, default is ``ObsValue`` (if a ``DerivedObsValue`` exists, it will be used instead).

**Method(s) available**

Only one method is available. (Any setting of :code:`METHOD` will result
in using this unique method.) Setting :code:`METHOD` can be omitted.


.. _VT-Pressure-from-Height-over-a-vertical-profile:

================================================
Pressure from Height over a vertical profile
================================================
Derive pressure from height for vertical profile (e.g. sonde report). This is especially needed for radiosonde using a 3 09 055 BUFR
template.

:code:`Transform: PressureFromHeightForProfile`

.. code-block:: yaml

    obs filters:
    - filter: Variable Transforms
      Transform: PressureFromHeightForProfile
      Method: UKMO
      observation relative humidity units: percentage
      height coordinate: geopotentialHeight
      pressure coordinate: pressure
      pressure group: MetaData

**Observation parameters needed** (JEDI name)

- geopotentialHeight (:math:`Z`), specified with the ``height coordinate`` parameter.
- airTemperature  (:math:`T`)
- dewPointTemperature (:math:`T_{d}`) or relativeHumidity (:math:`RH`)

**Parameters**

- ``observation relative humidity units`` [*Required*] The units of relative humidity, in case it is used by the transform. Valid values are ``percentage`` or ``fraction``.
- ``height coordinate`` [*Required*] Height coordinate variable name in group ``ObsValue`` (if a ``DerivedObsValue`` exists, it will be used instead).
- ``pressure coordinate`` [*Required*] Pressure coordinate variable name.
- ``pressure group`` [*Optional* | *default = ``ObsValue``*] Pressure coordinate group name, default is ``ObsValue`` (if a ``DerivedObsValue`` exists, it will be used instead).

**Method(s) available**

Only one method is available. (Any setting of :code:`METHOD` will result
in using this unique method.) Setting :code:`METHOD` can be omitted.

`Nash et al (2011) <https://library.wmo.int/doc_num.php?explnum_id=9467>`__
showed that with GPS heights and accurate temperatures measured
pressures are almost redundant and it seems likely that the use of pressure sensors
will decrease over time. The pressure can be calculated hydrostatically starting
from the station pressure. For two adjacent levels i and i+1
(eg eqn 2.2 of `Chouinard and Staniforth, 1995 <https://www.researchgate.net/publication/249620682_Deriving_Significant-Level_Geopotentials_from_Radiosonde_Reports>`__):

.. math::

    \frac{Z_{i+1}-Z_{i}}{ln(\frac{P_{i-1}}{P_{i}})} = \frac{-R_{d}(T_{i+1}-T_{i})}{2g}

which gives

.. math::

    P_{i+1} = P_{i} \times e^{ \frac{2g(Z_{i}-Z_{i+1})}{R_{d}(T_{i+1}-T_{i})}}

Where :math:`R_{d}` is the specific gas constant for dry air.

For better accuracy one can replace the temperature with the virtual temperature :math:`T_{v}`:

.. math::

    Tv = T \frac{P+\frac{e'_\text{sat w}}{\epsilon}}{P+e'_\text{sat w}}

where :math:`e'_\text{sat w}` is the saturated vapour pressure which can be calculated
from :math:`T_{d}` or :math:`RH` using saturation vapor pressure from temperature, and
:math:`\epsilon` is ratio of the gas constant for dry air (:math:`R_{d}`) over
the gas constant for water vapor (:math:`R_{v}`).

The Sonntag formulation for calculating the saturated or actual vapour pressure of pure water vapor (:math:`e_\text{sat w} = h(T)` or :math:`e = h(T_d)`) is used (see :ref:`the description of the Sonntag equation here <VT-_SatVaporPres_fromTemp_Methods>`).
An enhancement factor is used to correct this for moist air

.. math::

    e'_\text{sat w} = f_\text{w}(P, T)) e_\text{sat w}

or

.. math::

    e' = f_\text{w}(P, T_d)) e

where the enhancement factor :math:`f_\text{w}` is taken from Eq. A4.6 of Gill (1982) "Atmosphere-Ocean Dynamics", Academic Press.
This approximates table 89 of the Smithsonian Meteorological Tables correct to 2 parts in :math:`10^4`.

In this equation we use the pressure :math:`P` from the previous level as we don't yet have
:math:`P` for the current level (this should be a good approximation for the high-resolution reports).
Note that if the pressures have been calculated hydrostatically (or from the model height/pressure profile)
there is no point in applying the hydrostatic check below.
