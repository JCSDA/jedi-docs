Profile Specific QC Filters
===========================

Profile Background Check
------------------------

This filter calculates the RMS difference between the observations and the background for a profile.  If that RMS is above the given threshold, then all the observations in the profile are rejected.  Each variable is checked independently, so the rejection of the profile for one variable will not affect the other variables.

The user can specify two options in the yaml: :code:`absolute threshold` and :code:`relative threshold`.  Only one of these two options may be set.  If :code:`absolute threshold` is set, then the RMS is calculated without normalisation.  If :code:`relative threshold` is used, then the differences are normalised by the observation error for each observation-background difference.  Both :code:`absolute threshold` and :code:`relative threshold` can be either a single number or a string.  If they are a string, then this is the name of a variable which will be used to give the threshold for each profile.  The RMS value will be compared against the first value of the given variable in the profile.  The sorting of observations within each profile can be arranged using other options in the yaml file.

.. code-block:: yaml

    window begin: 2020-12-31T23:59:00Z
    window end: 2021-01-01T00:01:00Z

    observations:
    - obs space:
        name: test data
        obsdatain:
        obsfile: Data/ufo/testinput_tier_1/profile_filter_testdata.nc4
        obsgrouping:
          group variables: [ "record_number" ]
          sort variable: "latitude"
          sort order: "descending"
        simulated variables: [variable]
      HofX: HofX
      obs filters:
      - filter: Profile Background Check
        filter variables:
        - name: variable
        absolute threshold: 2.5
      
Note: The :code:`obsgrouping: group variables` option is necessary to identify which observations belong to a given profile.  The :code:`sort variable` and :code:`sort order` options are optional.

Note: This is separate from the background check in :ref:`profile consistency checks <profconcheck_background>`.

Profile Few Observations Check
------------------------------

This filter finds the number of valid observations within a profile.  If this number is less than the filter parameter :code:`threshold` then all observations in the profile are rejected.

.. code-block:: yaml

    window begin: 2020-12-31T23:59:00Z
    window end: 2021-01-01T00:01:00Z

    observations:
    - obs space:
        name: test data
        obsdatain:
        obsfile: Data/ufo/testinput_tier_1/profile_filter_testdata.nc4
        obsgrouping:
          group variables: ["record_number"]
        simulated variables: [variable]
      obs filters:
      - filter: Profile Few Observations Check
        filter variables:
        - name: variable
        threshold: 10

Note: The :code:`obsgrouping: group variables` option is necessary to identify which observations belong to a given profile.

Impact Height Check
-------------------

This filter is specific to GNSS-RO.  It is based on the impact height, which is calculated from the model as :math:`x = 10^{-6} N (r_0 + z) + z`, where :math:`N` is the refractivity, :math:`r_0` is the radius of curvature of the earth at the observation tangent point and :math:`z` is the geopotential height of the model layer.

For each observation it calculates the impact height of the lowest and highest model level.  If the observation is outside this range (plus :code:`surface offset`:) then the observation is rejected.

The filter also looks for regions where the vertical gradient of refractivity is large (i.e. less than :code:`gradient threshold`:, which is normally negative).  Any observations lower in the atmosphere than a large vertical gradient (plus :code:`sharp gradient offset`:) are rejected.  The algorithm starts looking from the top of the profile.  Therefore a large gradient which is highest in the atmosphere will be the one which is considered.  Large refractivity gradients are often associated with temperature inversions, and the radio-occultation retrieval can become ill-posed below such layers.

The following are the optional flags which may be used with this routine:

* :code:`surface offset`:  Reject data which is within this height (in m) of the surface. Default: :code:`600`.
* :code:`gradient threshold`:  The threshold used to define a sharp gradient in refractivity. Units: N-units / m. Default: :code:`-0.08`.
* :code:`sharp gradient offset`:  The height (in m) of a buffer-zone for rejecting data above sharp gradients. Default: :code:`500`.

This filter relies on the refractivity and model geopotential heights being saved as :code:`ObsDiagnostics`.  If these are not saved by the observation operator, then the code will fail.  More details on saving diagnostics are given below.  :code:`GnssroBendMetOffice` is an example of an observation operator which saves these data.

