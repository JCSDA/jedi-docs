.. _CLWRetMW_SSMIS:

CLWRetMW_SSMIS
============================================

Using channels 12-18 of SSMIS satellite brightness temperatures, retrieve cloud liquid water as
described by the references listed below.  This follows a similar routine in GSI Observer.

References:
^^^^^^^^^^^^^^^^^^^^^^^^^

 Weng, F., R. R. Ferraro, and N. C. Grody, 1999: Effects of AMSU-A cross track asymmetry of brightness temperatures on retrieval of atmospheric and surface parameters. Microwave Radiometry and Remote Sensing of the Earth's Surface and Atmosphere, edited by P. Pampaloni, and S. Paloscia, pp. 255–262, VSP Int. Sci., Leiden, Netherlands.

 Yan, B. and F. Weng, 2008: Intercalibration Between Special Sensor Microwave Imager/Sounder and Special Sensor Microwave Imager. IEEE Transactions on Geoscience and Remote Sensing, vol. 46, no. 4, pp. 984-995 doi: 10.1109/TGRS.2008.915752.

Required yaml parameters:
^^^^^^^^^^^^^^^^^^^^^^^^^

ch19h
  channel number of brightness temperature from 19GHz **horizontal** polarized channel

ch19v
  channel number of brightness temperature from 19GHz **vertical** polarized channel

ch22v
  channel number of brightness temperature from 22GHz **vertical** polarized channel

ch37h
  channel number of brightness temperature from 37GHz **horizontal** polarized channel

ch37v
  channel number of brightness temperature from 37GHz **vertical** polarized channel

ch91v
  channel number of brightness temperature from 91GHz **vertical** polarized channel

ch91h
  channel number of brightness temperature from 91GHz **horizontal** polarized channel

Example configuration:
^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: yaml

   - filter: Bounds Check
     filter variables:
     - name: brightness_temperature
       channels: 12-18
     test variables:
     - name: CLWRetMW_SSMIS@ObsFunction
       options:
         satellite: SSMIS
         ch19h: 12
         ch19v: 13
         ch22v: 14
         ch37h: 15
         ch37v: 16
         ch91v: 17
         ch91h: 18
         varGroup: ObsValue
     minvalue: 0.0
     maxvalue: 2.0

In this example, any retrieved cloud liquid water value less than zero or greater than 2
will cause the observation to be rejected.
