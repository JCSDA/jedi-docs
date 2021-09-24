.. _CLWRetMW:

CLWRetMW
--------------------------------------------------------

Retrieve cloud liquid water using 23.8 GHz and 31.4 GHz channels from AMSU-like instruments.
Follows the Grody et al., 2001 screening method, see publication or source code for specific implementation

References:
^^^^^^^^^^^^^^^^^^^^^^^^^

Grody et al. (2001), Determination of precipitable water and cloud liquid water over oceans from the NOAA 15 advanced microwave sounding unit, Journal of Geophysical Research (Vol. 106, No. D3, Pages 2943-2953).


Required yaml parameters:
^^^^^^^^^^^^^^^^^^^^^^^^^

Channel numbers corresponding to 23.8 GHz to which the retrieval of cloud liquid water applies.

:code:`clwret_ch238`
  Channel number of brightness temperature from the 23.8 GHz Brightness Temperature.

:code:`clwret_ch314`
  Channel number of brightness temperature from the 31.4 GHz Brightness Temperature.

Example configuration:
~~~~~~~~~~~~~~~~~~~~~~~~

AMSU-A Example (amsua_qc_clwretmw.yaml):
  
.. code-block:: yaml

  - filter: Bounds Check
    filter variables:
    - name: brightness_temperature
      channels: 1-6, 15
    test variables:
    - name: CLWRetMW@ObsFunction
      options:
        clwret_ch238: 1
        clwret_ch314: 2
        clwret_types: [ObsValue]
        test_group: GsiObsBias
    maxvalue: 999.0
    action:
      name: reject

