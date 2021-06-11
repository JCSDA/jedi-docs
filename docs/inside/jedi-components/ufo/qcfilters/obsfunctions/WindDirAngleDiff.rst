.. _WindDirAngleDiff:

WindDirAngleDiff
========================================================================================

This obsfunction computes the wind direction angle difference between the observation and model.
Since the wind component variables are used in JEDI, a translation to wind direction is made within the code.
The purpose of this function is to reject observed wind data when the observation differs from the model
background (first guess) by a threshold of angular difference in wind direction, typically done with the
Bounds Check filter.  Since light wind conditions (nearly calm) could be considered OK, there is an optional
parameter :code:`minimum_uv` that can be set (default is 0.5 m/s) below which the check will not be applied.

Options
^^^^^^^

:code:`test_hofx` is an option to compare the results against a reference (such as :code:`GsiHofX`) when
executed with test_OpsOperator.x application.

:code:`minimum_uv` is used to ignore large wind direction discrepancies (between model and obs) under light
wind conditions.  The default value is 0.5 m/s.

Example
^^^^^^^

For application in satellite-derived wind quality control, a difference of wind direction greater than 50 degrees is often used to reject the wind information.  The following yaml illustrates its usage together with the :code:`Bounds Check` filter.  The :code:`test_hofx` parameter is shown below (set to :code:`GsiHofX`), however, when running UFO HofX application, this option should be removed since the incomming model background field would be used instead of a pre-existing value of hofx.

.. code-block:: yaml

     - filter: Bounds Check
       filter variables:
       - name: eastward_wind
       - name: northward_wind
       test variables:
       - name: WindDirAngleDiff@ObsFunction
         options:
           minimum_uv: 1.0        # Wind components less than this value are ignored in the wind angle difference check
           #test_hofx: GsiHofX     # Only if testing against pre-existing hofx data; otherwise reference is hofx

       maxvalue: 50
