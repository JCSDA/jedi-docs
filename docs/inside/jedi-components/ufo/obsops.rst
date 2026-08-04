.. _top-ufo-obsops:

Observation Operators in UFO
=============================

Introduction
------------

There are four meta-operators which, when selected, run other operators and manipulate their output:

* :ref:`Categorical <obsops_categorical>`,

* :ref:`Composite <obsops_composite>`,

* :ref:`Density reduction <obsops_densred>`

* Time interpolation (documentation to be added).

.. _obsops_categorical:

Categorical
-----------

Description
^^^^^^^^^^^

The Categorical meta-operator can be used to run several observation operators, each of which produces a vector of H(x) values.
The Categorical operator then creates a final H(x) vector by selecting the observation operator at each location according to a categorical variable.

Configuration options
^^^^^^^^^^^^^^^^^^^^^

* :code:`categorical variable`: the name of the variable that is used to determine which observation operator is selected at each location.
  This must be an integer or string variable in the MetaData group.

* :code:`categorised operators`: a map between values of the categorical variable and the operator to be selected.

* :code:`fallback operator`: the name of the observation operator that will be used whenever a particular value of the categorical variable does not exist in :code:`categorised operators`.

* :code:`operator configurations`: the configuration of all observation operators whose output will be used to produce the final H(x) vector.
  If either the fallback operator or one of the categorised operators have not been configured, an exception will be thrown.

* :code:`operator labels`: This option must be used if there are at least two component operators of the same type.
  The labels are associated with each component operator and can subsequently be used to differentiate between them.
  The ordering of labels in this list must correspond to the ordering of operators in the :code:`operator configurations` parameter.
  Every component operator (even if it is not duplicated) must be assigned a unique label.

Example 1
^^^^^^^^^

In this example the Categorical operator uses :code:`MetaData/stationIdentification` as the categorical variable.
Both the :ref:`Identity <obsops_identity>` and :ref:`Composite <obsops_composite>` operators are used to produce H(x) vectors.
Then, at each location in the ObsSpace, if :code:`MetaData/stationIdentification` is equal to 54857 then the Identity H(x) is selected.
Otherwise, the H(x) produced by the fallback operator (i.e. Composite) is selected.

.. code-block:: yaml

 obs operator:
   name: Categorical
   categorical variable: stationIdentification
   fallback operator: "Composite"
   categorised operators: {"54857": "Identity"}
   operator configurations:
   - name: Identity
   - name: Composite
     components:
      - name: Identity
        variables:
        - name: airTemperature
        - name: stationPressure
      - name: VertInterp
        variables:
        - name: windNorthward
        - name: windEastward

Example 2
^^^^^^^^^

In this example the Categorical operator uses :code:`MetaData/stationIdentification` as the categorical variable and has two
:code:`Composite` operators and an :code:`Identity` operator. The fact that two operators are the same necessitates the use of the
:code:`operator labels` section. The first :code:`Composite` operator is labelled :code:`Composite1`, and the second is labelled
:code:`Composite2`. Note that the :code:`Identity` operator must also be labelled. There must be as many labels as there are operator
configurations and the contents of the two sections must appear in the same order.

At each location in the ObsSpace, if :code:`MetaData/stationIdentification` is equal to 47418 or 54857 then the H(x) produced by :code:`Composite1` is used,
and if :code:`MetaData/stationIdentification` is equal to 94332 or 96935 then the H(x) produced by :code:`Composite2` is used.
Otherwise, the H(x) produced by the fallback operator (i.e. :code:`Identity`) is selected.

.. code-block:: yaml

  obs operator:
    name: Categorical
    categorical variable: stationIdentification
    fallback operator: "Identity"
    categorised operators: {"47418": "Composite1",
    "54857": "Composite1",
    "94332": "Composite2",
    "96935": "Composite2"}
    operator labels: ["Identity", "Composite1", "Composite2"]
    operator configurations:
    - name: Identity
    - name: Composite
      components:
       - name: Identity
         variables:
         - name: airTemperature
       - name: VertInterp
         variables:
         - name: windNorthward
         - name: windEastward
    - name: Composite
      components:
       - name: Identity
         variables:
         - name: airTemperature
       - name: VertInterp
         variables:
         - name: windNorthward
         - name: windEastward

.. _obsops_composite:

Composite
---------

Description
^^^^^^^^^^^

This meta-operator wraps a collection of observation operators, each used to simulate a different
subset of variables from the ObsSpace. Example applications of this operator are discussed below.

.. warning::

  At present, many observation operators implicitly assume they need to simulate all variables from
  the ObsSpace. Such operators cannot be used as components of the `Composite` operator. Operators
  compatible with the `Composite` operator are marked as such in their documentation.

Configuration options
^^^^^^^^^^^^^^^^^^^^^

* :code:`components`: a list of one or more items, each configuring the observation operator to be
  applied to a specified subset of variables.

Example 1
^^^^^^^^^

The YAML snippet below shows how to use the :ref:`VertInterp <obsops_vertinterp>` operator to simulate upper-air variables
from the ObsSpace and the :ref:`Identity <obsops_identity>` operator to simulate surface variables. Note that the
variables to be simulated by both these operators can be specified using the :code:`variables`
option; if this option is not present, all variables in the ObsSpace are simulated.

.. code-block:: yaml

  obs space:
    name: Radiosonde
    obsdatain:
      engine:
        type: H5File
        obsfile: Data/ioda/testinput_tier_1/sondes_obs_2018041500_s.nc4
    simulated variables: [windEastward, windNorthward, stationPressure, relativeHumidity]
  obs operator:
    name: Composite
    components:
    - name: VertInterp
      variables:
      - name: relativeHumidity
      - name: windEastward
      - name: windNorthward
    - name: Identity
      variables:
      - name: stationPressure

Example 2
^^^^^^^^^

The YAML snippet below shows how to handle a model with a staggered grid, with wind components
defined on different model levels than the air temperature. The :code:`vertical coordinate` option
of the :code:`VertInterp` operator indicates the GeoVaL containing the levels to use for the
vertical interpolation of the variables simulated by this operator.

.. code-block:: yaml

  obs space:
    name: Radiosonde with staggered vertical levels
    obsdatain:
      engine:
        type: H5File
        obsfile: Data/ufo/testinput_tier_1/met_office_composite_operator_sonde_obs.nc4
    simulated variables: [windEastward, windNorthward, airTemperature]
  obs operator:
    name: Composite
    components:
    - name: VertInterp
      variables:
      - name: airTemperature
      vertical coordinate: air_pressure
      observation vertical coordinate: pressure
    - name: VertInterp
      variables:
      - name: windNorthward
      - name: windEastward
      vertical coordinate: air_pressure_levels
      observation vertical coordinate: pressure

.. _obsops_densred:

Density Reduction
-----------------

Description
^^^^^^^^^^^

This operator can be used to reduce the number of locations passed to the GetValues class, leading to a faster execution time at the cost of
potentially reduced accuracy in the subsequent H(x) calculations.

This operator wraps an underlying observation operator. This operator passes to the underlying operator a set of GeoVaLs of length equal to
the number of ObsSpace locations, but requests from OOPS a smaller number of GeoVaLs.

The GeoVaLs passed to the underlying operator are referred to as the 'reduced' GeoVaLs, and those retrieved from OOPS are referred to as the 'sampled' GeoVaLs.
There are, in general, more reduced than sampled GeoVaLs, and this operator actually increases the number of GeoVaLs present.
This is contrary to the behaviour in other operators for which there are more sampled than reduced GeoVaLs, but we retain the nomenclature here for consistency.

Configuration options
^^^^^^^^^^^^^^^^^^^^^

* :code:`operator`: The name and configuration options of the underlying observation operator.

* :code:`algorithm`: The density reduction algorithm to use. See below for details.

Available density reduction algorithms
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

* :code:`simple`: Simple GeoVaLs density reduction algorithm.

Given a :code:`reduction factor` :math:`k`, this algorithm divides the observation locations into consecutive blocks of length :math:`k`.
The GeoVaLs associated with the first location are copied to the subsequent :math:`k - 1` locations.
If :math:`k` is equal to :math:`1`, there is no change relative to the standard behaviour of the underlying observation operator.
There is no guarantee that the observation locations are spatially close, so this algorithm achieves
a speed-up in GetValues at the potential cost to accuracy in H(x).

* :code:`lat lon grid`: Lat-lon grid GeoVaLs density reduction algorithm.

This algorithm divides the model domain into a regular lat-lon grid whose dimensions and resolution are specified by the user
via the options :code:`latitude grid length`, :code:`longitude grid length`, :code:`latitude lower bound`,
:code:`latitude upper bound` and :code:`longitude lower bound`.

A bin number is assigned to each observation using the following procedure, given latitude :math:`\phi` and longitude :math:`\lambda`:

* Let the latitude bin number :math:`\text{bin}_\phi = \text{trunc}((\phi - \phi_{\text{min}}) / \Delta\phi)`, where :math:`\phi_{\text{min}}` corresponds to :code:`latitude lower bound`, :math:`\Delta\phi` corresponds to :code:`latitude grid length`, and :math:`\text{trunc}` is the integer truncation operator that discards any fractional part of its argument.
* Let the longitude bin number :math:`\text{bin}_\lambda = \text{trunc}((\lambda - \lambda_{\text{min}}) / \Delta\lambda)`, where :math:`\lambda_{\text{min}}` corresponds to :code:`longitude lower bound` and :math:`\Delta\lambda` corresponds to :code:`longitude grid length`.
* Let the number of latitude bins :math:`n_{\phi} = (\phi_{\text{max}} - \phi_{\text{min}}) / \Delta\phi + 1`, where :math:`\phi_{\text{max}}` corresponds to :code:`latitude upper bound`. Adding one ensures that values of latitude that lie exactly on the upper bound are handled correctly.
* Let the overall bin number equal :math:`\text{bin}_\phi + n_{\phi} \text{bin}_\lambda`.

Note that, because it is not required in the above calculation, there is no option called :code:`longitude upper bound`.

One observation location is chosen for each unique overall bin number and passed to GetValues in order to draw the GeoVaLs.
Any additional locations associated with that bin number are assigned copies of the GeoVaLs that were produced for the selected location.

Example
^^^^^^^

The examples below are used to reduce the number of GeoVaLs retrieved prior to the application of the :code:`VertInterp` operator.

* Example using the :code:`simple` density reduction algorithm with :math:`k = 5`:

.. code-block:: yaml

  obs operator:
    name: Density Reduction
    component:
      name: VertInterp
      observation alias file: ../resources/namemap/test_name_map.yaml
      observation vertical coordinate: pressure
      vertical coordinate: air_pressure
      interpolation method: log-linear
    algorithm:
      name: simple
      reduction factor: 5

* Example using the :code:`lat lon grid` density reduction algorithm with grid boxes of size :math:`0.1^\circ \times 0.1^\circ`, spanning the entire global domain:

.. code-block:: yaml

  obs operator:
    name: Density Reduction
    operator:
      name: VertInterp
      observation alias file: ../resources/namemap/test_name_map.yaml
      observation vertical coordinate: pressure
      vertical coordinate: air_pressure
      interpolation method: log-linear
    algorithm:
      name: lat lon grid
      latitude lower bound: 0.0
      latitude upper bound: 180.0
      longitude lower bound: 0.0
      latitude grid length: 0.1
      longitude grid length: 0.1


.. _obsops_vertinterp:

Vertical Interpolation
----------------------

Description:
^^^^^^^^^^^^
This observation operator implements linear interpolation (including log-linear interpolation), and nearest-neighbor interpolation in a vertical coordinate when explicitly chosen. If choose automatic (which is same as choose default), then if the vertical coordinate is :code:`air_pressure` or :code:`air_pressure_levels`, interpolation is done in the logarithm of air pressure; if choose :code: `constant vertical coordinate values` :code:, then the default interpolation is nearest-neighbor. For all other vertical coordinates interpolation is done in the specified coordinate (no logarithm applied).

This operator can be used as a component of the `Composite` operator.

Configuration options:
^^^^^^^^^^^^^^^^^^^^^^
* :code:`vertical coordinate` [optional]: the vertical coordinate to use in interpolation. If set to :code:`air_pressure` or :code:`air_pressure_levels`, the interpolation is done in log(air pressure). The default value is :code:`air_pressure`.
* :code:`constant vertical coordinate values` [optional]: use the (array) values as vertical coordinate in interpolation. If :code:`interpolation method` is not defined, then nearest-neighbor will be used in interpolation. If this option is chosen, the geovals for vertical coordinate are not requested and vertical coordinate option above shouldn't be used. The primary purpose of this option is to serve the requirement for soil moisture assimilation.
* :code:`observation vertical coordinate` [optional]: name of the ObsSpace variable (from the :code:`MetaData` group) storing the vertical coordinate of observation locations. If not set, assumed to be the same as :code:`vertical coordinate`.
* :code:`variables` [optional]: a list of names of ObsSpace variables to be simulated by this operator (see the example below). This option should only be set if this operator is used as a component of the `Composite` operator. If it is not set, the operator will simulate all ObsSpace variables.

Optionally the vertical interpolation can use a 'backup' coordinate for interpolation. For some data types it might be preferable to use a certain coordinate but then fall back on an alternative coordinate when data is missing. This can be acheieved by specifying:

* :code:`vertical coordinate backup` [optional]: the backup vertical coordinate to use in interpolation.
* :code:`observation vertical coordinate backup` [optional]: name of the ObsSpace variable storing the vertical coordinate of observation locations.
* :code:`observation vertical coordinate group backup` [optional]: If the observation coordinate is not in the group :code:`MetaData` the parameter can be used to set the group to something else.
* :code:`interpolation method backup` [optional]: Type of interpolation to do when using the backup coordinate.

Optionally the resulting :math:`H(x)` can be scaled by another variable from the GeoVaLs or ObsSpace. This is achieved using two configuration keys:

* :code:`hofx scaling field` [optional]: The group providing the scaling field. Can be `GeoVaLs`.
* :code:`hofx scaling field group` [optional]: The name of the field used for scaling.

If either the existing :math:`H(x)` or the scaling factor are missing at a given location, the scaled output at that location will also be missing.

Examples of yaml:
^^^^^^^^^^^^^^^^^
.. code-block:: yaml

  obs operator:
    name: VertInterp

The observation operator in the above example does vertical interpolation in log(air pressure).

