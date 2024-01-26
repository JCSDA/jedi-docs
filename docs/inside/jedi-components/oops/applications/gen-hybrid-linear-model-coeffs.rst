.. _top-oops-gen-hybrid-linear-model-coeffs:

Generate hybrid tangent linear model coefficients in OOPS
=========================================================

:code:`GenHybridLinearModelCoeffs` is an application used for calculating coefficients for a hybrid tangent linear model (H-TLM) over an assimilation window, and writing these to files.

OOPS's H-TLM implementation, named :code:`HybridLinearModel` in the code, can be used for any :code:`MODEL` which has implemented a :code:`LinearModel` in its interface.

The coefficient files can be read in during a run of the :doc:`Variational <variational>` application, in order to use a :code:`HybridLinearModel` as the :code:`LinearModel` in 4D-Var. There are further details on how to do this on the page for the :doc:`HybridLinearModel <../generic-implementations/hybrid-linear-model>`.

The :code:`LinearModel` is instantiated via a factory. To make this a :code:`HybridLinearModel`, the :code:`name` option in the :code:`linear model` subconfiguration must be set to :code:`HTLM`.

Description
-----------

The code has been implemented to follow the method in Payne (2021). Within this scope, the user must decide:

* The initial conditions for the nonlinear model control member (generally a background for the assimilation window of interest).
* Whether to explicitly provide initial conditions for the nonlinear model ensemble members, or generate them via perturbing the control member.
* The model used to forecast these initial conditions through the assimilation window of interest and its resolution.
* The underlying simple linear model and its resolution.
* The resolution at which to calculate and apply H-TLM coefficients. Note that if this is different from the previous resolution, then the multiresolution H-TLM method will be used, and the residual formulation of this method can optionally be used as well.
* The number of vertical levels in the columns of influence.
* The variables which H-TLM coefficients will be calculated for and applied to.
* The timestep of the H-TLM, which may be a multiple of the simple linear model's.
* Whether to do any root-mean-squared-by-level scaling and/or Tikhonov regularization/ridge regression.

The section below contains some more details on each of these choices.

Configuration
-------------

The application can be configured using the following options:

* :code:`update geometry`: subconfiguration for the :code:`MODEL`-specific :code:`Geometry` at which H-TLM coefficients will be calculated and applied (this must match the intended analysis geometry in 4D-Var)
* :code:`hybrid linear model`: subconfiguration for the :code:`HybridLinearModel`:

  - :code:`name`: must be "HTLM" in order to instantiate a :code:`HybridLinearModel` via the :code:`LinearModel` factory
  - :code:`simple linear model`: subconfiguration for the :code:`SimpleLinearModel` wrapper:

    - :code:`linear model`: subconfiguration for the underlying :code:`MODEL`-specific :code:`LinearModel`
    - :code:`geometry` (optional): subconfiguration for the :code:`MODEL`-specific :code:`Geometry` of the :code:`MODEL`-specific :code:`LinearModel` when using :code:`SimpleLinearModelMultiresolution` or :code:`SimpleLinearModelResidualForm`
    - :code:`residual form` (optional, default :code:`false`): boolean determining whether :code:`SimpleLinearModelResidualForm` is used over :code:`SimpleLinearModelMultiresolution`

  - :code:`update tstep`: timestep of the :code:`HybridLinearModel`, as used by :code:`CostFct4DVar`/:code:`CostFctWeak` (i.e. the time between :code:`HybridLinearModel` updates using the coefficients); a duration in ISO 8601 format
  - :code:`variables`: list of variables, as used by :code:`CostFct4DVar`/:code:`CostFctWeak` (i.e. the analysis variables); must be a superset of :code:`coefficients.update variables`
  - :code:`coefficients`: subconfiguration for the :code:`HybridLinearModelCoeffs` class:

    - :code:`output`: subconfiguration for the writing of coefficients to file, consisting of :code:`base filepath` (string) and :code:`one file per task` (boolean; currently, this must be set to :code:`true`)
    - :code:`update variables`: list of variables which are updated by the coefficients (having previously been trained on them)
    - :code:`influence region size`: number of vertical levels in column of influence (must be an odd number to allow centering on the level of interest)
    - :code:`time window`: subconfiguration for the :code:`TimeWindow` over which coefficients are applied (i.e. the assimilation window)
    - :code:`calculator`: subconfiguration for the :code:`HtlmCalculator` class which calculates the coefficients using the ensemble of nonlinear model differences and ensemble of simple linear models:

      - :code:`rms scaling` (optional, default :code:`false`): boolean determining whether or not root-mean-squared-by-level scaling is applied during the calculation; this is to avoid ill-conditioning of the matrices in the problem (see Section 3a of Payne (2021)); currently, the capability for this must be implemented in the :code:`MODEL` interface, so it is optional; in future, when a :code:`MODEL`-generic capability is implemented, this feature will be mandatory
      - :code:`regularization` (optional): subconfiguration for the Tikhonov regularization/ridge regression applied during the calculation; this is to relax the H-TLM towards its underlying simple linear model in particular regions of the model space (see Section 4b of Payne (2021)); this part of the code is currently undergoing changes and documentation will be provided when those are complete

    - :code:`ensemble`: subconfiguration for the :code:`HtlmEnsemble` class which runs the ensemble of nonlinear models and ensemble of simple linear models:

      - :code:`model`: subconfiguration for the :code:`MODEL`-specific :code:`Model`
      - :code:`model geometry`: subconfiguration for the :code:`MODEL`-specific :code:`Geometry` of the :code:`Model`
      - :code:`nonlinear control`: subconfiguration for the :code:`MODEL`-specific :code:`State` that forms the nonlinear control member initial condition
      - :code:`nonlinear ensemble`: subconfiguration for the nonlinear ensemble initial conditions, which has two options:

        - :code:`read`: subconfiguration for a :code:`StateEnsemble`, used if nonlinear ensemble initial conditions are being read in from file, which will contain :code:`MODEL`-specific elements
        - :code:`generate`: subconfiguration used of nonlinear ensemble initial conditions are being generated by perturbing the nonlinear control member initial condition:

          - :code:`ensemble size`: the number of ensemble members
          - :code:`background error`: subconfiguration for the :code:`ModelSpaceCovarianceParameters`, which may contain :code:`MODEL`-specific elements
          - :code:`variables`: list of variables to perturb

Here is an example configuration for the application:

.. code-block:: yaml

  update geometry:
    # MODEL-specific subconfiguration
  hybrid linear model:
    name: HTLM
    simple linear model:
      linear model:
        # MODEL-specific subconfiguration
    update tstep: PT1H
    variables: [x, y, z]
    coefficients:
      output:
        base filepath: path/to/coeffs
        one file per task: true
      update variables: [x, y]
      influence region size: 5
      time window:
        begin: 2024-01-16T06:00:00Z
        length: PT6H
      calculator:
        rms scaling: false
      ensemble:
        model:
          # MODEL-specific subconfiguration
        model geometry:
          # MODEL-specific subconfiguration
        nonlinear control:
          # MODEL-specific subconfiguration
        nonlinear ensemble:
          read:
            # partially MODEL-specific subconfiguration

References
----------

Payne, T. J. (2021). A Hybrid Differential-Ensemble Linear Forecast Model for 4D-Var. *Monthly Weather Review, 149*, 3-19. DOI:`10.1175/MWR-D-20-0088.1 <https://doi.org/10.1175/MWR-D-20-0088.1>`_
