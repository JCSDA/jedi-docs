
.. _remapscanposition_v1:

=======================
Satellite scan position
=======================
Satellite scan lines are often resampled as part of the pre-processing.  This is usual to
reduce the number of observations processed but can be because averaging is applied over
multiple fields of view to reduce the observation noise.  In most processing it is
neccessary to have scan positions which are increasing by one across the scan line.

:code:`Transform: RemapScanPosition`

.. code-block:: yaml

    - filter: Variable Transforms
      Transform: RemapScanPosition
    
**Parameters**

This transform requires the following variable:

- sensor scan position (:code:`MetaData/sensorScanPosition`)

There is one optional parameter that can be used with this variable transform and that is 
:code:`number of fields of view` which has a default value of 3. The :code:`number of fields of view` specifies
the denominator when calculating the remapped scan position.  See the method section below for details
of how this is applied.

An example with IASI data where a value of 4 is used for the :code:`number of fields of view` and the
valid data only flag from the base class is used is shown below.

.. code-block:: yaml

    - filter: Variable Transforms
      Transform: RemapScanPosition
      UseValidDataOnly: true
      number of fields of view: 4

**Method**

The updated scan position (:code:`scan_position_new`) is calculated using the following calculation.

    :code:`scan_position_new` = round down (:code:`sensorScanPosition` / :code:`number of fields of view`)

where the the part in brackets is treated as floating point division which is then rounded down to the
nearest integer value.  :code:`scan_position_new` is written back to :code:`MetaData/sensorScanPosition`.
