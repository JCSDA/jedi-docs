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
    
**Observation parameters needed** (JEDI name)

- geopotential_height (:math:`Z`)


**Method(s) available**

Only one method is avalable, shared accross all center options. (Any setting of :code:`METHOD` will result
in using this unique method.) Setting :code:`METHOD` can be omitted.
(see formulation for details)

**Formulation(s) available**

See the unique formulation :ref:`Heights_to_pressure_ICAO`  for details

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
    
**Observation parameters needed** (JEDI name)

- geopotential_height (:math:`Z`)
- air_temperature  (:math:`T`)
- dew_point_temperature (:math:`T_{d}`) or relative_humidity (:math:`Rh`)


**Method(s) available**

Only one method is avalable, shared accross all center options. (Any setting of :code:`METHOD` will result
in using this unique method.) Setting :code:`METHOD` can be omitted.
(see formulation for details)

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

    Tv = T \frac{P+\frac{e_{sat}}{\epsilon}}{P+e_{sat}}

where :math:`e_{sat}` is the saturated vapour pressure which can be calculated 
from :math:`T_{d}` or :math:`Rh` using saturation vapor pressure from temperature, and
:math:`\epsilon`is ratio of the gas constant for dry air (:math:`R_{d}`) over 
the gas constant for water vapor (:math:`R_{v}`).

In this equation we use the pressure :math:`P` from the previous level as we don't yet have 
:math:`P` for the current level (this should be a good approximation for the high-resolution reports). 
Note that if the pressures have been calculated hydrostatically (or from the model height/pressure profile) 
there is no point in applying the hydrostatic check below. 

**Formulation(s) available**

By default the saturated vapour pressure (:math:`e_{sat}`) is 
derived using the :code:`Sonntag` formulation of :ref:`SatVaporPres_fromTemp`.
