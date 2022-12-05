.. _top-oops-obserror:

Diagonal observation error covariance
=====================================

The diagonal observation error covariance :math:`R` implementation in OOPS can be used both for any of the :doc:`toy models <../toy-models/index>`, and for the models that use :doc:`UFO <../../ufo/index>`.

Observation error standard deviations for :math:`R` are read as an :code:`ObsError` group from the observation file.

The covariance can be configured using the following options:

* :code:`obs perturbations amplitude` (optional, default value is 1.0) -- a multiplier used when generating a random sample of observation perturbations using the observation error covariance matrix (standard deviations are multiplied by this number)
* :code:`zero-mean perturbations`: logical variable with a default of :code:`false`. Set to :code:`true` to constrain observation perturbations to have a zero ensemble mean (can be used in the :doc:`Ensemble of Data Assimilations (EDA) <../applications/ensemble-applications>`). If this option is set to :code:`true`, the following options also have to be set:

  - :code:`member`: ensemble member index (1-based);
  - :code:`number of members`: number of ensemble members.

.. important::
  For the zero-mean perturbations option to work, the following requirements must be satisfied:

  1. The :code:`obs perturbations seed` option in the :code:`obs space` section must be set to the same value for all ensemble members.
  2. All ensemble members must use the same observations in the same order.

A diagonal :math:`R` can be configured as:

.. code-block:: yaml

 obs error:
   covariance model: diagonal

For an EDA experiment where the amplitude of observation perturbations is half of its default value, the following YAML settings can be used:

.. code-block:: yaml

 obs error:
   covariance model: diagonal
   obs perturbations amplitude: 0.5

For an EDA experiment with 10 ensemble members, and perturbing observations ensuring zero-mean perturbations, a diagonal :math:`R` for the 2nd ensemble member can be set up as:

.. code-block:: yaml

 obs error:
   covariance model: diagonal
   zero-mean perturbations: true
   member: 2
   number of members: 10
