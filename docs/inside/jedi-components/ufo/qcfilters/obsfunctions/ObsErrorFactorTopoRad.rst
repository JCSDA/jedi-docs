.. _ObsErrorFactorTopoRad:

ObsErrorFactorTopoRad
=====================

This obsfunction was designed to mimic GSI-Observer method of observation Error Inflation Factor (EIF).

Error Inflation Factor (EIF) as a function of terrain height, channel, and surface-to-space transmittance.

H = surface height [m]

X = surface-to-space transmittance

IASI, CrIS, AIRS and AVHRR3:

  :math:`factor = (2000/H)^4`

  :math:`EIF = SQRT \{ 1 / [ 1 - (1 -factor ) * X] \}` if :math:`H > 2000`, for all the input channels

AMSU-A:

  :math:`EIF = SQRT [ 1 / ( 2000 / H ) ]` if :math:`2000 < H < 4000`, for Channels 1-6,15

  :math:`EIF = SQRT [ 1 / ( 4000 / H ) ]` if :math:`H > 4000`, for Channel 7

ATMS:

  :math:`EIF = SQRT [ 1 / ( 2000 / H ) ]` if :math:`2000 < H < 4000`, for Channels 1-7,16

  :math:`EIF = SQRT [ 1 / ( 4000 / H ) ]` if :math:`H > 4000`, for Channel 8

Required input parameters:
~~~~~~~~~~~~~~~~~~~~~~~~~~

Sensor
  Sensor name: currently only works for these sensors :code:`iasi`, :code:`cris-fsr`, :code:`airs`, :code:`avhrr3`, :code:`amsua`, :code:`atms`

Channels
  Used channels

Output parameters:
~~~~~~~~~~~~~~~~~~

Error Inflation Factor (EIF) for each input channel of the input sensor at each location.

Required fields from obs/geoval:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

geovals
  :code:`surface_geopotential_height@GeoVaLs`

obsDiag
  :code:`transmittances_of_atmosphere_layer@ObsDiag`

Example configurations:
~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: yaml

   - filter: BlackList
    filter variables:
    - name: brightness_temperature
      channels: 1-15
    action:
      name: inflate error
      inflation variable:
        name: ObsErrorFactorTopoRad@ObsFunction
        channels: 1-15
        options:
          sensor: amsua_n19
          channels: 1-15

In this example, the observation errors of NOAA-19 AMSU-A are inflated according to the algorithm.