.. code-block:: yaml

  obs operator:
    name: VertInterp
    vertical coordinate: height

The observation operator in the above example does vertical interpolation in height.

.. code-block:: yaml

  obs operator:
    name: VertInterp
    vertical coordinate: air_pressure_levels
    observation vertical coordinate: pressure

The observation operator in the above example does vertical interpolation in log(pressure) on the levels taken from the :code:`air_pressure_levels` GeoVaL.

.. code-block:: yaml

  obs operator:
      name: VertInterp
      constant vertical coordinate values: [0.1, 0.5, 1.0, 2.0]
      interpolation method: nearest-neighbor
      observation vertical coordinate group: MetaData
      observation vertical coordinate: depthBelowSoilSurface

The observation operator in the above example choose array :code:`[0.1, 0.5, 1.0, 2.0]` as vertical coordinate in interpolation, :code:`interpolation method: nearest-neighbor` choose nearest-neighbor interpolation method.

.. code-block:: yaml

  obs operator:
    name: Composite
    components:
    - name: VertInterp
      variables:
      - name: windEastward
      - name: windNorthward
    - name: Identity
      variables:
      - name: stationPressure

In the example above, the `VertInterp` operator is used to simulate only the wind components; the surface pressure is simulated using the `Identity` operator.

.. code-block:: yaml

  obs operator:
    name: Composite
    components:
     - name: VertInterp
       variables: [windEastward, windNorthward]
       hofx scaling field: wind_reduction_factor_at_10m
       hofx scaling field group: GeoVaLs

       # Use height vertical coordinate first
       vertical coordinate: geometric_height
       observation vertical coordinate: height
       interpolation method: linear

       # Use pressure vertical coordinate backup
       vertical coordinate backup: air_pressure
       observation vertical coordinate backup: pressure
       interpolation method backup: log-linear

In the above example wind observations are simulated and scaled near the surface. The preferred coordinate to use for interpolation is height but in the case that height observations are missing the code will fall back on using pressure as the coordinate.


Column Retrieval Operator
-------------------------

Algorithmic Description:
^^^^^^^^^^^^^^^^^^^^^^^^

Observation operator for profile and columns satellite retrievals with averaging kernel functions and apriori terms. It computes the model equivalent to the observation :math:`\mathbf{X}_{\text{c}}` using the retrieval equation as follows:

.. math::

   \mathbf{X}_{\text{c}} = \mathbf{A}\mathbf{X}_{\text{background}} + (\mathbf{I} - \mathbf{A})\mathbf{X}_{\text{apriori}}

The operator recieves the geovals profiles :math:`\mathbf{X}_{\text{background}}` after the :code:`getvalues` procedure and then applies, if needed, the averaging kernel matrix information :math:`\mathbf{A}`. If needed as well it can apply an apriori term :math:`(\mathbf{I} - \mathbf{A})\mathbf{X}_{\text{apriori}}`. For each geoval profile the operator computes the :code:`tropospheric column` or :code:`total column` of any given atmospheric molecule concentration (**dry volume mixing ratio**) by integrating the geovals levels over a pressure range. such as:

.. math::

   X = \frac{1}{M_{\text{dry}} g} \int_{\alpha}^{\beta} C \, dp

Where :math:`X` is the partial column, :math:`M_{dry}` is the dry air molecular mass, :math:`g` the earth gravitational constant, :math:`\alpha` and :math:`\beta` the pressure vertices (also known as pressure retrieval interfaces), :math:`C` the geoval concentration and :math:`p` the geoval pressure. In a discrete algorithmic form this equation is defined in two cases described in the figure below:

.. image:: images/ColumnRetreival_levels.png
   :alt: Schematic representation for the column calculations comprehension

**Case1** - The vertices are over multiple pressure levels :math:`N`:

.. math::

   X = \frac{1}{M_{\text{dry}} g} \sum_{i=0}^{N}w_{i}C_{i}\left( p_{i+1} - p_{i} \right)

where :math:`w` is the interpolation weight, that is 1 if the geoval level pressure range is within the vertices range or a :math:`w_{i}\in ]0,1[, \forall i\in \left\{ \alpha,\beta \right\}` to account for the vertice to pressure interface staggering.

**Case2** - The vertices are within the same pressure level :math:`N`:

.. math::

   X = \frac{1}{M_{\text{dry}} g} \left( w_{\alpha} - w_{\beta} \right)C_{N}\left( p_{N+1} - p_{N} \right)

The result of that first part of the operator is to either calculate a partial/total column if the averaging kernel and apriori option aren't provided (see below) the code returns the column values without "smoothing". Otherwise the operator applies the averaging kernel and/or the apriori as follows:

.. math::

   X_{c}=\sum_{k=0}^{M}\left( A_{k}X_{k} \right) + P_{c}

where :math:`A_{k}` the averaging kernel value at the retrieval level :math:`k`, :math:`X_{k}` the partial column corresponding to the retrieval level and :math:`P_{c}=(\mathbf{I} - \mathbf{A})\mathbf{X}_{\text{apriori}}` which is calculated within the iodaconverter and put as scalar value per observation location.

The code of the non-linear and tangent linear and adjoint of this operator is in:
:code:`ufo/operators/columnretrieval/ufo_satcolumn_mod.F90`

Option descriptions:
^^^^^^^^^^^^^^^^^^^^
Yaml options are defined in :code:`ufo/operators/columnretrieval/ObsColumnRetrievalParameters.h`

* :code:`nlayers_retrieval`: Integer, optional and default is 1. It defines the number of retrieval layers in the obs file. Number of vertices will be and must be :code:`nlayers_retrieval +1`
* :code:`tracer variables`: String, required. It specify the names of model tracer variables in Geovals.
* :code:`isApriori`: Boolean, optional and default is false. It adds the a priori retrieval term if set to True.
* :code:`isAveragingKernel`: Boolean, optional and default is false. It adds the averaging kernel term if set to True.
* :code:`stretchVertices`: String, optional and default value is None. This option allows top and/or bottom retrieval vertices to match the geovals top of the atmosphere and/or surface pressure vertices. Options are: top, bottom, topbottom and none (default).
* :code:`model units coeff`: Double, optional and default is 1.0. It adds a conversion factor if background geovals values are not in the correct required unit: **dry volume mixing ratio** which is **mol of molecule considered per mol of dry air**
* :code:`totalNoVertice`: Boolean, optional and default is false. This option, if set to true, is valid if :code:`isAveragingKernel` is false and :code:`nlayers_retrieval` is 1. This then calculates the total column with all the geovals level values using all the pressure ranges. No pressure vertice information is needed.
* :code:`tropopause pressure`: Force the tropopause level when the observation product tropopause level could be above the chemical tropopause. Unit is in Pa and default value is 0 (top of the atmosphere).

Examples of yaml:
^^^^^^^^^^^^^^^^^

Example of using O3 OMPS Total Column without the Averaging Kernel Information. Here no vertices are needed. This is the simplest total column calculation that the operator can perform.

.. code-block:: yaml

  obs operator:
    name: ColumnRetrieval
    nlayers_retrieval: 1
    tracer variables: [mole_fraction_of_ozone_in_air]
    isApriori: false
    isAveragingKernel: false
    totalNoVertice: true
    stretchVertices: topbottom

Example of using O3 OMPS Nadir Profiler without the Averaging Kernel Information. Here vertices are provided to define the pressure ranges of each of profile values. Since no averaging kernel is used in this case, each retrieval profile level is considered as a separate observation (partial columns) and the 2D structure of the original observation (retrieval pixel, retrieval layers) can be flatten in the :code:`Location` dimension in the observation file.

.. code-block:: yaml

  obs operator:
    name: ColumnRetrieval
    nlayers_retrieval: 1
    tracer variables: [mole_fraction_of_ozone_in_air]
    isApriori: false
    isAveragingKernel: false
    totalNoVertice: false
    stretchVertices: none
    model units coeff: 2.1415E-3 #for GFS backgrounds, will be different or not needed with other models




Example of using NO2 TropOMI retrievals. Here the averaging kernel function is used but no apriori term (DOAS retrieval). :code:`pressureVertice` and :code:`averagingKernel` terms are needed in the :code:`RetrievalAncillaryData` group in the observation file (see observation file structure section below).

.. code-block:: yaml

  obs operator:
    name: ColumnRetrieval
    nlayers_retrieval: 34
    tracer variables: [volume_mixing_ratio_of_no2]
    isApriori: false
    isAveragingKernel: true
    stretchVertices: topbottom
    model units coeff: 1e-6 # ppmv to ppv
    tropopause pressure: 25000

Example of using CO MOPITT retrievals. Here the :code:`aprioriTerm` is added.

.. code-block:: yaml

  obs operator:
    name: ColumnRetrieval
    nlayers_retrieval: 10
    tracer variables: [volume_mixing_ratio_of_co]
    isApriori: true
    isAveragingKernel: true
    stretchVertices: topbottom
    model units coeff: 1e-6 # ppmv to ppv

An observation file structure example:
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

All codes to produce IODA observation files from raw format are in :code:`ioda-converters/tree/develop/src/compo`. For the name of the observable per convention we use the the camelCase format with :code:`<moleculeTypeofcolumn>`.  :code:`Total` will be used for total columns and :code:`Column` will be used for partial columns (e.g. :code:`nitrogendioxideColumn`, :code:`ozoneTotal`).

.. code-block::

  netcdf mopitt_co_2020090318_m {                                     # MOPITT CO as an example
  dimensions:
  	Location = 1901 ;                                                 # number of data points
  	Layer = 10 ;                                                      # number of retrieval layers if using averaging kernel
  	Vertice = 11 ;                                                    # number of pressure vertices, if used, it is always layer + 1
  variables:
  	int Location(Location) ;
  		Location:suggested_chunk_dim = 1901LL ;
  		Location:_FillValue = -2147483647 ;
  	int Layer(Layer) ;
  		Layer:suggested_chunk_dim = 10 ;
  	int Vertice(Vertice) ;
  		Vertice:suggested_chunk_dim = 11LL ;

  group: MetaData {
    variables:
    	int64 dateTime(Location) ;
    		dateTime:_FillValue = -9223372036854775801LL ;
    		dateTime:units = "seconds since 2020-09-03T15:00:00Z" ;
    	float latitude(Location) ;
    		latitude:_FillValue = -3.368795e+38f ;
    		latitude:units = "degrees_north" ;
    	float longitude(Location) ;
    		longitude:_FillValue = -3.368795e+38f ;
    		longitude:units = "degrees_east" ;
    } // group MetaData

  group: ObsError {
    variables:
    	float carbonmonoxideTotal(Location) ;
    		carbonmonoxideTotal:_FillValue = -3.368795e+38f ;
    		carbonmonoxideTotal:coordinates = "longitude latitude" ;
    		carbonmonoxideTotal:units = "mol m-2" ;                         # mol m-2 is the default unit choosen for the operator to return column values, therefore geovals must be provided in mol/mol. the conversion factor should be used to accomodate for this
    } // group ObsError

  group: ObsValue {
    variables:
    	float carbonmonoxideTotal(Location) ;
    		carbonmonoxideTotal:_FillValue = -3.368795e+38f ;
    		carbonmonoxideTotal:coordinates = "longitude latitude" ;
    		carbonmonoxideTotal:units = "mol m-2" ;                         # mol m-2 is the default unit choosen for the operator to return column values, therefore geovals must be provided in mol/mol. the conversion factor should be used to accomodate for this
    } // group ObsValue

  group: PreQC {
    variables:
    	int64 carbonmonoxideTotal(Location) ;
    		carbonmonoxideTotal:_FillValue = -9223372036854775801LL ;
    		carbonmonoxideTotal:coordinates = "longitude latitude" ;
    		carbonmonoxideTotal:units = "unitless" ;
    } // group PreQC

  group: RetrievalAncillaryData {
    variables:
    	float aprioriTerm(Location) ;
    		aprioriTerm:_FillValue = -3.368795e+38f ;
    	float averagingKernel(Location, Layer) ;
    		averagingKernel:_FillValue = -3.368795e+38f ;
    		averagingKernel:coordinates = "longitude latitude" ;
    		averagingKernel:units = "" ;
    	float pressureVertice(Location, Vertice) ;
    		pressureVertice:_FillValue = -3.368795e+38f ;
    } // group RetrievalAncillaryData
  }


Atmosphere Vertical Layer Interpolation (deprecated)
----------------------------------------------------

Description:
^^^^^^^^^^^^

Observational operator for vertical summation of model layers within an observational atmospheric layer where the top and bottom pressure levels are specified in cbars.

Examples of yaml:
^^^^^^^^^^^^^^^^^

.. code-block:: yaml

  obs operator:
    name: AtmVertInterpLay

Atmosphere Surface Interpolation (deprecated)
----------------------------------------------------

Note:
Surface Corrected operator :ref:`SfcCorrected <obsops_sfc_corrected>` for Temperature and Pressure can be used instead.

Description:
^^^^^^^^^^^^

Observational operator for surface interpolation of model surface values to observation locations.

Examples of yaml:
^^^^^^^^^^^^^^^^^
.. code-block:: yaml

  obs operator:
    name: GSISfcModel

Community Radiative Transfer Model (CRTM)
-----------------------------------------

Description:
^^^^^^^^^^^^

Interface to the Community Radiative Transfer Model (CRTM) as an observational operator.

Configuration options:
^^^^^^^^^^^^^^^^^^^^^^

The CRTM operator has some required geovals (see varin_default in ufo/crtm/ufo_radiancecrtm_mod.F90). The configurable geovals are as follows:

* :code:`Absorbers` : CRTM atmospheric absorber species that will be requested as geovals.  H2O and O3 are always required. So far H2O, O3, CO2 are implemented. More species can be added readily by extending UFO_Absorbers and CRTM_Absorber_Units in ufo/crtm/ufo_crtm_utils_mod.F90.
* :code:`CO2AbsorberMethod` [optional]: The method used to populate the CO\ :sub:`2`  profile for CRTM. Methods include 'Background' (default), 'EternalConstant', and 'MaunaLoa' (empirical global constant derived from time at the middle of the analysis cycle).
* :code:`CO2ppmvValue` [optional]: When the 'EternalConstant' method is chosen for CO2AbsorberMethod, this specifies in ppmv the global constant.
* :code:`Clouds` [optional] : CRTM cloud constituents that will be requested as geovals; can include any of Water, Ice, Rain, Snow, Graupel, Hail. Clouds water contents and effective radius can be re-set as zero in the atmospheric profiles for CRTM by assigning a value 1 to :code:`MetaData/zeroCloudInCRTM` in certain conditions in :code:`obs prior filters`. An example to zero-out cloud constituents above surface where :code:`GeoVaLs/water_area_fraction` is less than 0.99 is provided.
* :code:`Cloud_Fraction` [optional] : sets the CRTM Cloud_Fraction to a constant value across all profiles (e.g., 1.0). Omit this option in order to request cloud_area_fraction_in_atmosphere_layer as a geoval from the model. This parameter is also used for :code:`linear obs operator`.
* :code:`SurfaceWindGeoVars` [str, optional, options: :code:`vector` - default, :code:`uv`] : specify which two surface wind GeoVaLs are requested from the model.  :code:`vector` indicates that surface wind direction and magnitude are requested.  :code:`uv` indicates that surface eastward and northward wind components are requested.

