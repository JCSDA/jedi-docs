
Absolute dynamic topography
---------------------------

Description:
^^^^^^^^^^^^
This UFO simulates absolute dynamic topography.
It re-references the model's sea surface height to the
observed absolute dynamic topography. The calculated offset is also handeld in the
linear model and its adjoint.
This forward operator currently does not handle eustatic sea level changes. This later feature will
be part of a future release.

Input variables:
^^^^^^^^^^^^^^^^

 - sea_surface_height_above_geoid

Examples of yaml:
^^^^^^^^^^^^^^^^^

.. code-block:: yaml

   obs space:
     name: ADT
     obsdatain:
       engine:
         type: H5File
         obsfile: Data/ufo/testinput_tier_1/Jason-2-2018-04-15.nc
     simulated variables: [absoluteDynamicTopography]
   obs operator:
     name: ADT

Cool skin
---------

Description:
^^^^^^^^^^^^

The cool skin UFO simulates the latent heat loss at the ocean surface given a bulk ocean surface temperature
and ocean-air fluxes.

Input variables:
^^^^^^^^^^^^^^^^

 - seaSurfaceTemperature
 - net_downwelling_shortwave_radiation
 - upward_latent_heat_flux_in_air
 - upward_sensible_heat_flux_in_air
 - net_downwelling_longwave_radiation
 - friction_velocity_over_water

Examples of yaml:
^^^^^^^^^^^^^^^^^

.. code-block:: yaml

   obs operator:
     name: CoolSkin
   obs space:
     name: CoolSkin
     obsdatain:
       engine:
         type: H5File
         obsfile: Data/ufo/testinput_tier_1/coolskin_fake_obs_2018041500.nc
     simulated variables: [seaSurfaceTemperature]


Insitu temperature
------------------

Description:
^^^^^^^^^^^^

This UFO uses the
`The Gibbs SeaWater (GSW) Oceanographic
Toolbox of TEOS-10 <https://www.teos-10.org/pubs/gsw/html/gsw_contents.html#1>`_
to simulate insitu temperature given sea water potential temperature, salinity and the
cell thicknesses.

Input variables:
^^^^^^^^^^^^^^^^

 - sea_water_potential_temperature
 - salinity
 - sea_water_cell_thickness

Examples of yaml:
^^^^^^^^^^^^^^^^^

.. code-block:: yaml

   obs operator:
     name: InsituTemperature
   obs space:
     name: InsituTemperature
     obsdatain:
       engine:
         type: H5File
         obsfile: Data/ufo/testinput_tier_1/profile_2018-04-15.nc
     simulated variables: [waterTemperature]

Vertical Interpolation
----------------------

Description:
^^^^^^^^^^^^

This UFO is an adaptation of ref :ref:`obsops_vertinterp` for the ocean. The only vertical coordinate currently
suported is depth in absolute value.

Examples of yaml:
^^^^^^^^^^^^^^^^^

.. code-block:: yaml


   obs operator:
     name: MarineVertInterp
     observation alias file: name_map.yaml
   obs space:
     name: InsituSalinity
     obsdatain:
       engine:
         type: H5File
         obsfile: Data/ufo/testinput_tier_1/profile_2018-04-15.nc
     simulated variables: [salinity]

Sea ice thickness
-----------------


Description:
^^^^^^^^^^^^
The sea ice thickness UFO can simulate sea ice freeboard
or sea ice thickness from categorized ice concentration, thickness and snow depth.

Input variables when simulating thickness:
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

 - sea_ice_category_area_fraction
 - sea_ice_category_thickness

Input variables when simulating freeboard:
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

 - sea_ice_category_area_fraction
 - sea_ice_category_thickness
 - sea_ice_category_snow_thickness

Examples of yaml:
^^^^^^^^^^^^^^^^^

.. code-block:: yaml

   observations:
     observers:
     - obs space:
         name: cryosat2_thickness
         obsdatain:
           engine:
             type: H5File
             obsfile: Data/ufo/testinput_tier_1/cryosat2-2018-04-15.nc
         simulated variables: [iceThickness]
       obs operator:
         name: SeaIceThickness

     - obs space:
         name: cryosat2_freeboard
         obsdatain:
           engine:
             type: H5File
             obsfile: Data/ufo/testinput_tier_1/cryosat2-2018-04-15.nc
         simulated variables: [seaIceFreeboard]
       obs operator:
         name: SeaIceThickness


