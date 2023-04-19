.. _CLWRetMW:

CLWRetMW
--------------------------------------------------------

Retrieve cloud liquid water using 23.8 GHz and 31.4 GHz channels from AMSU-like instruments.
Follows the Grody et al., 2001 screening method, see publication or source code for specific implementation

References:
^^^^^^^^^^^^^^^^^^^^^^^^^

Grody et al. (2001), Determination of precipitable water and cloud liquid water over oceans from the NOAA 15 advanced microwave sounding unit, Journal of Geophysical Research (Vol. 106, No. D3, Pages 2943-2953).


Required yaml parameters:
^^^^^^^^^^^^^^^^^^^^^^^^^

:code:`clwret_types`
  Names of the data group used to retrieve the cloud liquid water. Values could be [ObsValue], [HofX] or [ObsValue, HofX].

  
Optional yaml parameters:
^^^^^^^^^^^^^^^^^^^^^^^^^

:code:`clwret_ch238`
  Channel number corresponding to 23.8 GHz channel .

:code:`clwret_ch314`
  Channel number corresponding to 31.4 GHz channel.

:code:`bias_application`
  Name of the data group to which the bias correction is applied. Could be ObsValue or HofX (default is HofX).

:code:`test_bias`
  Name of the bias correction group used to replace the default group (default is ObsBiasData). Could be a group name from the input file. This option is usually used for testing/validation purposes.

The following parameters are intended for cloud index for some sensors, e.g., GMI.

:code:`clwret_ch37h`
  Channel number corresponding to 37H channel. 

:code:`clwret_ch37v`
  Channel number corresponding to 37V channel. 

The following parameters are intended for cloud index for some sensors, e.g., MHS

:code:`clwret_ch89h`
  Channel number corresponding to 89H channel. 

:code:`clwret_ch166v`
  Channel number corresponding to 166V channel. 

The following parameters are intended for cloud index for some sensors, e.g., AMSR2

:code:`clwret_ch18h`
  Channel number corresponding to 18H channel.

:code:`clwret_ch18v`
  Channel number corresponding to 18V channel .

:code:`clwret_ch36h`
  Channel number corresponding to 36H channel . 

:code:`clwret_ch36v`
  Channel number corresponding to 36V channel. 

Example configuration:
~~~~~~~~~~~~~~~~~~~~~~~~

AMSU-A Example (amsua_qc_clwretmw.yaml):
  
.. code-block:: yaml

  - filter: Bounds Check
    filter variables:
    - name: brightnessTemperature
      channels: 1-6, 15
    test variables:
    - name: ObsFunction/CLWRetMW
      options:
        clwret_ch238: 1
        clwret_ch314: 2
        clwret_types: [ObsValue]
        test_group: GsiObsBias
    maxvalue: 999.0
    action:
      name: reject

