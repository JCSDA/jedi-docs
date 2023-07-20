.. _spectralb_horizontal_localization:

Horizontal localization in spectral space
=========================================

This block relies on the fact that convolution on the physical space is equivalent to multiplication on the spectral space. 

To model convolution by a Gaussian localization function :math:`f(d)` in physical space (where :math:`d` is the great circle separation distance), we multiply by a Gaussian localization function :math:`\widehat{f}(n)`` in spectral space (where :math:`n` is the total wavenumber). 
If the physical space Gaussian is given by

.. math:: 

  f(d) &= \exp\biggl(-\frac{d^2}{2 L^2}\biggr)\\
  \text{Or equivalently }f(\lambda) &= \exp\biggl(-\frac{\lambda^2}{2 \sigma_{\lambda}^2}\biggr)

where :math:`L` is the horizontal localization length, :math:`d = \lambda R`, :math:`R` is the Earth radius and :math:`\sigma_\lambda = L / R`,
then the associated Gaussian in spectral space is given by:

.. math::

  \widehat{f}(n) = C\exp\biggl(-\frac{n^2}{2\sigma_n}\biggr)

where :math:`\sigma_n = 1/ \sigma_\lambda = R / L` and :math:`C` is some normalization constant.


The normalization constant :math:`C` is computed by ensuring the total variance of the localization function in spectral space is 1. 



Example yaml
~~~~~~~~~~~~

.. code-block:: yaml
 
  saber central block:
    saber block name: horizontal localization in spectral space
    horizontal daley length: 6000e3
    read:
      uut consistency test: true    # Default is false
      consistency tolerance: 1e-13  # Default is 1e-12
      adjoint tolerance: 1e-13      # Default is 1e-12

The localization is modeled as a Gaussian with Daley length specified from the yaml, in meters.
For a Gaussian function, the Daley length :math:`\sqrt{-f(0) / f''(0)}` is parameter :math:`L` in the equations above (see for instance Pannekoucke *et al.*, 2008).

The :code:`read` section is optional, and is only used to trigger internal testing.

.. _references:

References
~~~~~~~~~~

Errera, Q., & Ménard, R. (2012). Technical Note: Spectral representation of spatial correlations in variational assimilation with grid point models and application to the Belgian Assimilation System for Chemical Observations (BASCOE). Atmospheric Chemistry and Physics, 12(21), 10015–10031. `doi:10.5194/acp-12-10015-2012 <https://doi.org/10.5194/acp-12-10015-2012>`_

Pannekoucke, O., Berre, L., & Desroziers, G. (2008). Background-error correlation length-scale estimates and their sampling statistics. Quarterly Journal of the Royal Meteorological Society, 134(631), 497–508. `doi:10.1002/qj.212 <https://doi.org/10.1002/qj.212>`_
