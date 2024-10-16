ObsFunctions in UFO
===================

Observation Functions are more advanced filtering routines that are encapsulated together in
a unit. They usually combine several complicated logic operations, and decomposing these
filters into separate parts would have an obfuscating effect.

:ref:`AssignValueEqualChannels <AssignValueEqualChannels>`
  Assign values to a variable, depending on a value of another (channel-by-channel)

:ref:`BennartzScatIndex <BennartzScatIndex>`
  Compute Bennartz scattering index from microwave channels

:ref:`BgdDepartureAnomaly <BgdDepartureAnomaly>`
  Compute the background departure anomaly between two channels

:ref:`ChannelUseflagCheckRad <ChannelUseflagCheckRad>`
  Channel usage flag check for radiances

:ref:`CloudCostFunction <CloudCostFunction>`
  Bayesian cost function for detecting cloud-affected radiances

:ref:`CloudDetectMinResidualAVHRR <CloudDetectMinResidualAVHRR>`
  Cloud detection using Minimum Residual Method for AVHRR

:ref:`CloudDetectMinResidualIR <CloudDetectMinResidualIR>`
  Cloud detection using Minimum Residual Method for IR Sensors

:ref:`CloudFirstGuessMinimumResidual <CloudFirstGuessMinimumResidual>`
  Cloud top pressure and effective cloud amount from satellite BTs.

:ref:`CLWMatchIndexMW <CLWMatchIndexMW>`
  Cloud liquid water match index for microwave radiances

:ref:`CLWRetMW <CLWRetMW>`
  Retrieve cloud liquid water using MW channels (non-SSMIS version)

:ref:`CLWRetMW_SSMIS <CLWRetMW_SSMIS>`
  Cloud liquid water for SSMIS

:ref:`CLWRetSymmetricMW <CLWRetSymmetricMW>`
  Estimates the actual Cloud Liquid Water (CLW) content from both model background and observed content

:ref:`Conditional <Conditional>`
  Create an array of ints, floats, strings or date times using a series of where clauses.

:ref:`DateTimeOffset <DateTimeOffset>`
  Add an offset variable, with units of seconds, minutes or hours, to the :code:`MetaData/dateTime` variable.

:ref:`DrawObsErrorFromFile <DrawObsErrorFromFile>`
    Derive observation error values by interpolating an array loaded from a file, representing the variance or covariance matrix (of which only the diagonal elements are taken into account), indexed by coordinates whose names correspond to ObsSpace variables.  This file can potentially contain a collection ("stack") of such matrices.

:ref:`DrawValueFromFile <DrawValueFromFile>`
    Derive values by interpolating an array loaded from a file, indexed by coordinates whose names correspond to ObsSpace variables

:ref:`FillAveragedProfileData <FillAveragedProfileData>`
   Copy values from an observed atmospheric profile to the same profile averaged onto model levels.

:ref:`HydrometeorCheckAMSUA <HydrometeorCheckAMSUA>`
  AMSU-A cloud and precipitation checks

:ref:`HydrometeorCheckATMS <HydrometeorCheckATMS>`
  ATMS cloud and precipitation checks

:ref:`InterChannelConsistencyCheck <InterChannelConsistencyCheck>`
  Inter-channel consistency check for radiances

:ref:`MetOfficeRelativeHumidityCorrection <MetOfficeRelativeHumidityCorrection>`
  Produce correction to Met Office relative humidity H(x).

:ref:`NearSSTRetCheckIR <NearSSTRetCheckIR>`
  NCEP-GDAP near-sea-surface temperature IR retrieval

:ref:`ObsErrorBoundIR <ObsErrorBoundIR>`
  Observation error bound for gross check

:ref:`ObsErrorBoundMW <ObsErrorBoundMW>`
  Obseration error bounds for microwave radiances

:ref:`ObsErrorFactorConventional <ObsErrorFactorConventional>`
  Compute observation error inflation factor for conventional observations based on vertical spacing

:ref:`ObsErrorFactorLatRad <ObsErrorFactorLatRad>`
  Observation error bound reduction within tropics

:ref:`ObsErrorFactorQuotient <ObsErrorFactorQuotient>`
  Reject observations based on comparing final observation error to initial error estimate

:ref:`ObsErrorFactorSfcPressure <ObsErrorFactorSfcPressure>`
  Inflate observation error for surface pressure (as in GSI)

:ref:`ObsErrorFactorSituDependMW <ObsErrorFactorSituDependMW>`
  Compute error inflation factors for AMSU-A and ATMS

:ref:`ObsErrorFactorSurfJacobianRad <ObsErrorFactorSurfJacobianRad>`
  Inflate error using surface temperature and emissivity Jacobians

:ref:`ObsErrorFactorTopoRad <ObsErrorFactorTopoRad>`
  GSI error inflation as a function of terrain height, channel, and transmittance

:ref:`ObsErrorFactorTransmitTopRad <ObsErrorFactorTransmitTopRad>`
  Satellite radiance observation error inflation factor

