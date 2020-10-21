.. _top-oops-ensapp:

Ensemble Applications in OOPS
=============================


Description
-----------

There are three ensemble applications available in OOPS: Ensemble Forecast, Ensemble HofX and Ensemble Data Assimilation. Their purpose is to allow users to run forecast and data assimilation applications on all the members of an ensemble at once.

MPI partition
-------------

:code:`MPI_WORLD` (the communicator containing all the tasks requested for running an application) is split into several separate communicators; as many as there are members in the ensemble. Each ensemble member is then run on one of these MPI communicators. The members only know about their **designated communicator** until the end of the run and at the moment there is no communication between different ensemble members.
To run the Ensemble Application to completion correctly, you need to allocate :math:`members * typical number of tasks for your application` MPI tasks.

Templated Ensemble Application
------------------------------

There is only one :code:`EnsembleApplication` to handle all three options in OOPS. It is templated on :code:`APP` and will create an :code:`Ensemble<APP>` that runs an ensemble of the :code:`APP` application you passed. For example, :code:`oops::EnsembleApplication<HofX>` will run the Ensemble Hofx application while :code:`oops::EnsembleApplication<Variational>` will run an Ensemble of Data Assimilation.

How to run an Ensemble Application
----------------------------------

Like all the other applications in OOPS, the Ensemble Application takes a yaml file as argument. The yaml file for this application differs from the typical yaml files in that it will be a **list of yaml files**, see the :ref:`example below <yaml-file>` to run EnsHofX with five members.

.. _yaml-file:

.. code:: yaml

    ---
    files:
      - "testinput/ens_hofx_1.yaml"
      - "testinput/ens_hofx_2.yaml"
      - "testinput/ens_hofx_3.yaml"
      - "testinput/ens_hofx_4.yaml"
      - "testinput/ens_hofx_5.yaml"


The first member of the ensemble will run HofX with the first file in the list, the second one will run HofX the second file, ... In order to run an Ensemble Hofx with five members, you need a total of six yaml files (the one passed to the EnsembleApplication, plus one for each member). In this case, each :code:`ens_hofx_{i}.yaml` file contains the exact HofX yaml file for member{i}.

More about how to write yaml files for:
- Forecast
- HofX
- :doc:`Variational<variational>`
