.. _top-vader-recipe-totalmixingratioa:

Total water mixing ratio wrt dry air from individual mixing ratios wrt dry air
==============================================================================

* **Description**: Produces total water mixing ratio wrt dry air from other individual mixing ratios wrt dry air
* **Name**: TotalMixingRatio_A
* **Variable produced**: m_t (total_water_mixing_ratio_wrt_dry_air)
* **Input Variables**: m_cl (cloud_liquid_water_mixing_ratio_wrt_dry_air), m_ci (cloud_ice_mixing_ratio_wrt_dry_air), m_v (water_vapor_mixing_ratio_wrt_dry_air), m_r (rain_mixing_ratio_wrt_dry_air)
* **Number of Levels** - The same number of levels as the input m_v Field
* **FunctionSpace** - The same FunctionSpace as the input m_v Field
* **hasTLAD** - True
* **Optional Parameters**: None
