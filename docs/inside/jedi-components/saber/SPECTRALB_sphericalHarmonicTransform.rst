.. _spectralb_spherical_harmonic_transform:

Spectral To Gauss
=================

This block performs the following:

- :code:`multiply`: the inverse of the spherical harmonic transform, from spectral space to a Gaussian mesh.
- :code:`multiplyAD`: the adjoint of the inverse of the spherical harmonic transform.
- :code:`leftInverseMultiply`: the direct spherical harmonic transform from a Gaussian mesh to spectral space.

(Additional notes for developers are included as footnotes.)

Requirements
~~~~~~~~~~~~

This SABER block uses ECMWF libraries `Atlas`, `ectrans` and `fiat` and requires them to work.

Both the SABER block and the ECMWF libraries have been written to run in MPI and OpenMP contexts.

Example yaml
~~~~~~~~~~~~

.. code-block:: yaml
 
  saber outer blocks:
  - (...)
  - saber block name: spectral to gauss
    active variables:
    - unbalanced_pressure
    - moisture_control_variable
    - streamfunction
    - velocity_potential
    - eastward_wind
    outer inverse tolerance: 1e-8

Overview of the ``multiply`` method
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This transforms spectral fields onto a Gaussian mesh.  Note that the resolution of the Gaussian mesh is preset implicitly since it can be inferred from the preceding outer blocks or the model geometry (if there are no preceding outer blocks) [#f1]_.

The highest total wavenumber represented in the spectral space is currently fixed to :math:`2 N - 1` where :math:`N` is the Gaussian resolution. Formally the spherical harmonic transform can support total wavenumbers up to :math:`2 N`. However, only :math:`2 N - 1` are exact. Also the transformation from spectral fields to horizontal winds require a maximum of :math:`2 N - 1`, due to using a recursive formula for calculating the derivative of Legendre polynomials.

For active variables that are neither `eastward_wind` nor `northward_wind`, the standard scalar inverse spherical harmonic transform is used [#f2]_. Scientific details are explained in more detail in section `Analytical representation 2`.

For the horizontal wind components the spectral Helmholtz decomposition formula is used in conjunction with the standard scalar inverse spherical harmonic transform. In that case the active variables needs to include either `streamfunction` and `velocity_potential` or `vorticity` and `divergence`. The spectral fields of those variables need to be available from the the SABER block that is either the central block or one step closer to the central block [#f3]_.

Further scientific details are given in section `Analytical representation 3`.


Overview of the ``multiplyAD`` method
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

As this is the adjoint of the `multiply` method, it is somewhat similar in nature, but the steps are reversed. It transforms the data from a grid-point Gaussian mesh to spectral space and uses the adjoint of the scalar inverse spherical harmonic transform [#f4]_.

When the outer active variables include `eastward_wind`, `northward_wind` the adjoint of the inverse spherical harmonic transform is used with the adjoint of a spectral Helmholtz decomposition transformation [#f5]_.

Overview of the ``leftInverseMultiply`` method
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This uses the direct spherical harmonic transform that converts fields on a Gaussian mesh onto a spectral space [#f6]_.

When the outer active variables include `eastward_wind`, `northward_wind` the inverse of the spectral Helmholtz decomposition is used with the direct spherical harmonic transform [#f7]_.

Further details are given in section `Analytical representation 4`.


Analytical representation 0: Total, meridional wavenumber and normalised Legendre Polynomials
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The spherical harmonic formulation considers a triangular truncation of zonal and meridional complex spectral coefficients.

Imagine a Gaussian mesh with :math:`Resolution=2` e.g. `F2`. Then the spectral truncation is :math:`N = 2 * Resolution-1` which equal :math:`3` in this case.

The triangular truncation can be visualised by the diagram below:

+-----+--------------+--------------+--------------+--------------+
|     |       m=0    |      m=1     |       m=2    |       m=3    |
+=====+==============+==============+==============+==============+
| n=3 | (6)a         | (12)a+(13)bi | (16)a+(17)bi |  (18)+(19)bi |
+-----+--------------+--------------+--------------+--------------+
| n=2 | (4)a         | (10)a+(11)bi | (14)a+(15)bi |              |
+-----+--------------+--------------+--------------+--------------+
| n=1 | (2)a         |  (8)a+(9)bi  |              |              |
+-----+--------------+--------------+--------------+--------------+
| n=0 | (0)a         |              |              |              |
+-----+--------------+--------------+--------------+--------------+

The bracketed number refers to the index of the spectral coefficient. The value is represented in the form of a complex number of the form :math:`a + bi`. Note that the imaginary values for m=0 are zero and as such are not included. Note also that the values for negative m are held implicitly are they are the complex conjugate of the values for positive m.

Spherical harmonics :math:`Y^m_n (\theta, \lambda)`, where :math:`\theta` is the latitude and  :math:`\lambda` is the longitude, are calculated from the product of

- complex exponent :math:`e^{i m \lambda}`
- an associated Legendre polynomial of degree :math:`n` and order :math:`m` i.e.  :math:`P^m_n (\sin \theta)`,
- and a normalisation coefficient  :math:`s^m_n`

i.e.

.. math::

  Y^m_n (\lambda, \theta) = s^m_n P^m_n (\sin \theta) e^{i m \lambda}

Henceforth in this note we will consider the `normalised associated Legendre polynomial`, denoted by :math:`\tilde{P^m_n} = s^m_n P^m_n`.


A few notes:

(1) The normalisation is defined as in `Belousov 1962, p.5 eq.8` such that

.. math::

  \int_{-1}^{1} \biggl( \tilde{P^m_n} \biggr)^2 \mathrm{d}[\sin{\theta}] = 1

and the normalisation coefficient is effectively

.. math::

  s^m_n = \sqrt{\frac{2n+1}{2\pi}\frac{(n-m)!}{(n+m)!}}.


(2) The Condon-Shortley phase term (Condon, 1970) is not included in the normalised associated Legendre Polynomial :math:`\tilde{P^m_n}`.

(3) The normalised associated Legendre Polynomials for :math:`m=0` and :math:`m=1` are calculated using the Newton-Raphson method. The other normalised Legendre Polynomials are calculated recursively (Wedi, 2013).

Analytical representation 1: The direct spherical harmonic transform
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
The direct complex spherical harmonic transform is given by (Wedi et al, 2013)

.. math::

  (a+bi)^m_n = \frac{1}{2}\int_{-1}^{1} \biggl( \frac{1}{2\pi} \biggl[ \int_{0}^{2\pi} f(\theta, \lambda) e^{-im \lambda} \mathrm{d} \lambda \biggr] \tilde{P^m_n} [\sin \theta] \mathrm{d}[\sin \theta] \biggr)

where the scalar field on the Gaussian mesh is represented by :math:`f(\lambda, \theta)`.

The discrete analogue of the above equation involves an FFT for the inner square bracket as documented in (Temperton, 1983). Let us assume that the output of this FFT is :math:`\xi^m (\theta)`.

For each :math:`m` a Gaussian quadrature is employed to get the spectral coefficients

.. math::

  (a+bi)^m_n = \sum_{k=1}^{k=K} w_k \xi^m (x_k) \tilde{P^m_n} (x_k)

where :math:`w_k` is a Gaussian weight at the :math:`k^{\text{th}}` Gaussian latitudes. Gaussian latitudes are where the roots of the normalised associated Legendre polyomials are 0 for :math:`P^0_N`.

The Gaussian weights are calculated as in Swatztrauber (2002), namely from

.. math::

  w_k = \frac{2 N + 1} { [\tilde{P}^{m=1}_N (\sin \theta) ] ^2 }

The Gaussian weights are equal to the ratio of surface area segments that are associated with each Gaussian latitude to the surface area of the sphere. So the sum of the Gaussian weights across all Gaussian latitudes will sum to 1. This is different to the standard textbook set of weights which are typically twice as large (but then use a different normalisation for the normalised associated Legendre polynomials).

Analytical representation 2: The inverse spherical harmonic transform
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
The inverse transform is defined as (Wedi, 2013)

.. math::

  f(\lambda, \theta) = \sum_{m=-N}^{m=N} e^{im\lambda} \sum_{n=|m|}^{n=N} (a+bi)^m_n \tilde{P^m_n} [\sin(\theta)]


Note that the actual code does not use this formulation, but takes numerous shortcuts to the same result.



Analytical representation 3: The inverse spherical harmonic transform for horizontal winds
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This section explains the transformations that convert the horizontal spectral `vorticity` and `divergence` to horizontal wind components on the Gaussian mesh [#f8]_.

A spectral equivalent version of the 2D Helmholtz equation is used for this.

First the spectral vorticity and divergence coefficients, :math:`\zeta^m_n` and :math:`D^m_n`, are converted into spectral streamfunction and velocity potential coefficients, :math:`\psi^m_n` and :math:`\chi^m_n` using the inverse Laplacian scaling.

.. math::
  \psi^m_n &= \frac{-a^2}{n(n+1)} \zeta^m_n \ \\
  \chi^m_n &= \frac{-a^2}{n(n+1)} D^m_n

where :math:`\psi^0_0 = \chi^0_0 = 0`.

Then a spectral version of the 2D Helmholtz equation is used to get spectral coefficients U and V. The equations use a Legendre difference relationship to represent the derivative of the Legendre polynomial.

.. math::
  U^m_n &= \frac{1}{a}[i m \chi^m_n + (n-1) \epsilon^m_n \psi^m_{n-1} - (n+2) \epsilon^m_{n+1} \psi^m_{n+2}]  \\
  V^m_n &= \frac{1}{a}[i m \psi^m_n - (n-1) \epsilon^m_n \chi^m_{n-1} + (n+2) \epsilon^m_{n+1} \chi^m_{n+2}]  \\
  \epsilon^m_n & = \sqrt{(n^2 - m^2) / (4n^2 -1)}

A grid point version of :math:`U, V` is given by spherical harmonic synthesis.

.. math::
  U(\lambda, \theta) &= \sum_{m=-N}^{m=N} e^{im\lambda} \sum_{n=|m|}^{n=N} U^m_n  \tilde{P^m_n} [\sin(\theta)] \\
  V(\lambda, \theta) &= \sum_{m=-N}^{m=N} e^{im\lambda} \sum_{n=|m|}^{n=N} V^m_n  \tilde{P^m_n} [\sin(\theta)] 

The actual wind components are calculated by dividing by :math:`\cos \theta`.

.. math::
  u &= \frac{1}{\cos \theta} U \\
  v &= \frac{1}{\cos \theta} V 


Analytical representation 4: The direct spherical harmonic transform for horizontal winds
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This section explains the transformation from horizontal wind components on the Gaussian mesh to the spectral `vorticity` and `divergence` fields [#f9]_.

The input to this transformation comprises the zonal and meridional wind components which are stored in a single Atlas vector field on a Gaussian mesh. The output is the two-dimensional vorticity and divergence stored as spectral coefficients.

In general the steps are the inverse of `Analytical representation 3`.

The trick that is used to solve the former is to scale the grid point wind components (u,v) into two scalar fields (U,V)

.. math::
  U &= (\cos \theta) u \\
  V &= (\cos \theta) v 

Each :math:`U` and :math:`V` is decomposed into spectral coefficients and treated as if they were scalars.

Then the inverse of the spectral Helmholtz decomposition (described in Section 3) is performed.  This involves solving a tri-diagonal banded system of equations for each meridional wavenumber :math:`m`.
The spectral horizontal vorticity and divergence are calculated by using Laplacian scaling

.. math::
  \zeta^m_n &= \frac{-n(n+1)}{a^2} \psi^m_n \ \\
  D^m_n &= \frac{-n(n+1)}{a^2} \chi^m_n

where :math:`D^0_0 = \zeta^0_0 = 0`.

.. _references_spherical_harmonic_transform:

References
~~~~~~~~~~

Belousov, S. L. (1962), Tables of normalized associated Legendre polynomials, Mathematical tables, vol. 18, Pergamon Press. https://www.google.de/books/edition/Tables_of_Normalized_Associated_Legendre/u_viBQAAQBAJ?hl=en&gbpv=1&dq=belousov+legendre+polynomials&printsec=frontcover

Condon, E. U.; Shortley, G. H. (1970), The Theory of Atomic Spectra, Cambridge, England: Cambridge University Press, OCLC 5388084; Chapter 3.

Swarztrauber, P. N. (2002) On computing the points and weights for Gauss-Legendre quadrature, SIAM J. Sci. Comput. Vol. 24 (3) pp. 945-954, https://epubs.siam.org/doi/abs/10.1137/S1064827500379690

Temperton, C., 1991: On Scalar and Vector Transform Methods for Global Spectral Models. Mon. Wea. Rev., 119, 1303–1307, https://doi.org/10.1175/1520-0493-119-5-1303.1.

Wedi, N. P., M. Hamrud, and G. Mozdzynski, 2013: A Fast Spherical Harmonics Transform for Global NWP and Climate Models. Mon. Wea. Rev., 141, 3450–3461, https://doi.org/10.1175/MWR-D-13-00016.1.

.. rubric:: Footnotes (for developers)

.. [#f1] The Gaussian mesh geometry is passed to the saber block from the ``outerGeometryData`` object when the 'gauss to spectral` SABER block is instantiated.

.. [#f2] The SABER method ``multiplyScalarField`` is used for the inverse spherical harmonic transform. Within this method the Atlas method ``invtrans`` is called which is an interface to the underlying ECMWF spherical harmonic transform code.

.. [#f3] In the case where we need to create the eastward and northward components of the wind the following steps are taken in SABER method ``multiplyVectorFields``:

  - identify whether inner active variables contain the ``streamfunction`` and ``velocity_potential`` spectral fields or horizontal ``vorticity`` and ``divergence`` fields.
  - if the inner active variables contain ``streamfunction`` and ``velocity_potential`` spectral fields then convert them into horizontal ``vorticity`` and ``divergence`` spectral fields.
  - apply an altas method, called  ``invtrans_vordiv2wind``, that converts ``vorticity`` and ``divergence`` spectral fields into an Atlas vector field holding the horizontal wind components on the Gaussian grid.
  - since Atlas and ``ectrans`` happens to store the two components as a single field, it is split into separate eastward_wind and northward_wind fields for each longitude, latitude pair.

.. [#f4] The adjoint of the scalar inverse spherical harmonic transform is done in the SABER method ``multiplyScalarFieldAdj`` and within this method the Atlas method ``invtrans_adj`` is called.
.. [#f5] The adjoint of the scalar inverse spherical harmonic transform for the horizontal wind components is done in the SABER method ``multiplyVectorFieldsAdj``. The steps in this method are:

  - copy the data from the two fields ``eastward_wind`` and ``northward_wind`` into a single vector Atlas field.
  - apply an Atlas method, called ``invtrans_vortdiv2wind_adj`` that converts  the single horizontal vector field  into ``vorticity`` and ``divergence`` spectral fields.
  - if the inner active variables contain ``streamfunction`` and ``velocity_potential`` spectral fields convert the horizontal ``vorticity`` and ``divergence`` spectral fields into them. The scaling is the same that is used in the equivalent ``multiply`` method as it is self-adjoint.

.. [#f6] The scalar transform is done in SABER method ``invertMultiplyScalarFields`` using the Atlas method ``dirtrans``.

.. [#f7] When the outer active variables include ``eastward_wind``, ``northward_wind`` we do the steps in ``invertMultiplyVectorFields``:

  - copy the data from the two fields ``eastward_wind`` and ``northward_wind`` into a single vector Atlas field.
  - apply an altas method, called ``dirtrans_wind2vortdiv`` that converts  the single horizontal vector field  into ``vorticity`` and ``divergence`` spectral fields.
  - for inner active variables ``streamfunction`` and ``velocity_potential``, the associated spectral fields are converted into horizontal `vorticity` and `divergence` spectral fields. The scaling is the reciprocal of what is used in the equivalent ``multiply`` method.

.. [#f8] The Atlas routine ``invtrans_vortdiv2wind`` is the interface to the ECWMF code which calculates the grid point horizontal wind components from the horizontal spectral vorticity and the divergence.

.. [#f9] The Atlas routine ``dirtrans_wind2vortdiv`` is the interface to the ECMWF code which calculates the horizontal spectral vorticity and the divergence from the horizontal wind components on the Gaussian mesh.





