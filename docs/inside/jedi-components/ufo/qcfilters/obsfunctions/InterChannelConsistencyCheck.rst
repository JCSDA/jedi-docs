.. _InterChannelConsistencyCheck:

InterChannelConsistencyCheck
----------------------------------------------------------------------------

The Inter-channel consistency check is another feature of interest when assimilating radiances. This check is performed through the :code:`InterChannelConsistencyCheck` function. Currently, this function is implemented for AMSU-A and ATMS platforms, and performs a check over a group of channels depending on the instrument. For AMSU-A, it considers the channels 1-6 and 15, while for ATMS the channels 1-7 and 16-18. The function internally converts effective observation error to inverse of the error variance and checks if one of the channels is being rejected, if so, all channels in the group are rejected for a given location.

Required input parameters:
~~~~~~~~~~~~~~~~~~~~~~~~~~

channels
  List of channels available for assimilation.

sensor
  Name of the sensor for which the observation error factor applies.

use_flag
  Useflag (-1: not used; 0: monitoring; 1: used) for each channel in channels.

Optional Input parameters:
~~~~~~~~~~~~~~~~~~~~~~~~~~

test_obserr
  Name of the data group to which the observation error is applied (default: ObsErrorData).

test_qcflag
  Name of the data group to which the QC flag is applied (default: QCflagsData).

Example configuration:
~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: yaml

    - filter: Bounds Check
      filter variables:
      - name: brightness_temperature
        channels: 1-15
      test variables:
      - name: InterChannelConsistencyCheck@ObsFunction
        channels: 1-15
        options:
          channels: 1-15
          sensor: amsua_n19
          use_flag: [ 1,  1,  1,  1,  1,
                      1, -1, -1,  1,  1,
                      1,  1,  1, -1,  1 ]
      maxvalue: 1.0e-12
      action:
        name: reject

The above example is for AMSU-A N19 (:code:`amsua_n19`), and the filter checks if any of the brightness temperature for channels 1-6 and 15 are being rejected, if so, all the channels 1-6 and 15 are rejected for a given location.
