.. _top-oops-forecast:

Forecast in OOPS
================

The forecast application is a generic application for running a forecast from an initial condition.

Yaml structure for the forecast application
-------------------------------------------

.. _yaml-forecast:

.. code-block:: yaml

    ---
    forecast length: #the forecast application will run for this time period
    geometry:
      #geometry of the model
    initial condition:
      #background file
    model:
      #model used for the experiment
    output:
      #name, path, ... options for writing the output files
    prints: (optional)
      #optional parameters for calling the PostProcessor
