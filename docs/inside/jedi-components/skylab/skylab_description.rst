SkyLab experiments: Parameters and description
==============================================

This page describes which parameters are available in SkyLab experiments, and the implementation
of the four flagship experiments ran by the JSCDA team. You can see results from these on
the `JCSDA SkyLab website <https://skylab.jcsda.org/>`_.

Experiment configuration
------------------------

All the parameters for these experiments are contained within one yaml file,
and running the :code:`create_experiment.py` command sets up the generic workflow
(EWOK: Experiments and Workflows Orchestration Kit) for this experiment.

More information about how to build and run SkyLab is available here:
:ref:`build-run-skylab`.

The experiment yaml has to contain the following information:

.. code-block:: yaml

    workflow engine: # workflow manager, only `ecworkflow` is supported at the moment

    workdir: # path to tmp work directory
    flowdir: # path to tmp scripts directory

    suite: # Choice between including path to `cyclingDA.py`, `skylab.py` (full DA), `hofx.py`, `forecast.py`..
    model: # Choice between `qg`, `mpas`, `gfs`, `gfs_aero`, `geos_cf`, `ufs`..
    model_path: # Path to model repository
    modeltasks:  # Path to model specific tasks (get backgrounds, ..)
    init_cycle: # Date for the first cycle of the experiment
    last_cycle: # Date for the last cycle of the experiment
    step_cycle: # Step between cycles

    cycling mode: # Optional, `non cycling` (default; will read backgrounds from an experiment set in `init_exp`) or `cycling`, (will use forecasts from the previous cycle of current experiment as backgrounds)
    init_exp: # Reference for the first background to be read from DB, to initialize the experiment.
    init_type: # Optional, `fc` (default;will initialize from forecasts) or `an` (will initialize from analysis and run forecast to get backgrounds for the first DA cycle)

    cost_function: # Cost function, choice between `3D-Var`, `4D-Var`, `3D-FGAT`,
    window_length: # Window length
    window_offset: # Offset between analysis and end of the assimilation window

    forecast_length: # Forecast length after the variational task. If set to `PT0H` the forecast task will not run. 
    forecast_output_frequency: # Forecast output frequency

    obs_sampling: # Optional, `coarse` if the coarse observation file exists
    OBSERVATIONS:
    - Observation 1 # yaml configuration for observation type 1
    - Observation 2 # yaml configuration for observation type 2

    init_exp_obsbias: # Reference for the first obs bias to be read from DB
    init_model_obsbias: # Model obs bias has been created from, e.g. `gfs`
    init_provider_obsbias: # Provider obs bias has been created from. e.g. `noaa`
    obsbias cycling mode: # Optional, `non cycling` will read bias correction from file at each cycle instead of cycling

    AN_VARIABLES: # yaml configuration, list of analysis variables
    BG_VARIABLES: #  yaml configuration, list of background variables
    MODEL_VARIABLES: # yaml configuration, list of model variables

    GEOMETRY: # yaml configuration, geometry and resolution for the outer loop, typically model dependent
    MODEL: # yaml configuration, model to run in the forecast (and var steps if needed)

    static_data: # Path to static files directory, e.g. static B, model files, or other needed files not found in r2d2 or elsewhere.
    background_error_type: # Type of background error matrix, options are `hybrid`, `ensemble`, `static`
    # ensemble B component parameters
    BACKGROUND_ERROR_LOCALIZATION: # Yaml file for localizations
    members: # Number of members in the ensemble B matrix
    ensb_weight: # Weight of ensemble B matrix
    ensemble_exp: # Reference to read ensemble backgrounds from DB
    # static B component parameters
    BACKGROUND_ERROR: # Yaml file for static B
    staticb_weight: # Weight of static B

    MINIMIZER: {algorithm: DRPLanczos} # Options are all the minimizers available in OOPS
    ninner: 10 # Maximum number of iterations in quadratic minimization
    reduc: 0.05 # Target norm reduction in quadratic minimization
    MIN_GEOMETRY: # yaml configuration, geometry and resolution inside the quadratic minimization
    LINEAR_MODEL: # yaml configuration, linear model to run in 4D-Var applications
    diag: ombg # diagnostics in obs space, can be `oman`, `ombg`..

    plots: # yaml configuration, activates log based and model-space plots
    
    evaluation:   # running evaluation or not
      evaluation_frequency: PT6H   # how frequently to evaluate the forecast within the forecast length
      evaluation_baseline: self_anl   # evaluation is against with 'self_anl' or analyses from other exps (expid).
      evaluation_cycles: ['00']       # a list that defines the valid cycle of evaluation.
      type: metplus        # 'metplus' or 'basic'
      verif_grid: G002     # if type is metplus, can select evaluation on which grid definition, GXXX
                           # (more info https://www.nco.ncep.noaa.gov/pmb/docs/on388/tableb.html)
      grid_stat_template: !ENV ${JEDI_SRC}/skylab/eval/metplus/GridStat.conf.IN  # the template to run GridStat in METplus

