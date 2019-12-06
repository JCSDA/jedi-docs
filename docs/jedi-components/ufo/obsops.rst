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

:code:`ufo/vertinterp/`

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

Atmosphere Vertical Layer Interpolation (AtmVertInterpLay)
----------------------------------------------------------

Description:
^^^^^^^^^^^^

Observational operator for vertical summation of model layers within an observational atmospheric layer where the top and bottom pressure levels are specified in cbars.

Code:
^^^^^

:code:`ufo/atmvertinterplay/`

Configuration options:
^^^^^^^^^^^^^^^^^^^^^^

Examples of yaml:
^^^^^^^^^^^^^^^^^

.. code:: yaml

  ObsOperator:
    name: AtmVertInterpLay

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

Radar Reflectivity (RadarReflectivity)
--------------------------------------

Description:
^^^^^^^^^^^^

UFO radar operator for reflectivity. It is tested with radar observations dumped from a specific modified GSI program at NSSL for the Warn-on-Forecast project.

Code:
^^^^^

.. code:: bash

  ufo/radarreflectivity

    CMakeLists.txt
    ObsRadarReflectivity.cc
    ObsRadarReflectivity.h
    ObsRadarReflectivity.interface.F90
    ObsRadarReflectivity.interface.h
    ObsRadarReflectivityTLAD.cc
    ObsRadarReflectivityTLAD.h
    ObsRadarReflectivityTLAD.interface.F90
    ObsRadarReflectivityTLAD.interface.h
    ufo_radarreflectivity_mod.F90
    ufo_radarreflectivity_tlad_mod.F90

Configuration options:
^^^^^^^^^^^^^^^^^^^^^^

Examples of yaml:
^^^^^^^^^^^^^^^^^

See :code:`test/testinput/reflectivity.yaml`

.. code:: yaml

  window_begin: 2019-05-22T21:55:00Z
  window_end: 2019-05-22T22:05:00Z

  LinearObsOpTest:
    coefTL: 0.1
    toleranceTL: 1.0e-13
    toleranceAD: 1.0e-11

  Observations:
    ObsTypes:
    - ObsOperator:
        name: RadarReflectivity
        VertCoord: geopotential_height
      ObsSpace:
        name: Radar
        ObsDataIn:
          obsfile: Data/radar_dbz_obs_2019052222.nc4
        simulate:
          variables: [equivalent_reflectivity_factor]
      GeoVaLs:
        filename: Data/radar_dbz_geoval_2019052222.nc4
      vecequiv: GsiHofX
      tolerance: 1.0e-05


Radar Radial Velocity (Radarradialvelocity)
-------------------------------------------

Description:
^^^^^^^^^^^^

Similar to RadarReflectivity, but for radial velocity. It is tested with radar observations dumped from a specific modified GSI program at NSSL for the Warn-on-Forecast project.

Code:
^^^^^

.. code:: bash

   ufo/radarradialvelocity

     CMakeLists.txt
     ObsRadarRadialVelocity.cc
     ObsRadarRadialVelocity.h
     ObsRadarRadialVelocity.interface.F90
     ObsRadarRadialVelocity.interface.h
     ObsRadarRadialVelocityTLAD.cc
     ObsRadarRadialVelocityTLAD.h
     ObsRadarRadialVelocityTLAD.interface.F90
     ObsRadarRadialVelocityTLAD.interface.h
     ufo_radarradialvelocity_mod.F90
     ufo_radarradialvelocity_tlad_mod.F90

Configuration options:
^^^^^^^^^^^^^^^^^^^^^^

Examples of yaml:
^^^^^^^^^^^^^^^^^

see :code:`test/testinput/radialvelocity.yaml`

.. code:: yaml

  window_begin: 2019-05-22T21:55:00Z
  window_end: 2019-05-22T22:05:00Z

  LinearObsOpTest:
    coefTL: 0.1
    toleranceTL: 1.0e-13
    toleranceAD: 1.0e-11

  Observations:
    ObsTypes:
    - ObsOperator:
        name: RadarRadialVelocity
      ObsSpace:
        name: Radar
        ObsDataIn:
          obsfile: Data/radar_rw_obs_2019052222.nc4
        simulate:
          variables: [radial_velocity]
      ObsFilters:
      - Filter: Domain Check
        variables: [radial_velocity]
        where:
        - variable: height@MetaData
          minvalue: 0
          maxvalue: 10000
      GeoVaLs:
        filename: Data/radar_rw_geoval_2019052222.nc4
      vecequiv: GsiHofX
      tolerance: 1.0e-05


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
