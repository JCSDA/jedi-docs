===================
Humidity Transforms
===================

----------
Parameters
----------

All humidity transforms share a common set of parameters. Exactly which parameters are needed depends on the transform and the method.

- ``AllowSuperSaturation`` [*Optional* | *default = false*] Allow supersaturation.
- ``specific humidity variable``: [*Optional* | *default = ``specificHumidity``*] Variable name for specific humidity.
- ``pressure variable``: [*Optional* | *default = ``pressure``*] Variable name for pressure.
- ``pressure at 2m variable``: [*Optional* | *default = ``pressureAt2M``*] Variable name for pressure at 2m.
- ``pressure group variable``: [*Optional* | *default = ``ObsValue``*] Name of group within which pressure is found.
- ``temperature variable``: [*Optional* | *default = ``airTemperature``*] Variable name for temperature.
- ``virtual temperature variable``: [*Optional* | *default = ``virtualTemperature``*] Variable name for virtual temperature.
- ``temperature at 2m variable``: [*Optional* | *default = ``airTemperatureAt2M``*] Variable name for temperature at 2m.
- ``relative humidity variable``: [*Optional* | *default = ``relativeHumidity``*] Variable name for relative humidity.
- ``relative humidity at 2m variable``: [*Optional* | *default = ``relativeHumidityAt2M``*] Variable name for relative humidity at 2m.
- ``water vapor mixing ratio variable``: [*Optional* | *default = ``waterVaporMixingRatio``*] Variable name for water vapor mixing ratio (defined as mass of water vapor per unit mass of *dry* air).
- ``dew point temperature variable``: [*Optional* | *default = ``dewPointTemperature``*] Variable name for dew point temperature.
- ``dew point temperature at 2m variable``: [*Optional* | *default = ``dewPointTemperatureAt2M``*] Variable name for dew point temperature at 2m.


.. _VT-Relative-Humidity:

=================
Relative Humidity
=================

Calculates relative humidity from other variables.
**The definition of relative humidity depends on the method used**, as does the exact set of variables needed.

------------------
Example yaml block
------------------

.. code-block:: yaml

    obs filters:
    - filter: Variable Transforms
      Transform: RelativeHumidity
      Method: UKMO

-------
Methods
-------

There are two groups of methods, those which use the default recipe with varying formulations for calculating the saturation vapor pressure from temperature, and the more complex `UKMO` and `UKMOmixingratio` methods.


Default Recipe
^^^^^^^^^^^^^^

These methods define the relative humidity (:math:`RH`) as the ratio of the mass of water vapor per unit mass of dry air (:math:`r`) to the equivalent quantity at at saturation (:math:`r_\text{sat}`)

.. math::

    r = m_\text{water vapor}/m_\text{dry air}

    r_\text{sat} = m_\text{water vapor at saturation}/m_\text{dry air}

    RH = \frac{r}{r_\text{sat}}.


Observation parameters needed
"""""""""""""""""""""""""""""

- Specific humidity (:math:`q`, reported in :math:`kg / kg`) - defined as the mass of water vapor per unit mass of *dry* air. The variable name can be configured with the parameter ``specific humidity variable``.
- Air temperature (:math:`T`, reported in :math:`K`) - The variable name can be configured with the parameter ``temperature variable``.
- Pressure (:math:`P` reported in :math:`Pa`) - The variable name can be configured with the parameters ``pressure variable`` and ``pressure group variable``. If this variable is empty then the ``pressure at 2m variable`` is used instead: it is looked for in the ``ObsValue`` group.


Calculation Used
""""""""""""""""

Firstly the saturation vapor pressure of pure water vapor over water or ice :math:`e_\text{sat w/i}` is calculated

.. math::

    e_\text{sat w/i} = \text{min}(h(T), 0.15 \times P).

The exact formulation of :math:`h(T)` is controlled by the method name.
Note that a floor of 15% of the measured pressure is applied.
This limits the maximum transformed relative humidity.

Next this is converted to a saturation vapor pressure in moist air :math:`e'_\text{sat w/i}`

.. math::

    e'_\text{sat w/i} = e_\text{sat w/i}.


Note that a correction factor is **not** applied in this calculation: this is likely a mistake since atmospheric humidity variables are usually defined for air rather than pure water. The usual formulation is :math:`e'_\text{sat w/i} = f_\text{w/i} e_\text{sat w/i}`.

This is converted to the saturation mixing ratio of water vapor in dry air :math:`r_\text{sat}`

.. math::

    r_\text{sat} = \frac{\epsilon \times e'_\text{sat w/i}}{P - e'_\text{sat w/i}}

