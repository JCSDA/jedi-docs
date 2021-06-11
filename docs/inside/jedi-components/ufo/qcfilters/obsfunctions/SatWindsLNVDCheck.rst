.. _SatWindsLNVDCheck:

SatWindsLNVDCheck
==========================================================================================

This obsfunction follows a similar subroutine of GSI Observer to compute the log-normal vector difference (LNVD)
between the observed and model winds. Calculation of LNVD uses the following
:math:`LNVD = \sqrt{(u_{ob}-u_{model})^2 + (v_{ob}-v_{model})^2}/\log(\textrm{observed wind speed})`. Within GSI, computed
values greater than a threshold (3.0) are used to reject winds, which can be accomplished using the
:code:`Bounds Check` filter shown in the example.

Options
^^^^^^^

:code:`test_hofx` is optional as a way to test against a reference value when running the
test_ObsOperator.x application instead of the test_ObsFilters.x application.

Example
^^^^^^^

.. code-block:: yaml

     - filter: Bounds Check
       filter variables:
       - name: eastward_wind
       - name: northward_wind
       test variables:
       - name: SatWindsLNVDCheck@ObsFunction
         options:
           test_hofx: GsiHofX
       maxvalue: 3
