.. _top-oops-toymodels:

Toy Models in OOPS
==================

Specific documentation
----------------------

OOPS provides the following toy models that can be used in idealized experiments:

* :doc:`Lorenz95<l95>`
* :doc:`Quasi-geostrophic<qg>`

Unified plotting tool
---------------------

Usage
^^^^^

The python script :code:`plot.py` in :code:`oops/tools` can be used to plot various diagnostics for the Lorenz95 and quasi-geostrophic models, with the following syntax:

.. code-block:: bash

  python3 plot.py $MODEL $DIAG $GENERIC_ARGS $SPECIFIC_ARGS

where:
 - $MODEL indicates the toy-model,
 - $DIAG indicates the diagnostic,
 - $GENERIC_ARGS is a sequence of generic arguments,
 - $SPECIFIC_ARGS is a sequence of model- and diagnostic-specific arguments.

Generic arguments:

+------------------+---------------------------------------------+
| $GENERIC_ARGS    | DESCRIPTION                                 +
+==================+=============================================+
| :code:`-h`       | Print help message                          |
+------------------+---------------------------------------------+
| :code:`--output` | Optional output file name without extension |
+------------------+---------------------------------------------+

Specific arguments:

+-------------+---------------------+----------------------+--------------------------------------------------------+
| $MODEL      | $DIAG               | $SPECIFIC_ARGS       | DESCRIPTION                                            |
+=============+=====================+======================+========================================================+
| :code:`l95` | :code:`cost`        | :code:`filepath`     | Log file path [.test or .log.out]                      |
+             +---------------------+----------------------+--------------------------------------------------------+
|             | :code:`fields`      | :code:`filepath`     | NetCDF file path [.nc]                                 |
+             +                     +----------------------+--------------------------------------------------------+
|             |                     | :code:`basefilepath` | Base NetCDF file path for difference [.nc]             |
+             +                     +----------------------+--------------------------------------------------------+
|             |                     | :code:`-bg`          | Background file path (optional for plot) [.nc]         |
+             +                     +----------------------+--------------------------------------------------------+
|             |                     | :code:`-t`           | Truth file path (optional for plot) [.nc]              |
+             +                     +----------------------+--------------------------------------------------------+
|             |                     | :code:`-o`           | Observations file path (optional for plot) [.nc]       |
+             +---------------------+----------------------+--------------------------------------------------------+
|             | :code:`timeseries`  | :code:`filepath`     | NetCDF file path (with %id% template) [.nc]            |
+             +                     +----------------------+--------------------------------------------------------+ 
|             |                     | :code:`-fKey`        | Legend key for data from 'filepath' file (optional)    |
+             +                     +----------------------+--------------------------------------------------------+
|             |                     | :code:`-f2`          | NetCDF file path (with %id% template) [.nc] (optional) |
+             +                     +----------------------+--------------------------------------------------------+ 
|             |                     | :code:`-f2Key`       | Legend key for data from '-f2' file (optional)         |
+             +                     +----------------------+--------------------------------------------------------+
|             |                     | :code:`-f3`          | NetCDF file path (with %id% template) [.nc] (optional) |
+             +                     +----------------------+--------------------------------------------------------+ 
|             |                     | :code:`-f3Key`       | Legend key for data from '-f3' file (optional)         |
+             +                     +----------------------+--------------------------------------------------------+
|             |                     | :code:`-f4`          | NetCDF file path (with %id% template) [.nc] (optional) |
+             +                     +----------------------+--------------------------------------------------------+ 
|             |                     | :code:`-f4Key`       | Legend key for data from '-f4' file (optional)         |
+             +                     +----------------------+--------------------------------------------------------+
|             |                     | :code:`truthfilepath`| Truth file path (with %id% template) [.nc]             |
+             +                     +----------------------+--------------------------------------------------------+
|             |                     | :code:`times`        | Time series pattern values (used to replace %id%)      |
+             +---------------------+----------------------+--------------------------------------------------------+
|             | :code:`errors`      | :code:`filepath`     | Analysis file path [.nc]                               |
+             +                     +----------------------+--------------------------------------------------------+
|             |                     | :code:`truthfilepath`| Truth file path [.nc]                                  |
+             +                     +----------------------+--------------------------------------------------------+
|             |                     | :code:`-bg`          | Background file path (optional for plot) [.nc]         |
+             +                     +----------------------+--------------------------------------------------------+
|             |                     | :code:`--recenter`   | Recenter plot around first and last variable (optional)|
+             +                     +----------------------+--------------------------------------------------------+
|             |                     | :code:`--title`      | User specified title (optional)                        |
+             +---------------------+----------------------+--------------------------------------------------------+
|             | :code:`increments`  | :code:`filepath`     | Analysis file path [.nc]                               |
+             +                     +----------------------+--------------------------------------------------------+
|             |                     | :code:`bgfilepath`   | Background file path [.nc]                             |
+             +                     +----------------------+--------------------------------------------------------+
|             |                     | :code:`-t`           | Truth file path (optional for plot) [.nc]              |
+             +                     +----------------------+--------------------------------------------------------+
|             |                     | :code:`--recenter`   | Recenter plot around first and last variable (optional)|
+             +                     +----------------------+--------------------------------------------------------+
|             |                     | :code:`--title`      | User specified title (optional)                        |
+-------------+---------------------+----------------------+--------------------------------------------------------+
| :code:`qg`  | :code:`cost`        | :code:`filepath`     | Log file path [.test or .log.out]                      |
+             +---------------------+----------------------+--------------------------------------------------------+
|             | :code:`fields`      | :code:`filepath`     | NetCDF file path [.nc]                                 |
+             +                     +----------------------+--------------------------------------------------------+
|             |                     | :code:`basefilepath` | Base NetCDF file path for difference [.nc]             |
+             +                     +----------------------+--------------------------------------------------------+
|             |                     | :code:`--plotwind`   | Flag to plot the wind                                  |
+             +                     +----------------------+--------------------------------------------------------+
|             |                     | :code:`--gif`        | Pattern replacing %id% in filepath to create a gif     |
+             +---------------------+----------------------+--------------------------------------------------------+
|             | :code:`obs`         | :code:`filepath`     | NetCDF file path [.nc]                                 |
+-------------+---------------------+----------------------+--------------------------------------------------------+