* :code:`linear obs operator` [optional] : used to indicate a different configuration for K-Matrix multiplication of tangent linear and adjoint operators from the configuration used for the Forward operator.  The same atmospheric profile is used in the CRTM Forward and K_Matrix calculations. Only the linear GeoVaLs interface to the model will be altered by this sub-configuration. Omit :code:`linear obs operator` in order to use the same settings across Forward, Tangent Linear, and Adjoint operators.
* :code:`linear obs operator.Absorbers` [optional] : only the selected Absorbers will be acted upon in K-Matrix multiplication.  Must be a sub-set of :code:`obs operator.Absorbers`.
* :code:`linear obs operator.Clouds` [optional] : only the selected Clouds will be acted upon in K-Matrix multiplication.  Must be a sub-set of :code:`obs operator.Clouds`.

:code:`obs options` configures the tabulated coefficient files that are used by CRTM

* :code:`obs options.Sensor_ID` : {sensor}_{platform} prefix of the sensor-specific coefficient files, e.g., amsua_n19
* :code:`obs options.EndianType` : Endianness of the coefficient files. Either little_endian or big_endian.
* :code:`obs options.CoefficientPath` : location of all coefficient files

* :code:`obs options.IRwaterCoeff` [optional] : options: [Nalli (D), WuSmith]
* :code:`obs options.VISwaterCoeff` [optional] : options: [NPOESS (D)]
* :code:`obs options.IRVISlandCoeff` [optional] : options: [NPOESS (D), USGS, IGBP]
* :code:`obs options.IRVISsnowCoeff` [optional] : options: [NPOESS (D)]
* :code:`obs options.IRVISiceCoeff` [optional] : options: [NPOESS (D)]
* :code:`obs options.MWwaterCoeff` [optional] : options: [FASTEM6 (D), FASTEM5, FASTEM4]

Examples of valid yaml:
^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: yaml

  obs operator:
    name: CRTM
    Absorbers: [H2O, O3]
    Clouds: [Water, Ice, Rain, Snow, Graupel, Hail]
    linear obs operator:
      Absorbers: [H2O]
      Clouds: [Water, Ice]
    obs options:
      Sensor_ID: amsua_n19
      EndianType: little_endian
      CoefficientPath: Data/

.. code-block:: yaml

  obs operator:
    name: CRTM
    Absorbers: [H2O, O3, CO2]
    Clouds: [Water, Ice]
    Cloud_Fraction: 1.0
    SurfaceWindGeoVars: uv
    obs options:
      Sensor_ID: iasi_metop-a
      EndianType: little_endian
      CoefficientPath: Data/
      IRVISlandCoeff: USGS

.. code-block:: yaml

  obs operator:
    name: CRTM
    Absorbers: [H2O, O3]
    SurfaceWindGeoVars: vector
    linear obs operator:
      Absorbers: [H2O]
    obs options:
      Sensor_ID: abi_g16
      EndianType: little_endian
      CoefficientPath: Data/

.. code-block:: yaml

  ## Zero-out cloud constituents above surface where water area fraction is less than 0.99.
  obs prior filters:
  - filter: Variable Assignment
    assignments:
    - name: MetaData/zeroCloudInCRTM
      type: int
      function:
        name: ObsFunction/Conditional
        options:
          defaultvalue: 0 # Will not zero clouds by default
          cases:
          - where:
            - variable:
                name: GeoVaLs/water_area_fraction
              maxvalue: 0.99
            value: 1 # Will zero clouds by default

RTTOV
-----------------------------------------

Description:
^^^^^^^^^^^^

Interface to the RTTOV observation operator.

Inputs:
^^^^^^^^^^^^^^^^^^^^^
RTTOV requires the following GeoVaLs for clear-sky radiance calculation. The variable name for use with ufo is given in parentheses () and the expected units in square brackets []:

* :code:`air_pressure` (:code:`var_prs`) [Pa]
* :code:`air_temperature` (:code:`var_ts`) [K]
* :code:`specific_humidity` (:code:`var_q`) [kg/kg]
* :code:`surface_temperature` (:code:`var_sfc_t2m`) [K]
* :code:`uwind_at_10m` (:code:`var_sfc_u10`) [m/s]
* :code:`vwind_at_10m` (:code:`var_sfc_v10`) [m/s]
* :code:`air_pressure_at_two_meters_above_surface` (:code:`var_sfc_p2m`) [Pa]
* :code:`specific_humidity_at_two_meters_above_surface` (:code:`var_sfc_q2m`) [kg/kg]
* :code:`skin_temperature` (:code:`var_sfc_tskin`) [K]

Additionally, for calculation of MW cloud-affected radiances using RTTOV-SCATT the following GeoVaLs are also required:

* :code:`air_pressure_levels` (:code:`var_prsi`) [Pa]
* :code:`cloud_liquid_water_mixing_ratio_wrt_moist_air_and_condensed_water` (:code:`var_qcl`) [kg/kg]
* :code:`cloud_ice_mixing_ratio_wrt_moist_air_and_condensed_water` (:code:`var_qci`) [kg/kg]
* :code:`cloud_area_fraction_in_atmosphere_layer`  (:code:`var_cloud_layer`) [dimensionless]

The geographic location of the observation, the satellite zenith angle and the RTTOV surface type are also required from the ObsSpace:

* At least one (in order of priority) from :code:`MetaData/heightOfSurface`, :code:`MetaData/heightOfSurface`, :code:`MetaData/model_orography` or the :code:`surface_altitude` geoval [m]
* :code:`MetaData/latitude` [degrees]
* :code:`MetaData/longitude` [degrees, -180--180 or 0--360]
* :code:`MetaData/sensorZenithZngle` [degrees]
* :code:`MetaData/surfaceQualifier` [0-2]

  :code:`MetaData/surfaceQualifier` is used to specify whether RTTOV should treat an observation as having a land (0), sea (1) or sea-ice (2) surface. The :code:`SetSurfaceType` ObsFunction, may be called via the :code:`VariableAssignment` ObsFilter to generate this data according to rules used in operational processing at the Met Office.

Optionally, the satellite azimuth angle and the solar zenith/azimuth angles may be supplied:

* :code:`MetaData/sensorAzimuthAngle` (optional) [degrees]
* :code:`MetaData/solarZenithAngle` (optional) [degrees]
* :code:`MetaData/solarAzimuthAngle` (optional) [degrees]

Outputs:
^^^^^^^^^^^^^^^^^^^^^

