.. _top-oops-genenspertb:

Generate an ensemble, and run an ensemble forecast
==================================================

The GenEnsPertB application perturbs an initial state with random perturbations generated with a specified background error covariance model, and runs forecasts from the ensemble of states. This application can be used for generating an initial ensemble.

The following options need to be specified in the configuration file:

* :code:`geometry`: Geometry of the initial condition;
* :code:`initial condition`: initial condition (State) that will be perturbed before running the forecasts;
* :code:`model`: Model used for the forecast;
* :code:`forecast length`: Duration of the forecast;
* :code:`background error`: model space ErrorCovariance used for the initial condition perturbations;
* :code:`perturbed variables`: list of the initial condition state variables to perturb
* :code:`members`: integer specifying how many perturbed states to generate
* :code:`output`: options describing writing the output files

For example, to generate an ensemble of 100 members as :math:`x_i = x_0 + \eta_i, i={1,...,100}` where :math:`\eta_i \sim N(0, B)`, and run a one-day forecast from all of those members, the following configuration structure can be used:

.. code-block:: yaml

    ---
    geometry:
      # geometry of x_0 state
    initial condition:
      # options describing x_0
    model:
      # model used for the forecast
    forecast length: P1D
    background error:
      # options describing B
    perturbed variables: # list of the initial condition state variables to perturb
    members: 100
    output:
      # options for writing the output files

To generate a single forecast from a perturbed initial condition, :code:`members` option can be set to :code:`1`.

See an example of a configuration file used for the GenEnsPertB application with the :doc:`L95 toy model<../toy-models/l95>` `here <https://github.com/JCSDA/oops/blob/master/l95/test/testinput/genenspert.yaml>`_.