Examples
^^^^^^^^

**L95 / cost**

Plot the cost function components for the 3DVar test of the L95 model:
 - red triangles: :math:`J_b` term
 - blue circles: :math:`J_o` term
 - black xs: :math:`J = J_b + J_o`
 - black continuous line: :math:`quadratic J` inside inner iterations

.. code-block:: bash

  ./plot.py l95 cost --output l95_cost \
                    [build_bundle]/oops/l95/test/testoutput/3dvar.out
  Parameters:
   - model: l95
   - diagnostic: cost
   - filepath: [build_bundle]/oops/l95/test/testoutput/3dvar.out
   - output: l95_cost
  Run script
   -> plot produced: l95_cost.jpg

You will notice the quadratic function is flat, it is because the problem converges very fast.


.. image:: l95_cost.jpg
   :align: center

**L95 / fields**

Plot the analysis increment (analysis - background) for the 3DVar test of the L95 model.

.. code-block:: bash

  ./plot.py l95 fields --output l95_fields \
                       [build_bundle]/oops/l95/test/Data/3dvar.an.2010-01-02T00\:00\:00Z.l95 \
                       [build_bundle]/oops/l95/test/Data/forecast.fc.2010-01-01T00\:00\:00Z.P1D.l95
  Parameters:
   - model: l95
   - diagnostic: fields
   - filepath: [build_bundle]/oops/l95/test/Data/3dvar.an.2010-01-02T00:00:00Z.l95
   - basefilepath: [build_bundle]/oops/l95/test/Data/forecast.fc.2010-01-01T00:00:00Z.P1D.l95
   - output: l95_fields
  Run script
   -> plot produced: l95_fields_incr.jpg

.. image:: l95_fields_incr.jpg
   :align: center


