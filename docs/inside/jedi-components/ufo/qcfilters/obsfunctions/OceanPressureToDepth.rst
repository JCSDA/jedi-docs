.. _OceanPressureToDepth:

OceanPressureToDepth
-----------------------------------------------------------------

Convert an ocean pressure variable (Pa) to depth below surface (m). This uses the latitude-dependent formulation of Fofonoff and Millard (1983) as given in equation 3 of https://archimer.ifremer.fr/doc/00447/55889/57949.pdf


Required input parameters:
~~~~~~~~~~~~~~~~~~~~~~~~~~

pressure variable
  The variable containing the ocean pressure values. (Note that it accepts a variable name from the user because the pressure values might be in a non-obvious variable, e.g. :code:`ObsValue/height`. However, the latitude is always assumed to be in :code:`MetaData/latitude`.) There are no optional input parameters.

  
Example configuration:
~~~~~~~~~~~~~~~~~~~~~~

Here is an example that assigns to :code:`DerivedObsValue/depthBelowWaterSurface`, the depth computed by the ObsFunction, in locations where :code:`MetaData/argo_identifier` is not missing. It takes the ocean pressure from :code:`ObsValue/height`.

.. code-block:: yaml

  - filter: Variable Assignment  # calculate cool-skin correction
    where:
    - variable:
        name: MetaData/argo_identifier
      is_defined:
    assignments:
    - name: DerivedObsValue/depthBelowWaterSurface
      type: float
      function:
        name: ObsFunction/OceanPressureToDepth
        options:
          pressure variable: ObsValue/height
