
.. _VT-wind_u_v:

=============================================
Eastward (u) and northward (v) wind component
=============================================
Performs a variable conversion from wind speed and direction to 
the eastward (u) and northward (v) wind component. 

:code:`Transform: WindComponents`

.. code-block:: yaml

    obs filters:
    - filter: Variable Transforms
      Transform: WindComponents
    
**Observation parameters needed** (JEDI name)

The default option for this transform requires the following variables:

- wind_speed (:math:`V_{s}`)
- wind_from_direction (:math:`V_{d}`)

It is possible to change the default variables by setting the following options in the yaml: 

- wind direction variable
- wind speed variable
- group

For example the surface wind speed and direction can be transformed using the following:

.. code-block:: yaml

    obs filters:
    - filter: Variable Transforms
      Transform: WindComponents
      wind speed variable: windSpeedAt10M
      wind direction variable: windDirectionAt10M

The group option can be set to transform wind speed and direction from a group other than ObsValue. 


**Method(s) available**

Only one method is avalable, shared accross all center options. (Any setting of :code:`METHOD` will result
in using this unique method.) Setting :code:`METHOD` can be omitted.

The eastward (:math:`u`) and northward (:math:`v`) wind component are derived as follow:

.. math::
        
     u = -V_{s} \times sin(V_{d} \times \frac{\pi}{180})

     v = -V_{s} \times cos(V_{d} \times \frac{\pi}{180})

**Formulation(s) available**

None


.. _VT-wind_sp_dir:

========================
Wind speed and direction
========================
Performs a variable conversion from eastward (u) and northward (v) wind components to
wind speed and direction. 

:code:`Transform: WindSpeedAndDirection`

.. code-block:: yaml

    obs filters:
    - filter: Variable Transforms
      Transform: WindSpeedAndDirection
    
**Observation parameters needed** (JEDI name)

The default option for this transform requires the following variables:

- eastward_wind (:math:`u`)
- northward_wind (:math:`v`)

It is possible to change the default variables by setting the following options in the yaml: 

- eastward wind variable
- northward wind variable
- group

For example the surface wind speed and direction can be transformed using the following:

.. code-block:: yaml

    obs filters:
    - filter: Variable Transforms
      Transform: WindSpeedAndDirection
      eastward wind variable: windEastwardAt10M
      northward wind variable: windNorthwardAt10M

The group option can be set to transform eastward and northward wind from a group other than ObsValue. 


**Method(s) available**

Only one method is avalable, shared accross all center options. (Any setting of :code:`METHOD` will result
in using this unique method.) Setting :code:`METHOD` can be omitted.

The wind speed (:math:`V_{s}`) and direction (:math:`V_{d}`) are derived as follows:

.. math::
        
    V_{s} =  \sqrt{u^{2}+v^{2}}
    
    V_{d} = \mod((270.0 - \arctan(v, u) \times  \frac{\pi}{180}),  \frac{\pi}{180})

    

**Formulation(s) available**

None
