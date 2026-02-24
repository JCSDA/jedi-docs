.. _top-vader-recipe-geopotentialatinterfacea:

Geopotential at interface
=========================

* **Description**: Produces geopotential at layer interfaces from geopotential, virtual temperature, ln_air_pressure, and ln_air_pressure_at_interface.
* **Name**: GeopotentialAtInterface_A
* **Variable produced**: geopotential_levels
* **Input Variables**: geopotential, virtual_temperature, ln_air_pressure, ln_air_pressure_at_interface
* **Trajectory Variables**: ln_air_pressure, ln_air_pressure_at_interface
* **Number of Levels**: Same as ln_air_pressure_at_interface
* **FunctionSpace**: Same as geopotential 
* **hasTLAD**: True
* **hasNL**: True
* **Required Configuration Variables**: gas_constant_of_dry_air
* **Optional Parameters**: None
