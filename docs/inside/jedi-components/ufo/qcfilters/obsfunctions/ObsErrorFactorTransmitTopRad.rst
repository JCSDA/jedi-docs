.. _ObsErrorFactorTransmitTopRad:

ObsErrorFactorTransmitTopRad
======================================================================================

This obsfunction calculates the observation error inflation factor for 
satellite radiances as a function of model top-to-space transmittance.

The Error Inflation Factor (EIF) is calculated as 
:math:`EIF = \sqrt{ 1.0 / \tau }`, where :math:`\tau` is the model top-to-space transmittance.

Required input parameters:
--------------------------

channels
  List of channel to which the observation error factor applies


Example:
--------

.. code-block:: yaml

  - filter: Background Check
    filter variables:
    - name: brightness_temperature
      channels: *all_channels
    function absolute threshold:
    - name: ObsErrorBoundIR@ObsFunction
      channels: *all_channels
      options:
        channels: *all_channels
        obserr_bound_transmittop:
          name: ObsErrorFactorTransmitTopRad@ObsFunction
          channels: *all_channels
          options:
            channels: *all_channels
    action:
      name: reject
