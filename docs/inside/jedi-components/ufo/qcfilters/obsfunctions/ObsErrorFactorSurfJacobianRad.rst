.. _ObsErrorFactorSurfJacobianRad:

ObsErrorFactorSurfJacobianRad
-----------------------------------------------------------------------------------------------

This obsFunction is designed to compute observation error inflation factor for brightness temperature as a function of weighted surface temperature jacobian and surface emissivity jacobian. The error inflation factor (EIF) is defined as:

.. math::
   \text{EIF} = \sqrt{1 + Errinv * Beta}

where
  :math:`Errinv` = inverse of effective observation error variance

  :math:`Beta` = :math:`{(obserr_{dtempf} * \left| {Jtemp} \right| + obserr_{demisf} * \left| {Jemis} \right| )}^2`

  :math:`J_{temp}` = surface temperature jacobian

  :math:`J_{emis}` = surface emissivity jacobian

  :math:`obserr_{dtempf}` = empirical constant as a function of surface type applied to Jtemp

  :math:`obserr_{demisf}` = empirical constant as a function of surface type applied to Jemis

Required input parameters:
~~~~~~~~~~~~~~~~~~~~~~~~~~

channels
  List of channel to which the observation error factor applies

obserr_dtempf
  Observation error scale factors applied to surface temperature jacobians
  over five surface types: [sea, land, ice, snow and mixed]

obserr_demisf
  Observation error scale factors applied to surface emissivity jacobians
  over five surface types: [sea, land, ice, snow and mixed]

Optional input parameters:
~~~~~~~~~~~~~~~~~~~~~~~~~~

test_obserr
  Name of the data group to which the observation error is applied (default is ObsErrorData)

test_qcflag
  Name of the data group to which the QC flag is applied  (default is QCflagsData)

Required fields from obs/geoval:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
geovals
  :code:`water_area_fraction@GeoVaLs`,
  :code:`land_area_fraction@GeoVaLs`,
  :code:`ice_area_fraction@GeoVaLs`,
  :code:`surface_snow_area_fraction@GeoVaLs`

obsDiag
  :code:`brightness_temperature_jacobian_surface_temperature@ObsDiag`,
  :code:`brightness_temperature_jacobian_surface_emissivity@ObsDiag`

In addition, brightness_temperature observation error and QC flags will come from
prior filters or from the input files defined by :code:`test_obserr` and :code:`test_qcflag`.

Example configurations:
~~~~~~~~~~~~~~~~~~~~~~~

Here is an example to use this obsFunction inside a fiter to inflate obs errors.

.. code-block:: yaml

  - filter: Perform Action
    filter variables:
    - name: brightness_temperature
      channels: *all_channels
    action:
      name: inflate error
      inflation variable:
        name: ObsErrorFactorSurfJacobianRad@ObsFunction
        channels: *all_channels
        options:
          channels: *all_channels
          obserr_demisf: [0.010, 0.020, 0.015, 0.020, 0.200]
          obserr_dtempf: [0.500, 2.000, 1.000, 2.000, 4.500]

