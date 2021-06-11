.. _ObsErrorModelRamp:

ObsErrorModelRamp
----------------------------------------------------------------------------------

This function parameterizes the observation error as a piece-wise linear function of a ufo Variable.

The output function is specified by the coordinates of the
inflection points and includes:

- # initial constant value
- # linear growth or decay (ramp)
- # final constant value

Diagrams:

::
  
  err1  -   -   - *---
                ,'.
              ,'  .
            ,'    .
  err0  --*'      .
          .       .
       '--+-------+---
          '       '
         x0      x1
  ~~~~
  In case there are x2 and err2 values:
  
  err2  -   -   -  -  -  -  -  *---
                           , ' .
                       , '     .
                   , '         .
  err1  -   -   - *---         .
                ,'.            .
              ,'  .            .
            ,'    .            .
  err0  --*'      .            .
          .       .            .
       '--+-------+---------------
          '       '            '
         x0      x1           x2
  ~~~~

Notes:

- for a decaying ramp, set err1 < err0 and/or err2 < err1.

- for a step function starting at either the first or second inflection point, set x0 == x1
  or x2 == x1, respectively.


Required input parameters:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~


xvar
  The x-variable of the piece-wise function.

x0
  x-coordinate of the lower ramp inflection point.

x1
  x-coordinate of the upper ramp inflection point.

err0
  y-coordinate of the lower ramp inflection point

err1
  y-coordinate of the upper ramp inflection point


Optional input parameters:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

channels
  Channels for which to calculate the ObsError for radiances.
  Omit channels for application to a single non-radiance filter variable.
  When multiple "filter variables" are provided without channels,
  they will have the same observation error.

x2
  An extra upper ramp.

err2
  An extra error value.

save
  Whether to save xvar values to the ObsSpace.

Example configurations:
~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: yaml

  ### example configurations for a FilterBase derived class: ###
 
      - Filter: {Filter Name}

  #### AMSUA ####
 
        filter variables:
        - name: brightness_temperature
          channels: &errassignchan 1-15
        action:
          name: assign error
          error function:
            name: ObsErrorModelRamp@ObsFunction
            channels: *errassignchan
            options:
              channels: *errassignchan
              xvar:
                name: CLWRetMean@ObsFunction
                options:
                  clwret_ch238: 1
                  clwret_ch314: 2
                  clwret_types: [ObsValue, HofX]
                  bias_application: HofX
              x0:    [ 0.050,  0.030,  0.030,  0.020,  0.000,
                       0.100,  0.000,  0.000,  0.000,  0.000,
                       0.000,  0.000,  0.000,  0.000,  0.030]
              x1:    [ 0.600,  0.450,  0.400,  0.450,  1.000,
                       1.500,  0.000,  0.000,  0.000,  0.000,
                       0.000,  0.000,  0.000,  0.000,  0.200]
              err0: [ 2.500,  2.200,  2.000,  0.550,  0.300,
                      0.230,  0.230,  0.250,  0.250,  0.350,
                      0.400,  0.550,  0.800,  3.000,  3.500]
              err1: [20.000, 18.000, 12.000,  3.000,  0.500,
                      0.300,  0.230,  0.250,  0.250,  0.350,
                      0.400,  0.550,  0.800,  3.000, 18.000]
             {save: true}
 
  #### ABI/AHI ####
 
        filter variables:
        - name: brightness_temperature
          channels: &errassignchan 8-10
        action:
          name: assign error
          error function:
            name: ObsErrorModelRamp@ObsFunction
            channels: *errassignchan
            options:
              channels: *errassignchan
              xvar:
                name: SymmCldImpactIR@ObsFunction
                channels: *errassignchan
                options:
                  channels: *errassignchan
              x0: [ 0.0,  0.0,  1.0]
              x1: [15.0, 20.0, 25.0]
              err0: [ 2.5,  3.2,  3.2]
              err1: [17.0, 20.5, 21.1]

  #### Non-radiance ObsTypes ####
 
        filter variables:
        - name: {filter variable name}
        action:
          name: assign error
          error function:
            name: ObsErrorModelRamp@ObsFunction
            options:
              xvar:
                name: {xvar@[ObsFunction, GeoVaLs, ObsDiag, ObsValue, etc...]}
                options: {xvar options}
              x0: [{X0}]
              x1: [{X1}]
              err0: [{ERR0}]
              err1: [{ERR1}]
 

