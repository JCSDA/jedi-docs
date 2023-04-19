.. _top-ufo-varbc:

Variational Bias Correction in UFO
======================================
  .. note::

    Summarized from :

      - :cite:`ZhuVarBC14`
      - :cite:`DDVarBC04`

Linear combination formulation
+++++++++++++++++++++++++++++++++++++

  .. math::

    \vec{y} = H(\vec{x}) + \sum_{i=0}^{N} \beta_i p_i(\vec{x}) + \tilde{\vec{e}_o}

  with scalar coefficients :math:`\beta_i, i = 0, . . . ,N` . The selection of predictors :math:`p_i(\vec{x}), i = 1, . . . ,N`  is flexible and depends on the instrument and channel.

Augmented control variable
+++++++++++++++++++++++++++++++++++

  Define the augmented control vector

    .. math::

      \vec{z}^T = \lbrack \vec{x}^T \vec{\beta}^T \rbrack

  Therefore, the cost function to be minimized

    .. math::

      J(\vec{z}) = \frac{1}{2} (\vec{z}_b - \vec{z})^T \textbf{Z}^{-1} (\vec{z}_b - \vec{z}) +  \frac{1}{2} (\vec{y} - \tilde{H}(\vec{z}))^T \textbf{R}^{-1} (\vec{y} - \tilde{H}(\vec{z}))

  where

    .. math::
      :label: Hop

      \tilde{H}(\vec{z}) = H(\vec{x}) + \sum_{i=0}^{N} \beta_i p_i(\vec{x})

Adjoint of the bias model
+++++++++++++++++++++++++++++

  In the incremental formulation of the variational analysis, nonlinear observation operators are linearized about the latest outer-loop estimate :math:`\overline{\vec{x}}` of :math:`\vec{x}` . Similarly, for the modified operator we use

    .. math::

        H(\vec{x}, \beta) \approx H(\overline{\vec{x}}, \beta) & = H(\overline{\vec{x}}) + \sum_{i=0}^{N} \beta_i p_i(\overline{\vec{x}}) \\
        & = H(\overline{\vec{x}}) + \mathcal{P}(\overline{\vec{x}}) \cdot \vec{\beta}

  where :math:`\mathcal{P}(\overline{\vec{x}})` is a :math:`m × n` predictor matrix consisting of :math:`n` predictors evaluated on :math:`m` observation locations.

  The modification to :math:`H(\vec{x})` is therefore additive and linear in the bias parameters, and its adjoint with respect to these additional control parameters is trivial to implement.

  For the linear predictor model :eq:`Hop`, the derivatives with respect to the parameters are simply the values of the predictors at the observation locations

    .. math::

      \frac{\partial H }{\partial \vec{\beta}} \Bigg \vert_{\vec{\beta} = \vec{\beta}_b} = \mathcal{P}(\overline{\vec{x}})


Background error covariance
++++++++++++++++++++++++++++++

  In general the parameter estimation errors will be correlated with the state estimation errors, because they depend on the same data. We know of no practical way to account for this statistical dependence, and therefore take

    .. math::

      \textbf{Z} = \begin{bmatrix}
                      \textbf{B}_x & 0 \\
                      0 & \textbf{B}_{\beta}
                    \end{bmatrix}

  where :math:`\textbf{B}_x` denotes the usual (state) background error covariance, and :math:`\textbf{B}_\beta` the parameter background error covariance.

  We take :math:`\textbf{B}_\beta` diagonal:

    .. math::

      \textbf{B}_\beta & = diag(\sigma_{\beta_1}^2, ...., \sigma_{\beta_n}^2)  \\
                        & = \begin{bmatrix}
                              \sigma_{\beta_1}^2 & &   \\
                              & \ddots &  \\
                              & & \sigma_{\beta_n}^2
                            \end{bmatrix}   \\
                        & = \begin{bmatrix}
                              \frac{\sigma_{o_1}^2}{N_1} & &   \\
                              & \ddots &  \\
                              & & \frac{\sigma_{o_n}^2}{N_j}
                            \end{bmatrix}

  Here :math:`\beta_j` denotes the :math:`j^{th}` bias parameter, :math:`\sigma_{o_j}` is the error standard deviation of the observations associated with :math:`\beta_j`, and :math:`N_j` is a positive integer represents the number of observations.

  .. note::

    - For example, taking :math:`N_j = 10,000` for all parameters, the system will adapt quickly to changes in the bias for a clean channel generating thousands of radiances per analysis cycle.
    - On the other hand, it will respond slowly to a cloudy channel that generates only a few hundreds of data per cycle.


  .. note::

    - When the :math:`N_j` are sufficiently large (say, :math:`N_j >> 100` ), the effect of neglecting off-diagonal elements of the parameter background error covariance matrix should be insignificant. This is because :math:`\mathcal{O}(N_j)` observations are used to estimate just a few bias parameters; the estimation errors will be small even when the estimation is suboptimal.
    - The situation is, of course, very different for the state estimation, which can be extremely sensitive to the specification of the background error covariances, especially in data-sparse areas.

