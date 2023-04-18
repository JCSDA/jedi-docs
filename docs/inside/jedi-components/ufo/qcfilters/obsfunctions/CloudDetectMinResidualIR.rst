.. _CloudDetectMinResidualIR:

CloudDetectMinResidualIR
--------------------------------------------------------------------------------------

This obsFunction is designed to perform 
cloud detection using the Minimum Residual Method for Infrared sensors
using selected channels from 15 microns CO2 absorption band.

The output of this function is:

0 = channel is not affected by clouds (clear channel)

1 = channel is affected by clouds (cloudy channel)

2 = channel is not affected by clouds but too sensitive to surface condition

Required input parameters:
~~~~~~~~~~~~~~~~~~~~~~~~~~

channels
  List of channel to which the cloud detection is performed

use_flag
  Use flag (-1: not used; 0: monitoring; 1: used) for each channel in channel list

use_flag_clddet
  Useflag (-1: not used; 1: used) indicating if the channel is used for cloud detection

obserr_dtempf
  Observation error scale factors applied to surface temperature jacobians
  over 5 surface types: [sea, land, ice, snow and mixed]

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
  :code:`GeoVaLs/water_area_fraction` , :code:`GeoVaLs/ice_area_fraction`,
  :code:`GeoVaLs/land_area_fraction` , :code:`GeoVaLs/surface_snow_area_fraction`
  :code:`GeoVaLs/average_surface_temperature_within_field_of_view` , :code:`GeoVaLs/air_pressure`
  :code:`GeoVaLs/air_temperature` , :code:`GeoVaLs/tropopause_pressure`

obsDiag
  :code:`ObsDiag/brightness_temperature_jacobian_surface_temperature` , 
  :code:`ObsDiag/brightness_temperature_jacobian_air_temperature`,
  :code:`ObsDiag/transmittances_of_atmosphere_layer`,
  :code:`ObsDiag/pressure_level_at_peak_of_weightingfunction`

from observation space:
  :code:`ObsValue/brightnessTemperature`, :code:`ObsError/brightnessTemperature`.
  In addition, brightnessTemperature observation error, QC flags, and simulated
  values at the observatioin locations will come from JEDI default values or 
  or from the input defined by :code:`test_obserr`, :code:`test_qcflag` and :code:`test_hofx` 

Example configurations:
~~~~~~~~~~~~~~~~~~~~~~~

Here is an example to use this obsFunction inside the Bounds Check filter.
The brightnessTemperature is rejected if the QC flags from 
this ObsFunction output value is bigger than maxvalue=1.0e-12. 

.. code-block:: yaml

  - filter: Bounds Check
    filter variables:
    - name: brightnessTemperature
      channels: *all_channels
    test variables:
    - name: ObsFunction/CloudDetectMinResidualIR
      channels: *all_channels
      options:
        channels: *all_channels
        use_flag: [ -1, -1,  1, -1, -1,  1, -1, -1,  1,  1,
                     1, -1,  1,  1, -1, -1, -1,  1, -1, -1,
                     1, -1, -1, -1, -1, -1, -1, -1,  1, -1,
                     1, -1, -1, -1, -1, -1, -1, -1, -1, -1 ]
        use_flag_clddet: [ -1, -1,  1, -1, -1,  1, -1, -1,  1,  1,
                            1, -1,  1,  1, -1, -1, -1,  1, -1, -1,
                            1, -1, -1, -1, -1, -1, -1, -1,  1, -1,
                            1, -1, -1, -1, -1, -1, -1, -1, -1, -1 ]
        obserr_dtempf: [0.50, 2.00, 4.00, 2.00, 4.00]
    maxvalue: 1.0e-12
    action:
      name: reject





