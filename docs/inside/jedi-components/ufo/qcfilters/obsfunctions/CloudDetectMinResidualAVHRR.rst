.. _CloudDetectMinResidualAVHRR:

CloudDetectMinResidualAVHRR
---------------------------------------

Cloud Detection Algorithm (Minimum Residual Method) for Infrared sensors (specifically AVHRR in this case) using selected channels from 15 microns CO2 absorption band.

Output of this function:

  0 = channel is not affected by clouds (clear channel)

  1 = channel is affected by clouds (cloudy channel)

  2 = channel is not affected by clouds but too sensitive to surface condition


Required YAML Parameters
^^^^^^^^^^^^^^^^^^^^^^^^^

channels
  List of channels available for assimilation.

use_flag
  Useflag (-1: not used; 0: monitoring; 1: used) for each channel in `channels`.

use_flag_clddet
  Useflag (-1: not used; 1: used) indicating if the channel is used for cloud detection.

obserr_dtempf
  Observation error scale factors applied to surface temperature jacobians over 5 surface types: [sea, land, ice, snow and mixed].

Optional YAML Parameters
^^^^^^^^^^^^^^^^^^^^^^^^^

test_obserr
  Name of the data group to which the observation error is applied (default: `ObsErrorData`).

test_hofx
  Name of the HofX group used to replace the default group (default is `HofX`).

test_bias
  Name of the bias correction group used to replace the default group (default is `ObsBias`).

test_qcflag
  Name of the data group to which the QC flag is applied  (default is `QCflagsData`).


Example configuration
~~~~~~~~~~~~~~~~~~~~~

AVHRR3 Metop-A Example (from avhrr3_metop-a.yaml)

.. code-block:: yaml

  - filter: Bounds Check
    filter variables:
    - name: brightnessTemperature
      channels: *avhrr3_metop-a_channels
    test variables:
    - name: ObsFunction/CloudDetectMinResidualAVHRR
      channels: *avhrr3_metop-a_channels
      options:
        channels: *avhrr3_metop-a_channels
        use_flag: [ 1,  1,  1 ]
        use_flag_clddet: [ 1,  1,  1 ]
        obserr_dtempf: [0.50,2.00,4.00,2.00,4.00]
    maxvalue: 1.0e-12
    action:
      name: reject