where :math:`\epsilon` is the ratio of the gas constant for dry air (:math:`R_d`) to the gas constant for pure water vapor (:math:`R_v`).

The specific humidity :math:`q` is the mass of water vapor per unit mass of total air, which here is taken to be the sum of the mass of dry air and the mass of water vapor (the mass of any liquid water, ice, aerosol or anything else that might make up to total air mass are ignored).
This is used to calculate the mixing ratio of water vapor in dry air :math:`r`

.. math::

    m_\text{total air} \approx m_\text{dry air} + m_\text{water vapor}

    q = m_\text{water vapor}/m_\text{total air} \approx m_\text{water vapor}/(m_\text{dry air} + m_\text{water vapor})

    \Rightarrow r = q/(1-q).

A floor of :math:`r = 1 \times 10^{-12} kg/kg` is applied:

.. math::

    r = \text{max}(q/(1-q), 1 \times 10^{-12}).

Lastly the relative humidity is calculated as the fraction

.. math::

    RH = \text{max}(r/r_\text{sat}, 1 \times 10^{-6}).

.. _VT-_SatVaporPres_fromTemp_Methods:

Method Names for Default Recipe
"""""""""""""""""""""""""""""""

The following method names are available to control :math:`h(T)` in the default recipe:

- **Rogers** | **default**:
  Classical formula from Rogers and Yau (1989; Eq2.17) for saturation vapor pressure over water.

  .. math::

      e_\text{sat w} = 1000 \times 0.6112 \times \exp\left(17.67 \times \frac{T - 2.7315 \times 10^{2}}{T - 29.65}\right)


- **Sonntag**:
  Eqn 7, Sonntag, D., Advancements in the field of hygrometry,
  Meteorol. Zeitschrift, N. F., 3, 51-66, 1994.
  Most radiosonde manufacturers use Wexler, or Hyland and Wexler
  or Sonntag formulations, which are all very similar (Holger Vomel,
  pers. comm., 2011)

  .. math::

      e_\text{sat w} = \exp\left(\frac{-6096.9385}{T} + 21.2409642 - 2.711193 \times 10^{-2}

                   \times T + 1.673952 \times 10^{-5} \times T^{2} + 2.433502 \times \log(T)\right)

- **Walko**:
  Polynomial fit of Goff-Gratch (1946) formulation (Walko, 1991).
  The Walko formulation is computationally fastest of all methods, but becomes less accurate at extremely low temperatures, below roughly -70C.

  .. math::

    e_\text{sat w} = c_{0}+x \times (c_{1}+x \times (c_{2}+x \times (c_{3}+x \times (c_{4}+

              x \times (c_{5}+x \times (c_{6}+x \times (c_{7}+x \times c_{8})))))))

  with:

  .. math::

     c = [610.5851, 44.40316, 1.430341, 0.2641412 \times 10^{-1},

          0.2995057 \times 10^{-3}, 0.2031998 \times 10^{-5}, 0.6936113 \times 10^{-8},

          0.2564861 \times 10^{-11}, -0.3704404 \times 10^{-13}]


- **Murphy**:
  Equation 10 of Murphy and Koop, Review of the vapour pressure of ice
  and supercooled water for atmospheric applications, Q. J. R. Meteorol.
  Soc (2005), 131, pp. 1539-1565.

  .. math::

     e_\text{sat w} = \exp\left(54.842763 - \frac{6763.22}{T} - 4.210 \times \log(T)

                   + 0.000367 \times T + tanh(0.0415 \times (T - 218.8))

                   \times (53.878 - \frac{1331.22}{T} - 9.44523 \times \log(T)

                   + 0.014025 \times T)\right)

- **GoffGratchLandoltBornsteinIceWater**
  Uses the Goff-Gratch formulae over ice below and including 273.15 K (0 C) and over water above 273.15 K, with calculations of the formulae retrieved from a lookup table.
  This table taken from "Landolt-Bornstein, 1987, Numerical Data and Functional relationships in Science and Technology. Group V/Vol 4B Meteorology. Physical and Chemical properties of Air, P35." with values converted to Pa.
  The original table covers the range 233 K to 303 K in increments of 1 K.
  The table used here covers temperatures from 183.15 K to 338.15 K in 0.1 K increments.
  The source of the extra values in the table is unclear but has been included to allow exact reproduction of the UKMO OPS code.

- **NCAR**
  Uses Rogers.

- **NOAA**
  Uses Rogers.



UKMO Method
^^^^^^^^^^^

