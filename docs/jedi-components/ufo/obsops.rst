.. _top-ufo-obsops:

Observation Operators in UFO
=============================

Vertical Interpolation (VertInterp)
-----------------------------------

Description:
^^^^^^^^^^^^
Vertical interpolation observation operator implements linear interpolation in vertical coordinate. If vertical coordinate is air_pressure, interpolation is done in logarithm of air pressure. For all other vertical coordinates interpolation is done in specified coordinate (no logarithm applied)

Code:
^^^^^

`ufo/vertinterp/`

Configuration options:
^^^^^^^^^^^^^^^^^^^^^^
* VertCoord [optional] : specifies which vertical coordinate to use in interpolation. If air_pressure is used, the interpolation is done in log(air pressure). Default value is air pressure.

Examples of yaml:
^^^^^^^^^^^^^^^^^
.. code:: yaml

  ObsOperator:
    name: VertInterp

ObsOperator in the above example does vertical interpolation in log(air pressure).

.. code:: yaml

  ObsOperator:
    name: VertInterp
    VertCoord: height

ObsOperator in the above example does vertical interpolation in height.

(AtmSfcInterp)
-----------------------------------

Description:
^^^^^^^^^^^^

Code:
^^^^^

Configuration options:
^^^^^^^^^^^^^^^^^^^^^^

Examples of yaml:
^^^^^^^^^^^^^^^^^

(AtmVertInterpLay)
-----------------------------------

Description:
^^^^^^^^^^^^

Code:
^^^^^

Configuration options:
^^^^^^^^^^^^^^^^^^^^^^ 

Examples of yaml:
^^^^^^^^^^^^^^^^^

(CRTM)
-----------------------------------

Description:
^^^^^^^^^^^^

Code:
^^^^^

Configuration options:
^^^^^^^^^^^^^^^^^^^^^^ 

Examples of yaml:
^^^^^^^^^^^^^^^^^

(AOD)
-----------------------------------

Description:
^^^^^^^^^^^^

Code:
^^^^^

Configuration options:
^^^^^^^^^^^^^^^^^^^^^^ 

Examples of yaml:
^^^^^^^^^^^^^^^^^

(GnssroBndBNAM)
-----------------------------------

Description:
^^^^^^^^^^^^

Code:
^^^^^

Configuration options:
^^^^^^^^^^^^^^^^^^^^^^ 

Examples of yaml:
^^^^^^^^^^^^^^^^^

(GnssroBndROPP1D)
-----------------------------------

Description:
^^^^^^^^^^^^

Code:
^^^^^

Configuration options:
^^^^^^^^^^^^^^^^^^^^^^ 

Examples of yaml:
^^^^^^^^^^^^^^^^^

(GnssroBndROPP2D)
-----------------------------------

Description:
^^^^^^^^^^^^

Code:
^^^^^

Configuration options:
^^^^^^^^^^^^^^^^^^^^^^ 

Examples of yaml:
^^^^^^^^^^^^^^^^^

(GnssroRefGsi)
-----------------------------------

Description:
^^^^^^^^^^^^

Code:
^^^^^

Configuration options:
^^^^^^^^^^^^^^^^^^^^^^ 

Examples of yaml:
^^^^^^^^^^^^^^^^^

(Identity)
-----------------------------------

Description:
^^^^^^^^^^^^

Code:
^^^^^

Configuration options:
^^^^^^^^^^^^^^^^^^^^^^ 

Examples of yaml:
^^^^^^^^^^^^^^^^^

(ADT)
-----------------------------------

Description:
^^^^^^^^^^^^

Code:
^^^^^

Configuration options:
^^^^^^^^^^^^^^^^^^^^^^ 

Examples of yaml:
^^^^^^^^^^^^^^^^^

(CoolSkin)
-----------------------------------

Description:
^^^^^^^^^^^^

Code:
^^^^^

Configuration options:
^^^^^^^^^^^^^^^^^^^^^^ 

Examples of yaml:
^^^^^^^^^^^^^^^^^

(InsituTemperature)
-----------------------------------

Description:
^^^^^^^^^^^^

Code:
^^^^^

Configuration options:
^^^^^^^^^^^^^^^^^^^^^^ 

Examples of yaml:
^^^^^^^^^^^^^^^^^

(MarineVertInterp)
-----------------------------------

Description:
^^^^^^^^^^^^

Code:
^^^^^

Configuration options:
^^^^^^^^^^^^^^^^^^^^^^ 

Examples of yaml:
^^^^^^^^^^^^^^^^^

(SeaIceFraction)
-----------------------------------

Description:
^^^^^^^^^^^^

Code:
^^^^^

Configuration options:
^^^^^^^^^^^^^^^^^^^^^^ 

Examples of yaml:
^^^^^^^^^^^^^^^^^

(SeaIceThickness)
-----------------------------------

Description:
^^^^^^^^^^^^

Code:
^^^^^

Configuration options:
^^^^^^^^^^^^^^^^^^^^^^ 

Examples of yaml:
^^^^^^^^^^^^^^^^^

(RadialVelocity)
-----------------------------------

Description:
^^^^^^^^^^^^

Code:
^^^^^

Configuration options:
^^^^^^^^^^^^^^^^^^^^^^ 

Examples of yaml:
^^^^^^^^^^^^^^^^^

(RadarReflectivity)
-----------------------------------

Description:
^^^^^^^^^^^^

Code:
^^^^^

Configuration options:
^^^^^^^^^^^^^^^^^^^^^^ 

Examples of yaml:
^^^^^^^^^^^^^^^^^

(RTTOV)
-----------------------------------

Description:
^^^^^^^^^^^^

Code:
^^^^^

Configuration options:
^^^^^^^^^^^^^^^^^^^^^^ 

Examples of yaml:
^^^^^^^^^^^^^^^^^

(TimeOper)
-----------------------------------

Description:
^^^^^^^^^^^^

Code:
^^^^^

Configuration options:
^^^^^^^^^^^^^^^^^^^^^^ 

Examples of yaml:
^^^^^^^^^^^^^^^^^
