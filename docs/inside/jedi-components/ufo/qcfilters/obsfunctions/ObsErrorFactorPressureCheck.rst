.. _ObsErrorFactorPressureCheck:

ObsErrorFactorPressureCheck
---------------------------

This obsFunction mimics the NCEP GSI observer codes (i.e., setupt.f90, setupw.f90, and setupq.f90) and is used for conventional observations of temperature, moisture, and winds. This Obsfunction checks an observation's vertical relative position with respect to a model's vertical coordinate of pressure or geometric height levels. If the reported pressure/geometric height is not between the model's surface pressure/geometric height and the model top, the obs error is inflated as in the following:

  ratio_errors = (error + drpx + 1.e6*rhgh + (inflation factor)*rlow) / error

where, rlow=max(sfcchk-dpres,zero) with sfcchk being the grid relative position of model surface pressure/geometric height and dpres the grid relative position of the observation's reported pressure/geometric height. rhgh=max(dpres-0.001-nlevs-1, zero) and value of drpx is situation dependent. For example, drpx is zero if the observation is reported with the pressure levels (e.g. satwind, radiosonde, etc). If the observation is reported with the geometric height levels (e.g. Ascat), drpx is given a non-zero value depending on the grid relative position of station's geometric height with respect to the model surface geometric height. The inflation factor is a required parameter which is given 4.0 for wind type and 8.0 for both temperatue and humidity. For specific humidity observations, the obs error is transfered from relative humidity to specific humidity.

Note: Surface wind obs are not reported with observation height (ZOB) in bufr/ioda, but there is MetaData/stationElevation. The SetSfcWndObsHeight parameter can be specified along with a user defined zob value (AssumedSfcWndObsHeight).

Typically, obs_height = dstn + AssumedSfcWndObsHeight
where AssumedSfcWndObsHeight = 10 m and dstn is sationElevation, but there are exceptions. Therefore, there are additional options that can be used to change how the obs_height value is calculated as follows.

 1) Default (no flags set):
    obs_height = AssumedSfcWndObsHeight

 2) AddObsHeightToStationElevation: true
    obs_height = dstn + AssumedSfcWndObsHeight

 3) UseStationElevationAsObsHeight: true
    obs_height = dstn

Required input parameter:
~~~~~~~~~~~~~~~~~~~~~~~~~

variables
  Variable names to be inflated.

inflation factor
  4.0 or 8.0

Optional input parameters:
~~~~~~~~~~~~~~~~~~~~~~~~~~

request_saturation_specific_humidity_geovals (Default: false)
  With the default (false), the variable of saturated specifical humidity is calculated from model air temperature of Geovals within this ObsFunction. When the parameter is set to true, this variable is obtained directly from Geovals via VADER (for FV3-JEDI only). In both cases, the same Rogers formula is used in calculation of the variable, and the results are identical. Since geovals variables are used in the function, it works as a post filter.

SetSfcWndObsHeight (Default false)

AddObsHeightToStationElevation (Default false)

UseStationElevationAsObsHeight (Default false)

AssumedSfcWndObsHeight (Default false)

Example configurations:
~~~~~~~~~~~~~~~~~~~~~~~

Here are two examples to use this obsFunction for observation errors of winds and specific humidity:

.. code-block:: yaml

  - filter: Perform Action
    filter variables:
    - name: windEastward
    where:
    - variable:
        name: ObsType/windEastward
      is_in: 220-221
    action:
      name: inflate error
      inflation variable:
        name: ObsFunction/ObsErrorFactorPressureCheck
        options:
          variable: windEastward
          inflation factor: 4.0
          SetSfcWndObsHeight: true
          AddObsHeightToStationElevation: true
          AssumedSfcWndObsHeight: 10

.. code-block:: yaml

  - filter: Perform Action
    filter variables:
    - name: specificHumidity
    where:
    - variable: ObsType/specificHumidity
      is_in: 188
    action:
      name: inflate error
      inflation variable:
        name: ObsFunction/ObsErrorFactorPressureCheck
        options:
          variable: specificHumidity
          inflation factor: 8.0