This more complex method defines the relative humidity (:math:`RH`) as the ratio of the saturation specific humidity at the dew point temperature (:math:`q_\text{sat}(T_d)`) to the specific humidity at saturation at the dry bulb temperature (:math:`q_\text{sat}(T_\text{dry bulb})`).

.. math::

    RH = \frac{q_\text{sat}(T_d)}{q_\text{sat}(T_\text{dry bulb})} \times 100.

**Note:** the relative humidity is written to the ObsSpace as a percentage rather than a fraction.

The ``AllowSuperSaturation`` parameter has an effect here: if set to false, the reported value will be capped at 100%.


Observation parameters needed
"""""""""""""""""""""""""""""

- Pressure (:math:`P` reported in :math:`Pa`) - The variable name can be configured with the ``pressure at 2m variable``.
- Air temperature (:math:`T` reported in :math:`K`) - The variable name can be configured with the parameter ``temperature at 2m variable``.
- Dew point temperature (:math:`T_{dew point}` reported in :math:`K`) - The variable name can be configured with the parameter ``dew point temperature at 2m variable``.
- Relative humidity (:math:`RH`) - The variable name can be configured with the parameter ``relative humidity at 2m variable``.

If any of these variables are not found in the ``ObsValue`` group , the ``pressure variable`` (via the specific ``pressure group variable``), ``temperature variable``, ``dew point temperature variable`` and ``relative humidity variable`` are used instead.


Calculation Used
""""""""""""""""

This is not yet documented.
The reported value will be capped at 100% if the ``AllowSuperSaturation`` parameter is set to false.


UKMOmixingratio Method
^^^^^^^^^^^^^^^^^^^^^^

This method approximates the relative humidity (:math:`RH`) as the ratio of the mass of water vapor per unit mass of dry air (:math:`r`) to the specific humidity at saturation at the dry bulb temperature (:math:`q_\text{sat}(T_\text{dry bulb})`)

.. math::

    RH = \frac{r}{q_\text{sat}(T_\text{dry bulb})} \times 100.

**Note:** the relative humidity is written to the ObsSpace as a percentage rather than a fraction.

The ``AllowSuperSaturation`` parameter has an effect here: if set to false, the reported value will be capped at 100%.


Observation Parameters Needed
"""""""""""""""""""""""""""""

- Pressure (:math:`P` reported in :math:`Pa`) - The variable name can be configured with the ``pressure variable`` and ``pressure group variable`` parameters.
- Dry bulb temperature (:math:`T` reported in :math:`K`) - The variable name can be configured with the parameter ``temperature variable``.
- Water vapor mixing ratio (:math:`r`) - The variable name can be configured with the parameter ``water vapor mixing ratio variable``.
- Relative humidity (:math:`RH`) - The variable name can be configured with the parameter ``relative humidity variable``.


Calculation Used
""""""""""""""""

The saturation vapor pressure of pure water vapor over water or ice :math:`e_\text{sat w/i}` is calculated at the dry bulb temperature

.. math::

    e_\text{sat w/i} = h(T_\text{dry bulb}))

where :math:`h` uses the GoffGratchLandoltBornsteinIceWater formulation (see :ref:`default method names <VT-_SatVaporPres_fromTemp_Methods>`).
The :math:`w/i` subscript indicates that the saturation vapor pressure is calculated over water or ice depending on the temperature.

This is converted to a saturation vapor pressure in moist air :math:`e'_\text{sat w/i}`

.. math::

    e'_\text{sat w/i} = f_\text{w/i}(P, T_\text{dry bulb})) e_\text{sat w/i}

where the enhancement factor :math:`f_\text{w/i}` is taken from Eq. A4.6 of Gill (1982) "Atmosphere-Ocean Dynamics", Academic Press.
This approximates table 89 of the Smithsonian Meteorological Tables correct to 2 parts in :math:`10^4`.

The saturation specific humidity :math:`q_\text{sat}` at the dry bulb temperature can now be calculated by rearranging equation A4.3 in Gill (1982) giving

.. math::

    q_\text{sat} = \frac{\epsilon \times e'_\text{sat w/i}}{P - (1 - \epsilon) e'_\text{sat w/i}}.

where :math:`\epsilon` is the ratio of the gas constant for dry air (:math:`R_d`) to the gas constant for pure water vapor (:math:`R_v`).
However, to avoid asymptotic behaviour for :math:`P < e'_\text{sat w/i}`, the denominator is modified to ensure :math:`q_\text{sat} = 1 kg/kg` for :math:`P < e'_\text{sat w/i}`:

