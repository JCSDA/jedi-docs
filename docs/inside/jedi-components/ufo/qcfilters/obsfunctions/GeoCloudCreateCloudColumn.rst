.. _GeoCloudCreateCloudColumn:

GeoCloudCreateCloudColumn
=========================

This ObsFunction is used to populate the cloud fraction on model levels observation product known as GeoCloud, which is derived from satellite-based radiance observations.
GeoCloud can process both cloudy and clear scenes, handled separately within the code.
For cloudy scenes there must be an estimation of the cloud-top pressure and cloud fraction in the ObsSpace, usually from a prior 1D-Var analysis, or from the "stable layers" ObsFunction.

The basic functionality of GeoCloud is that the model level closest to the provided cloud-top pressure is determined to be the location of the cloud top, on which level the provided cloud fraction is placed.
Then, above the cloud top a cloud fraction of 0.0 is placed on all model levels up to a given altitude limit, above which model levels are assigned a missing value.
Below the cloud top, levels are assigned the missing value.
There is also the possibility of extending the cloud thickness over multiple model levels below the cloud top, replacing the missing values to a certain depth, using one of two methods described in more detail below.
For clear scenes, a cloud fraction of 0.0 is placed on all model levels from the level closest to the surface + 1 up to the provided altitude limit.
For both cloudy and clear scenes, the model level closest to the surface is always assigned a value of missing.

This cloud-fraction column is then output into the ObsSpace via the usual method.
Also output into the ObsSpace directly is a cloud-fraction error column, constructed within the code at the same time as the main output is determined.
For clear model levels, this error is taken directly from a Parameter input (multiplied by a Parameter input factor :math:`M` which can be used to inflate or deflate all errors).
For levels with cloud, the following formula is used:

:math:`E_{\mathrm{cloud}} = (E_{\mathrm{clear}} (1 - C_f) + E_{\mathrm{overcast}} C_f) M`

Where:
 * :math:`E_{\mathrm{cloud}}` is the error for the cloudy level
 * :math:`E_{\mathrm{clear}}` is error input Parameter defined by ``error for cloudy scene clear levels``
 * :math:`E_{\mathrm{overcast}}` is error input Parameter defined by ``error for cloudy levels``
 * :math:`C_f` is the cloud fraction at the cloud-top model level
 * :math:`M` is the observation error multiplication factor, used to inflate or deflate the overall error

To deepen the cloud, two options are available.
The primary method uses a provided value of cloud optical thickness (COT) to derive a geometrical thickness, which is then converted to a number of model levels on which cloud should be placed.
If no cloud optical thickness is available, or if none is provided, a fall-back option can be used to define a cloud depth for each model level, which simply acts as a cross reference for the determined cloud-top level.
For practical applications this determination of cloud depth through the atmosphere should come from an analysis of the climatology of the region for which the GeoCloud scene is being created.
By default no deepening of cloud is performed.


Required Parameters
^^^^^^^^^^^^^^^^^^^

:code:`cloud top pressure` - Cloud-top pressure in Pa, which usually would be calculated by a prior call to the :code:`RTTOV OneDVar Check` filter or Stable Layers calculation ObsFunction :code:`StableLayersCloudTopPressure`.

:code:`cloud amount` - Cloud fraction between 0.0 and 1.0, which usually would be calculated by a prior call to the :code:`RTTOV OneDVar Check` filter or Stable Layers calculation ObsFunction :code:`StableLayersCloudTopPressure`.

:code:`cloud optical thickness` - Scaled cloud optical thickness (COT) which should be provided by prior calculation.

:code:`spatial coherence test` - Cloud mask. Contains values of 0, 1 (cloudy) or 2 (clear) and is used to distinguish whether to treat the column as cloudy or clear.

:code:`channels` - List of "channels" (really model levels) which the cloud column should be placed on.

Parameters
^^^^^^^^^^

:code:`error for cloudy scene clear levels` - For cloudy scenes, error to be put on cloudless levels above the cloud top. Default = 0.6.

:code:`error for cloudy levels` - For cloudy scenes, error value to be used in calculation of error to put on cloudy levels at cloud top level. Also applied to further levels below cloud top when cloud depth is more than one level. Default = 0.4.

