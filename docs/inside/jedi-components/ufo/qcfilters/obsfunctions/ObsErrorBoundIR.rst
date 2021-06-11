.. _ObsErrorBoundIR:

ObsErrorBoundIR
========================================================

This obsfunction calculates the observation error bound (Residual Threshold) 
for gross check as a function of transmittance at model top and latitude.
It uses two sub-obsfunctions :code:`ObsErrorFactorLatRad`
and :code:`ObsErrorFactorTransmitTopRad` to determine the residual
threshold.

Input parameters: 
-----------------

Errobs0
  un-inflated observation error

ErrobsMax
  maximum observation error bound (obserr_bound_max)

Errflat
  error factor as a function of latitude (ObsErrorFactorLatRad@ObsFunction)

Errtaotop
  error factor as a function of transmittance at model top (ObsErrorFactorTransmitTopRad@ObsFunction)

The residual threshold is calculated as :math:`\min( (3.0 * ( 1 / Errflat )^2 * (1 / Errftaotop )^2), ErrobsMax )`.
This function filters out data if :math:`|obs-h(x)| > Residual Threshold`.

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
        obserr_bound_latitude:
          name: ObsErrorFactorLatRad@ObsFunction
          options:
            latitude_parameters: [25.0, 0.5, 0.04, 1.0]
        obserr_bound_transmittop:
          name: ObsErrorFactorTransmitTopRad@ObsFunction
          channels: *all_channels
          options:
            channels: *all_channels
        obserr_bound_max: [ 3.5, 3.5, 3.5, 3.5, 3.5, 3.5, 3.5, 3.5, 3.5, 3.5,
                            3.5, 3.5, 3.5, 3.5, 3.5, 3.5, 3.5, 3.5, 3.5, 3.5,
                            3.5, 3.5, 3.5, 3.5, 3.5, 3.5, 3.5, 3.5, 3.5, 3.5,
                            3.5, 3.5, 3.5, 3.5, 3.5, 3.5, 3.5, 3.5, 3.5, 3.5,
                            3.5, 3.5, 3.5, 3.5, 3.5, 3.5, 3.5, 3.5, 3.5, 3.5,
                            3.5, 3.5, 3.5, 3.5, 3.5, 3.5, 3.5, 3.5, 3.5, 3.5,
                            3.5, 3.5, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0,
                            3.0, 3.0, 3.0, 3.0, 3.5, 3.5, 3.5, 3.0, 3.0, 3.5,
                            3.5, 3.0, 3.0, 3.0, 3.5, 3.0, 3.0, 3.0, 3.0, 3.0,
                            3.5, 3.0, 3.5, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0,
                            3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0,
                            3.5, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0,
                            3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0,
                            3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0,
                            3.5, 3.5, 3.5, 3.5, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0,
                            3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0,
                            3.0, 3.5, 3.0, 3.5, 3.0, 3.0, 3.0, 3.0, 3.5, 3.0,
                            4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5,
                            4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5,
                            4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5,
                            4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5,
                            4.5, 4.5, 4.5, 4.5, 2.5, 2.5, 2.5, 2.5, 2.5, 2.5,
                            2.5, 2.5, 2.5, 2.5, 2.5, 2.5, 2.5, 2.5, 2.5, 3.5,
                            3.5, 3.5, 3.5, 3.5, 3.5, 3.5, 3.5, 3.5, 3.5, 3.5,
                            3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0,
                            3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0,
                            3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0,
                            3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0,
                            3.0 ]
    action:
      name: reject

