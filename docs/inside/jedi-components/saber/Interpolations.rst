.. _interpolations:

Interpolations
==============

This document provides an overview of the interpolation blocks available in Saber module.

.. toctree::
    :maxdepth: 1

    rescalingLayer

Interpolation
-------------

Generic interpolation block relying on oops global interpolator. 

Gauss to Cubed-Sphere-Dual
--------------------------

Bespoke interpolation block to interpolate from a Gaussian grid to a Cubed-Sphere-Dual grid.
This block comes with an :ref:`optional rescaling layer<rescalingLayer>` to compensate the variance lost during the interpolation.

Simple Vertical Projection
--------------------------

Simple vertical projection assuming linearly-spaced vertical levels.

Spectral to Spectral
--------------------

Change of resolution in spectral space, via zero-padding (prolongation) or spectral truncation (restriction).