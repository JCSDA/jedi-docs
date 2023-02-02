.. _VT-OceanPracticalSalinityToAbsoluteSalinity:

==========================================
Ocean Absolute Salinity
==========================================
Converts practical salinity into absolute salinity (g/kg). The newly calculated variable is included in the same obs space. Note that this requires GSW-Fortran to be included in your build.

--------------
Variables used
--------------

- Practical salinity.
- Pressure (dbar).

---------------
Output Variable
---------------

- Absolute Salinity (g/kg). The corresponding :code:`ObsError`, :code:`GrossErrorProbability` and :code:`QCFlags` are the same as those of the input salinity variable.

----------
Parameters
----------
- ``ocean salinity variable``: Practical salinity variable name (default :code:`salinity`).
- ``ocean salinity group``: Practical salinity variable group (default :code:`ObsValue`).
- ``ocean pressure variable``: Pressure variable name (default :code:`waterPressure`).
- ``ocean pressure group``: Pressure variable group (default :code:`ObsValue` - note that it will be :code:`DerivedObsValue` if created using ``OceanDepthToPressure``).
- ``ocean absolute salinity name``: Variable name of output (default :code:`absoluteSalinity`; created in group :code:`DerivedObsValue`).

------------------
Example yaml block
------------------

.. code-block:: yaml

    obs filters:
    - filter: Variable Transforms
      Transform: "OceanPracticalSalinityToAbsoluteSalinity"
      ocean pressure group: "DerivedObsValue"


------
Method
------

Currently the only method used is from the TEOS-10 GSW toolbox, `gsw_SA_from_SP <https://www.teos-10.org/pubs/gsw/html/gsw_SA_from_SP.html>`__. 

.. _VT-OceanTempToConservativeTemp:

==========================================
Ocean Conservative Temperature
==========================================
Converts in situ temperature (deg.C), absolute salinity (g/kg) and pressure (dbar) into conservative temperature (deg.C). The newly calculated variable is included in the same obs space. Note that this requires GSW-Fortran to be included in your build.

--------------
Variables used
--------------

- Absolute salinity (g/kg).
- In situ temperature (deg.C).
- Pressure (dbar).

---------------
Output Variable
---------------

- Conservative temperature (deg.C). The corresponding :code:`ObsError`, :code:`GrossErrorProbability` and :code:`QCFlags` are the same as those of the input temperature variable.

----------
Parameters
----------
- ``ocean salinity variable``: Salinity variable name (default :code:`absoluteSalinity`).
- ``ocean salinity group``: Salinity variable group (default :code:`ObsValue` - note that it will be :code:`DerivedObsValue` if created using ``OceanPracticalSalinityToAbsoluteSalinity``).
- ``ocean temperature variable``: Temperature variable name (default :code:`waterTemperature`).
- ``ocean temperature group``: Temperature variable group (default :code:`ObsValue`).
- ``ocean pressure variable``: Pressure variable name (default :code:`waterPressure`).
- ``ocean pressure group``: Pressure variable group (default :code:`ObsValue` - note that it will be :code:`DerivedObsValue` if created using ``OceanDepthToPressure``).
- ``ocean conservative temperature name``: Variable name of output (default :code:`waterConservativeTemperature`; created in group :code:`DerivedObsValue`).

------------------
Example yaml block
------------------

.. code-block:: yaml

    obs filters:
    - filter: Variable Transforms
      Transform: "OceanTempToConservativeTemp"
      ocean pressure group: "DerivedObsValue"


------
Method
------

Currently the only method used is from the TEOS-10 GSW toolbox, `gsw_CT_from_t <https://www.teos-10.org/pubs/gsw/html/gsw_CT_from_t.html>`__. 

.. _VT-OceanDensity:

=====================================================
Ocean Density
=====================================================
Converts in situ temperature (deg.C), absolute salinity (g/kg) and pressure (dbar) into density (kg/m^3). The newly calculated variable is included in the same obs space. Note that this requires GSW-Fortran to be included in your build.

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
- ``ocean salinity variable``: Salinity variable name (default :code:`absoluteSalinity`).
- ``ocean salinity group``: Salinity variable group (default :code:`ObsValue` - note that it will be :code:`DerivedObsValue` if created using ``OceanPracticalSalinityToAbsoluteSalinity``).
- ``ocean temperature variable``: Temperature variable name (default :code:`waterTemperature`).
- ``ocean temperature group``: Temperature variable group (default :code:`ObsValue`).
- ``ocean pressure variable``: Pressure variable name (default :code:`waterPressure`).
- ``ocean pressure group``: Pressure variable group (default :code:`ObsValue` - note that it will be :code:`DerivedObsValue` if created using ``OceanDepthToPressure``).
- ``ocean density variable``: Variable name of output (default :code:`waterDensity`; created in group :code:`DerivedObsValue`).

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

.. _VT-OceanTempToTheta:

==========================================
Ocean Potential Temperature
==========================================
Converts in situ temperature (deg.C), absolute salinity (g/kg) and pressure (dbar) into potential temperature (deg.C). The newly calculated variable is included in the same obs space. Note that this requires GSW-Fortran to be included in your build.

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
- ``ocean salinity variable``: Salinity variable name (default :code:`absoluteSalinity`).
- ``ocean salinity group``: Salinity variable group (default :code:`ObsValue` - note that it will be :code:`DerivedObsValue` if created using ``OceanPracticalSalinityToAbsoluteSalinity``).
- ``ocean temperature variable``: Temperature variable name (default :code:`waterTemperature`).
- ``ocean temperature group``: Temperature variable group (default :code:`ObsValue`).
- ``ocean pressure variable``: Pressure variable name (default :code:`waterPressure`).
- ``ocean pressure group``: Pressure variable group (default :code:`ObsValue` - note that it will be :code:`DerivedObsValue` if created using ``OceanDepthToPressure``).
- ``ocean potential temperature name``: Variable name of output (default :code:`waterPotentialTemperature`; created in group :code:`DerivedObsValue`).

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

- ``ocean depth variable``: Depth coordinate name (default :code:`depthBelowWaterSurface`).
- ``ocean depth group``: Depth coordinate group (default :code:`MetaData`).
- ``ocean pressure name``: Output pressure coordinate name (default :code:`waterPressure`; created in group :code:`DerivedObsValue`).

------------------
Example yaml block
------------------

.. code-block:: yaml

    obs filters:
    - filter: Variable Transforms
      Transform: "OceanDepthToPressure"
      ocean depth group: "DerivedObsValue"
      ocean depth variable: "depthBelowWaterSurface"
      ocean pressure name: "waterPressure"


------
Method
------

Currently the only method used is from the TEOS-10 GSW toolbox, `gsw_p_from_z <https://www.teos-10.org/pubs/gsw/html/gsw_p_from_z.html>`__. Here we assume the dynamic height anomaly and sea surface geopotential are both zero.


