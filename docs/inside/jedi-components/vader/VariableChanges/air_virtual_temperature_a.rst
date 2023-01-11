.. _top-vader-recipe-airvirtualtemperaturea:

Virtual Temperature from potential temperature and exner
========================================================

* **Description**: Produces virtual temperature from temperature and specific humidity
* **Name**: AirVirtualTemperature_A
* **Variable produced**: virtual_temperature
* **Input Variables**: air_temperature, specific_humidity
* **Number of Levels** - The same number of levels as the input air temperature Field
* **FunctionSpace** - The same FunctionSpace as the input air temperature Field
* **hasTLAD** - True
* **Optional Parameters**:
    * **epsilon** - The ratio of the gas constants of air and water vapor. Defaults to a value of 0.62196.
