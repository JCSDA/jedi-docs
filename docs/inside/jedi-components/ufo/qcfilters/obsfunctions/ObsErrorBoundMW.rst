.. _ObsErrorBoundMW:

ObsErrorBoundMW
----------------------------------------------------------------

The observation error bounds for microwave are obtained through the :code:`ObsErrorBoundMW` function. This function determines the observation error bounds (:math:`\text{Residual Threshold}`) for gross check as a function of transmittance at model top, latitude, and terrain height. This function filters out data if :math:`|obs-h(x)| > \text{Residual Threshold}`. Currently, this function is implemented for AMSU-A and ATMS platforms, and the :math:`\text{Residual Threshold}` is obtained differently for each instrument and, furthermore, depends on the channel of the instrument and if it's over water surface. For both instruments with observations over non-water surfaces, the :math:`\text{Residual Threshold}` is obtained following:

.. math::
   \text{Residual Threshold} = \min \left[ 3.0 * \left( \frac{1}{Errflat} \right)^2 * \left( \frac{1}{Errftaotop} \right)^2 * \left( \frac{1}{Errftopo} \right)^2, ErrobsMax \right]

where :math:`ErrobsMax` represents the maximum observation error bound, :math:`Errflat` the error factor as a function of latitude, :math:`Errftaotop` the error factor as a function of transmittance at model top, and :math:`Errftopo` the error factor as a function of terrain height.

Over water surfaces, the :math:`\text{Residual Threshold}` depends on the instrument and its channels. For AMSU-A channels 5 and 15, the :math:`\text{Residual Threshold}` is obtained following:

.. math::
   \text{Residual Threshold} = 3.0 * \left( \frac{1}{Errflat} \right)^2 * \left( \frac{1}{Errftaotop} \right)^2 * \left( \frac{1}{Errftopo} \right)^2

while for the other channels, it's obtained following the same relationship over non-water surfaces. For ATMS channels 6 and 16, the :math:`\text{Residual Threshold}` is obtained considering :math:`ErrobsMax=10.0`, while for other channels follow the same relationship over non-water surfaces.

Required input parameters:
~~~~~~~~~~~~~~~~~~~~~~~~~~

channels
  List of channels available for assimilation.

sensor
  Name of the sensor for which the observation error factor applies.

obserr_bound_max
  The maximum value of the observation error bound for each channel in :code:`channels`.

obserr_bound_latitude
  Function to set the observation bound based on latitude.

obserr_bound_transmittop
  Function to set the observation bound based on transmittance at model top.

obserr_bound_topo
  Function to set the observation bound based on terrain height.

obserr_function
  Function to estimate observation error based on symmetric cloud amount.

Optional Input parameters:
~~~~~~~~~~~~~~~~~~~~~~~~~~

test_obserr
  Name of the data group to which the observation error is applied (default: ObsErrorData).

test_qcflag
  Name of the data group to which the QC flag is applied  (default is QCflagsData).

Example configuration:
~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: yaml

    - filter: Background Check
      filter variables:
      - name: brightness_temperature
        channels: 1-15
      function absolute threshold:
      - name: ObsErrorBoundMW@ObsFunction
        channels: 1-15
        options:
          sensor: amsua_n19
          channels: 1-15
          obserr_bound_latitude:
            name: ObsErrorFactorLatRad@ObsFunction
            options:
              latitude_parameters: [25.0, 0.25, 0.04, 3.0]
          obserr_bound_transmittop:
            name: ObsErrorFactorTransmitTopRad@ObsFunction
            channels: 1-15
            options:
              channels: 1-15
          obserr_bound_topo:
            name: ObsErrorFactorTopoRad@ObsFunction
            channels: 1-15
            options:
              channels: 1-15
              sensor: amsua_n19
          obserr_function:
            name: ObsErrorModelRamp@ObsFunction
            channels: 1-15
            options:
              channels: 1-15
              xvar:
                name: CLWRetSymmetricMW@ObsFunction
                options:
                  clwret_ch238: 1
                  clwret_ch314: 2
                  clwret_types: [ObsValue, HofX]
                  bias_application: HofX
              x0:    [ 0.050,  0.030,  0.030,  0.020,  0.000,
                       0.100,  0.000,  0.000,  0.000,  0.000,
                       0.000,  0.000,  0.000,  0.000,  0.030 ]
              x1:    [ 0.600,  0.450,  0.400,  0.450,  1.000,
                       1.500,  0.000,  0.000,  0.000,  0.000,
                       0.000,  0.000,  0.000,  0.000,  0.200 ]
              err0:  [ 2.500,  2.200,  2.000,  0.550,  0.300,
                       0.230,  0.230,  0.250,  0.250,  0.350,
                       0.400,  0.550,  0.800,  3.000,  3.500 ]
              err1:  [20.000, 18.000, 12.000,  3.000,  0.500,
                       0.300,  0.230,  0.250,  0.250,  0.350,
                       0.400,  0.550,  0.800,  3.000, 18.000 ]
          obserr_bound_max: [4.5, 4.5, 4.5, 2.5, 2.0,
                             2.0, 2.0, 2.0, 2.0, 2.0,
                             2.5, 3.5, 4.5, 4.5, 4.5]
      action:
        name: reject

The above example is for AMSU-A N19 (:code:`amsua_n19`), and the filter checks the brightness temperature for channels 1-15 that fails the background check according to its observation error bounds. These bounds are obtained using the :code:`ObsErrorBoundMW` function, considering observation error factors provided by other functions. See specific documentation for :doc:`ObsErrorFactorLatRad <ObsErrorFactorLatRad>`, :doc:`ObsErrorFactorTransmitTopRad <ObsErrorFactorTransmitTopRad>`, :doc:`ObsErrorFactorTopoRad <ObsErrorFactorTopoRad>`, :doc:`ObsErrorModelRamp <ObsErrorModelRamp>`, and :doc:`CLWRetSymmetricMW <CLWRetSymmetricMW>` functions for more details.