.. math::

    q_\text{sat} = \frac{\epsilon \times e'_\text{sat w/i}}{\text{max}(P, e'_\text{sat w/i}) - (1 - \epsilon)e'_\text{sat w/i}}.

The relative humidity :math:`RH` is then calculated as

.. math::

    RH = \frac{r}{q_\text{sat}} \times 100.

The reported value will not be over 100% if the ``AllowSuperSaturation`` parameter is set to false.


.. _VT-Specific-Humidity:

=================
Specific Humidity
=================

Calculates specific humidity (:math:`q`) from the temperature (:math:`T`), pressure (:math:`P`), and relative humidity (:math:`RH`).
Dewpoint temperature (:math:`T_d`) can be used if the relative humidity is not available.

------------------
Example yaml block
------------------

.. code-block:: yaml

    obs filters:
    - filter: Variable Transforms
      Transform: SpecificHumidity
      Method: Sonntag


-----------------------------
Observation parameters needed
-----------------------------

- Relative humidity (:math:`RH`) - The variable name can be configured with the parameter ``relative humidity variable``.
- Dew point temperature (:math:`T_d`) - Only looked for if a relative humidity variable is not found. The variable name can be configured with the parameter ``dew point temperature variable``.
- Air temperature (:math:`T`) - The variable name can be configured with the parameter ``temperature variable``.
- Pressure (:math:`P` reported in :math:`Pa`) - The variable name can be configured with the parameters ``pressure variable`` and ``pressure group variable``. If this variable is empty then the ``pressure at 2m variable`` is used instead: it is looked for in the ``ObsValue`` group.

-------
Methods
-------

All methods use the same equations, with the only difference being the formulation used to calculate the saturation vapor pressure from the temperature.
These methods are the same as those used in the default method family of the :ref:`Relative Humidity <VT-Relative-Humidity>` transform (see :ref:`default method names <VT-_SatVaporPres_fromTemp_Methods>`), with the addition of the following:

- **UKMO** Uses Sonntag
- **UKMOmixingratio** Uses GoffGratchLandoltBornsteinIceWater

If the relative humidity is supplied as an input, these methods **assume that the relative humidity has been calculated as the ratio of the mixing ratio of water vapor in dry air to the saturation mixing ratio of water vapor in dry air**

.. math::

    RH = \frac{r}{r_\text{sat}}.

----------------
Calculation Used
----------------

Relative humidity available
^^^^^^^^^^^^^^^^^^^^^^^^^^^

If the relative humidity :math:`RH` is available, the saturation vapor pressure :math:`e_\text{sat w/i}` is calculated using the formulation specified by the method

.. math::

    e_\text{sat w/i} = \text{min}(h(T), 0.15 \times P)

This is converted to the saturation vapor pressure in moist air :math:`e'_\text{sat w/i}`

.. math::

    e'_\text{sat w/i} = e_\text{sat w/i}

Note that a correction factor is **not** applied in this calculation: this is likely a mistake since atmospheric humidity variables are usually to be defined for moist air rather than pure water. The usual formulation is :math:`e'_\text{sat w/i} = f_\text{w/i} e_\text{sat w/i}`.

This is converted to the saturation mixing ratio of water vapor in dry air :math:`r_\text{sat}`

.. math::

    r_\text{sat} = \frac{\epsilon \times e'_\text{sat w/i}}{P - e'_\text{sat w/i}}

where :math:`\epsilon` is the ratio of the gas constant for dry air (:math:`R_d`) to the gas constant for pure water vapor (:math:`R_v`).

Since the relative humidity is assumed to be :math:`RH = r/r_\text{sat}`, the mixing ratio is calculated as

.. math::

    r = RH \times r_\text{sat}

which is then converted to the specific humidity :math:`q`

.. math::

    q = r/(1+r)

where, since :math:`r = m_\text{water vapor}/m_\text{dry air}`,

.. math::

    q = \frac{m_\text{water vapor}}{m_\text{dry air} + m_\text{water vapor}}

i.e. it is assumed that :math:`m_\text{total air} = m_\text{dry air} + m_\text{water vapor}`.

Relative humidity unavailable
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

If the dew point temperature (:math:`T_d`) is reported, the vapor pressure and mixing ratio can be calculated directly (i.e. without the need to calculate anything at saturation):

.. math::

    e = \text{min}(h(T_d), 0.15 \times P)

    e' = e

    r = \frac{\epsilon \times e'}{P - e'}

    q = r/(1+r).

Note that relative humidity is not used, so no assumptions are made about how it is defined.


.. _VT-Virtual-Temperature:

===================
Virtual Temperature
===================

This humidity transform has not yet been documented.
