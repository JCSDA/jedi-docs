.. _top-vader-recipe-totalrelativehumiditya:

Total relative humidity from moisture mixing ratios
===================================================

* **Description**: Produces total relative humidity from multiple moisture mixing ratios
* **Name**: TotalRelativeHumidity_A
* **Variable produced**: rht (total relative humidity)
* **Input Variables**: cloud_ice_mixing_ratio_wrt_moist_air_and_condensed_water, cloud_liquid_water_mixing_ratio_wrt_moist_air_and_condensed_water, water_vapor_mixing_ratio_wrt_moist_air_and_condensed_water, qrain, qsat
* **Number of Levels** - The same number of levels as the input (MO) specific_humidity Field
* **FunctionSpace** - The same FunctionSpace as the input specific_humidity Field
* **hasTLAD** - False
* **Optional Parameters**: None
