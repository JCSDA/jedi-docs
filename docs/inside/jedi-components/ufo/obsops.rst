.. _top-ufo-obsops:

Observation Operators in UFO
=============================

Introduction
------------

There are three meta-operators which, when selected, run other operators and manipulate their output:

* :ref:`Categorical <obsops_categorical>`,

* :ref:`Composite <obsops_composite>`,

* Time interpolation (documentation to be added).

.. _obsops_categorical:

Categorical
-----------

Description
^^^^^^^^^^^

The Categorical meta-operator can be used to run several observation operators, each of which produces a vector of H(x) values.
The Categorical operator then creates a final H(x) vector by selecting the observation operator at each location according to a categorical variable.

Configuration options
^^^^^^^^^^^^^^^^^^^^^

* :code:`categorical variable`: the name of the variable that is used to determine which observation operator is selected at each location.
  This must be an integer or string variable in the MetaData group.

* :code:`categorised operators`: a map between values of the categorical variable and the operator to be selected.

* :code:`fallback operator`: the name of the observation operator that will be used whenever a particular value of the categorical variable does not exist in :code:`categorised operators`.

* :code:`operator configurations`: the configuration of all observation operators whose output will be used to produce the final H(x) vector.
  If either the fallback operator or one of the categorised operators have not been configured, an exception will be thrown.

* :code:`operator labels`: This option must be used if there are at least two component operators of the same type.
  The labels are associated with each component operator and can subsequently be used to differentiate between them.
  The ordering of labels in this list must correspond to the ordering of operators in the :code:`operator configurations` parameter.
  Every component operator (even if it is not duplicated) must be assigned a unique label.

Example 1
^^^^^^^^^

In this example the Categorical operator uses :code:`station_id@MetaData` as the categorical variable.
Both the :ref:`Identity <obsops_identity>` and :ref:`Composite <obsops_composite>` operators are used to produce H(x) vectors.
Then, at each location in the ObsSpace, if :code:`station_id@MetaData` is equal to 54857 then the Identity H(x) is selected.
Otherwise, the H(x) produced by the fallback operator (i.e. Composite) is selected.

.. code-block:: yaml

 obs operator:
   name: Categorical
   categorical variable: station_id
   fallback operator: "Composite"
   categorised operators: {"54857": "Identity"}
   operator configurations:
   - name: Identity
   - name: Composite
     components:
      - name: Identity
        variables:
        - name: air_temperature
        - name: surface_pressure
      - name: VertInterp
        variables:
        - name: northward_wind
        - name: eastward_wind

Example 2
^^^^^^^^^

In this example the Categorical operator uses :code:`station_id@MetaData` as the categorical variable and has two
:code:`Composite` operators and an :code:`Identity` operator. The fact that two operators are the same necessitates the use of the
:code:`operator labels` section. The first :code:`Composite` operator is labelled :code:`Composite1`, and the second is labelled
:code:`Composite2`. Note that the :code:`Identity` operator must also be labelled. There must be as many labels as there are operator
configurations and the contents of the two sections must appear in the same order.

At each location in the ObsSpace, if :code:`station_id@MetaData` is equal to 47418 or 54857 then the H(x) produced by :code:`Composite1` is used,
and if :code:`station_id@MetaData` is equal to 94332 or 96935 then the H(x) produced by :code:`Composite2` is used.
Otherwise, the H(x) produced by the fallback operator (i.e. :code:`Identity`) is selected.

.. code-block:: yaml

  obs operator:
    name: Categorical
    categorical variable: station_id
    fallback operator: "Identity"
    categorised operators: {"47418": "Composite1",
    "54857": "Composite1",
    "94332": "Composite2",
    "96935": "Composite2"}
    operator labels: ["Identity", "Composite1", "Composite2"]
    operator configurations:
    - name: Identity
    - name: Composite
      components:
       - name: Identity
         variables:
         - name: air_temperature
       - name: VertInterp
         variables:
         - name: northward_wind
         - name: eastward_wind
    - name: Composite
      components:
       - name: Identity
         variables:
         - name: air_temperature
       - name: VertInterp
         variables:
         - name: northward_wind
         - name: eastward_wind

.. _obsops_composite:

Composite
---------

Description
^^^^^^^^^^^

This meta-operator wraps a collection of observation operators, each used to simulate a different
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

The YAML snippet below shows how to use the :ref:`VertInterp <obsops_vertinterp>` operator to simulate upper-air variables
from the ObsSpace and the :ref:`Identity <obsops_identity>` operator to simulate surface variables. Note that the
variables to be simulated by both these operators can be specified using the :code:`variables`
option; if this option is not present, all variables in the ObsSpace are simulated.

.. code-block:: yaml

  obs space:
    name: Radiosonde
    obsdatain:
      engine:
        type: H5File
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
      engine:
        type: H5File
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

.. _obsops_vertinterp:

Vertical Interpolation
----------------------

Description:
^^^^^^^^^^^^
This observation operator implements linear interpolation (including log-linear interpolation), and nearest-neighbor interpolation in a vertical coordinate when explicitly chosen. If choose automatic (which is same as choose default), then if the vertical coordinate is :code:`air_pressure` or :code:`air_pressure_levels`, interpolation is done in the logarithm of air pressure; if choose :code: `constant vertical coordinate values` :code:, then the default interpolation is nearest-neighbor. For all other vertical coordinates interpolation is done in the specified coordinate (no logarithm applied).

This operator can be used as a component of the `Composite` operator.

Configuration options:
^^^^^^^^^^^^^^^^^^^^^^
* :code:`vertical coordinate` [optional]: the vertical coordinate to use in interpolation. If set to :code:`air_pressure` or :code:`air_pressure_levels`, the interpolation is done in log(air pressure). The default value is :code:`air_pressure`.
* :code:`constant vertical coordinate values` [optional]: use the (array) values as vertical coordinate in interpolation. If :code:`interpolation method` is not defined, then nearest-neighbor will be used in interpolation. If this option is chosen, the geovals for vertical coordinate are not requested and vertical coordinate option above shouldn't be used. The primary purpose of this option is to serve the requirement for soil moisture assimilation.
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
      name: VertInterp
      constant vertical coordinate values: [0.1, 0.5, 1.0, 2.0]
      interpolation method: nearest-neighbor
      observation vertical coordinate group: MetaData
      observation vertical coordinate: depthBelowSoilSurface

The observation operator in the above example choose array :code:`[0.1, 0.5, 1.0, 2.0]` as vertical coordinate in interpolation, :code:`interpolation method: nearest-neighbor` choose nearest-neighbor interpolation method.

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

Averaging Kernel Operator
-------------------------

Description:
^^^^^^^^^^^^

