
.. _VT-Relative-Humidity:

=================
Relative Humidity
=================
Performs a variable conversion from specific_humidity, temperature, and
pressure to relative humidity. The newly calculated variable is included in the same
obs space.

:code:`Transform: ["RelativeHumidity"]`

.. code-block:: yaml

    obs filters:
    - filter: Variables Transform
    Transform: ["RelativeHumidity"]
    Method: UKMO            
    Formulation: Sonntag    

**Observation parameters needed** (JEDI name)

- specific_humidity (:math:`q`)
- air_temperature (:math:`T`)
- air_pressure or surface_pressure (:math:`P`)

**Method(s) available**

Only one method is avalable, shared accross all center options. (Any setting of :code:`METHOD` will result
in using this unique method.) Setting :code:`METHOD` can be omitted.

The relative humidity (:math:`Rh`) is retrieved as follow:

.. math::
    
    Rh = w/w_{sat}

with :math:`w_{sat}` (saturated water vapor mixing ratio) derived using :math:`e_{sat}`
(saturated vapor pressure):

.. math::
    
    w_{sat} = \epsilon \times e_{sat}/(P-e_{sat})

and :math:`w` (water vapor mixing ratio) derived using :math:`q` (specific humidity):

.. math::
    
    w = q/(1-q)

:math:`\epsilon` is ratio of the gas constant for dry air (:math:`R_{d}`) over the gas constant for water vapor (:math:`R_{v}`).
The value of :math:`e_{sat}` (saturated vapor pressure) is derived using 
:ref:`SatVaporPres_fromTemp`.

**Formulation(s) available**

Various formulations are available to derive :ref:`SatVaporPres_fromTemp`.


.. _VT-Specific-Humidity:

=================
Specific Humidity
=================
Performs a variable conversion from relative humidity, temperature, and
pressure to specific humidity. The newly calculated variable is included in the same
obs space.

:code:`Transform: ["SpecificHumidity"]`

.. code-block:: yaml

    obs filters:
    - filter: Variables Transform
    Transform: ["SpecificHumidity"]
    Method: UKMO            
    Formulation: Sonntag  
    
**Observation parameters needed** (JEDI name)

- relative_humidity (:math:`Rh`)
- air_temperature (:math:`T`)
- air_pressure or surface_pressure (:math:`P`)

**Method(s) available**

Only one method is avalable, shared accross all center options. (Any setting of :code:`METHOD` will result
in using this unique method.) Setting :code:`METHOD` can be omitted.

The specific humidity (:math:`q`) is retrieved as follows:

.. math::
    
    q = w/(1+w)


where water vapor mixing ratio (:math:`w`) is derived from relative humidity (:math:`Rh`)

    .. math::
            
        w = Rh \times w_{sat}

with :math:`w_{sat}` (saturated water vapor mixing ratio) derived using :math:`e_{sat}`
(saturated vapor pressure):
    
    .. math::
        
        w_{sat} = \epsilon \times e_{sat}/(P-e_{sat})

With :math:`\epsilon` is ratio of the gas constant for dry air (:math:`R_{d}`) 
over the gas constant for water vapor (:math:`R_{v}`).
The value of :math:`e_{sat}` (saturated vapor pressure) is derived using :ref:`SatVaporPres_fromTemp`.

**Formulation(s) available**

Various formulation are available to derive :ref:`SatVaporPres_fromTemp`.

