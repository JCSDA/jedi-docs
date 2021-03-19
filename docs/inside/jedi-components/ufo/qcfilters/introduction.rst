.. _top-ufo-qc:

Background
==========


OOPS Observation Processing Flow
--------------------------------

Observations can be used in different ways in OOPS-JEDI. In variational data assimilation,
the initial computation of the observation term of the cost function (J\ :sub:`o`) is where
most of the quality control takes place.

The flow of this computation in OOPS is as follows:

.. code-block:: yaml

  CostFunction::evaluate
    CostJo::initialize
      ObsFilters::ObsFilters
      Observer::Observer
        ObsOperator::requiredVars
        ObsFilters::requiredVars
    CostFunction::runNL
      Model::forecast
        Observer::initialize
          ObsFilters::preProcess
          GeoVaLs::GeoVaLs
        loop over time steps
          Observer::process
            State::getValues
        end loop over time steps
        Observer::finalize
          ObsFilters::priorFilter
          ObsOperator::simulateObs
          ObsFilters::postFilter
    CostJo::finalize
      ObsErrors::ObsErrors
      ydep=ysimul-yobs

The :code:`Observer` calls the :code:`preProcess` method of :code:`ObsFilters` before the loop over time steps. After the loop, it calls the :code:`priorFilter` and :code:`postFilter` methods just before and just after calling the :code:`simulateObs` method of :code:`ObsOperator`. The observation filters are very generic and can perform a number of tasks, but mostly they are used for quality control.

Observation Filters
-------------------

Observation filters have access to:
 - Observation values and metadata
 - Model values at observations locations (GeoVaLs)
 - Simulated observation value (for post-filter)
 - Their own private data

Most filters are written once and used with many observation types; several such generic filters already exist and are decribed below. Filters applied to observations from a specific ObsSpace need to be listed in the :code:`observations.obs filters` section of the input YAML configuration file, together with any options controlling their behavior. Example:

.. code-block:: yaml

  observations:
  - obs space:
      name: AMSUA-NOAA19
      obsdatain:
        obsfile: Data/obs/testinput_tier_1/amsua_n19_obs_2018041500_m.nc4
      simulated variables: [brightness_temperature]
      channels: 1-15
    obs filters:
    - filter: Bounds Check
      filter variables:
      - name: brightness_temperature
        channels: 1-15
      minvalue: 100.0
      maxvalue: 500.0
    - filter: Background Check
      filter variables:
      - name: brightness_temperature
        channels: 1-15
      threshold: 3.0