.. _ProfileVerticalSmoothing:

ProfileVerticalSmoothing
========================

This obsfunction computes a smoothed version of the input data, by using local
polynomial regression. All observations which share a record number are assumed
to be part of the same profile, and are smoothed together. The vertical coordinate
is normalised using the filter width, and the weight given to each observation is
based on its distance from the target observation. Thus, using a larger filter
width will result in a smoother profile.

Options
^^^^^^^

:code:`variable` The variable to apply the smoothing to. Required.

:code:`heightVariable` The variable representing the height coordinate. Required.

:code:`filterWidth` List of filter widths to apply - must be in ascending order of height. Optional. (default is 100, 100)

:code:`filterHeight` List of filter heights to apply - must be in ascending order of height. Optional. (default is 0, 60000)

:code:`polynomialOrder` Order of polynomial to use for local regression. Optional. (default is 3, i.e. cubic).

Example
^^^^^^^

For application in a variable assignment filter, applying the smoothing to
bending angles, with the filter width and height increasing with height:

.. code-block:: yaml

  - filter: Variable Assignment
    assignments:
    - name: TestResult/smoothBendingAngle
      type: float
      function:
        name: ObsFunction/ProfileVerticalSmoothing
        options:
          variable: ObsValue/bendingAngle
          heightVariable: MetaData/impactHeightRO
          filterWidth: "150,250,400,600,850,1200,1500,2000,2200,2500"
          filterHeight: "2000,4000,6000,8000,10000,15000,20000,30000,40000,60000"
          polynomialOrder: 3