| The interface returns brightness temperatures for any channels requested using the :code:`obs space.channels` YAML configuration key. The brightness temperature fields shall be stored in a two-dimensional dataset in the :code:`HofX` group in the output observation database (e.g. :code:`/HofX/brightnessTemperature`.

| The interface optionally returns observation diagnostics including those requiring the calculation of jacobians, through the :code:`obs diagnostics.variables` YAML configuration key . Specifically:

* :code:`optical_thickness_of_atmosphere_layer`
* :code:`transmittances_of_atmosphere_layer`
* :code:`weightingfunction_of_atmosphere_layer`
* :code:`toa_outgoing_radiance_per_unit_wavenumber`
* :code:`brightness_temperature_assuming_clear_sky`
* :code:`pressure_level_at_peak_of_weightingfunction`
* :code:`toa_total_transmittance`
* :code:`emissivity`
* :code:`brightness_temperature_jacobian_${any_active_variable}`

Where an observation diagnostic is requested that is not recognised by the interface, **no error is returned**, but memory is still allocated for the named observation diagnostic and the array is initialised to :code:`missing`. This is to facilitate the subsequent creation of bias correction predictors using output from the observation operator.

Generic Obs Operator configuration options:
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
The configurable options for the RTTOV observation operator interface are:

* :code:`name` (string, required): Must be set to :code:`RTTOV` in order to invoke this RTTOV observation operator.

* :code:`Debug` (boolean, optional, default false): Print additional debugging statements.

* :code:`Absorbers` (string list, optional): *Additional* atmospheric absorber species that will be requested from geovals. Names must correspond to those specified in :code:`gas_name` array in the |rttov_const module|.

  * :code:`Water_vapour` (the internal RTTOV name for water vapour, c.f. :code:`H2O` in CRTM) is mandatory and maps to :code:`specificHumidity` and it is not necessary to list it here explicitly.

  * :code:`CLW` (cloud liquid water) is optional for clear-sky MW calculation but mandatory for MW scattering calculations and maps to :code:`cloud_liquid_water_mixing_ratio_wrt_moist_air_and_condensed_water`.

  * :code:`CIW` (cloud ice water) is not used for clear-sky MW calculation but mandatory for MW scattering calculations and maps to :code:`cloud_ice_mixing_ratio_wrt_moist_air_and_condensed_water`.

  * :code:`Ozone`, :code:`CO2`, :code:`CO`, :code:`N2O`, :code:`CH4`, :code:`SO2` are due to be implemented.

  | **N.B.**

  | Where the optional trace gas profiles are not present in the geovals, RTTOV reference profiles stored in the RTTOV coefficients will be used to determine their concentration if a compatible RTTOV coefficient is being used.

  | The contribution to optical depth from absorbing species for which there are no coefficients present in the RTTOV coefficient file will usually have been included with a fixed profile during the training process. See |RTTOV_12.3_user_guide| for details.

  | There are no reference profiles for :code:`CLW` and :code:`CIW`. If either absorber is required, because it is mandatory or by user request, then the requisite datasets must be present in the geovals.

.. todo::

  hyperspectral IR support (specifically add code to read RTTOV supported gases)

.. * :code:`linear model absorbers` (optional) : used to indicate a different set of active variables for the Tangent Linear (TL) and Adjoint (AD) operators from the configuration used for the non-linear operator. The same profile is used in the RTTOV Forward and TL/AD calculations.

  * :code:`linear model absorbers` (string list, optional) : controls which of the selected absorbers will be active during the Jacobian calculation.
  Omit :code:`linear model` in order to use the same absorbers as for the TL and AD operators as for the non-linear forward model.

RTTOV interface specific configuration options (:code:`obs options`):
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
The :code:`obs options` section configures the options that can be used to change the behaviour of the RTTOV interface.

Required
~~~~~~~~~~~~

Three options are required to uniquely specify the RTTOV coefficient file to be used to process observations.
The coefficient filename will be :code:`rtcoef_${Platform_Name}_${Sat_ID}_${Instrument_Name}` with the extension automatically discovered by RTTOV. The order of preference will be :code:`.bin` (platform-specific unformatted binary), :code:`.dat` (ASCII format), :code:`.H5` (HDF5 format).
Scattering coefficients will be automatically read when requested according to the other :code:`obs options`. Their absence when required shall result in an error.

* :code:`obs options.Platform_Name` (string): Corresponds to an
  element of the :code:`platform_name` array in the |rttov_const
  module|, e.g. 'NOAA', 'Metop'. Note that this is case-insensitive,
  as user input is automatically converted to lower case.
* :code:`obs options.Sat_ID` (integer): Corresponds to the satellite ID.
* :code:`obs options.Instrument_Name` (string): Corresponds to an
  element of the :code:`instrument_name` array in  |rttov_const
  module|, e.g. 'ATMS', 'IASI'. Note that this is case-insensitive as,
  as user input is automatically converted to lower case.
* :code:`obs options.CoefficientPath` (string): Relative or absolute path to all coefficient files to be read.

.. |rttov_const module| raw:: html

   <a href="https://github.com/JCSDA-internal/rttov/blob/develop/src/rttov/main/rttov_const.F90#L137" target="_blank">rttov_const module</a>


Optional
~~~~~~~~
* :code:`obs options.RTTOV_default_opts` (string, default :code:`default`): These are set first and may be overridden by setting individual options. Valid options are :code:`UKMO_PS43`, :code:`UKMO_PS44`, :code:`UKMO_PS45` and correspond to options pertaining to RTTOV used operationally at the Met Office.
* :code:`obs options.Do_MW_Scatt` (boolean, default :code:`false`): Call RTTOV-SCATT to simulate MW radiances affected by cloud and precipitation.
* :code:`obs options.UseQCFlagsToSkipHofX` (boolean, default :code:`false`): Use the quality control flags to decide whether a profile should be passed to rttov. This will turn on profile by profile processing. This is currently only implemented for the :code:`ObsOperator`. The :code:`LinearObsOperator` code will be added after oops functionality is available.
* :code:`obs options.RTTOV_GasUnitConv` (integer, default :code:`false`): Convert absorber concentration from mass concentration [kg/kg] to volume concentration [ppmv dry] for use with RTTOV.
* :code:`obs options.InspectProfileNumber` (integer list, default 0): Print RTTOV profile(s) with indices corresponding to the order in which the geovals are processed. Intended for use with debugging.
* :code:`obs options.InspectProfileLatLonBox` (list of 4 floats, [latmin, latmax, lonmin, lonmax]): Print RTTOV profile(s) which fall within a specified latitude and longitude box. Intended for use with debugging.
* :code:`obs options.SatRad_compatibility` (boolean, default :code:`true`): Sets internal options to replicate Met Office OPS processing.
* :code:`obs options.UseColdSurfaceCheck` (boolean, default :code:`false`): Reset surface temperature over land and sea-ice where it is below 271.4 K. This is a legacy option for replicating OPS results prior to PS45 (requires :code:`SatRad_compatibility` to be true).
* :code:`obs options.BoundQToSaturation` (boolean, default :code:`true`): Check the humidity profile and surface humidity does not exceed saturation.  If they do then reset to saturation. (requires :code:`SatRad_compatibility` to be true).
* :code:`obs options.UseRHWaterForQC` (boolean, default :code:`true`): Use liquid water only in the saturation calculation (requires :code:`SatRad_compatibility` and :code:`BoundQToSaturation` to both be set to true).
* :code:`obs options.UseMinimumQ` (boolean, default :code:`true`): Check the humidity profile and surface humidity is not less than min_q.  If the humidity is then it is reset to min_q.  Where the humidity profile has been reset to zero the Jacobian used in the TL and AD is set the zero. (requires :code:`SatRad_compatibility` to be true).
* :code:`obs options.UseSurfaceEmissivityAtlas` (boolean, default :code:`false`): Initialise and read a surface emissivity atlas.
* :code:`obs options.SurfaceEmissivityAtlasName` (string, default :code:`default`): Surface emissivity atlas name, valid options are: UWIREmis, CAMEL, CAMELClim, TELSEM2, CNRM
* :code:`obs options.SurfaceEmissivityAtlasPath` (string): Surface emissivity atlas relative path
* :code:`obs options.ReconstructedRadianceCorrection` (boolean, default :code:`false`): Apply a correction to simulated radiances to account for the effect of reconstruction from PC scores. The theory of this correction can be found <a href="https://itwg.ssec.wisc.edu/wordpress/wp-content/uploads/2025/06/poster.4p.04.Migliorini_itsc25.pdf" target="_blank">here</a>. If this option is set to true then :code:`CMatrixPath` must also be set. Note that when this option is set to true, :code:`RTTOV_switchrad` is set to false.
* :code:`obs options.CMatrixPath` (string): Relative path to the files required the apply the corrections for the reconstructed radiance observation operator. Required if :code:`ReconstructedRadianceCorrection` is set to true.

Additionally, each option that may be modified within the RTTOV options structure may be accessed by prefixing :code:`RTTOV_` ahead of the option name, regardless of where it resides within the RTTOV option structure.
For example, :code:`RTTOV_addrefrac: true` will enable the option within RTTOV to account for atmospheric refraction during the optical depth calculation.
All options are set to the defaults specified in the |RTTOV_12.3_user_guide|.

.. |RTTOV_12.3_user_guide| raw:: html

   <a href="https://www.nwpsaf.eu/site/download/documentation/rtm/docs_rttov12/users_guide_rttov12_v1.3.pdf" target="_blank">RTTOV 12.3 user guide</a>

Examples of yaml:
^^^^^^^^^^^^^^^^^

.. code-block:: yaml

  obs operator:
    name: RTTOV
    Absorbers: &rttov_absorbers [Water_vapour, CLW, CIW]
    linear model absorbers: [Water_vapour]
    obs options: &rttov_options
      RTTOV_default_opts: UKMO_PS45
      SatRad_compatibility: true
      RTTOV_GasUnitConv: true
      UseRHwaterForQC: &UseRHwaterForQC true # default
      UseColdSurfaceCheck: &UseColdSurfaceCheck false # default
      Do_MW_Scatt: &RTTOVMWScattSwitch false
      Platform_Name: &platform_name NOAA
      Sat_ID: &sat_id 20
      Instrument_Name: &inst_name ATMS
      CoefficientPath: &coef_path /Data

Aerosol Optical Depth (AODCRTM)
-------------------------------

Description:
^^^^^^^^^^^^

The operator to calculate Aerosol Optical Depth for GOCART aerosol parameterization. It relies on the implementation of GOCART (3 different options see below for details) in the CRTM. AOD is calculated using CRTM's tables of optical properties for these aerosols. Some modules are shared with CRTM radiance UFO.
On input, the operator requires aerosol mixing ratios, interface and mid-layer pressure, air temperature and specific / relative humidity for each model layer.


Configuration options:
^^^^^^^^^^^^^^^^^^^^^^

:code:`name`: AodCRTM
:code:`Absorbers`: (Both are required; No clouds since AOD retrievals are not obtained in cloudy regions).
* H2O to determine radii of hygrophillic aerosols particles
* O3 not strictly affecting aerosol radiative properties but required to be entered by the CRTM (here mixing ratio assigned a default value)

:code:`obs options` configures the tabulated coefficient files that are used by CRTM.
  * :code:`Sensor_ID`: v.viirs-m_npp, v.viirs-m_n20, v.modis_aqua, v.modis_terra
  * :code:`EndianType` : Endianness of the coefficient files. Either little_endian or big_endian.
  * :code:`CoefficientPath` : location of all coefficient files
  * :code:`AerosolOption`: aerosols_gocart_default, aerosols_gocart_1, aerosols_gocart_2. Define the different gocart variables, see https://github.com/JCSDA-internal/ufo/blob/develop/src/ufo/ufo_variables_mod.F90 for details.
  * :code:`model units coeff`: (optional) scaling factor for different background units, e.g. GFS is ug/kg and GEOS is kg/kg. Default value is 1.0 and operator would then expect ug/kg.


Example of a yaml:
^^^^^^^^^^^^^^^^^^

.. code-block:: yaml

   obs operator:
     name: AodCRTM
     Absorbers: [H2O,O3]
     obs options:
       Sensor_ID: v.viirs-m_npp
       EndianType: little_endian
       CoefficientPath: Data/
       AerosolOption: aerosols_gocart_default
       model units coef: 1e9

Aerosol Optical Depth (AODMassFraction)
---------------------------------------

Description:
^^^^^^^^^^^^

This operator calculates the Aerosol Optical Depth (AOD) for a given model and extinction coefficient calculation method. For each model, a list of species is defined in the ObsAodMassFraction constructor in ObsAodMassFraction.cc, along with the variable names for their mass fractions. The variable names for number fractions can also optionally be defined. The AOD is then calculated as a function of mass fractions per species, extinction coefficient per species and level, :code:`air_pressure_levels` and :code:`air_pressure_at_surface`, summing over all levels and species. :code:`air_pressure_levels` is assumed to be on staggered levels in relation to the aerosol mass and number fractions.

The operator is currently implemented for the GLOMAP/UKCA dust modal model, which has two defined 'species': the dust accumulation and coarse modes. The only method for calculating the extinction coefficient that is currently implemented is the :code:`MetOfficeLUTFit`. In this method the extinction coefficient for a given atmospheric level is calculated as a function of the median modal diameter for the UKCA dust model, using a best fit function. The best fit function parameters are defined in the yaml. The median modal diameter is itself derived from the mass and number fraction for each mode (assuming a log-normal distribution of sizes).

In future, other models with different species lists could be added, as could other methods for calculating the extinction coefficient per level and species. For example a Look-Up Table approach could be implemented for the extinction coefficient calculation, such as is currently used for AODCRTM.

Configuration options:
^^^^^^^^^^^^^^^^^^^^^^
- :code:`aerosolModel` (required parameter): the aerosol model to calculate the AOD for.
- :code:`extinctionMethod` (required parameter): method for calculating the extinction coefficient per level and species.
- :code:`coarseModeParams` (optional parameter, no default): vector of 4 best fit parameters for the UKCA dust coarse mode extinction coefficient calculation. Although this is an optional parameter, it is needed for the :code:`MetOfficeLUTFit` :code:`extinctionMethod` and a userError will be raised if :code:`coarseModeParams` is not provided with this option.
- :code:`accumulationModeParams` (optional parameter, no default): vector of 7 best fit parameters for the UKCA dust accumulation mode extinction coefficient calculation. As for :code:`coarseModeParams`, this parameter is optional but if the :code:`MetOfficeLUTFit` :code:`extinctionMethod` is used and :code:`accumulationModeParams` is not provided then a userError will be raised.

Example of a yaml:
^^^^^^^^^^^^^^^^^^

Note that the parameters given for :code:`coarseModeParams` and :code:`accumulationModeParams` in the below example are dummy values.

.. code-block:: yaml

    obs operator:
      name: AodMassFraction
      aerosolModel: UKCA_Dust
      extinctionMethod: MetOfficeLUTFit
      coarseModeParams: [0.00001, -1.2, 30000, 5.2]
      accumulationModeParams: [-78694.00351517955, -33703.77308488245, -5961.088273152457,
                               -557.8611937150873, -29.158406179998607, -0.8077018771540053,
                               -0.009270394299237103]

Aerosol Optical Depth (AOD) for dust (Met Office)
-------------------------------------------------

This operator calculates the Aerosol Optical Depth at one wavelength (e.g. 550 nm) from control variables of mass concentration of atmospheric dust (in :math:`kg/m^3`) by height for a number of different size bins, air pressure by height and surface pressure, assuming constant extinction coefficients per bin which are independent of humidity. The air pressure is assumed to be on staggered levels in relation to dust mass concentration, and the levels must be ordered from top-to-bottom. This operator is designed for use with the Met Office forecast model which includes prognostic dust fields with 2 - 6 bins, and for the assimilation of AOD products such as from MODIS and VIIRS.


Configuration options:
^^^^^^^^^^^^^^^^^^^^^^
- :code:`NDustBins`: number of bins;
- :code:`AodKExt`: extinction coefficients for each bin in :math:`m^2/kg`. This must be a vector of size `NDustBins`.

Example of a yaml:
^^^^^^^^^^^^^^^^^^

For example, to calculate the AOD for 3 aerosol dust bins with average extinction coefficients of (for the sake of argument) 100, 200 and 300 :math:`m^2/kg`:

.. code-block:: yaml

    obs operator:
      name: AodMetOffice
      NDustBins: 3
      AodKExt: [1.00E+02,2.00E+02,3.00E+02]

GNSS RO bending angle (NBAM)
-----------------------------

Description:
^^^^^^^^^^^^

A one-dimensional observation operator for calculating the Global
Navigation Satellite System (GNSS) Radio Occultation (RO) bending
angle data based on the NBAM (NCEP's Bending Angle Method)

Configuration options (ObsOperator):
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

* :code:`vertlayer`: if air pressure and geopotential height are read on the interface layer or the middle layer

  * options: :code:`mass` or :code:`full` (default is :code:`full`)

* :code:`super_ref_qc`: if use the "NBAM" or "ECMWF" method to do super refraction check.

  * options: :code:`NBAM` or :code:`ECMWF` (default is :code:`NBAM`)

* :code:`sr_steps`: when using the "NBAM" super refraction, if apply one or two step QC. As to September 2023, the super refraction check is consistent with the operational GSI codes.

  * options: :code:`1`, :code:`2`, or :code:`3` (default is :code:`2`. :code:`1` does only the first step super refraction check using the 0.75 critical threshold as GSI; :code:`2` replicates the GSI super refraction QC check including 2 steps; :code:`3` differs from :code:`2` in the second step. The differences are minor. Users are suggested to use :code:`3` for their research unless they want to exactly replicate GSI)

* :code:`use_compress`: compressibility factors in geopotential heights. Only for NBAM.

  * options: :code:`1` to turn on; :code:`0` to turn off (Default is 1)

Configuration options (ObsSpace):
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

* :code:`obsgrouping`: applying sequenceNumber as group_variable can get RO profiles in ufo. Otherwise RO data would be treated as single observations.

Configuration options (ObsFilters):
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

* :code:`Domain Check`: a generic filter used to control the maximum height one wants to assimilate RO observation.Default value is 50 km.

* :code:`ROobserror`: A RO specific filter. use generic filter class to apply observation error method.  More information on this filter is found in :ref:`obsFilterErrors`.

  * options: :code:`NBAM`, :code:`NRL`, :code:`ECMWF`, and more to come (default is :code:`NBAM`)

* :code:`Background Check`: the background check for RO can use either the generic one (see the filter documents) or the  RO specific one based on the NBAM implementation in GSI.

  * options: :code:`Background Check` for the JEDI generic one or :code:`Background Check RONBAM` for NBAM method.

Examples of yaml:
^^^^^^^^^^^^^^^^^
:code:`ufo/test/testinput/gnssrobndnbam.yaml`

.. code-block:: yaml

 observations:
   observers:
   - obs space:
        name: GnssroBnd
        obsdatain:
          engine:
            type: H5File
            obsfile: Data/ioda/testinput_tier_1/gnssro_obs_2018041500_3prof.nc4
          obsgrouping:
            group variable: "sequenceNumber"
            sort variable: "impactHeightRO"
            sort order: "ascending"
        obsdataout:
          engine:
            type: H5File
            obsfile: Data/gnssro_bndnbam_2018041500_3prof_output.nc4
        simulate variables: [bendingAngle]
      obs operator:
        name: GnssroBndNBAM
        obs options:
          use_compress: 1
          vertlayer: full
          super_ref_qc: NBAM
          sr_steps: 2
      obs filters:
      - filter: Domain Check
        filter variables:
        - name: [bendingAngle]
        where:
        - variable:
            name: MetaData/impactHeightRO
          minvalue: 0
          maxvalue: 50000
      - filter: ROobserror
        filter variables:
        - name: bendingAngle
        errmodel: NRL
      - filter: Background Check
        filter variables:
        - name: [bendingAngle]
        threshold: 3


GNSS RO bending angle (ROPP 1D)
--------------------------------

Description:
^^^^^^^^^^^^

The JEDI UFO interface of the Eumetsat ROPP package that implements
a one-dimensional observation operator for calculating the Global
Navigation Satellite System (GNSS) Radio Occultation (RO) bending
angle data

Configuration options (ObsSpace):
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

* :code:`obsgrouping`: applying sequenceNumber as a group_variable can get RO profiles in ufo. Otherwise RO data would be  treated as single observations.

Configuration options (ObsFilters):
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

* :code:`Domain Check`: a generic filter used to control the maximum height one wants to assimilate RO observation. Default value is 50 km.

* :code:`ROobserror`: a RO specific filter. Use generic filter class to apply observation error method.  More information on this filter is found in the :ref:`obsFilterErrors`.

  * options: :code:`NBAM`, :code:`NRL`, :code:`ECMWF`, and more to come (default is :code:`NBAM`, but not recommended for ROPP operators). One has to specific a error model.

* :code:`Background Check`: can only use the generic one (see the filter documents).

Examples of yaml:
^^^^^^^^^^^^^^^^^
:code:`ufo/test/testinput/gnssrobndropp1d.yaml`

.. code-block:: yaml

 observations:
   observers:
   - obs space:
       name: GnssroBndROPP1D
       obsdatain:
         engine:
           type: H5File
           obsfile: Data/ioda/testinput_tier_1/gnssro_obs_2018041500_m.nc4
         obsgrouping:
           group variable: "sequenceNumber"
           sort variable: "impactHeightRO"
       obsdataout:
         engine:
           type: H5File
           obsfile: Data/gnssro_bndropp1d_2018041500_m_output.nc4
       simulate variables: [bendingAngle]
     obs operator:
        name:  GnssroBndROPP1D
        obs options:
     obs filters:
     - filter: Domain Check
       filter variables:
       - name: [bendingAngle]
       where:
       - variable:
           name: MetaData/impactHeightRO
         minvalue: 0
         maxvalue: 50000
     - filter: ROobserror
       filter variables:
       - name: bendingAngle
       errmodel: NRL
     - filter: Background Check
       filter variables:
       - name: [bendingAngle]
       threshold: 3

GNSS RO bending angle (ROPP 2D)
-----------------------------------

Description:
^^^^^^^^^^^^

The JEDI UFO interface of the Eumetsat ROPP package that implements
a two-dimensional observation operator for calculating the Global
Navigation Satellite System (GNSS) Radio Occultation (RO) bending
angle data


Configuration options (ObsOperator):
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

* :code:`n_horiz`: the horizontal points the operator integrates along the 2d plane. Default is 31. Has to be a odd number.

* :code:`res`: The horizontal resolution of the 2d plance. Default is 40 km.

* :code:`top_2d`: the highest height to apply the 2d operator. Default is 20 km.

Configuration options (ObsSpace):
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

* :code:`obsgrouping`: applying sequenceNumber as group_variable can get RO profiles in ufo. Otherwise RO data would be treated as single observations.

Configuration options (ObsFilter):

* :code:`Domain Check`: a generic filter used to control the maximum height one wants to assimilate RO observation. Default value is 50 km.

* :code:`ROobserror`: a RO specific filter. Use generic filter class to apply observation error method.  More information on this filter is found in the :ref:`obsFilterErrors`.

  * options: :code:`NBAM`, :code:`NRL`, :code:`ECMWF`, and more to come (default is :code:`NBAM`, but not recommended for ROPP operators). One has to specific a error model.

* :code:`Background Check`: can only use the generic one (see the filter documents).

Examples of yaml:
^^^^^^^^^^^^^^^^^

.. code-block:: yaml

 observations:
   observers:
   - obs space:
       name: GnssroBndROPP2D
       obsdatain:
         engine:
           type: H5File
           obsfile: Data/ioda/testinput_tier_1/gnssro_obs_2018041500_m.nc4
         obsgrouping:
           group_variable: "sequenceNumber"
           sort_variable: "impactHeightRO"
       obsdataout:
         engine:
           type: H5File
           obsfile: Data/gnssro_bndropp2d_2018041500_m_output.nc4
       simulate variables: [bendingAngle]
     obs operator:
        name: GnssroBndROPP2D
        obs options:
          n_horiz: 31
          res: 40.0
          top_2d: 1O.0
     obs filters:
     - filter: Domain Check
       filter variables:
       - name: [bendingAngle]
       where:
       - variable:
           name: MetaData/impactHeightRO
         minvalue: 0
         maxvalue: 50000
     - filter: ROobserror
       n_horiz: 31
       filter variables:
       - name: bendingAngle
       errmodel: NRL
     - filter: Background Check
       filter variables:
       - name: [bendingAngle]
       threshold: 3

GNSS RO bending angle (MetOffice)
-----------------------------------

Description:
^^^^^^^^^^^^

The JEDI UFO interface of the Met Office's one-dimensional observation
operator for calculating the Global
Navigation Satellite System (GNSS) Radio Occultation (RO) bending
angle data

Configuration options (ObsOperator):
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

:code:`none`.

Configuration options (ObsSpace):
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

:code:`vert_interp_ops`: if true, then use log(pressure) for vertical interpolation, if false then use exner function for vertical interpolation.

:code:`pseudo_ops`: if true then calculate data on intermediate "pseudo" levels between model levels, to minimise interpolation artifacts.

:code:`min_temp_grad`: The minimum vertical temperature gradient. Default: 1e-6. Any vertical gradients below this threshold will be treated as isothermal.

:code:`no super-refraction check`: Switch off the super-refraction check in the forward operator (sometimes known as the impact parameter check).  Default: false.  If true, then the model profile will be altered to interpolate over any regions where the impact parameter co-ordinate in the model doesn't increase by at least 10m between model levels.

:code:`dry_refractivity_constant`: Coefficient applied to the dry part of the refractivity equation. Default: 0.776 which is the value from :cite:`Smith1953`.

:code:`wet_refractivity_constant`: Coefficient applied to the wet part of the refractivity equation. Default: 3730 which is the value from :cite:`Smith1953`.

Configuration options (ObsFilters):
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

:code:`Background Check`: not currently well configured.  More detail to follow.

Examples of yaml:
^^^^^^^^^^^^^^^^^
:code:`ufo/test/testinput/gnssrobendmetoffice.yaml`

.. code-block:: yaml

  - obs operator:
      name: GnssroBendMetOffice
      obs options:
        vert_interp_ops: true
        pseudo_ops: true
        min_temp_grad: 1.0e-6
        no super-refraction check: false
        dry_refractivity_constant: 0.776
        wet_refractivity_constant: 3730
    obs space:
      name: GnssroBnd
      obsdatain:
        engine:
          type: H5File
          obsfile: Data/ioda/testinput_tier_1/gnssro_obs_2019050700_1obs.nc4
      simulated variables: [bendingAngle]
    geovals:
      filename: Data/gnssro_geoval_2019050700_1obs.nc4
    obs filters:
    - filter: Background Check
      filter variables:
      - name: bendingAngle
      threshold: 3.0
    norm ref: MetOfficeHofX
    tolerance: 1.0e-5

References:
^^^^^^^^^^^

The scientific configuration of this operator has been documented in a number of
publications:

*  Buontempo C, Jupp A, Rennie M, 2008. Operational NWP assimilation of GPS
   radio occultation data, *Atmospheric Science Letters*, **9**: 129--133.
   doi: http://dx.doi.org/10.1002/asl.173

*  Burrows CP, 2014. Accounting for the tangent point drift in the assimilation of
   gpsro data at the Met Office, *Satellite applications technical memo 14*, Met
   Office.

*  Burrows CP, Healy SB, Culverwell ID, 2014. Improving the bias
   characteristics of the ROPP refractivity and bending angle operators,
   *Atmospheric Measurement Techniques*, **7**: 3445--3458.
   doi: http://dx.doi.org/10.5194/amt-7-3445-2014

GNSS RO refractivity (NCEP)
---------------------------

Description:
^^^^^^^^^^^^

A one-dimensional observation operator for calculating the Global
Navigation Satellite System (GNSS) Radio Occultation (RO)
refractivity data, based on the refractivity operator in the NCEP
GSI system. However, this operator is not an operational capability.
Note it is not updated or validated through extensive tests. Please
use this operator with caution.

Configuration options (ObsFilters):
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

* :code:`Domain Check`: a generic filter used to control the maximum height one wants to assimilate RO observation. Suggested value is 30 km for GnssroRefNCEP.

* :code:`ROobserror`: a RO specific filter. Use generic filter class to apply observation error method.  More information on this filter is found in the :ref:`obsFilterErrors`.

  * options: Only :code:`NBAM` (default) is implemented now.

* :code:`Background Check`: can only use the generic one (see the filter documents).

Examples of yaml:
^^^^^^^^^^^^^^^^^

:code:`ufo/test/testinput/gnssroref.yaml`

.. code-block:: yaml

 observations:
   observers:
   - obs space:
       name: GnssroRef
       obsdatain:
         engine:
           type: H5File
           obsfile: Data/ioda/testinput_tier_1/gnssro_obs_2018041500_s.nc4
       simulate variables: [atmosphericRefractivity]
     obs operator:
       name: GnssroRefNCEP
       obs options:
     obs filters:
     - filter: Domain Check
       filter variables:
       - name: [atmosphericRefractivity]
       where:
       - variable:
           name: MetaData/height
         minvalue: 0
         maxvalue: 30000
     - filter: ROobserror
       filter variables:
       - name: atmosphericRefractivity
       errmodel: NCEP
     - filter: Background Check
       filter variables:
       - name: [atmosphericRefractivity]
       threshold: 3

GNSS RO refractivity (Met Office)
---------------------------------

Description:
^^^^^^^^^^^^

A one-dimensional observation operator for calculating the Global
Navigation Satellite System (GNSS) Radio Occultation (RO)
refractivity data, based on the refractivity operator in the Met Office
system. However, this operator is not used operationally, except in the
NRT monitoring system used by the ROM SAF.

Configuration options (ObsFilters):
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

:code:`vert_interp_ops`: if true, then use log(pressure) for vertical interpolation, if false then use exner function for vertical interpolation.

:code:`pseudo_ops`: if true then calculate data on intermediate "pseudo" levels between model levels, to minimise interpolation artifacts.

:code:`min_temp_grad`: The minimum vertical temperature gradient. Default: 1e-6. Any vertical gradients below this threshold will be treated as isothermal.

:code:`dry_refractivity_constant`: Coefficient applied to the dry part of the refractivity equation. Default: 0.776 which is the value from :cite:`Smith1953`.

:code:`wet_refractivity_constant`: Coefficient applied to the wet part of the refractivity equation. Default: 3730 which is the value from :cite:`Smith1953`.

Examples of yaml:
^^^^^^^^^^^^^^^^^

:code:`ufo/test/testinput/gnssrorefmetoffice.yaml`

.. code-block:: yaml

 observations:
   observers:
    - obs operator:
        name: GnssroRefMetOffice
        vert_interp_ops: true
        pseudo_ops: true
        min_temp_grad: 1.0e-6
        dry_refractivity_constant: 0.776
        wet_refractivity_constant: 3730
      obs space:
        name: GnssroRef
        obsdatain:
          engine:
            type: H5File
            obsfile: Data/ufo/testinput_tier_1/gnssro_obs_2019123006_refractivity.nc4
        simulated variables: [atmosphericRefractivity]
        obsdataout:
          engine:
            type: H5File
            obsfile: Data/gnssro_obs_2019123006_refractivity_k1_ukmo_opr_out.nc4
      geovals:
        filename: Data/ufo/testinput_tier_1/gnssro_geoval_2019123006_refractivity.nc4
      norm ref: MetOfficeHofX
      tolerance: 1.0e-5
      linear obs operator test:
        coef TL: 1.0e-4
        iterations TL:  10
        tolerance TL: 1.0e-14
        tolerance AD: 1.0e-13

Ground Based GNSS observation operator (Met Office)
---------------------------------------------------

The JEDI UFO interface of the Met Office's observation operator for Ground based GNSS Zenith Total Delay (ZTD).
ZTD is the equivalent extra path that a radio signal from a Global Navigation Satellite System satellite travels from vertically overhead to a station on the ground due to the presence of the atmosphere compared to that same path through a vacuum.
The ZTD may be expressed as

.. math::
   ZTD=10^{-6}\int_{z=0}^{z=\infty}{N dz}

Where :math:`z` is the height above the surface and :math:`N` is the refractivity, given by

.. math::
  N=\frac{aP}{T}+\frac{be^2}{T^2}

Where :math:`P` is pressure, :math:`e` is water vapour pressure, :math:`T` is temperature and :math:`a` and :math:`b` are the dry and wet refractivity constants respectively, given by 0.776 KPa\ :sup:`-1` and 3.73x10\ :sup:`3` K\ :sup:`2` Pa\ :sup:`-1`. ZTD can be considered to be constructed from two delay components; Zenith Wet Delay (ZWD), due to the dipole moment of water and Zenith Hydrostatic Delay (ZHD) due to the dry atmosphere.

The Met Office Ground Based GNSS observation operator makes use of a generic refractivity calculator and for the tangent linear and adjoint it calculates the ZTD gradient with respect to both the pressure and specific humidity.

Model inputs for the forward operator are specific humidity, pressure, geopotential heights of air_pressure/full levels/theta and geopotential heights of air_pressure_levels/half levels/rho.

Configuration options (ObsFilters):
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
These configurations are generic to using the refractivity calculator, which the Ground Based GNSS operator utilises.
The operator requires these values to be set to the default values to work correctly, therefore, these configuration options do not need to be written out in the YAML when calling this operator.

:code:`vert_interp_ops`:
  If true, then perform vertical interpolation of pressure from half levels to full levels using ln(p), otherwise
  use exner (air_pressure levels pressure) (default: true).
:code:`pseudo_ops`:
  If true, use pseudo-levels to improve the accuracy of the refractivity
  calculation (default: false).
:code:`min_temp_grad`:
  Minimum value of the vertical temperature gradient when checking for isothermal
  levels in the pseudo-level calculation (default: 1e-6).
:code:`dry_refractivity_constant`:
  Coefficient applied to the dry part of the refractivity equation. Default: 0.776 which is the value from :cite:`Smith1953`.
:code:`wet_refractivity_constant`:
  Coefficient applied to the wet part of the refractivity equation. Default: 3730 which is the value from :cite:`Smith1953`.

Examples of yaml:
^^^^^^^^^^^^^^^^^
:code:`ufo/test/testinput/groundgnssmetoffice.yaml`

.. code-block:: yaml

  - obs operator:
      name: GroundgnssMetOffice
      min_temp_grad: 1.0e-6
      dry_refractivity_constant: 0.776
      wet_refractivity_constant: 3730
    obs space:
      name: Groundgnss
      obsdatain:
        engine:
          type: H5File
          obsfile: Data/ufo/testinput_tier_1/groundgnss_obs_2019123006_obs.nc
      simulated variables: [zenithTotalDelay]
    geovals:
      filename: Data/ufo/testinput_tier_1/groundgnss_geovals_20191230T0600Z.nc4

Details of how the operator works
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


Below, the method for calculating ZTD using the refractivity calculator, the partial derivatives at each calculation, and the ZTD gradient with respect to pressure and humidity is described.
Both pressure and humidity signals can be identified in the ZTD and so the gradient for the tangent linear and adjoint (TL/AD) are calculated with respect to both pressure and specific humidity.

The operator works in the direction of surface to the model top.

In this operator, we assume ln(pressure) is linear with height and therefore :code:`vert_interp_ops` needs to be true (default), and use this assumption to interpolate pressure on rho levels :math:`P_{\rho}` (air_pressure_levels/half levels) to pressure on theta levels :math:`P_{\theta}` (air_pressure/full levels), such that:

.. math::
  P_{\theta}=e^{((z_{weight})lnP_{\rho_{i}}+(1-z_{weight})lnP_{\rho_{i+1}} )}

Where

.. math::
  z_{weight} =\frac{z_{\rho_{i+1}}-z_{\theta_{i}}}{z_{\rho_{i+1}}-z_{\rho_{i}}},

with :math:`z_{\rho}` being the geopotential height of the rho levels and :math:`z_{\theta}` being the geopotential height of the theta levels.
Pressure on theta and rho levels, together with specific humidity on theta levels is then passed to the generic refractivity calculator, which calculates refractivity on theta levels. The partial derivative of the pressure on theta with regards to pressure on rho levels is required for the refractivity derivatives used in the ZTD TL/AD, and is

.. math::
  \frac{\partial P_{\theta_{i}}}{\partial P_{\rho_{i}}}=\frac{P_{\theta_{i}} z_{weight}}{P_{\rho_{i}}}

And for the ZTD above the model top we require

.. math::
  \frac{\partial P_{\theta_{i}}}{\partial P_{\rho_{i+1}}}=\frac{P_{\theta_{i}} (1-z_{weight})}{P_{\rho_{i+1}}}

The operator then loops through the theta levels, starting with the theta level directly above the station height, calculating the delay contribution for each layer bounded by the theta levels, assuming the refractivity decays exponentially between the model levels.

.. math::
  N_{i+1}=N_{i} e^{-c(z_{i+1}-z_{i})}

Where :math:`c` is the scale height such that

.. math::
  c_{i}=\frac{lnN_{i+1}-lnN_{i}}{z_{i}-z_{i+1}}

.. math::
  \frac{\partial c_{i}}{\partial N_{i} }=\frac{-1}{N_{i} (z_{i}-z_{i+1})}

.. math::
  \frac{\partial c_{i}}{\partial N_{i+1}}=\frac{1}{N_{i+1}(z_{i}-z_{i+1})}


Delay for layer :math:`i` is then

.. math::
  ZTD_{i}=-10^{-6} \frac{N_{i}}{c_{i}} e^{c_{i} z_{i}} (e^{-c_{i} z_{i+1}}-e^{-c_{i} z_{i}})

.. math::
  \frac{\partial ZTD_{i}}{\partial c_{i}} =-10^{-6} \frac{N_{i}}{c_{i}}  (\frac{1}{c_{i}} +e^{c_{i} (z_{i}-z_{i+1})} (z_{i}-z_{i+1}-\frac{1}{c_{i}} ))

.. math::
  \frac{\partial ZTD_{i}}{\partial N_{i}}=\frac{-10^{-6}}{c_{i}}  e^{c_{i} z_{i} } (e^{-c_{i} z_{i+1} }-e^{-c_{i} z_{i} })

The delay for each layer is added to the running total delay.
The operator iterates up to the highest theta level, calculating the delay up to that point.
A further small correction must be made for the signal above the model top. An assumption of hydrostatic equilibrium is used to calculate the integral

.. math::
   ZTD_{top}=10^{-6}\int_{z=z_{modeltop}}^{z=\infty}{\frac{aP}{T}}dz

which then gives the delay above the model top as

.. math::
  ZTD_{top}=\frac{10^{-6} aR}{g} P_{\theta_{top}}

where :math:`R` is the gas constant and :math:`g` is the gravitational acceleration.

:math:`ZTD_{top}` is then added to the accumulated ZTD. Therefore the partial differentials with respect to specific humidity :math:`q` and pressure at the top of the model levels (note for rho levels, :math:`\rho_{top}` is one level above :math:`\theta_{top}`) are

.. math::
  \frac{\partial {ZTD_{top}}}{\partial {q_{\theta_{top}}}}=0.0

.. math::
  \frac{\partial{ZTD_{top}}}{\partial P_{\rho_{top}}}=0.0

.. math::
  \frac{\partial ZTD_{top}}{\partial P_{\theta_{top}}} =\frac{10^{-6} aR}{g}


At the model bottom (see GBGNSS figure 1), if the station height is below the model bottom, the scale height from the first model layer is used, and the height of the station is used in the Zenith delay calculation such that

.. math::
  ZTD_{1}=-10^{-6}  \frac{N_{1}}{c_{1}}  e^{c_{1} z_{1} } (e^{-c_{1} z_{2} }-e^{-c_{1} z_{station} })

and

.. math::
  \frac{dZTD_{1}}{dN_{1}}=\frac{\partial ZTD_{1}}{\partial N_{1}}+\frac{\partial ZTD_{1}}{\partial c_{1}}  \frac{\partial c_{1}}{\partial N_{1}}

If the station lies above the lowest model level, the refractivity is interpolated exponentially to the station height (see GBGNSS figure 2) from level :math:`i`, the scale height is that for the whole model layer i.e. :math:`z_{i}` to :math:`z_{i+1}`, and Zenith delay is calculated from the station height such that

.. math::
  ZTD_{station}=-10^{-6} \frac{N_{station}}{c_{i}} e^{c_{i} z_{station}} (e^{-c_{i} z_{i+1} }-e^{-c_{i} z_{station}})

and

.. math::
  \frac{dZTD_{i}}{dN_{i}}=\frac{\partial ZTD_{station}}{\partial N_{station}} \frac{\partial N_{station}}{\partial N_{i}}+\frac{\partial ZTD_{station}}{\partial c_{i}} \frac{\partial c_{i}}{\partial N_{i}}

Where

.. math::
  \frac{\partial ZTD_{station}}{\partial c_{i}}=\frac{\partial ZTD_{station}}{\partial c_{i}}+\frac{\partial ZTD_{station}}{\partial N_{station}}  \frac{\partial N_{station}}{\partial c_{i}}

And

.. math::
  \frac{\partial N_{station}}{\partial c_{i}}=-N_{station} (z_{station}-z_{i+1})

Using the above partial differentials, and using the partial differential of refractivity with respect to pressure and specific humidity, the differential of ZTD with respect to input pressure and humidity on the rest of the levels can be found through:

.. math::
  \frac{dZTD_{i}}{dN_{i}}=\frac{\partial ZTD_{i}}{\partial N_{i}}+\frac{\partial ZTD_{i}}{\partial c_{i}}  \frac{\partial c_{i}}{\partial N_{i}} +\frac{\partial ZTD_{i}}{\partial c_{i-1}}  \frac{\partial c_{i-1}}{\partial N_{i}}

.. math::
  \frac{dZTD_{i}}{dP_{\rho_{i}}}=\frac{\partial ZTD_{i}}{\partial N_{i}}  \frac{\partial N_{i}}{\partial P_{\rho_{i}}}

.. math::
  \frac{dZTD_{i}}{dq_{\theta_{i}}}=\frac{\partial ZTD_{i}}{\partial N_{i}}  \frac{\partial N_{i}}{\partial q_{\theta_{i}}}

.. image:: images/GNSS_Station_height_below_model_surface.png
           :alt: A diagram for stations below model levels

GBGNSS Figure 1: Diagram of the model levels with the station height lying below the lowest model level.

.. image:: images/GNSS_Station_height_between_levels.png
           :alt: A diagram for stations between levels

GBGNSS Figure 2: Diagram of the model levels with the station height lying between two model levels.

.. _obsops_identity:

Identity observation operator
-----------------------------------

Description:
^^^^^^^^^^^^

A simple identity observation operator, applicable whenever only horizontal interpolation of model variables is required.

This operator can be used as a component of the :ref:`Composite <obsops_composite>` operator.

Configuration options:
^^^^^^^^^^^^^^^^^^^^^^

* :code:`variables` [optional]: a list of names of ObsSpace variables to be simulated by this operator (see the example below). This option should only be set if this operator is used as a component of the `Composite` operator. If it is not set, the operator will simulate all ObsSpace variables.

* :code:`level index 0 is closest to surface`: a boolean variable that specifies whether index 0 of a model column is closest to the Earth's surface. Default value: :code:`false`.

Examples of yaml:
^^^^^^^^^^^^^^^^^

.. code-block:: yaml

   obs operator:
     name: Identity

In the example above, the `Identity` operator is used to simulate all ObsSpace variables.

.. code-block:: yaml

  obs operator:
    name: Composite
    components:
    - name: VertInterp
      variables:
      - name: windEastward
      - name: windNorthward
    - name: Identity
      variables:
      - name: stationPressure

In the example above, the `Identity` operator is used to simulate only the surface pressure; the wind components are simulated using the `VertInterp` operator.

Product observation operator
----------------------------

Description:
^^^^^^^^^^^^

A simple observation operator based on the identity operator that allows scaling by another variable. The operator performs :math:`H(x) = x * a` where `x` is a variable at the lowest model level and `a` is some other customizable scaling variable that is two dimensional. The scaling variable may optionally be raised to a power.

Configuration options:
^^^^^^^^^^^^^^^^^^^^^^

* :code:`variables` [optional]: a list of names of ObsSpace variables to be simulated by this operator. This option should only be set if this operator is used as a component of the `Composite` operator. If it is not set, the operator will simulate all ObsSpace variables.

* :code:`geovals to act on` [optional]: name of the variable to apply H(x) to. If not specified, the operator assumes the same variable as the simulated variable. Note, if this is set then currently only one simulated variable may be specified.

* :code:`geovals to scale hofx by`: name of the variable (usually GeoVaLs) to multiply the simulated variable by.

* :code:`group of geovals to scale hofx by`: name of the group that the variable to multiply the simulated variable by belongs to.

* :code:`geovals exponent` [optional]: option to raise the scaling GeoVaL to a power.


Examples of yaml:
^^^^^^^^^^^^^^^^^

.. code-block:: yaml

  obs operator:
    name: Product
    geovals to scale hofx by: a

In the example above H(x) will be calculated as :math:`H(x) = x * a` where x is the simulated variable.

.. code-block:: yaml

  obs operator:
    name: Product
    geovals to scale hofx by: SurfaceWindScalingCombined
    group of geovals to scale hofx by: DerivedVariables

In the example above H(x) is scaled by a custom varable belonging to a group other than the GeoVaLs.

.. code-block:: yaml

  obs operator:
    name: Product
    geovals to act on: x
    geovals to scale hofx by: a
    geovals exponent: -0.5

In the example above H(x) would be calculated as :math:`H(x) = \frac{x}{\sqrt{a}}`  Here x need not be the same as the simulated variable.


Logarithm observation operator
------------------------------

Description:
^^^^^^^^^^^^

A simple observation operator that allows the logarithm of a variable, with a chosen base, to be calculated. If acting on a model column with more than one level, this operator selects the model level closest to the Earth's surface.

The operator performs :math:`H(x) = \log_n(x)` where :math:`x` is the variable at the lowest model level and :math:`n` is the base.

If this operator encounters values which are less than or equal to zero, the output is set to missing.
Invalid bases (zero, one or negative numbers) will produce an error.

This operator can be used as a component of the :ref:`Composite <obsops_composite>` operator.

Configuration options:
^^^^^^^^^^^^^^^^^^^^^^

* :code:`variables` [optional]: a list of names of ObsSpace variables to be simulated by this operator. This option should only be set if this operator is used as a component of the `Composite` operator. If it is not set, the operator will simulate all ObsSpace variables.

* :code:`base` [optional]: the base of the logarithm. Default value: e (natural logarithm).

Examples of yaml:
^^^^^^^^^^^^^^^^^

.. code-block:: yaml

  obs operator:
    name: Logarithm

In the example above H(x) will be calculated as :math:`H(x) = \ln(x)` where :math:`x` is the simulated variable and :math:`\ln` is the natural logarithm.

.. code-block:: yaml

  obs operator:
    name: Logarithm
    base: 2

In the example above H(x) will be calculated as :math:`H(x) = \log_2(x)` where :math:`x` is the simulated variable.

.. code-block:: yaml

  obs operator:
    name: Composite
    components:
    - name: Logarithm
      variables:
      - name: horizontalVisibility
      base: 10
    - name: VertInterp
      variables:
      - name: windEastward
      - name: windNorthward

In the example above, the :code:`Logarithm` operator is applied to the horizontal visibility variable with base 10; the :code:`VertInterp` operator is applied to the wind components.

Generic particulate matter (PM) operator
----------------------------------------

This operator performs a simple vertical interpolation from PM geovals using the :code:`VertInterp` operator. Those geovals can be extracted directly from model outputs or from vader transforms to obtain PM values. See the vader documentation.

Examples of yaml:
^^^^^^^^^^^^^^^^^

.. code-block:: yaml

  obs operator:
    name: VertInterp
    observation alias file: test/testinput/obsop_name_map.yaml
    vertical coordinate: height
    observation vertical coordinate: height
    observation vertical coordinate group: MetaData

Alias obsop_name_map.yaml

.. code-block:: yaml

  - name: particulatematter2p5Surface
    alias: mass_density_of_particulate_matter_2p5_in_air

CMAQ particulate matter (PM) operator (**deprecated**)
------------------------------------------------------

Warning:
^^^^^^^^

**This operator is model specific and is breaking the UFO paradigm of model genericity. An alternative has been implemented using variable transform using Vader capabilities. Please refer to this the Vader part of the documentation for more details. This operator will be removed from the JEDI code at some point.**

Description:
^^^^^^^^^^^^

This operator calculates modeled particulate matter (PM) at monitoring stations, such as the U.S. AirNow sites that provide PM2.5 & PM10 data. With few/no code changes, it can also be applied to calculate total or/and speciated PM for applications related to other networks/datasets.

Unit conversion is included in the calculations.

The users are allowed to select a vertical interpolation approach to: 1) match model height (above sea level, asl = height above ground level + surface height) to station elevation (also asl) which is required for the AirNow application; or 2) match model log(pressure) to observation log(pressure), likely suitable for use with other types of observational datasets that contain pressure information, e.g. aircraft, sonde, tower...

