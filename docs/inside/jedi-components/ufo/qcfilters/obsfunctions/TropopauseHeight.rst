.. _TropopauseHeight:

TropopauseHeight
================

This ObsFunction calculates the height of the tropopause based on model (GeoVaLs) fields, then outputs an integer value model level which corresponds to the level nearest the calculated tropopause height.
Required input parameters include the GeoVaLs names of model pressure, specific humidity, and temperature.
Several optional inputs control the maximum and minimum tropospheric pressure used in the calculation, as well as the relative humidity of the troposphere.
These each have generic default values but it is recommended that users consider altering these default values.

Two methods for calculating the tropopause height exist in this routine.
The first method, which is used by default, calculates the tropopause lapse rate in terms of log(pressure) coordinates and compares that to the WMO definition of tropopause lapse rate.
Once the calculated lapse falls below the WMO definition, and provided the pressure at this level is between the optionally defined tropopause maximum and minimum pressures, the tropopause level is set.

If the first method fails, the second method is called.
This method first calculates the relative humidity at each level.
It then loops down through the atmosphere and at each level, compares the relative humidity to the user-defined relative humidity at the tropopause.
If either relative humidity rises above the tropopause value, or if the pressure at that level exceeds the maximum pressure of the tropopause, the tropopause level is set.
There exists a boolean input which forces the use of the second, relative-humidity based method.

Required Parameters
^^^^^^^^^^^^^^^^^^^

:code:`model pressure` - GeoVaLs name of air pressure at each model level. Usually :code:`air_pressure`.

:code:`model specific humidity` - GeoVaLs name of specific humidity at each model level. Usually :code:`water_vapor_mixing_ratio_wrt_moist_air`.

:code:`model temperature` - GeoVaLs name of air temperature at each model level. Usually :code:`air_temperature`.

Parameters
^^^^^^^^^^

:code:`tropopause maximum pressure` - float value (default 100000.0 Pa) to set the upper pressure bounding limit for tropopause height.

:code:`tropopause minimum pressure` - float value (default 100.0 Pa) to set the lower pressure bounding limit for tropopause height.

:code:`tropopause relative humidity` - float value (default 0.5) to set the expected relative humidity of the tropopause, used in the second method.

:code:`rhmethod` - boolean (default false) to force use of the relative humidity method for calculating tropopause height.

Example 1
^^^^^^^^^

The following example is the most basic use of this ObsFunction, as part of a :code:`Variable Assignment` filter.
This sets the required parameter names of the GeoVaLs but uses the default values of maximum and minimum tropopause pressure and relative humidity.
Output into the obs space is placed into the variable :code:`MetaData/tropopauseLevel`.
Note the use of :code:`IntObsFunction` in the call to this ObsFunction.

.. code-block:: yaml

    - filter: Variable Assignment
      assignments:
        - name: MetaData/tropopauseLevel
          type: int
          function:
            name: IntObsFunction/TropopauseHeight
            options:
              model pressure: air_pressure
              model specific humidity: water_vapor_mixing_ratio_wrt_moist_air
              model temperature: air_temperature


Example 2
^^^^^^^^^

This example makes use of the input parameters to allow the user to set maximum and minimum tropopause pressure and relative humidity.

.. code-block:: yaml

    - filter: Variable Assignment
      assignments:
        - name: MetaData/tropopauseLevel
          type: int
          function:
            name: IntObsFunction/TropopauseHeight
            options:
              model pressure: air_pressure
              model specific humidity: water_vapor_mixing_ratio_wrt_moist_air
              model temperature: air_temperature
              tropopause maximum pressure: 60000.0
              tropopause minimum pressure: 5000.0
              tropopause relative humidity: 0.3

Example 3
^^^^^^^^^

This final example forces the use of the relative humidity method for all locations, overriding the default method of using the tropopause lapse rate.
Due to this, the only relevant input parameter which can be altered by the user is the tropopause relative humidity.

.. code-block:: yaml

    - filter: Variable Assignment
      assignments:
        - name: MetaData/tropopauseLevel
          type: int
          function:
            name: IntObsFunction/TropopauseHeight
            options:
              model pressure: air_pressure
              model specific humidity: water_vapor_mixing_ratio_wrt_moist_air
              model temperature: air_temperature
              tropopause relative humidity: 0.3
              rhmethod: true
