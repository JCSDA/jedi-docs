.. _top-vader-recipe-airpressureextendedupbyonea:

Air pressure at midpoints including a point above the model top
===============================================================

* **Description**: Produces pressure at the midpoints of levels including a point above the model top
* **Name**: AirPressureExtendedUpByOne_A
* **Variable produced**: air_pressure_levels
* **Input Variables**: dimensionless_exner_function_levels_minus_one, air_pressure_levels_minus_one, air_potential_temperature, height_above_mean_sea_level_levels
* **Number of Levels** - One more level than air_pressure_levels_minus_one
* **FunctionSpace** - The same FunctionSpace as the input air_pressure_levels_minus_one Field
* **hasTLAD** - False