Currently this tool mainly supports the calculation from the NOAA FV3-CMAQ aerosol fields (user-defined, up to 70 individual species). Based on the user definition, the calculation can involve the usage of the model-based scaling factors for three modes of Aitken, accumulation, and coarse.

Configuration options:
^^^^^^^^^^^^^^^^^^^^^^

* :code:`simulated variables`: variables to be simulated, total or speciated PM. [Note: This operator currently works well with one "simulated variable", e.g., PM25 or total PM. With slight modifications it can be used to simulate multiple speciated PM variables]
* :code:`vertical_coordinate`: character, vertical interpolation approach chosen. As described above, height_asl (default) and log_pressure are currently supported. If neither option is chosen, the application will stop with an error msg.
* :code:`model` [required]: character, model name. This operator currently mainly supports CMAQ. If the model name is not CMAQ, the application will stop with an error msg.
* :code:`tracer_geovals` [required]: character, a list of names of model aerosol species needed to calculate the "simulated variables"
* :code:`use_scalefac_cmaq`: logical, false by default, indicating whether scaling factors will be applied to execute PM2.5 or total PM related steps
* :code:`tracer_modes_cmaq` [optional]: a list of integers indicating CMAQ aerosol modes (1-Aitken; 2-accumulation; 3-coarse). This option should only be set if the model name is CMAQ and "use_scalefac_cmaq" is set to "true". The sizes of tracer_modes_cmaq and tracer_geovals must be consistent.

