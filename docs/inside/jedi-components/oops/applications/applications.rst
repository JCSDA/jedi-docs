.. _top-oops-apps:

Applications in OOPS
====================

OOPS provides the following applications that can be used with different models and observations:

Applications running forecast (and computing H(x))
--------------------------------------------------
* :doc:`Forecast<forecast>`: model forecast
* :doc:`HofX<hofx>`: model forecast and computes H(x)

Data assimilation applications
------------------------------
* :doc:`Variational<variational>`: variational data assimilation
* :doc:`LocalEnsembleDA<localensembleda>`: local ensemble data assimilation

Ensemble applications
---------------------
These applications are similar to the above but allow users to run several members at once in order to compute a Forecast, HofX or Variational Data Assimilation for an entire ensemble. See the documentation on :doc:`Ensemble Applications<ensemble-applications>`.

* EnsembleForecast: ensemble of model forecasts
* EnsembleHofX: ensemble of model forecasts; computes H(x) for each ensemble member.
* EDA: ensemble of variational data assimilations

Data assimilation helper applications
-------------------------------------
* EstimateParams
* :doc:`GenEnsPertB<genenspertb>`: generates an ensemble of states distributed according to a specifed background error covariance, and runs an ensemble forecast from that ensemble.
* StaticBInit
* ExternalDFI
* EnsVariance
* :doc:`GenHybridLinearModelCoeffs<gen-hybrid-linear-model-coeffs>`: generates hybrid tangent linear model coefficients via ensemble forecasts

Applications operating on model states and increments
-----------------------------------------------------
* EnsRecenter: recenters ensemble around a provided state
* AddIncrement: adds increment to the model state
* DiffStates: computes and saves difference between two model states
