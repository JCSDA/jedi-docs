
.. _btfromrad_v1:

==========================================
Convert radiance to brightness temperature
==========================================
The observed values in the level 1 satellite data products are sometimes in spectral radiance values.  This
variable transform allows for the values to be converted into brightness temperatures
using an input spectral radiance and a choice of frequency, wavenumber or wavelength.

:code:`Transform: SatBrightnessTempFromRad`

.. code-block:: yaml

    - filter: Variable Transforms
      Transform: SatBrightnessTempFromRad
      transform from:
        name: ObsValue/radiance
        channels: 1-22
      spectral variable:
        name: MetaData/wavenumber
        channels: 1-22
      radiance units: wavenumber

**Parameters**

* :code:`transform from` is a required parameter and is of type :code:`ufo::Variable`.  This type requires a name and usually a list of channels.
* :code:`spectral variable` is a required parameter and is of type :code:`ufo::Variable`.  This type requires a name and usually a list of channels.
* :code:`radiance units` is a required parameter and takes a string variable which must be :code:`wavenumber`, :code:`wavelength` or :code:`frequency`.  In ufo, wavenumbers are in :math:`m^{-1}`, wavelengths are in :math:`\mu m` and frequencies are in Hz.
* :code:`minimum value` is an optional parameter and specifies the minimum tolerable output value.  Any values below this are filled with the missing value indicator.
* :code:`maximum value` is an optional parameter and specifies the maximum tolerable output value.  Any values above this are filled with the missing value indicator.
* :code:`planck1` is a parameter which species the value of of the first planck constant, :math:`c_1` in the formula below.  The default value is 1.191042972e-16. This option is only included to allow backwards compatibility and is not recommended to use.
* :code:`planck2` is a parameter which species the value of of the second planck constant, :math:`c_2` in the formula below.  The default value is 1.4387769e-2.  This option is only included to allow backwards compatibility and is not recommended to use.

**Examples with additional options**

The below yaml extract shows how all the filter options can be used:

.. code-block:: yaml

    - filter: Variable Transforms
      Transform: SatBrightnessTempFromRad
      transform from:
        name: ObsValue/radiance
        channels: 1-22
      spectral variable:
        name: MetaData/frequency
        channels: 1-22
      radiance units: frequency
      minimum value: 150.0
      maximum value: 350.0
      planck1: 1.191042953e-16
      planck2: 1.4387774e-2

**Method**

The brightness temperature at a given wavenumber (:math:`T_b(\nu)`) is derived using the inverse planck formula with the formulation below:

.. math::

    T_b(\nu)=\frac{c_2 \nu}{ln(1+\frac{c_1 \nu^3}{I_\nu})}

where:
    * :math:`c_1` is a pre-computed constant (:math:`2hc^2 = 1.191042972\times10^{-16}` :math:`W / (m^2 sr m^{-4})`)
    * :math:`c_2` is a pre-computed constant (:math:`hc/k = 1.4387769\times10^{-2}` :math:`m K`)
    * :math:`\nu` is the wavenumber in :math:`m^{-1}`
    * :math:`I(\nu)` is the radiance.

As shown in the parameters above, there is also the option to provide values for :math:`c_1` and :math:`c_2`. This is to allow backwards compatibility with the values in RTTOV which have rounding errors.
