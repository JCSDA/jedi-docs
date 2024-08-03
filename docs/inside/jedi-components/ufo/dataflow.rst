.. _top-ufo-qc:

Observation Processing Flow
===========================

The flow of H(x) computation and QC filters application in OOPS is shown in the figure below.

.. _ufo-observer-flow:
.. figure:: images/observer_flow.png
   :align: center

   Flow chart for computing H(x) and running QC filters

The :code:`Observer` calls the :code:`preProcess` method of :code:`ObsFilters` before the loop over time steps. After the loop, it calls the :code:`priorFilter` and :code:`postFilter` methods just before and just after calling the :code:`simulateObs` method of :code:`ObsOperator`. The observation filters are very generic and can perform a number of tasks, but mostly they are used for quality control.

In variational data assimilation, the above flow happens inside of the observation term of the cost function (J\ :sub:`o`) evaluation.

GetValues postprocessor
-----------------------

The :code:`GetValues` postprocessor in the observation processing data flow fills the :code:`GeoVaLs` (model state at the horizontal observation locations) during the model (or pseudomodel) run. The timestep :code:`tstep` in the dataflow above is not a physical model timestep but rather a time resolution that is chosen for the data assimilation application (typically specified in YAML). By default, the state that is nearest in time to the observation is used for computing :code:`GeoVaLs` for that particular observation. An option to use linear interpolation in time between the states closest to the observation is available, and can be turned on by setting a :code:`get values.time interpolation` YAML option:

.. code-block:: yaml

  - obs space: ...
    get values:
      time interpolation: linear   # only "linear" and "nearest" (default) are supported
