.. _top-vader-varchanges:

######################
Vader Variable Changes
######################

Each variable change that can be performed by Vader is defined by code called a "Recipe" (from a design metaphor within the Vader code.) Each recipe shares the same structure:

* **Name** - The name of the recipe which can be used in yaml to specify the recipe parameters.
* **Variable produced** - The variable that will be created by the algorithm.
* **Input Variables** - Sometimes called "ingredients", these are the variables required as input for the algorithm.
* **Algorithm** - Put into a method called ``execute``, this code performs the calculations on the inputs and produces the output.
* **Parameters** - Recipes can have optional parameters which can configure their behavior. These parameters should not be required.

Below is a list of the recipes that have been implemented in VADER:

.. toctree::
   :maxdepth: 2

   pot_temp_from_temp

