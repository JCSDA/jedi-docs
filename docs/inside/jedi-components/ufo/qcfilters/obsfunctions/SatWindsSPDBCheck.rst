.. _SatWindsSPDBCheck:

SatWindsSPDBCheck
============================================

This obsfunction follows a similar subroutine of GSI Observer and first computes the wind speed
difference between the observation and model. Then, if model wind speed is greater than observed
wind speed, a residual of the two wind components is computed as
:math:`residual = \sqrt{(u_{ob}-u_{model})^2 + (v_{ob}-v_{model})^2}`. Next, the observational
error is kept within lower/upper bounds defined by yaml parameters :code:`error_min` and :code:`error_max`
(since it may have been inflated from prior steps).  These error bound limits were found in a GSI fix file.
Lastly, the quotient of the residual over obsError is calculated as the final output value that is tested
against a maximum value of gross error to reject the observation.

Options
^^^^^^^

:code:`error_min` and :code:`error_max` are required parameters set to the lowest/highest value desired
for calculated ObsError value. Typically this was supplied by a GSI fix file.

:code:`original_obserr` is the optional group name for the original value of ObsError before any inflation steps.
This option is typically used for testing against prior datasets, but within UFO, the option is not needed
because it would be the starting value of ObsErrorData.

:code:`test_hofx` is the optional group name for the hofx value used when testing against a reference value
such as :code:`GsiHofX` when using the test_ObsOperator.x application.

Example
^^^^^^^

.. code-block:: yaml

     - filter: Bounds Check
       filter variables:
       - name: windEastward
       - name: windNorthward
       test variables:
       - name: ObsFunction/SatWindsSPDBCheck
         options:
           error_min: 1.4
           error_max: 20.0
       maxvalue: 1.75            # gross error * 0.7

