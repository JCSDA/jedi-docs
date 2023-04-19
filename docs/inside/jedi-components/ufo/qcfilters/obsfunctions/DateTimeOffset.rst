.. _DateTimeOffset:

DateTimeOffset
==============

The :code:`DateTimeOffset` ObsFunction can be used to add an offset to the variable :code:`MetaData/dateTime` and save the result to a new variable.
The offset variable is obtained from the ObsSpace and can have units of seconds, minutes or hours.
This ObsFunction should typically be used in conjunction with the Variable Assignment filter as shown in the example below.
If a Variable Assignment is used to set :code:`DerivedMetaData/dateTime` at the pre-filter stage, that variable will be used as the observation time
when generating the GeoVaLs and in any subsequent processing.

If the :code:`keep in window` option is selected, then observations will be forced
to remain within the DA window if they have an offset applied. If a computed
date-time is outside one of the window boundaries, it is set equal to the
date-time at that boundary. Since observations at the start of the window are
rejected, one second is added to the observation time for observations at the
start of the window. This ensures that no observations are lost through the
process of offsetting, but assumes that only observations which "should" be
within the DA window are passed to this routine (which is true within JEDI).

Parameters
----------

- :code:`offset variable name`: Name of the offset variable.

- :code:`offset unit`: Name of the offset unit. Valid options: seconds, minutes, hours.

- :code:`keep in window`: Boolean, default false: if true then the observations will be forced to remain inside the DA window.

Example yaml
------------

.. code-block:: yaml

  - filter: Variable Assignment
    assignments:
    - name: DerivedMetaData/dateTime
      type: datetime
      function:
        name: DateTimeObsFunction/DateTimeOffset
        options:
          offset variable name: MetaData/time_offset
          offset unit: seconds
          keep in window: false

Example behaviour with :code:`keep in window`
---------------------------------------------

Imagine that you have a group of observations with these times and offsets (for
simplicity they are all the same date):

====== ======== ======== ======== ======== ======== ======== ========
Time   09:03:00 11:20:00 12:00:00 12:00:00 13:30:00 14:30:00 14:58:00
Offset -0:05:00  0:10:00  0:10:00 -0:10:00  0:30:00  0:29:00  0:10:00
====== ======== ======== ======== ======== ======== ======== ========

If the DA window runs from 09:00 to 15:00, then some of these observations would
end up outside this window and be rejected.  The :code:`DateTimeOffset` function
would yield the following results, with and without the :code:`keep in window`
option:

============== ============ ======== ======== ======== ======== ======== ============
Keep in window
============== ============ ======== ======== ======== ======== ======== ============
false            08:58:00   11:30:00 12:10:00 11:50:00 14:00:00 14:59:00   15:08:00
true           **09:00:01** 11:30:00 12:10:00 11:50:00 14:00:00 14:59:00 **15:00:00**
============== ============ ======== ======== ======== ======== ======== ============

