
.. _VT-Logarithm:

=========
Logarithm
=========
Takes the logarithm of a variable, with a chosen base, and stores the result in the same obs space:

.. math::

    v_\text{log} = \log_{n}(v)

where :math:`v_\text{log}` is the transformed variable, :math:`v` is the original variable and :math:`n` is the base of the logarithm.

The group and name of the new variable can, optionally, be specified.
Where the group is not specified, the derived version of the input group name is used.

---------------------
Additional Parameters
---------------------

This transform has the following parameters:

 - **variable**: the name of the variable to be transformed.
 - **group**: the name of the group in which the variable to be transformed is found.
 - **base**: [*Optional*] the base of the logarithm to be taken. Default is :math:`e` (natural logarithm).
 - **output variable**: [*Optional*] the name of the transformed variable. If this does not exist it will be created.
 - **output group**: [*Optional*] the name of the group in which the transformed variable is to be stored. If this does not exist it will be created.

Note that the :code:`Method` and :code:`Formulation` parameters have no effect on this transform.
Since the variable to act on must be specified, there are no required variables for this transform.

---------------------------
Invalid logarithm behaviour
---------------------------

If this variable transform encounters an input which is either missing or not a positive number, the output will be missing.

-------------------
Example yaml blocks
-------------------

**No output variable or group specified**:

.. code-block:: yaml

    obs filters:
    - filter: Variable Transforms
      Transform: Logarithm
      variable: airTemperature
      group: ObsValue

This will take the natural logarithm of :code:`ObsValue/airTemperature` and store the result in :code:`DerivedObsValue/airTemperature`.

**Output variable specified, but no output group**:

.. code-block:: yaml

    obs filters:
    - filter: Variable Transforms
      Transform: Logarithm
      variable: height
      group: MetaData
      base: 10
      output variable: logHeight

This will take the base 10 logarithm of :code:`MetaData/height` and store the result in :code:`DerivedMetaData/logHeight`.

**Output variable and group specified**:

.. code-block:: yaml

    obs filters:
    - filter: Variable Transforms
      Transform: Logarithm
      variable: airTemperature
      group: ObsValue
      base: 1.5
      output variable: airTemperature_log
      output group: SomeGroup

This will take the base 1.5 logarithm of :code:`ObsValue/airTemperature` and store the result in :code:`SomeGroup/airTemperature_log`.
