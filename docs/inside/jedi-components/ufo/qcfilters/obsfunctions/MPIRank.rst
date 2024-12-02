.. _MPIRank:

MPIRank
-------

This ObsFunction writes the MPI rank that stores each ObsSpace location to the output variable.

For non-overlapping ObsSpace distributions such as the :code:`Round Robin`, there is an unambiguous rank that stores each location.

For overlapping ObsSpace distributions such as the :code:`InefficientDistribution`, the rank associated with the observation 'patch'
at a given location is used.
The rank of the observation patch is always unique for each location; for example, the :code:`InefficientDistribution`
has a patch rank of 0 for all locations. Further details can be found in the source code for each distribution.

There are no configurable parameters for this ObsFunction.


Example
~~~~~~~

This example shows how the ObsFunction can be used to save the rank of each location to a variable called :code:`MetaData/MPIRank`:

.. code-block:: yaml

  - filter: Variable Assignment
    assignments:
    - name: MetaData/MPIRank
      type: int
      function:
        name: IntObsFunction/MPIRank
