.. _DateTimeOffset:

DateTimeOffset
==============

The :code:`DateTimeOffset` ObsFunction can be used to add an offset to the variable :code:`MetaData/dateTime` and save the result to a new variable.
The offset variable is obtained from the ObsSpace and can have units of seconds, minutes or hours.
This ObsFunction should typically be used in conjunction with the Variable Assignment filter as shown in the example below.
If a Variable Assignment is used to set :code:`DerivedMetaData/dateTime` at the pre-filter stage, that variable will be used as the observation time
when generating the GeoVaLs and in any subsequent processing.

Parameters
----------

- :code:`offset variable name`: Name of the offset variable.

- :code:`offset unit`: Name of the offset unit. Valid options: seconds, minutes, hours.

Example yaml
------------

.. code-block:: yaml

  - filter: Variable Assignment
    assignments:
    - name: DerivedMetaData/dateTime
      type: datetime
      function:
        name: DateTimeOffset@DateTimeObsFunction
        options:
          offset variable name: MetaData/time_offset
          offset unit: seconds