Observation operator for satellite retrievals with averaging kernel functions. Using the retrieval equation: :math:`\mathbf{x}_{retrieval} = \mathbf{A}\mathbf{x}_{truth} + (\mathbf{I}-\mathbf{A})\mathbf{x}_{apriori}`
The operator uses :code:`AtmVertInterpLay` to interpolate the :code:`tropospheric column` or :code:`total column` to the averaging kernel levels :code:`AvgKernelVar` function using pressure coordinates :code:`PresLevVar`.
The vertical profile is then summed vertically using the averaging kernel coefficients values as weights.


Examples of yaml:
^^^^^^^^^^^^^^^^^

.. code-block:: yaml

  obs operator:
    name: AvgKernel
    nlayers_kernel: 34
    AvgKernelVar: averaging_kernel_level
    PresLevVar: pressure_level
    tracer variables: [no2]
    tropospheric column: true
    total column: false

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
* :code:`SurfaceWindGeoVars` [str, optional, options: :code:`vector` - default, :code:`uv`] : specify which two surface wind GeoVaLs are requested from the model.  :code:`vector` indicates that surface wind direction and magnitude are requested.  :code:`uv` indicates that surface eastward and northward wind components are requested.

* :code:`linear obs operator` [optional] : used to indicate a different configuration for K-Matrix multiplication of tangent linear and adjoint operators from the configuration used for the Forward operator.  The same atmospheric profile is used in the CRTM Forward and K_Matrix calculations. Only the linear GeoVaLs interface to the model will be altered by this sub-configuration. Omit :code:`linear obs operator` in order to use the same settings across Forward, Tangent Linear, and Adjoint operators.
* :code:`linear obs operator.Absorbers` [optional] : only the selected Absorbers will be acted upon in K-Matrix multiplication.  Must be a sub-set of :code:`obs operator.Absorbers`.
* :code:`linear obs operator.Clouds` [optional] : only the selected Clouds will be acted upon in K-Matrix multiplication.  Must be a sub-set of :code:`obs operator.Clouds`.

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

Examples of valid yaml:
^^^^^^^^^^^^^^^^^^^^^^^

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
    SurfaceWindGeoVars: uv
    obs options:
      Sensor_ID: iasi_metop-a
      EndianType: little_endian
      CoefficientPath: Data/
      IRVISlandCoeff: USGS

.. code-block:: yaml

  obs operator:
    name: CRTM
    Absorbers: [H2O, O3]
    SurfaceWindGeoVars: vector
    linear obs operator:
      Absorbers: [H2O]
    obs options:
      Sensor_ID: abi_g16
      EndianType: little_endian
      CoefficientPath: Data/

RTTOV
-----------------------------------------

Description:
^^^^^^^^^^^^

Interface to the RTTOV observation operator.

Inputs:
^^^^^^^^^^^^^^^^^^^^^
RTTOV requires the following GeoVaLs for clear-sky radiance calculation. The variable name for use with ufo is given in parentheses () and the expected units in square brackets []:

* :code:`air_pressure` (:code:`var_prs`) [Pa]
* :code:`air_temperature` (:code:`var_ts`) [K]
* :code:`specific_humidity` (:code:`var_q`) [kg/kg]
* :code:`surface_temperature` (:code:`var_sfc_t2m`) [K]
* :code:`uwind_at_10m` (:code:`var_sfc_u10`) [m/s]
* :code:`vwind_at_10m` (:code:`var_sfc_v10`) [m/s]
* :code:`air_pressure_at_two_meters_above_surface` (:code:`var_sfc_p2m`) [Pa]
* :code:`specific_humidity_at_two_meters_above_surface` (:code:`var_sfc_q2m`) [kg/kg]
* :code:`skin_temperature` (:code:`var_sfc_tskin`) [K]

Additionally, for calculation of MW cloud-affected radiances using RTTOV-SCATT the following GeoVaLs are also required:

* :code:`air_pressure_levels` (:code:`var_prsi`) [Pa]
* :code:`mass_content_of_cloud_liquid_water_in_atmosphere_layer` (:code:`var_qcl`) [kg/kg]
* :code:`mass_content_of_cloud_ice_in_atmosphere_layer` (:code:`var_qci`) [kg/kg]
* :code:`cloud_area_fraction_in_atmosphere_layer`  (:code:`var_cloud_layer`) [dimensionless]

The geographic location of the observation, the satellite zenith angle and the RTTOV surface type are also required from the ObsSpace:

* At least one (in order of priority) from :code:`MetaData/elevation`, :code:`MetaData/surface_height`, :code:`MetaData/model_orography` or the :code:`surface_altitude` geoval [m]
* :code:`MetaData/latitude` [degrees]
* :code:`MetaData/longitude` [degrees, -180--180 or 0--360]
* :code:`MetaData/sensor_zenith_angle` [degrees]
* :code:`MetaData/surface_type` [0-2]

  :code:`MetaData/surface_type` is used to specify whether RTTOV should treat an observation as having a land (0), sea (1) or sea-ice (2) surface. The :code:`SetSurfaceType` ObsFunction, may be called via the :code:`VariableAssignment` ObsFilter to generate this data according to rules used in operational processing at the Met Office.

Optionally, the satellite azimuth angle and the solar zenith/azimuth angles may be supplied:

* :code:`MetaData/sensor_azimuth_angle` (optional) [degrees]
* :code:`MetaData/solar_zenith_angle` (optional) [degrees]
* :code:`MetaData/solar_azimuth_angle` (optional) [degrees]

Outputs:
^^^^^^^^^^^^^^^^^^^^^

