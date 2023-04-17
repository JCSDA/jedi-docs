.. _top-vader-recipe-airpressureatinterfaceb:

Air pressure at interface from pressure thickness
=================================================

* **Description**: Produces pressure at the interface of levels from the air pressure thickness values. It sums the pressure thickness value with the pressure level beneath to produce the next pressure level value.
* **Name**: AirPressureAtInterface_B
* **Variable produced**: air_pressure_levels
* **Input Variables**: air_pressure_thickness
* **Number of Levels** - One more level than air_pressure_thickness
* **FunctionSpace** - The same FunctionSpace as the input air pressure thickness Field
* **hasTLAD** - False
* **Required Configuration Variables**:
    * **air_pressure_at_top_of_atmosphere_model**
* **Optional Parameters**: None