.. _UKMO:

UKMO-specific saber blocks
==========================
Most of the UKMO-specific saber blocks are because of the vertical-stagger that exists between variables.
The UKMO-specific vertical stagger in saber is not including the surface level.

It can be described by the ASCII art below:

.. code-block::

 -      half-level (index n)   (half-level above model top)
 
 ---    full level (index n-1) (model top)
 
 -      half-level (index n-1)
 
 ---
 
 -
 
 ---
 
 -      half-level (index 1)
 
 ---    full level (index 0)
 
 -      half-level (index 0)
 
 ---    surface

Note that variables on half-levels that don't have include the level above the model top have suffix "_levels_minus_one".  Half levels that include the level above the model top have the suffix "_levels".  Variables located on full levels do not have a suffix.

In particular the outer blocks that are affected are:

- :ref:`mo_vertical_localization <ukmo_vertical_localization>`: Vertical localization as implemented in UK Met Office system.  It assumes that the variables are located at half-levels (although the UKMO variable naming convention is not enforced at this point)
- :code:`mo vertical localization interpolation`: This outer block interpolates the localization matrix from half-levels to the required vertical stagger of each variable considered. The outer variable fields are consistent with the UKMO variable naming conventions.
- :code:`mo_hydro_bal`: Applies a linearised hydrostatic balance to calculate the virtual potential temperature from hydrostatic exner increments. The virtual potential temperature is on full levels and the hydrostatic exner are on half-levels (including the level above the model top.)  If we need to do the left inverse of this transformation we need to also use the air_pressure (at the lowest half level) as well.

Future
------
In the future we expect to be changing the naming of the variables. Full levels will have the "_at_interface" suffix, half-levels (not including level above model top) will no longer have a suffix, and half-levels including level above model top will include suffix "_including_point_above_model_top".


Index
^^^^^

.. toctree::
   :titlesonly:

   UKMO_vertical_localization.rst
