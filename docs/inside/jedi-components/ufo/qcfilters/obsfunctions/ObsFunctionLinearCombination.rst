.. _ObsFunctionLinearCombination:

ObsFunctionLinearCombination
-----------------------------------------------------------------

This obsFunction is designed to form a linear combination of given variables weighted by given coefficients. E.g. for variables :code:`[var1, var2, var3]` and coefficients :code:`[a1, a2, a3]`, the output is: :code:`a1*var1 + a2*var2 + a3*var3`.

Required input parameters:
~~~~~~~~~~~~~~~~~~~~~~~~~~

variables
  An array of the variables to be linearly combined. These may be multi-channel variables, in which case both the name of the variables and the channels must be given.

coefs
  An array of float values by which the variables are weighted in the linear combination. There must be the same number of coefficients as variables, i.e. the :code:`variables` and :code:`coefs` arrays must be the same length - otherwise the filter will stop with an error. In the case of multi-channel variables, the same coefficient is applied to all selected channels of the variable (see below).
  
Example configuration:
~~~~~~~~~~~~~~~~~~~~~~

Here is an example to assign to a variable :code:`sea_level_anomaly@DerivedObsValue`, the linear combination: :code:`(1.0 * sea_surface_height@DerivedObsValue - 1.0 * mean_sea_height@HofX)`.

.. code-block:: yaml

  - filter: Variable Assignment
    assignments:
    - name: sea_level_anomaly@DerivedObsValue
      type: float
      function:
        name: LinearCombination@ObsFunction
        options:
          variables: [sea_surface_height@DerivedObsValue, mean_sea_height@HofX]
          coefs: [1.0, -1.0]

An example with multi-channel variables:

.. code-block:: yaml

  obs function:
    name: LinearCombination@ObsFunction
    channels: &select_chans 6-15, 18-22
    options:
      variables:
      - name: var1@ObsValue
        channels: *select_chans
      - name: var1@ObsError
        channels: *select_chans
      coefs: [1.0, 0.5]

This will return: :code:`sum over channels [6-15,18-22] of (1.0 * var1@ObsValue_<channel> + 0.5 * var1@ObsError_<channel>)`.