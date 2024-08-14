.. _RecordNumberToObsSpace:

RecordNumberToObsSpace
----------------------

If the ObsSpace is grouped into records, each record is assigned a unique numerical identifier
in the ioda code. The `RecordNumberToObsSpace` ObsFunction can be used to write out this identifier
for use as a variable in ufo.

If the ObsSpace has not been divided into records, attempting to use this ObsFunction
will cause an exception to be thrown.

Example
~~~~~~~

This example assigns the internal record number to the variable :code:`MetaData/sequenceNumber`.

.. code-block:: yaml

  - filter: Variable Assignment
    assignments:
    - name: MetaData/sequenceNumber
      type: int
      function:
        name: IntObsFunction/RecordNumberToObsSpace
