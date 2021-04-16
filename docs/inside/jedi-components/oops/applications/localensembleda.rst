.. _top-oops-localensda:

Local Ensemble data assimilation in OOPS
========================================

The Local Ensemble DA application is a generic application for running data assimilation with Local Ensemble Kalman filters. It can be extended to use any Local EnKF that updates state gridpoints independently from each other by using observations within a localization distance from a gridpoint.

Configuration file (e.g. :code:`letkf.yaml`) for running LocalEnsembleDA application has to contain the following sections:

* :code:`geometry` - geometry for the background and analysis files

* :code:`background` - ensemble background members (currently used both for computing H(x) and as backgrounds)

* :code:`observations` - describes observations, observation errors, observation operators used in the assimilation, and the horizontal localization

* :code:`driver` - describes optional modifications to the behavior of the LocalEnsembleDA driver

* :code:`local ensemble DA` - configuration of the local ensemble DA solver package


Supported modifications to the driver
---------------------------------------

* Read HX from disk instead of computing it at run-time.
 
.. code:: yaml

  driver:
    read HX from disk: false #default value

* Compute posterior observer and output test prints for the oma statistics. One might choose to set this flag to false in order to speed up completion of the localEnsembleDA solver.

.. code:: yaml

  driver:
    do posterior observer: true #default value

* Run LocalEnsembleDA in observer mode to compute HX offline. This works hand-in-hand with :code:`read HX from disk`. One might choose to separate this into two steps because it is possible to use more efficient round-robin distribution if :code:`run as observer only: true`. 

.. code:: yaml

  driver:
    run as observer only: false #default value

* Save posterior mean. Requires "output" section in the yaml file.
.. code:: yaml
 driver: 
   save posterior mean: false #default value

* Save posterior ensemble. Requires "output" section in the yaml file. 
.. code:: yaml
 driver: 
   save posterior ensemble: true #default value

* Save prior mean. Requires "output mean prior" section in the yaml file.
.. code:: yaml
 driver: 
   save prior mean: false #default value
   
* save posterior mean increment. Requires "output increment" section in the yaml file.
.. code:: yaml
 driver: 
   save posterior mean increment: false #default value
   
* save prior variance. Requires "output variance prior" section in the yaml file.
.. code:: yaml
 driver: 
   save prior variance: false #default value

* save posterior variance. Requires "output variance posterior" section in the yaml file.
.. code:: yaml
 driver: 
   save posterior variance: false #default value
   
* If Halo obs. distribution is used, one also needs to set  the following option as "true"
.. code:: yaml
 driver: 
   update obs config with geometry info: fasle #default value


Supported Local Ensemble Kalman filters
---------------------------------------

LETKF
^^^^^

Two Local Ensemble Transform Kalman Filter (`Hunt et al 2007 <https://doi.org/10.1016/j.physd.2006.11.008>`_) implementations are supported:

* C++ implementation using Eigen (double precision).

This implementation is used when :code:`LETKF` keyword is used in :code:`solver` section of configuration file:

.. code-block:: yaml

   local ensemble DA:
     solver: LETKF

* GSI-LETKF Fortran implementation using LAPACK (single precision).

This implementation is used when :code:`GSI LETKF` keywords are used in :code:`solver` section of configuration file:

.. code-block:: yaml

   local ensemble DA:
     solver: GSI LETKF

LGETKF
^^^^^^

Another available solver is Local GETKF (Gain form of the Ensemble Transform Kalman filter, `Bishop et al 2017 <https://doi.org/10.1029/2018MS001468>`_) using modulated ensembles to emulate model-space localization in vertical. The implementation calls GSI-GETKF Fortran implementation and follows `Lei et al 2018 <https://doi.org/10.1029/2018MS001468>`_.

To use LGETKF, specify :code:`GETKF` in :code:`solver` section. Using LGETKF also requires specifying parameters for the modulation product that emulates model-space localization in vertical:

* :code:`fraction of retained variance` - fraction of the variance retained after the eigenspectrum of the vertical localization function is truncated (1 -- retain all eigenvectors, 0 -- retain the first eigenvector)