.. code-block:: yaml

    window begin: 2020-05-01T03:00:00Z
    window end: 2020-05-01T09:00:00Z

    observations:
    - obs operator:
        name: GnssroBendMetOffice
        obs options:
          vert_interp_ops: true
          pseudo_ops: true
      obs space:
        name: GnssroBnd
        obsdatain:
          obsfile: Data/ioda/testinput_tier_1/gnssro_obs_2020050106_1dvar.nc4
        simulated variables: [bending_angle]
      geovals:
        filename: Data/ufo/testinput_tier_1/gnssro_geoval_2020050106_1dvar.nc4
      obs filters:
      - filter: GNSSRO Impact Height Check
        filter variables:
        - name: bending_angle
        gradient threshold: -0.08
        sharp gradient offset: 600
        surface offset: 500


Profile Consistency Checks
--------------------------

.. _profconcheck_overview:

Overview
^^^^^^^^

This filter comprises several QC checks that can be applied to atmospheric profile data (e.g. as measured by radiosondes) whose observations lie at particular pressure levels.
These checks have been ported from UK Met Office observation processing system (OPS).
The following checks are available:

- **Basic**: These checks ensure the profile pressures lie in a reasonable range and are in the correct order.
  :ref:`Click here for more details <profconcheck_basic>`.

- **SamePDiffT**: If two levels have the same pressure, but their temperature difference is larger than a threshold, reject one of the levels.
  :ref:`Click here for more details <profconcheck_samepdifft>`.

- **Sign**: This check determines whether an observed temperature may have had its sign (in degrees Celsius) recorded incorrectly.
  To do this the temperature is compared to the model background value.
  If the check is failed a temperature correction is calculated.
  :ref:`Click here for more details <profconcheck_sign>`.

- **UnstableLayer**: The temperature in a particular level is used to compute the expected temperature in the level above given the dry adiabatic lapse rate.
  If the measured temperature in the level above is lower than its expected value by a certain threshold then both levels are flagged.
  :ref:`Click here for more details <profconcheck_unstablelayer>`.

- **Interpolation**: The temperature between adjacent significant pressure levels is interpolated onto any encompassed standard pressure levels.
  If the interpolated temperature differs from the observed value by more than a particular threshold then the relevant standard and significant levels are flagged.
  (Further information on standard and significant levels can be found :ref:`here <profconcheck_standardlevels>`.)
  :ref:`Click here for more details <profconcheck_interpolation>`.

- **Hydrostatic**: This is a check of the consistency between the observed values of temperature and geopotential height at each pressure level.
  The check relies on the hydrostatic equation and has a complicated decision-making algorithm.
  If a particular level fails this check then a height correction is (sometimes) computed.
  :ref:`Click here for more details <profconcheck_hydrostatic>`.

- **UInterp**: The wind speed between adjacent significant pressure levels is interpolated onto any encompassed standard pressure levels.
  If the vector difference of the interpolated and measured wind speeds is larger than a certain threshold then the relevant standard and significant levels are flagged.
  :ref:`Click here for more details <profconcheck_uinterp>`.

- **RH**: This check detects relative humidity errors at the top of cloud layers and at high altitudes.
  :ref:`Click here for more details <profconcheck_rh>`.

- **Time**: This check flags any observations whose time of measurement lies outside the assimilation window. It also optionally rejects wind values for a certain period after launch.
  :ref:`Click here for more details <profconcheck_time>`.

- **BackgroundX**: These checks use a Bayesian approach to modify the probability of gross error for several variables (**X** can be **GeopotentialHeight**, **RelativeHumidity**, **Temperature** or **WindSpeed**). The use of such an approach distinguishes these checks from the Background Check filter introduced above.
  :ref:`Click here for more details <profconcheck_background>`.

- **PermanentReject**: This check permanently rejects observations that have previously been flagged as failing by another check.
  :ref:`Click here for more details <profconcheck_permrej>`.

- **SondeFlags**: This check accounts for any QC flags that were assigned to the sonde data prior to UFO being run.
  :ref:`Click here for more details <profconcheck_sondeflags>`.

- **WindProfilerFlags**: This check accounts for any QC flags that were assigned to the wind profiler data prior to UFO being run.
  :ref:`Click here for more details <profconcheck_winproflags>`.

- **Pressure**: This routine calculates profile pressures if they have not been measured (or were measured but are potentially inaccurate). This is achieved by vertical interpolation and extrapolation using the observed height and model values of height and pressure.
  :ref:`Click here for more details <profconcheck_pressure>`.

This filter can apply more than one check in turn. Please note the following:

- The total number of errors that have occurred is recorded as the filter proceeds through each check.
  If this number exceeds a threshold (set by defining the parameter :code:`nErrorsFail`) then the entire profile is rejected.

- The basic checks are always performed unless they are specifically disabled (by setting the parameter :code:`flagBasicChecksFail` to true).

