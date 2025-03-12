.. _VisibilityDiagnostic:

VisibilityDiagnostic
====================

This obsfunction computes a visibility (in meters) given input obs space variables (i.e. GeoVals or observations) and a set of parameters.

This follows the method outlined in Clark et al. (2008) [1]_.

The visibility is assumed to only be limited by (potentially wet) aerosol particles, subject to some visibility limit.

Required Obs Space Variables
----------------------------

- Relative Humidity (unitless fraction): this is specified via the :code:`relative humidity variable` parameter. Both the group and variable name must be specified, for example ``ObsValue/relativeHumidityAt2M``.
- Pressure (Pa): this is specified via the :code:`pressure variable` parameter. Both the group and variable name must be specified, for example ``ObsValue/surfacePressure``.
- Temperature (K): this is specified via the :code:`temperature variable` parameter. Both the group and variable name must be specified, for example ``ObsValue/temperatureAt2M``.

Other Parameters
----------------

- :code:`critical relative humidity` (unitless fraction - *Required*): that at which liquid water droplets are considered to form (:math:`RH_\text{crit}` below).

The below parameterize the RH_TO_CC diagnostic taken from the UK Met Office Unified Model, as used in the Met Office Observation Processing System (OPS).
This calculates a cloud cover fraction, a proxy for the presence of mist or fog, from relative humidity.

- :code:`cloud cover parameter 1` (unitless - *Required*): Corresponds to :math:`\text{ccp1}` in the diagnostic.
- :code:`cloud cover parameter 2` (unitless - *Required*): As above, but corresponds to :math:`\text{ccp2}`.
- :code:`cloud cover parameter 3` (unitless - *Required*): As above, but corresponds to :math:`\text{ccp3}`.

The relative humidity is capped to 1.0 (i.e. 100% - referred to below as :math:`RH_\text{capped}`).
The cloud cover fraction is then calculated as:

  .. math::

      CC = \begin{cases}
      0 & \text{if } RH_\text{capped} \leq RH_\text{crit}, \\
      \left(2 \times \cos\left(\text{ccp3} + \frac{1}{3}\arccos\left(\text{ccp1} \times \frac{RH_\text{capped} - RH_\text{crit}}{1 - RH_\text{crit}}\right)\right)\right)^2 & \text{if } RH_\text{capped} < \frac{5 + RH_\text{crit}}{6}, \\
      1 - \left(\text{ccp2} \times \frac{1 - RH_\text{capped}}{1 - RH_\text{crit}}\right)^{\frac{2}{3}} & \text{otherwise.}
      \end{cases}

The below parameterize the CC_TO_RHTOT diagnostic taken from the UK Met Office Unified Model, as used in the Met Office Observation Processing System (OPS).
In that diagnostic, total water relative humidity is associated with cloud cover via a piecewise function, derived from a triangular distribution.
This is consistent with the Smith (1990) cloud scheme [2]_.

- :code:`total water relative humidity parameter 1` (unitless fraction - *Required*): The cloud cover fraction at which the piecewise function transitions (:math:`\text{P1}` below).
- :code:`total water relative humidity parameter 2` (unitless - *Required*): The scaling to apply to the cloud cover fraction within the first part of the piecewise function (:math:`\text{P2}` below).
- :code:`total water relative humidity parameter 3` (unitless - *Required*): The scaling to apply to :math:`(1 - CC)`, where :math:`CC` is the cloud cover fraction, within the second part of the piecewise function (:math:`\text{P3}` below).

The cloud cover is first limited to the inclusive range :math:`[0, 1]`, then the total water relative humidity is calculated as:

.. math::
    RH_\text{tot} = \begin{cases}
    1 + (1 - RH_\text{crit}) \left(\sqrt{\text{P2} \cdot CC} - 1\right) & \text{if } CC \leq \text{P1}, \\
    1 + (1 - RH_\text{crit}) \left(1 - \sqrt{\text{P3} \cdot (1 - CC)}\right) & \text{otherwise.}
    \end{cases}

The below parameters correspond to variables found in the Clark 2008 paper [1]_.

- :code:`aerosol mass concentration` (kg kg\ :sup:`-1` - *Required*): :math:`m` in Eq. 1 - also known as the dry aerosol mass mixing ratio.
- :code:`aerosol density` (kg m\ :sup:`-3` - *Optional - Default 1700*): :math:`\rho` in Eq. 1
- :code:`standard aerosol radius` (m - *Optional - Default 0.16E-6*): :math:`r_0` in Eq. 2
- :code:`standard aerosol number density` (m\ :sup:`-3` - *Optional - Default 5E6*): :math:`N_0` in Eq. 3
- :code:`air density` (kg m\ :sup:`-3` - *Optional - Default 1.0*): :math:`\rho_\text{a}` in Eq. 1
- :code:`water density` (kg m\ :sup:`-3` - *Optional - Default 1000.0*): :math:`\rho_\text{wat}` in Eq. 13
- :code:`aerosol size distribution power law exponent` (unitless - *Optional - Default 1/6*): :math:`p` in Eq. 2
- :code:`Koehler curve constant A` (m - *Optional - Default 1.2E-9*): :math:`A` in Eq. 10: related to the surface tension of water
- :code:`Koehler curve constant B` (unitless - *Optional - Default 0.5*): :math:`B` in Eq. 10 - the "activation parameter"
- :code:`liminal contrast` (unitless - *Optional - Default 0.02*): :math:`\epsilon` in Eq. 7 - for calculation of the extinction coefficient
- :code:`extinction efficiency factor Q` (unitless - *Optional - Default 2.0*): :math:`Q` in Eq. 16 - for calculation of the extinction coefficient
- :code:`particle size weighting factor eta` (unitless - *Optional - Default 0.75*): :math:`\eta` in Eq. 19 - for calculation of the extinction coefficient
- :code:`visibility limit` (m - *Optional - Default 10000*): used in place of the extinction coefficient of air to limit unrealistically high visibilities (see text after Eq. 8)

