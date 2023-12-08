.. _top-vader-recipe-airpressurethicknessa:

Air pressure thickness from pressure at interface
=================================================

* **Description**: Produces pressure thickness at each level from the air pressure at the interface of levels. It takes the difference of the pressure at the top and bottom of the level.
* **Name**: AirPressureThickness_A
* **Variable produced**: air_pressure_thickness
* **Input Variables**: air_pressure_levels
* **Number of Levels** - One fewer level than air_pressure_levels
* **FunctionSpace** - The same FunctionSpace as the input air pressure levels Field
* **hasTLAD** - False
* **Optional Parameters**: None