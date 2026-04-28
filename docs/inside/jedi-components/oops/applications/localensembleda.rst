.. _top-oops-localensda:

Local ensemble data assimilation in OOPS
========================================

The :code:`LocalEnsembleDA` application is a generic application for running data assimilation with local ensemble transform Kalman filters (ETKF). It can be extended to use any local ETKF that updates state gridpoints independently from each other by using observations within a localization distance from a gridpoint.

The configuration file (e.g. :code:`letkf.yaml`) for running the :code:`LocalEnsembleDA` application must contain the following top-level sections:

* :code:`geometry`: geometry for the background and analysis files.

* :code:`background`: ensemble background members (currently used both for computing :math:`\mathcal{H}(\mathbf{x})` and as backgrounds).

* :code:`observations`: describes observations, observation error statistics, observation operators used in the assimilation, and the horizontal localization.

* :code:`local ensemble DA`: configuration of the local ensemble DA solver package.

* :code:`driver`: describes optional modifications to the behavior of the :code:`LocalEnsembleDA` driver.

* Output sections may have to be defined depending on the :code:`driver` configuration. Further information can be found in the driver section below.


Local ensemble DA configuration
-------------------------------

The options available to configure the :code:`local ensemble DA` configuration section are as follows.

* :code:`solver`,
* :code:`use linear observer`.
* :code:`unperturbed obs ensemble member index`.

These options are described in the following sections.

Local volume solvers
^^^^^^^^^^^^^^^^^^^^

The specific type of local ensemble transform Kalman filter can be chosen with the :code:`solver` option.
The following variants are available:

* :code:`Stochastic LETKF`: Stochastic Local Ensemble Transform Kalman filter.
* :code:`Deterministic LETKF`: Deterministic Local Ensemble Transform Kalman filter.
* :code:`Stochastic GETKF`: Stochastic Gain form of the local Ensemble Transform Kalman filter.
* :code:`Deterministic GETKF`: Deterministic Gain form of the local Ensemble Transform Kalman filter.

The algorithmic details of these filters can be found :ref:`here <top-oops-ETKF>`.

**Deterministic solver implementations**

Two ETKF implementations are supported for the deterministic solvers:

* C++ implementation using Eigen,
* GSI Fortran implementation using LAPACK.

The Fortran implementation is used if the parameter :code:`fortran ETKF` is set to :code:`true`.
By default, this parameter is :code:`false` for the LETKF solver and :code:`true` for the GETKF solver.

For example, the C++ implementation of the deterministic GETKF solver can be selected with the following yaml snippet:

.. code-block:: yaml

   local ensemble DA:
     solver: Deterministic GETKF
     fortran ETKF: false

The stochastic solvers always use the Eigen solver implementation, so the :code:`fortran ETKF` option has no effect.

**GETKF solver options**

Using either of the GETKF solvers also requires specifying parameters for the modulation product that approximates model-space localization in the vertical.
The Gaspari-Cohn localization function :cite:`GaspariCohn99` is used to modulate the covariance matrix of the vertical coordinate.

The following parameters must appear in the :code:`vertical localization` subsection:

* :code:`fraction of retained variance`: fraction of the variance retained after the eigenspectrum of the vertical localization function is truncated. The fraction is expressed as a number between 1 and 0 with 1.0 retaining all eigenvectors and 0.0 retaining only the first eigenvector.

* :code:`lengthscale units`: name of variable for vertical localization. This is a model-dependent value. For example, the FV3 implementation currently supports two types of units: :code:`logp` -- logarithm of pressure at mid level of the vertical column with surface pressure set to 1e5 Pa at all points, and :code:`levels` -- indices of vertical levels.

* :code:`lengthscale`: localization distance in the above units, at which Gaspari-Cohn localization function is zero.

An example of using the GETKF solver in FV3 is as follows:

.. code-block:: yaml

   local ensemble DA:
     solver: Deterministic GETKF
     vertical localization:
       fraction of retained variance: .95
       lengthscale units: logp
       lengthscale: 1.5


