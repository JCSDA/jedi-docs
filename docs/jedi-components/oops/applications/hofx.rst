.. _top-oops-hofx:

HofX computation in OOPS
========================

The HofX application is a generic application for running the model forecast (or reading forecasts from file) and computing H(x).

HofX yaml structure
-------------------

.. _yaml-hofx:

.. code-block:: yaml

    ---
    geometry:
      #geometry of the model
    initial condition:
      #background file
    model:
      #model used for the experiment
    forecast length: #the hofx application will run the model forecast for this time period
    window begin: #beginning of the time window
    window length: #length of the time window
    observations:
      #list of observation files
    prints: (optional)
      #optional parameters for calling the PostProcessor

HofX no model yaml structure
----------------------------

Users can run the HofX application without running their model forecast by providing a list of forecasts and using the HofXNoModel application.
The yaml structure to run HofXNoModel is similar to the following:

.. _yaml-hofx-nomodel:

.. code-block:: yaml

    ---
    geometry:
      #geometry of the model
    forecasts:
      #file or list of files from a previously ran forecast experiment
    window begin: #beginning of the time window
    window length: #length of the time window
    observations:
      #list of observation files
    prints: (optional)
      #optional parameters for calling the PostProcessor