Examples of yaml:
^^^^^^^^^^^^^^^^^

.. code-block:: yaml

    simulated variables: [pm25]
  obs operator:
    name: InsituPM
    tracer_geovals: [aso4i,ano3i,anh4i,anai,acli,aeci,aothri,alvpo1i,asvpo1i,asvpo2i,alvoo1i,alvoo2i,asvoo1i,asvoo2i,
                        aso4j,ano3j,anh4j,anaj,aclj,aecj,aothrj,afej,asij,atij,acaj,amgj,amnj,aalj,akj,
                        alvpo1j,asvpo1j,asvpo2j,asvpo3j,aivpo1j,axyl1j,axyl2j,axyl3j,atol1j,atol2j,atol3j,
                        abnz1j,abnz2j,abnz3j,aiso1j,aiso2j,aiso3j,atrp1j,atrp2j,asqtj,aalk1j,aalk2j,apah1j,
                        apah2j,apah3j,aorgcj,aolgbj,aolgaj,alvoo1j,alvoo2j,asvoo1j,asvoo2j,asvoo3j,apcsoj,
                        aso4k,asoil,acors,aseacat,aclk,ano3k,anh4k]
    vertical_coordinate: height_asl
    model: CMAQ
    use_scalefac_cmaq: true
    tracer_modes_cmaq: [1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,
                        2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,3,3,3,3,3,3,3]

