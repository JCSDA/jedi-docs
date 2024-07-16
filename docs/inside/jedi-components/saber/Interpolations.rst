.. _interpolations:

Interpolations
==============

This document provides an overview of the interpolation blocks available in Saber module.

In many cases, the grid used by inner blocks in a covariance model may not match the model
grid providing the analysis increment. In these cases, an interpolation block will be
needed in the outer block chain to transform between the model grid/geometry and the
geometry used internally by the covariance model.

.. toctree::
    :maxdepth: 1

    rescalingLayer
    genericInterpolation

Interpolation
-------------

Generic interpolation block relying on the OOPS :code:`GlobalInterpolator` class which
is a wrapper around two interpolator implementations: the :code:`AtlasInterpolator` and
the :code:`UnstructuredInterpolator`. For more information see :ref:`generic-interp`.

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
