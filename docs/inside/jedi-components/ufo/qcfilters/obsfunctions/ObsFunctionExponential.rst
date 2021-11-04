.. _ObsFunctionExponential:

ObsFunctionExponential
-----------------------------------------------------------------

This obsFunction computes the exponential function of a variable, e.g. :code:`var1` - given coefficients :code:`A`, :code:`B`, :code:`C`, :code:`D`, the output is :code:`A * exp ( B * var1 ) + C`, or the output is :code:`D` when :code:`var1` is missing.

Required input parameters:
~~~~~~~~~~~~~~~~~~~~~~~~~~

variables
  The variable to be in the argument of the exponential function. May be a multi-channel variable, in which case both the name of the variable and the channels must be given. Only one variable should be specified, otherwise the filter will stop with an error.

Optional input parameters:
~~~~~~~~~~~~~~~~~~~~~~~~~~

coeffA
  Multiplier of exponential function. Default if not specified: :code:`1.0`

coeffB
  Multiplier of input variable within the exponential function. Default: :code:`1.0`

coeffC
  Constant term additional to the exponential. Default: :code:`0.0`

coeffD
  Value output at locations where the input variable is missing. Default: :code:`missing`

  
Example configuration:
~~~~~~~~~~~~~~~~~~~~~~

Here is an example that assigns to :code:`cool_skin_correction@DerivedObsValue`, the output :code:`(0.2 * exp ( -0.2 * wind_speed@ObsValue ) + 0.1)` in locations where :code:`wind_speed@ObsValue` is not missing, and :code:`0.15` in locations where :code:`wind_speed@ObsValue` is missing.

.. code-block:: yaml

  - filter: Variable Assignment  # calculate cool-skin correction
    assignments:
    - name: cool_skin_correction@DerivedObsValue
      type: float
      function:
        name: Exponential@ObsFunction
        options:
          variables: [wind_speed@ObsValue]
          coeffA: 0.2
          coeffB: -0.2
          coeffC: 0.1
          coeffD: 0.15 # not actual values


An example with a multi-channel variable:

.. code-block:: yaml

  obs function:
    name: Exponential@ObsFunction
    options:
      variables:
      - name: fake_x_data@MetaData
        channels: 1-3
      coeffA: -1.0
      coeffB: -0.1
      coeffC: 1.0

This will return the 3-channel output: :code:`-1.0 * exp ( -0.1 * fake_x_data_<channel>@MetaData ) + 1.0`. Missing values of :code:`fake_x_data_<channel>@MetaData` result in missing values output at those locations, since no :code:`coeffD` is specified.

Note that to prevent floating-point overflow, the argument of the exponential is limited to :code:`+40.0` - when :code:`(B * var1) > 40.0`, a value of :code:`coeffD` is returned at that location and a warning is output. Care should be taken when choosing :code:`coeffB`. Please ensure the input variable's missing values are the proper JEDI missing values, rather than some other large negative number - that could also trigger the exponential argument limit if :code:`B < 0`.