| The interface returns brightness temperatures for any channels requested using the :code:`obs space.channels` YAML configuration key. The brightness temperature fields shall have a suffix to denote the channel and shall be stored in a one-dimensional dataset in the :code:`HofX` group in the output observation database (e.g. :code:`/HofX/brightness_temperature_5`.

| The interface optionally returns observation diagnostics including those requiring the calculation of jacobians, through the :code:`obs diagnostics.variables` YAML configuration key . Specifically:

* :code:`optical_thickness_of_atmosphere_layer`
* :code:`transmittances_of_atmosphere_layer`
* :code:`weightingfunction_of_atmosphere_layer`
* :code:`toa_outgoing_radiance_per_unit_wavenumber`
* :code:`brightness_temperature_assuming_clear_sky`
* :code:`pressure_level_at_peak_of_weightingfunction`
* :code:`toa_total_transmittance`
* :code:`surface_emissivity`
* :code:`brightness_temperature_jacobian_${any_active_variable}`

Where an observation diagnostic is requested that is not recognised by the interface, **no error is returned**, but memory is still allocated for the named observation diagnostic and the array is initialised to :code:`missing`. This is to facilitate the subsequent creation of bias correction predictors using output from the observation operator.

Generic Obs Operator configuration options:
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
The configurable options for the RTTOV observation operator interface are:

* :code:`name` (string, required): Must be set to :code:`RTTOV` in order to invoke this RTTOV observation operator.

* :code:`Debug` (boolean, optional, default false): Print additional debugging statements.

* :code:`Absorbers` (string list, optional): *Additional* atmospheric absorber species that will be requested from geovals. Names must correspond to those specified in :code:`gas_name` array in the |rttov_const module|.

  * :code:`Water_vapour` (the internal RTTOV name for water vapour, c.f. :code:`H2O` in CRTM) is mandatory and maps to :code:`specific_humidity` and it is not necessary to list it here explicitly.

  * :code:`CLW` (cloud liquid water) is optional for clear-sky MW calculation but mandatory for MW scattering calculations and maps to :code:`mass_content_of_cloud_liquid_water_in_atmosphere_layer`.

  * :code:`CIW` (cloud ice water) is not used for clear-sky MW calculation but mandatory for MW scattering calculations and maps to :code:`mass_content_of_cloud_ice_in_atmosphere_layer`.

  * :code:`Ozone`, :code:`CO2`, :code:`CO`, :code:`N2O`, :code:`CH4`, :code:`SO2` are due to be implemented.

  | **N.B.**

  | Where the optional trace gas profiles are not present in the geovals, RTTOV reference profiles stored in the RTTOV coefficients will be used to determine their concentration if a compatible RTTOV coefficient is being used.

  | The contribution to optical depth from absorbing species for which there are no coefficients present in the RTTOV coefficient file will usually have been included with a fixed profile during the training process. See |RTTOV_12.3_user_guide| for details.

  | There are no reference profiles for :code:`CLW` and :code:`CIW`. If either absorber is required, because it is mandatory or by user request, then the requisite datasets must be present in the geovals.

.. todo::

  hyperspectral IR support (specifically add code to read RTTOV supported gases)

.. * :code:`linear model absorbers` (optional) : used to indicate a different set of active variables for the Tangent Linear (TL) and Adjoint (AD) operators from the configuration used for the non-linear operator. The same profile is used in the RTTOV Forward and TL/AD calculations.

  * :code:`linear model absorbers` (string list, optional) : controls which of the selected absorbers will be active during the Jacobian calculation.
  Omit :code:`linear model` in order to use the same absorbers as for the TL and AD operators as for the non-linear forward model.

RTTOV interface specific configuration options (:code:`obs options`):
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
The :code:`obs options` section configures the options that can be used to change the behaviour of the RTTOV interface.

Required
~~~~~~~~~~~~

Three options are required to uniquely specify the RTTOV coefficient file to be used to process observations.
The coefficient filename will be :code:`rtcoef_${Platform_Name}_${Sat_ID}_${Instrument_Name}` with the extension automatically discovered by RTTOV. The order of preference will be :code:`.bin` (platform-specific unformatted binary), :code:`.dat` (ASCII format), :code:`.H5` (HDF5 format).
Scattering coefficients will be automatically read when requested according to the other :code:`obs options`. Their absence when required shall result in an error.

* :code:`obs options.Platform_Name` (string): Corresponds to an
  element of the :code:`platform_name` array in the |rttov_const
  module|, e.g. 'NOAA', 'Metop'. Note that this is case-insensitive,
  as user input is automatically converted to lower case.
* :code:`obs options.Sat_ID` (integer): Corresponds to the satellite ID.
* :code:`obs options.Instrument_Name` (string): Corresponds to an
  element of the :code:`instrument_name` array in  |rttov_const
  module|, e.g. 'ATMS', 'IASI'. Note that this is case-insensitive as,
  as user input is automatically converted to lower case.
* :code:`obs options.CoefficientPath` (string): Relative or absolute path to all coefficient files to be read.

.. |rttov_const module| raw:: html

   <a href="https://github.com/JCSDA-internal/rttov/blob/develop/src/rttov/main/rttov_const.F90#L137" target="_blank">rttov_const module</a>


Optional
~~~~~~~~
* :code:`obs options.RTTOV_default_opts` (string, default :code:`default`): These are set first and may be overridden by setting individual options. Valid options are :code:`UKMO_PS43`, :code:`UKMO_PS44`, :code:`UKMO_PS45` and correspond to options pertaining to RTTOV used operationally at the Met Office.
* :code:`obs options.Do_MW_Scatt` (boolean, default :code:`false`): Call RTTOV-SCATT to simulate MW radiances affected by cloud and precipitation.
* :code:`obs options.RTTOV_GasUnitConv` (integer, default :code:`false`): Convert absorber concentration from mass concentration [kg/kg] to volume concentration [ppmv dry] for use with RTTOV.
* :code:`obs options.InspectProfileNumber` (integer list, default 0): Print RTTOV profile(s) with indices corresponding to the order in which the geovals are processed. Intended for use with debugging.
* :code:`obs options.SatRad_compatibility` (boolean, default :code:`true`): Sets internal options to replicate Met Office OPS processing.
* :code:`obs options.UseRHWaterForQC` (boolean, default :code:`true`): Use liquid water only in the saturation calculation (requires :code:`SatRad_compatibility` to be true).
* :code:`obs options.UseColdSurfaceCheck` (boolean, default :code:`false`): Reset surface temperature over land and sea-ice where it is below 271.4 K. This is a legacy option for replicating OPS results prior to PS45 (requires :code:`SatRad_compatibility` to be true).

Additionally, each option that may be modified within the RTTOV options structure may be accessed by prefixing :code:`RTTOV_` ahead of the option name, regardless of where it resides within the RTTOV option structure.
For example, :code:`RTTOV_addrefrac: true` will enable the option within RTTOV to account for atmospheric refraction during the optical depth calculation.
All options are set to the defaults specified in the |RTTOV_12.3_user_guide|.

.. |RTTOV_12.3_user_guide| raw:: html

   <a href="https://www.nwpsaf.eu/site/download/documentation/rtm/docs_rttov12/users_guide_rttov12_v1.3.pdf" target="_blank">RTTOV 12.3 user guide</a>

Examples of yaml:
^^^^^^^^^^^^^^^^^

.. code-block:: yaml

  obs operator:
    name: RTTOV
    Absorbers: &rttov_absorbers [Water_vapour, CLW, CIW]
    linear model absorbers: [Water_vapour]
    obs options: &rttov_options
      RTTOV_default_opts: UKMO_PS45
      SatRad_compatibility: true
      RTTOV_GasUnitConv: true
      UseRHwaterForQC: &UseRHwaterForQC true # default
      UseColdSurfaceCheck: &UseColdSurfaceCheck false # default
      Do_MW_Scatt: &RTTOVMWScattSwitch false
      Platform_Name: &platform_name NOAA
      Sat_ID: &sat_id 20
      Instrument_Name: &inst_name ATMS
      CoefficientPath: &coef_path /Data

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

Aerosol Optical Depth (AOD) for dust (Met Office)
-------------------------------------------------

This operator calculates the Aerosol Optical Depth at one wavelength (e.g. 550 nm) from control variables of mass concentration of atmospheric dust (in :math:`kg/m^3`) by height for a number of different size bins, air pressure by height and surface pressure, assuming constant extinction coefficients per bin which are independent of humidity. The air pressure is assumed to be on staggered levels in relation to dust mass concentration, and the levels must be ordered from top-to-bottom. This operator is designed for use with the Met Office forecast model which includes prognostic dust fields with 2 - 6 bins, and for the assimilation of AOD products such as from MODIS and VIIRS.


Configuration options:
^^^^^^^^^^^^^^^^^^^^^^
- :code:`NDustBins`: number of bins;
- :code:`AodKExt`: extinction coefficients for each bin in :math:`m^2/kg`. This must be a vector of size `NDustBins`.

Example of a yaml:
^^^^^^^^^^^^^^^^^^

For example, to calculate the AOD for 3 aerosol dust bins with average extinction coefficients of (for the sake of argument) 100, 200 and 300 :math:`m^2/kg`:

.. code-block:: yaml

    obs operator:
      name: AodMetOffice
      NDustBins: 3
      AodKExt: [1.00E+02,2.00E+02,3.00E+02]

GNSS RO bending angle (NBAM)
-----------------------------

Description:
^^^^^^^^^^^^

A one-dimensional observation operator for calculating the Global
Navigation Satellite System (GNSS) Radio Occultation (RO) bending
angle data based on the NBAM (NCEP's Bending Angle Method)

Configuration options (ObsOperator):
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

* :code:`vertlayer`: if air pressure and geopotential height are read on the interface layer or the middle layer

  * options: :code:`mass` or :code:`full` (default is :code:`full`)

* :code:`super_ref_qc`: if use the "NBAM" or "ECMWF" method to do super refraction check.

  * options: :code:`NBAM` or :code:`ECMWF` (default is :code:`NBAM`)

* :code:`sr_steps`: when using the "NBAM" suepr refraction, if apply one or two step QC.

  * options: :code:`1` or :code:`2` (default is :code:`2` following NBAM implementation in GSI)

* :code:`use_compress`: compressibility factors in geopotential heights. Only for NBAM.

  * options: :code:`1` to turn on; :code:`0` to turn off (Default is 1)

Configuration options (ObsSpace):
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

* :code:`obsgrouping`: applying record_number as group_variable can get RO profiles in ufo. Otherwise RO data would be treated as single observations.

Configuration options (ObsFilters):
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

* :code:`Domain Check`: a generic filter used to control the maximum height one wants to assimilate RO observation.Default value is 50 km.

* :code:`ROobserror`: A RO specific filter. use generic filter class to apply observation error method.  More information on this filter is found in the :doc:`observation uncertainty documentation <obserrors>`
 
  * options: :code:`NBAM`, :code:`NRL`, :code:`ECMWF`, and more to come (default is :code:`NBAM`)

* :code:`Background Check`: the background check for RO can use either the generic one (see the filter documents) or the  RO specific one based on the NBAM implementation in GSI.

  * options: :code:`Background Check` for the JEDI generic one or :code:`Background Check RONBAM` for NBAM method.
 
Examples of yaml:
^^^^^^^^^^^^^^^^^
:code:`ufo/test/testinput/gnssrobndnbam.yaml`

.. code-block:: yaml

 observations:
   observers:
   - obs space:
        name: GnssroBnd
        obsdatain:
          engine:
            type: H5File
            obsfile: Data/ioda/testinput_tier_1/gnssro_obs_2018041500_3prof.nc4
          obsgrouping:
            group variable: "record_number"
            sort variable: "impact_height"
            sort order: "ascending"
        obsdataout:
          engine:
            type: H5File
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

Configuration options (ObsSpace):
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

* :code:`obsgrouping`: applying record_number as a group_variable can get RO profiles in ufo. Otherwise RO data would be  treated as single observations.

Configuration options (ObsFilters):
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

* :code:`Domain Check`: a generic filter used to control the maximum height one wants to assimilate RO observation. Default value is 50 km.

* :code:`ROobserror`: a RO specific filter. Use generic filter class to apply observation error method.  More information on this filter is found in the :doc:`observation uncertainty documentation <obserrors>`

  * options: :code:`NBAM`, :code:`NRL`, :code:`ECMWF`, and more to come (default is :code:`NBAM`, but not recommended for ROPP operators). One has to specific a error model.

* :code:`Background Check`: can only use the generic one (see the filter documents).

Examples of yaml:
^^^^^^^^^^^^^^^^^
:code:`ufo/test/testinput/gnssrobndropp1d.yaml`

.. code-block:: yaml

 observations:
   observers:
   - obs space:
       name: GnssroBndROPP1D
       obsdatain:
         engine:
           type: H5File
           obsfile: Data/ioda/testinput_tier_1/gnssro_obs_2018041500_m.nc4
         obsgrouping:
           group variable: "record_number"
           sort variable: "impact_height"
       obsdataout:
         engine:
           type: H5File
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


Configuration options (ObsOperator):
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

* :code:`n_horiz`: the horizontal points the operator integrates along the 2d plane. Default is 31. Has to be a odd number.

* :code:`res`: The horizontal resolution of the 2d plance. Default is 40 km.

* :code:`top_2d`: the highest height to apply the 2d operator. Default is 20 km.

Configuration options (ObsSpace):
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

* :code:`obsgrouping`: applying record_number as group_variable can get RO profiles in ufo. Otherwise RO data would be treated as single observations.

Configuration options (ObsFilter):

* :code:`Domain Check`: a generic filter used to control the maximum height one wants to assimilate RO observation. Default value is 50 km.

* :code:`ROobserror`: a RO specific filter. Use generic filter class to apply observation error method.  More information on this filter is found in the :doc:`observation uncertainty documentation <obserrors>`

  * options: :code:`NBAM`, :code:`NRL`, :code:`ECMWF`, and more to come (default is :code:`NBAM`, but not recommended for ROPP operators). One has to specific a error model.

* :code:`Background Check`: can only use the generic one (see the filter documents).

Examples of yaml:
^^^^^^^^^^^^^^^^^

.. code-block:: yaml

 observations:
   observers:
   - obs space:
       name: GnssroBndROPP2D
       obsdatain:
         engine:
           type: H5File
           obsfile: Data/ioda/testinput_tier_1/gnssro_obs_2018041500_m.nc4
         obsgrouping:
           group_variable: "record_number"
           sort_variable: "impact_height"
       obsdataout:
         engine:
           type: H5File
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
       n_horiz: 31
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

Configuration options (ObsOperator):
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

:code:`none`.

Configuration options (ObsSpace):
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

:code:`vert_interp_ops`: if true, then use log(pressure) for vertical interpolation, if false then use exner function for vertical interpolation.

:code:`pseudo_ops`: if true then calculate data on intermediate "pseudo" levels between model levels, to minimise interpolation artifacts.

Configuration options (ObsFilters):
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

:code:`Background Check`: not currently well configured.  More detail to follow.

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
        engine:
          type: H5File
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

*  Buontempo C, Jupp A, Rennie M, 2008. Operational NWP assimilation of GPS
   radio occultation data, *Atmospheric Science Letters*, **9**: 129--133.
   doi: http://dx.doi.org/10.1002/asl.173

*  Burrows CP, 2014. Accounting for the tangent point drift in the assimilation of
   gpsro data at the Met Office, *Satellite applications technical memo 14*, Met
   Office.

*  Burrows CP, Healy SB, Culverwell ID, 2014. Improving the bias
   characteristics of the ROPP refractivity and bending angle operators,
   *Atmospheric Measurement Techniques*, **7**: 3445--3458.
   doi: http://dx.doi.org/10.5194/amt-7-3445-2014

GNSS RO refractivity (NCEP)
---------------------------

Description:
^^^^^^^^^^^^

A one-dimensional observation operator for calculating the Global
Navigation Satellite System (GNSS) Radio Occultation (RO)
refractivity data, based on the refractivity operator in the NCEP 
GSI system. However, this operator is not an operational capability.
Note it is not updated or validated through extensive tests. Please 
use this operator with caution.

Configuration options (ObsFilters):
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

* :code:`Domain Check`: a generic filter used to control the maximum height one wants to assimilate RO observation. Suggested value is 30 km for GnssroRefNCEP.

* :code:`ROobserror`: a RO specific filter. Use generic filter class to apply observation error method.  More information on this filter is found in the :doc:`observation uncertainty documentation <obserrors>`

  * options: Only :code:`NBAM` (default) is implemented now.
 
* :code:`Background Check`: can only use the generic one (see the filter documents).

Examples of yaml:
^^^^^^^^^^^^^^^^^

:code:`ufo/test/testinput/gnssroref.yaml`

.. code-block:: yaml

 observations:
   observers:
   - obs space:
       name: GnssroRef
       obsdatain:
         engine:
           type: H5File
           obsfile: Data/ioda/testinput_tier_1/gnssro_obs_2018041500_s.nc4
       simulate variables: [refractivity]
     obs operator:
       name: GnssroRefNCEP
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
       errmodel: NCEP
     - filter: Background Check
       filter variables:
       - name: [refractivity]
       threshold: 3

Ground Based GNSS observation operator (Met Office)
---------------------------------------------------

The JEDI UFO interface of the Met Office's observation operator for Ground based GNSS Zenith Total Delay (ZTD). 
ZTD is the equivalent extra path that a radio signal from a Global Navigation Satellite System satellite travels from vertically overhead to a station on the ground due to the presence of the atmosphere compared to that same path through a vacuum. 
The ZTD may be expressed as

.. math::
   ZTD=10^{-6}\int_{z=0}^{z=\infty}{N dz}
 
Where :math:`z` is the height above the surface and :math:`N` is the refractivity, given by

.. math::
  N=\frac{aP}{T}+\frac{be^2}{T^2}

Where :math:`P` is pressure, :math:`e` is water vapour pressure, :math:`T` is temperature and :math:`a` and :math:`b` are the dry and wet refractivity constants respectively, given by 0.776 KPa\ :sup:`-1` and 3.73x10\ :sup:`3` K\ :sup:`2` Pa\ :sup:`-1`. ZTD can be considered to be constructed from two delay components; Zenith Wet Delay (ZWD), due to the dipole moment of water and Zenith Hydrostatic Delay (ZHD) due to the dry atmosphere.

The Met Office Ground Based GNSS observation operator makes use of a generic refractivity calculator and for the tangent linear and adjoint it calculates the ZTD gradient with respect to both the pressure and specific humidity. 

Model inputs for the forward operator are specific humidity, pressure, geopotential heights of air_pressure/full levels/theta and geopotential heights of air_pressure_levels/half levels/rho. 

Configuration options (ObsFilters):
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
These configurations are generic to using the refractivity calculator, which the Ground Based GNSS operator utilises.  
The operator requires these values to be set to the default values to work correctly, therefore, these configuration options do not need to be written out in the YAML when calling this operator.

:code:`vert_interp_ops`:
  If true, then perform vertical interpolation of pressure from half levels to full levels using ln(p), otherwise
  use exner (air_pressure levels pressure) (default: true).
:code:`pseudo_ops`:
  If true, use pseudo-levels to improve the accuracy of the refractivity
  calculation (default: false).
:code:`min_temp_grad`:
  Minimum value of the vertical temperature gradient when checking for isothermal
  levels in the pseudo-level calculation (default: 1e-6).
  
Examples of yaml:
^^^^^^^^^^^^^^^^^
:code:`ufo/test/testinput/groundgnssmetoffice.yaml`

.. code-block:: yaml

  - obs operator: 
      name: GroundgnssMetOffice
      min_temp_grad: 1.0e-6
    obs space: 
      name: Groundgnss
      obsdatain: 
        engine:
          type: H5File
          obsfile: Data/ufo/testinput_tier_1/groundgnss_obs_2019123006_obs.nc
      simulated variables: [total_zenith_delay] 
    geovals: 
      filename: Data/ufo/testinput_tier_1/groundgnss_geovals_20191230T0600Z.nc4

Details of how the operator works
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
 

Below, the method for calculating ZTD using the refractivity calculator, the partial derivatives at each calculation, and the ZTD gradient with respect to pressure and humidity is described.
Both pressure and humidity signals can be identified in the ZTD and so the gradient for the tangent linear and adjoint (TL/AD) are calculated with respect to both pressure and specific humidity. 

The operator works in the direction of surface to the model top.  

In this operator, we assume ln(pressure) is linear with height and therefore :code:`vert_interp_ops` needs to be true (default), and use this assumption to interpolate pressure on rho levels :math:`P_{\rho}` (air_pressure_levels/half levels) to pressure on theta levels :math:`P_{\theta}` (air_pressure/full levels), such that:

.. math::
  P_{\theta}=e^{((z_{weight})lnP_{\rho_{i}}+(1-z_{weight})lnP_{\rho_{i+1}} )}

Where

.. math::
  z_{weight} =\frac{z_{\rho_{i+1}}-z_{\theta_{i}}}{z_{\rho_{i+1}}-z_{\rho_{i}}},

with :math:`z_{\rho}` being the geopotential height of the rho levels and :math:`z_{\theta}` being the geopotential height of the theta levels. 
Pressure on theta and rho levels, together with specific humidity on theta levels is then passed to the generic refractivity calculator, which calculates refractivity on theta levels. The partial derivative of the pressure on theta with regards to pressure on rho levels is required for the refractivity derivatives used in the ZTD TL/AD, and is

.. math::
  \frac{\partial P_{\theta_{i}}}{\partial P_{\rho_{i}}}=\frac{P_{\theta_{i}} z_{weight}}{P_{\rho_{i}}} 

And for the ZTD above the model top we require

.. math::
  \frac{\partial P_{\theta_{i}}}{\partial P_{\rho_{i+1}}}=\frac{P_{\theta_{i}} (1-z_{weight})}{P_{\rho_{i+1}}} 

The operator then loops through the theta levels, starting with the theta level directly above the station height, calculating the delay contribution for each layer bounded by the theta levels, assuming the refractivity decays exponentially between the model levels.

.. math::
  N_{i+1}=N_{i} e^{-c(z_{i+1}-z_{i})}

Where :math:`c` is the scale height such that

.. math::
  c_{i}=\frac{lnN_{i+1}-lnN_{i}}{z_{i}-z_{i+1}} 

.. math::
  \frac{\partial c_{i}}{\partial N_{i} }=\frac{-1}{N_{i} (z_{i}-z_{i+1})}
  
.. math::  
  \frac{\partial c_{i}}{\partial N_{i+1}}=\frac{1}{N_{i+1}(z_{i}-z_{i+1})}


Delay for layer :math:`i` is then

.. math::
  ZTD_{i}=-10^{-6} \frac{N_{i}}{c_{i}} e^{c_{i} z_{i}} (e^{-c_{i} z_{i+1}}-e^{-c_{i} z_{i}})

.. math::
  \frac{\partial ZTD_{i}}{\partial c_{i}} =-10^{-6} \frac{N_{i}}{c_{i}}  (\frac{1}{c_{i}} +e^{c_{i} (z_{i}-z_{i+1})} (z_{i}-z_{i+1}-\frac{1}{c_{i}} ))

.. math::
  \frac{\partial ZTD_{i}}{\partial N_{i}}=\frac{-10^{-6}}{c_{i}}  e^{c_{i} z_{i} } (e^{-c_{i} z_{i+1} }-e^{-c_{i} z_{i} })
  
The delay for each layer is added to the running total delay.
The operator iterates up to the highest theta level, calculating the delay up to that point. 
A further small correction must be made for the signal above the model top. An assumption of hydrostatic equilibrium is used to calculate the integral 

.. math::
   ZTD_{top}=10^{-6}\int_{z=z_{modeltop}}^{z=\infty}{\frac{aP}{T}}dz

which then gives the delay above the model top as

.. math::
  ZTD_{top}=\frac{10^{-6} aR}{g} P_{\theta_{top}}
  
where :math:`R` is the gas constant and :math:`g` is the gravitational acceleration.
  
:math:`ZTD_{top}` is then added to the accumulated ZTD. Therefore the partial differentials with respect to specific humidity :math:`q` and pressure at the top of the model levels (note for rho levels, :math:`\rho_{top}` is one level above :math:`\theta_{top}`) are

.. math::
  \frac{\partial {ZTD_{top}}}{\partial {q_{\theta_{top}}}}=0.0

.. math::
  \frac{\partial{ZTD_{top}}}{\partial P_{\rho_{top}}}=0.0

.. math::
  \frac{\partial ZTD_{top}}{\partial P_{\theta_{top}}} =\frac{10^{-6} aR}{g}


At the model bottom (see GBGNSS figure 1), if the station height is below the model bottom, the scale height from the first model layer is used, and the height of the station is used in the Zenith delay calculation such that

.. math::
  ZTD_{1}=-10^{-6}  \frac{N_{1}}{c_{1}}  e^{c_{1} z_{1} } (e^{-c_{1} z_{2} }-e^{-c_{1} z_{station} })

and

.. math::
  \frac{dZTD_{1}}{dN_{1}}=\frac{\partial ZTD_{1}}{\partial N_{1}}+\frac{\partial ZTD_{1}}{\partial c_{1}}  \frac{\partial c_{1}}{\partial N_{1}}
  
If the station lies above the lowest model level, the refractivity is interpolated exponentially to the station height (see GBGNSS figure 2) from level :math:`i`, the scale height is that for the whole model layer i.e. :math:`z_{i}` to :math:`z_{i+1}`, and Zenith delay is calculated from the station height such that

.. math::
  ZTD_{station}=-10^{-6} \frac{N_{station}}{c_{i}} e^{c_{i} z_{station}} (e^{-c_{i} z_{i+1} }-e^{-c_{i} z_{station}})
  
and

.. math::
  \frac{dZTD_{i}}{dN_{i}}=\frac{\partial ZTD_{station}}{\partial N_{station}} \frac{\partial N_{station}}{\partial N_{i}}+\frac{\partial ZTD_{station}}{\partial c_{i}} \frac{\partial c_{i}}{\partial N_{i}}

Where

.. math:: 
  \frac{\partial ZTD_{station}}{\partial c_{i}}=\frac{\partial ZTD_{station}}{\partial c_{i}}+\frac{\partial ZTD_{station}}{\partial N_{station}}  \frac{\partial N_{station}}{\partial c_{i}}

And

.. math::
  \frac{\partial N_{station}}{\partial c_{i}}=-N_{station} (z_{station}-z_{i+1})

Using the above partial differentials, and using the partial differential of refractivity with respect to pressure and specific humidity, the differential of ZTD with respect to input pressure and humidity on the rest of the levels can be found through: 

.. math::
  \frac{dZTD_{i}}{dN_{i}}=\frac{\partial ZTD_{i}}{\partial N_{i}}+\frac{\partial ZTD_{i}}{\partial c_{i}}  \frac{\partial c_{i}}{\partial N_{i}} +\frac{\partial ZTD_{i}}{\partial c_{i-1}}  \frac{\partial c_{i-1}}{\partial N_{i}}

.. math::
  \frac{dZTD_{i}}{dP_{\rho_{i}}}=\frac{\partial ZTD_{i}}{\partial N_{i}}  \frac{\partial N_{i}}{\partial P_{\rho_{i}}}

.. math::
  \frac{dZTD_{i}}{dq_{\theta_{i}}}=\frac{\partial ZTD_{i}}{\partial N_{i}}  \frac{\partial N_{i}}{\partial q_{\theta_{i}}}

.. image:: images/GNSS_Station_height_below_model_surface.png
           :alt: A diagram for stations below model levels

GBGNSS Figure 1: Diagram of the model levels with the station height lying below the lowest model level. 

.. image:: images/GNSS_Station_height_between_levels.png
           :alt: A diagram for stations between levels
	   
GBGNSS Figure 2: Diagram of the model levels with the station height lying between two model levels. 

.. _obsops_identity:

Identity observation operator
-----------------------------------

Description:
^^^^^^^^^^^^

A simple identity observation operator, applicable whenever only horizontal interpolation of model variables is required.

This operator can be used as a component of the :ref:`Composite <obsops_composite>` operator.

Configuration options:
^^^^^^^^^^^^^^^^^^^^^^

* :code:`variables` [optional]: a list of names of ObsSpace variables to be simulated by this operator (see the example below). This option should only be set if this operator is used as a component of the `Composite` operator. If it is not set, the operator will simulate all ObsSpace variables.

* :code:`level index 0 is closest to surface`: a boolean variable that specifies whether index 0 of a model column is closest to the Earth's surface. Default value: :code:`false`.

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

In situ particulate matter (PM) operator
----------------------------------------

Description:
^^^^^^^^^^^^

This operator calculates modeled particulate matter (PM) at monitoring stations, such as the U.S. AirNow sites that provide PM2.5 & PM10 data. With few/no code changes, it can also be applied to calculate total or/and speciated PM for applications related to other networks/datasets.

Unit conversion is included in the calculations.

The users are allowed to select a vertical interpolation approach to: 1) match model height (above sea level, asl = height above ground level + surface height) to station elevation (also asl) which is required for the AirNow application; or 2) match model log(air_pressure) to observation log(air_pressure), likely suitable for use with other types of observational datasets that contain pressure information, e.g. aircraft, sonde, tower...

