.. _HydrometeorCheckATMS:

HydrometeorCheckATMS
--------------------------

Cloud and precipitation checks for ATMS

Checks for all observations:
  (1) Sanity check on observaton values
  (2) Sanity check on retrieved CLW values
       
Checks for observation over ocean include:
  (1) Scattering check based on 54.4GHz channel
  (2) Scattering check based on 53.6GHz channel
  (3) Sensitivity to surface emissivity
       
Checks observation over non-ocean surface include:
  (1) Scattering check based on 54.4GHz channel
  (2) Thick cloud check based on 52.8GHz channel
  (3) Sensitivity to surface emissivity

Output of this function:
   0 = channel is not affected by thick clouds and precipitation

   1 = channel is affected by thick clouds and precipitation
    

Required yaml parameters:
^^^^^^^^^^^^^^^^^^^^^^^^^

ATMS Example (atms_qc_filters.yaml):

.. code-block:: yaml

  - filter: Bounds Check
    filter variables:
    - name: brightness_temperature
      channels: *all_channels
    test variables:
    - name: HydrometeorCheckATMS@ObsFunction
      channels: *all_channels
      options:
        channels: *all_channels
        obserr_clearsky:  [ 4.500,  4.500,  4.500,  2.500,  0.550,
                            0.300,  0.300,  0.400,  0.400,  0.400,
                            0.450,  0.450,  0.550,  0.800,  3.000,
                            4.000,  4.000,  3.500,  3.000,  3.000,
                            3.000,  3.000]
        clwret_function:
          name: CLWRetMW@ObsFunction
          options:
            clwret_ch238: 1
            clwret_ch314: 2
            clwret_types: [ObsValue]
        obserr_function:
          name: ObsErrorModelRamp@ObsFunction
          channels: *all_channels
          options:
            channels: *all_channels
            xvar:
              name: CLWRetSymmetricMW@ObsFunction
              options:
                clwret_ch238: 1
                clwret_ch314: 2
                clwret_types: [ObsValue, HofX]
            x0:    [ 0.030,  0.030,  0.030,  0.020,  0.030,
                     0.080,  0.150,  0.000,  0.000,  0.000,
                     0.000,  0.000,  0.000,  0.000,  0.000,
                     0.020,  0.030,  0.030,  0.030,  0.030,
                     0.050,  0.100]
            x1:    [ 0.350,  0.380,  0.400,  0.450,  0.500,
                     1.000,  1.000,  0.000,  0.000,  0.000,
                     0.000,  0.000,  0.000,  0.000,  0.000,
                     0.350,  0.500,  0.500,  0.500,  0.500,
                     0.500,  0.500]
            err0:  [ 4.500,  4.500,  4.500,  2.500,  0.550,
                     0.300,  0.300,  0.400,  0.400,  0.400,
                     0.450,  0.450,  0.550,  0.800,  3.000,
                     4.000,  4.000,  3.500,  3.000,  3.000,
                     3.000,  3.000]
            err1:  [20.000, 25.000, 12.000,  7.000,  3.500,
                    3.000,  0.800,  0.400,  0.400,  0.400,
                    0.450,  0.450,  0.550,  0.800,  3.000,
                   19.000, 30.000, 25.000, 16.500, 12.000,
                    9.000,  6.500]
    maxvalue: 0.0
    action:
      name: reject

