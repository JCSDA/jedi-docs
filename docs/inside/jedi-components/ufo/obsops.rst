.. _top-ufo-obsops:

Observation Operators in UFO
=============================

Vertical Interpolation
----------------------

Description:
^^^^^^^^^^^^
This observation operator implements linear interpolation in a vertical coordinate. If the vertical coordinate is :code:`air_pressure` or :code:`air_pressure_levels`, interpolation is done in the logarithm of air pressure. For all other vertical coordinates interpolation is done in the specified coordinate (no logarithm applied).

This operator can be used as a component of the `Composite` operator.

Configuration options:
^^^^^^^^^^^^^^^^^^^^^^
* :code:`vertical coordinate` [optional]: the vertical coordinate to use in interpolation. If set to :code:`air_pressure` or :code:`air_pressure_levels`, the interpolation is done in log(air pressure). The default value is :code:`air_pressure`.
* :code:`observation vertical coordinate` [optional]: name of the ObsSpace variable (from the :code:`MetaData` group) storing the vertical coordinate of observation locations. If not set, assumed to be the same as :code:`vertical coordinate`.
* :code:`variables` [optional]: a list of names of ObsSpace variables to be simulated by this operator (see the example below). This option should only be set if this operator is used as a component of the `Composite` operator. If it is not set, the operator will simulate all ObsSpace variables.

Examples of yaml:
^^^^^^^^^^^^^^^^^
.. code-block:: yaml

  obs operator:
    name: VertInterp

The observation operator in the above example does vertical interpolation in log(air pressure).

.. code-block:: yaml

  obs operator:
    name: VertInterp
    vertical coordinate: height

The observation operator in the above example does vertical interpolation in height.

.. code-block:: yaml

  obs operator:
    name: VertInterp
    vertical coordinate: air_pressure_levels
    observation vertical coordinate: air_pressure

The observation operator in the above example does vertical interpolation in log(air_pressure) on the levels taken from the :code:`air_pressure_levels` GeoVaL.

.. code-block:: yaml

  obs operator:
    name: Composite
    components:
    - name: VertInterp
      variables:
      - name: eastward_wind
      - name: northward_wind
    - name: Identity
      variables:
      - name: surface_pressure

In the example above, the `VertInterp` operator is used to simulate only the wind components; the surface pressure is simulated using the `Identity` operator.

Atmosphere Vertical Layer Interpolation
----------------------------------------

Description:
^^^^^^^^^^^^

Observational operator for vertical summation of model layers within an observational atmospheric layer where the top and bottom pressure levels are specified in cbars.

Examples of yaml:
^^^^^^^^^^^^^^^^^

.. code-block:: yaml

  obs operator:
    name: AtmVertInterpLay

Community Radiative Transfer Model (CRTM)
-----------------------------------------

Description:
^^^^^^^^^^^^

Interface to the Community Radiative Transfer Model (CRTM) as an observational operator.

Configuration options:
^^^^^^^^^^^^^^^^^^^^^^

The CRTM operator has some required geovals (see varin_default in ufo/crtm/ufo_radiancecrtm_mod.F90). The configurable geovals are as follows:

* :code:`Absorbers` : CRTM atmospheric absorber species that will be requested as geovals.  H2O and O3 are always required. So far H2O, O3, CO2 are implemented. More species can be added readily by extending UFO_Absorbers and CRTM_Absorber_Units in ufo/crtm/ufo_crtm_utils_mod.F90.
* :code:`Clouds` [optional] : CRTM cloud constituents that will be requested as geovals; can include any of Water, Ice, Rain, Snow, Graupel, Hail
* :code:`Cloud_Fraction` [optional] : sets the CRTM Cloud_Fraction to a constant value across all profiles (e.g., 1.0). Omit this option in order to request cloud_area_fraction_in_atmosphere_layer as a geoval from the model.

* :code:`linear obs operator` [optional] : used to indicate a different configuration for K-Matrix multiplication of tangent linear and adjoint operators from the configuration used for the Forward operator.  The same profile is used in the CRTM Forward and K_Matrix calculations. Only the interface to the model will be altered. Omit :code:`linear obs operator` in order to use the same settings across Forward, Tangent Linear, and Adjoint operators.
* :code:`linear obs operator.Absorbers` [optional] : controls which of the selected Absorbers will be acted upon in K-Matrix multiplication
* :code:`linear obs operator.Clouds` [optional] : controls which of the selected Clouds will be acted upon in K-Matrix multiplication