The below parameters are specific to the Newton-Raphson method used to estimate the particle radius :math:`r_m` given the atmospheric conditions.
Equation numbers continue to refer to Clark 2008, referenced above.

- :code:`minimum total water specific humidity` (kg kg\ :sup:`-1` - *Optional - Default 0.001*): :math:`q_T^\text{min}`
- :code:`minimum relative humidity for first guess` (unitless fraction - *Optional - Default 0.01*): for calculating the first guess of the particle radius.
- :code:`maximum relative humidity for first guess` (unitless fraction - *Optional - Default 0.999*): for calculating the first guess of the particle radius.
- :code:`minimum allowed normalized droplet radius` (m m\ :sup:`-1` - *Optional - Default 2.0*): :math:`r_m^\text{min}/r_{md}` - minimum allowed wet particle (droplet) radius, normalized by the mean dry radius :math:`r_{md}`. The expression for :math:`r_{md}` is Eq. 2.
- :code:`maximum allowed normalized droplet radius` (m m\ :sup:`-1` - *Optional - Default 10000.0*): :math:`r_m^\text{max}/r_{md}` - maximum allowed wet particle (droplet) radius, normalized by the mean dry radius :math:`r_{md}`. The expression for :math:`r_{md}` is Eq. 2.
- :code:`maximum number of iterations` (unitless - *Optional - Default 10*): maximum number of iterations for the Newton-Raphson loop.
- :code:`maximum inflation factor` (m m\ :sup:`-1` - *Optional - Default 2.0*): maximum allowed droplet radius inflation factor for each iteration of the Newton-Raphson loop (i.e. :math:`\text{max}(r_m^{n+1}/r_m^n)`).
- :code:`minimum inflation factor` (m m\ :sup:`-1` - *Optional - Default 0.5*): minimum allowed droplet radius inflation factor for each iteration of the Newton-Raphson loop (i.e. :math:`\text{min}(r_m^{n+1}/r_m^n)`).
- :code:`loop stopping value` (m m\ :sup:`-1` - *Optional - Default 0.01*): the maximum allowed difference between the normalized droplet radius :math:`r_m/r_{md}` at iteration :math:`n` and :math:`n+1`.
- :code:`droplet radius exponential smoothing factor` (unitless - *Optional - Default 0.9*): the exponential smoothing factor to apply to previous and current droplet radius at the start of the Newton-Raphson loop before continuing: if 1.0, then the previous droplet radius becomes the new droplet radius and no smoothing is applied. If 0.0, the smoothing is infinite and the loop will always keep the first guess of the droplet radius.

Example
-------

.. code-block:: yaml

  - filter: Variable Assignment
    assignments:
    - name: MetaData/diagnosedVisibility
      type: float
      function:
        name: ObsFunction/VisibilityDiagnostic
        options:
          aerosol mass concentration: 1E-9  # Required
          relative humidity variable:  # Required
            name: ObsValue/relativeHumidityAt2M
          pressure variable:  # Required
            name: GeoVals/surfacePressure
          temperature variable: # Required
            name: ObsValue/airTemperatureAt2M
          critical relative humidity: 0.940  # Required
          cloud cover parameter 1: 1.060660172  # 3*sqrt(2)/4 - Required
          cloud cover parameter 2: 2.121320344  # 3*sqrt(2)/2 - Required
          cloud cover parameter 3: 1.047197551  # pi/3 - Required
          total water relative humidity parameter 1: 0.5  # Required
          total water relative humidity parameter 2: 2.0  # Required
          total water relative humidity parameter 3: 2.0  # Required
          aerosol density: 1700  # Optional - same default as paper
          standard aerosol radius: 0.16E-6  # Optional - same default as paper
          standard aerosol number density: 5.0E+8  # Optional - same default as paper
          air density: 1.0  # Optional - same default as paper
          water density: 1000. # Optional - same default as paper
          aerosol size distribution power law exponent:  0.1666666667  # 1/6 - optional - same default as paper
          Koehler curve constant A: 1.2E-9  # Optional - same default as paper
          Koehler curve constant B: 0.5  # Optional - same default as paper
          liminal contrast: 0.02  # Optional - same default as paper
          extinction efficiency factor Q: 2.0  # Optional - same default as paper
          particle size weighting factor eta: 0.75  # Optional - same default as paper
          visibility limit: 100000  # Optional - same default as paper
          minimum total water specific humidity:  0.001  # Optional
          minimum relative humidity for first guess: 0.01  # Optional
          maximum relative humidity for first guess: 0.999  # Optional
          minimum allowed normalized droplet radius: 2.0  # Optional
          maximum allowed normalized droplet radius: 10000.0  # Optional
          maximum number of iterations: 10  # Optional
          maximum inflation factor: 2.0  # Optional
          minimum inflation factor: 0.5  # Optional
          loop stopping value: 0.01  # Optional
          droplet radius exponential smoothing factor: 0.9  # Optional

References
----------

.. [1] Clark, Peter A., et al. "Prediction of visibility and aerosol within the operational Met Office Unified Model. I: Model formulation and variational assimilation." Quarterly Journal of the Royal Meteorological Society 134.636 (2008): 1801-1816. DOI 10.1002/qj.318.

.. [2] Smith, R. N. B. "A scheme for predicting layer clouds and their water content in a general circulation model." Quarterly Journal of the Royal Meteorological Society 116.492 (1990): 435-460. DOI 10.1002/qj.4971164910.
