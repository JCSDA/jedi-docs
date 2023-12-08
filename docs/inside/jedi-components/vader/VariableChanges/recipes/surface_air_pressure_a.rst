.. _top-vader-recipe-surfaceairpressurea:

Surface air pressure from air pressure thickness
================================================

* **Description**: Produces surface air pressure by summing the pressure at model top with all the pressure thickness values
* **Name**: SurfaceAirPressure_A
* **Variable produced**: surface_pressure
* **Input Variables**: air_pressure_thickness
* **Number of Levels** - One (1)
* **FunctionSpace** - The same FunctionSpace as the input air pressure thickness Field
* **hasTLAD** - False
* **Required Configuration Variables**:
    * **air_pressure_at_top_of_atmosphere_model**
* **Optional Parameters**: None