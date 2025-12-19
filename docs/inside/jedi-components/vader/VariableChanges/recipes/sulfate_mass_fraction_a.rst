.. _top-vader-recipe-sulfatemassfractiona:

Sulfate unit conversion from ppmv to ug/kg
=======================================================

* **Description**: Convert sulfate concentration in ppmv to mass fraction in ug/kg
* **Name**: SulfateMassFraction_A
* **Variable produced**: mass_fraction_of_sulfate_in_air
* **Input Variables**: sulfate_ppmv
* **Number of Levels**: The same number of levels as the input Fields
* **FunctionSpace**: The same FunctionSpace as the input Fields
* **hasTLAD**: False
* **Required Configuration Variables**:
  * **sulfmw** - molecular weight of sulfate
  * **airmw** - molecular weight of air
* **Optional Parameters**: None
