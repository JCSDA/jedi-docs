.. _BUMP_theoretical_overview:

General overview
----------------

Covariance models
*****************

Since geophysical models (atmosphere, ocean, sea-ice, land surface, etc.) use very diverse model grids, structured or unstructured, global or regional, sometimes with complex boundaries, a generic background error covariances model should consider all of them as unstructured meshes. The BUMP (Background error on Unstructured Mesh Package) software is precisely designed for this purpose, to diagnose and apply background error covariance related operators efficiently on any kind of grid.

Three categories of background error covariance models are currently handled in BUMP:

* The **ensemble covariance** model is built as a localized sample covariance matrix:

  .. math::

    \mathbf{B}_e = \widetilde{\mathbf{B}} \circ \mathbf{L}

  where:

  * :math:`\widetilde{\mathbf{B}} \in \mathbb{R}^{n \times n}` is the sample covariance matrix estimated from an ensemble,
  * :math:`\mathbf{L} \in \mathbb{R}^{n \times n}` is the localization matrix,
  * :math:`\circ` denotes the Schur product (element-by-element).

* The **static covariance** model is built with successive parametrized operators:

  .. math::

     \mathbf{B}_s = \mathbf{U}_b \boldsymbol{\Sigma} \mathbf{C} \boldsymbol{\Sigma} \mathbf{U}_b^\mathrm{T}

  where:

  * :math:`\mathbf{U}_b \in \mathbb{R}^{n \times n}` is a multivariate balance operator,
  * :math:`\boldsymbol{\Sigma} \in \mathbb{R}^{n \times n}` is a diagonal matrix containing standard deviations,
  * :math:`\mathbf{C} \in \mathbb{R}^{n \times n}` is a block diagonal (univariate) correlation matrix.

* The **hybrid covariance** model is a linear combination of both previous models:

  .. math::

     \mathbf{B}_h = \beta_1 \mathbf{B}_1 \beta_1^T + \beta_2 \mathbf{B}_2 \beta_2^T

  where :math:`\beta_i \in \mathbb{R}^{n \times n}` is a diagonal matrix providing local weights for the component :math:`\mathbf{B}_i`. In BUMP, :math:`\mathbf{B}_1` is always an ensemble covariance but :math:`\mathbf{B}_2` can be either a static or an ensemble covariance, potentially at a lower resolution than :math:`\mathbf{B}_1`. 

The goal of BUMP is to estimate and apply all the operators required for these covariance models.

Code basics
***********

The core of the code is written in object-oriented Fortran 90 (~ 35,000 lines), but it also has OOPS-based C++ interfaces (~ 5,000 lines). Some Python scripts are also available (~ 4,000 lines), especially to plot results.

BUMP usage
**********

BUMP always works in two steps:

1. Operators are prepared and written into files (either model state files for 3D fields, or specific BUMP files). Parameters for these operators can be specified in the input configuration and also be diagnosed from ensembles of states. For the case of an hybrid covariance with an external static covariance, pseudo-ensemble members are generated from the static covariance square-root (randomization process). 

2. In applications (variational run, Dirac test), BUMP loads pre-computed operators and applies them to input fields when the **B** matrix is needed.

For both steps, the BUMP setup (in :code:`BUMP.h`) follows the same process:

* Setup BUMP configuration using both SABER block configuration and background.
* Read universe size from a model file (optional).
* Initialize BUMP instances:

  * parallelization aspects (MPI, OpenMP, parallel I/O),
  * configuration parameters (consistency checking),
  * missing values,
  * output unit for logging,
  * random number generator,
  * model and internal grids geometry,
  * masks,
  * etc.

* Pass ensemble member pointers (if already loaded in OOPS).
* Read input fields from model files (optional).
* Read ensemble members sequentially (if not loaded in OOPS).
* Run drivers:

  * **Dead-end** drivers are run first. They implement some diagnostics used for scientific experiments, but their outputs are not used any further in the code.
  * The **VBAL** driver (for Vertial BALance) computes the vertical balance operator using the first ensemble and writes output data. Data can also be loaded directly. A companion driver performs adjoint and inverse tests.
  * The **VAR** driver (for VARiance) computes the variance of the ensemble, optionally filters it with an iterative method.
  * The **HDIAG** driver (for Hybrid DIAGnostics) computes local correlation and localization functions from ensembles and determines their length-scales. It also estimates hybrid weights if necessary. Output data are interpolated on the internal grid and stored into the CMAT object (for Correlation MATrix). They can also be written in specific files.
  * The **CMAT** fields can also be read from files, modified via the interface, or via configuration parameters.
  * The **NICAS** driver (for Normalized Interpolated Convolution on an Adaptive Subgrid) computes indices and weights for the NICAS smoother using the CMAT data and writes specific output data for further use. Data can also be loaded directly from files. A companion driver performs various tests (adjoint, Dirac).
  * The **PsiChiToUV** driver is a linear variable change operator, from streamfunction and velocity potential to horizontal wind components, using smooth estimates of the derivatives.

* Partial memory release.
* Write the model fields computed in the previous step and specified in the :code:`output` section (optional).
* Apply VBAL, VAR and NICAS operators to fields specified in the :code:`operators application` section (optional).

Specific documentation
**********************
Some theoretical documentation is available in PDF documents:

* about covariance filtering: `covariance_filtering.pdf <https://github.com/benjaminmenetrier/covariance_filtering/blob/master/covariance_filtering.pdf>`_
* about multivariate localization: `multivariate_localization.pdf <https://github.com/benjaminmenetrier/multivariate_localization/blob/master/multivariate_localization.pdf>`_
