.. _obsErrorWithinGroup:

Observation error covariance with correlations for observations within one record
=================================================================================

The observation error covariance can be set up to use correlations for observations within one record. To use this capability, the obsgrouping feature of ObsSpace needs to be used to group observations by records (see e.g. :ref:`top-ioda-interface`).

Correlations are computed using either a Gaspari-Cohn, Gaussian, or Markov function with the lengthscale specified in yaml. The same correlations are applied to all assimilated variables in one record. Correlations between locations in different records are considered to be zero.
The full observation error covariance matrix is :math:`R = D^{1/2} * C * D^{1/2}` where :math:`D^{1/2}` is a diagonal matrix with the observation error standard deviations (:code:`ObsError` group) on the diagonal, and :math:`C` is the correlation matrix.

This type of observation error covariance is set up using the following options:

* :code:`correlation function` (Parameter, type: string, default value: :code:`gc99`): the correlation function to use for computing the correlation matrix.  Currently a Gaspari-Cohn correlation profile (:code:`gc99`), a gaussian correlation profile (:code:`gaussian`), and a Markov method (:code:`markov`) are the available options.
* :code:`correlation lengthscale` (RequiredParameter, type: float): the lengthscale which normalizes the distance between observations (distance / :code:`correlation lengthscale`). Correlations are set to zero at and beyond this value for the :code:`gc99` correlation function.
* :code:`correlation variable names` (OptionalParameter, type: vector of strings): variables in MetaData group used as a coordinate variable in the distance calculation. This is not needed when using the :code:`haversine` distance function because latitude and longitude are the only variables needed.
* :code:`distance function` (Parameter, type: string, default value: :code:`linear`): the name of the function used to calculate the distance between observations. Currently only :code:`linear` and :code:`haversine` are supported. If :code:`linear` is used the :code:`correlation variable names` must be defined. For the `haversine` function only the latitude and longitude are needed and the :code:`correlation lengthscale` needs to be specified in meters.
* :code:`lengthscale factor for markov correlation limit` (Parameter, type: double, default value: 1.0): the lengthscale factor is multiplied by the lengthscale to provide the limit in which correlations are evaluated, beyond this distance correlation values are set to zero. This is only used when :code:`markov` is selected as the :code:`correlation function`.
* :code:`apply basic reconditioning` (Parameter, type: boolean, default value: false): this parameter should only be used with the :code:`gaussian` correlation function. It will apply the same basic, ridge regression reconditioning that is applied to the :code:`markov` correlation function.

For testing and diagnostics purposes, `ufo_obserrorcov_diags.x` application is available. It saves the following diagnostics for one specified record in the netcdf file:

- coordinate used for computing correlations (e.g. pressure in the example above),
- correlation matrix :math:`C`,
- random vector :math:`x` for the specified record,
- result of :math:`C * x`.

A Python script for plotting is provided in `ufo/tools/plots/plot_obserrorwithingroupcorr_diags.py`.


.. _gc99-corr:

Gaspari-Cohn correlation function
---------------------------------

When using the Gaspari-Cohn correlation function (the default), a user must set a correlation
length (the :code:`correlation lengthscale` parameter) which sets the cutoff point where the
Gaspari-Cohn function becomes zero. This length is approximately 3.57 times the standard deviation
of the Gaussian function which best-fits the Gaspari-Cohn. An example yaml configuration is below:

.. code-block:: yaml

  observations:
  - obs space:
      name: Sondes (within group covariances for one variable)
      obsdatain:
          ... # input/output files and other options
        obsgrouping:
          group variables: [sequenceNumber]
          sort variable: pressure
          sort order: ascending
      simulated variables: [airTemperature]
    obs error:
      covariance model: within group covariances
      correlation function: gc99                # optional b/c gc99 is the default
      correlation lengthscale: 15000.           # length in meters
      correlation variable names: [pressure]
      distance function: linear

.. _markov-corr:

Markov correlation function
---------------------------

The Markov correlation function sets up a correlation profile following a decaying exponential:
:math:`e^{-|x|/l}`, where :math:`l` is the correlation lengthscale. The
``lengthscale factor for markov correlation limit``, :math:`f` is a factor which sets the length
beyond which the function will evalute to zero (similar to the lengthscale for Gaspari-Cohn
correlation function). If the distance :math:`d` between two observation locations is greater than
:math:`f*l`, then the correlation will be set to zero. An example yaml configuration is below:


.. code-block:: yaml

  observations:
  - obs space:
      name: Sondes (within group covariances with markov correlation)
      obsdatain:
        ... # input/output files and other options
        obsgrouping:
          group variables: [sequenceNumber]
          sort variable: pressure
          sort order: ascending
      simulated variables: [airTemperature, windEastward, windNorthward]
    obs error:
      covariance model: within group covariances
      distance function: haversine
      correlation function: markov
      lengthscale factor for markov correlation limit: 2.0   # default is 1.0
      correlation lengthscale: 13000.                        # length in meters


The Markov correlation function is not guaranteed to produce a positive definite :math:`R`
matrix, so a basic ridge regression reconditioning in the form of adding 10% of the
smallest eigenvalue to the diagonal of the Markov correlation matrix.

.. _gaussian-corr:

Gaussian correlation function
-----------------------------

The gaussian correlation function creates a gaussian correlation profile: 
:math:`e^{-\frac{(x/l)^2}{2}}`, where :math:`x` is the distance between observations and
:math:`l` is the ``correlation lengthscale``, which represents the standard deviation of
the Guassian profile. 

The gaussian correlation function (like the Markov function) is not guaranteed to produce
a positive definite :math:`R` matrix, and has several reconditioning options. The recommended
option is to use the same reconditioning that is applied to the Markov correlation function.
This is enabled by setting ``apply basic reconditioning: true`` in the yaml configuration.
There is also a more advanced reconditioning option available which is documented in
:ref:`reconditioning`; some tuning by the user is recommended before using this option
scientifically.

.. code-block:: yaml

  observations:
  - obs space:
      name: Sondes (Gaussian correlation function w/ reconditioner)
      obsdatain:
        ... # input/output files and other options
        obsgrouping:
          group variables: [sequenceNumber]
          sort variable: pressure
          sort order: ascending
      simulated variables: [airTemperature, windEastward, windNorthward]
    obs error:
      covariance model: within group covariances
      distance function: haversine
      correlation function: gaussian
      correlation lengthscale: 5000.  # in meters
      apply basic reconditioning: true  # default is false
      # to apply more advanced reconditioning use config below
      # reconditioning:
      #   recondition method: Ridge Regression
      #   fraction: 0.9