..
  (Commented out for now - will be revisited once all of the filters are in place)
  The checks must be performed in a particular order if it is desired to exactly reproduce the operation of the OPS code.
  This is because the QC flags (and values of temperature or height) that are modified in one routine may then be read by a subsequent routine.
  To achieve the same outcome as in the OPS code the following order must be used:
  Basic, SamePDiffT, Sign, UnstableLayer, Interpolation, Hydrostatic, UInterp, RH.

.. _profconcheck_filtervars:

Filter variables
^^^^^^^^^^^^^^^^

The QC checks rely on a variety of physical observables. The value of :code:`filter variables` for each check should be:

- Basic, SamePDiffT, Sign, UnstableLayer, Interpolation, Hydrostatic: :code:`air_temperature`, :code:`geopotential_height`.

- UInterp: :code:`eastward_wind`, :code:`northward_wind`.

- RH: :code:`air_temperature`, :code:`relative_humidity`.

- BackgroundX: :code:`air_temperature`, :code:`relative_humidity`, :code:`eastward_wind`, :code:`northward_wind`, :code:`geopotential_height` depending on the value of X.

- Pressure: :code:`geopotential_height`.

- Time, PermanentReject, SondeFlags, WindProfilerFlags: these routines act on QC flags so must be supplied with a dummy filter variable. Any variable that exists in the data set is acceptable; :code:`eastward_wind` would be a good choice.

The :code:`obsgrouping` category should be set up in one of two ways. The first applies a descending sort to the air pressures:

.. code-block:: yaml

        obsgrouping:
          group variable: "station_id"
          sort variable: "air_pressure"
          sort order: "descending"

The second does not sort the air pressures:

.. code-block:: yaml

        obsgrouping:
          group variable: "station_id"

The second formulation could be used if the pressures have been sorted prior to applying this filter.
An ascending sort order is not valid; if this is selected the checks will throw an error.
In both cases the station ID is used to discriminate between different sonde profiles.

:ref:`Back to overview of profile consistency checks <profconcheck_overview>`

.. _profconcheck_generic:

Filter configuration
^^^^^^^^^^^^^^^^^^^^

The following yaml parameters can be used to configure the filter itself:

- :code:`Checks`: List of checks to perform. The checks will be performed in the specified order.  Examples: ["Basic"], ["Basic", "Hydrostatic", "UInterp"].

- :code:`nErrorsFail`: Total number of errors at which an entire profile is rejected (default 1).

- :code:`flagBasicChecksFail`: Reject a profile if it fails the basic checks (default true). This should only be set to false for testing purposes.

- :code:`compareWithOPS`: Compare values obtained in these checks with the equivalent values produced in the OPS code (default false).
  This is set to true for certain unit tests (named :code:`*OPScomparison*`) for which the relevant quantities are present in the input files.

- :code:`Comparison_Tol`: Tolerance for comparisons with OPS, enabling rounding errors to be accommodated (default 0.1).

:ref:`Back to overview of profile consistency checks <profconcheck_overview>`

.. _profconcheck_standardlevels:

Standard and significant levels
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

**Definitions**

Standard, or mandatory, levels are values of pressure at which it has been internationally agreed that complete measurements of the physical observables should ideally be recorded.
Significant levels correspond to other pressure values at which the physical observables should be recorded to get an accurate picture of the sonde ascent.

Each profile is checked for the presence of both standard and significant levels.

**Summary of yaml parameters:**

- :code:`FS_MinP`: Minimum pressure for including a level in standard level finding routine (default 0.0 Pa).

- :code:`StandardLevels`: list of standard levels (default [1000, 925, 850, 700, 500, 400, 300, 250, 200, 150, 100, 70, 50, 30, 20, 10, 7, 3, 2, 1] hPa). These are internationally-agreed values and should usually not be changed.

:ref:`Back to overview of profile consistency checks <profconcheck_overview>`

.. _profconcheck_basic:

Basic check
^^^^^^^^^^^

**Operation**

The following basic checks are applied to each profile:

- There is at least one pressure level present,

- The pressures lie between minimum and maximum values (\ :code:`BChecks_minValidP` and :code:`BChecks_maxValidP`),

- The pressures are in descending order.

Any profiles that do not meet these criteria are rejected.

**Summary of yaml parameters**

- :code:`BChecks_minValidP`: Minimum pressure in profile (default 0.0 Pa).

- :code:`BChecks_maxValidP`: Maximum pressure in profile (default 110.0e3 Pa).

- :code:`BChecks_Skip`: Do not perform the basic checks (default false). Only set to true for unit tests in which the input sample consists of pressures that should not be sorted.