Plot the analysis, background, truth and observations for the 3DVar test of the L95 model.

.. code-block:: bash

  ./plot.py l95 fields [build_bundle]/oops/l95/test/Data/3dvar.an.2010-01-02T00\:00\:00Z.l95 \
            -bg [build_bundle]/oops/l95/test/Data/forecast.fc.2010-01-01T00\:00\:00Z.P1D.l95 \
            -t [build_bundle]/oops/l95/test/Data/truth.fc.2010-01-01T00\:00\:00Z.P1D.l95 \
            -o [build_bundle]/oops/l95/test/Data/truth3d.2010-01-02T00\:00\:00Z.obt
            
  Parameters:
   - model: l95
   - diagnostic: fields
   - filepath: [build_bundle]/oops/l95/test/Data/3dvar.an.2010-01-02T00:00:00Z.l95
   - bgfilepath: [build_bundle]/oops/l95/test/Data/forecast.fc.2010-01-01T00:00:00Z.P1D.l95
   - truthfilepath: [build_bundle]/oops/l95/test/Data/truth.fc.2010-01-01T00:00:00Z.P1D.l95
   - obsfilepath: [build_bundle]/oops/l95/test/Data/truth3d.2010-01-02T00:00:00Z.obt
   - output: None
  Run script
   -> plot produced: 3dvar.an.2010-01-02T00:00:00Z.jpg



Since several observations are available at each location throughout the time window, you can see up to three observation points for each location on the following plot.

.. image:: l95_fields_all_plots.jpg
   :align: center

**L95 / timeseries**

Plot a time series of RMSE(field1 - field2) for DA tests using the L95 model. Optionally plot up to 3 more series with optional user specified legend keys. 

.. code-block:: bash
   
   ./plot.py l95 timeseries [build_bundle]/oops/l95/test/Data/forecast.fc.2010-01-01T00\:00\:00Z.P%id%.l95 \
                            -fKey "Series 1" \
                            -f2 [build_bundle]/oops/l95/test/Data/forecast.ens.1.2010-01-01T00\:00\:00Z.P%id%.l95  \
                            -f2Key "Series 2" \
                            -f3 [build_bundle]/oops/l95/test/Data/forecast.ens.2.2010-01-01T00\:00\:00Z.P%id%.l95 \
                            -f3Key "Series 3" \
                            -f4 [build_bundle]/oops/l95/test/Data/forecast.ens.3.2010-01-01T00\:00\:00Z.P%id%.l95 \
                            -f4Key "Series 4" \
                            [build_bundle]/oops/l95/test/Data/truth.fc.2010-01-01T00\:00\:00Z.P%id%.l95 \
                            T3H,T6H,T9H,T12H,T18H,1D 

  Parameters:
   - model: l95
   - diagnostic: timeseries
   - filepath: [build_bundle]/oops/l95/test/Data/forecast.fc.2010-01-01T00:00:00Z.P%id%.l95
   - fileKey: Series 1
   - filepath2: [build_bundle]/oops/l95/test/Data/forecast.ens.1.2010-01-01T00:00:00Z.P%id%.l95
   - file2Key: Series 2
   - filepath3: [build_bundle]/oops/l95/test/Data/forecast.ens.2.2010-01-01T00:00:00Z.P%id%.l95
   - file3Key: Series 3
   - filepath4: [build_bundle]/oops/l95/test/Data/forecast.ens.3.2010-01-01T00:00:00Z.P%id%.l95
   - file4Key: Series 4
   - truthfilepath: [build_bundle]/oops/l95/test/Data/truth.fc.2010-01-01T00:00:00Z.P%id%.l95
   - times: T3H,T6H,T9H,T12H,T18H,1D
   - output: None
  Run script
   -> plot produced: forecast.fc.2010-01-01T00:00:00Z.P.jpg

.. image:: l95_errors_timeseries.jpg
   :align: center

**L95 / errors**

Plot the following errors for the L95 model: analysis - truth (always) and background - truth (optionally).


