.. _SPECTRALB:

SPECTRALB
=========

.. toctree::
   :hidden:

   SPECTRALB_analyticalFilter.rst


SABER blocks relying on spectral transforms. 
This includes the blocks needed to build a spectral correlation or covariance operator. 
The blocks currently implemented are listed here by their block names.

Central blocks
~~~~~~~~~~~~~~

- :code:`SPCTRL_COV`: first try of a spectral covariance, to be removed.
- :code:`spectral covariance`: 3D covariance or correlation in spectral space.

Outer blocks
~~~~~~~~~~~~

- :code:`spectral to gauss`: interpolation block from spectral space to Gauss grid.
- :code:`spectral to spectral`: change of resolution in spectral space, by truncation or zero-padding.
- :ref:`spectral analytical filter <spectralb_analytical_filter>`: multiplication by analytical 2D function in spectral space. Used for horizontal localization.
- :code:`gauss winds to geostrophic pressure`: to derive geostrophic pressure from winds. To be applied on a Gauss grid.
- :code:`mo_hydrostatic_pressure`: super block combining :code:`gauss winds to geostrophic pressure` and :code:`mo_hydrostatic_pressure_from_geostrophic_pressure`. Derives hydrostatic pressure from unbalanced pressure and from a vertical regression on the wind-derived geostrophic pressure. To be applied on a Gauss grid.