VarBC example
+++++++++++++++++++++++++

To use the bias correction in an observation operator, add the :code:`obs bias` section as shown in the highlighted lines below.

.. code-block:: yaml

  :linenos:
  :emphasize-lines: 12-24

  observations:
    observers:
    - obs space:
        name: AMSUA-NOAA19
        ...
        simulated variables: [brightnessTemperature]
        channels: &channels 1-15
      obs operator:
        name: CRTM
        obs options:
          Sensor_ID: &Sensor_ID amsua_n19
        ...
      obs bias:
        input file: Data/obs/satbias_crtm_in_amsua_n19.nc4
        variational bc:
          predictors:
          - name: constant
          - name: emissivity
          - name: scan_angle
            order: 4
          - name: scan_angle
            order: 3
          - name: scan_angle
            order: 2
          - name: scan_angle

Here is the detailed explanation:

  1. Defines the predictors (required)

    Here, we defined 6 predictors to be used for VarBC, which are :code:`constant`, :code:`emissivity`, and 1st, 2nd, 3rd, 4th order :code:`scan_angle`, respectively. To find what predictor functions are available, please refer to directory :code:`ufo/src/ufo/predictors/`.

    .. code-block:: yaml

      variational bc:
        predictors:
        - name: constant
        - name: emissivity
        - name: scan_angle
          order: 4
        - name: scan_angle
          order: 3
        - name: scan_angle
          order: 2
        - name: scan_angle

  2. Defines the input file for the bias coefficients prior (optional)

     Usually, the prior is coming from the previous data assimilation cycle. If it is not available, all coefficients will start with zero.

    .. code-block:: yaml

      input file: Data/obs/satbias_crtm_in_amsua_n19.nc4

Static Bias Correction in UFO
=============================

Static bias correction is handled very similarly to variational bias correction. Mathematically, the only difference is that the coefficients :math:`\beta_i` of predictors used for static bias correction are kept constant and equal to 1. These predictors are defined in the :code:`obs bias.static bc` YAML section, whose syntax is identical to :code:`obs bias.variational bc`. For example,

.. code-block:: yaml

  static bc:
    predictors:
    - name: interpolate_data_from_file
      corrected variables:
      - name: airTemperature
        file: air_temperature_static_bc.csv
        interpolation:
        - name: MetaData/stationIdentification
          method: exact
      - name: relativeHumidity
        file: relative_humidity_static_bc.csv
        interpolation:
        - name: MetaData/stationIdentification
          method: exact
        - name: MetaData/pressure
          method: least upper bound

See the :ref:`interpolate_data_from_file` section for more information about the predictor used
above, which was written specifically with static bias correction in mind.

Available Predictors
====================

`cloud_liquid_water`
++++++++++++++++++++

Cloud liquid water.

The following options are supported:

* :code:`satellite`: Satellite reference name such as :code:`SSMIS`; this lets the predictor know which which channels to expect. At present :code:`SSMIS` is the only supported satellite.
* :code:`varGroup`: (Optional) Name of the ObsSpace group from which brightness temperatures will be loaded. By default, :code:`ObsValue`.
* :code:`ch...`: Satellite-dependent channel numbers used for cloud liquid water calculation. For :code:`SSMIS` the following channel numbers need to be specified: :code:`ch19h`, :code:`ch19v`, :code:`ch22v`, :code:`ch37h`, :code:`ch37v`, :code:`ch91h` and :code:`ch91v`:.

Example
.......

