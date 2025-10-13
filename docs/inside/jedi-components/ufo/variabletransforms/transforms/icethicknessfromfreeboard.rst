.. _VT-Cal_IceThicknessFromIceFreeboard:

===========================================
Calculate iceThickness from seaIceFreeboard
===========================================

Calculate ice thickness from ice freeboard, ice depth, and the densities of the snow, ice, and surface water.

This will return ice thickness in a variable named (by default) `DerivedObsValue/iceThickness`. The derived error standard deviations are combined in quadrature into the variables observation error data, as well as the constituent random and systematic components going into `RandomErrorStandardDeviation/iceThickness` and `SystematicErrorStandardDeviation/iceThickness` respectively. 

--------------
Variables used
--------------

- ice freeboard :math:`f` (:math:`m`)
- water density :math:`\rho_w` (:math:`kg/m^3`)
- snow density :math:`\rho_s` (:math:`kg/m^3`)
- ice density :math:`\rho_i` (:math:`kg/m^3`)
- snow depth :math:`d` (:math:`m`)
- instrument-sourced random error standard deviation of ice density measurements :math:`\sigma_{\rho_{i}}` (:math:`kg/m^3`)
- instrument-sourced random error standard deviation of ice freeboard measurements :math:`\sigma_f` (:math:`m`)
- instrument-sourced systematic error standard deviation of snow density measurements :math:`\sigma_{\rho_{s}}` (:math:`kg/m^3`)
- instrument-sourced systematic error standard deviation of snow depth measurements :math:`\sigma_d` (:math:`m`)

----------------
Output Variables
----------------


- calculated random error standard deviation of the derived ice thickness :math:`\sigma_{tR}` (:math:`m`)
- calculated systematic error standard deviation of the derived ice thickness :math:`\sigma_{tS}` (:math:`m`)
- ice thickness :math:`t` (:math:`m`)

----------
Parameters
----------

Inputs:

- ``ice freeboard variable``: Sea ice protruding above the water surface level variable (default ``ObsValue/seaIceFreeboard``)
- ``ice density variable``: Density of the ice variable (default ``ObsValue/iceDensity``)
- ``snow depth variable``: Depth of the snow on top of the ice variable (default ``ObsValue/totalSnowDepth``)
- ``snow density variable``: Density of the snow on top of the ice variable (default ``ObsValue/snowDensity``)
- ``sea water density variable``: Density of the sea water below the ice variable (default ``ObsValue/seaWaterDensity``)

Inputs if calculating error:

- ``calculate error standard deviations``: (default ``true``)
- ``ice freeboard error standard deviation variable``: (default ``ObservedErrorStandardDeviation/seaIceFreeboard``)
- ``ice density error standard deviation variable``: (default ``ObservedErrorStandardDeviation/iceDensity``)
- ``snow depth error standard deviation variable``: (default ``ObservedErrorStandardDeviation/snowDepth``)
- ``snow density error standard deviation variable``: (default ``ObservedErrorStandardDeviation/snowDensity``)

Outputs:

- ``ice thickness variable``: Thickness of the sea ice including both above and below the water surface level variable (default ``DerivedObsValue/iceThickness``)
- ``ice thickness systematic error standard deviation variable``: (default ``SystematicErrorStandardDeviation/iceThickness``)
- ``ice thickness random error standard deviation variable``: (default ``RandomErrorStandardDeviation/iceThickness``)

------------------
Example yaml block
------------------

.. code-block:: yaml

  obs filters:
  - filter: Variable Transforms
    Transform: Calculate iceThickness from seaIceFreeboard
    ice freeboard variable: ObsValue/seaIceFreeboard
    sea water density variable: ObsValue/seaWaterDensity
    snow depth variable: ObsValue/totalSnowDepth
    snow density variable: ObsValue/snowDensity
    ice density variable: ObsValue/iceDensity
    ice freeboard error standard deviation variable: \
        ObservedErrorStandardDeviation/seaIceFreeboard
    ice density error standard deviation variable: \
        ObservedErrorStandardDeviation/iceDensity
    ice thickness variable: iceThickness
    ice thickness systematic error standard deviation variable: \
        SystematicStandardDeviation/iceThickness
    ice thickness random error standard deviation variable: \
        RandomStandardDeviation/iceThickness

------
Method
------

The ice thickness is calculated using the formula from (`Ricker et al. 2014 <https://tc.copernicus.org/articles/8/1607/2014/tc-8-1607-2014.html>`__). In that paper they refer to the ice freeboard as the radar freeboard, this is because they assume these two quantities are equal. We maintain the distinction to allow us flexibility when calculating the ice freeboard from the radar freeboard.

.. math::
  t = \frac{f \rho_{w} + d \rho_{s}}  {\rho_{w} - \rho_{i}}

The filter will also (optionally) propagate the uncertainties through Gaussian error propagation to give the random error standard deviation on the thickness, assuming the ice freeboard and ice density uncertainties are random and uncorrelated:

.. math::
  \sigma_{tR}^2 &= \sigma_{f}^{2} \left( \frac{\partial t}{\partial f} \right)^{2} + \sigma_{\rho_{i}}^{2} \left( \frac{\partial t}{\partial \rho_{i}} \right)^{2}
  
  \sigma_{tR} &= \sqrt{
    \left( \sigma_{f} \frac{\rho_{w}}{\rho_{w} - \rho_{i}} \right)^{2} +
    \left( \sigma_{\rho_{i}} \frac{f \rho_{w} + d \rho_{s}} {\left(\rho_{w} - \rho_{i}\right)^{2}} \right)^{2}
  }

The filter will also optionally give the systematic error, assuming that the errors on snow depth and snow density are systematic:

.. math::
  \sigma_{tS}^2 &= \sigma_{d}^{2} \left( \frac{\partial t}{\partial d} \right)^{2} +
                             \sigma_{\rho_{s}}^{2} \left( \frac{\partial t}{\partial \rho_{s}} \right)^{2}
  
  \sigma_{tS} &= \sqrt{
    \left( \sigma_{d}  \frac{\rho_{s}} {\rho_{w} - \rho_{i}} \right)^{2} +
    \left( \sigma_{\rho_{s}} \frac{d} {\rho_{w} - \rho_{i}} \right)^{2}
    }

