
.. _VT-surfacepressure:

=============================================
Model surface pressure
=============================================
Performs a variable conversion to presure at model surface height from: 

- Station pressure (stationPressure)
- Pressure reduced to sea level (pressureReducedToMeanSeaLevel)
- The derived height of a standard pressure surface (standardPressure)

:code:`Transform: PStar`

.. code-block:: yaml

    obs filters:
    - filter: Variable Transforms
      Transform: PStar
    
**Observation parameters needed** (JEDI name)

The default option for this transform requires the following observed variables:

- stationPressure 
- pressureReducedToMeanSeaLevel
- standardPressure

The following GeoVaLs are also required: 

- surf_param_a (:math:`A`)
- surf_param_b (:math:`B`)
- height
- stationPressure (:math:`P_{*b}`)
 
**Method(s) available**

Only one method is available, shared across all center options. (Any setting of :code:`METHOD` will result
in using this unique method.) Setting :code:`METHOD` can be omitted.

The derivation of observed pressure at the model surface is separated into two steps:

1. Determine the background pressure at the observation location,

   .. math::

     P_{rb} = \left[\frac{A - z}{B}\right]^{g/RL},

   where :math:`z` is the height of the observation and :math:`g`, :math:`R` and :math:`L` are standard constants. 
2. Calculate the observed pressure at model level:  

   .. math::

     P_{*o} = P_{ro}\frac{P_{*b}}{P_{rb}}

   where :math:`P_{ro}` is the observed pressure value.

The surface pressure is calculated for all observed pressures. A set of diagnostic flags, and the existence of the observed pressures, are used to determine which of the derived :math:`P_{*o}` are used as the final observed surface pressure. 

**Formulation(s) available**

None

.. _VT-qnhtoqfepressure:

===========================================================================
Convert 'nautical height' pressure to 'field elevation' pressure for METARs
===========================================================================

This transform, which is only applicable to METAR data,
converts QNH (Query: Nautical Height) pressure to QFE (Query: Field Elevation) pressure
using parameters associated with the ICAO standard atmosphere.
QNH pressure is the pressure measured at mean sea level, and QFE pressure is the
mean sea level pressure corrected for temperature and station altitude.

The transform also adds a bias correction to reports that have been rounded down to the nearest whole hPa.

The equations appear in ICAO (2011) Manual on Automatic Meterological Observing Systems at Aerodromes Doc 9837 AN/454 (chapter 9).

The transform can be used in a yaml file as follows:

:code:`Transform: QNHtoQFEpressure`

.. code-block:: yaml

    obs filters:
    - filter: Variable Transforms
      Transform: QNHtoQFEpressure

There are no configurable parameters for this transform.

**Variables required**

The default option for this transform requires the following observed variables:

- stationPressure
- pressureReducedToMeanSeaLevel (corresponds to QNH pressure; referred to as :math:`p_{MSL}` in the text below).

Observation errors must be present for the stationPressure variable. These errors are referred to as
:math:`\sigma_{p}` below.

Station height (referred to as :math:`z` below) is retrieved from either correctedStationAltitude or stationElevation in the MetaData group.
If both are present then correctedStationAltitude is preferred.

Finally the following diagnostic flags must have been created using the :ref:`Create Diagnostic Flags filter <create-diagnostic-flags-filter>`:

- DiagnosticFlags/notRounded/stationPressure
- DiagnosticFlags/QNHinHg/stationPressure
- DiagnosticFlags/QNHhPa/stationPressure

Prior to performing the transform, the user must set the notRounded flag appropriately depending on the nature of the input data.

**Method(s) available**

Only one method is available, shared across all center options. (Any setting of :code:`METHOD` will result
in using this unique method.) Setting :code:`METHOD` can be omitted.

The conversion of QNH to QFE pressure occurs for each observation as follows.
If either :math:`z` or :math:`p_{MSL}` are missing for an observation then no calculation is performed and the
QFE pressure is recorded as missing for that observation.

1. Let altimeter pressure :math:`p_{alt}` be equal to :math:`p_{MSL}`:

   .. math::

     p_{alt} = p_{MSL}.

2. If the notRounded diagnostic flag has been set to :code:`false` in a previous QC step and :math:`p_{alt}` is a multiple of
   100 Pa, add 50 Pa to :math:`p_{alt}` in order to account for bias caused by rounding.
   Correspondingly inflate the error as follows:

   .. math::

    \sigma_{p} \to \sqrt{\sigma_{p}^{2} + 2500/3}.

   The extra uncertainty relates to that assigned to a uniform distribution spanning :math:`\pm 50` Pa.

   Set the QNHhPa diagnostic flag to :code:`true` if this correction is performed.
   Otherwise, set the QNHinHg diagnostic flag to :code:`true`.

3. Compute a quantity (:math:`H`) from :math:`p_{alt}` and :math:`z` as follows:

   .. math::

    H = \frac{T_{S}}{L} \left(1 - \frac{p_{alt}}{p_{S}} \right)^{k}  + z

   where :math:`T_{S}`, :math:`p_{S}` and :math:`L` are the surface temperature (K), surface pressure (Pa), and
   lower troposphere lapse rate (K/m) in the ICAO standard atmosphere.
   The parameter :math:`k\equiv LR_{d}/g`, where :math:`R_d` is the gas constant for dry air and
   :math:`g` is the gravitational constant.

4. Finally compute QFE pressure from :math:`H`:

   .. math::

    p = \left(\frac{C_{1} - H}{C_{2}}\right)^{1/k}

   where :math:`C_{1} \equiv T_{S}/L`, :math:`C_{2} \equiv C_{1}/p_{S}^{k}`.


**Formulation(s) available**

None
