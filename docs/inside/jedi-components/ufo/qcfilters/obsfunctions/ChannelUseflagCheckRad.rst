.. _ChannelUseflagCheckRad:

ChannelUseflagCheckRad
--------------------------------------------------------------

An important feature of interest when assimilating radiances is the selection of the channels to be assimilated. This can be performed through the usage of the :code:`ChannelUseflagCheckRad` function. This function rejects observations whose values are set to less than one.

Required input parameters:
~~~~~~~~~~~~~~~~~~~~~~~~~~

channels
  List of channels available for assimilation.

use_flag
  Useflag (-1: not used; 0: monitoring; 1: used) for each channel in channelList.

Example configuration:
~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: yaml

   - filter: Bounds Check
     filter variables:
     - name: brightnessTemperature
       channels: 4-6
     test variables:
     - name: ObsFunction/ChannelUseflagCheckRad
       channels: 4-6
       options:
         channels: 4-6
         use_flag: [ 1, -1,  1 ]
     minvalue: 1.0e-12
     action:
       name: reject

In the above example the filter checks if brightness temperature for channels 4, 5 and 6 are expected to be used. Suppose we have the following observation data with 3 locations and 4 channels:

* channel 3: [100, 250, 450]
* channel 4: [250, 260, 270]
* channel 5: [200, 250, 270]
* channel 6: [340, 200, 250]

In this example, all observations from channel 3 will pass QC because the filter isn't configured to act on this channel. All observations for channels 4 and 6 will pass QC because these channels are set to 1, while all observations for channel 5 will be rejected because that channel is set to -1.

