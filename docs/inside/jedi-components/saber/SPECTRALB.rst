.. _SPECTRALB:

SPECTRALB
=========

SABER blocks relying on spectral transforms.

This includes the blocks needed to build a spectral correlation or covariance operator. 
The blocks currently implemented are listed here by their block names.

Central blocks
^^^^^^^^^^^^^^

- :code:`spectral covariance`: 3D covariance in spectral space.
- :code:`spectral correlation`: 3D correlation in spectral space, using same covariance statistics as :code:`spectral covariance`.

These two blocks can also be used to model 2D horizontal correlations or covariances, by activating the :code:`skip vertical convolution` key.
This capability is not implemented in calibration mode, nor in outer blocks.
It can typically be used in conjunction with the :code:`covariance profile` capability of the :doc:`ErrorCovarianceToolbox`, to extract a full column of horizontal covariance profiles.

Outer blocks
^^^^^^^^^^^^

- :code:`square root of spectral covariance`: the outer block equivalent of :code:`spectral covariance`.  To be typically used with central block 'ID' for generating random increments.
- :code:`square root of spectral correlation`: the outer block equivalent of :code:`spectral correlation`.  To be typically used with central block 'ID' for generating random increments.
- :ref:`spectral to gauss <spectralb_spherical_harmonic_transform>`: outer block from spectral space to Gauss grid that applies the inverse spherical harmonic transform within the internal "multiply" method. The adjoint of the inverse transform and the direct transform from the Gauss grid to spectral space is also included in this outer block.
- :code:`spectral to spectral`: change of resolution in spectral space, by truncation or zero-padding.
- :ref:`spectral analytical filter <spectralb_analytical_filter>`: multiplication by analytical 2D function in spectral space. Used for horizontal localization.
- :code:`gauss winds to geostrophic pressure`: to derive geostrophic pressure from winds. To be applied on a Gauss grid.
- :code:`mo_hydrostatic_pressure`: super block combining :code:`gauss winds to geostrophic pressure` and :code:`mo_hydrostatic_pressure_from_geostrophic_pressure`. Derives hydrostatic pressure from unbalanced pressure and from a vertical regression on the wind-derived geostrophic pressure. To be applied on a Gauss grid.

Index
^^^^^

.. toctree::
   :titlesonly:

   SPECTRALB_sphericalHarmonicTransform.rst
   SPECTRALB_analyticalFilter.rst