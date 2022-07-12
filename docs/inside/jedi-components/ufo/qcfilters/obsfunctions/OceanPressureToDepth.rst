.. _OceanPressureToDepth:

OceanPressureToDepth
-----------------------------------------------------------------

Convert an ocean pressure variable (Pa) to depth below surface (m). This uses the latitude-dependent formulation of Fofonoff and Millard (1983) as given in equation 3 of https://archimer.ifremer.fr/doc/00447/55889/57949.pdf


Required input parameters:
~~~~~~~~~~~~~~~~~~~~~~~~~~

pressure variable
  The variable containing the ocean pressure values. (Note that it accepts a variable name from the user because the pressure values might be in a non-obvious variable, e.g. :code:`height@ObsValue`. However, the latitude is always assumed to be in :code:`latitude@MetaData`.) There are no optional input parameters.

  
Example configuration:
~~~~~~~~~~~~~~~~~~~~~~

Here is an example that assigns to :code:`ocean_depth@DerivedObsValue`, the depth computed by the ObsFunction, in locations where :code:`argo_identifier@MetaData` is not missing. It takes the ocean pressure from :code:`height@ObsValue`.

.. code-block:: yaml

  - filter: Variable Assignment  # calculate cool-skin correction
    where:
    - variable:
        name: argo_identifier@MetaData
      is_defined:
    assignments:
    - name: ocean_depth@DerivedObsValue
      type: float
      function:
        name: OceanPressureToDepth@ObsFunction
        options:
          pressure variable: height@ObsValue