Retrieving experiment configuration
-----------------------------------

A new feature in Skylab v8 and later is the ability to retrieve the experiment configuration
used for Skylab experiments via Research Repository for Data and Diagnostics (R2D2).
An example on how to do this in python is given below.
Update `<my_exp_name>` to the experiment id (expid).

.. code-block:: python

  from r2d2 import R2D2Index
  experiment_index_object = R2D2Index.get(item='experiment', name=<my_exp_name>)
  yaml_name = experiment_index_object.get_property('yaml_name')
  yaml_text = experiment_index_object.get_property('yaml_text')

Then adding the line ``print(yaml_text)`` to the above script would return the yaml name, such as:

.. code-block:: bash

  l95-4dvar.yaml

And adding the line ``print(yaml_text)`` to the script would return the configuration file used, such as:

.. code-block:: bash

  # (C) Copyright 2020-2022 UCAR
  #
  # This software is licensed under the terms of the Apache Licence Version 2.0
  # which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.

  workflow engine: ecworkflow

  workdir: !ENV ${EWOK_WORKDIR}
  flowdir: !ENV ${EWOK_FLOWDIR}

  suite: !ENV ${JEDI_SRC}/ewok/src/ewok/suites/cyclingDA.py
  model: l95
  model_path: !ENV ${JEDI_SRC}/skylab/models/l95
  init_cycle: 2020-01-01T00:00:00Z
  last_cycle: 2020-01-01T18:00:00Z
  step_cycle: PT6H

  cycling mode: cycling
  init_type: an
  init_exp: test

  window_length: PT6H
  window_offset: PT3H

  forecast_length: P2D
  forecast_output_frequency: PT3H

  GEOMETRY: !INCLUDE ${JEDI_SRC}/skylab/models/l95/defaults/resol.yaml
  MODEL: !INCLUDE ${JEDI_SRC}/skylab/models/l95/defaults/model.yaml

  cost_function: 4D-Var
  AN_VARIABLES: !INCLUDE ${JEDI_SRC}/skylab/models/l95/defaults/an_variables.yaml

  BACKGROUND_ERROR: !INCLUDE ${JEDI_SRC}/skylab/models/l95/defaults/bstatic.yaml

  OBSERVATIONS:
  - !INCLUDE ${JEDI_SRC}/skylab/models/l95/defaults/obs.yaml

  JC: !INCLUDE ${JEDI_SRC}/skylab/models/l95/defaults/jc.yaml
  MINIMIZER: !INCLUDE ${JEDI_SRC}/skylab/algorithms/drplanczos.yaml

  ninner: 10
  reduc: 1.0e-5
  MIN_GEOMETRY: !INCLUDE ${JEDI_SRC}/skylab/models/l95/defaults/resol.yaml
  LINEAR_MODEL: !INCLUDE ${JEDI_SRC}/skylab/models/l95/defaults/tlm.yaml

More information on R2D2 can be found in the
`R2D2 README <https://github.com/JCSDA-internal/r2d2?tab=readme-ov-file#research-repository-for-data-and-diagnostics-r2d2>`_.

Plots configuration
-------------------

Yaml configuration for the plots (included in :code:`plots` section of the experiment configuration yaml) allows the user to configure plots of variational diagnostics, and plots of model fields on lat-lon grid. The following options are available:

.. code-block:: yaml

    # For model plots
    plotModel:
      plot_geom: 1                            # lat-lon grid resolution in degrees
      plot_variables: [air_temperature]       # list of variables to output
      plot_pressure_levels: [850, 500, 250]   # list of pressure levels in hPa to plot (optional)
      plot_model_levels: [1]                  # list of model levels to plot (optional). Typically either
                                              # pressure or model levels are specified. For plotting 2D
                                              # variables both plot_pressure_levels and plot_model_levels
                                              # can be omitted
      plot_4d: true                           # flag to output 4D increments for 4DEnVar (false by default)
      plot_region: conus                      # key for limiting plot region to CONtinental US (CONUS)
                                              # omiting key will produce global plot

    # Plots of variational diagnostics
    plotVarDiagnostics:
    - CostFunction # line plot of minimization-related diagnostics
    - JoJb         # time-series of Jo & Jb
    - trHKbyp      # time-series of the trace of HK scaled by the number of observations
    - ObCnt        # barplot of the mean observation count per cycle
    - TotImp       # barplot of the mean total impact per cycle (Jo reduction)
    - ImpPerOb     # barplot of the mean impact per observation per cycle (Jo reduction)
    - FracImp      # barplot of the mean fractional impact per cycle (Jo reduction)


Plot region
~~~~~~~~~~~

Currently, the only two available plot regions are :code:`global` and :code:`conus`. However, with a few
modifications in the :code:`SIMOBS` repository, a user can change the domain to another limited area. In
script for the :code:`plot_global_latlon_map.py` located in :code:`simobs/src/simobs/plotting`, find the
:code:`if` block that defines the **CONUS** region:

.. code-block:: python

        map_projection = cartopy.crs.LambertConformal()
        map_transform = cartopy.crs.PlateCarree()
        image_extent = (-120, -70, 25, 50)
        lon_gridlines = [-110, -100, -90, -80]
        lat_gridlines = [25, 35, 45]
        data_range = (230, 295, 25, 50)  # (-130, -65, 25, 50)
        # slice out data within plot region
        pdata, plon, plat, lats = plot_limiter(data, lat, lon, data_range)
        data = pdata


The :code:`image_extent` tuple roughly defines the :code:`cartopy` plot window. Respectively,
the entries are the west-longitude, east-longitude, southern-latitude, and northern-latitude boundaries.
The :code:`lon_gridlines` and :code:`lat_gridlines` lists manually set the gridlines that will appear
in the plot. :code:`data_range` is similar to :code:`image_extent`, except this is (1) what will be used
to slice out the data for your region out of the global data set (so that the histogram & colorbar only
include data from your chosen region) and (2) expects longitudes in the range [0, 360). The entries in
:code:`image_extent` and :code:`data_range` should *nearly* correspond to eachother; the longitude bounds in
:code:`data_range` will likely need extend a little beyond the ones in :code:`image_extent` so that the plotted
data fills your entire plot window. When running an experiment, leave the :code:`plot_region: conus` line in
the plot configuration yaml.

.. note::

  Producing a limited plot region that extends around full lines of latitude (i.e., includes all longitudes),
  like a plot of the tropics, is not fully supported with this method. More work will be needed to produce such
  a plot.


Existing experiments and adding new experiments
-----------------------------------------------

To add a new experiment we recommend starting from an existing experiment yaml file
and modify it for your case to reduce the chance of introducing syntax errors.


Light versions of these experiments are also available. Using the same dates,
algorithm, model, observations and observation operators, and background. Users
can run them on a local machine (look for :code:`experiment-name-small.yaml`).


1. skylab-aero.yaml
-------------------

The :code:`skylab-aero` experiment runs an EDA with 3 members at a c96 resolution, for 17 days
in August 2021. At the moment it is non cycling and running the ID model (as a placeholder for
future gfs-aero model integration).
It is using a static B and a 3D-Var cost function. The four instruments being assimilated are:

* viirs_npp

* viirs_n20

* modis_aqua

* modis_terra


2. skylab-atm-land.yaml
-----------------------

The :code:`skylab-atm-land` experiment runs a full DA system (deterministic and EDA) with 25
members at a c384 resolution for outer loops and c192 for inner loops, for 30 days in
February-March 2022.
It is non cycling and currently running the FV3-LM model (as a placeholder for future
UFS model integration).

It is using a hybrid B matrix and 3D-Var cost functions for both the deterministic and the EDA.
The observations currently assimilated are:

* radiosonde_prepbufr

* windborne

* aircraft_prepbufr

* satwinds_ssec_amv

* buoy_ldm

* synop_ldm

* metar_ldm

* ship_ldm

* scatwind

* snowdepth_ghcn

* gnssro_planetiq

* gnssro_noaa_comm

* gnssro

* gnssro_spire

* amsua_n19

* amsua_n18

* amsua_n15

* amsua_metop-c

* amsua_metop-b

* cris-fsr_npp

* cris-fsr_n20

* iasi_metop-b

* iasi_metop-c

* atms_npp

* atms_n20

* mhs_n19

* mhs_metop-c

* mhs_metop-b

* amsr2_gcom-w1

* gmi_gpm

* ssmis_f17

* ssmis_f18

* tms_tropics-01 (currently monitored only)

* abi_g16_bt_64km

* abi_g17_bt_64km

* cowvr_iss

* tempest_iss


3. skylab-marine.yaml
---------------------

The :code:`skylab-marine` experiment runs a single DA system at 0.25 degrees resolution for
outer loops and inner loops, for 30 days in August 2021.
It is non cycling (waiting for future MOM6 model integration).

It is using a static B matrix and 3D-Var cost function.
The observations currently assimilated are:

* adt_3a

* adt_3b

* adt_c2

* adt_j3

* adt_sa

* sst_avhrr_metop-b

* sst_avhrr_metop-c

* ocean_profile

* icec_ssmis_f17

* icec_ssmis_f18

4. skylab-trace-gas.yaml
------------------------

The :code:`skylab-trace-gas` experiment runs a single DA system at c90 resolution for
outer loops and inner loops, for 10 days in August 2021.
It is non cycling and running the Pseudo model (as a placeholder for the geos-cf model integration).

It is using a static B matrix and 3D-FGAT cost function.
The observations currently assimilated are:

* tropomi_s5p_no2_tropo or tropomi_s5p_no2_total

* mopitt_terra_co_total

* tropomi_s5p_co_total

* tempo_no2_tropo
