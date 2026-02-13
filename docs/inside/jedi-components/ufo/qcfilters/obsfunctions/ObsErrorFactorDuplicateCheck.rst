.. _ObsErrorFactorDuplicateCheck:

ObsErrorFactorDuplicateCheck
============================

This ``obsFunction`` identifies observations at duplicate locations (matching latitude and longitude, and optionally pressure) within a specified time window. When duplicates are found, the observation error is inflated to account for the redundant information.

The inflation factor is determined by the temporal proximity of the duplicates and a user-defined ``duplicate_retention_weight`` (:math:`w`). This weight ranges from 0 to 1:

* **0**: Maximum inflation (minimum retention of the duplicate's value).
* **1**: No inflation (duplicates are treated as independent information).

Mathematical Formulation
------------------------

For each duplicate observation found within the window, a temporal factor :math:`t_{fact}` is calculated:

.. math::

   t_{fact} = \min \left( 1, \frac{|\Delta t|}{T_{window}} \right)

Where :math:`|\Delta t|` is the time difference between the current and reference observation, and :math:`T_{window}` is the total time window in hours. The cumulative duplicate penalty :math:`D` is updated for each match:

.. math::

   D_{new} = D_{old} + 1 - t_{fact}^2 (1 - w)

After checking all potential duplicates, if :math:`D > 1`, the final multiplicative inflation factor applied to the observation error is:

.. math::

   f_{multiplier} = \sqrt{D}

Required input parameter:
~~~~~~~~~~~~~~~~~~~~~~~~~

inflation variable
  Variable to be inflated. It can include multiple variables if this obsFunction is used independently.
  If this obsFunction is used as part of a QC filter, it can only include one variable for each use.

Optional input parameters:
~~~~~~~~~~~~~~~~~~~~~~~~~~

use_air_pressure
  Duplicate checking is done by the same latitude and longitude and additionally air_pressure. Default is false.

time_window_hours
  A time window in hours where an observation less than this value will be counted as a duplicate. Default is 3 hours.

duplicate_retention_weight
  A weight between 0 and 1 where higher values do smaller error inflation and lower values do greater inflation. Default is 0.75.

Example configurations:
~~~~~~~~~~~~~~~~~~~~~~~

Here is an example to use this obsFunction to inflate observation errors of windEastward:

.. code-block:: yaml

  - filter: Perform Action
    filter variables:
    - name: windEastward
    where:
    - variable:
        name: ObsType/windEastward
    action:
      name: inflate error
      inflation variable:
        name: ObsFunction/ObsErrorFactorDuplicateCheck
        options:
          variable: windEastward
          time_window_hours: 12
          duplicate_retention_weight: 0.25

