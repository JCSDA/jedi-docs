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

coefficients: to specify the observation units
nlevels: to specify the number of observation pressure levels

Examples of yaml:
^^^^^^^^^^^^^^^^^

.. code:: yaml

window begin: 2018-04-14T20:30:00Z
window end: 2018-04-15T03:30:00Z

observations:
- obs operator:
    name: AtmVertInterpLay
    geovals: [mole_fraction_of_ozone_in_air]
    coefficients: [0.007886131] # convert from ppmv to DU
    nlevels: [22]
  obs space:
    name: OzoneLayer
    obsdatain:
      obsfile: Data/ioda/testinput_tier_1/sbuv2_n19_obs_2018041500_m.nc4
    obsdataout:
      obsfile: Data/sbuv2_n19_obs_2018041500_m_out.nc4
    simulated variables: [integrated_layer_ozone_in_air]
  geovals:
    filename: Data/sbuv2_n19_geoval_2018041500_m.nc4
  vector ref: GsiHofX
  tolerance: 1.0e-04  # in % so that corresponds to 10^-3
  linear obs operator test:
    coef TL: 0.1
    tolerance TL: 1.0e-9
    tolerance AD: 1.0e-11

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

Description: The operator to calculate Aerosol Optical Depth for GOCART aerosol parameterization. It relies on the implementation of GOCART in the CRTM. This implementation includes hydorphillic and hydrophobic black and organic carbonaceous species, sulphate, five dust bins (radii: 0.1-1, 1.4-1.8, 1.8-3.0, 3.0-6.0, 6.0-10. um), and four sea-salt bins (dry aerosol radii: 0.1-0.5, 0.5-1.5, 1.5-5.0, 5.0-10.0 um). AOD is calculated using CRTM's tables of optical properties for these aerosols. Some modules are shared with CRTM radiance UFO.
On input, the operator requires aerosol mixing ratios, interface and mid-layer pressure, air temperature and specific / relative humidity for each model layer.

^^^^^^^^^^^^

Code:
:code:`ufo/crtm/`

Configuration options:
^^^^^^^^^^^^^^^^^^^^^^

Absorbers: (Both are required; No clouds since AOD retrievals are not obtained in cloudy regions):
* H2O to determine radii of hygrophillic aerosols particles
* O3 not strictly affecting aerosol radiative properties but required to be entered by the CRTM (here mixing ratio assigned a default value)

