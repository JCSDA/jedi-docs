.. _top-vader-recipe-relativehumiditya:

Relative humidity
=================

* **Description**: Produces relative humidity from specific humidity (q), specific humidity assuming saturation (qsat), air temperature (T) and the derivative of the logarithm of the saturation vapour pressure with respect to air temperature (dlsvpdT). The purpose of this recipe is to test for adjointness the tangent-linear and adjoint code, not to be used as part of a variable change. The TL/AD codes are related to the non-linear code, but don't use the same inputs. 
* **Name**: RelativeHumidity_A
* **Variable produced**: relative_humidity (in units percent, varying from 0 to 100)
* **Input Variables**: q and qsat for the non-linear code, q and T increments with q, qsat and dlsvpdT states for the tangent-linear code
* **Number of Levels** - The same number of levels as the air_temperature Field
* **FunctionSpace** - The same FunctionSpace as the input air_temperature Field
* **hasTLAD** - True, see description above
* **Optional Parameters**: None
