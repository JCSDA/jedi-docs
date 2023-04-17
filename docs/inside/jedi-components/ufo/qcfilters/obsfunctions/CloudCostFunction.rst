.. _CloudCostFunction:

CloudCostFunction
--------------------------------------------------------------------------------------

This ObsFunction calculates a Bayesian cost function for detecting cloud-affected
radiances. Its heritage is the Met Office OPS.

A cloud cost, :math:`J_{c}`, is calculated from observation-H(x) departures,
:math:`\mathbf{y}`, via

:math:`J_{c} = (0.5/N_{chan}) * \mathbf{y} \mathbf{W} \mathbf{y}^{T}`

where :math:`N_{chan}` is the number of channels in the calculation and
:math:`\mathbf{W}` is the inverse of
:math:`(\mathbf{H}\mathbf{B}\mathbf{H}^{T}+\mathbf{R})`:

- :math:`\mathbf{H}` is the Jacobian matrix;
- :math:`\mathbf{B}` is a background error covariance matrix;
- :math:`\mathbf{R}` is an observation error covariance matrix.

Implementation here follows Met Office usage, with a static (latitude-varying)
:math:`\mathbf{B}`-matrix and a fixed, diagonal :math:`\mathbf{R}`-matrix.

Required parameters:
~~~~~~~~~~~~~~~~~~~~

cost channels list
  List of channels used in the calculation of the cost function

RMatrix
  Path to location of file describing the :math:`\mathbf{R}`-matrix

BMatrix
  Path to location of file describing the :math:`\mathbf{B}`-matrix

background fields
  List of geovals names describing fields required from the
  :math:`\mathbf{B}`-matrix

Optional parameters:
~~~~~~~~~~~~~~~~~~~~

qtotal
  Boolean flag indicating that the :math:`\mathbf{B}`-matrix file contains
  error covariances for :math:`ln(` qtotal in units g/kg :math:`)`. Setting this
  flag requires that the following are all present in the parameter list
  "background fields":

  - specific_humidity
  - mass_content_of_cloud_liquid_water_in_atmosphere_layer
  - mass_content_of_cloud_ice_in_atmosphere_layer

  Default: false

qtotal split rain
  Include treatment of rain when splitting total humidity into constituent phases

  Default: false

scattering radiative transfer
  Include gradient due to ice in brightness temperature total humidity Jacobian

  Default: false

minimum specific humidity
  Limit specific humidity to minimum value (kg/kg)

  Default: 3.0e-6f

reverse Jacobian order
  Jacobian vertical ordering is reverse of geovals

  Default: false

minimum ObsValue
  Minimum bound for ObsValue brightness temperature (K)

  Default: 70.0

maximum ObsValue
  Maximum bound for ObsValue brightness temperature

  Default: 340.0

maximum final cost
  Maximum value for final cost returned by the ObsFunction

  Default: 1600.0

HofX group
  Name of the H(x) group used in the cost function calculation

  Default: "HofX"

Reference:
~~~~~~~~~~

S.J. English, J.R. Eyre and J.A. Smith.
A cloud‐detection scheme for use with satellite sounding radiances in the
context of data assimilation for numerical weather prediction support of
nowcasting applications.
Quart. J. Royal Meterol. Soc., Vol. 125, pp. 2359-2378 (1999).
https://doi.org/10.1002/qj.49712555902

Example yaml:
~~~~~~~~~~~~~

Here is an example using this ObsFunction inside the Bounds Check filter.
The brightnessTemperature filter variables are rejected if the output value
of this ObsFunction is larger than the example maxvalue = 69.8.

.. code-block:: yaml

  - filter: Bounds Check
    filter variables:
    - name: brightnessTemperature
      channels: 18-20
    where:
    - variable:
        name: MetaData/landOrSeaQualifier
      is_in: 0  # land=0, sea=1, ice=2
    test variables:
    - name: ObsFunction/CloudCostFunction
      options:
        cost channels list: 18, 20, 22
        RMatrix: ../resources/rmatrix/rttov/atms_noaa_20_rmatrix_test.nc4
        BMatrix: ../resources/bmatrix/rttov/atms_bmatrix_70_test.dat
        background fields:
        - air_temperature
        - specific_humidity
        - mass_content_of_cloud_liquid_water_in_atmosphere_layer
        - mass_content_of_cloud_ice_in_atmosphere_layer
        - surface_temperature
        - specific_humidity_at_two_meters_above_surface 
        - skin_temperature 
        - air_pressure_at_two_meters_above_surface
        qtotal: true
        qtotal split rain: true
        reverse Jacobian order: true
        HofX group: HofX  # default
    maxvalue: 69.8        # example value
    action:
      name: reject
