.. _top-vader:

#####
VADER
#####

VADER is the **VAriable DErivation Repository**.

It provides generic routines for producing new variables from known variables.

Before VADER, every JEDI model interface had to implement every variable change that it required, resulting in duplicated code and effort between models. VADER provides a way for all models to use the same variable change code, while still maintaining the flexibility for models to use their own code when desired.

.. toctree::
   :maxdepth: 2

   how_to_use_vader
   recipe_naming
   VariableChanges/index.rst
