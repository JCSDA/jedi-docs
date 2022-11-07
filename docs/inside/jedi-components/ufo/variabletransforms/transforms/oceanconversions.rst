.. _VT-OceanDepthToPressure:

================================================
Ocean Pressure
================================================
Converts depth (m) to pressure (dbar). The newly calculated variable is included in the same obs space. Note that this requires GSW-Fortran to be included in your build.

--------------
Variables used
--------------

- Depth (m), from 0 at surface, increasing positively with depth.
- Latitude (deg).

---------------
Output Variable
---------------

- Pressure (dbar). The corresponding :code:`ObsError` is set to 1.0 (the user should :ref:`Perform Action: Assign Error <filter-actions>` if something different is required), :code:`QCFlags` are set to 0, and :code:`GrossErrorProbability` initialised to all missing.

----------
Parameters
----------

- ``ocean depth variable``: Depth coordinate name (default :code:`ocean_depth`).
- ``ocean depth group``: Depth coordinate group (default :code:`MetaData`).
- ``ocean pressure name``: Output pressure coordinate name (default :code:`ocean_pressure`; created in group :code:`DerivedObsValue`).

------------------
Example yaml block
------------------

.. code-block:: yaml

    obs filters:
    - filter: Variable Transforms
      Transform: "OceanDepthToPressure"
      ocean depth group: "DerivedObsValue"
      ocean depth variable: "ocean_depth"
      ocean pressure name: "ocean_pressure"


------
Method
------

Currently the only method used is from the TEOS-10 GSW toolbox, `gsw_p_from_z <https://www.teos-10.org/pubs/gsw/html/gsw_p_from_z.html>`__. Here we assume the dynamic height anomaly and sea surface geopotential are both zero.


.. _VT-OceanTempToTheta:

==========================================
Ocean Potential Temperature
==========================================
Converts temperature (deg.C), salinity (g/kg) and pressure (dbar), into potential temperature (deg.C). The newly calculated variable is included in the same obs space. Note that this requires GSW-Fortran to be included in your build.

--------------
Variables used
--------------

- Absolute salinity (g/kg).
- In situ temperature (deg.C).
- Pressure (dbar).

---------------
Output Variable
---------------

- Potential temperature (deg.C), i.e. the temperature that a water parcel would have if moved adiabatically from the given pressure to the reference pressure (zero in this case, i.e. the surface). The corresponding :code:`ObsError`, :code:`GrossErrorProbability` and :code:`QCFlags` are the same as those of the input temperature variable.

----------
Parameters
----------
- ``ocean salinity variable``: Salinity variable name (default :code:`ocean_salinity`).
- ``ocean salinity group``: Salinity variable group (default :code:`ObsValue`).
- ``ocean temperature variable``: Temperature variable name (default :code:`ocean_temperature`).
- ``ocean temperature group``: Temperature variable group (default :code:`ObsValue`).
- ``ocean pressure variable``: Pressure variable name (default :code:`ocean_pressure`).
- ``ocean pressure group``: Pressure variable group (default :code:`ObsValue` - note that it will be :code:`DerivedObsValue` if created using ``OceanDepthToPressure``).
- ``ocean potential temperature name``: variable name of output (default :code:`ocean_potential_temperature`; created in group :code:`DerivedObsValue`).

------------------
Example yaml block
------------------

.. code-block:: yaml

    obs filters:
    - filter: Variable Transforms
      Transform: "OceanTempToTheta"
      ocean pressure group: "DerivedObsValue"


------
Method
------

Currently the only method used is from the TEOS-10 GSW toolbox, `gsw_pt_from_t <https://www.teos-10.org/pubs/gsw/html/gsw_pt_from_t.html>`__. Here we assume the reference pressure is zero.


.. _VT-OceanDensity:

=====================================================
Ocean Density
=====================================================
Converts temperature (deg.C), salinity (g/kg) and pressure (dbar), into density (kg/m^3). The newly calculated variable is included in the same obs space. Note that this requires GSW-Fortran to be included in your build.

--------------
Variables used
--------------

- Absolute salinity (g/kg).
- In situ temperature (deg.C).
- Pressure (dbar).

---------------
Output Variable
---------------

- Density (kg/m^3) - absolute rather than anomaly, i.e. 1000 kg/m^3 is not subtracted from it. The corresponding :code:`ObsError` is set to 1.0 (the user should :ref:`Perform Action: Assign Error <filter-actions>` if something different is required), :code:`QCFlags` are set to 0, and :code:`GrossErrorProbability` initialised to all missing.

----------
Parameters
----------
- ``ocean salinity variable``: Salinity variable name (default :code:`ocean_salinity`).
- ``ocean salinity group``: Salinity variable group (default :code:`ObsValue`).
- ``ocean temperature variable``: Temperature variable name (default :code:`ocean_temperature`).
- ``ocean temperature group``: Temperature variable group (default :code:`ObsValue`).
- ``ocean pressure variable``: Pressure variable name (default :code:`ocean_pressure`).
- ``ocean pressure group``: Pressure variable group (default :code:`ObsValue` - note that it will be :code:`DerivedObsValue` if created using ``OceanDepthToPressure``).
- ``ocean density variable``: variable name of output (default :code:`ocean_density`; created in group :code:`DerivedObsValue`).

------------------
Example yaml block
------------------

.. code-block:: yaml

    obs filters:
    - filter: Variable Transforms
      Transform: "OceanDensity"
      ocean pressure group: "DerivedObsValue"


------
Method
------

Currently the only method used is from the TEOS-10 GSW toolbox, `gsw_rho_t_exact <https://www.teos-10.org/pubs/gsw/html/gsw_rho_t_exact.html>`__.
