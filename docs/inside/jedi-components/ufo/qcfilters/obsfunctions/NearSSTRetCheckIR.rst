.. _NearSSTRetCheckIR:

NearSSTRetCheckIR
----------------------------------------------------------------------

This obsFunction is designed to perform QC using retrieved near-sea-surface 
temperature (NSST) from Infrared radiances.
This QC includes two steps:
(1) Perform NSST retrieval from radiances at obs location following NCEP GDAS
scheme, and obtained increment of NSST from its first guess value;  
(2) For surface sensitive channels, remove them from assimilation if the
retrieved NSST increment from step (1) is larger than a pre-defined
threshold.
The output of this obsFunction is the default JEDI QC flags: 0 = channel 
is retained for assimilation; 1 = channel is not retained for assimilation.

Required input parameters:
~~~~~~~~~~~~~~~~~~~~~~~~~~

channels
  List of channel to which the QC is performed

use_flag
  Use flag (-1: not used; 0: monitoring; 1: used) for each channel in channel list

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
  :code:`GeoVaLs/water_area_fraction` , :code:`GeoVaLs/surface_temperature_where_sea`

obsDiag
  :code:`ObsDiag/brightness_temperature_jacobian_surface_temperature` , 
  :code:`ObsDiag/brightness_temperature_jacobian_air_temperature`,
  :code:`ObsDiag/brightness_temperature_jacobian_humidity_mixing_ratio`

from observation space:
  :code:`ObsValue/brightnessTemperature`, :code:`ObsError/brightnessTemperature`,
  :code:`MetaData/sensorCentralFrequency`. 
  In addition, brightness_temperature observation error, QC flags, and simulated
  values at the observatioin locations will come from JEDI default values or 
  or from the input defined by :code:`test_obserr`, :code:`test_qcflag` and :code:`test_hofx` 

Example configurations:
~~~~~~~~~~~~~~~~~~~~~~~

Here is an example to use this obsFunction inside the Bounds Check filter.
The brightness_temperature is rejected if the QC flags from 
this ObsFunction output value is bigger than maxvalue=1.0e-12. 

.. code-block:: yaml

  - filter: Bounds Check
    filter variables:
    - name: brightnessTemperature
      channels: *all_channels
    test variables:
    - name: ObsFunction/NearSSTRetCheckIR
      channels: *all_channels
      options:
        channels: *all_channels
        test_bias: GsiObsBias
        use_flag: [ -1,  1,  1, -1,  1, -1,  1, -1,  1,  1,
                     1,  1,  1,  1, -1,  1, -1,  1, -1,  1,
                    -1,  1, -1,  1, -1,  1, -1,  1, -1,  1,
                    -1,  1, -1,  1, -1,  1, -1,  1, -1,  1 ]
    maxvalue: 1.0e-12
    action:
      name: reject


