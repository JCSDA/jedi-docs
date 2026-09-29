.. _geographical-mask:

Geographical Mask Block
=======================

The :code:`GeographicalMask` outer block splits a domain into separate regions
(in the adjoint application) so that separate covariances can be applied to the
different regions. The separate regions are then recombined in the forward
application of the block.

To calibrate the block (i.e. create the geographical masks) a "mask" field is
read from a user-specified variable in a file (can be a model file - like a
background or first guess - or a user provided file with desired mask). The user then
specifies the conditions for the mask using relational operators (<, <=, ==, !=,
>= or >) and thresholds. In :code:`calibration mode` the masks can be written out
into a form that can then be read in later (when the block is in :code:`read mode`).

Filtering can also be applied to smooth out sharp cutoffs.

For example, if the latitude can be read out of a model file, then a mask
separating the domain into latitude bands could be created. In the examples
that follow, a land/sea split is used. See :cite:`Menetrier2011` for another
example using this feature for data assimilation of fog events.

Example
-------

The example below separates the :code:`air_temperature` variable in to
separate :code:`air_temperature_land` and :code:`air_temperature_sea`
regions using the :code:`landmask` variable read from a model file
in which grid points over land have a value of 1 and points over
water have a value of 0.

.. code-block:: yaml

   saber outer blocks:
   - saber block name: GeographicalMask
     active variables: [air_temperature]
     calibration:
       masks:
       - suffix: _land
         relational operator: ">="
         threshold: 0.5
       - suffix: _sea
         relational operator: "<"
         threshold: 0.5
       mask variable: landmask
       input mask file:
         overriding variables: [landmask]
         filename: <path/to/model_file>
         date: *date

For a specific example for a :code:`landmask` from a 480km mpas model file,
see :ref:`mpas480km-land-mask`.

.. _mpas480km-land-mask:
.. figure:: /inside/jedi-components/saber/fig/landsea_mask_480km.png
    :scale: 50%

    Landmask for 480km MPAS grid

A demonstration of a dirac test using the :ref:`diffusion` central block
correlation operator (with a longer correlation lengthscale over water
than over land) is shown below (the locations of the dirac points are indicated
in :ref:`mpas480km-land-mask`).

.. _geoMask-dirac:
.. figure:: /inside/jedi-components/saber/fig/geoMask_dirac.png
    :scale: 50%

    Dirac test using ExplicitDiffusion central block and GeographicalMask
    to split land/sea regions.

The dirac point off the western African coast shows that covariance is NOT
spread across the domains.
