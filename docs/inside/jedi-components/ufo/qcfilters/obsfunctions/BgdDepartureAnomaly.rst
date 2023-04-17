.. _BgdDepartureAnomaly:

BgdDepartureAnomaly
--------------------------------------------------------------------------------------

This ObsFunction calculates the background departure anomaly difference between
two channels, such as:

.. math::
  \text{Anomaly(i) = (O(i)-B(i) - MEAN(O-B))_ch1 - (O(i)-B(i) - MEAN(O-B))_ch2}

With i the ith location under consideration, O the Tb from observation, B the Tb from the background,
and MEAN(O-B) the mean departure over all valid observations on all processors. 
 
Because hydrometeors are known to scatter radiation more efficiently with increasing microwave frequency, 
the anomaly tends to be positive at 36.5 GHz and negative at 89 GHz. The difference between these anomalies,
largest in the H-polarised channels, is typically used to diagnose cloudy scenes. 

Required parameters:
~~~~~~~~~~~~~~~~~~~~

channel_low_freq
  Lower frequency channel number
  Example: AMSR2 channel 11 corresponding to 36.5 GHz H-pol


channel_high_freq
  Higher frequency channel number 
  Example: AMSR2 channel 13 corresponding to 89 GHz H-pol

Optional parameters:
~~~~~~~~~~~~~~~~~~~~

ObsBias
  Name of the bias correction group used to apply correction to ObsValue.
  Default (missing optional parameter) applies no bias 

testHofX
  Name of the HofX group used to replace the default group (default is HofX) 

Example yaml:
~~~~~~~~~~~~~

Here is an example using this ObsFunction inside the Bounds Check filter for
AMSR-2. The brightnessTemperature filter variables are rejected if the output
value of this ObsFunction is larger than the example maxvalue = 5.

.. code-block:: yaml

  - filter: Bounds Check
    test variables:
    - name: ObsFunction/BgdDepartureAnomaly
      options:
        channel_low_freq: 11
        channel_high_freq: 13
        ObsBias: ObsBias
    maxvalue: 5
    action:
      name: reject

