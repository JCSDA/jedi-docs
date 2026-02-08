.. _top-oops-obserror:

Diagonal observation error covariance (l95/QG/UFO)
==================================================

The generic diagonal observation error covariance :math:`R` implementation in OOPS has been removed and replaced with specific implementations where one is required (in the l95 and QG toy models, in UFO, and in some model interfaces). For the vast majority of use cases, the new generic diagonal :math:`R` implmentation can be used instead and will exactly replicate the old OOPS implementation.

The old behavior of defaulting to a diagonal ObsError when not including an :code:`ObsError:` has been preserved, and can still also be explicitly included as:

.. code-block:: yaml

    obs error:
      covariance model: diagonal

For EDA experiments, the :code:`obs perturbations amplitude` setting remains in all implementations and can be included in the same format as before:

.. code-block:: yaml

    obs error:
      covariance model: diagonal
      obs perturbations amplitude: 0.5

Availability of the :code:`zero-mean perturbations` feature for EDA is now implementation specific, but is available in the new generic diagonal observation error covariance in UFO. See :ref:`ufoObsErrorDiag` for more information.
