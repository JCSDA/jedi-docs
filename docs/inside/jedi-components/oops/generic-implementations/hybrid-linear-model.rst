.. _top-oops-hybrid-linear-model:

Hybrid tangent linear model
=====================================

OOPS's hybrid tangent linear model (H-TLM) implementation, named :code:`HybridLinearModel` in the code, can be used for any :code:`MODEL` which has implemented a :code:`LinearModel` in its interface.

The :code:`LinearModel` is instantiated via a factory. To make this a :code:`HybridLinearModel`, the :code:`name` option in the :code:`linear model` subconfiguration must be set to :code:`HTLM`.

Coefficients can be generated either "on the fly" in a :doc:`Variational <../applications/variational>` run, or precalculated using :doc:`GenHybridLinearModelCoeffs <../applications/gen-hybrid-linear-model-coeffs>`.

Assuming the coefficients have been precalculated, the :code:`HybridLinearModel` can be configured using the following options within the :code:`linear model` subconfiguration:

* :code:`name`: must be "HTLM" in order to instantiate a :code:`HybridLinearModel` via the :code:`LinearModel` factory
* :code:`simple linear model`: subconfiguration for the :code:`SimpleLinearModel` wrapper:

  - :code:`linear model`: subconfiguration for the underlying :code:`MODEL`-specific :code:`LinearModel`
  - :code:`geometry` (optional): subconfiguration for the :code:`MODEL`-specific :code:`Geometry` of the :code:`MODEL`-specific :code:`LinearModel` when using :code:`SimpleLinearModelMultiresolution` or :code:`SimpleLinearModelResidualForm`
  - :code:`residual form` (optional, default :code:`false`): boolean determining whether :code:`SimpleLinearModelResidualForm` is used over :code:`SimpleLinearModelMultiresolution`

* :code:`update tstep`: timestep of the :code:`HybridLinearModel`, as used by :code:`CostFct4DVar`/:code:`CostFctWeak` (i.e. the time between :code:`HybridLinearModel` updates using the coefficients); a duration in ISO 8601 format
* :code:`variables`: list of variables, as used by :code:`CostFct4DVar`/:code:`CostFctWeak` (i.e. the analysis variables); must be a superset of :code:`coefficients.update variables`
* :code:`coefficients`: subconfiguration for the :code:`HybridLinearModelCoeffs` class:

  - :code:`input`: subconfiguration for the reading of coefficients from file, consisting of :code:`base filepath` (string) and :code:`one file per task` (boolean; currently, this must be set to :code:`true`)
  - :code:`update variables`: list of variables which are updated by the coefficients (having previously been trained on them)
  - :code:`influence region size`: number of vertical levels in column of influence (must be an odd number to allow centering on the level of interest)
  - :code:`time window`: subconfiguration for the :code:`TimeWindow` over which coefficients are applied (i.e. the assimilation window)

Note that the configuration must match that used to precalculate the coefficients (with the exception of :code:`input`, which would be set to :code:`output` for the precalculation).

Here is an example configuration as would be used to run 4D-Var using the :code:`Variational` application when coefficients have been precalculated:

.. code-block:: yaml

  # rest of Variational configuration
  linear model:
    name: HTLM
    simple linear model:
      linear model:
        # MODEL-specific subconfiguration
    update tstep: PT1H
    variables: [x, y, z]
    coefficients:
      input:
        base filepath: path/to/coeffs
        one file per task: true
      update variables: [x, y]
      influence region size: 5
      time window:
        begin: 2024-01-16T06:00:00Z
        length: PT6H
  # rest of Variational configuration

To instead generate coefficients "on the fly" (during the execution of :code:`Variational`), more options are needed in the configuration. These options are the same as would be required to generate the coefficients using :doc:`GenHybridLinearModelCoeffs <../applications/gen-hybrid-linear-model-coeffs>`, and are detailed on that page.