.. code-block:: yaml

  name: cloud_liquid_water
  satellite: SSMIS
  ch19h: 12
  ch19v: 13
  ch22v: 14
  ch37h: 15
  ch37v: 16
  ch91v: 17
  ch91h: 18

`constant`
++++++++++

A predictor equal to one at all locations.

`cosine_of_latitude_times_orbit_node`
+++++++++++++++++++++++++++++++++++++

Cosine of the observation latitude multiplied by the sensor azimuth angle.

`emissivity`
++++++++++++

Emissivity.

.. _interpolate_data_from_file:

`interpolate_data_from_file`
++++++++++++++++++++++++++++

A predictor drawing values from an input CSV or NetCDf file depending on the values of specified
ObsSpace variables. Typically used for static bias correction.

Example 1 (minimal)
...................

Consider a simple example first and suppose this predictor is configured as follows:

.. code-block:: yaml

  name: interpolate_data_from_file
  corrected variables:
  - name: airTemperature
    file: myfolder/example_1.csv
    interpolation:
    - name: MetaData/stationIdentification
      method: exact

and the :code:`example_1.csv` file looks like this:

.. code-block::

    MetaData/stationIdentification, ObsBias/airTemperature
    string,float
    ABC,0.1
    DEF,0.2
    GHI,0.3

The predictor will load this file and at each location compute the bias correction of air temperature by

* selecting the row of the CSV file in which the value in the :code:`MetaData/stationIdentification` column matches exactly the value of the :code:`MetaData/stationIdentification` ObsSpace variable at that location and
* taking the value of the :code:`ObsBias/airTemperature` column from the selected row.

It is possible to customize this process in several ways by

* correcting more than one variable
* making the bias correction dependent on more than one variable
* using other interpolation methods than exact match (for example nearest-neighbor match or linear interpolation)
* using a NetCDF rather than a CSV input file.

This is explained in more detail below.

The :code:`corrected variables` option
......................................

Each element of the :code:`corrected variables` list specifies how to generate bias corrections for
a particular bias-corrected variable and should have the following attributes:

* :code:`name`: Name of a bias-corrected variable.
* :code:`channels`: (Optional) List of channel numbers of the bias-corrected variable.
* :code:`file`: Path to an input NetCDF or CSV file.  See :ref:`here <DataExtractorInputFileFormats>`
  for supported file formats.  However, note that unlike :ref:`DrawValueFromFile`,
  we don't specify the group name corresponding to our payload array.  We expect it to be ``ObsBias``.
* :code:`interpolation`: A list of one or more elements indicating how to map specific
  ObsSpace variables to slices of arrays loaded from the input file.  See
  :ref:`here <DrawValueFromFileInterpolation>` for further details.

The predictor produces zeros for all bias-corrected variables missing from the :code:`corrected
variables` list.

The following examples illustrate more advanced applications of this predictor.

Example 2 (multiple criterion variables, linear interpolation)
..............................................................

To make the air-temperature bias correction depend not only on the station ID, but also on the air pressure, we could use the following YAML snippet

.. code-block:: yaml

  name: interpolate_data_from_file
  corrected variables:
  - name: airTemperature
    file: example_2.csv
    interpolation:
    - name: MetaData/stationIdentification
      method: exact
    - name: MetaData/pressure
      method: linear

and CSV file:

.. code-block::

    MetaData/stationIdentification, MetaData/pressure, ObsBias/air_temperature
    string,float,float
    ABC,30000,0.1
    ABC,60000,0.2
    ABC,90000,0.3
    XYZ,40000,0.4
    XYZ,80000,0.5

For an observation taken by station XYZ at pressure 60000 the bias correction would be evaluated in
the following way:

* First, find all rows in the CSV file with a value of :code:`XYZ` in the :code:`MetaData/stationIdentification`
  column.
* Then take the values of the :code:`MetaData/pressure` and :code:`ObsBias/airTemperature` columns
  in these rows and use them to construct a piecewise linear interpolant. Evaluate this
  interpolant at pressure 60000. This produces the value of 0.45.

.. _interpolate example 3:

Example 3 (multichannel variables)
..................................

To make the brightness-temperature bias correction vary with the channel number and scan position,
we could use the following YAML snippet

