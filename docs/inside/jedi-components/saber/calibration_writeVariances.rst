.. _calibration_write_variances:

Write Variances
===============

This block has two modes of use:

- ``instantaneous statistics`` mode - where horizontal global averaged variances are calculated for each model level. The data is from a single FieldSet at a specific point in the workflow. In all cases, when activated, it deals the input FieldSet to the class method in question, whether it is `multiply`, `multiplyAD`, `leftInverseMultiply`. This is to be used primarily for diagnostic purposes. With this there is the option of writing the variances to NetCDF files. In the near future, we will make this code more consistent with the other main mode.
- ``calibration`` mode - where we accumulate using the "direct calibration" method. This method is still work in progress and will be extended in the near future. Currently, it has the capability to generate:
    - grid-point variances and global horizontal-averaged variances,
    - grid-point covariances and global horizontal-averaged covariances between 2 variables,
    - grid-point vertical covariances and global horizontal-averaged vertical covariances,
    - grid-point vertical cross-covariances and horizontal-averaged vertical cross-covariances between 2 variables.

In all cases we are assuming:

- that the mean of each field has been removed before entering this saber block. This affects the operations being performed.
- that the fields are either on a cubed-sphere dual mesh or on a classic Gaussian latitude mesh. The main restriction here is the need for a measure of the horizontal area for each grid point. In principle, we should be able to extend the usefulness of this block when we are able to get the horizontal area associated with each grid point from the model's geometry.
- in calibration mode we are assuming (for now) that the perturbations that are being used come from the randomization method. A consequence of this is that with this method there are N degrees of freedom with N perturbations, unlike the standard calculation where there are N-1 degrees of freedom for N perturbations (where one of the degrees of freedom has been used in calculating the ensemble mean as part of the process of creating the perturbations.)


Example yamls
~~~~~~~~~~~~~
There is an intentional limitation built into this saber block. Each instantiation of the block for the calibration will deal with only one type of statistics. Variances and covariance between 2 variables are both considered to have the `statistics type = variances`. Similarly vertical covariances and vertical cross-covariances are also grouped together with their `statistics type = vertical covariances`. Also, only one type of binning strategy (that is either "horizontal global average" or "horizontal grid point") is allowed for each instantiation of the block.

Calculation of instantaneous statistics example is below. Note that at the moment `binning` is required, even though the type is not yet used as it only does "horizontal global average" binning.

Note that the default statistics that are generated are variances and not vertical covariances

An example of instantaneous statistics.

.. code-block:: yaml

  saber outer blocks:
  - (...)
  - saber block name: write variances
    binning:                                                    // binning category (required)
      type: "horizontal global average"                         // binning category type (required - but not used with instantaneous statistics yet)
    field names: *vars                                          // list of variable names used calculuting the variances or vertical covariances.
    instantaneous statistics:                                   // setting instantaneous statistics option: (optional)
       multiply fset filename: process_perts2_f8_variance_wb2   // creating statistics every time going through multiply method. (optional)
       multiplyad fset filename: blah_adjoint                   // creating statistics every time going through the adjoint of the multiply method. (optional)
       left inverse fset filename: blah3                        // creating statistics every time going through left inverse multiply method. (optional)
       output path: test-output-ancil1                          // tag used in files (required)
  - (...)


An example of vertical covariance calibration

.. code-block:: yaml
 
  saber outer blocks:
  - (...)
  - saber block name: write variances
    binning:                                                    // binning category (required)
      type: "horizontal global average"                         // binning category type (required - but not used with instantaneous statistics yet)
    calibration:                                                // switching on calibration (optional)
      write:                                                    // allow writing (optional)
        covariance name: "randomization with F12 mesh"          // covariance name (used as a global header attribute) in the NetCDF file. (required)
        mpi pattern: '%MPI%'                                    // mpi pattern string (needs %'s)
        file path: path2/vertcov_2_%MPI%.nc                     // file path for netCDF (total number of mpi ranks replace the %MPI%)
    field names: *vars                                          // list of variable names used calculating the variances or vertical covariances. (defaults to an empty vector of strings)
    statistics type: "vertical covariances"                     // statistics type (either "variances" (default) or "vertical covariances")
  - (...)

An example of covariances between two variables on each grid point with binning information dumped to file

