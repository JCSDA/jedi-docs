.. _spectralb_horizontal_localization:

Horizontal localization in spectral space
=========================================

This block relies on the fact that convolution on the physical space is equivalent to multiplication on the spectral space. 

To model convolution by a Gaussian localization function :math:`f(d)` in physical space (where :math:`d` is the great circle separation distance), we multiply by a Gaussian localization function :math:`\widehat{f}(n)`` in spectral space (where :math:`n` is the total wavenumber). 
The two Gaussians are related by:

.. math:: 

  f(d) &= \exp\biggl(-\frac{d^2}{2 L^2}\biggr)\\
       &= \exp\biggl(-\frac{\lambda^2}{2 \sigma_{\lambda}^2}\biggr)\\
  \widehat{f}(n) &= C\exp\biggl(-\frac{n^2}{2\sigma_n}\biggr)

where :math:`L` is the horizontal localization Daley length, :math:`d = \lambda R` where :math:`R` is the Earth radius, :math:`\sigma_\lambda = L / R`, :math:`\sigma_n = 1/ \sigma_\lambda = R / L` and :math:`C` is some normalization constant.


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

The :code:`read` section is optional, and is only used to trigger internal testing.

Reference
~~~~~~~~~
Errera, Q., & Ménard, R. (2012). Technical Note: Spectral representation of spatial correlations in variational assimilation with grid point models and application to the Belgian Assimilation System for Chemical Observations (BASCOE). Atmospheric Chemistry and Physics, 12(21), 10015–10031. `doi:10.5194/acp-12-10015-2012 <https://doi.org/10.5194/acp-12-10015-2012>`_