Currently this tool mainly supports the calculation from the NOAA FV3-CMAQ aerosol fields (user-defined, up to 70 individual species). Based on the user definition, the calculation can involve the usage of the model-based scaling factors for three modes of Aitken, accumulation, and coarse.

Configuration options:
^^^^^^^^^^^^^^^^^^^^^^

* :code:`simulated variables`: variables to be simulated, total or speciated PM. [Note: This operator currently works well with one "simulated variable", e.g., PM25 or total PM. With slight modifications it can be used to simulate multiple speciated PM variables]
* :code:`vertical_coordinate`: character, vertical interpolation approach chosen. As described above, height_asl (default) and log_pressure are currently supported. If neither option is chosen, the application will stop with an error msg.
* :code:`model` [required]: character, model name. This operator currently mainly supports CMAQ. If the model name is not CMAQ, the application will stop with an error msg.
* :code:`tracer_geovals` [required]: character, a list of names of model aerosol species needed to calculate the "simulated variables"
* :code:`use_scalefac_cmaq`: logical, false by default, indicating whether scaling factors will be applied to execute PM2.5 or total PM related steps
* :code:`tracer_modes_cmaq` [optional]: a list of integers indicating CMAQ aerosol modes (1-Aitken; 2-accumulation; 3-coarse). This option should only be set if the model name is CMAQ and "use_scalefac_cmaq" is set to "true". The sizes of tracer_modes_cmaq and tracer_geovals must be consistent.

