
.. _VT-wind_u_v:

=============================================
Eastward (u) and northward (v) wind component
=============================================
Performs a variable conversion from wind speed and direction to 
the eastward (u) and northward (v) wind component. 

:code:`Transform: ["WindComponents"]`

.. code-block:: yaml

    obs filters:
    - filter: Variables Transform
    Transform: ["WindComponents"]
    
**Observation parameters needed** (JEDI name)

- wind_speed (:math:`V_{s}`)
- wind_from_direction (:math:`V_{d}`)

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

:code:`Transform: ["WindSpeedAndDirection"]`

.. code-block:: yaml

    obs filters:
    - filter: Variables Transform
    Transform: ["WindSpeedAndDirection"]
    
**Observation parameters needed** (JEDI name)

- eastward_wind (:math:`u`)
- northward_wind (:math:`v`)

**Method(s) available**

Only one method is avalable, shared accross all center options. (Any setting of :code:`METHOD` will result
in using this unique method.) Setting :code:`METHOD` can be omitted.

The wind speed (:math:`V_{s}`) and direction (:math:`V_{d}`) are derived as follows:

.. math::
        
    V_{s} =  \sqrt{u^{2}+v^{2}}
    
    V_{d} = \mod((270.0 - \arctan(v, u) \times  \frac{\pi}{180}),  \frac{\pi}{180})

    

**Formulation(s) available**

None