.. code-block:: yaml
 
  saber outer blocks:
  - (...)
  - saber block name: write variances
    additional cross covariances:                               // switching on cross covariances
    - variable 1: eastward_wind                                 // setting cross (co)variance between "eastward_wind" and "northward_wind"
      variable 2: northward_wind                                // both variable1 and variable2 are required.
    - variable 1: eastward_wind                                 // setting cross (co)variance between "eastward_wind" and "northward_wind"
      variable 2: mu
    - variable 1: northward_wind                                // setting cross (co)variance between "eastward_wind" and "northward_wind"
      variable 2: mu
    binning:                                                    // binning category (required)
      type: "horizontal grid point"                             // binning category type (required)
      mpi rank pattern: '%MPI%'                                 // pattern (optional) but needed with filepath
      file path: path3/binning_data_%MPI%.nc                    // replaces %MPI% with MPI rank. One file is created for each MPI rank.
    calibration:                                                // switching on calibration (optional)
      write:                                                    // allow writing (optional)
        covariance name: "randomization with F12 mesh"          // covariance name (used as a global header attribute) in the NetCDF file. (required)
        mpi pattern: '%MPI%'                                    // mpi pattern string (needs %'s)
        file path: path2/intervariable_variances_%MPI%.nc       // file path for netCDF (total number of mpi ranks replace the %MPI%)
  - (...)


General equations used
~~~~~~~~~~~~~~~~~~~~~~

We are moving towards a generic binning strategy for variance/cross-covariance/vertical covariance/vertical cross-covariances.
The description below will be limited single processor element (PE) case.  The considerations for the "domain decomposed" multiple PE case is described in the `Technical implementation` section.

Let:

- :math:`e` be the ensemble member index;
- :math:`i` be the horizontal index associated with each field. In the context of covariances between 2 variables and vertical cross-covariances between 2 variables, we assume that this indexing is valid for the fields of both variables;
- :math:`k` be the model level index of each field;
- :math:`\mathrm{fld1}(i,k)_e` denote the first field for ensemble perturbation :math:`e`;
- :math:`\mathrm{fld2}(i,k)_e` denote the second field. When calculating variances and vertical covariances (and not covariances or vertical cross-covariances) both fields end up being the same;
- :math:`b` be the bin index;
- :math:`j` index the horizontal points in each bin. For instance when calculating grid-point variances, we will have a bin of each grid point and :math:`j= 0`;
- :math:`\mathrm{binIdx}(b, j)` denote the horizontal points used in each bin. So in the case of grid-point variances, the value of :math:`\mathrm{binIndx}(b, 0)` will be equal to the horizontal index associated with the bin :math:`b`;
- :math:`\mathrm{w}(b, j)` be the normalized horizontal area for each grid point within each bin. We enforce that the total summed normalized horizontal area for each bin is equal to 1. To do this is means that when binning over the global domain the area associated with each grid point is normalized to be its fraction of the total area of the domain;
- :math:`\mathrm{covar}(b,k)` be the (co)variance between two fields.  When both fields are the same the equation reduces to calculating the variance;
- :math:`\mathrm{vertcrosscov}(b,k_1,k_2)` be vertical cross-covariance between two fields. Here we need a model level index for field 1 :math:`k_1` and an associated level index for field2 :math:`k_2`. When both fields are the same, the equation reduces to calculating the vertical covariance.

The limits of each index is denoted by capitalization.

The covariance is a generalisation of the variance calculation. To create the variance, field 1 and field 2 need to be the same.

.. math:: 

  \mathrm{covar}(b, k) = \frac{1}{E} \sum_{e=0}^{e=E-1}  \sum_{j=0}^{j=J-1} \mathrm{w}(b,j) \text{ fld1}(\mathrm{binIdx}(b,j),k)_e \text{ fld2}(\mathrm{binIdx}(b,j),k)_e

Note that this only makes sense when both fields have the same number of model levels. (We do have an error trap to protect the user in that case).

The vertical cross-covariance is a generalisation of the covariance calculation (where :math:`\mathrm{covar}(b, k) = \mathrm{vertcrosscov}(b, k, k)`).

.. math:: 

  \mathrm{vertcrosscov}(b, k_1, k_2) = \frac{1}{E} \sum_{e=0}^{e=E-1}  \sum_{j=0}^{j=J-1} \mathrm{w}(b,j) \text{ fld1}(\mathrm{binIdx}(b,j),k_1)_e \text{ fld2}(\mathrm{binIdx}(b,j),k_2)_e .

NetCDF file specifications
~~~~~~~~~~~~~~~~~~~~~~~~~~

The calibration covariance file is generated with a global NetCDF header of the form:

