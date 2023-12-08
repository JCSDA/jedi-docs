.. _top-vader-recipe-airpressureatinterfacea:

Air pressure at interface from ak/bk
====================================

* **Description**: Produces pressure at the interface of levels from the surface pressure and ak & bk
* **Name**: AirPressureAtInterface_B
* **Variable produced**: air_pressure_levels
* **Input Variables**: surface_pressure
* **Number of Levels** - The "nLevels" number of levels stored in the VADER configuration variables
* **FunctionSpace** - The same FunctionSpace as the input surface pressure Field
* **hasTLAD** - False
* **Required Configuration Variable(s) in VADER constructor**:
    * **nLevels**
    * **sigma_pressure_hybrid_coordinate_a_coefficient**
    * **sigma_pressure_hybrid_coordinate_b_coefficient**
* **Optional Parameters**: None