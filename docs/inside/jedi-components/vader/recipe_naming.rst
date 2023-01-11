.. _top-vader-recipe-naming:

Recipe Naming Standard
======================

As described elsewhere, *recipes* are the classes that contain the algorithm code to produce a new variable when given other variables as input. Each recipe produces one and only one variable, which is referred to as the recipe's *product*.

The name of a VADER recipe consists of two parts. The first part is simply the name of its product variable, in CamelCase. Then an underscore character ('_'), then the letter 'A', 'B', 'C', etc., used to distinguish multiple recipes that all produce the same product.

As an example, at the time of this writing VADER had two recipes that would produce the variable ``air_temperature``. One recipe produces it using potential temperature and exner as inputs. (Recipe inputs are often called *ingredients*.) This recipe is named ``AirTemperature_A``. Another recipe produces ``air_temperature`` using virtual temperature and specific humidity as ingredients, and is called ``AirTemperature_B``. Note that the ``A`` and ``B`` only indicate the order in which the recipes were created, not the order that VADER will attempt to use them. (The order in which VADER will attempt to use recipes is defined by VADER's *cookbook*, described elsewhere.)

Even if VADER has only one recipe that creates a certain product, that recipe's name should still end with ``_A``.
