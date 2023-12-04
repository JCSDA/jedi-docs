.. _spectralb_analytical_filter:

Spectral Analytical Filter
==========================

This block performs multiplication in spectral space by an analytical function depending only on the total wavenumber. 
Typical use cases include horizontal localization and frequency filters.
We refer the reader to :cite:`errera2012spectral` for an explanation of how these filters relate to isotropic convolutions. 

Example yaml
~~~~~~~~~~~~

.. code-block:: yaml
 
  saber outer blocks:
  - (...)
  - saber block name: spectral analytical filter
    normalize filter variance: false  # Optional. Default is true (for localization)
    function:
      shape: gaussian                 # Optional. Default is gaussian.
      horizontal daley length: 2000e3
  - (...)

The parameter `normalize filter variance` decides whether the analytical function should be normalized to act as a localization function.
The only function shape currently implemented is `gaussian`.

Usage for horizontal localization
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This block can be used for horizontal localization, relying on the fact that convolution on the physical space is equivalent to multiplication on the spectral space.

To model convolution by a Gaussian localization function :math:`f(d)` in physical space (where :math:`d` is the great circle separation distance), we multiply by a Gaussian localization function :math:`\widehat{f}(n)` in spectral space (where :math:`n` is the total wavenumber). 
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


.. code-block:: yaml

  - saber block name: spectral analytical filter
    function:
      horizontal daley length: 2000e3


Here, the localization is modeled as a Gaussian with Daley length specified from the yaml, in meters.
For a Gaussian function, the Daley length :math:`\sqrt{-f(0) / f''(0)}` is parameter :math:`L` in the equations above (see for instance :cite:`pannekoucke2008background`).

Since the spectral analytical localization is a (self-adjoint) outer block, it is actually applied twice in a multiplication by the associated localization or covariance matrix. 
The block accounts for this in the definition of the Daley length :math:`L`, so that the full correlation model (with the outer block applied twice) has a Daley length :math:`L`.