:code:`obs options` configures the tabulated coefficient files that are used by CRTM

* :code:`obs options.Sensor_ID` : {sensor}_{platform} prefix of the sensor-specific coefficient files, e.g., amsua_n19
* :code:`obs options.EndianType` : Endianness of the coefficient files. Either little_endian or big_endian.
* :code:`obs options.CoefficientPath` : location of all coefficient files

* :code:`obs options.IRwaterCoeff` [optional] : options: [Nalli (D), WuSmith]
* :code:`obs options.VISwaterCoeff` [optional] : options: [NPOESS (D)]
* :code:`obs options.IRVISlandCoeff` [optional] : options: [NPOESS (D), USGS, IGBP]
* :code:`obs options.IRVISsnowCoeff` [optional] : options: [NPOESS (D)]
* :code:`obs options.IRVISiceCoeff` [optional] : options: [NPOESS (D)]
* :code:`obs options.MWwaterCoeff` [optional] : options: [FASTEM6 (D), FASTEM5, FASTEM4]

Examples of yaml:
^^^^^^^^^^^^^^^^^

.. code-block:: yaml

  obs operator:
    name: CRTM
    Absorbers: [H2O, O3]
    Clouds: [Water, Ice, Rain, Snow, Graupel, Hail]
    linear obs operator:
      Absorbers: [H2O]
      Clouds: [Water, Ice]
    obs options:
      Sensor_ID: amsua_n19
      EndianType: little_endian
      CoefficientPath: Data/

.. code-block:: yaml

  obs operator:
    name: CRTM
    Absorbers: [H2O, O3, CO2]
    Clouds: [Water, Ice]
    Cloud_Fraction: 1.0
    obs options:
      Sensor_ID: iasi_metop-a
      EndianType: little_endian
      CoefficientPath: Data/
      IRVISlandCoeff: USGS

.. code-block:: yaml

  obs operator:
    name: CRTM
    Absorbers: [H2O, O3]
    linear obs operator:
      Absorbers: [H2O]
    obs options:
      Sensor_ID: abi_g16
      EndianType: little_endian
      CoefficientPath: Data/

Aerosol Optical Depth (AOD)
----------------------------

Description:
^^^^^^^^^^^^

The operator to calculate Aerosol Optical Depth for GOCART aerosol parameterization. It relies on the implementation of GOCART in the CRTM. This implementation includes hydorphillic and hydrophobic black and organic carbonaceous species, sulphate, five dust bins (radii: 0.1-1, 1.4-1.8, 1.8-3.0, 3.0-6.0, 6.0-10. um), and four sea-salt bins (dry aerosol radii: 0.1-0.5, 0.5-1.5, 1.5-5.0, 5.0-10.0 um). AOD is calculated using CRTM's tables of optical properties for these aerosols. Some modules are shared with CRTM radiance UFO.
On input, the operator requires aerosol mixing ratios, interface and mid-layer pressure, air temperature and specific / relative humidity for each model layer.


Configuration options:
^^^^^^^^^^^^^^^^^^^^^^

:code:`Absorbers`: (Both are required; No clouds since AOD retrievals are not obtained in cloudy regions):
* H2O to determine radii of hygrophillic aerosols particles
* O3 not strictly affecting aerosol radiative properties but required to be entered by the CRTM (here mixing ratio assigned a default value)

