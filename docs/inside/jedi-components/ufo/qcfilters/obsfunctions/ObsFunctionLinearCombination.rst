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

Here is an example to assign to a variable :code:`DerivedObsValue/sea_level_anomaly`, the linear combination: :code:`(1.0 * DerivedObsValue/sea_surface_height - 1.0 * HofX/mean_sea_height)`.

.. code-block:: yaml

  - filter: Variable Assignment
    assignments:
    - name: DerivedObsValue/sea_level_anomaly
      type: float
      function:
        name: ObsFunction/LinearCombination
        options:
          variables: [DerivedObsValue/sea_surface_height, HofX/mean_sea_height]
          coefs: [1.0, -1.0]

An example with multi-channel variables:

.. code-block:: yaml

  obs function:
    name: ObsFunction/LinearCombination
    channels: &select_chans 6-15, 18-22
    options:
      variables:
      - name: ObsValue/var1
        channels: *select_chans
      - name: ObsError/var1
        channels: *select_chans
      coefs: [1.0, 0.5]

This will return: :code:`sum over channels [6-15,18-22] of (1.0 * ObsValue/var1_<channel> + 0.5 * ObsError/var1_<channel>)`.
