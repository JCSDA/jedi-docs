.. _ObsFunctionVelocity:

ObsFunctionVelocity
-----------------------------------------------------------------

This obsFunction is designed to compute wind speed based on u(eastward_wind) and v(northward_wind) components of wind. 

Required input parameters:
~~~~~~~~~~~~~~~~~~~~~~~~~~

eastward_wind
  zonel velocity, i.e. the component of the horizontal wind TOWARDS EAST
  
northward_wind
  meridional velocity, i.e. the component of the horizontal wind TOWARDS NORTH
  
Example configuration:
~~~~~~~~~~~~~~~~~~~~~~

Here is an example to use this obsFunction to compute velocity and then reject data if the velocity 
value is bigger than :code:`maxvalue`.

.. code-block:: yaml

  - filter: Bounds Check
    filter variables:
    - name: eastward_wind
    - name: northward_wind
    test variables:
    - name: Velocity@ObsFunction
    maxvalue: 135.0
    action:
      name: reject