Sequential EnKF
^^^^^^^^^^^^^^^^

A sequential ensemble Kalman filter framework has been implemented that processes observations one at a time, updating the ensemble state after each observation using regression-based updates (`Anderson and Collins 2007 <https://doi.org/10.1175/JTECH2049.1>`_). Unlike the LETKF and GETKF, which update each grid point using all observations within a local volume simultaneously, the sequential EnKF assimilates observations one at a time and propagates each observation's impact to the state and remaining observation ensembles. See :ref:`top-oops-sequential-enkf` for algorithmic details.

The only flavor currently implemented is the Ensemble Adjustment Kalman Filter (EAKF):

.. code-block:: yaml

   local ensemble DA:
     solver: EAKF

The sequential EnKF supports the same inflation methods (multiplicative, RTPP, RTPS), observation localizations, and 4D (multi-time) updates as the other solvers. The key difference in localization behavior is that the sequential EnKF applies obs-obs localization (between pairs of observations) in addition to the usual grid-obs localization applied during the state update.

.. note::

   The sequential EnKF currently runs through the ``LocalEnsembleDA`` application and inherits from ``LocalEnsembleSolver``. This is a temporary arrangement — the sequential EnKF is not a local ensemble solver. A future refactor will extract a common ``EnsembleSolver`` base class.


Use linear observer
^^^^^^^^^^^^^^^^^^^

:code:`use linear observer`

**to be added**


Unperturbed member
^^^^^^^^^^^^^^^^^^

Both stochastic solvers perturb the observations according to the observation error covariance matrix, with an independent perturbation computed for each ensemble member. It is possible to leave one member unperturbed by setting the option :code:`unperturbed obs ensemble member index` to the index of that member in the ensemble. The index can take values between :math:`0` and :math:`N_e - 1` inclusive, where :math:`N_e` is the number of ensemble members.

This option has no effect if the :code:`Deterministic LETKF` or :code:`Deterministic GETKF` solvers are selected.

For example, to leave the ensemble member with index 6 unperturbed when running the stochastic GETKF solver, the following yaml configuration can be used:

.. code-block:: yaml

   local ensemble DA:
     solver: Stochastic GETKF
     unperturbed obs ensemble member index: 6


Obs Error Covariances in the ensemble solvers
---------------------------------------------

Available `R`-matrix representations in the local solvers are model dependent, with models generally either using :ref:`obs error classes from UFO <ObsErrorOperatorsUFO>` or implementing their own diagonal representation. The `R`-matrix representation is specified as follows for each obs space:

.. code-block:: yaml

   observations:
     observers:
     - obs space:
         name: radiosonde
       ...
       obs error:
         covariance model: diagonal

For models which use UFO `R`-matrices, an additional representation is currently supported, using cross-variable/inter-channel correlations. This is declared as follows:

.. code-block:: yaml

   obs error:
     covariance model: cross variable covariances
     input file: obserror_correlations.nc4

Here, :code:`input file` is a file containing cross-variable or inter-channel correlations. See :ref:`obsErrorCrossVar` for more information, including the required format for :code:`input file`. As with the diagonal `R`-matrix, the observation error standard deviations are read as an :code:`ObsError` group from the observation file.


Observation-space localization supported in the ensemble solvers
----------------------------------------------------------------

Observation-space :math:`R-localization` is used in all local solvers following :cite:`FrolovEnKF24`.
The localization procedure is applied independently at each model grid point in turn.

The :code:`obs localizations` section specifies a sequence of localization functions.
Each localization function in the sequence does the following:

* Select observations within a chosen distance of the model grid point,
* Optionally compute weights for the observation error covariances according to a distance-dependent function.
  By default the weights are equal to one everywhere.
* Return a vector of weights of length equal to the ObsSpace.

The selection of observations is performed with a KD-tree distance search.

At each model grid point a vector of final localization weights (with length equal to the ObsSpace) is initialized to contain ones.
This vector is then multiplied (element-wise) by the weights returned by each localization function in the sequence.
(In other words, we assume that the localizations can be applied in any order.)
The final weights are then used to scale the observation error covariance matrix.