ObsOptions:
* Sensor_ID: v.viirs-m_npp
* Other possibilities: v.modis_aqua, v.modis_terra
AerosolOption: aerosols_gocart_default (Currently, that's the only one that works)

Example of a yaml:
^^^^^^^^^^^^^^^^^^
.. code:: yaml

   ObsOperator:
     name: Aod
     Absorbers: [H2O,O3]
     ObsOptions:
       Sensor_ID: v.viirs-m_npp
       EndianType: little_endian
       CoefficientPath: Data/
       AerosolOption: aerosols_gocart_default

(GnssroBndBNAM)
-----------------------------------

Description:
^^^^^^^^^^^^

A one-dimensional observation operator for calculating the Global
Navigation Satellite System (GNSS) Radio Occultation (RO) bending
angle data based on the  NBAM (NCEP's Bending Angle Method)

Code:
^^^^^

:code:`ufo/gnssro/BndNBAM`

Configuration options:
^^^^^^^^^^^^^^^^^^^^^^

1. configurables in "ObsOperator" section:

  a. vertlayer: if air pressure and geopotential height are read on the interface layer or the middle layer

    - options: "mass" or "full" (default is full)

  b. super_ref_qc: if use the "NBAM" or "ECMWF" method to do super refraction check.

    - options: "NBAM" or "ECMWF" ("NBAM" is default)

  c. sr_steps: when using the "NBAM" suepr refraction, if apply one or two step QC.

    - options: default is two-step QC following NBAM implementation in GSI.

  d. use_compress: compressibility factors in geopotential heights. Only for NBAM.

    - options: 1 to turn on; 0 to turn off. Default is 1.

2. configurables in "ObsSpace" section:

  a. obsgrouping: applying record_number as group_variable can get RO profiles in ufo. Otherwise RO data would be treated as single observations.

3. configurables in "ObsFilters" section:

  a. Domain Check: a generic filter used to control the maximum height one wants to assimilate RO observation.Default value is 50 km.

  b. ROobserror: A RO specific filter. use generic filter class to apply observation error method.
         options: NBAM, NRL,ECMWF, and more to come. (NBAM is default)

  c. Background Check: the background check for RO can use either the generic one (see the filter documents) or the  RO specific one based on the NBAM implementation in GSI.
        options: "Background Check" for the JEDI generic one or "Background Check RONBAM" for the NBAM method.

Examples of yaml:
^^^^^^^^^^^^^^^^^
:code:`ufo/test/testinput/gnssrobndnbam.yaml`

.. code:: yaml

 observations:
 - obs space:
      name: GnssroBnd
      obsdatain:
        obsfile: Data/ioda/testinput_tier_1/gnssro_obs_2018041500_3prof.nc4
        obsgrouping:
          group variable: "record_number"
          sort variable: "impact_height"
          sort order: "ascending"
      obsdataout:
        obsfile: Data/gnssro_bndnbam_2018041500_3prof_output.nc4
      simulate variables: [bending_angle]
    obs operator:
      name: GnssroBndNBAM
      obs options:
        use_compress: 1
        vertlayer: full
        super_ref_qc: NBAM
        sr_steps: 2
    obs filters: 
    - filter: Domain Check
      filter variables:
      - name: [bending_angle]
      where:
      - variable:
          name: impact_height@MetaData
        minvalue: 0
        maxvalue: 50000
    - filter: ROobserror
      filter variables:
      - name: bending_angle
      errmodel: NRL
    - filter: Background Check
      filter variables:
      - name: [bending_angle]
      threshold: 3


(GnssroBndROPP1D)
-----------------------------------

Description:
^^^^^^^^^^^^

The JEDI UFO interface of the Eumetsat ROPP package that implements
a one-dimensional observation operator for calculating the Global
Navigation Satellite System (GNSS) Radio Occultation (RO) bending
angle data

Code:
^^^^^
:code:`ufo/gnssro/BndROPP1D`

Configuration options:
^^^^^^^^^^^^^^^^^^^^^^
1. configurables in "ObsSpace" section:

   a. obsgrouping: applying record_number as a group_variable can get RO profiles in ufo. Otherwise RO data would be  treated as single observations.

2. configurables in "ObsFilters" section:

   a. Domain Check: a generic filter used to control the maximum height one wants to assimilate RO observation. Default value is 50 km.

   b. ROobserror: A RO specific filter. Use generic filter class to apply observation error method.
         options: NBAM, NRL,ECMWF, and more to come. (NBAM is default, but not recommended for ROPP operators). One has to specific a error model.

   c. Background Check: can only use the generic one (see the filter documents).

Examples of yaml:
^^^^^^^^^^^^^^^^^
:code:`ufo/test/testinput/gnssrobndropp1d.yaml`

.. code:: yaml

 observations:
 - obs space:
     name: GnssroBndROPP1D
     obsdatain:
       obsfile: Data/ioda/testinput_tier_1/gnssro_obs_2018041500_m.nc4
       obsgrouping:
         group variable: "record_number"
         sort variable: "impact_height"
     obsdataout:
       obsfile: Data/gnssro_bndropp1d_2018041500_m_output.nc4
     simulate variables: [bending_angle]
   obs operator:
      name:  GnssroBndROPP1D
      obs options:
   obs filters:
   - filter: Domain Check
     filter variables:
     - name: [bending_angle]
     where:
     - variable:
         name: impact_height@MetaData
       minvalue: 0
       maxvalue: 50000
   - filter: ROobserror
     filter variables:
     - name: bending_angle
     errmodel: NRL
   - filter: Background Check
     filter variables:
     - name: [bending_angle]
     threshold: 3

(GnssroBndROPP2D)
-----------------------------------

Description:
^^^^^^^^^^^^

The JEDI UFO interface of the Eumetsat ROPP package that implements
a two-dimensional observation operator for calculating the Global
Navigation Satellite System (GNSS) Radio Occultation (RO) bending
angle data

Code:
^^^^^
:code:`ufo/gnssro/BndROPP2D`

Configuration options:
^^^^^^^^^^^^^^^^^^^^^^
1. configurables in "ObsOperator" section:

  a. n_horiz: The horizontal points the operator integrates along the 2d plane. Default is 31. Has to be a even number.

  b. res: The horizontal resolution of the 2d plance. Default is 40 km.

  c. top_2d: the highest height to apply the 2d operator. Default is 20 km.

2. configurables in "ObsSpace" section:

  a. obsgrouping: applying record_number as group_variable can get RO profiles in ufo. Otherwise RO data would be treated as single observations.

3. configurables in "ObsFilters" section:

  a. Domain Check: a generic filter used to control the maximum height one wants to assimilate RO observation. Default value is 50 km.

  b. ROobserror: A RO specific filter. Use generic filter class to apply observation error method.

    - options: NBAM, NRL,ECMWF, and more to come. (NBAM is default, but not recommended for ROPP operators). One has to specific a error model.

  c. Background Check: can only use the generic one (see the filter documents).

Examples of yaml:
^^^^^^^^^^^^^^^^^
:code:`ufo/test/testinput/gnssrobndropp2d.yaml`

.. code:: yaml

 observations:
 - obs space:
     name: GnssroBndROPP2D
     obsdatain:
       obsfile: Data/ioda/testinput_tier_1/gnssro_obs_2018041500_m.nc4
       obsgrouping:
         group_variable: "record_number"
         sort_variable: "impact_height"
     obsdataout:
       obsfile: Data/gnssro_bndropp2d_2018041500_m_output.nc4
     simulate variables: [bending_angle]
   obs operator:
      name: GnssroBndROPP2D
      obs options:
        n_horiz: 31
        res: 40.0
        top_2d: 1O.0
   obs filters:
   - filter: Domain Check
     filter variables:
     - name: [bending_angle]
     where:
     - variable:
         name: impact_height@MetaData
       minvalue: 0
       maxvalue: 50000
   - filter: ROobserror
     filter variables:
     - name: bending_angle
     errmodel: NRL
   - filter: Background Check
     filter variables:
     - name: [bending_angle]
     threshold: 3

(GnssroBendMetOffice)
-----------------------------------

Description:
^^^^^^^^^^^^

The JEDI UFO interface of the Met Office's one-dimensional observation
operator for calculating the Global
Navigation Satellite System (GNSS) Radio Occultation (RO) bending
angle data

Code:
^^^^^
:code:`ufo/gnssro/BendMetOffice`

Configuration options:
^^^^^^^^^^^^^^^^^^^^^^
1. configurables in "obs operator" section:

  a. none.

2. configurables in "obs space" section:

  a. vert_interp_ops: if true, then use log(pressure) for vertical interpolation, if false then use exner function for vertical interpolation.
  
  b. pseudo_ops: if true then calculate data on intermediate "pseudo" levels between model levels, to minimise interpolation artifacts.
  
3. configurables in "ObsFilters" section:

  a. Background Check: not currently well configured.  More detail to follow.

Examples of yaml:
^^^^^^^^^^^^^^^^^
:code:`ufo/test/testinput/gnssrobendmetoffice.yaml`

.. code:: yaml

  - obs operator:
      name: GnssroBendMetOffice
      obs options:
        vert_interp_ops: true
        pseudo_ops: true
    obs space:
      name: GnssroBnd
      obsdatain:
        obsfile: Data/ioda/testinput_tier_1/gnssro_obs_2019050700_1obs.nc4
      simulated variables: [bending_angle]
    geovals:
      filename: Data/gnssro_geoval_2019050700_1obs.nc4
    obs filters:
    - filter: Background Check
      filter variables:
      - name: bending_angle
      threshold: 3.0
    norm ref: MetOfficeHofX
    tolerance: 1.0e-5

References:
^^^^^^^^^^^

The scientific configuration of this operator has been documented in a number of
publications:

 - Buontempo C, Jupp A, Rennie M, 2008. Operational NWP assimilation of GPS
   radio occultation data, *Atmospheric Science Letters*, **9**: 129--133.
   doi: http://dx.doi.org/10.1002/asl.173
 - Burrows CP, 2014. Accounting for the tangent point drift in the assimilation of
   gpsro data at the Met Office, *Satellite applications technical memo 14*, Met
   Office.
 - Burrows CP, Healy SB, Culverwell ID, 2014. Improving the bias
   characteristics of the ROPP refractivity and bending angle operators,
   *Atmospheric Measurement Techniques*, **7**: 3445--3458.
   doi: http://dx.doi.org/10.5194/amt-7-3445-2014

(GnssroRef)
-----------------------------------

Description:
^^^^^^^^^^^^

A one-dimensional observation operator for calculating the Global
Navigation Satellite System (GNSS) Radio Occultation (RO)
refractivity data.

Code:
^^^^^
:code:`ufo/gnssro/Ref`

Configuration options:
^^^^^^^^^^^^^^^^^^^^^^

1. configurables in "ObsFilters" section:

  a. Domain Check: a generic filter used to control the maximum height one wants to assimilate RO observation. Recommended value is 30 km for GnssroRef.

  b. ROobserror: A RO specific filter. Use generic filter class to apply observation error method.
         options: Only NBAM (default) is implemented now.

  c. Background Check: can only use the generic one (see the filter documents).

Examples of yaml:
^^^^^^^^^^^^^^^^^

:code:`ufo/test/testinput/gnssroref.yaml`

.. code:: yaml

 observations:
 - obs space:
     name: GnssroRef
     obsdatain:
       obsfile: Data/ioda/testinput_tier_1/gnssro_obs_2018041500_s.nc4
     simulate variables: [refractivity]
   obs operator:
     name: GnssroRef
     obs options:
   obs filters:
   - filter: Domain Check
     filter variables:
     - name: [refractivity]
     where:
     - variable:
         name: altitude@MetaData
       minvalue: 0
       maxvalue: 30000
   - filter: ROobserror
     filter variables:
     - name: refractivity
     errmodel: NBAM
   - filter: Background Check
     filter variables:
     - name: [refractivity]
     threshold: 3

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

Atmosphere Vertical Layer Interpolation (AtmVertInterpLev)
----------------------------------------------------------

Description:
^^^^^^^^^^^^

Observational operator for vertical interpolation of model levels for an observational atmospheric level where the pressure level is specified in cbars.

Code:
^^^^^

:code:`ufo/atmvertinterplev/`

Configuration options:
^^^^^^^^^^^^^^^^^^^^^^

The coefficients field in the yaml file can be adjusted to change the units of the observation.

Examples of yaml:
^^^^^^^^^^^^^^^^^

.. code:: yaml

window begin: 2019-10-16T20:30:00Z
window end: 2019-10-17T03:30:00Z

observations:
- obs operator:
    name: AtmVertInterpLev
    coefficients: [.6042290]
  obs space:
    name: OzoneLevel
    obsdatain:
      obsfile: Data/ioda/testinput_tier_1/ompslp_npp_obs_2019101700_m.nc4
    obsdataout:
      obsfile: Data/ompslp_npp_obs_2019101700_m_out.nc4
    simulated variables: [mixing_ratio_ozone_in_air]
  geovals:
    filename: Data/ompslp_npp_geoval_2019101700_m.nc4
  vector ref: GsiHofX
  tolerance: 1.0e-04  # in % so that corresponds to 10^-3
  linear obs operator test:
    coef TL: 0.1
    tolerance TL: 1.0e-9
    tolerance AD: 1.0e-11
