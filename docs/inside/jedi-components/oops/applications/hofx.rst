.. _top-oops-hofx:

HofX applications in OOPS
=========================

There are two applications that simulate model equivalents of the observations in JEDI: HofX3D and HofX4D. Both of these applications apply the observation operator :math:`H(x)` to specified model state(s) :math:`x` to simulate specified observations.

The HofX3D application computes values of :math:`H(x)` using a single specified model state :math:`x`. The HofX4D application computes values of :math:`H(x)` using a set of model states that are computed via running the forecast model. HofX4D is thus similar to a Forecast application, with the addition of computing :math:`H(x)` during the forecast run.

These applications could be used for diagnostics. For example, the HofX4D application can be used to run forecasts starting from two different initial conditions, and computing :math:`H(x)` values for these two different runs. The computed :math:`H(x)` can then be compared with observation values to evaluate the two forecasts' performance.

The HofX applications can also be used for generating observation values for Observing System Simulation Experiments (OSSE). In this case after the :math:`H(x)` values for specified observation locations are computed they can be optionally perturbed using specified observation error statistics, and saved as "observation values" for the future experiments.

HofX3D yaml structure
---------------------

The HofX3D application computes :math:`H(x)` for all specified observations using a single specified model state on input. The computed :math:`H(x)` values can be optionally perturbed and saved as observation values, e.g. for OSSE.

.. _yaml-hofx3d:

.. code-block:: yaml

    ---
    ### Sections describing model state.
    geometry:
      # geometry of the model
    state:
      # model state used for computing H(x)

    ### Sections describing observations.
    # only observations taken at times lying in the (`window begin`, `window begin` + `window length`]
    # interval will be included
    window begin:  # datetime in ISO format
    window length: # duration in ISO format
    # list of observations (input files, observation operators, observation errors, etc).
    observations:
      obs perturbations:  # default false; set to true for perturbing the result of H(x) -- for OSSE experiments
      observers:
      - ...
      - ...
    make obs:  # default false; set to true to save the result of H(x) as "ObsValue" -- for OSSE experiments

HofX4D yaml structure
---------------------

The HofX4D application runs the model forecast from the specified `initial condition` and computes :math:`H(x)` using model states from the forecast run. The time resolution of model states is specified in the `model` YAML section as the "time step", or "time resolution", depending on the model. As with the HofX3D application, the computed :math:`H(x)` values can be optionally perturbed and saved as observation values, e.g. for OSSE. 

.. _yaml-hofx4d:

.. code-block:: yaml

    ---
    ### Sections describing model state.
    geometry:
      # geometry of the model
    initial condition:
      # model state used as initial condition for the forecast
    model:
      # model used during the forecast
    forecast length: # how long to run the forecast for
    prints:
      # options used when writing out forecast fields.
    
    ### Sections describing observations.
    # only observations taken at times lying in the (`window begin`, `window begin` + `window length`]
    # interval will be included
    window begin:  # datetime in ISO format
    window length: # duration in ISO format
    # list of observations (input files, observation operators, observation errors, etc).
    observations:
      obs perturbations:  # default false; set to true for perturbing the result of H(x) -- for OSSE experiments
      observers:
      - ...
      - ...
    make obs:  # default false; set to true to save the result of H(x) as "ObsValue" -- for OSSE experiments
