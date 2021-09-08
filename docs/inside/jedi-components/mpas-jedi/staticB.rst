  .. _top-mpas-jedi-staticB:

.. _staticB:

Static Background Error Covariance
==================================

.. _generalBdesign:

General B Design
----------------


The multivariate background error covariance :math:`\mathbf{B}` is designed primarily to follow that of WRFDA and GSI.
It uses both a generic component from the SABER repository and a model-specific compoment from the
MPAS-JEDI repository. It is impliemented as a set of linear variable changes to a block-diagonal
correlation matrix :math:`\mathbf{C}`.

.. math::

   \mathbf{B}=\mathbf{K}_{1}\mathbf{K}_{2}\mathbf{\Sigma}\mathbf{C}\mathbf{\Sigma}^{T}\mathbf{K}_{2}^{T}\mathbf{K}_{1}^{T}

The set of linear variable changes includes: (1) a linear variable change :math:`\mathbf{K}_{1}`,
:code:`control2analysis` in the MPAS-JEDI repository, (2) a linear variable change :math:`\mathbf{K}_{2}`,
BUMP Vertical BALance (VBAL) in the SABER repository, and (3) a linear variable change :math:`\mathbf{\Sigma}`,
BUMP VARiance (VAR) in the SABER repository.

Please refer to :ref:`control2analysis` for explanation of :code:`control2analysis`.

BUMP VBAL considers the following vertical balances between variables
:code:`[stream_function, velocity_potential, temperature, spechum, surface_pressure]`.

.. code:: yaml

   bump:
     vbal_block:     [1, 1,0, 0,0,0, 1,0,0,0]  # Activate the multivariate blocks
                                               # K = [ I  0  0  0  0 ]
                                               #     [ K1 I  0  0  0 ]
                                               #     [ K2 0  I  0  0 ]
                                               #     [ 0  0  0  I  0 ]
                                               #     [ K3 0  0  0  I ]

I.e., it calculates the balanced part of :code:`velocity_potential`, :code:`temperature`, and
:code:`surface_pressure` based on :code:`stream_function`. Note that :code:`K1` is a diagonal
matrix which considers the level-by-level balance, while :code:`K2` and :code:`K3` are full matrices,
which consider the vertical balace between one variable at all vertical levels and the other variable
at a given level.

BUMP VAR is a diagonal matrix with error standard deviations for
:code:`[stream_function, velocity_potential, temperature, spechum, surface_pressure]`.
Although the variable name is not clear on this, here :code:`velocity_potential`,
:code:`temperature`, and :code:`surface_pressure` are their "unbalanced" parts.

The block-diagonal correlation matrix is a form of univariate correlation matrix for
"unbalanced" variables using BUMP Normalized Interpolated Convolution from on Adaptive Subgrid (NICAS)
with pre-diagnosed horizontal and vertical correlation length scales.


.. _BEstimation:

B Estimation
------------

Please see the :code:`operators-generation` section in SABER's :doc:`../saber/getting_started` to
generate various BUMP statistics in general.

One missing operation in MPAS-JEDI is an inverse operation of :code:`control2analysis`
(i.e., from zonal and meridional winds to stream_function and velocity_potential) because solving the
Poisson's equation on the unstructured grid efficiently is not straightforward. Thus a
spherical harmonics-based NCL (NCAR Command Language) function is used on an intermediate
lat/lon grid, then the :code:`stream_function` and :code:`velocity_potential` fields on
the lat/lon grids are interpolated back to the MPAS native mesh.

With the samples of
:code:`[stream_function, velocity_potential, temperature, spechum, surface_pressure]`,
we diagnose the vertical balances (BUMP VBAL), the error standard deviation (BUMP VAR),
and the horizontal and vertical length scales (BUMP HDIAG). Finally with the length
scales diagnostics (CMAT file) from BUMP HDIAG, the BUMP NICAS operations can be calculated.
When we run the variational applications, we need to specify the location of saved netcdf output files
from BUMP VBAL, BUMP VAR, and BUMP NICAS.

If users want to diagnose the B statistics for hydrometeors, the variables names
:code:`[qc, qi, qr, qs, qg]` need to be added to :code:`input variables` yaml key in the parameter
estimation application together with :code:`[stream_function, velocity_potential, temperature, spechum, surface_pressure]`.