:ref:`Back to overview of profile consistency checks <profconcheck_overview>`

.. _profconcheck_samepdifft:

SamePDiffT check
^^^^^^^^^^^^^^^^

**Operation**

This check searches for pairs of levels that have identical pressures but for which the absolute difference between their temperatures is larger than a particular threshold (\ :code:`SPDTCheck_TThresh`).
The level with the larger absolute difference between the observed and model background temperature is rejected.

**Summary of yaml parameters**

- :code:`SPDTCheck_TThresh`: Absolute temperature difference threshold (default 0.0 K).

:ref:`Back to overview of profile consistency checks <profconcheck_overview>`

.. _profconcheck_sign:

Sign check
^^^^^^^^^^

**Operation**

The sign check for a particular level is failed in the following case:

- The absolute difference between the observed and model background temperature is larger than a threshold (\ :code:`SCheck_tObstBkgThresh`),

- Changing the sign (in degrees C) of the observed temperature causes its absolute difference relative to the model background temperature (also in degrees C) to be smaller than a threshold (\ :code:`SCheck_ProfileSignTol`),

- The level pressure is lower by more than a certain amount (\ :code:`SCheck_PstarThresh`) than the model surface pressure.

**Summary of yaml parameters**

- :code:`SCheck_tObstBkgThresh`: Threshold for absolute temperature difference between observation and background (default 5.0 K).

- :code:`SCheck_ProfileSignTol`: Threshold for absolute temperature difference between observation and background after the observation sign has been changed (default 100.0 degrees C).

- :code:`SCheck_PstarThresh`: Threshold for difference between observed pressure and model surface pressure (default 1000.0 Pa).

- :code:`SCheck_PrintLargeTThresh`: Pressure threshold above which large temperature differences are printed (default 1000.0 Pa).

- :code:`SCheck_CorrectT`: Compute correction to temperature (default true).

:ref:`Back to overview of profile consistency checks <profconcheck_overview>`

.. _profconcheck_unstablelayer:

UnstableLayer check
^^^^^^^^^^^^^^^^^^^

**Operation**

The temperature at a particular level is used to compute the temperature at the adjacent level (upwards) in the profile.
The calculation assumes that the temperature-pressure relationship follows the dry adiabatic lapse rate.
If the observed temperature at the adjacent level is lower than the calculated temperature by more than a particular amount (\ :code:`ULCheck_SuperadiabatTol`) the level is flagged.
This check is only applied to levels whose pressure is larger than a minimum threshold (\ :code:`ULCheck_MinP`) and lower by a certain amount (\ :code:`ULCheck_PBThresh`) than the surface pressure.

**Summary of yaml parameters**

- :code:`ULCheck_SuperadiabatTol`: Temperature difference threshold between observed temperature and temperature computed assuming dry adiabatic lapse rate (default -1.0 K).

- :code:`ULCheck_PBThresh`: Threshold on difference between level pressure and 'bottom' pressure (which can change during the routine) (default 10000.0 Pa).

- :code:`ULCheck_MinP`: Minimum pressure at which the checks are performed (default 0.0 Pa).

:ref:`Back to overview of profile consistency checks <profconcheck_overview>`

.. _profconcheck_interpolation:

Interpolation check
^^^^^^^^^^^^^^^^^^^

**Operation**

The temperature is interpolated from significant levels onto any encompassed standard levels.
If the absolute difference between the standard level temperature and the interpolated value is more than a particular threshold (\ :code:`ICheck_TInterpTol`) then the level in question, together with the relevant significant levels,
are all flagged.
Below a particular pressure (\ :code:`ICheck_TolRelaxPThresh`) the threshold is relaxed by multiplying it by the factor :code:`ICheck_TolRelax`.

This check is only performed if the pressure difference between the standard and significant levels is not too large.
The difference, known loosely as a 'big gap', depends upon the pressure of the standard level.
As the standard level pressure decreases, the big gaps also decrease in size
according to the list in :code:`ICheck_BigGaps`; the smallest big gap is defined as :code:`ICheck_BigGapInit`.

**Summary of yaml parameters**

- :code:`ICheck_TInterpTol`: Threshold for temperature difference between observed and interpolated value (default 1.0 K).

- :code:`ICheck_TolRelaxPThresh`: Pressure below which temperature difference threshold is relaxed (default 50000.0 Pa).

- :code:`ICheck_TolRelax`: Multiplicative factor for temperature difference threshold, used if pressure is lower than :code:`ICheck_TolRelaxPThresh` (default 1.0).

