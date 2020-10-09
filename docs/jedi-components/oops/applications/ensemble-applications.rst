.. _top-oops-ensapp:

Ensemble Applications in OOPS
=====================================


Description
-----------

There are three ensemble applications available in OOPS: Ensemble Forecast, Ensemble HofX and Ensemble Data Assimilation. Their purpose is to allow users to run forecast and data assimilation applications on all the members of an ensemble at once.

MPI partition
^^^^^^^^^^^^^

:code:`MPI_WORLD` (the communicator containing all the tasks requested for running an application) is split into several separate communicators; as many as there are members in the ensemble. Each ensemble member is then run on one of these MPI communicators. The members only know about their **designated communicator** until the end of the run and at the moment there is no communication between different ensemble members.

Templated Ensemble Application
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

There is only one :code:`EnsembleApplication` to handle all three options in OOPS. It is templated on :code:`APP` and will create an :code:`Ensemble<APP>` that runs an ensemble of the :code:`APP` application you passed. For example, :code:`oops::EnsembleApplication<HofX>` will run the Ensemble Hofx application while :code:`oops::EnsembleApplication<Variational>` will run an Ensemble of Data Assimilation.


YAML how to
-----

yaml: how to specify number of members; links to yaml explanations for Forecast, Variational, HofX

Primal Minimizers
^^^^^^^^^^^^^^^^^