* :code:`lengthscale units` - name of variable for vertical localization. FV3 implementation currently supports two types of units: :code:`logp` -- logarithm of pressure at mid level of the vertical column with surface pressure set to 1e5 at all points, and :code:`levels` -- indices of vertical levels.

* :code:`lengthscale` - localization distance in the above units, at which Gaspari-Cohn localization function is zero.

An example of using LGETKF solver in FV3:

.. code-block:: yaml

   local ensemble DA:
     solver: GETKF
     vertical localization:
       fraction of retained variance: .95
       lengthscale: 1.5
       lengthscale units: logP


Localization supported in the ensemble solvers
----------------------------------------------

Observation-space :math:`R`-localization is used in the horizontal in all of the currently available solvers. Localization distance can be specified differently for different observation types in the :code:`obs error.localization` section of configuration, for example:

.. code-block:: yaml

   observations:
   - obs space:
       name: radiosonde
     ...
     obs error:
       covariance model: localized diagonal   # inflate obs errors based on the distance from the updated grid point
       localization:
         localization method: Gaspari-Cohn
         lengthscale: 1000e3                  # localization distance in meters


There is currently no vertical localization in LETKF implementations in JEDI. LGETKF implementation uses ensemble modulation to emulate model-space vertical localization.

.. list-table:: Localization options available in different solvers
   :header-rows: 1

   * - Solver
     - Horizontal localization
     - Vertical localization
   * - LETKF
     - Gaspari-Cohn R-localization
     - No localization
   * - GSI LETKF
     - Gaspari-Cohn R-localization
     - No localization
   * - GETKF
     - Gaspari-Cohn R-localization
     - Modulated ensembles for emulating Gaspari-Cohn B-localization

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

* RTPP (relaxation to prior perturbation), `Zhang et al, 2004 <https://journals.ametsoc.org/mwr/article/132/5/1238/67253/Impacts-of-Initial-Estimate-and-Observation>`_

.. math::

   {X_{a}^{i}}' = \alpha X_{b}^{i} + (1-\alpha) X_{a}^{i}

Parameter of RTPP inflation is controlled by :code:`inflation.rtpp` configuration value, for example:

.. code-block:: yaml

   local ensemble DA:
     inflation:
       rtpp: 0.5

* RTPS (relaxation to prior spread), `Whitaker and Hamill, 2012 <https://doi.org/10.1175/MWR-D-11-00276.1>`_

.. math::

   {X_{a}^{i}}' = X_{a}^{i}  (\alpha  \frac{\sigma_{b}-\sigma_{a}}{\sigma_{a}}+1)

Parameter of RTPS inflation is controlled by :code:`inflation.rtps` configuration value, for example:

.. code-block:: yaml

   local ensemble DA:
     inflation:
       rtps: 0.6

.. list-table:: Inflation options available in different solvers
   :header-rows: 1

   * - Solver
     - Inflation options
   * - LETKF
     - Multiplicative inflation, RTPP, RTPS
   * - GSI LETKF
     - RTPP, RTPS
   * - GETKF
     - RTPP, RTPS

NOTE about obs distributions
-----------------------------
Currently Local Ensemble DA supports :code:`InefficientDistribution` and :code:`Halo` obs distribution. For InefficientDistribution each obs and H(x) is replicated on each PE. For Halo distribution only obs. needed on this PE are stored on each PE. Halo is more efficient however it is less mature compared to InefficientDistribution. 
We also have an option to run Local Ensemble DA in the observer only mode with :code:`RoundRobin` to compute H(X). Then one can read ensemble of H(x) from disk using :code:`driver.read HX from disk == true` and :code:`driver.do posterior observer == false`. 

The type of the obs. distribution is specified for each ObsSpace:
.. code-block:: yaml
observations:
- obs space:
    distribution: Halo 

If Halo obs. distribution is used one also needs to specify
.. code-block:: yaml
 driver: 
   update obs config with geometry info: true
