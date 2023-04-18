
.. _radfromscaledrad_v1:

=========================================
Converts from scaled radiance to radiance
=========================================

Performs a conversion of a scaled radiance to a spectral radiance.

:code:`Transform: SatRadianceFromScaledRadiance`

.. code-block:: yaml

    - filter: Variable Transforms
      Transform: SatRadianceFromScaledRadiance
      transform from:
        name: ObsValue/scaledRadiance
        channels: *all_channels
      number of scale factors: 10
      scale factor variable: MetaData/channelScaleFactor
      scale factor start: MetaData/startChannel
      scale factor end: MetaData/endChannel

**Parameters**

* :code:`transform from` is a required parameter and is of type :code:`ufo::Variable`.  This type requires a name and usually a list of
  channels.  The name will typically be :code:`ObsValue/scaledRadiance`.

Radiance scaling is done using scale factors for a range of channels. The following variables are required to specify
the scale factors and which channels they should be applied to.

* :code:`number of scale factors` is a required parameter and specifies how many scale factors need to be read in.
* :code:`scale factor variable` is a required parameter and of type :code:`ufo::Variable`.  This specifies the name of the array containing 
  the :math:`channelScaleFactor` values to be used with the equation in the method section below.
* :code:`scale factor start` is a required parameter and of type :code:`ufo::Variable`.  This specifies the name of the array containing the
  smallest channel number with which to use a given :math:`channelScaleFactor`.
* :code:`scale factor end` is a required parameter and of type :code:`ufo::Variable`.  This specifies the name of the array containing the
  largest channel number with which to use a given :math:`channelScaleFactor`.
* :code:`get scaling factors from multiple arrays` is a boolean with a default value of false. By default (false)
  the arrays associated with :code:`scale factor variable`, :code:`scale factor start` and :code:`scale factor end` values will 
  each be read from single arrays.  The array associated with :code:`scale factor variable` is of size :code:`number of scale factors`.
  If set to true the radiance scale factors are expected to be in separate arrays of size number of locations e.g.

  * :code:`number of scale factors: 3` then
  * MetaData/channelScaleFactor1, MetaData/channelScaleFactor2, MetaData/channelScaleFactor3
  * MetaData/startChannel1, MetaData/startChannel2, MetaData/startChannel3
  * MetaData/endChannel1, MetaData/endChannel2, MetaData/endChannel3

**Example with additional options**

This example shows all the options being used with the scaling factors being read in from single arrays. e.g. :code:`MetaData/channelScaleFactor(2)`.

.. code-block:: yaml

    - filter: Variable Transforms
      Transform: SatRadianceFromScaledRadiance
      transform from:
        name: ObsValue/scaledRadiance
        channels: *all_channels
      number of scale factors: 2
      scale factor variable: MetaData/channelScaleFactor
      scale factor start: MetaData/startChannel
      scale factor end: MetaData/endChannel

If the first two entries in :code:`MetaData/channelScaleFactor` are 7 and 9, in :code:`MetaData/startChannel` are 1 and 50 and in
:code:`MetaData/endChannel` are 49 and 100.  For channels 1 to 49 a scale factor of 7 will be used and for channels 50 to 100 a scale factor of 9
will be used.

This examples shows all the options being used with the scaling factors being read in from separate arrays.  Each array is of size, number of locations e.g. MetaData/channelScaleFactor1, MetaData/channelScaleFactor2, MetaData/channelScaleFactor3.  In this case the values associated
with location one will be read in.  This is because the scale factors are independent of location.

.. code-block:: yaml

    - filter: Variable Transforms
      Transform: SatRadianceFromScaledRadiance
      transform from:
        name: ObsValue/scaledRadiance
        channels: *all_channels
      number of scale factors: 3
      scale factor variable: MetaData/channelScaleFactor
      scale factor start: MetaData/startChannel
      scale factor end: MetaData/endChannel
      get scaling factors from multiple arrays: true

**Method**

The following calculation is performed by this variable transform:

.. math::

    L(\nu) = L_{scal}(\nu)10^{-channelScaleFactor}

where:
  - :math:`L(\nu)` is the spectral radiance at a given wavenumber.
  - :math:`L_{scal}(\nu)` is the scaled radiance at a given wavenumber.
  - :math:`channelScaleFactor` is the exponent.