Examples of yaml:
^^^^^^^^^^^^^^^^^

.. code-block:: yaml

    simulated variables: [pm25]
  obs operator:
    name: InsituPM
    tracer_geovals: [aso4i,ano3i,anh4i,anai,acli,aeci,aothri,alvpo1i,asvpo1i,asvpo2i,alvoo1i,alvoo2i,asvoo1i,asvoo2i,
                        aso4j,ano3j,anh4j,anaj,aclj,aecj,aothrj,afej,asij,atij,acaj,amgj,amnj,aalj,akj,
                        alvpo1j,asvpo1j,asvpo2j,asvpo3j,aivpo1j,axyl1j,axyl2j,axyl3j,atol1j,atol2j,atol3j,
                        abnz1j,abnz2j,abnz3j,aiso1j,aiso2j,aiso3j,atrp1j,atrp2j,asqtj,aalk1j,aalk2j,apah1j,
                        apah2j,apah3j,aorgcj,aolgbj,aolgaj,alvoo1j,alvoo2j,asvoo1j,asvoo2j,asvoo3j,apcsoj,
                        aso4k,asoil,acors,aseacat,aclk,ano3k,anh4k]
    vertical_coordinate: height_asl
    model: CMAQ
    use_scalefac_cmaq: true
    tracer_modes_cmaq: [1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,
                        2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,3,3,3,3,3,3,3]

