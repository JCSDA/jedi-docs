.. _top-oops-apps:

Applications in OOPS
====================

OOPS provides the following applications that can be used with different models and observations:

Applications running forecast (and computing H(x))
--------------------------------------------------
* Forecast: model forecast
* HofX: model forecast and computes H(x)

Ensemble forecast applications
------------------------------
These applications are similar to the above. Each ensemble member is run on a separate MPI communicator, there is no communication between different ensemble members.

* EnsembleForecast: ensemble of model forecasts
* EnsembleHofX: ensemble of model forecasts; computes H(x) for each ensemble member.

Data assimilation applications
------------------------------
* :doc:`Variational<variational>`: variational data assimilation
* EDA: ensemble of variational data assimilations
* LocalEnsembleDA: local ensemble data assimilation

Data assimilation helper applications
-------------------------------------
* EstimateParams
* GenEnsPertB
* StaticBInit
* ExternalDFI
* EnsVariance

Applications operating on model states and increments
-----------------------------------------------------
* EnsRecenter: recenters ensemble around a provided state
* AddIncrement: adds increment to the model state
* DiffStates: computes and saves difference between two model states
