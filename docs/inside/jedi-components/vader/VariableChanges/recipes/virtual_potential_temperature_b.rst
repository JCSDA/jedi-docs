.. _top-vader-recipe-virtualpotentialtemperatureb:

Virtual Potential Temperature from specific humidity and potential temperature
==============================================================================

* **Description**: Produces virtual potential temperature from (Met Office) specific humidity and potential temperature
* **Name**: VirtualPotentialTemperature_B
* **Variable produced**: virtual_potential_temperature
* **Input Variables**: water_vapor_mixing_ratio_wrt_moist_air_and_condensed_water, air_potential_temperature
* **Trajectory Variables**: water_vapor_mixing_ratio_wrt_moist_air_and_condensed_water, air_potential_temperature
* **Number of Levels**: The same number of levels as the input potential_temperature Field
* **FunctionSpace**: The same FunctionSpace as the input potential_temperature Field
* **hasTLAD**: True
* **Optional Parameters**: None
