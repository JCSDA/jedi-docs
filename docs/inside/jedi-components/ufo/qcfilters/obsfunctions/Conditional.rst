.. _Conditional:

Conditional
-----------------------------------------------------------------------

Creates an array with values specified by a series of where statements.

The obs function was designed to work with the :ref:`variable assignment filter <VariableAssignmentFilter>`
to simplify the assignment of more complicated variables.  However, the obs function can be used with any filter
which takes an obs function as an argument.  Any functionality in the
:ref:`Where <where-statement>` statements can be used with this obs function.

This is a templated function which can be used to produce different types of output arrays:
 * `Conditional@ObsFunction` produces floats
 * `Conditional@IntObsFunction` produces ints
 * `Conditional@StringObsFunction` produces strings
 * `Conditional@DateTimeObsFunction` produces datetimes.

Input parameters:
~~~~~~~~~~~~~~~~~~~~~~~~~~

cases (required; can take as many case statements as required)
  A list of one or more individual cases. Each case contains a "where" statement and a "value" to assign should the where clause evaluate to true.
  Like all where clauses in ufo this can have multiple arguments, see the examples below.
defaultvalue (optional)
  A default value to assign to the output array at the beginning of the processing.  This is optional and
  if the value is not present the array will be initialised with missing data.
firstmatchingcase (optional with default value = true)
  A boolean to determine whether the first or last matching case should be the value assigned.  If true then
  the first matching case is assigned which is analogous to the python case logic and is the default behaviour.
  If this is false the value can be changed multiple times as each case is processed leading to the final
  matching case being the assigned value.


Example configuration:
~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: yaml

    function:
      name: Conditional@ObsFunction
      options:
        defaultvalue: 9.0
        firstmatchingcase: true
        cases:
        - where:
          - variable:
              name: float_variable_1@MetaData
            minvalue: 4
          - variable:
              name: float_variable_2@MetaData
            minvalue: -11.75
          value: 75.5
        - where:
          - variable:
              name: int_variable_1@MetaData
            is_in: 1
          value: 3.0

In the above example, the return value of the obs function is initialised to 9.0.  The first case tests where :code:`float_variable_1@MetaData`
has a minimum value of 4.0 and also where :code:`float_variable_2@MetaData` has a minimum value of -11.75, assigning a return value of 75.5 if
these where clauses both evaluate to true. Since firstmatchingcase is set to true, these values are not overwritten by subsequent cases.
The second case tests where :code:`int_variable_1@MetaData` is equal to 1 and if so assigns a return value of 3.0.

For further examples see the unit test yaml in ufo which can be found `here <https://github.com/JCSDA-internal/ufo/blob/develop/test/testinput/unit_tests/function_conditional.yaml>`_.
