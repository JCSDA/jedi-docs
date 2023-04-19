.. _SatwindIndivErrors:

SatwindIndivErrors
==========================================================================================

This obsfunction calculates individual observation errors for Satwind u and v wind
components, dependent on an input pressure error estimate and the model vertical wind shear.
The error function is desgined to be used with the :code:`assign error` action for the 
:code:`Perform Action` filter as shown in the example below. Since the computation requires 
the HofX value, the filter must be called with :code:`defer to post: true`.

Wind component errors are calculated by combining an estimate of the error in
the vector, with an estimate of the error in vector due to an error in the
pressure (i.e. the height assignment).

The vector error estimate :math:`E_{vector}` is currently based on the quality index (QI), 
a quality value between 0-100 which is supplied with the Satwind observations.

:math:`E_{vector} = \text{EuMult}\left(QI \times 0.01\right) + \text{EuAdd}`

where EuMult and EuAdd are linear coefficients.

The error in vector due to the height error, :math:`E_{vpress}` is calculated as:

:math:`E_{vpress} = \sqrt{\frac{\sum{W_{i}\left(v_{i}-v_{n}\right)^{2}}}{\sum{W_{i}}}}`
 
where

- :math:`W_{i} = \exp\left(- \left( \left( p_{i} - p_{n} \right)^2 / 2E_{p}^2 \right)\right) \times dP_{i}`
- :math:`i` = model level
- :math:`N` = number of model levels (sum over) 
- :math:`v_{i}` = wind component on model level 
- :math:`v_{n}` = wind component at observation location 
- :math:`p_{i}` = pressure on model level 
- :math:`p_{n}` = pressure at observation location 
- :math:`E_{p}` = error in height assignment 
- :math:`dP_{i}` = layer thickness 
 
This total wind component error is then given as
 
:math:`E_{total}^2 = E_{vector}^2 + E_{vpress}^2`
 

Options
^^^^^^^

Required parameters:

:code:`wind component`
  String containing the name of the wind component we are calculating the error for.
  Must be one of :code:`windEastward` or :code:`windNorthward`.

:code:`observation vertical coordinate`
  String containing the observation vertical coordinate.

:code:`vertical coordinate`
  String containing the vertical coordinate to use for the model wind component.
  Must be one of :code:`pressure` or :code:`pressure_levels`.

:code:`pressure error`
  Name of the variable containing the input pressure error estimates. Units Pa.

:code:`verror add`
  Vector error estimate addition coefficient (EuAdd).

:code:`verror mult`
  Vector error estimate multiplication coefficient (EuMult).

:code:`quality index`
  Name of the variable containing quality index (QI) values for use in the vector error calculation.

Optional parameters:

:code:`minimum pressure`
  Ignore contribution from pressures less than the minimum pressure, Pa. Default is 10000 Pa.


Example
^^^^^^^

.. code-block:: yaml

  - filter: Perform Action
    defer to post: true
    filter variables:
    - name: windEastward
    action:
      name: assign error
      error function:
        name: ObsFunction/SatwindIndivErrors
        options:
          verror add: 15.0
          verror mult: -10.0
          wind component: windEastward
          observation vertical coordinate: pressure
          vertical coordinate: pressure_levels
          pressure error:
            name: MetaDataError/pressure
          quality index:
            name: MetaData/qiWithoutForecast