.. code-block:: bash

  ./plot.py l95 errors [build_bundle]/oops/l95/test/Data/3dvar.an.2010-01-02T00\:00\:00Z.l95 \
                       [build_bundle]/oops/l95/test/Data/truth.fc.2010-01-01T00\:00\:00Z.P1D.l95 \
                       -bg [build_bundle]/oops/l95/test/Data/forecast.fc.2010-01-01T00\:00\:00Z.P1D.l95 \
                       --recenter --title "Errors Experiment I"

  Parameters:
   - model: l95
   - diagnostic: errors
   - filepath: [build_bundle]/oops/l95/test/Data/3dvar.an.2010-01-02T00\:00\:00Z.l95
   - truthfilepath: [build_bundle]/oops/l95/test/Data/truth.fc.2010-01-01T00\:00\:00Z.P1D.l95
   - bgfilepath: [build_bundle]/oops/l95/test/Data/forecast.fc.2010-01-01T00\:00\:00Z.P1D.l95
   - output: None
   - recenter: True
   - title Errors Experiment I 
  Run script
   -> plot produced: 3dvar.an.2010-01-02T00:00:00Z.jpg

.. image:: l95_errors_an_bg.jpg
   :align: center
   
**L95 / increments**

Plot the following increments for the L95 model: increment analysis-background (always) and perfect increment truth - background (optionally).


.. code-block:: bash

  ./plot.py l95 increments [build_bundle]/oops/l95/test/Data/3dvar.an.2010-01-02T00\:00\:00Z.l95 \
                       [build_bundle]/oops/l95/test/Data/forecast.fc.2010-01-01T00\:00\:00Z.P1D.l95 \
                       -t [build_bundle]/oops/l95/test/Data/truth.fc.2010-01-01T00\:00\:00Z.P1D.l95 \
                       --recenter --title "Increments Experiment I"

  Parameters:
   - model: l95
   - diagnostic: increments
   - filepath: [build_bundle]/oops/l95/test/Data/3dvar.an.2010-01-02T00:00:00Z.l95
   - bgfilepath: [build_bundle]/oops/l95/test/Data/forecast.fc.2010-01-01T00:00:00Z.P1D.l95
   - truthfilepath: [build_bundle]/oops/l95/test/Data/truth.fc.2010-01-01T00:00:00Z.P1D.l95
   - output: None
   - recenter: True
   - title: Increments Experiment I
  Run script
   -> plot produced: 3dvar.an.2010-01-02T00:00:00Z.jpg

.. image:: l95_increments.jpg
   :align: center


**QG / fields**

Plot the analysis for the 3DVar test of the QG model, with corresponding geostropic winds:
 - streamfunction on levels 1 and 2,
 - potential vorticity on levels 1 and 2.

.. code-block:: bash

  ./plot.py qg fields --output qg_fields \
                      --plotwind \
                      [build_bundle]/oops/qg/test/Data/3dvar.an.2010-01-01T12\:00\:00Z.nc
  Parameters:
   - model: qg
   - diagnostic: fields
   - filepath: [build_bundle]/oops/qg/test/Data/3dvar.an.2010-01-01T12:00:00Z.nc
   - basefilepath: None
   - plotwind: True
   - output: qg_fields
  Run script
   -> plot produced: qg_fields_x.jpg
   -> plot produced: qg_fields_q.jpg

.. image:: qg_fields_x.jpg
   :align: center

.. image:: qg_fields_q.jpg
   :align: center

**QG / fields - animated GIF**

Plot the sequence of states of the "truth" forecast in an animated GIF.