- :code:`ICheck_BigGaps`: 'Big gaps' for use in this check (default [500, 500, 500, 500, 100, 100, 100, 100, 50, 50, 50, 50, 10, 10, 10, 10, 10, 10, 10, 10] hPa).

- :code:`ICheck_BigGapInit`: Smallest value of 'big gap' (default 1000.0 Pa).

:ref:`Back to overview of profile consistency checks <profconcheck_overview>`

.. _profconcheck_hydrostatic:

Hydrostatic check
^^^^^^^^^^^^^^^^^

**Operation**

The hydrostatic check is used to check the consistency of the standard levels. The thickness between two standard levels is computed according to the hydrostatic equation.

If this thickness differs from the measured value by more than a particular amount then the associated levels may be flagged.
A decision-making algorithm is used to classify the levels as having height or temperature errors.

**Summary of yaml parameters**

- :code:`HCheck_CorrectZ`: Compute correction to Z (default true).

- :code:`HydDesc`: Text description of hydrostatic errors.

- There are a large number of thresholds used in the decision-making algorithm. Their default values are listed here:

  - :code:`HCheck_SurfacePThresh`: 10000.0 Pa

  - :code:`HCheck_ETolMult`: 0.5

  - :code:`HCheck_ETolMax`: 1.0 m

  - :code:`HCheck_ETolMaxPThresh`: 50000.0 Pa

  - :code:`HCheck_ETolMaxLarger`: 1.0 m

  - :code:`HCheck_ETolMin`: 1.0 m

  - :code:`HCheck_EThresh`: 100.0 m

  - :code:`HCheck_EThreshB`: 100.0 m

  - :code:`HCheck_ESumThresh`: 50.0 m

  - :code:`HCheck_MinAbsEThresh`: 10.0 m

  - :code:`HCheck_ESumThreshLarger`: 100.0 m

  - :code:`HCheck_MinAbsEThreshLarger`: 100.0 m

  - :code:`HCheck_CorrThresh`: 5.0 m

  - :code:`HCheck_ESumNextThresh`: 50.0 m

  - :code:`HCheck_MinAbsEThreshT`: 10.0 m

  - :code:`HCheck_CorrDiffThresh`: 10.0

  - :code:`HCheck_CorrMinThresh`: 1.0

:ref:`Back to overview of profile consistency checks <profconcheck_overview>`

.. _profconcheck_uinterp:

UInterp check
^^^^^^^^^^^^^

**Operation**

This check is used to detect two types of error in the observed wind speed.
The first occurs when two levels have identical pressures but a large vector difference between their measured wind speeds.
If the squared difference between the measured wind speeds is larger than a threshold (\ :code:`UICheck_TInterpIdenticalPTolSq`) then both levels are flagged.

The second type of error is detected by interpolating the significant level wind speeds onto any encompassed standard levels,
as is done for temperature in the Interpolation check (\ :ref:`see here <profconcheck_interpolation>`).
If the squared difference between the interpolated and measured wind speeds is larger than a certain amount (\ :code:`UICheck_TinterpTolSq`) then
both levels are flagged.

Similarly to the interpolation check, the second type of error is only searched for if the pressure difference between the adjacent standard levels is not too large.
The maximum permitted difference is referred to as a 'big gap'. The value of the big gap depends on the pressure of the standard level in question;
as this pressure reduces (and passes thresholds defined in :code:`UICheck_BigGapsPThresh`), the value of the big gap also reduces
(according to the values in :code:`UICheck_BigGaps`),
down to a minimum value given by the value of :code:`UICheck_BigGapLowP`.

**Summary of yaml parameters**

- :code:`UICheck_TInterpIdenticalPTolSq`: threshold for squared difference between observed wind speeds for levels with identical pressures (default 0.0 m\ :sup:`2` s\ :sup:`-2`).

- :code:`UICheck_TInterpTolSq`: threshold for squared difference between observed and interpolated wind speeds (default 0.0 m\ :sup:`2` s\ :sup:`-2`).

- :code:`UICheck_BigGapsPThresh`: Maximum pressure thresholds corresponding to the big gaps as defined in :code:`UICheck_BigGaps` (default [50000.0, 10000.0, 5000.0, 1000.0] Pa).

- :code:`UICheck_BigGaps`: Big gaps corresponding to the pressure thresholds defined in :code:`UICheck_BigGapsPThresh` (default [100000.0, 50000.0, 10000.0, 5000.0] Pa).

- :code:`UICheck_BigGapLowP`: Minimum 'big gap' in pressure (default 500.0 Pa).

:ref:`Back to overview of profile consistency checks <profconcheck_overview>`

.. _profconcheck_rh:

