.. _top-vader-recipe-airpressuretokappaa:

Air pressure to kappa from air pressure at interface
====================================================

* **Description**: Produces pressure to kappa from air pressure at interface
* **Name**: AirPressureToKappa_A
* **Variable produced**: air_pressure_to_kappa
* **Input Variables**: air_pressure_levels, ln_air_pressure_at_interface
* **Number of Levels** - One fewer level than air_pressure_levels
* **FunctionSpace** - The same FunctionSpace as the input air pressure levels Field
* **hasTLAD** - False
* **Optional Parameters**:
    * **kappa** - Defaults to a value of 0.28571428571428570