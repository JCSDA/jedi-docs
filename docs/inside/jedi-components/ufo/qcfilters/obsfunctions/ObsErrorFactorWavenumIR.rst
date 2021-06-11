.. _ObsErrorFactorWavenumIR:

ObsErrorFactorWavenumIR
======================================================================================

This obsfunction inflates observation error for infrared sensors
as a function of wavenumber,solar zenith angle and surface type for Infrared sensors.
Users do not need to specify any inflation factors. Instead the inflation factors are
coded as a function of wavenumber number, surface-to-space transmittance, solar zenith
angle, and surface type.


* Error Inflation Factor (EIF) for channels with wavenumber in the range of (2000, 2400] during daytime (sun zenith angle < 89) and containing water fraction in the field-of-view
* x = wavenumber [1/cm]
* y = surface-to-space transmittance
* z = solar zenith angle [radian]
* :math:`EIF = \sqrt{ 1 / ( 1 - (x - 2000)) * y * \max(0, \cos(z)) / 4000 }`

Example:
--------

.. code-block:: yaml

  - filter: BlackList
    filter variables:
    - name: brightness_temperature
      channels: *all_channels
    action:
      name: inflate error
      inflation variable:
        name: ObsErrorFactorWavenumIR@ObsFunction
        channels: *all_channels
        options:
          channels: *all_channels
