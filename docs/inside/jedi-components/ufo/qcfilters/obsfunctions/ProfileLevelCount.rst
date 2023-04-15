.. _ProfileLevelCount:

ProfileLevelCount
-----------------

Count the number of levels in each profile (subject to conditions in the :ref:`where <where-statement>` clause).

This ObsFunction can be used for samples that have been divided into profiles (records).
(If that is not the case, an exception will be thrown.)
The number of locations in each profile that pass the :code:`where` clause associated
with this function is computed. The number is then assigned to all members of that record in the output vector.

The default behaviour of the ProfileLevelCount ObsFunction is to count locations even when values are missing or
QC flags are not equal to :code:`pass` for some variables.
The user therefore needs to specify additional selections on such values if desired.

Note that the :code:`where` clause associated with the governing filter (e.g. Variable Assignment)
can be used to control which locations are assigned the count.

The :code:`where operator` parameter can be used to specify the logical operator which combines conditions
that appear in the :code:`where` statement. The possible values are :code:`and` (the default) and :code:`or`.
Note that it is possible to use the :code:`where operator` option without the :code:`where` statement. The option has no impact in that case.

Documentation on profile-specific QC filters can be found :ref:`here <profilespecificqc>`.

Example
~~~~~~~

.. code-block:: yaml

  - filter: Variable Assignment
    where:
    - variable:
        name: MetaData/fill
      is_in: 2
    assignments:
    - name: DerivedMetaData/number_of_levels
      type: int
      function:
        name: IntObsFunction/ProfileLevelCount
        options:
          where:
          - variable:
              name: MetaData/apply
            is_in: 1

In this example, the Variable Assignment filter is used in combination with the Profile Level Count
ObsFunction to count the number of locations in each profile with :code:`MetaData/apply` equal to 1.
The count is assigned to the variable :code:`DerivedMetaData/number_of_levels` in the profile for all
locations at which :code:`MetaData/fill` is equal to 2.