:code:`obs options`:
* :code:`Sensor_ID`: v.viirs-m_npp
* Other possibilities: v.modis_aqua, v.modis_terra
:code:`AerosolOption`: aerosols_gocart_default (Currently, that's the only one that works)

Example of a yaml:
^^^^^^^^^^^^^^^^^^
.. code-block:: yaml

   obs operator:
     name: AodCRTM
     Absorbers: [H2O,O3]
     obs options:
       Sensor_ID: v.viirs-m_npp
       EndianType: little_endian
       CoefficientPath: Data/
       AerosolOption: aerosols_gocart_default

GNSS RO bending angle (NCEP)
-----------------------------

Description:
^^^^^^^^^^^^

A one-dimensional observation operator for calculating the Global
Navigation Satellite System (GNSS) Radio Occultation (RO) bending
angle data based on the  NBAM (NCEP's Bending Angle Method)

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

.. code-block:: yaml

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


GNSS RO bending angle (ROPP 1D)
--------------------------------

Description:
^^^^^^^^^^^^

The JEDI UFO interface of the Eumetsat ROPP package that implements
a one-dimensional observation operator for calculating the Global
Navigation Satellite System (GNSS) Radio Occultation (RO) bending
angle data

Configuration options:
^^^^^^^^^^^^^^^^^^^^^^
1. configurables in "obs space" section:

   a. obsgrouping: applying record_number as a group_variable can get RO profiles in ufo. Otherwise RO data would be  treated as single observations.

2. configurables in "obs filters" section:

   a. Domain Check: a generic filter used to control the maximum height one wants to assimilate RO observation. Default value is 50 km.

   b. ROobserror: A RO specific filter. Use generic filter class to apply observation error method.
         options: NBAM, NRL,ECMWF, and more to come. (NBAM is default, but not recommended for ROPP operators). One has to specific a error model.

   c. Background Check: can only use the generic one (see the filter documents).

Examples of yaml:
^^^^^^^^^^^^^^^^^
:code:`ufo/test/testinput/gnssrobndropp1d.yaml`

.. code-block:: yaml

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

GNSS RO bending angle (ROPP 2D)
-----------------------------------

Description:
^^^^^^^^^^^^

The JEDI UFO interface of the Eumetsat ROPP package that implements
a two-dimensional observation operator for calculating the Global
Navigation Satellite System (GNSS) Radio Occultation (RO) bending
angle data


Configuration options:
^^^^^^^^^^^^^^^^^^^^^^
1. configurables in "obs operator" section:

  a. n_horiz: The horizontal points the operator integrates along the 2d plane. Default is 31. Has to be a even number.

  b. res: The horizontal resolution of the 2d plance. Default is 40 km.

  c. top_2d: the highest height to apply the 2d operator. Default is 20 km.

2. configurables in "obs space" section:

  a. obsgrouping: applying record_number as group_variable can get RO profiles in ufo. Otherwise RO data would be treated as single observations.

3. configurables in "obs filters" section:

  a. Domain Check: a generic filter used to control the maximum height one wants to assimilate RO observation. Default value is 50 km.

  b. ROobserror: A RO specific filter. Use generic filter class to apply observation error method.

    - options: NBAM, NRL,ECMWF, and more to come. (NBAM is default, but not recommended for ROPP operators). One has to specific a error model.

  c. Background Check: can only use the generic one (see the filter documents).

Examples of yaml:
^^^^^^^^^^^^^^^^^

.. code-block:: yaml

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

GNSS RO bending angle (MetOffice)
-----------------------------------

Description:
^^^^^^^^^^^^

The JEDI UFO interface of the Met Office's one-dimensional observation
operator for calculating the Global
Navigation Satellite System (GNSS) Radio Occultation (RO) bending
angle data

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

.. code-block:: yaml

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

GNSS RO refractivity
----------------------

Description:
^^^^^^^^^^^^

A one-dimensional observation operator for calculating the Global
Navigation Satellite System (GNSS) Radio Occultation (RO)
refractivity data.

Configuration options:
^^^^^^^^^^^^^^^^^^^^^^

1. configurables in "obs filters" section:

  a. Domain Check: a generic filter used to control the maximum height one wants to assimilate RO observation. Recommended value is 30 km for GnssroRef.

  b. ROobserror: A RO specific filter. Use generic filter class to apply observation error method.
         options: Only NBAM (default) is implemented now.

  c. Background Check: can only use the generic one (see the filter documents).

Examples of yaml:
^^^^^^^^^^^^^^^^^

:code:`ufo/test/testinput/gnssroref.yaml`

.. code-block:: yaml

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

Identity observation operator
-----------------------------------

Description:
^^^^^^^^^^^^

A simple identity observation operator, applicable whenever only horizontal interpolation of model variables is required.

This operator can be used as a component of the `Composite` operator.

Configuration options:
^^^^^^^^^^^^^^^^^^^^^^

* :code:`variables` [optional]: a list of names of ObsSpace variables to be simulated by this operator (see the example below). This option should only be set if this operator is used as a component of the `Composite` operator. If it is not set, the operator will simulate all ObsSpace variables.

Examples of yaml:
^^^^^^^^^^^^^^^^^

.. code-block:: yaml

   obs operator:
     name: Identity

In the example above, the `Identity` operator is used to simulate all ObsSpace variables.

.. code-block:: yaml

  obs operator:
    name: Composite
    components:
    - name: VertInterp
      variables:
      - name: eastward_wind
      - name: northward_wind
    - name: Identity
      variables:
      - name: surface_pressure

In the example above, the `Identity` operator is used to simulate only the surface pressure; the wind components are simulated using the `VertInterp` operator.

Radar Radial Velocity
--------------------------

Description:
^^^^^^^^^^^^

Similar to RadarReflectivity, but for radial velocity. It is tested with radar observations dumped from a specific modified GSI program at NSSL for the Warn-on-Forecast project.

Examples of yaml:
^^^^^^^^^^^^^^^^^

.. code-block:: yaml

  observations:
  - obs operator:
      name: RadarRadialVelocity
    obs space:
      name: Radar
      obsdatain:
        obsfile: Data/radar_rw_obs_2019052222.nc4
      simulated variables: [radial_velocity]

Scatterometer neutral wind (Met Office)
---------------------------------------

Description:
^^^^^^^^^^^^
Met Office observation operator for treating scatterometer wind data 
as a "neutral" 10m wind, i.e. where the effects of atmospheric stability are neglected. 
For each observation we calculate the momentum roughness length using the Charnock relation. 
We then calculate the Monin-Obukhov stability function for momentum, integrated to the model's lowest wind level.
The calculations are dependant upon on whether we have stable or unstable conditions
according to the Obukhov Length. The neutral 10m wind components are then calculated
from the lowest model level winds.

Configuration options:
^^^^^^^^^^^^^^^^^^^^^^
* none

Examples of yaml:
^^^^^^^^^^^^^^^^^
.. code-block:: yaml

  observations:
  - obs operator:
      name: ScatwindNeutralMetOffice
    obs space:
      name: Scatwind
      obsdatain:
        obsfile: Data/ioda/testinput_tier_1/scatwind_obs_1d_2020100106.nc4
      obsdataout:
        obsfile: Data/scatwind_obs_1d_2020100106_opr_test_out.nc4
      simulated variables: [eastward_wind, northward_wind]
    geovals:
      filename: Data/ufo/testinput_tier_1/scatwind_geoval_20201001T0600Z.nc4
    vector ref: MetOfficeHofX
    tolerance: 1.0e-05

References:
^^^^^^^^^^^^^^^^^^^^^^
Cotton, J., 2018. Update on surface wind activities at the Met Office.
Proceedings for the 14 th International Winds Workshop, 23-27 April 2018, Jeju City, South Korea. 
Available from http://cimss.ssec.wisc.edu/iwwg/iww14/program/index.html.

Composite
---------

Description
^^^^^^^^^^^

This "meta-operator" wraps a collection of observation operators, each used to simulate a different
subset of variables from the ObsSpace. Example applications of this operator are discussed below.

.. warning::

  At present, many observation operators implicitly assume they need to simulate all variables from
  the ObsSpace. Such operators cannot be used as components of the `Composite` operator. Operators
  compatible with the `Composite` operator are marked as such in their documentation.

Configuration options
^^^^^^^^^^^^^^^^^^^^^

* :code:`components`: a list of one or more items, each configuring the observation operator to be
  applied to a specified subset of variables.

Example 1
^^^^^^^^^

The YAML snippet below shows how to use the `VertInterp` operator to simulate upper-air variables
from the ObsSpace and the `Identity` operator to simulate surface variables. Note that the
variables to be simulated by both these operators can be specified using the :code:`variables`
option; if this option is not present, all variables in the ObsSpace are simulated.

.. code-block:: yaml

  obs space:
    name: Radiosonde
    obsdatain:
      obsfile: Data/ioda/testinput_tier_1/sondes_obs_2018041500_s.nc4
    simulated variables: [eastward_wind, northward_wind, surface_pressure, relative_humidity]
  obs operator:
    name: Composite
    components:
    - name: VertInterp
      variables:
      - name: relative_humidity
      - name: eastward_wind
      - name: northward_wind
    - name: Identity
      variables:
      - name: surface_pressure

Example 2
^^^^^^^^^

The YAML snippet below shows how to handle a model with a staggered grid, with wind components
defined on different model levels than the air temperature. The :code:`vertical coordinate` option
of the :code:`VertInterp` operator indicates the GeoVaL containing the levels to use for the
vertical interpolation of the variables simulated by this operator.

.. code-block:: yaml

  obs space:
    name: Radiosonde with staggered vertical levels
    obsdatain:
      obsfile: Data/ufo/testinput_tier_1/met_office_composite_operator_sonde_obs.nc4
    simulated variables: [eastward_wind, northward_wind, air_temperature]
  obs operator:
    name: Composite
    components:
    - name: VertInterp
      variables:
      - name: air_temperature
      vertical coordinate: air_pressure
      observation vertical coordinate: air_pressure
    - name: VertInterp
      variables:
      - name: northward_wind
      - name: eastward_wind
      vertical coordinate: air_pressure_levels
      observation vertical coordinate: air_pressure

Background Error Vertical Interpolation
---------------------------------------

This operator calculates ObsDiagnostics representing vertically interpolated
background errors of the simulated variables.

It should be used as a component of the `Composite` observation operator (with another
component handling the calculation of model equivalents of observations). It populates all
requested ObsDiagnostics called :code:`<var>_background_error`, where :code:`<var>` is the name of a
simulated variable, by vertically interpolating the :code:`<var>_background_error` GeoVaL at the
observation locations. Element (i, j) of this GeoVaL is interpreted as the background error
estimate of variable :code:`<var>` at the ith observation location and the vertical position read from
the (i, j)th element of the GeoVaL specified in the :code:`interpolation level` option of the
operator.

Configuration options
^^^^^^^^^^^^^^^^^^^^^

* :code:`vertical coordinate`: name of the GeoVaL storing the interpolation levels of background
  errors.
* :code:`observation vertical coordinate`: name of the ufo variable (from the `MetaData` group)
  storing the vertical coordinate of observation locations.
* :code:`variables` [optional]: simulated variables whose background errors may be calculated by
  this operator. If not specified, defaults to the list of all simulated variables in the ObsSpace.

.. _Background Error Vertical Interpolation Example:

Example
^^^^^^^

.. code-block:: yaml

  obs operator:
    name: Composite
    components:
    # operators used to evaluate H(x)
    - name: VertInterp
      variables:
      - name: air_temperature
      - name: specific_humidity
      - name: northward_wind
      - name: eastward_wind
    - name: Identity
      variables:
      - name: surface_pressure
    # operators used to evaluate background errors
    - name: BackgroundErrorVertInterp
      variables:
      - name: northward_wind
      - name: eastward_wind
      - name: air_temperature
      - name: specific_humidity
      observation vertical coordinate: air_pressure
      vertical coordinate: background_error_air_pressure
    - name: BackgroundErrorIdentity
      variables:
      - name: surface_pressure

Background Error Identity
-------------------------

This operator calculates ObsDiagnostics representing single-level
background errors of the simulated variables.

It should be used as a component of the `Composite` observation operator (with another
component handling the calculation of model equivalents of observation). It populates all
requested ObsDiagnostics called :code:`<var>_background_error`, where :code:`<var>` is the name of a
simulated variable, by copying the :code:`<var>_background_error` GeoVaL at the observation
locations.

Configuration options
^^^^^^^^^^^^^^^^^^^^^

* :code:`variables` [optional]: simulated variables whose background errors may be calculated by
  this operator. If not specified, defaults to the list of all simulated variables in the ObsSpace.

Example
^^^^^^^

See the listing in the :ref:`Background Error Vertical Interpolation Example` section of the
documentation of the Background Error Vertical Interpolation operator.
