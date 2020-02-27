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

Interface to the Community Radiative Transfer Model (CRTM) as an observational operator.

Code:
^^^^^

:code:`ufo/crtm/`

Configuration options:
^^^^^^^^^^^^^^^^^^^^^^

The CRTM operator has some required geovals (see varin_default in ufo/crtm/ufo_radiancecrtm_mod.F90). The configurable geovals are as follows:

* Absorbers : CRTM atmospheric absorber species that will be requested as geovals.  H2O and O3 are always required. So far H2O, O3, CO2 are implemented. More species can be added readily by extending UFO_Absorbers and CRTM_Absorber_Units in ufo/crtm/ufo_crtm_utils_mod.F90.
* Clouds [optional] : CRTM cloud constituents that will be requested as geovals; can include any of Water, Ice, Rain, Snow, Graupel, Hail
* Cloud_Fraction [optional] : sets the CRTM Cloud_Fraction to a constant value across all profiles (e.g., 1.0). Omit this option in order to request cloud_area_fraction_in_atmosphere_layer as a geoval from the model.

* LinearObsOperator [optional] : used to indicate a different configuration for K-Matrix multiplication of tangent linear and adjoint operators from the configuration used for the Forward operator.  The same profile is used in the CRTM Forward and K_Matrix calculations. Only the interface to the model will be altered. Omit LinearObsOperator in order to use the same settings across Forward, Tangent Linear, and Adjoint operators.
* LinearObsOperator.Absorbers [optional] : controls which of the selected Absorbers will be acted upon in K-Matrix multiplication
* LinearObsOperator.Clouds [optional] : controls which of the selected Clouds will be acted upon in K-Matrix multiplication

ObsOptions configures the tabulated coeffecient files that are used by CRTM
* ObsOptions.Sensor_ID : {sensor}_{platform} prefix of the sensor-specific coefficient files, e.g., amsua_n19
* ObsOptions.EndianType : Endianness of the coefficient files. Either little_endian or big_endian.
* ObsOptions.CoefficientPath : location of all coefficient files

* ObsOptions.IRwaterCoeff [optional] : options: [Nalli (D), WuSmith]
* ObsOptions.VISwaterCoeff [optional] : options: [NPOESS (D)]
* ObsOptions.IRVISlandCoeff [optional] : options: [NPOESS (D), USGS, IGBP]
* ObsOptions.IRVISsnowCoeff [optional] : options: [NPOESS (D)]
* ObsOptions.IRVISiceCoeff [optional] : options: [NPOESS (D)]
* ObsOptions.MWwaterCoeff [optional] : options: [FASTEM6 (D), FASTEM5, FASTEM4]

Examples of yaml:
^^^^^^^^^^^^^^^^^

.. code:: yaml

  ObsOperator:
    name: CRTM
    Absorbers: [H2O, O3]
    Clouds: [Water, Ice, Rain, Snow, Graupel, Hail]
    LinearObsOperator:
      Absorbers: [H2O]
      Clouds: [Water, Ice]
    ObsOptions:
      Sensor_ID: amsua_n19
      EndianType: little_endian
      CoefficientPath: Data/

.. code:: yaml

  ObsOperator:
    name: CRTM
    Absorbers: [H2O, O3, CO2]
    Clouds: [Water, Ice]
    Cloud_Fraction: 1.0
    ObsOptions:
      Sensor_ID: iasi_metop-a
      EndianType: little_endian
      CoefficientPath: Data/
      IRVISlandCoeff: USGS

.. code:: yaml

  ObsOperator:
    name: CRTM
    Absorbers: [H2O, O3]
    LinearObsOperator:
      Absorbers: [H2O]
    ObsOptions:
      Sensor_ID: abi_g16
      EndianType: little_endian
      CoefficientPath: Data/

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