In the example above, this `InsituPM` operator calculates modeled (CMAQ) PM2.5 at selected U.S. AirNow monitoring stations. This calculation is based on 70 CMAQ aerosol species (defined in "tracer_geovals") in three modes (defined in "tracer_modes_cmaq"), with mode-specific scaling factors applied (use_scalefac_cmaq: true). Vertical interpolation is conducted to match the model height (asl) with the monitoring station elevation (vertical_coordinate: height_asl).

Radar Radial Velocity
--------------------------

Description:
^^^^^^^^^^^^

Similar to RadarReflectivity, but for radial velocity. It is tested with radar observations dumped from a specific modified GSI program at NSSL for the Warn-on-Forecast project.

Examples of yaml:
^^^^^^^^^^^^^^^^^

.. code-block:: yaml

  observations:
    observers:
    - obs operator:
        name: RadarRadialVelocity
      obs space:
        name: Radar
        obsdatain:
          engine:
            type: H5File
            obsfile: Data/radar_rw_obs_2019052222.nc4
        simulated variables: [radialVelocity]

Radar Doppler wind
------------------

Description
^^^^^^^^^^^

This operator computes the model equivalent of radial velocity [m/s] for Doppler radar observations.

The following variables must be present in the obs space prior to running this operator:

* :code:`MetaData/sinTilt`
* :code:`MetaData/cosAzimuthCosTilt`
* :code:`MetaData/sinAzimuthCosTilt`
* :code:`MetaData/height`

These variables can be produced with the :code:`RadarBeamGeometry` Variable Transform filter.
Tilt is the angle [deg] of the radar beam relative to the horizontal, and
and azimuth [deg] is the angle of the radar beam measured clockwise relative to true North.

It is mandatory to specify the names of the model vertical coordinates associated with both
horizontal (u, v) and vertical (w) wind speeds. That will ensure the correct vertical
interpolation is performed.

This operator shares functionality with the :code:`RadarRadialVelocity` operator, but is implemented entirely in C++.

Configuration options
^^^^^^^^^^^^^^^^^^^^^

:code:`vertical coordinate for horizontal wind`: (required, string) model vertical coordinate associated with horizontal winds.
:code:`vertical coordinate for vertical wind`: (required, string) model vertical coordinate associated with vertical wind.

Example
^^^^^^^

.. code-block:: yaml

 obs operator:
   name: RadarDopplerWind
   vertical coordinate for horizontal wind: height_levels
   vertical coordinate for vertical wind: height

Radar Reflectivity
------------------

This operator computes the model equivalent of radar reflectivity.
The :code:`algorithm.name` parameter controls which algorithm is used to perform the calculation.
Each algorithm can implement its own set of parameters.

An example yaml configuration that uses an algorithm called :code:`abc` is as follows:

.. code-block:: yaml

  - obs operator:
      name: RadarReflectivity
      algorithm:
        name: abc

To create a new algorithm, the user must create a subclass of
:code:`ReflectivityAlgorithmBase` (and, if there are to be configurable parameters,
a subclass of :code:`ReflectivityAlgorithmParametersBase` to hold them).
See the header file of :code:`ReflectivityAlgorithmBase` for further details.

This operator can be used as part of the :code:`Composite` operator.


Met Office reflectivity
^^^^^^^^^^^^^^^^^^^^^^^

This algorithm computes the model equivalent of radar reflectivity accounting for contributions from both rain and ice.
There are several semi-empirical parameters that control the relationship between the model mixing ratios and the reflectivity.
These parameters are tuned for specific combinations of radar sites and NWP models.

At the Met Office, reflectivity has units :math:`\text{mm}^{6} \text{m}^{-3}`. Prior to assimilation the square root of (reflectivity + :math:`k`)
is computed, where :math:`k` is usually equal to 1. This avoids an infinite derivative in the tangent linear operator.
The units of the square-root reflectivity for :math:`k = 1` are :math:`\sqrt{\text{mm}^{6}\text{m}^{-3} + 1}`.

To compute H(x), model values of pressure (:math:`p`), temperature (:math:`T`), rain mixing ratio (:math:`q_{\text{rain}}`) and ice mixing ratio (:math:`q_{\text{ice}}`)
are interpolated vertically to the observation location. The air density :math:`\rho` is computed from :math:`p` and :math:`T`.

The contribution of rain to the reflectivity is calculated as:

.. math::

  Z_R = \begin{cases} A (\rho q_{\text{rain}})^B & q_{\text{rain}} > 0, \\
                      0                          & q_{\text{rain}} = 0.
        \end{cases}

where :math:`A` corresponds to the parameter :code:`rain multiplier` and
:math:`B` corresponds to the parameter :code:`rain exponent`.

The equivalent contribution from ice is:

.. math::

  Z_I = \begin{cases} 10^{C T_\text{C} + D} (\rho q_{\text{ice}})^E & q_{\text{ice}} > 0, \\
                      0                                             & q_{\text{ice}} = 0.
        \end{cases}.

where :math:`C` corresponds to the parameter :code:`ice multiplier`,
:math:`D` corresponds to the parameter :code:`ice additive constant` and
:math:`E` corresponds to the parameter :code:`ice exponent`.
The quantity :math:`T_\text{C}` is the temperature expressed in degrees C.

Finally, the square-root reflectivity is calculated as

.. math::

   Z = \sqrt{Z_R + Z_I + k}.

where :math:`k` is a constant, corresponding to the parameter :code:`lower bound` and usually equal to 1.

It is possible to use the tangent linear and adjoint version of this operator in an assimilation,
but that is discouraged due to the high nonlinearity present.

An example usage of the algorithm is as follows:

.. code-block:: yaml

  - obs operator:
      name: RadarReflectivity
      algorithm:
        name: Met Office reflectivity
        rain multiplier: 1000.0
        rain exponent: 1.1
        ice multiplier: 0.1
        ice additive constant: 2.0
        ice exponent: 2.0
        lower bound: 1.0



Scatterometer neutral wind (Met Office)
---------------------------------------

Description:
^^^^^^^^^^^^
Met Office observation operator for treating scatterometer wind data
as a "neutral" 10m wind, i.e. where the effects of atmospheric stability are neglected.
For each observation we calculate the momentum roughness length using the Charnock relation.
We then calculate the Monin-Obukhov stability function for momentum, integrated to the model's lowest wind level.
The calculations are dependant upon on whether we have stable or unstable conditions
according to the Obukhov Length. The neutral 10m wind components are then calculated
from the lowest model level winds.

Configuration options:
^^^^^^^^^^^^^^^^^^^^^^

* :code:`surface_type_check`: logical, true by default, indicating whether to check if the surface type is sea before calculating H(x).
* :code:`surface_type_sea`: integer, 0 by default, the value of surfaceQualifier used to denote sea in the surface type check.

Examples of yaml:
^^^^^^^^^^^^^^^^^
.. code-block:: yaml

  observations:
    observers:
    - obs operator:
        name: ScatwindNeutralMetOffice
      obs space:
        name: Scatwind
        obsdatain:
          engine:
            type: H5File
            obsfile: Data/ioda/testinput_tier_1/scatwind_obs_1d_2020100106.nc4
        obsdataout:
          engine:
            type: H5File
            obsfile: Data/scatwind_obs_1d_2020100106_opr_test_out.nc4
        simulated variables: [windEastward, windNorthward]
      geovals:
        filename: Data/ufo/testinput_tier_1/scatwind_geoval_20201001T0600Z.nc4
      vector ref: MetOfficeHofX
      tolerance: 1.0e-05

References:
^^^^^^^^^^^^^^^^^^^^^^
Cotton, J., 2018. Update on surface wind activities at the Met Office.
Proceedings for the 14 th International Winds Workshop, 23-27 April 2018, Jeju City, South Korea.
Available from http://cimss.ssec.wisc.edu/iwwg/iww14/program/index.html.

.. _obsops_sfc_corrected:

SfcCorrected
---------------------------------------

Description:
^^^^^^^^^^^^
This forward operator contains three schemes (WRFDA, UKMO, GSL) to correct the computation of surface variables (2m air temperature, station pressure) caused by the discrepancy of model topography at observed locations.

To note:
* Currently the 2m temperature using the WRFDA and UKMO method and station pressure for all schemes of forward operators are the ones implemented. Surface correction for Humidity is not implemented.
* The `Non-linear` operators can be used in simulation of OBS only.
* The `Linear` operators have not been implemented. Until TL/AD is available, must specify Identity Obs Operator in assimilation.

The unified SfcCorrected operator is an initial framework to apply a consistent model terrain height discrepancy correction for many of surface observation types.

Configuration options:
^^^^^^^^^^^^^^^^^^^^^^
* variable - list of variables to be simulated which must be a subset of the simulated variables in the ObsSpace.
* geovar_geomz - model variable for height of vertical levels. Geopotential heights will be converted to height above mean sea level.
* geovar_sfc_geomz - model variable for surface height. Geopotential heights will be converted to height above mean sea level.
* station_altitude - variable in the ObsSpace which will be used for the staion height of the observation.
* correction shceme to use - the scheme to use to correct the variable.  Currently available are 'WRFDA', 'UKMO' and 'GSL'.

Example of surface air temperature correction yaml:
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
.. code-block:: yaml

  observations:
  - obs operator:
    name: SfcCorrected
    correction scheme to use: UKMO
    geovar_sfc_geomz: geopotential_height_at_surface
    geovar_geomz: geopotential_height
  obs space:
    name: Surface operator 2M temperature UKMO method with geopotential values
    obsdatain:
      engine:
        type: H5File
        obsfile: Data/ufo/testinput_tier_1/surface_tquv_obs_2022052700.nc4
    simulated variables: [airTemperatureAt2M]
  geovals:
    filename: Data/ufo/testinput_tier_1/surface_tquv_geovals_2022052700.nc4
  rms ref: 290.1876
  tolerance: 1.e-5

Example of surface pressure correction yaml:
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
.. code-block:: yaml

  observations:
  - obs operator:
    name: SfcCorrected
    correction scheme to use: WRFDA
  obs space:
    name: Surface operator station pressure WRFDA method
    obsdatain:
      engine:
        type: H5File
        obsfile: Data/ufo/testinput_tier_1/sfc_obs_2018041500_m.nc4
    simulated variables: [stationPressure]
  geovals:
    filename: Data/ufo/testinput_tier_1/ps_geovals_2018041500_0000.nc4
  rms ref: 98240.77327572
  tolerance: 1.e-08
  linear obs operator test:
    coef TL: 0.1
    tolerance TL: 1.0e-13
    tolerance AD: 1.0e-11

Algorithmic Description:
^^^^^^^^^^^^^^^^^^^^^^^^
The surface corrector operator, based on the correction scheme selected, performs simulation for station pressure as described below.

Schemes:

:code:`GSI`: If there is observed temperature along with pressure, take the average of the model simulated and observed near surface temperature, otherwise use just the model simulated temperature (and extrapolate to the surface using 6.5K/km
lapse rate if the ob height is below the model lowest layer).  Then the pressure output from this option is the model (background) surface pressure corrected from model surface to observation height as such:

.. math::
  H(x) = exp(log(Ps_{model}) - ((Zs_{ob} - Zs_{model}) * (gravity * Rd) / Tv_{avg}))

where `Rd` is 287.05 J/kg/K, `Ps` and `Zs` are the surface pressure and height, and
`Tv_avg` is the averged virtual temperature of the model surface virtual temperature (`Tv_model`) and observed (virtual) temperature as such:

.. math::
  Tv_{avg} = (Tv_{model} + Tv_{ob})/2.0

if the surface obervation has virtual temperature value (`Tv_ob`). Otherwise

.. math::
  Tv_{avg} = (Tv_{model} + T_{ob})/2.0

:code:`UKMO`: If the observed surface height and pressure are not missing, the pressure output from this option is the corrected
model pressure as such:

.. math::
  H(x) = Ps_{model}+(Ps_{ob}-Ps_{o2m})

where `Ps_model` and `Ps_ob` are the model and observed surface
pressure, and `Ps_o2m` is the observed pressure adjusted to the model surface height.
`Ps_o2m` is computed based on the method descried in UKMO Technical Report No.582, Appendix 1, by B. Ingleby (2013) as such:

.. math::
  Ps_{o2m} = Ps_{ob} * (Ps_{model}/Ps_{m2o})

