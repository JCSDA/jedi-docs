
.. _satzencorrection_v1:

======================================================
Correct a variable based on the sensor zenith angle
======================================================
This variable transform was written to correct a variable for
the sensor viewing angle, principally for emissivity data read from a
static atlas.

:code:`Transform: SatZenithAngleCorrection`

.. code-block:: yaml

    - filter: Variable Transforms
      Transform: SatZenithAngleCorrection
      transform variable:
        name: MetaData/emissivity

**Parameters**

The default option for this transform requires the following variable to be available:

- sensor zenith angle (:code:`MetaData/sensorZenithAngle`)

The following options are available for this variable transform:

- :code:`transform variable` is a required parameter and is of type :code:`ufo::Variable`.  This type
  requires a name and usually a list of channels.
- :code:`coefficient a` is a parameter and a vector of floats with a default value of {1.0}.  This
  variable is :math:`a_1` in the equation in the method section.  It must be the same size as the total number of
  variables in :code:`transform variable`.
- :code:`coefficient b` is a parameter and a vector of floats with a default value of {1.0}.  This
  variable is :math:`a_2` in the equation in the method section.  It must be the same size as the total number of
  variables in :code:`transform variable`.
- :code:`coefficient c` is a parameter and a vector of floats with a default value of {1.0}.  This
  variable is :math:`a_3` in the equation in the method section.  It must be the same size as the total number of
  variables in :code:`transform variable`.
- :code:`exponent a` is a parameter and an integer with a default value of 1.  This variable is :math:`b_1`
  in the equation in the method section. This exponent is applied to all variables in :code:`transform variable`.
  In the example below the same `exponent a` is used for emissivity_1 and emissivity_2.
- :code:`exponent b` is a parameter and an integer with a default value of 1.  This variable is :math:`b_2`
  in the equation in the method section. This exponent is applied to all variables in :code:`transform variable`.
  In the example below the same `exponent b` is used for emissivity_1 and emissivity_2.
- :code:`exponent c` is a parameter and an integer with a default value of 1.  This variable is :math:`b_3`
  in the equation in the method section. This exponent is applied to all variables in :code:`transform variable`.
  In the example below the same `exponent c` is used for emissivity_1 and emissivity_2.
- :code:`minimum value` is an optional parameter which defines the minimum acceptable value of the output
  :math:`var` in the equation in the method section. If an output value exceeds this limit the missing value indicator
  is the assigned value.
- :code:`maximum value` is an optional parameter which defines the maximum acceptable value of the output
  :math:`var` in the equation in the method section. If an output value exceeds this limit the missing value indicator
  is the assigned value.

**Example using all the available parameters**

.. code-block:: yaml

    - filter: Variable Transforms
      Transform: SatZenithAngleCorrection
      transform variable:
        name: DerivedObsValue/emissivity
        channels: 1,2
      coefficient a: [-3.60e-03, -2.38e-03]
      coefficient b: [ 2.21e-05,  2.15e-05]
      coefficient c: [-7.83e-09, -5.00e-09]
      exponent a: 0
      exponent b: 2
      exponent c: 4
      minimum value: 0.0
      maximum value: 1.0

If you have an observation with an input emissivity of 0.5 and a sensor zenith angle of 30.0, the above yaml would do the following calculation for channel 2:

.. math::

     var = 0.5 + (-2.38\times10^3\times30.0^0) + (2.15\times10^5\times30.0^2) + (-5.00\times10^9\times30.0^4)

.. math::

     var = 0.51292

**Method**

The input variable is updated using the following formula:

.. math::

     var = var + a_1\theta ^{b_1} + a_2\theta ^{b_2} + a_3\theta ^{b_3}

where:
  - :math:`var` is the input and output variable of interest.
  - :math:`a_n` is the :math:`n^{th}` coefficient used to multiple the zenith angle.
  - :math:`b_n` is the :math:`n^{th}` exponent of the zenith angle.
  - :math:`\theta` is the sensor viewing angle in degrees.