Sea ice freeboard
-----------------

Description:
^^^^^^^^^^^^
The sea ice freeboard UFO simulates the freeboard measured by lidar (e.g. ICESat-2) or
radar (e.g. CryoSat-2) altimeters from the aggregate (single-category) sea ice and snow
thicknesses:

.. math::

   F = \alpha \, h_i + \beta \, h_s, \qquad \alpha = \frac{\rho_w - \rho_i}{\rho_w}

where :math:`h_i` and :math:`h_s` are the sea ice and snow thicknesses, and
:math:`\rho_i`, :math:`\rho_s` and :math:`\rho_w` are the sea ice, snow and seawater
densities. The :code:`instrument` option selects the snow coefficient :math:`\beta`:

 - :code:`lidar`: the return comes from the air/snow interface, so the operator simulates
   the total (ice + snow) freeboard, :math:`\beta = (\rho_w - \rho_s) / \rho_w`.
 - :code:`radar Ka`: Ka-band radar (e.g. SARAL/AltiKa) little penetration into snow,
   is treated the same as :code:`lidar` total (ice + snow) freeboard.
 - :code:`radar Ku`: Ku-band radar (e.g. CryoSat-2) is assumed to penetrate to the snow/ice
   interface, so the operator simulates the ice freeboard, :math:`\beta = -\rho_s / \rho_w`.

For the same ice and snow thicknesses, the total freeboard (:code:`lidar`, :code:`radar Ka`)
is larger than the ice freeboard (:code:`radar Ku`) by exactly :math:`h_s`.

Freeboard is a height measured over the ice, not a grid-cell mean. The input thicknesses
are per unit ice area, so no sea ice concentration weighting is applied. Freeboard is not
defined over open water. Screen out low-concentration locations with a filter, for
example a Domain Check on :code:`GeoVaLs/sea_ice_area_fraction`.

The operator is linear in :math:`h_i` and :math:`h_s`. Its tangent linear and adjoint use
the same coefficients. Locations where the trajectory thickness is missing are masked.
The operator throws an exception if the input thicknesses have more than one category,
or if the simulated variable is not :code:`seaIceFreeboard`.

Options:
^^^^^^^^

 - :code:`instrument`: :code:`lidar`, :code:`radar Ka` or :code:`radar Ku` (required).
 - :code:`sea ice density`: sea ice density in kg m\ :sup:`-3`, between 850 and 950 (required).
 - :code:`surface snow density`: snow density in kg m\ :sup:`-3`, between 50 and 450 (required).
 - :code:`sea water density`: seawater density in kg m\ :sup:`-3`, between 990 and 1035 (required).

Input variables:
^^^^^^^^^^^^^^^^

 - sea_ice_thickness
 - sea_ice_snow_thickness

Examples of yaml:
^^^^^^^^^^^^^^^^^

.. code-block:: yaml

   obs space:
     name: SeaIceFreeboard lidar
     obsdatain:
       engine:
         type: H5File
         obsfile: Data/ufo/testinput_tier_1/cryosat2-2018-04-15.nc
     simulated variables: [seaIceFreeboard]
   obs operator:
     name: SeaIceFreeboard
     instrument: lidar
     sea ice density: 917.0
     surface snow density: 330.0
     sea water density: 1026.0
   linear obs operator:
     name: SeaIceFreeboard
     instrument: lidar
     sea ice density: 917.0
     surface snow density: 330.0
     sea water density: 1026.0


Sea ice fraction
----------------

Description:
^^^^^^^^^^^^
The sea ice fraction UFO returns the aggregate of the input sea ice categories.

Input variables:
^^^^^^^^^^^^^^^^

 - sea_ice_category_area_fraction

Examples of yaml:
^^^^^^^^^^^^^^^^^

.. code-block:: yaml

   obs operator:
     name: SeaIceFraction
   linear obs operator:
     name: SeaIceFraction
   obs space:
     name: SeaIceFraction
     obsdatain:
       engine:
         type: H5File
         obsfile: Data/ufo/testinput_tier_1/icec-2018-04-15.nc
     simulated variables: [seaIceFraction]
