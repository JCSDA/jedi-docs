  .. _top-mpas-jedi-staticB:

.. _staticB:

Static Background Error Covariance
==================================

.. _generalBdesign:

General B Design
----------------


The multivariate background error covariance :math:`\mathbf{B}` is designed primarily to follow that of
the Weather Research and Forecasting (WRF) model Data Assimilation system (`WRFDA <https://www2.mmm.ucar.edu/wrf/users/wrfda/>`_)
and the Gridpoint Statistical Interpolation (`GSI <https://dtcenter.org/community-code/gridpoint-statistical-interpolation-gsi>`_).
It uses both a generic component from the :doc:`SABER <../saber/index>` repository and a model-specific compoment from the
MPAS-JEDI repository. It is implemented as a set of linear variable changes to a block-diagonal
correlation matrix :math:`\mathbf{C}`.

.. math::

   \mathbf{B}=\mathbf{K}_{1}\mathbf{K}_{2}\mathbf{\Sigma}\mathbf{C}\mathbf{\Sigma}^{T}\mathbf{K}_{2}^{T}\mathbf{K}_{1}^{T}

The set of linear variable changes includes: (1) a linear variable change :math:`\mathbf{K}_{1}`,
:code:`control2analysis` in the MPAS-JEDI repository, (2) a linear variable change :math:`\mathbf{K}_{2}`,
BUMP Vertical BALance (VBAL) in the SABER repository, and (3) a linear variable change :math:`\mathbf{\Sigma}`,
BUMP VARiance (VAR) in the SABER repository.

:math:`\mathbf{K}_{1}` transforms :code:`stream_function` and :code:`velocity_potential` to
:code:`uReconstructZonal` and :code:`uReconstructMeridional`. If users choose the pseudo relative humidity, :code:`relhum`,
as the moisture control variable, :math:`\mathbf{K}_{1}` will also transform :code:`relhum` to :code:`spechum`.
Please refer to :ref:`control2analysis` for explanation of :code:`control2analysis`.

:math:`\mathbf{K}_{2}` and :math:`\mathbf{\Sigma}` depend on a decomposition of :code:`velocity_potential`, :code:`temperature`,
and :code:`surface_pressure` into a "balanced" component that is predictable from :code:`stream_function`
and a residual, "unbalanced" component that is independent of :code:`streamfunction`.

:math:`\mathbf{K}_{2}` calculates the the balanced parts of :code:`velocity_potential`, :code:`temperature`, and :code:`surface_pressure`
from :code:`stream_function`, and returns the full code:`velocity_potential`, :code:`temperature`, and :code:`surface_pressure`,
that is, the sum of the balanced and unbalanced parts for each variable.
The balanced parts are calculated via linear regression with pre-diagnosed coefficients.
No balance is applied to :code:`spechum` or :code:`relhum` with other variables.

:math:`\mathbf{\Sigma}` is a diagonal matrix with pre-diagnosed error standard deviations for
:code:`stream_function`, :code:`spechum` (or :code:`relhum`), and the unbalanced parts of :code:`[velocity_potential, temperature, surface_pressure]`.

The block-diagonal correlation matrix :math:`\mathbf{C}` consists of univariate correlation matrices that define
the spatial autocorrelations of :code:`stream_function`, :code:`spechum` (or :code:`relhum`),
and the unbalanced parts of :code:`[velocity_potential, temperature, surface_pressure]`.
The application of these univariate correlation matrices is implemented using BUMP Normalized Interpolated Convolution from an Adaptive Subgrid
(`NICAS <https://github.com/benjaminmenetrier/nicas_doc/blob/master/nicas_doc.pdf>`_) with pre-diagnosed horizontal and vertical correlation length scales.


.. _BEstimation:

B Estimation
------------

Please see the :code:`operators-generation` section in SABER's :doc:`../saber/BUMP_getting_started` to
generate various BUMP statistics in general.

One missing operation in MPAS-JEDI is an inverse operation of :code:`control2analysis`
(i.e., from zonal and meridional winds to stream_function and velocity_potential) because solving the
Poisson's equation on the unstructured grid efficiently is not straightforward. Thus a
spherical harmonics-based NCL (NCAR Command Language) function is used on an intermediate
lat/lon grid, then the :code:`stream_function` and :code:`velocity_potential` fields on
the lat/lon grids are interpolated back to the MPAS native mesh.

With the samples of
:code:`[stream_function, velocity_potential, temperature, spechum or relhum, surface_pressure]`,
we diagnose the following B statistics: the regression coefficients defining the balanced components by using the BUMP VBAL driver,
the error standard deviations by using BUMP VAR driver, and the horizontal and vertical correlation length scales
by using the BUMP Hybrid DIAGnostics driver. Finally, given the diagnosed length scales,
various quantities used in the BUMP NICAS operations can be pre-calculated.
When we run the variational applications, we need to specify the location of saved netcdf output files
from BUMP VBAL, BUMP VAR, and BUMP NICAS.

If users want to diagnose the B statistics for hydrometeors, the variables names
:code:`[qc, qi, qr, qs, qg]` need to be added to :code:`input variables` yaml key in the parameter
estimation application together with :code:`[stream_function, velocity_potential, temperature, spechum or relhum, surface_pressure]`.