:ref:`ObsErrorFactorWavenumIR <ObsErrorFactorWavenumIR>`
  Observation error inflation for satellite infrared sensors

:ref:`ObsErrorModelHumidity <ObsErrorModelHumidity>`
  Variant of ObsErrorModelStepwiseLinear for humidity observation error assignment

:ref:`ObsErrorModelRamp <ObsErrorModelRamp>`
  Parameterize observation error as a piecewise linear function

:ref:`ObsErrorModelStepwiseLinear <ObsErrorModelStepwiseLinear>`
  GSI variant of ObsErrorModelRamp

:ref:`ObsFunctionExponential <ObsFunctionExponential>`
  Compute exponential function of a variable

:ref:`ObsFunctionLinearCombination <ObsFunctionLinearCombination>`
  Compute linear combination of given variables weighted by given coefficients.

:ref:`ObsFunctionSelectStatistic <ObsFunctionSelectStatistic>`
  Output all 0's, except for 1 in locations corresponding (or closest) to the minimum, maximum, median or mean of the input variable within each record.
  
:ref:`ObsFunctionStringManipulation <ObsFunctionStringManipulation>`
  Perform an operation on a string to change its format i.e slice. 

:ref:`ObsFunctionVelocity <ObsFunctionVelocity>`
  Compute wind speed from u- and v- components

:ref:`OceanPressureToDepth <OceanPressureToDepth>`
  Convert an ocean pressure variable (Pa) to depth below surface (m)

:ref:`ProfileAverageObsPressure <ProfileAverageObsPressure>`
  Fill values of pressure in profiles that have been averaged onto model levels.

:ref:`ProfileLevelCount <ProfileLevelCount>`
  Count the number of locations in each profile that satisfy a particular condition.

:ref:`RecordNumberToObsSpace <RecordNumberToObsSpace>`
  For an input data set that has been grouped into records, enable the internal unique record number to be saved to the ObsSpace.

:ref:`RONBAMErrInflate <RONBAMErrInflate>`
  Observation error inflation factor for GnssroBndNBAM

:ref:`SatwindIndivErrors <SatwindIndivErrors>`
  Compute individual u- or v- component observation errors for Satwinds

:ref:`SatWindsLNVDCheck <SatWindsLNVDCheck>`
  log-normal vector difference (LNVD) between observed and model winds

:ref:`SatWindsSPDBCheck <SatWindsSPDBCheck>`
  Wind gross error check

:ref:`SCATRetMW <SCATRetMW>`
  Retrieve Grody et al. scattering index from bias-adjusted channels over water surfaces

:ref:`SetSurfaceType <SetSurfaceType>`
  Determine and output surface type for use with observation operator
  
:ref:`SetSeaIceEmiss <SetSeaIceEmiss>`
  Calculate MW emissivity for surfaces classified as Ice by AAPP.

:ref:`TropopauseEstimate <TropopauseEstimate>`
  First-guess extimate of tropopause pressure from climatology

:ref:`WindDirAngleDiff <WindDirAngleDiff>`
  Compute wind direction angle different between observation and model

.. toctree::
   :hidden:

   AssignValueEqualChannels
   BennartzScatIndex
   BgdDepartureAnomaly
   ChannelUseflagCheckRad
   CloudCostFunction
   CloudDetectMinResidualAVHRR
   CloudDetectMinResidualIR
   CloudFirstGuessMinimumResidual
   CLWMatchIndexMW
   CLWRetMW
   CLWRetMW_SSMIS
   CLWRetSymmetricMW
   Conditional
   DateTimeOffset
   DrawObsErrorFromFile
   DrawValueFromFile
   FillAveragedProfileData
   HydrometeorCheckAMSUA
   HydrometeorCheckATMS
   InterChannelConsistencyCheck
   MetOfficeRelativeHumidityCorrection
   NearSSTRetCheckIR
   ObsErrorBoundIR
   ObsErrorBoundMW
   ObsErrorFactorConventional
   ObsErrorFactorLatRad
   ObsErrorFactorQuotient
   ObsErrorFactorSfcPressure
   ObsErrorFactorSituDependMW
   ObsErrorFactorSurfJacobianRad
   ObsErrorFactorTopoRad
   ObsErrorFactorTransmitTopRad
   ObsErrorFactorWavenumIR
   ObsErrorModelHumidity
   ObsErrorModelRamp
   ObsErrorModelStepwiseLinear
   ObsFunctionExponential
   ObsFunctionLinearCombination
   ObsFunctionSelectStatistic
   ObsFunctionStringManipulation
   ObsFunctionVelocity
   OceanPressureToDepth
   ProfileAverageObsPressure
   ProfileLevelCount
   RecordNumberToObsSpace
   ROobserrInflation
   SatwindIndivErrors
   SatWindsLNVDCheck
   SatWindsSPDBCheck
   SCATRetMW
   SetSurfaceType
   SetSeaIceEmiss
   TropopauseEstimate
   WindDirAngleDiff
