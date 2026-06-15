.. _duplicatevariables:

Duplicate Variables: Outer saber block to copy specific grouped fields to component variables
=============================================================================================

Example yaml
~~~~~~~~~~~~

.. code-block:: yaml
 
  saber outer blocks:
  - (...)
  - saber block name: duplicate variables
    variable groupings:
    - group variable name: group_name_1
      group components:
      - component_name_1_1
      - component_name_1_2
      - component_name_1_3
    - group variable name: group_name_2
      group components:
      - component_name_2_1
      - component_name_2_2

Explaining the yaml
-------------------

In the yaml example above we have created two variable groups. The specific names `group_name_*` and `component_name_*` are just chosen for the example and are purely arbitrary. One restriction is that all the names are unique so that the groups are disjoint.

Variables that exist in the fieldset at the time are considered passive and copied to inner blocks.

In the `multiply` method of the outer block the field associated with each group name is deep copied into its group components. It is expected that the input fieldset entering the `multiply` method does not have any fields with names from the group components name list.  The fields with the group names are removed from the fieldset.

The `multiplyAD` operation first allocates space for each group name based on the dimensions of the first component in its group. It then places the sum of the values of each component into each grouped variable. For this to work it is assumed that the component fields have the same dimension and size as the group-named field.  The fields associated with the component field names are then removed from the fieldset.

Use case
--------
One scientific use case is to apply this saber block to remove inter-variable localization.