`Ps_m2o` is the model(background) surface pressure adjusted to observed station height as such:

.. math::
  Ps_{m2o} = Ps_{model} * (T_{m2o}/T_{model})** (gravity / Rd * L)

where `L` is the constant lapse rate (0.0065 K/m),
`T_model` is the temperature at model surface height (`H_model`), derived from the virtual temperature at 2000m above the model surface height (Tv_2000) to avoid diurnal/local variations, and `T_m2o` is the model temperature at observed station height (`H_ob`) as such:

.. math::
  T_{model} = TV_{2000} * (Ps_{model} / P_{2000}) ** (Rd * L / gravity)

.. math::
  T_{m2o} = T_{model} + L*(H_{model} - H_{ob})


:code:`WRFDA`: If the observed surface height and pressure are not missing, the pressure output from this option is the corrected
model pressure as such:

.. math::
  H(x) = Ps_{model}+(Ps_{obs}-Ps_{o2m})

where `Ps_o2m` is the observed pressure adjusted from station height to model surface height as such

.. math::
  Ps_{o2m} = Ps_{ob} * exp(- (H_{model} - H_{ob}) * gravity / (Rd * Tv_{avg}))

where `Tv_avg` is the averged virtual temperature of the model surface virtual temperature (`Tv_model`) and observed (virtual) temperature as such:

.. math::
   Tv_{avg} = (Tv_{model} + Tv_{ob})/2.0


where the observed virtual temperature value is computed from the observed temperature and humidity, or using the observed
temperature or model temperature if there are missing values for any observed quantities.

When both observed temperature `T_{ob}` and observed humidity `Q_{ob}` have non-missing values then the observed virtual temperature `Tv_{ob}` is calculated as such:

.. math::
   q = std::max(1e-12 or Q_{ob}/(1.0-Q_{ob}))
   Tv_{ob} = T_{ob} * (1.0 + (t2tv * q));


where `t2tv=0.608` is the constant factor used in conversion defined in ufo/utils/Constants.h.

Background Error Vertical Interpolation
---------------------------------------

This operator calculates ObsDiagnostics representing vertically interpolated
background errors of the simulated variables.

It should be used as a component of the :ref:`Composite <obsops_composite>` observation operator (with another
component handling the calculation of model equivalents of observations). It populates all
requested ObsDiagnostics called :code:`<var>_background_error`, where :code:`<var>` is the name of a
simulated variable, by vertically interpolating the :code:`<var>_background_error` GeoVaL at the
observation locations. Element (i, j) of this GeoVaL is interpreted as the background error
estimate of variable :code:`<var>` at the ith observation location and the vertical position read from
the (i, j)th element of the GeoVaL specified in the :code:`interpolation level` option of the
operator.

Configuration options
^^^^^^^^^^^^^^^^^^^^^

* :code:`vertical coordinate`: name of the GeoVaL storing the interpolation levels of background
  errors.
* :code:`observation vertical coordinate`: name of the ufo variable (from the `MetaData` group)
  storing the vertical coordinate of observation locations.
* :code:`variables` [optional]: simulated variables whose background errors may be calculated by
  this operator. If not specified, defaults to the list of all simulated variables in the ObsSpace.

Optionally the resulting error can be scaled by another variable from the GeoVaLs or ObsSpace. This is achieved using two configuration keys:

* :code:`error scaling field` [optional]: The group providing the scaling field. Can be `GeoVaLs`.
* :code:`error scaling field group` [optional]: The name of the field used for scaling.

If either the existing error or the scaling factor are missing at a given location, the scaled output at that location will also be missing.

.. _Background Error Vertical Interpolation Example:

Example
^^^^^^^

.. code-block:: yaml

  obs operator:
    name: Composite
    components:
    # operators used to evaluate H(x)
    - name: VertInterp
      variables:
      - name: airTemperature
      - name: specificHumidity
      - name: windNorthward
      - name: windEastward
    - name: Identity
      variables:
      - name: stationPressure
    # operators used to evaluate background errors
    - name: BackgroundErrorVertInterp
      variables:
      - name: windNorthward
      - name: windEastward
      - name: airTemperature
      - name: specificHumidity
      observation vertical coordinate: pressure
      vertical coordinate: background_error_air_pressure
    - name: BackgroundErrorIdentity
      variables:
      - name: stationPressure

Background Error Identity
-------------------------

This operator calculates ObsDiagnostics representing single-level
background errors of the simulated variables.

It should be used as a component of the :ref:`Composite <obsops_composite>` observation operator (with another
component handling the calculation of model equivalents of observation). It populates all
requested ObsDiagnostics called :code:`<var>_background_error`, where :code:`<var>` is the name of a
simulated variable, by copying the :code:`<var>_background_error` GeoVaL at the observation
locations.

Configuration options
^^^^^^^^^^^^^^^^^^^^^

* :code:`variables` [optional]: simulated variables whose background errors may be calculated by
  this operator. If not specified, defaults to the list of all simulated variables in the ObsSpace.

Example
^^^^^^^

See the listing in the :ref:`Background Error Vertical Interpolation Example` section of the
documentation of the Background Error Vertical Interpolation operator.

Total column water vapour
--------------------------

Description:
^^^^^^^^^^^^

The operator (SatTCWV) to calculate total column water vapour (TCWV) or precipitable water from the
model specific humidity profiles. Clear air is assumed. On input, the operator requires surface
pressure (Pa), and pressure (Pa) and specific humidity (kg/sq.m) for each model layer. The model
levels input should be from the top of the atmosphere going down. Furthermore it is expected that
the model layer pressures and humidities are on staggered levels with respect to each other, i.e.
the humidity values are valid for heights between the pressure levels. This was written for use with
the OLCI total column water vapour product but other possibilities are MODIS, ABI, FCI.


Example of a yaml
^^^^^^^^^^^^^^^^^^

.. code-block:: yaml

  - obs operator:
      name: SatTCWV

..
   Link to the marine ufo

.. include:: marineufo.rst

.. _profileaverageoperator:

Profile Average operator
------------------------

This observation operator produces :math:`H(x)` vectors which correspond to vertically-averaged profiles. The algorithm determines the locations at which reported-level profiles
intersect each model pressure level. The intersections are found by stepping through the observation locations from the lowest-altitude value upwards. For each model level,
the location of the observation whose pressure is larger than, and closest to, the model pressure is recorded. The :code:`vertical coordinate` parameter controls the model pressure GeoVaLs that are used in this procedure. If there are no observations in a model level, which can occur for (e.g.) sondes reporting in low-frequency TAC format, the location corresponding to the last filled level is used. (If there are some model levels closer to the surface than the lowest-altitude observation, the location of the lowest observation is used for these levels.)

This procedure is iterated multiple times in order to account for the fact that model pressures can be slanted close to the Earth's surface. The number of iterations is configured with the :code:`number of intersection iterations` parameter.

Having obtained the profile boundaries, values of model pressure and any simulated variables are obtained as in the locations that were determined in the procedure above.
This produces a single column of model values which are used as the :math:`H(x)` variable.

In order for this operator to work correctly the ObsSpace must have been extended as in the following yaml snippet:


.. code-block:: yaml

  - obs space:
     extension:
       average profiles onto model levels: 71


(where 71 can be replaced by the length of the air_pressure_levels GeoVaL). The :math:`H(x)` values are placed in the extended section of the ObsSpace. Note that, unlike what may be expected for an observation operator, averaging of the model values across each layer is not performed; a single model value is used in each case.

A comparison with results obtained using the Met Office OPS system is performed if the option :code:`compare with OPS` is set to true. This checks values of the locations and pressure values associated with the slant path. All other comparisons are performed with the standard :code:`vector ref` option in the yaml file.

This operator also accepts an optional :code:`variables` parameter, which controls which ObsSpace variables will be simulated. This option should only be set if this operator is used as a component of the Composite operator. If :code:`variables` is not set, the operator will simulate all ObsSpace variables. Please see the documentation of the Composite operator for further details.

An optional :code:`scaling factor` parameter can be used to scale the input simulated variable GeoVaLs :math:`x` when calculating :math:`H(x)`, for example to convert model units to observation units. The default value is :code:`1.0`, which means no scaling is applied.


Configuration options
^^^^^^^^^^^^^^^^^^^^^

- :code:`variables`: List of variables to be used by this operator.

- :code:`model vertical coordinate`: Name of model vertical coordinate.

- :code:`number of intersection iterations`: Number of iterations that are used to find the intersection between the observed profile and each model level. Default: :code:`3`.

- :code:`compare with OPS`: If true, perform comparisons of auxiliary variables with the Met Office OPS system. Default: :code:`false`.

- :code:`pressure coordinate`: Name of air pressure coordinate.

- :code:`pressure group`: Name of air pressure group.

- :code:`scaling factor`: Scaling factor for to apply to input simulated variable GeoVaLs :math:`x` when calculating :math:`H(x)`. Default: :code:`1.0`.


Example
^^^^^^^

.. code-block:: yaml

    # Operator used to calculate H(x) for averaged profiles
    - name: ProfileAverage
      model vertical coordinate: "air_pressure_levels"
      pressure coordinate: pressure
      pressure group: MetaData

Vertical/Slant-path summation/integration Operator
--------------------------------------------------

The :code:`pathsum` operator computes a weighted summation of a GeoVaLs variable along a vertical or slant path:

.. math::

   H(x) = \alpha \sum_{i=1}^{N} v_i w_i

where:

* :math:`H(x)` is the simulated observation.
* :math:`v_i` is the GeoVaL value at point :math:`i`
* :math:`w_i` is the weight associated with point :math:`i`
* :math:`\alpha` is an optional scaling factor. This factor can be used for H(x) unit conversion 

Integration weights may be:

* read from GeoVaLs
* specified directly in YAML
* computed internally using trapezoidal integration

If weights are computed internally, segment lengths (distances between adjacent points along the path) are computed using WGS-84 Earth-Centered Earth-Fixed (ECEF) coordinates, converted from geodetic latitude, longitude and height read from GeoVals.

When the weights correspond to segment lengths, the summation provides a numerical approximation to the path integral:

.. math::

   H(x) = \alpha \int_S V(s)\, ds.

where:

* :math:`H(x)` is the simulated observation.
* :math:`\alpha` is an optional scaling factor.
* :math:`S` is the integration path usually provided by observations.
* :math:`V(s)` is the GeoVaL value at location :math:`s` along the path :math:`S`.

The operator supports:

* vertical-path integration/summation
* slant-path integration/summation
* optional height-range restriction
* optional interpolation to exact height boundaries at two end points of the path, implemented only for vertical paths 

Important notes:
^^^^^^^^^^^^^^^^^^^^^^^^

This operator currently does not provide tangent-linear (TLM) or adjoint (ADJ) implementations. As a result, it can be used directly in ensemble-based data assimilation systems, but TLM and ADJ implementations are required for use in variational data assimilation.

If weights are computed internally, segment lengths are calculated from WGS-84 ECEF coordinates. Therefore, for slant paths, geodetic latitude, longitude, and height must be available in GeoVaLs. If a model does not provide geodetic coordinates, a conversion to geodetic coordinates is required. 
For vertical paths, the segment length reduces to the distance between adjacent height levels along the local vertical direction. In this case, geocentric height may be an acceptable approximation for some applications, provided that the resulting height differences between adjacent levels do not differ significantly from those obtained using geodetic height.


Configuration options:
^^^^^^^^^^^^^^^^^^^^^^^^

- :code:`geoval variable`: Name of the GeoVaLs variable to be summed/integrated along a path.

- :code:`path type` [optional]: Summation path type. Supported values are :code:`vertical` and :code:`slant`. Default is :code:`vertical`.

- :code:`weight variable` [optional]: GeoVaLs variable containing weights for weighted summation.

- :code:`weights` [optional]: Weights specified directly in YAML.

- :code:`height range` [optional]: Restrict summation to the specified height range :code:`[hmin, hmax]`.

- :code:`interpolate boundaries` [optional]: If :code:`true`, linearly interpolate GeoVaL values to exact lower and upper height boundaries before summation Currently implemented only for :code:`path type: vertical`.  Default is :code:`false`.

- :code:`use km for height` [optional]: If :code:`true`, heights from input GeoVals are in km.  Default is :code:`false`. Only applicable when the weighting for summation is from operator-computed weights.

- :code:`scaling factor` [optional]: Multiplicative scaling factor applied to the final integrated value. Default is :code:`1.0`. This can be used for final unit conversion.

- :code:`path point latitude variable` [optional]: GeoVaLs variable containing \mathbf{geodetic} latitude for each slant-path point. Default is :code:`pathPointLatitude`. Not applicable to vertical summation.

- :code:`path point longitude variable` [optional]: GeoVaLs variable containing \mathbf{geodetic} longitude for each slant-path point. Default is :code:`pathPointLongitude`. Not applicable for vertical summation.

- :code:`path point height variable` [optional]: GeoVaLs variable containing \mathbf{geodetic} height for each slant/vertical path point. Default is :code:`pathPointHeight`.

Examples of YAML:
^^^^^^^^^^^^^^^^^^^^^^^^

Slant-path integration using GeoVaLs weights:

.. code-block:: yaml

  - obs operator:
      name: PathSum
      path type: slant
      geoval variable: variablename
      weight variable: path_weight

Vertical integration using YAML weights:

.. code-block:: yaml

  - obs operator:
      name: PathSum
      path type: vertical            
      geoval variable: variablename
      weights: [1.0, 2.0, 3.0]    

Slant-path integration using internally computed weights, with height from Geovals in unit of km and a scaling factor, 1.0e-07, for H(x):

.. code-block:: yaml

  - obs operator:
      name: PathSum
      path type: slant
      geoval variable: variablename
      path point latitude variable: path_latitude
      path point longitude variable: path_longitude
      path point height variable: path_height
      use km for height: true
      scaling factor: 1.0e-07

Vertical integration using internally computed weights with a defined height range:

.. code-block:: yaml

  - obs operator:
      name: PathSum
      path type: vertical
      geoval variable: variablename
      path point height variable: path_height
      height range: [0, 20]
      use km for height: true

Vertical integration with boundary interpolation at two end points from the YAML defined height range:

.. code-block:: yaml

  - obs operator:
      name: PathSum
      path type: vertical
      geoval variable: variablename
      weight variable: weights
      path point height variable: path_height
      height range: [0, 105]
      use km for height: true
      interpolate boundaries: true
      scaling factor: 1.0e-04
