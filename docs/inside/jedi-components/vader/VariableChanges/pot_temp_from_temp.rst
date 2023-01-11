.. _top-vader-recipe-temptoptemp:

Potential Temperature from temperature and surface pressure
===========================================================

* **Description**: Produces potential temperature from temperature and surface pressure
* **Name**: AirPotentialTemperature_A
* **Variable produced**: potential_temperature
* **Input Variables**: air_temperature, surface_pressure
* **Number of Levels** - The same number of levels as the input temperature Field
* **FunctionSpace** - The same FunctionSpace as the input temperature Field
* **hasTLAD** - False
* **Optional Parameters**:
    * **p0** - p-naught. Defaults to a value of 100,000 if the pressure units are Pa, or 1,000 if the units are hPa. If ``p0`` is not specified, and pressure units are also not specified in the pressure Field metadata, the algorithm fails.
    * **kappa** - Defaults to a value of 0.2857