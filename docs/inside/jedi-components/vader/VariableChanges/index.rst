.. _top-vader-varchanges:

######################
Vader Variable Changes
######################

Each variable change that can be performed by Vader is defined by code called a "Recipe" (from a design metaphor within the Vader code.) Each recipe shares the same structure:

* **Name** - The name of the recipe which can be used in yaml to specify the recipe parameters. (Follows the recipe naming standard.)
* **Variable Produced** - The variable that will be created by the algorithm, usually called the "product".
* **Input Variables** - Usually called "ingredients", these are the variables required as input for the algorithms.
* **Number of Levels** - The number of levels for the Atlas Field for the product. Must be a constant or a function of the number of levels of the ingredients.
* **FunctionSpace** - The Atlas FunctionSpace for the Atlas Field for the product. Can be specific FunctionSpace or the same as one of the ingredients.
* **hasTLAD** - This is a boolean flag indicating whether the recipe has implemented the tangent linear and adjoint (TL/AD) of the transformation. (These are optional, while the non-linear transformation is required.)
* **Algorithms** - Put into methods called ``executeNL`` (and ``executeTL`` and ``executeAD`` if ``hasTLAD`` is ``true``), this code performs the calculations on the inputs and produces the output.
* **Required Configuration Variables** - Some recipes reference values that are stored in VADER's configuration variables. These variables must be defined in the `VaderConstructConfig` class that is passed to the VADER constructor.
* **Parameters** - Recipes can have optional parameters which can configure their behavior. These parameters should not be required.

Below is a list of the recipes that have been implemented in VADER:

.. toctree::
   :maxdepth: 2

   pot_temp_from_temp
   air_potential_temperature_b
   air_pressure_a
   air_pressure_at_interface_a
   air_pressure_at_interface_b
   ln_air_pressure_at_interface_a
   air_pressure_thickness_a
   air_pressure_to_kappa_a
   surface_air_pressure_a
   air_temperature_a
   air_temperature_b
   air_virtual_temperature_a
   dry_air_density_levels_minus_one_a
   uwind_at_10m_a
   vwind_at_10m_a