The sequence of localizations is applied separately to each obs space.

There are two main types of observation-space localization function: those that act horizontally, and those that act vertically.
Observation-space horizontal localization can be used for both the LETKF and GETKF solvers, whereas observation-space vertical localization should only be used for the LETKF solvers.
Further discussion of this point can be found :ref:`here <top-oops-ETKF>`.

If using observation-space vertical localization for the LETKF solvers, the 3D geometry iterator must be enabled to carry model height information into the vertical localization routines.
The geometry iterator is model-specific and the yaml syntax varies between models. In the FV3 model the 3D iterator can be enabled as follows:

.. code-block:: yaml

   geometry:
     iterator dimension: 3


The following horizontal localization methods are available in ufo:

..
  Warning: the links below may change in the future.

* `Box-car <https://github.com/JCSDA-internal/ufo/blob/develop/src/ufo/obslocalization/ObsHorLocalization.h>`_ (weights set to 1 inside the localization distance, 0 outside),
* `Gaspari-Cohn <https://github.com/JCSDA-internal/ufo/blob/develop/src/ufo/obslocalization/ObsHorLocGC99.h>`_,
* `Second-order auto-regressive (SOAR) <https://github.com/JCSDA-internal/ufo/blob/develop/src/ufo/obslocalization/ObsHorLocSOAR.h>`_.

Additional horizontal localizations are supported in SOCA (Rossby radius based) and FV3-JEDI (soil-specific localization).

An example of horizontal localization using the Gaspari-Cohn function is:

.. code-block:: yaml

   observations:
     observers:
     - obs space:
         name: radiosonde
       ...
       obs localizations:
       - localization method: Horizontal Gaspari-Cohn    # inflate errors with Gaspari-Cohn function, based on the
                                                         #   horizontal distance from the updated grid point
         lengthscale: 1000e3                             # horizontal localization distance in meters

When using the EAKF solver, the same :code:`obs localizations` are also applied as obs-obs localization between pairs of observations during the sequential update, in addition to the grid-obs localization applied during the state update.

The Gaspari-Cohn, SOAR, and Box Car methods are also supported for vertical localization. An example of vertical localization using the Gaspari-Cohn function is:

.. code-block:: yaml

   observations:
     observers:
     - obs space:
         name: radiosonde
       ...
       obs localizations:
       - localization method: Vertical localization      # As above but for vertical localization
         localization function: Gaspari Cohn             # Function for vertical localization
         ioda vertical coordinate group: MetaData        # Group containing the below vertical coordinate
         ioda vertical coordinate: height                # Name of UFO variable storing the vertical coordinate
                                                         #   of the observation locations
         vertical lengthscale: 6e3                       # vertical localization distance in units of given coord


Inflation supported in the ensemble solvers
-------------------------------------------

Several covariance inflation methods are supported:

* multiplicative prior inflation:

.. math::

   {P^{b}}'=\alpha P^{b}

Parameter of multiplicative inflation is controlled by :code:`inflation.mult` configuration value, for example:

.. code-block:: yaml

   local ensemble DA:
     inflation:
       mult: 1.1

* RTPP (relaxation to prior perturbation), :cite:`ZhangRTPP04`:

.. math::

   {X_{a}^{i}}' = \alpha X_{b}^{i} + (1-\alpha) X_{a}^{i}

Parameter of RTPP inflation is controlled by :code:`inflation.rtpp` configuration value, for example:

.. code-block:: yaml

   local ensemble DA:
     inflation:
       rtpp: 0.5

* RTPS (relaxation to prior spread), :cite:`WhitakerHamill12`:

.. math::

   {X_{a}^{i}}' = X_{a}^{i}  (\alpha  \frac{\sigma_{b}-\sigma_{a}}{\sigma_{a}}+1)

Parameter of RTPS inflation is controlled by :code:`inflation.rtps` configuration value, for example:

.. code-block:: yaml

   local ensemble DA:
     inflation:
       rtps: 0.6


Cross validation supported in the ensemble solvers
--------------------------------------------------

In order to use cross validation (`Buehner, 2020 <https://doi.org/10.1175/MWR-D-19-0402.1>`_), one can specify:

.. code-block:: yaml

  local ensemble DA:
    cross validation:
      number of subensembles: 5

This makes use of a :code:`SubensembleSplitter` class to split the ensemble of :math:`N_{e}` members into :math:`N_{sub}` subensembles. The value of :math:`N_{sub}` is assigned using the mandatory :code:`number of subensembles` configuration value. The value of :code:`number of subensembles` must be between 2 and the number of ensemble members :math:`N_{e}`, and must cleanly divide the number of ensemble members :math:`N_{e}`.

Currently there are two splitting methods implemented to split the ensemble. The contiguous split divides the ensemble into :math:`N_{sub}` subensembles evenly, with the first :math:`N_{e}/N_{sub}` members belonging to subensemble 1, the second :math:`N_{e}/N_{sub}` members belonging to subensemble 2, etc.

The contiguous split happens by default if no :code:`splitting method` is specified, but if one wishes to explicitly split via this method:

.. code-block:: yaml

  local ensemble DA:
    cross validation:
      number of subensembles: 5
      splitting method: Contiguous #default value

Alternatively, one can split the ensemble randomly (with an optional seed):

.. code-block:: yaml

  local ensemble DA:
    cross validation:
      number of subensembles: 5
      splitting method: Random
      random seed: 0 #default value

This method also splits the ensemble into :math:`N_{sub}` subensembles evenly, except each ensemble member will be assigned to a subensemble at random.

Note that if one is using a modulated ensemble by using the stochastic GETKF solver, no further options need to be specified as the entire modulated ensemble is split evenly for you. Cross validation for the deterministic GETKF solver is not yet supported.

NOTE about obs distributions
-----------------------------
Currently Local Ensemble DA supports :code:`InefficientDistribution` and :code:`Halo` obs distribution. When :code:`InefficientDistribution` distribution is used, all observations and :math:`\mathcal{H}(\mathbf{x})` are replicated on all MPI ranks. When :code:`Halo` distribution is used, only observations needed on this rank are stored on each rank. :code:`Halo`  distribution allows for more efficient memory management compared to :code:`distribution.name: InefficientDistribution`, however at the expense of potentially poor load management compared to :code:`distribution.name: RoundRobin`. For optimal combination of memory and load balancing, we developed an option to run Local Ensemble DA in the observer-only mode with :code:`distribution.name: RoundRobin`. Then one can read ensemble of :math:`\mathcal{H}(\mathbf{x})` from disk using :code:`driver.read HX from disk == true`, :code:`distribution.name: Halo` obs distribution, and :code:`driver.do posterior observer == false`.

The type of the obs. distribution is specified for each ObsSpace. For example:

.. code-block:: yaml

 observations:
   observers:
   - obs space:
       distribution:
         name: Halo
         halo size: 5000e3

Note on QC masking
------------------------------

When the solvers are run, quality control (QC) flags are applied to different data objects during the calculation of the background ensemble and the background ensemble mean in observation-space, :math:`\mathcal{H}(\mathbf{X})` and :math:`\mathcal{H}(\overline{\mathbf{x}})`, respectively. Information of which observations are flagged by quality control is stored in a single object, a vector of inverse observation variances where observations failing QC are masked out as missing.

The inverse variance vector has its elements initially masked out to reflect the QC done using the ensemble mean (calculated during :math:`\mathcal{H}(\overline{\mathbf{x}})`). When :math:`\mathcal{H}` is non-linear, the inverse variance vector's elements are then recursively updated as :math:`\mathcal{H}` is applied to each ensemble member and new observations fail the respective QC (otherwise, when :math:`\mathcal{H}` has been linearized, the QC is only gathered from the background ensemble mean). The vector is finally updated with information on which observations are missing from the observation vector.

