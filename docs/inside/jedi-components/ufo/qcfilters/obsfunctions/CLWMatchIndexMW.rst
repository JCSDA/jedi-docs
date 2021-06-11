.. _CLWMatchIndexMW:

CLWMatchIndexMW
-----------------------------------------------------------------------

The cloud match index for microwave sensors based on retrieved cloud liquid water is obtained through the :code:`CLWMatchIndexMW` function. This function obtains cloud liquid water retrieved from observation and simulated observation from background through the usage of specific functions that depends on the instrument. Once the cloud liquid water is available, this function assumes there is no cloud on both (observation and simulated observation from background) and starts to verify two conditions over water surfaces. The first condition considers the squared differences between cloud liquid water from observation and the symmetric cloud amount threshold for a given channel, and the cloud liquid water simulated observation from background and the former, following:

.. math::
  \text{Condition 1: } ( CLW_{obs} - CLW_{clr} ) * ( CLW_{bkg} - CLW_{clr} ) < 0

where :math:`CLW_{obs}` and :math:`CLW_{bkg}` represents the cloud liquid water obtained from observation and simulated observation from background, respectively, and :math:`CLW_{clr}` the symmetric cloud amount threshold. While the second condition considers the absolute difference between the cloud liquid water obtained from observation and simulated observation from background, following:

.. math::
  \text{Condition 2: } | CLW_{obs} - CLW_{bkg} | > 0.0005

If both conditions are satisfied, either background has cloud or observation has cloud detected and this function returns 0. Otherwise, both background and observation don't contain clouds and this function returns 1.

Optional input parameters:
~~~~~~~~~~~~~~~~~~~~~~~~~~

channels
  List of channels available for assimilation.

clwret_clearsky
  Symmetric cloud amount threshold for each channel. Channel is considered insensitivity to the cloud amount less than the threshold.

clwobs_function
  Function to retrieve the cloud liquid water from observation.

clwbkg_function
  Function to retrieve the cloud liquid water from the simulated observation.

Example configuration:
~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: yaml

    clwmatchidx_function:
      name: CLWMatchIndexMW@ObsFunction
      channels: 1-15
      options:
        channels: 1-15
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

The above configuration is an example for AMSU-A N19, which makes use of :code:`CLWRetMW` function to retrieve cloud liquid water from observations and simulated observations from background (see documentation for the :doc:`CLWRetMW <CLWRetMW>` function for more details).
