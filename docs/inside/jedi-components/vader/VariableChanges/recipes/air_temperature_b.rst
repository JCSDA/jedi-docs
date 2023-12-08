.. _top-vader-recipe-airtemperatureb:

Temperature from virtual temperature and specific humidity
==========================================================

* **Description**: Produces temperature from virtual temperature and specific humidity
* **Name**: AirTemperature_B
* **Variable produced**: air_temperature
* **Input Variables**: virtual_temperature, specific_humidity
* **Number of Levels** - The same number of levels as the input virtual temperature Field
* **FunctionSpace** - The same FunctionSpace as the input virtual temperature Field
* **hasTLAD** - False
* **Optional Parameters**:
    * **epsilon** - The ratio of the gas constants of air and water vapor. Defaults to a value of 0.62196.