The values masked out of the finalised inverse variance vector are used to mask out values in the innovations and the background ensemble member perturbations in observation space :math:`\mathbf{Y}` which are missing or have failed QC, ensuring consistent missing values across ensemble members and observation vectors in successive calculations.

Driver configuration
--------------------

* Read :math:`\mathcal{H}(\mathbf{x})` from disk instead of computing it at run-time.

.. code:: yaml

  driver:
    read HX from disk: false #default value

* Run :code:`LocalEnsembleDA` to compute :math:`\mathcal{H}(\mathbf{x})` and save it to disk without performing any assimilation. This works hand-in-hand with :code:`read HX from disk`. One might choose to separate this into two steps because it is possible to use the more efficient round-robin distribution if :code:`run as observer only` is :code:`true`.

.. code:: yaml

  driver:
    run as observer only: false #default value

* Compute posterior observer and output test prints for the O-A statistics. One might choose to set this flag to :code:`false` in order to speed up completion of the :code:`LocalEnsembleDA` solver.

.. code:: yaml

  driver:
    do posterior observer: true #default value

..
  Warning: the link below may change in the future.

* Save posterior mean. Requires a top-level :code:`output` section to be defined in the yaml file. The contents of this section must adhere to the `DataSetBase::write() <https://github.com/JCSDA-internal/oops/blob/develop/src/oops/base/DataSetBase.h#414>`_ syntax, including any model-specific options.

.. code:: yaml

 driver:
   save posterior mean: false #default value

..
  Warning: the link below may change in the future.

* Save posterior ensemble. Requires a top-level :code:`output` section to be defined in the yaml file. The contents of this section must adhere to the `DataSetBase::write() <https://github.com/JCSDA-internal/oops/blob/develop/src/oops/base/DataSetBase.h#L140>`_ syntax, including any model-specific options.

.. code:: yaml

 driver:
   save posterior ensemble: true #default value

..
  Warning: the link below may change in the future.

* Save prior mean. Requires a top-level :code:`output mean prior` section to be defined in the yaml file. The contents of this section must adhere to the `DataSetBase::write() <https://github.com/JCSDA-internal/oops/blob/develop/src/oops/base/DataSetBase.h#L140>`_ syntax, including any model-specific options.

.. code:: yaml

 driver:
   save prior mean: false #default value

..
  Warning: the link below may change in the future.

* save posterior mean increment. Requires a top-level :code:`output increment` section to be defined in the yaml file. The contents of this section must adhere to the `DataSetBase::write() <https://github.com/JCSDA-internal/oops/blob/develop/src/oops/base/DataSetBase.h#L140>`_ syntax, including any model-specific options.

.. code:: yaml

 driver:
   save posterior mean increment: false #default value

..
  Warning: the link below may change in the future.

* save prior variance. Requires a top-level :code:`output variance prior` section to be defined in the yaml file. The contents of this section must adhere to the `DataSetBase::write() <https://github.com/JCSDA-internal/oops/blob/develop/src/oops/base/DataSetBase.h#L140>`_ syntax, including any model-specific options.

.. code:: yaml

 driver:
   save prior variance: false #default value

..
  Warning: the link below may change in the future.

* save posterior variance. Requires a top-level :code:`output variance posterior` section to be defined in the yaml file. The contents of this section must adhere to the `DataSetBase::write() <https://github.com/JCSDA-internal/oops/blob/develop/src/oops/base/DataSetBase.h#L140>`_ syntax, including any model-specific options.

.. code:: yaml

 driver:
   save posterior variance: false #default value

* This option is needed for the :code:`Halo` distribution to work properly. In that case, each MPI rank must know the center of the local grid patch (i.e. the region specified in the model domain decomposition)
and the radius of the circle (centered on the center of the grid patch) that can encircle all points on the local grid.
If not using the :code:`Halo` distribution, or using models that do not implement model domain decomposition (e.g. L95), one might choose to not update obs config by setting :code:`update obs config with geometry info: false`.

.. code:: yaml

 driver:
   update obs config with geometry info: true #default value

