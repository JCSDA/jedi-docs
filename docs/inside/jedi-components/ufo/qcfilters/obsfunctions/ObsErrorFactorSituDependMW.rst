.. _ObsErrorFactorSituDependMW:

ObsErrorFactorSituDependMW
-------------------------------------------------------------------------------

This obsFunction is designed to compute situation-dependent error inflation factors based on
retrieved cloud liquid water from background, observations, scattering index,
surface wind speed, and cloud information match index over the ocean.
Currently, this obsFunction is limited to certain channels of amsua or atms:
For amsua, only channels 1-5 and 15 will be applied;
For atms, only channels 1-6 and channel 16 and beyond will be applied. 

Required input parameters:
~~~~~~~~~~~~~~~~~~~~~~~~~~

channels
  List of channels to which the obsFunction is applied

sensor 
  Name of the sensor for which the observation error factor applies.
  Format: instrumentName_platformName, e.g. amsua_n19

obserr_clearsky
  Observation error for each channel under the clear-sky condition

clwobs_function
  Function to retrieve the cloud liquid water from the observation

clwbkg_function
  Function to retrieve the cloud liquid water from the simulated observation

scatobs_function
  Function to retrieve the scattering index from the observation

clwmatchidx_function
  Function to get the cloud match index based on cloud amount retrieved from
  background and observation

Optional input parameters:
~~~~~~~~~~~~~~~~~~~~~~~~~~

test_obserr
  Name of the data group to which the observation error is applied (default is ObsErrorData) 
 
test_hofx
  Name of the HofX group used to replace the default group (default is HofX)

test_qcflag
  Name of the data group to which the QC flag is applied  (default is QCflagsData)

Required fields from obs/geoval 
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
geovals
  :code:`water_area_fraction@GeoVaLs` , 
  :code:`surface_wind_speed@GeoVaLs` 

observation space:
  :code:`brightness_temperature@ObsValue`.
  In addition, brightness_temperature observation error, QC flags, and simulated
  values at the observatioin locations will come from JEDI default values or 
  or from the input defined by :code:`test_obserr`, :code:`test_qcflag` and :code:`test_hofx` 

Example configurations:
~~~~~~~~~~~~~~~~~~~~~~~

Here is an example to use this obsFunction inside a filter for :code:`action: name: inflate error`.
The brightness_temperature observation error for amsua_n19 is inflated. Note: All channels
are prescribed in the yaml (:code:`channels: &all_channels 1-15`). However, only amsua channels 
1-5 and 15 will be inflated as a result  f this obsFunction. For each additional obsFunctions used
in this yaml, please refer to their specific documentations, respectively.

.. code-block:: yaml

  - filter: Perform Action
    filter variables:
    - name: brightness_temperature
      channels: &all_channels 1-15
    action:
      name: inflate error
      inflation variable:
        name: ObsErrorFactorSituDependMW@ObsFunction
        channels: *all_channels
        options:
          sensor: amsua_n19
          channels: *all_channels
          clwobs_function:
            name: CLWRetMW@ObsFunction
            options:
              clwret_ch238: 1
              clwret_ch314: 2
              clwret_types: [ObsValue]
          clwbkg_function:
            name: CLWRetMW@ObsFunction
            options:
              clwret_ch238: 1
              clwret_ch314: 2
              clwret_types: [HofX]
              bias_application: HofX
          scatobs_function:
            name: SCATRetMW@ObsFunction
            options:
              scatret_ch238: 1
              scatret_ch314: 2
              scatret_ch890: 15
              scatret_types: [ObsValue]
              bias_application: HofX
          clwmatchidx_function:
            name: CLWMatchIndexMW@ObsFunction
            channels: *all_channels
            options:
              channels: *all_channels
              clwobs_function:
                name: CLWRetMW@ObsFunction
                options:
                  clwret_ch238: 1
                  clwret_ch314: 2
                  clwret_types: [ObsValue]
              clwbkg_function:
                name: CLWRetMW@ObsFunction
                options:
                  clwret_ch238: 1
                  clwret_ch314: 2
                  clwret_types: [HofX]
                  bias_application: HofX
              clwret_clearsky: [0.050, 0.030, 0.030, 0.020, 0.000,
                                0.100, 0.000, 0.000, 0.000, 0.000,
                                0.000, 0.000, 0.000, 0.000, 0.030]
          obserr_clearsky: [2.500, 2.200, 2.000, 0.550, 0.300,
                            0.230, 0.230, 0.250, 0.250, 0.350,
                            0.400, 0.550, 0.800, 3.000, 3.500]