In the example above, this `InsituPM` operator calculates modeled (CMAQ) PM2.5 at selected U.S. AirNow monitoring stations. This calculation is based on 70 CMAQ aerosol species (defined in "tracer_geovals") in three modes (defined in "tracer_modes_cmaq"), with mode-specific scaling factors applied (use_scalefac_cmaq: true). Vertical interpolation is conducted to match the model height (asl) with the monitoring station elevation (vertical_coordinate: height_asl).

Radar Radial Velocity
--------------------------

Description:
^^^^^^^^^^^^

Similar to RadarReflectivity, but for radial velocity. It is tested with radar observations dumped from a specific modified GSI program at NSSL for the Warn-on-Forecast project.

Examples of yaml:
^^^^^^^^^^^^^^^^^

.. code-block:: yaml

  observations:
    observers:
    - obs operator:
        name: RadarRadialVelocity
      obs space:
        name: Radar
        obsdatain:
          engine:
            type: H5File
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
    observers:
    - obs operator:
        name: ScatwindNeutralMetOffice
      obs space:
        name: Scatwind
        obsdatain:
          engine:
            type: H5File
            obsfile: Data/ioda/testinput_tier_1/scatwind_obs_1d_2020100106.nc4
        obsdataout:
          engine:
            type: H5File
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