.. code-block:: yaml

  name: interpolate_data_from_file
  corrected variables:
  - name: brightnessTemperature
    channels: 1-2, 4-6
    file: example_3.csv
    interpolation:
    - name: MetaData/sensorScanPosition
      method: nearest

and CSV file:

.. code-block::

    MetaData/sensorChannelNumber,MetaData/sensorScanPosition,ObsBias/brightnessTemperature
    int,int,float
    1,25,0.01
    2,25,0.02
    4,25,0.04
    5,25,0.05
    6,25,0.06
    1,75,0.11
    2,75,0.12
    4,75,0.14
    5,75,0.15
    6,75,0.16

This would produce, for example, a bias correction of 0.12 for an observation from channel 2 taken
at scan position 60.

.. _interpolate example 4:

Example 4 (fallback values, ranges)
...................................

To apply a bias correction of 1.0 to observations taken by station XYZ in the Northern hemisphere
and 0.0 to all other observations, we could use the following YAML snippet

.. code-block:: yaml

  name: interpolate_data_from_file
  corrected variables:
  - name: airTemperature
    file: example_4.csv
    interpolation:
    - name: MetaData/stationIdentification
      method: exact
    - name: MetaData/latitude
      method: least upper bound

and CSV file:

.. code-block::

    MetaData/stationIdentification,MetaData/latitude,ObsBias/airTemperature
    string,float,float
    _,_,0
    XYZ,0,0
    XYZ,90,1

Above, the first row of the data block (:code:`_,_,0`) encodes the bias correction to apply to
observations taken by stations other than XYZ; the second row, to observations taken by station XYZ
in the Southern hemisphere or on the equator (:code:`latitude` ≤ 0); and the third row, to
observations taken by station XYZ in the Northern hemisphere.

`lapse_rate`
++++++++++++

nth power of the lapse rate.

The following options are supported:

* :code:`order` (Optional) Power to which to raise the lapse rate. By default, 1.

`Legendre`
++++++++++

The Legendre polynomial :math:`P_n(x)` where `n` is the value of the :code:`order` option,

    x = -1 + 2 * (scan_position - 1) / (n_scan_positions - 1),

:code:`n_scan_positions` is the value of the :code:`number of scan positions` option and :code:`scan_position` is the sensor scan position loaded from the :code:`scan_position@MetaData` variable (assumed to range from 1 to :code:`n_scan_positions`).

The following options are supported:

* :code:`number of scan positions` The number of scan positions.
* :code:`order` (Optional) Order of the Legendre polynomial. By default, 1.

Example
.......

.. code-block:: yaml

  name: Legendre
  number of scan positions: 32
  order: 2

`orbital_angle`
+++++++++++++++

A term of the Fourier series of the orbital angle :math:`\theta` (loaded from the :code:`satellite_orbital_angle@MetaData` variable), i.e. :math:`\sin(n\theta)` or :math:`\cos(n\theta)`.

The following options are supported:

* :code:`component`: Either :code:`sin` or :code:`cos`.
* :code:`order` (Optional) Order of the term to be calculated (:math:`n` in the formulas above). By default, 1.

Example
.......

.. code-block:: yaml

  name: orbital_angle
  component: cos
  order: 2

`scan_angle`
++++++++++++

nth power of the scan angle.

The following options are supported:

* :code:`var_name`: (Optional) Name of the ObsSpace variable (from the :code:`MetaData` group) storing the scan angle (in degrees). By default, :code:`sensor_view_angle`.
* :code:`order` (Optional) Power to which to raise the scan angle. By default, 1.

Example
.......

.. code-block:: yaml

  name: scan_angle
  var_name: scan_position
  order: 2

`sine_of_latitude`
++++++++++++++++++

Sine of the observation latitude.

`thickness`
+++++++++++

Thickness (in km) of a specified pressure level interval, calculated as the difference between the geopotential heights at two pressure levels and normalized to zero mean and unit variance.

The following options are required:

* :code:`layer top`: Pressure value (in Pa) at the top of the required thickness layer.
* :code:`layer base`: Pressure value (in Pa) at the bottom of the required thickness layer.
* :code:`mean`: Climatological mean of the predictor.
* :code:`standard deviation`: Climatological standard deviation of the predictor.

Example
.......

.. code-block:: yaml

  name: thickness
  layer top: 30000
  layer base: 85000
  mean: 7.6
  standard deviation: 0.4