:code:`error for clear scenes` - For clear scenes, error to be put on all cloudless levels. Default = 0.6.

:code:`observation error multiplier` - Multiplication factor for cloudy and clear level errors, which can be used to inflate or deflate error values. Default = 1.0.

:code:`clear altitude limit` - Altitude limit for clear scenes in Pa. Model levels with pressure below this value have cloud fraction set to missing. Default = 10000.0 Pa.

:code:`cloudy altitude limit` - Altitude limit for cloudy scenes in Pa. Model levels with pressure below this value have cloud fraction set to missing. Default = 50000.0 Pa.

:code:`use cloud optical thickness` - Boolean for using cloud optical thickness (COT) to calculate cloud thickness and number of model levels to apply cloud fracction to. Default = ``false``.

:code:`tau denominator` - Denominator in the scaling of input cloud optical thickness value back to true value, :math:`\tau`. Default = 1.0 (no scaling).

:code:`tau offset` - Offset in scaling of input cloud optical thickness value back to true value, :math:`\tau`. Default = 0.0 (no scaling).

:code:`maximum zdepth layers` - Maximum number of vertical layers having coefficients available for calculating cloud geometric thickness from cloud optical thickness, if :code:`use cloud optical thickness = true`. Default = 1.

:code:`tau lower height limit array` - Lower limit of height range array for calculation of tau. Should have a number of elements equal to :code:`maximum zdepth layers` and will fail if it does not. Must be assigned if :code:`use cloud optical thickness = true`. Note: Ordering of tau arrays is contrary to JEDI convention, with the first element being the band closest to the surface. Final value should be negative to tell the code to stop looking for tau range.

:code:`tau upper height limit array` - Upper limit of height range array for calculation of tau. Should have a number of elements equal to :code:`maximum zdepth layers` and will fail if it does not. Must be assigned if :code:`use cloud optical thickness = true`. Note: Ordering of tau arrays is contrary to JEDI convention, with the first element being the band closest to the surface.

:code:`tau gradient array` - Gradient of linear functional fit between log_e(COT) and cloud depth, to be used when COT is available for a particular cloud-top observation. Should have a number of elements equal to :code:`maximum zdepth layers` and will fail if it does not. Must be assigned if :code:`use cloud optical thickness = true`. Note: Ordering of tau arrays is contrary to JEDI convention, with the first element being the band closest to the surface.

:code:`tau constant array` - Constant of linear functional fit between log_e(COT) and cloud depth, to be used when COT is available for a particular cloud-top observation. Should have a number of elements equal to :code:`maximum zdepth layers` and will fail if it does not. Must be assigned if :code:`use cloud optical thickness = true`. Note: Ordering of tau arrays is contrary to JEDI convention, with the first element being the band closest to the surface.

:code:`tau maximum depth array` - Maximum geometric layer thickness in which model levels can be assigned non-zero cloud values when a COT is available for a particular cloud-top observation. Should have a number of elements equal to :code:`maximum zdepth layers` and will fail if it does not. Must be assigned if :code:`use cloud optical thickness = true`. Note: Ordering of tau arrays is contrary to JEDI convention, with the first element being the band closest to the surface.

:code:`ndepth array` - Number of model levels below cloud top to be assigned non-missing values for a given cloud-top observation. Provided array should have number of elements equal to the number of model levels and will fail if it does not. Default is an array length 1 with a value of 0.

:code:`output group` - This is an option to change the ObsSpace name of the group for the error column. By default it is ``DerivedObsError``.

Output
^^^^^^

:code:`DerivedObsValue/cloudAmount` - ObsSpace variable name for the GeoCloud cloud-fraction column on model levels. Variable name and group name can be changed by the user in the ``Variable Assignment`` filter.

:code:`DerivedObsError/cloudAmount` - ObsSpace variable name for the cloud-fraction error column. Group name can be changed by the user with the ``output group`` input option. Variable name (``cloudAmount``) is fixed.

