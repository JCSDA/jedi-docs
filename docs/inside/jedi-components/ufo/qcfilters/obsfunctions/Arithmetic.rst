.. _Arithmetic:

Arithmetic
==========

The :code:`Arithmetic` ObsFunction can be used to manipulate and combine an arbitrary number of inputs using selected mathematical operations.

Please note that this ObsFunction used to be called :code:`LinearCombination`. The name has been retained for backwards compatibility,
but its use is deprecated.


Operations
----------

The following operations are available:

* Multiplication,
* Addition,
* Exponentiation,
* Logarithms,
* Absolute value,
* Truncation towards an integer.

The operations are combined as follows:

.. math::
  :name: eqarithmetic

  y = A F\Big(\sum_i a_i f_i(g_i(x_i))\Big) + C

where :math:`y` is the output value,
:math:`x_i` are the variables to combine,
:math:`a_i` are multiplicative coefficients applied to each variable,
:math:`A` is a total multiplicative coefficient,
:math:`C` is an additive constant,
:math:`F(\cdot)` and :math:`f_i(\cdot)` represent the application of one or both of the exponentiation and logarithm functions, and
:math:`g_i(\cdot)` represents the application of one or both of the absolute value and truncation functions.

The base used in both the exponentiation and logarithm functions is user-defined and can be different for each application of those functions.
The truncation function rounds (towards zero) each variable to the nearest integer multiple of a chosen integer. For example, if the chosen integer is 5, the
truncation function will round 12 to 10 and -17 to -15.


Parameters
----------

The ObsFunction accepts the following parameters. In each case the correspondence between the parameter and a term in the
:ref:`above equation <eqarithmetic>` is shown.

* :code:`variables`: Vector of input variables (:math:`x_i`).
* :code:`coefs`: Vector of multiplicative constants associated with the input variables (:math:`a_i`).
* :code:`exponents`: Vector of exponents associated with the input variables (:math:`f_i(\cdot)`).
* :code:`total exponent`: Overall exponent (:math:`F(\cdot)`).
* :code:`total coefficient`: Overall multiplicative coefficient (:math:`A`).
* :code:`intercept`: Additive constant (:math:`C`).
* :code:`total log base`: Overall log base (can be empty string for no logarithm, or ``e`` for natural logarithm) (:math:`f_i(\cdot)`).
* :code:`log bases`: Vector of log bases associated with the input variables (can empty string for no logarithm, or ``e`` for natural logarithm) (:math:`f_i(\cdot)`).
* :code:`absolute value`: Take absolute value of each variable (:code:`true`/:code:`false`). If :code:`true`, the absolute value is taken before any other operation is performed (:math:`g_i(\cdot)`).
* :code:`truncate`: Truncate (round towards zero) each input variable to the nearest integer multiple of the corresponding entry in this vector. If the value in the vector is zero or negative, no truncation is performed. If the value is positive, truncation is performed before any other operation apart from taking the absolute value. (:math:`g_i(\cdot)`).
* :code:`use channel numbers`: This option enables channel numbers to be combined if that is desired. If :code:`true`, the channel number will be used in the calculation instead of the value of each variable. Default :code:`false`.
* :code:`abort if invalid operation`: When :code:`true`, certain invalid operations (outlined below) will cause an exception to be raised. When :code:`false` a warning will be logged instead and the output value will be set to missing. Default :code:`false`.
The :code:`variables` parameter must be present. All other parameters are optional.
The length of vector parameters such as :code:`log bases` must be the same length as :code:`variables`.

If the input variable is equal to the missing value, the output variable is set to the missing value.
The same occurs for a missing input channel if :code:`use channel numbers` is :code:`true`.

Warnings are emitted in the following situations:

* The :code:`total exponent` parameter is larger than 25, or any value in the :code:`exponents` vector is larger than 10. Such values could cause numerical overflows.
* A negative value is raised to a non-integer exponent and :code:`abort if invalid exception` is :code:`false`. In this case the output value is set to missing.
* Zero is raised to a negative exponent and :code:`abort if invalid exception` is :code:`false`. In this case the output value is set to missing.

Exceptions are thrown in the following situations:

* The logarithm of a negative number (or zero) is taken.
* The chosen log base is invalid.
* A negative value is raised to a non-integer exponent and :code:`abort if invalid exception` is :code:`true`.
* Zero is raised to a negative exponent and :code:`abort if invalid exception` is :code:`true`.


Example 1
---------

.. code-block:: yaml

 obs function:
   name: ObsFunction/Arithmetic
   options:
     variables: [GeoVaLs/representation_error,
                 ObsError/waterTemperature]
     coefs: [0.1, 1.0]

Output: 0.1 :code:`GeoVaLs/representation_error` + :code:`ObsError/waterTemperature`.


Example 2
---------

.. code-block:: yaml

 obs function:
   name: ObsFunction/Arithmetic
   options:
     variables: [ObsValue/variable1,
                 ObsValue/variable2,
                 ObsValue/variable3]
     coefficients: [0.1, 0.2, 0.3]
     exponents: [1, 2, 3]
     log bases: ["10", "", e]
     total coefficient: 4
     total exponent: 5
     total log base: 2
     intercept: 6

Output:

4 :math:`\log_{2}` :math:`\Big(\big(` 0.1 :math:`\log_{10}` (:code:`ObsValue/variable1`:math:`^1`) + 0.2 :code:`ObsValue/variable2`:math:`^2` + 0.3 :math:`\ln` (:code:`ObsValue/variable3`:math:`^3`) :math:`\big)^5` :math:`\Big)` + 6.


Example 3
---------

This example shows how calculations can be performed on multi-channel data.

.. code-block:: yaml

 obs function:
   name: ObsFunction/Arithmetic
   channels: &select_chans 6-15, 18-22 # this line may be needed depending on the filter used
   options:
     variables:
     - name: ObsValue/brightnessTemperature
       channels: *select_chans
     - name: ObsError/brightnessTemperature
       channels: *select_chans
     coefs: [1.0, 0.5]

Output for channel :code:`k`: :code:`ObsValue/brightnessTemperature[k]` + 0.5 :code:`ObsError/brightnessTemperature[k]`.


Example 4
---------

This example shows how calculations can be performed on multi-channel data, using the channel number instead of the value of each variable.

.. code-block:: yaml

 obs function:
   name: ObsFunction/Arithmetic
   channels: &select_chans 6-15, 18-22 # this line may be needed depending on the filter used
   options:
     variables:
     - name: ObsValue/brightnessTemperature
       channels: *select_chans
     coefs: [0.5]
     intercept: 3.6
     use channel numbers: true

Output for channel :code:`k`: 3.6 + 0.5 :code:`k`.


Example 5
---------

.. code-block:: yaml

 obs function:
   name: ObsFunction/Arithmetic
   options:
     variables: [ObsValue/variable1,
                 ObsValue/variable2]
     absolute value: [true, false]
     truncate: [0, 3]

Output: :code:`|ObsValue/variable1| + trunc(ObsValue/variable2, 3)`
where :code:`trunc(x, y)` returns x truncated to the nearest integer multiple of y.
Truncation is always performed towards zero, e.g. trunc(17, 3) = 15, trunc(-13, 3) = -12.
