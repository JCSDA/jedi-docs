.. _CLWRetSymmetricMW:

CLWRetSymmetricMW
--------------------------

This function estimates the Cloud Liquid Water (CLW) content at the observation location from both the model background :math:`CLW_m` and the observation derived :math:`CLW_o`. :math:`CLW` is used in radiance assimilation as an indication of the presence of cloud.

The estimate is the mean of the model and observed content: :math:`CLW_{sym} = 0.5 * (CLW_m + CLW_o)`.

The mean is used so that the :math:`CLW` is a symmetric function of :math:`CLW_o` and :math:`CLW_m`. Since the observation error for radiances is inflated 
in presence of cloud, as indicated by :math:`CLW`, the symmetrical dependence on the model and observations better deals with situations when :math:`CLW_m` and  :math:`CLW_o` are very different.  


References
^^^^^^^^^^^^^^^^^^^^^^^^^

Geer A. J. and P Bauer, 2010: Enhanced use of all-sky microwave observations sensitive to water vapour, cloud and precipitation. ECMWF Technical Memoranda 620. http://dx.doi.org/10.21957/mi79jebka

Geer A. J. and P Bauer, 2011: Observation errors in all-sky data assimilation. 
https://doi.org/10.1002/qj.830


Required yaml parameters
^^^^^^^^^^^^^^^^^^^^^^^^^

Requires CLWRetMW inputs, and clwret_types of ObsValue (observations) TBs, and simulated bias-corrected TBs GsiHofXBc.

Returns clw_symmetric_amount.

Example configuration
~~~~~~~~~~~~~~~~~~~~~

AMSU-A Example (function_clwretmean.yaml), see "obs function" section below:

.. code-block:: yaml

  observations:
  - obs space:
      name: amsua_n19
      obsdatain:
        obsfile: Data/ufo/testinput_tier_1/amsua_n19_obs_2018041500_m_qc.nc4
      simulated variables: [brightness_temperature]
      channels: 1, 2
    geovals:
      filename: Data/ufo/testinput_tier_1/amsua_n19_geoval_2018041500_m_qc.nc4
    obs function:
      name: CLWRetSymmetricMW@ObsFunction
      options:
        clwret_ch238: 1
        clwret_ch314: 2
        clwret_types: [ObsValue, GsiHofXBc]
      variables: [clw_symmetric_amount]
      tolerance: 1.0e-8