.. code-block:: text

  covariance name = "randomization with F12 mesh" ;
  date time = "2010-01-01T12:00:00Z" ;
  no of samples = 10 ;

The number of samples comes from the ensemble perturbations that have been read in. "date time" and "covariance name" come from the yaml.

The short name of each variable is the statistics type ("variance" or "vertical covariance") followed by a variable index number.

Each NetCDF variable has its own set of variable attributes. An example of this for one variable is shown below. The variable attribute shows the covariance between variables "northward_wind" and "mu" in terms of horizontal global averages.

.. code-block:: text

  double variance 6(horizontal global average index, levels index 1) ;
    variance 6:_FillValue = -3.33476705790481e+38 ;
    variance 6:long_name = "variance of northward_wind and mu" ;
    variance 6:statistics type = "variance" ;
    variance 6:binning type = "horizontal global average" ;
    variance 6:variable name 1 = "northward_wind" ;
    variance 6:variable name 2 = "mu" ;
    variance 6:levels 1 = 70 ;
    variance 6:levels 2 = 70 ;

Another example is below:

.. code-block:: text

  double vertical covariance 5(horizontal global average index, levels index 1, levels index 2) ;
    vertical covariance 5:_FillValue = -3.33476705790481e+38 ;
    vertical covariance 5:long_name = "vertical covariance of eastward_wind and mu" ;
    vertical covariance 5:statistics type = "vertical covariance" ;
    vertical covariance 5:binning type = "horizontal global average" ;
    vertical covariance 5:variable name 1 = "eastward_wind" ;
    vertical covariance 5:variable name 2 = "mu" ;
    vertical covariance 5:levels 1 = 70 ;
    vertical covariance 5:levels 2 = 70 ;

We see that in this case the vertical cross-covariance between "eastward_wind" and "mu" is stored as a horizontal global average.

In addition we dump Binning data from each MPI rank to file. This is mainly for diagnostic uses. The global attributes of this file include the "binning type" and the "date time". An example of the NetCDF header is below from the rank 1.

.. code-block:: text

  netcdf hor_gri_ave_1 {
  dimensions:
    global PE bin index = 576 ;
    local PE bin index = 576 ;
    local PE horizontal point index = 1 ;
  variables:
    double longitude(local PE bin index, local PE horizontal point index) ;
      longitude:_FillValue = -3.33476705790481e+38 ;
      longitude:long_name = "longitude" ;
      longitude:units = "degrees" ;
    double latitude(local PE bin index, local PE horizontal point index) ;
      latitude:_FillValue = -3.33476705790481e+38 ;
      latitude:long_name = "latitude" ;
      latitude:units = "degrees" ;
    double horizontal grid point weights(local PE bin index, local PE horizontal point index) ;
      horizontal grid point weights:_FillValue = -3.33476705790481e+38 ;
      horizontal grid point weights:long_name = "horizontal grid point weights" ;
      horizontal grid point weights:binning type = "horizontal grid point" ;
    int horizontal grid point global bins(global PE bin index) ;
      horizontal grid point global bins:_FillValue = -2147483643 ;

    // global attributes:
      :date time = "2010-01-01T12:00:00Z" ;
      :binning type = "horizontal grid point" ;
  }

Here we store some of the information that we use within the `BinningData_` fieldset.  The longitude and latitude values and the weights are given for each local bin index on the PE rank in question. Also a 1-dimensional array, called :code:`<binning_type> global bins`, gives the global bin value for each local bin index on this PE rank. The variable `horizontal grid point weights` relates to the :math:`\mathrm{w}(b, j)` in the equations above. We do not put the equivalent of :math:`\mathrm{binIdx}(b, j)` into the NetCDF file. Instead we put the longitude and latitudes values associated to each horizontal index and each local bin index. In summary, we write :math:`\mathrm{longitude}(b, j)`, :math:`\mathrm{latitude}(b, j)`, :math:`\mathrm{w}(b, j)` and :code:`<binning_type> global bins` to a NetCDF file for each PE rank.

In the near future we expect to extend this to include an additional 1-dimensional array called :code:`<binning_type> bin extent` which will give the number of horizontal points for each bin. At present it is not needed as the binnning strategies implemented have the same number of longitude, latitude points on each MPI rank.

Technical implementation considerations
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The main process in the calibration is to calculate the variances/vertical variances locally on each MPI rank for the bins that exist there and then to gather and sum this information onto processor rank 0.  The data from a local MPI rank with a local bin index is mapped to the correct global index number as part of this process.
