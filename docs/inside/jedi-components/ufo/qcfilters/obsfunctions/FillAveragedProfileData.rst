.. _FillAveragedProfileData:

FillAveragedProfileData
-----------------------

When processing atmospheric profile data, the ObsSpace is extended in order to enable reported profiles to be averaged onto model levels before they are sent to the data
assimilation. During the ObsSpace extension procedure, selected MetaData variables are initialised to the first entry in the corresponding observed profile. This ObsFunction enables a more accurate transfer of values by following the slanted path of the ascent. The SlantPathLocation algorithm is used to do that; it determines the locations in the original profile that correspond to the intersections of the ascent with each model level. Those locations are used to copy values across to the averaged profile.

Parameters
----------

- :code:`variable to copy`: Name of the variable to be copied from the original to the averaged profiles.

- :code:`observation vertical coordinate`: Name of the observation vertical coordinate.

- :code:`model vertical coordinate`: Name of the model vertical coordinate.

- :code:`number of intersection iterations`: Number of iterations that are used to find the intersection between the observed profile and each model level. Default value: 3.

Example yaml
------------

.. code-block:: yaml

  - filter: Variable Assignment
    assignments:
      - name: MetaData/latitude
        type: float
        function:
          name: ObsFunction/FillAveragedProfileData
          options:
            variable to copy: MetaData/latitude
            observation vertical coordinate: MetaData/pressure
            model vertical coordinate: air_pressure_levels