SfcPCorrected
---------------------------------------

Description:
^^^^^^^^^^^^
This forward operator contains several schemes to correct the computation of surface atmospheric pressure at a location for the discrepancy in model topography at the observation location. Note that only the nonlinear operator is included, and to use it in variational applications will require specifying the linear obs operator (Identity).

Schemes:

:code:`GSI`: If there is observed temperature along with pressure, take the average of the model simulated and observed near surface temperature, otherwise use just the model simulated temperature (and extrapolate to the surface using 6.5K/km 
lapse rate if the ob height is below the model lowest layer).  Then the pressure output from this option is the model (background) surface pressure corrected from model surface to observation height as such: 

.. math::
  H(x) = exp(log(Ps_{model}) - ((Zs_{ob} - Zs_{model}) * (gravity * Rd) / Tv_{avg})) 

where `Rd` is 287.05 J/kg/K, `Ps` and `Zs` are the surface pressure and height, and 
`Tv_avg` is the averged virtual temperature of the model surface virtual temperature (`Tv_model`) and observed (virtual) temperature as such: 

.. math::
  Tv_{avg} = (Tv_{model} + Tv_{ob})/2.0

if the surface obervation has virtual temperature value (`Tv_ob`). Otherwise

.. math::
  Tv_{avg} = (Tv_{model} + T_{ob})/2.0 

:code:`UKMO`: If the observed surface height and pressure are not missing, the pressure output from this option is the corrected
model pressure as such: 

.. math::
  H(x) = Ps_{model}+(Ps_{ob}-Ps_{o2m}) 

where `Ps_model` and `Ps_ob` are the model and observed surface
pressure, and `Ps_o2m` is the observed pressure adjusted to the model surface height. 
`Ps_o2m` is computed based on the method descried in UKMO Technical Report No.582, Appendix 1, by B. Ingleby (2013) as such:

