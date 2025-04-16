.. _top-vader-recipe-dryairdensitylevelsminusonea:

Dry air density levels minus one from virtual potential temperature and pressure
================================================================================

* **Description**: Produces dry air density from height, virtual potential temperature, and pressure
* **Name**: DryAirDensityLevelsMinusOne_A
* **Variable produced**: dry_air_density_levels_minus_one
* **Input Variables**: height_above_mean_sea_level, height_above_mean_sea_level_levels, air_potential_temperature, cloud_liquid_water_mixing_ratio_wrt_moist_air_and_condensed_water, cloud_ice_mixing_ratio_wrt_moist_air_and_condensed_water, water_vapor_mixing_ratio_wrt_moist_air_and_condensed_water, air_pressure_levels_minus_one
* **Trajectory Variables**: height_above_mean_sea_level, height_above_mean_sea_level_levels, air_potential_temperature, cloud_liquid_water_mixing_ratio_wrt_moist_air_and_condensed_water, cloud_ice_mixing_ratio_wrt_moist_air_and_condensed_water, water_vapor_mixing_ratio_wrt_moist_air_and_condensed_water, air_pressure_levels_minus_one, dry_air_density_levels_minus_one
* **Number of Levels**: The same number of levels as the input air_pressure_levels_minus_one Field
* **FunctionSpace**: The same FunctionSpace as the input air_pressure_levels_minus_one Field
* **hasTLAD**: True
* **Optional Parameters**: None
