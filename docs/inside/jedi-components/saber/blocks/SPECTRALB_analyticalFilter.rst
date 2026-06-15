.. _spectralb_analytical_filter:

Spectral Analytical Filter
==========================

This block performs multiplication, in spectral space, by an analytical function depending only on the total wavenumber. The block is self-adjoint, so the block's ``multiply()`` and ``multiplyAD()`` methods are identical.

The two typical use-cases are for :ref:`frequency filters <freq-filt>` in :ref:`ProcessPerts` or for :ref:`horiz-loc` in a general variational application (implemented in SABER as a dirac test in the :ref:`ErrorCovarianceToolbox`).

In both cases, this block should appear above (in the list of saber outer blocks in the yaml configuration) a transformation to spectral space (for instance the :ref:`spectralb_spherical_harmonic_transform` block) as it operates on fieldSets in the frequency domain. In typical cases, a spectral representation of a fieldSet will be transformed from a Regular Gaussian grid (see `Gaussian Grids <https://confluence.ecmwf.int/display/OIFS/4.1+OpenIFS%3A+Gaussian+grids>`_ for more information). In this case, the default maximum waveband in the spectral representation will be :math:`2N-1` where :math:`N` is the `Gaussian Number <https://sites.ecmwf.int/docs/atlas/design/grid/#regulargaussiangrid>`_ of the regular gaussian grid. 

We refer the reader to :cite:`errera2012spectral` for an explanation of how these filters relate to isotropic convolutions.

.. _freq-filt:

Frequency Filter Mode
---------------------

This block can be used as a bandpass filter (applied to each vertical level) on fieldSets that have been transformed into frequency space. Several filter profiles for attenuating waveband coefficients are available:

- triangle (trapeziod for special cases)
- boxcar (rectangle)
- gaussian

To use the triangle filter profile, the user provides a ``waveband min``, ``waveband peak``, and ``waveband max`` to specify the filter profile. If the lowest waveband (:math:`n = 0`) is the ``waveband min`` or the maximum waveband in your truncation is the ``waveband max``; then, the filter will create a trapezoidal profile and set the attenuation to 1 between the waveband end-point and the ``waveband peak``. To use the boxcar profile, the user provides a ``waveband min``, ``waveband max``, and ``waveband amplitude``. See :ref:`Filter Shapes <filter-shapes>` and yaml examples below for more information.

.. _filter-shapes:
.. figure:: ../fig/figure_filter_shapes.png
   :align: center
   :scale: 60%

   Triangle and boxcar filter profiles (top). Special trapeziod cases of the triangle profile (below).


Example yaml: Triangle/Trapeziod filter
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To use a triangle filter profile, choose ``waveband fitler`` for ``shape`` in the filter ``function`` settings, and select waveband parameters. If ``waveband min`` is zero, the filter profile will be a `left trapeziod` and if ``waveband max`` is equal to the maximum number kept in the spectral transformation the profile will have the `right trapeziod` profile (see :ref:`Filter Shapes <filter-shapes>`).

.. code-block:: yaml

  saber outer blocks:
    - (*** inner blocks ***)
    - saber block name: spectral analytical filter
      function:
        shape: waveband filter        # "waveband filter" selects the triangle profile
        waveband min: wb_min          # (int) minimum waveband
        waveband peak: wb_peak        # (int) peak waveband
        waveband max: wb_max          # (int) maximum waveband
      preserving variance: true       # (bool) set to 'true' in filtering mode
      active variables: *vars         # variables to be filtered
    -(*** outer blocks ***)


.. note::

  For more information on the ``preserving variance`` parameter, see the :ref:`bandpass-filter` section of the ProcessPerts documentation.

Example yaml: Boxcar filter
~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: yaml

  saber outer blocks:
    - (*** inner blocks ***)
    - saber block name: spectral analytical filter
      function:
        shape: boxcar            # "boxcar" selects the rectangle profile
        waveband min: wb_min     # (int) minimum waveband of box
        waveband max: wb_max     # (int) maximum waveband of box
        waveband amplitude: 1.0  # amplitude of box
      preserving variance: true  # (bool) set to 'true' in filtering mode
      active variables: *vars    # variables to be filtered
    -(*** outer blocks ***)

Example yaml: Gaussian filter
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: yaml
 
  saber outer blocks:
  - (...)
  - saber block name: spectral analytical filter
    normalize filter variance: false  # Optional. Default is true (for localization)
    function:
      shape: gaussian                 # Optional. Default is gaussian.
      horizontal daley length: 2000e3
  - (...)

The parameter ``normalize filter variance`` decides whether the analytical function should be normalized to act as a localization function (so should be set to ``false`` in filter mode).

.. _horiz-loc:

Horizontal Localization Mode
----------------------------

This block can be used for horizontal localization, relying on the fact that convolution on the physical space is equivalent to multiplication on the spectral space. In this use-case, only the ``gaussian`` filter profile (function) is recommended.

To model convolution by a Gaussian localization function :math:`f(d)` in physical space (where :math:`d` is the great circle separation distance), we multiply by a Gaussian localization function :math:`\widehat{f}(n)` in spectral space (where :math:`n` is the total wavenumber). 
If the physical space Gaussian is given by

.. math:: 

  f(d) &= \exp\biggl(-\frac{d^2}{2 L^2}\biggr)\\
  \text{Or equivalently }f(\lambda) &= \exp\biggl(-\frac{\lambda^2}{2 \sigma_{\lambda}^2}\biggr)

where :math:`L` is the horizontal localization length, :math:`d = \lambda R`, :math:`R` is the Earth radius and :math:`\sigma_\lambda = L / R`,
then the associated Gaussian in spectral space is given by:

.. math::

  \widehat{f}(n) = C\exp\biggl(-\frac{n^2}{2\sigma_n^2}\biggr)

where :math:`\sigma_n = 1/ \sigma_\lambda = R / L` and :math:`C` is some normalization constant.


The normalization constant :math:`C` is computed by ensuring the total variance of the localization function in spectral space is 1. 

Example yaml (localization)
~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: yaml

  - saber block name: spectral analytical filter
    function:
      horizontal daley length: 2000e3


Here, the localization is modeled as a Gaussian with Daley length specified from the yaml, in meters.
For a Gaussian function, the Daley length :math:`\sqrt{-f(0) / f''(0)}` is parameter :math:`L` in the equations above (see for instance :cite:`pannekoucke2008background`).

Since the spectral analytical localization is a (self-adjoint) outer block, it is actually applied twice in a multiplication by the associated localization or covariance matrix. 
The block accounts for this in the definition of the Daley length :math:`L`, so that the full correlation model (with the outer block applied twice) has a Daley length :math:`L`.
