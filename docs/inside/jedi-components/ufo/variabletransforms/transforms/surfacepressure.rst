
.. _VT-surfacepressure:

=============================================
Model surface pressure
=============================================
Performs a variable conversion to presure at model surface height from: 

- Station pressure (stationPressure)
- Pressure reduced to sea level (pressureReducedToMeanSeaLevel)
- The derived height of a standard pressure surface (standardPressure)

:code:`Transform: ["PStar"]`

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
- surface_altitude
- surface_pressure (:math:`P_{*b}`)
 
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