Example 1
^^^^^^^^^
This example uses all options to construct a cloud column for a 70 level GeoCloud observation into an ObsSpace variable ``DerivedObsValue/cloudAmount``. 
By default, the primary method for calculating cloud depth is to use cloud optical thickness, however here the :code:`ndepth array` is also provided for any circumstances when cloud optical thickness is not available.
In this example, the :code:`RTTOV OneDVar Check` filter should have been run beforehand to provide values of ``OneDVar/pressureAtTopOfCloud`` and ``OneDVar/cloudAmount``.
Cloud optical thickness (``MetaData/cloudOpticalThickness``) and spatial coherence flag (``MetaData/autosat_spatial_test``) are expected to be available in the ObsSpace, read in from input ODB via ioda.

.. code-block:: yaml

  - filter: Variable Assignment
    assignments:
    - name: DerivedObsValue/cloudAmount
      channels: 1-70
      type: float
      function:
        name: ObsFunction/GeoCloudCreateCloudColumn
        options:
          cloud top pressure: OneDVar/pressureAtTopOfCloud
          cloud amount: OneDVar/cloudAmount
          cloud optical thickness: MetaData/cloudOpticalThickness
          spatial coherence test: MetaData/autosat_spatial_test
          channels: 1-70
          error for cloudy scene clear levels: 0.3
          error for cloudy levels: 0.1
          error for clear scenes: 0.5
          clear altitude limit: 40000.0
          cloudy altitude limit: 40000.0
          tau denominator: 5.0
          tau offset: -5.0
          ndepth array: [1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 2, 2, 2, 2, 2, 2, 2, 2, 1, 1, 1, 1, 0]
          maximum zdepth layers: 24
          use cloud optical thickness: true
          tau lower height limit array: [25.0, 50.0, 75.0, 100.0, 150.0, 200.0, 250.0, 375.0, 450.0, 600.0, 750.0, 1000.0, 1300.0, 1500.0, 2000.0, 2500.0, 3000.0, 3500.0, 4500.0, 5000.0, 6000.0, 8500.0, 9000.0, -999.99]
          tau upper height limit array: [50.0, 75.0, 100.0, 150.0, 200.0, 250.0, 375.0, 450.0, 600.0, 750.0, 1000.0, 1300.0, 1500.0, 2000.0, 2500.0, 3000.0, 3500.0, 4500.0, 5000.0, 6000.0, 8500.0, 9000.0, 12000.0, -999.99]
          tau gradient array: [250.0, 260.0, 265.0, 180.0, 300.0, 180.0, 200.0, 175.0, 175.0, 250.0, 275.0, 350.0, 575.0, 875.0, 850.0, 2000.0, 2250.0, 1500.0, 2500.0, 7.5e+06, 6.5e+06, 7.5e+06, 5.0e+06, 0.0]
          tau constant array: [-450.0, -475.0, -475.0, -300.0, -600.0, -250.0, -275.0, -150.0, -100.0, -200.0, -250.0, -350.0, -650.0, -1000.0, -900.0, -2250.0, -2500.0, -1000.0, -1500.0, -6.5e+06, -6.0e+06, -4.0e+06, -2.0e+06, 1.0]
          tau maximum depth array: [45.0, 70.0, 100.0, 150.0, 200.0, 225.0, 300.0, 350.0, 400.0, 450.0,  550.0, 600.0, 650.0, 750.0, 800.0, 900.0, 950.0, 1000.0, 1250.0, 1250.0, 1000.0, 1500.0, 1000.0, 0.0]

Example 2
^^^^^^^^^
This example uses only the fixed n-depth per model level option for assigning cloud depth into ObsSpace variable ``DerivedObsValue/cloudAmount``.
Other constants (error values and altitude limits) are set to the same values as in Example 1.

.. code-block:: yaml

  - filter: Variable Assignment
    assignments:
    - name: DerivedObsValue/cloudAmount
      channels: 1-70
      type: float
      function:
        name: ObsFunction/GeoCloudCreateCloudColumn
        options:
          cloud top pressure: OneDVar/pressureAtTopOfCloud
          cloud amount: OneDVar/cloudAmount
          cloud optical thickness: MetaData/cloudOpticalThickness
          spatial coherence test: MetaData/autosat_spatial_test
          channels: 1-70
          error for cloudy scene clear levels: 0.3
          error for cloudy levels: 0.1
          error for clear scenes: 0.5
          clear altitude limit: 40000.0
          cloudy altitude limit: 40000.0
          ndepth array: [1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 2, 2, 2, 2, 2, 2, 2, 2, 1, 1, 1, 1, 0]
