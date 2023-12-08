.. _top-vader-recipe-totalwatera:

Total water mixing ratio wrt moist air and condensed water from specific humidity and other moisture mixing ratios
==================================================================================================================

* **Description**: Produces total water mixing ratio wrt moist air and condensed water from (Met Office defined) specific humidity, and water vapor and cloud liquid water mixing ratios
* **Name**: TotalWater_A
* **Variable produced**: qt (total_water_mixing_ratio_wrt_moist_air_and_condensed_water)
* **Input Variables**: specific_humidity (water_vapor_mixing_ratio_wrt_moist_air_and_condensed_water), mass_content_of_cloud_liquid_water_in_atmosphere_layer (cloud_liquid_water_mixing_ratio_wrt_moist_air_and_condensed_water), mass_content_of_cloud_ice_in_atmosphere_layer (cloud_ice_mixing_ratio_wrt_moist_air_and_condensed_water)
* **Number of Levels** - The same number of levels as the input specific_humidity Field
* **FunctionSpace** - The same FunctionSpace as the input specific_humidity Field
* **hasTLAD** - True
* **Optional Parameters**: None
