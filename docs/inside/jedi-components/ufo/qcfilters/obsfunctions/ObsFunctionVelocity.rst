.. _ObsFunctionVelocity:

ObsFunctionVelocity
-----------------------------------------------------------------

This obsFunction is designed to compute wind speed based on u(windEastward) and v(windNorthward) components of wind. 

Parameters:
~~~~~~~~~~~~~~~~~~~~~~~~~~

- :code:`channels`: List of assimilated channels. Default is none.

- :code:`type`: Observation group name. Default is ObsValue.

- :code:`eastward wind variable`: Name of the u wind component variable. Default is windEastward.

- :code:`northward wind variable`: Name of the v wind component variable. Default is windNorthward.

Example configuration:
~~~~~~~~~~~~~~~~~~~~~~

Here is an example to use this obsFunction to compute velocity and then reject data if the velocity 
value is bigger than :code:`maxvalue`.

.. code-block:: yaml

  - filter: Bounds Check
    filter variables:
    - name: windEastward
    - name: windNorthward
    test variables:
    - name: ObsFunction/Velocity
    maxvalue: 135.0
    action:
      name: reject

Example for calculating 10m wind speed

.. code-block:: yaml

  obs function:
    name: ObsFunction/Velocity
    options:
      eastward wind variable: windEastwardAt10M
      northward wind variable: windNorthwardAt10M