.. math::
  Ps_{o2m} = Ps_{ob} * (Ps_{model}/Ps_{m2o})

`Ps_m2o` is the model(background) surface pressure adjusted to observed station height as such:

.. math::
  Ps_{m2o} = Ps_{model} * (T_{m2o}/T_{model})** (gravity / Rd * L) 

where `L` is the constant lapse rate (0.0065 K/m), 
`T_model` is the temperature at model surface height (`H_model`), derived from the virtual temperature at 2000m above the model surface height (Tv_2000) to avoid diurnal/local variations, and `T_m2o` is the model temperature at observed station height (`H_ob`) as such:

.. math::
  T_{model} = TV_{2000} * (Ps_{model} / P_{2000}) ** (Rd * L / gravity)

.. math::
  T_{m2o} = T_{model} + L*(H_{model} - H_{ob})


:code:`WRFDA`: This option is based on a subroutine from WRFDA da_intpsfc_prs.inc file
corresponding to `sfc_assi_options = 1` in WRFDA's namelist.
If the observed surface height and pressure are not missing, the pressure output from this option is the corrected
model pressure as such: 

.. math::
  H(x) = Ps_{model}+(Ps_{obs}-Ps_{o2m}) 

where `Ps_o2m` is the observed pressure adjusted from station hight to model surface height as such

.. math::
  Ps_{o2m} = Ps_{ob} * exp(- (H_{model} - H_{ob}) * gravity / (Rd * Tv_{avg}))

where `Tv_avg` is the averged virtual temperature of the model surface virtual temperature (`Tv_model`) and observed (virtual) temperature as such:

.. math::
   Tv_{avg} = (Tv_{model} + Tv_{ob})/2.0


Where the observed virtual temperature value is computed from the observed temperature and humidity, or using the observed
temperature or model temperature if there are missing values for any observed quantities.



Configuration options:
^^^^^^^^^^^^^^^^^^^^^^
* da_psfc_scheme - choice of `UKMO`, `GSI`, or `WRFDA` methods
* geovar_geomz - name of height geovar
* geovar_sfc_geomz - name of surface altitude/elevation geovar

Examples of yaml:
^^^^^^^^^^^^^^^^^
.. code-block:: yaml

  observations:
    observers:
    - obs space:
      name: sondes_ps
      obsdatain:
        engine:
          type: H5File
          obsfile: sondes_ps_obs_2022082300.nc4
      obsdataout:
        engine:
          type: H5File
          obsfile: sondes_ps_diag_2022082300.nc4
      simulated variables: [surface_pressure]
    obs operator:
      name: SfcPCorrected
      da_psfc_scheme: GSI
      geovar_sfc_geomz: surface_geopotential_height
      geovar_geomz: geopotential_height
    linear obs operator:
      name: Identity

Background Error Vertical Interpolation
---------------------------------------

This operator calculates ObsDiagnostics representing vertically interpolated
background errors of the simulated variables.

It should be used as a component of the :ref:`Composite <obsops_composite>` observation operator (with another
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

It should be used as a component of the :ref:`Composite <obsops_composite>` observation operator (with another
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

Total column water vapour
--------------------------

Description:
^^^^^^^^^^^^

The operator (SatTCWV) to calculate total column water vapour (TCWV) or precipitable water from the 
model specific humidity profiles. Clear air is assumed. On input, the operator requires surface 
pressure (Pa), and pressure (Pa) and specific humidity (kg/sq.m) for each model layer. The model 
levels input should be from the top of the atmosphere going down. Furthermore it is expected that 
the model layer pressures and humidities are on staggered levels with respect to each other, i.e. 
the humidity values are valid for heights between the pressure levels. This was written for use with
the OLCI total column water vapour product but other possibilities are MODIS, ABI, FCI.


Example of a yaml
^^^^^^^^^^^^^^^^^^

.. code-block:: yaml

  - obs operator: 
      name: SatTCWV

..
   Link to the marine ufo

.. include:: marineufo.rst

.. _profileaverageoperator:

Profile Average operator
------------------------

This observation operator produces H(x) vectors which correspond to vertically-averaged profiles. The algorithm determines the locations at which reported-level profiles
intersect each model pressure level. The intersections are found by stepping through the observation locations from the lowest-altitude value upwards. For each model level,
the location of the observation whose pressure is larger than, and closest to, the model pressure is recorded. The :code:`vertical coordinate` parameter controls the model pressure GeoVaLs that are used in this procedure. If there are no observations in a model level, which can occur for (e.g.) sondes reporting in low-frequency TAC format, the location corresponding to the last filled level is used. (If there are some model levels closer to the surface than the lowest-altitude observation, the location of the lowest observation is used for these levels.)

This procedure is iterated multiple times in order to account for the fact that model pressures can be slanted close to the Earth's surface. The number of iterations is configured with the :code:`number of intersection iterations` parameter.

Having obtained the profile boundaries, values of model pressure and any simulated variables are obtained as in the locations that were determined in the procedure above.
This produces a single column of model values which are used as the H(x) variable.

In order for this operator to work correctly the ObsSpace must have been extended as in the following yaml snippet:


.. code-block:: yaml

  - obs space:
     extension:
       average profiles onto model levels: 71


(where 71 can be replaced by the length of the air_pressure_levels GeoVaL). The H(x) values are placed in the extended section of the ObsSpace. Note that, unlike what may be expected for an observation operator, averaging of the model values across each layer is not performed; a single model value is used in each case.

A comparison with results obtained using the Met Office OPS system is performed if the option :code:`compare with OPS` is set to true. This checks values of the locations and pressure values associated with the slant path. All other comparisons are performed with the standard :code:`vector ref` option in the yaml file.

This operator also accepts an optional :code:`variables` parameter, which controls which ObsSpace variables will be simulated. This option should only be set if this operator is used as a component of the Composite operator. If :code:`variables` is not set, the operator will simulate all ObsSpace variables. Please see the documentation of the Composite operator for further details.


Configuration options
^^^^^^^^^^^^^^^^^^^^^

- :code:`variables`: List of variables to be used by this operator.

- :code:`model vertical coordinate`: Name of model vertical coordinate.

- :code:`number of intersection iterations`: Number of iterations that are used to find the intersection between the observed profile and each model level. Default: 3.

- :code:`compare with OPS`: If true, perform comparisons of auxiliary variables with the Met Office OPS system. Default: false.

- :code:`pressure coordinate`: Name of air pressure coordinate.

- :code:`pressure group`: Name of air pressure group.


Example
^^^^^^^

.. code-block:: yaml

    # Operator used to calculate H(x) for averaged profiles
    - name: ProfileAverage
      model vertical coordinate: "air_pressure_levels"
      pressure coordinate: air_pressure
      pressure group: MetaData