RH check
^^^^^^^^

**Operation**

The RH check is designed to detect errors in relative humidity that may be caused by ascents through clouds. Two checks are employed:

- Transient humidity error at the cloud top,

- Persistent humidity error at high altitude (low pressure) levels after passing through a cloud.

The following conditions must be met in order for a level to fail the cloud top check:

- The level pressure must be larger than a particular value (\ :code:`RHCheck_PressThresh`),

- The pressure difference between the present level and the lowest level must be larger than a particular threshold (\ :code:`RHCheck_PressDiff0Thresh`),

- The dew point temperature difference between the present level and the level below must be larger than the threshold :code:`RHCheck_tdDiffThresh`,

- The level relative humidity must be larger than the threshold :code:`RHCheck_RHThresh`,

- The minimum relative humidity of all levels above the present level must be less than a certain threshold (\ :code:`RHCheck_MinRHThresh`).
  Only levels whose pressure is close to that of the current level (with a difference threshold of (\ :code:`RHCheck_PressDiffAdjThresh`) are considered.

The following conditions must be met in order for a level to fail the high-altitude check:

- The minimum observed temperature in the profile must be less than a particular threshold (\ :code:`RHCheck_TminThresh`),

- At least one of the following is true:

  - The difference between the observed and model background (O-B) relative humidity in the present level must be larger than a particular threshold (\ :code:`RHCheck_SondeRHHiTol`),

  - The present level has a pressure lower than :code:`RHCheck_PressInitThresh` and the mean RH O-B, computed over all levels with a pressure lower than :code:`RHCheck_PressInitThresh`,
    is larger than :code:`RHCheck_SondeRHHiTol`.

**Summary of yaml parameters**

The following parameters are used in the cloud top check:

- :code:`RHCheck_PressThresh`: Pressure threshold for check at top of cloud layers (default 500.0 Pa).

- :code:`RHCheck_PressDiff0Thresh`: Threshold for difference between pressure at the present level and pressure at the lowest level (default 50.0 Pa).

- :code:`RHCheck_tdDiffThresh`: Threshold for difference in dew point temperature between the present level and the level below (default 5.0 K).

- :code:`RHCheck_RHThresh`: Threshold for relative humidity check to be applied (default 75.0%).

- :code:`RHCheck_MinRHThresh`: Threshold for minimum relative humidity at top of cloud layers (default 75.0%).

- :code:`RHCheck_PressDiffAdjThresh`: Pressure threshold for determining cloud layer minimum RH (default 50.0 Pa).

The following parameters are used in the high-altitude check:

- :code:`RHCheck_TminThresh`: Threshold value of minimum observed temperature in the profile (default 200.0 K).

- :code:`RHCheck_TminInit`: Initial value used in the algorithm that determines the minimum observed temperature (default 400.0 K).

- :code:`RHCheck_SondeRHHiTol`: Threshold for relative humidity O-B difference in sonde ascent check (default 0.0%).

- :code:`RHCheck_PressInitThresh`: Pressure below which O-B mean is calculated (default 500.0 Pa).

- :code:`RHCheck_TempThresh`: Minimum temperature threshold for accumulating an error counter (default 250.0 K).

:ref:`Back to overview of profile consistency checks <profconcheck_overview>`

.. _profconcheck_time:

Time check
^^^^^^^^^^

**Operation**

This check flags any observations whose time of measurement lies outside the assimilation window. The time check also optionally rejects wind values whose observation pressure is within :code:`TimeCheck_SondeLaunchWindRej` of the surface pressure.

**Summary of yaml parameters**

- :code:`ModelLevels`: Governs whether the observations have been averaged onto model levels.

- :code:`TimeCheck_SondeLaunchWindRej`: Observations are rejected if they differ from the surface pressure by less than this value. Assuming an ascent rate of 5 m/s, 10 hPa corresponds to around 20 s of flight time. Using a pressure difference enables all sonde reports to be dealt with. (Default: 0.0 hPa, i.e. no rejection is performed).

:ref:`Back to overview of profile consistency checks <profconcheck_overview>`

.. _profconcheck_background:

BackgroundX checks
^^^^^^^^^^^^^^^^^^

**Operation**

The BackgroundX checks, where X is GeopotentialHeight, RelativeHumidity, Temperature or WindSpeed, use a Bayesian method to update the probability of gross error (PGE) for the relevant set of observations. Each observation must have previously been assigned a value of PGE in order for these checks to be used; this value could, for example, be taken from a stationlist. This PGE is updated with the method detailed below and is used in further filters such as the Buddy check. In addition to updating the PGE, various QC flags are set by each check.

The Bayesian background checks all operate in a similar manner. Firstly, the probability density of 'bad' observations is set. Such observations are in gross error, and are assumed to have a uniform probability of taking any climatologically reasonable value. Secondly, for some variables, the observation and background errors are increased to reflect additional sources of error which may be present. Finally the PGE calculation routine is called. Some of the modifications to the errors, and to the PGE within the Bayesian calculation, are only performed if the values in a profile have been averaged onto model levels. This is signified by the filter parameter :code:`ModelLevels` being equal to true.

The errors and PGEs are modified as follows for each variable:

- Geopotential height: the background errors and probability density of bad observations are initialised from the arrays :code:`BkCheck_zBkgErrs` and :code:`BkCheck_zBadPGEs` respectively. The value taken from each array depends on where the observed pressure lies in the array :code:`BkCheck_PlevelThresholds`.
- Relative humidity: the probability density of bad observations is set to :code:`BkCheck_PdBad_rh`. The background and observation error values are multiplied by the square root of two in order to account for long-tailed error distributions. The maximum combined observation and background error variance passed to the Bayesian PGE update is set to the value :code:`BkCheck_ErrVarMax_rh`.
- Temperature: the probability density of bad observations is set to :code:`BkCheck_PdBad_t`. The observation errors above a certain pressure threshold ('Psplit') are scaled in order to account for extra representivity error. The value of Psplit depends on whether the observation is in the tropics, defined as the region with absolute latitude less than :code:`options_.BkCheck_Psplit_latitude_tropics` degrees. If the observation is in the tropics, Psplit is set to :code:`BkCheck_Psplit_tropics`; otherwise it is :code:`BkCheck_Psplit_extratropics`. The error inflation for pressures less than or equal to Psplit is set to :code:`BkCheck_ErrorInflationBelowPsplit` and :code:`BkCheck_ErrorInflationAbovePsplit` otherwise. The observation PGE is modified if the observation was previously flagged in the UnstableLayer, Interpolation or Hydrostatic checks.
- Wind speed: the probability density of bad observations is set to :code:`BkCheck_PdBad_uv`. The observation PGE is modified if observation was previously flagged in the Interpolation check.

The PGE update then proceeds as follows. Firstly the probability of the difference between the observed and background values is calculated, assuming the difference follows a normal distribution with variance equal to the combined observation and background error variance. The wind speed components (u and v) are treated together, so a two-dimensional probability density is formed in that case. The PGE is then weighted by this calculated probability and also by the probability that the observation is bad. The updated PGE can be passed to the Buddy check if desired.

The PGE update code is located in a UFO utility function, enabling it to be used by multiple UFO filters. All of the configurable parameters used in the utility function are prefixed with :code:`PGE_` and are defined in the section below. Further details of the Bayesian update method can be found in Ingleby, N.B. and Lorenc, A.C. (1993), Bayesian quality control using multivariate normal distributions. Q.J.R. Meteorol. Soc., 119: 1195-1225. https://doi.org/10.1002/qj.49711951316

**Summary of yaml parameters**

- :code:`ModelLevels`: Governs whether the observations have been averaged onto model levels.

- :code:`BkCheck_PdBad_t`: Probability density of bad observations for T (default: 0.05).

- :code:`BkCheck_PdBad_rh`: Probability density of bad observations for RH (default: 0.05).

- :code:`BkCheck_PdBad_uv`: Probability density of bad observations for u and v (default: 0.001).

- :code:`BkCheck_Psplit_latitude_tropics`: Observations with a latitude smaller than this value (both N and S) are taken to be in the tropics (default: 30 degrees).

- :code:`BkCheck_Psplit_extratropics`: Pressure threshold above which extra representivity error occurs in extratropics (default: 50000 Pa).

- :code:`BkCheck_Psplit_tropics`: Pressure threshold above which extra representivity error occurs in tropics (default: 10000 Pa).

- :code:`BkCheck_ErrorInflationBelowPsplit`: Error inflation factor below Psplit (default value: 1.0).

- :code:`BkCheck_ErrorInflationAbovePsplit`: Error inflation factor above Psplit (default value: 1.0).

- :code:`BkCheck_ErrVarMax_rh`: Maximum combined observation and background error variance for RH (default: 500.0 per 10000).

- :code:`BkCheck_PlevelThresholds`: Pressure thresholds for setting geopotential height background errors and bad observation PGE. This vector must be the same length as :code:`BkCheck_zBkgErrs` and :code:`BkCheck_zBadPGEs` (default: [1000.0, 500.0, 100.0, 50.0, 10.0, 5.0, 1.0, 0.0] hPa).

- :code:`BkCheck_zBkgErrs`: List of geopotential height background errors that are assigned based on pressure. This vector must be the same length as :code:`BkCheck_PlevelThresholds` and :code:`BkCheck_zBadPGEs` (default: [10.0, 10.0, 10.0, 10.0, 10.0, 10.0, 10.0, 10.0] m).

- :code:`BkCheck_zBadPGEs`: List of geopotential height PGEs for bad observations that are assigned based on pressure. This vector must be the same length as :code:`BkCheck_PlevelThresholds` and :code:`BkCheck_zBkgErrs` (default: [0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01]).

- :code:`PGE_ExpArgMax`: Maximum value of exponent in background QC (default 80.0). This could be changed depending upon the machine precision.

- :code:`PGE_PGECrit`: PGE rejection limit (default 0.1). Observations with values of PGE above this threshold are flagged.

- :code:`PGE_ObErrMult`: Multiplication factor for observation errors (default 1.0).

- :code:`PGE_BkgErrMult`: Multiplication factor for background errors (default 1.0).

- :code:`PGE_SDiffCrit`: Threshold for (squared observation minus background difference) / (error variance) (default 100.0). Observations with values larger than this threshold are flagged. This is only performed if the observations have been averaged onto model levels.

:ref:`Back to overview of profile consistency checks <profconcheck_overview>`

.. _profconcheck_permrej:

PermanentReject check
^^^^^^^^^^^^^^^^^^^^^

**Operation**

This check permanently rejects observations that have previously been flagged as failing by another check.

**Summary of yaml parameters**

- :code:`ModelLevels`: Governs whether the observations have been averaged onto model levels.

:ref:`Back to overview of profile consistency checks <profconcheck_overview>`

.. _profconcheck_sondeflags:

SondeFlags check
^^^^^^^^^^^^^^^^

**Operation**

This check accounts for any QC flags that were assigned to the sonde data prior to UFO being run. These QC flags may be (e.g.) standard WMO designations.

**Summary of yaml parameters**

There are no configurable parameters for this check.

:ref:`Back to overview of profile consistency checks <profconcheck_overview>`

.. _profconcheck_winproflags:

WindProfilerFlags check
^^^^^^^^^^^^^^^^^^^^^^^

**Operation**

This check accounts for any QC flags that were assigned to the wind profiler data prior to UFO being run.

**Summary of yaml parameters**

There are no configurable parameters for this check.

:ref:`Back to overview of profile consistency checks <profconcheck_overview>`

.. _profconcheck_pressure:

Pressure calculation
^^^^^^^^^^^^^^^^^^^^

**Operation**

This routine calculates profile pressures if they are have not been measured (or were measured but are potentially inaccurate). Firstly the model heights are computed from the orography and the terrain-following height coordinate. The model heights are used together with the observation heights and model pressures to interpolate (or extrapolate) values of the observed pressures.

**Summary of yaml parameters**

The default values of these parameters are suitable for the UM.

- :code:`zModelTop`: Height of the upper boundary of the highest model layer.

- :code:`firstConstantRhoLevel`: First model rho level at which there is no geographical variation in the height.

- :code:`etaTheta`: Values of terrain-following height coordinate (eta) on theta levels.

- :code:`etaRho`: Value of terrain-following height coordinate (eta) on rho levels.

:ref:`Back to overview of profile consistency checks <profconcheck_overview>`

.. _profconcheck_example:

Examples
^^^^^^^^

This example runs the basic checks on the input data:

.. code-block:: yaml

    - filter: Profile Consistency Checks
      filter variables:
      - name: air_temperature
      - name: geopotential_height
      Checks: ["Basic"]

This example runs the basic and SamePDiffT checks on the input data, using separate instances of the filter to do so:

.. code-block:: yaml

    - filter: Profile Consistency Checks
      filter variables:
      - name: air_temperature
      - name: geopotential_height
      Checks: ["Basic"]
    - filter: Profile Consistency Checks
      filter variables:
      - name: air_temperature
      - name: geopotential_height
      Checks: ["SamePDiffT"]
      SPDTCheck_TThresh: 30.0 # This is an example modification of a check parameter

This example runs the basic and SamePDiffT checks on the input data, using the same filter instance:

.. code-block:: yaml

    - filter: Profile Consistency Checks
      filter variables:
      - name: air_temperature
      - name: geopotential_height
      Checks: ["Basic", "SamePDiffT"]
      SPDTCheck_TThresh: 30.0 # This is an example modification of a check parameter

