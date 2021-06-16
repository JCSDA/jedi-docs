.. _SCATRetMW:

SCATRetMW
==============

Retrieve Grody et al. scattering index from bias-adjusted 23.8 GHz, 31.4 GHz and 89 GHz channels over water surfaces only.

Required input parameters:
~~~~~~~~~~~~~~~~~~~~~~~~~~

scatret_ch238
  Channel number corresponding to 23.8 GHz to which the retrieval
  of scattering index applies:

scatret_ch314
  Channel number corresponding to 31.4 GHz to which the retrieval
  of scattering index applies

scatret_890
  Channel number corresponding to 89 GHz to which the retrieval
  of scattering index applies

scatret_types
  Names of the data group used to retrieve the scattering index.

bias_application
  Name of the data group to which the bias correction is applied (default is HofX).

test_bias
  Name of the bias correction group used to replace the default group (default is ObsBias)
   
Consts:

Bad value:
  bad_scatret_value = 1000.0f

Formula from SCATRetMW.cc:
  :math:`SI = -113.2 + (2.41 - 0.0049 * bt_{ch238}) * bt_{ch238} + 0.454 * bt_{ch314} - bt_{ch890}`
   
Restrictions:

* water_frac[iloc] >= 0.99

Note:
  output value is 0 or greater.

References
^^^^^^^^^^^^^^^^^^^^^^^^^

Grody et al. (2000), Application of AMSU for obtaining hydrological parameters, Microw. Radiomet. Remote Sens. Eatch's Surf. Atmosphere, pp. 339-351

Required yaml parameters
^^^^^^^^^^^^^^^^^^^^^^^^^

ATMS Example (atms_qc_filters.yaml):

.. code-block:: yaml

  scatobs_function:
    name: SCATRetMW@ObsFunction
    options:
      scatret_ch238: 1
      scatret_ch314: 2
      scatret_ch890: 16
      scatret_types: [ObsValue]

      
AMSUA Example (amsua_qc_filters.yaml):

.. code-block:: yaml

  scatobs_function:
    name: SCATRetMW@ObsFunction
    options:
      scatret_ch238: 1
      scatret_ch314: 2
      scatret_ch890: 15
      scatret_types: [ObsValue]
      bias_application: HofX

