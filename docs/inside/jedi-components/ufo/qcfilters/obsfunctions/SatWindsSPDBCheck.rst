.. _SatWindsSPDBCheck:

SatWindsSPDBCheck
=================

This obsfunction first computes the wind speed difference between the observation and model.
Then, if model wind speed is greater than observed wind speed, a residual of the two wind
components is computed as :math:`residual = \sqrt{(u_{ob}-u_{model})^2 + (v_{ob}-v_{model})^2}`.
Next, the observational error is kept within lower/upper bounds defined by yaml parameters
:code:`error_min` and :code:`error_max` (since it may have been inflated from prior steps).
Lastly, the function returns a maximum allowable tolerance for the component residual. 
This threshold is the product of the :code:`cgross` and the observation Error.

.. math::
   Threshold_{u} = C_{gross} \cdot \sigma_{obs} \cdot \frac{|\Delta u|}{Residual}

Observations are rejected if the component residual exceeds this calculated threshold.

Required
^^^^^^^^

:code:`wndtype` is a required parameter. This is an integer value to group observations, if the incoming
data are assumed alike a user defined value can be specified allowing use of this filter (example):

.. code-block:: yaml

     - filter: Variable Assignment
       assignments:
       - name: ObsType
       value: 290
       type: integer

The length of the `wndtype` list asserts the length of the following `error_min`, `error_max` and `cgross`
parameters. The ObsSpace must contain an ObsType/{variable} and this type (integer value) will be matched
against `wndtype` in the configuration to be used to assign the error values.

:code:`error_min` and :code:`error_max` are required parameters. They define the lowest/highest ObsError
values considered by the filter.

:code:`cgross` is a required parameter. It is a coefficient for gross error and is multiplied by the ObsError
value which lies in the range defined by `error_min` and `error_max` to define the maximum residual allowable.

Options
^^^^^^^

:code:`original_obserr` is the optional group name for the original value of ObsError before any inflation steps.
This option is typically used for testing against prior datasets, but within UFO, the option is not needed
because it would be the starting value of ObsErrorData.

:code:`test_hofx` is the optional group name for the hofx value used when testing against a reference value
such as :code:`GsiHofX` when using the test_ObsOperator.x application.

Example
^^^^^^^

.. code-block:: yaml

     - filter: Background Check
       filter variables:
       - name: windEastward
       test variables:
       - name: ObsFunction/SatWindsSPDBCheck
         options:
           wndtype: 290
           cgross: 5.0
           error_min: 1.5
           error_max: 6.0
           variable: windEastward
     - filter: Background Check
       filter variables:
       - name: windNorthward
       test variables:
       - name: ObsFunction/SatWindsSPDBCheck
         options:
           wndtype: 290
           cgross: 5.0
           error_min: 1.5
           error_max: 6.0
           variable: windNorthward

