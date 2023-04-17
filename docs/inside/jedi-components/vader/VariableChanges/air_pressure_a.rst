.. _top-vader-recipe-airpressurea:

Air pressure at midpoints from air pressure at interface
========================================================

* **Description**: Produces pressure at the midpoints of levels from the pressure at the interface of levels, using the Phillips method
* **Name**: AirPressure_A
* **Variable produced**: air_pressure
* **Input Variables**: air_pressure_levels
* **Number of Levels** - One less level than air_pressure_levels
* **FunctionSpace** - The same FunctionSpace as the input air pressure levels Field
* **hasTLAD** - False
* **Optional Parameters**:
    * **kappa** - Defaults to a value of 0.28571428571428570