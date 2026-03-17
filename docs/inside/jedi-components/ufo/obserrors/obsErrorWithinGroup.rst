.. _obsErrorWithinGroup:

Observation error covariance with correlations for observations within one record
=================================================================================

The observation error covariance can be set up to use correlations for observations within one record. To use this capability, the obsgrouping feature of ObsSpace needs to be used to group observations by records (see e.g. :ref:`top-ioda-interface`).

Correlations are computed using either a Gaspari-Cohn function or a Markov function with the lengthscale specified in yaml. The same correlations are applied to all assimilated variables in one record. Correlations between locations in different records are considered to be zero.
The full observation error covariance matrix is :math:`R = D^{1/2} * C * D^{1/2}` where :math:`D^{1/2}` is a diagonal matrix with the observation error standard deviations (:code:`ObsError` group) on the diagonal, and :math:`C` is the correlation matrix.

This type of observation error covariance is set up using the following options:

* :code:`correlation function` (Parameter, type: string, default value: :code:`gc99`): the correlation function to use for computing the correlation matrix.  Currently the Gaspari-Cohn method (:code:`gc99`) and a Markov method (:code:`markov`) are the only available options.
* :code:`correlation lengthscale` (RequiredParameter, type: float): the lengthscale which normalizes the distance between observations (distance / :code:`correlation lengthscale`). Correlations are set to zero at and beyond this value for the :code:`gc99` correlation function.
* :code:`correlation variable names` (OptionalParameter, type: vector of strings): variables in MetaData group used as a coordinate variable in the distance calculation. This is not needed when using the :code:`haversine` distance function because latitude and longitude are the only variables needed.
* :code:`distance function` (Parameter, type: string, default value: :code:`linear`): the name of the function used to calculate the distance between observations. Currently only :code:`linear` and :code:`haversine` are supported. If :code:`linear` is used the :code:`correlation variable names` must be defined. For the `haversine` function only the latitude and longitude are needed and the :code:`correlation lengthscale` needs to be specified in meters.
* :code:`lengthscale factor for markov correlation limit` (Parameter, type: double, default value: 1.0): the lengthscale factor is multiplied by the lengthscale to provide the limit in which correlations are evaluated, beyond this distance correlation values are set to zero. This is only used when :code:`markov` is selected as the :code:`correlation function`.

.. code-block:: yaml

 obs space:
   name: Sondes (within group covariances for one variable)
   obsdatain:
     # input/output files and other options
     obsgrouping:
       group variables: [sequenceNumber]
       sort variable: pressure
       sort order: ascending
   simulated variables: [airTemperature]
 obs error:
   covariance model: within group covariances
   correlation function: gc99
   correlation lengthscale: 15000.
   correlation variable names: [pressure]
   distance function: linear

For testing and diagnostics purposes, `ufo_obserrorcov_diags.x` application is available. It saves the following diagnostics for one specified record in the netcdf file:

- coordinate used for computing correlations (e.g. pressure in the example above),
- correlation matrix :math:`C`,
- random vector :math:`x` for the specified record,
- result of :math:`C * x`.

A Python script for plotting is provided in `ufo/tools/plots/plot_obserrorwithingroupcorr_diags.py`.