.. code-block:: bash

  ./plot.py qg fields --output qg_fields_animation_%id% \
                      [build_bundle]/oops/qg/test/Data/truth.fc.2009-12-15T00\:00\:00Z.%id%.nc \
                      --gif P1D,P2D,P3D,P4D,P5D,P6D,P7D,P8D,P9D,P10D,P11D,P12D,P13D,P14D,P15D,P16D,P17D,P18D
  Parameters:
   - model: qg
   - diagnostic: fields
   - filepath: [build_bundle]/oops/qg/test/Data/truth.fc.2009-12-15T00:00:00Z.%id%.nc
   - basefilepath: None
   - plotwind: False
   - gif: P1D,P2D,P3D,P4D,P5D,P6D,P7D,P8D,P9D,P10D,P11D,P12D,P13D,P14D,P15D,P16D,P17D,P18D
   - output: qg_fields_animation_%id%
  Run script
   -> plot produced: qg_fields_animation_P1D_x.jpg
   -> plot produced: qg_fields_animation_P2D_x.jpg
   -> plot produced: qg_fields_animation_P3D_x.jpg
   -> plot produced: qg_fields_animation_P4D_x.jpg
   -> plot produced: qg_fields_animation_P5D_x.jpg
   -> plot produced: qg_fields_animation_P6D_x.jpg
   -> plot produced: qg_fields_animation_P7D_x.jpg
   -> plot produced: qg_fields_animation_P8D_x.jpg
   -> plot produced: qg_fields_animation_P9D_x.jpg
   -> plot produced: qg_fields_animation_P10D_x.jpg
   -> plot produced: qg_fields_animation_P11D_x.jpg
   -> plot produced: qg_fields_animation_P12D_x.jpg
   -> plot produced: qg_fields_animation_P13D_x.jpg
   -> plot produced: qg_fields_animation_P14D_x.jpg
   -> plot produced: qg_fields_animation_P15D_x.jpg
   -> plot produced: qg_fields_animation_P16D_x.jpg
   -> plot produced: qg_fields_animation_P17D_x.jpg
   -> plot produced: qg_fields_animation_P18D_x.jpg
   -> gif produced: qg_fields_animation_P1D_x.gif
   -> plot produced: qg_fields_animation_P1D_q.jpg
   -> plot produced: qg_fields_animation_P2D_q.jpg
   -> plot produced: qg_fields_animation_P3D_q.jpg
   -> plot produced: qg_fields_animation_P4D_q.jpg
   -> plot produced: qg_fields_animation_P5D_q.jpg
   -> plot produced: qg_fields_animation_P6D_q.jpg
   -> plot produced: qg_fields_animation_P7D_q.jpg
   -> plot produced: qg_fields_animation_P8D_q.jpg
   -> plot produced: qg_fields_animation_P9D_q.jpg
   -> plot produced: qg_fields_animation_P10D_q.jpg
   -> plot produced: qg_fields_animation_P11D_q.jpg
   -> plot produced: qg_fields_animation_P12D_q.jpg
   -> plot produced: qg_fields_animation_P13D_q.jpg
   -> plot produced: qg_fields_animation_P14D_q.jpg
   -> plot produced: qg_fields_animation_P15D_q.jpg
   -> plot produced: qg_fields_animation_P16D_q.jpg
   -> plot produced: qg_fields_animation_P17D_q.jpg
   -> plot produced: qg_fields_animation_P18D_q.jpg
   -> gif produced: qg_fields_animation_P1D_q.gif

.. image:: qg_fields_animation_P1D_x.gif
   :align: center

.. image:: qg_fields_animation_P1D_q.gif
   :align: center

**QG / obs**

Copy the observation file values from the NetCDF into a text file.

.. code-block:: bash

  ./plot.py qg obs --output qg_obs [build_bundle]/oops/qg/test/Data/3dvar.obs3d.nc
  Parameters:
   - model: qg
   - diagnostic: obs
   - filepath: [build_bundle]/oops/qg/test/Data/3dvar.obs3d.nc
   - output: qg_obs
  Run script
   -> Observations values written in qg_obs.txt

File extract:

.. code-block:: bash

  # location / value / hofx
  [ -29.87208056    3.63767342 3266.44902118] / [10594165.5105961] / [10594165.5105961]
  [ 178.98653093    8.23197272 5786.33931931] / [-876673.14254443] / [-876673.14254443]
  [  79.31681614   59.17619073 5270.58105916] / [-1.33785214e+08] / [-1.33785214e+08]
  ...
  [  30.72931674   18.82485907 6153.04231877] / [56.26459124] / [56.26459124]
