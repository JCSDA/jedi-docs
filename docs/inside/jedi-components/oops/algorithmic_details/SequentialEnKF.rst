.. _top-oops-sequential-enkf:

Sequential ensemble Kalman filters
====================================

This note describes the formulation of sequential ensemble Kalman filter solvers implemented in OOPS. Unlike the local volume solvers described in :ref:`top-oops-ETKF`, which update each grid point using all observations within a localization radius simultaneously, sequential solvers process observations one at a time. After each observation is assimilated, its impact is propagated to the remaining observation ensembles and to the state ensemble via regression.

The MPI-parallel implementation of the sequential update (distributing observations across processors while keeping the global sequential ordering) follows `Anderson and Collins (2007) <https://doi.org/10.1175/JTECH2049.1>`_.

General description
-------------------

For each observation :math:`k` (processed sequentially), the algorithm performs three steps:

1. **Observation ensemble update**: Compute the analysis update for the :math:`k`-th observation ensemble using only that observation's innovation and error variance. This step is specific to the flavor of sequential EnKF (e.g., EAKF).

2. **Observation-to-observation regression**: For each remaining observation :math:`j > k`, compute the regression coefficient

   .. math::

      \beta_{jk} = \frac{\text{cov}(y_j^b, y_k^b)}{\text{var}(y_k^b)}

   and apply a localized update to the :math:`j`-th observation ensemble:

   .. math::

      \Delta y_j = \rho_{jk} \, \beta_{jk} \, \Delta y_k

   where :math:`\rho_{jk}` is the localization between observations :math:`j` and :math:`k`, and :math:`\Delta y_k` is the increment computed in step 1.

3. **Observation-to-state regression**: For each grid point :math:`i`, compute the regression coefficient

   .. math::

      \boldsymbol{\beta}_{ik} = \frac{\mathbf{X}'_i \, \mathbf{y}_k^{b\prime}}{\|\mathbf{y}_k^{b\prime}\|^2}

   and apply a localized update to the state ensemble at grid point :math:`i`:

   .. math::

      \Delta \mathbf{X}_i = \rho_{ik} \, \boldsymbol{\beta}_{ik} \, \Delta y_k^T

   where :math:`\rho_{ik}` is the localization between grid point :math:`i` and observation :math:`k`.

Here :math:`\mathbf{y}_k^{b\prime}` denotes the ensemble perturbations of the :math:`k`-th observation prior (deviations from the ensemble mean), and :math:`\mathbf{X}'_i` is the state ensemble perturbation matrix at grid point :math:`i`.


Localization
------------

The localization weights :math:`\rho_{jk}` (observation-to-observation) and :math:`\rho_{ik}` (model-grid-to-observation) are evaluated at run time by the same obs-space localization classes used by the LETKF/GETKF solvers, invoked via :code:`computeLocalization(p1, p2)` on 3D points produced by the model geometry iterator and :code:`ioda::ObsIterator`. The available methods, parameters, and YAML reference are documented in :ref:`ensDA-obs-space-loc`.

For vertical localization specifically, the EAKF solver requires the corresponding obs space to expose its vertical coordinate to the iterator by setting the :code:`iterator vertical coordinate` key (see :ref:`ensDA-obs-space-loc`); when unset, the iterator emits :code:`z = 0` and vertical localization will be inactive.


Ensemble Adjustment Kalman Filter (EAKF)
-----------------------------------------

The EAKF (`Anderson 2001 <https://doi.org/10.1175/1520-0493(2001)129%3C2884:AEAKFF%3E2.0.CO;2>`_) is the only sequential EnKF flavor currently implemented. For a scalar observation :math:`k` with prior ensemble :math:`\{y_{k,j}^b\}_{j=1}^{N_e}`, innovation :math:`d_k = y_k^o - \bar{y}_k^b`, and observation error variance :math:`\sigma_k^2`, the observation ensemble update is:

.. math::

   K_k = \frac{P_k^b}{P_k^b + \sigma_k^2}

.. math::

   P_k^a = (1 - K_k) \, P_k^b

.. math::

   \Delta y_{k,j} = K_k \, d_k + \left(\sqrt{\frac{P_k^a}{P_k^b}} - 1\right) (y_{k,j}^b - \bar{y}_k^b)

where :math:`P_k^b = \frac{1}{N_e - 1} \sum_{j=1}^{N_e} (y_{k,j}^b - \bar{y}_k^b)^2` is the prior ensemble variance, :math:`K_k` is the scalar Kalman gain, and :math:`P_k^a` is the posterior variance. The increment :math:`\Delta y_{k,j}` adjusts both the ensemble mean (first term) and the ensemble spread (second term) deterministically — no perturbed observations are needed.
