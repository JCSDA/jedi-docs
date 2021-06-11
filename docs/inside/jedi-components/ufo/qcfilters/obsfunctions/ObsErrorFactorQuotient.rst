.. _ObsErrorFactorQuotient:

ObsErrorFactorQuotient
================================================================================================================

This obsfunction was designed to mimic GSI Observer method of rejecting observations when
the ratio of final ObsError, after inflation, is more than a threshold amount greater than
the starting ObsError.  The ObsFunction is a simple division expected to be used with
:code:`Bounds Check` filter above a maximum threshold.

Options
^^^^^^^

:code:`numerator` (with :code:`name`)
  the variable and group name to be used in the numerator.

:code:`denominator` (with :code:`name`)
  the variable and group name to be used in the denominator.

Example
^^^^^^^

.. code-block:: yaml

     - Filter: Bounds Check
       filter variables:
       - name: air_temperature
       action:
         name: reject
       maxvalue: 3.6
       test variables:
       - name: ObsErrorFactorQuotient@ObsFunction
           options:
             numerator:
               name: air_temperature@ObsErrorData   # After inflation step
             denominator:
               name: air_temperature@ObsError
       defer to post: true                          # Likely necessary for order of filters

In this example, the observations of :code:`air_temperature` are rejected when the final
ObsError is 3.6 times larger than the original ObsError due to one or more prior series
of error inflation steps.  The usage of :code:`defer to post` option helps to ensure that
earlier QC steps in the yaml that may inflate the ObsError will occur before this filter is run.

