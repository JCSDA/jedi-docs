.. _top-ufo-obserrors:

Observation uncertainties in the UFO
====================================

Using filter to specify observation uncertainties
-------------------------------------------------

For many observation types, the observation uncertainties (also known as observation errors) can be specified using filters within ufo.  For instance, the following yaml snippet shows the ``VariableAssignment`` filter being used to give uncertainty values to ``air_pressure`` in the AMV processing:

.. code-block:: yaml

  - filter: Variable Assignment
    assignments:
    - name: air_pressure@MetaDataError
      type: float
      function:
        name: DrawValueFromFile@ObsFunction
        options:
          file: Data/ufo/testinput_tier_1/satwind_pressure_errors.nc4
          group: MetaDataError
          interpolation:
          - name: satwind_id@MetaData
            method: exact
          - name: air_pressure@MetaData
            method: linear

Also, within filters there is the ability to set observation uncertainties using the :doc:`assign_error filter action <qcfilters/FilterOptions>`.  An example of this, from the surface observation code when assigning errors to ``surface_pressure``, is included here:

.. code-block:: yaml

  - filter: Perform Action
    filter variables:
    - name: surface_pressure
    action:
      name: assign error
      error parameter: 120             # 120 Pa = 1.2 mb

It is quite common to use an ObsFunction to define how the uncertainties are specified as this can be used to account for a wide variety of cases.

GNSS-RO observation uncertainties
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Observation uncertainties for GNSS-RO are set using a specific filter ``ROobserror``.  This filter encompases a handful of different methods to specify the uncertainties, and these will be described below.  Unusually for a filter, the code is kept in ``ufo/gnssro/QC`` rather than ``ufo/filters``.  Much of the functionality of this filter could be replaced with the above methods combined with a specially-created obs function.

The main option for this filter is ``errmodel`` which defines the error-model to use when setting the uncertainties.  This may take the values ``NBAM``, ``ECMWF``, ``NRL`` or ``MetOffice`` for bending angles, and ``NBAM`` for refractivity.  Each of these models will be described in turn.

NBAM (bending angle)
********************

This option adopts the bending angle uncertainties specified in the NCEP GSI data assimilation system. The error model 
is specified for three sets of RO observations based on their processing centers/satellite missions:
EUMETSAT processed RO data, UCAR/CDAAC processed RO data, and COSMIC-2 RO data (UCAR/CDAAC processed).
The COSMIC-2 bending angle uncertainties were estimated during the COSMIC-2 implementation in 2019, while the other observation uncertainties were already in place prior to that. 

The regression coefficients for the fitting function are predefined according to offline computations.
The resulting bending angle uncertainty varies with missions (as described above), impact height, and latitude (observation uncertainties are split into two sets for observations between 40S and 40N and at higher latitudes). 



ECMWF (bending angle)
*********************
The ECMWF bending angle uncertainty model is specified as a percentage of the observation value.  The specified uncertainty begins at a value of zero impact height.  Note that the impact height of an observation at the surface is around 2 km, but we use 0 km for convenience when specifying the uncertainty model.

ECMWF uses a maximum percentage uncertainty of 20% at surface (0 km impact height). The percentage uncertainty  falls linearly with impact height to 1.25% at 10 km. The percentage uncertainty is specified as 1.25% between 10 and 32 km. The bending angle observation uncertainty is :math:`3. 10^{-6}` radian (rather than percentage) above 32 km.

NRL (bending angle)
*******************
The NRL bending angle uncertainty model is specified as a percentage of the observation value.  The uncertainty model begins at a value of zero impact height.  Note that the impact height of an observation at the surface is around 2 km, but we use 0 km for convenience when specifying the uncertainty model.   

NRL uses a maximum percentage uncertainty of 25% at 0-degree latitude, but this is damped away from the equator by cosine of the latitude, :math:`cos(\text{lat})`, falling to 16.5% at the Poles as given in the Equation below. The percentage uncertainty also falls linearly with impact height to 1.5% at a “minimum error height”. This varies from 12 km at 0-degrees latitude, decreasing by cosine of latitude to 5333.33 km at the Poles shown in the second Equation.

Maximum error at zero impact height = :math:`0.25 \left( 0.66 + \frac{cos(\text{lat})}{3} \right)`

Minimum error height = :math:`8666.66 + 3333.33 cos(2*\text{lat})`

The minimum uncertainty value of 1.5% of the observation is used vertically upwards until this drops below a threshold of 6 microradians.

MetOffice (bending angle)
*************************

This option is based on reading ancillary files which contain the observation uncertainty specification.  These specify the "fractional error" for the observations.  That is, the uncertainties are multiplied by the observed bending angle before being used.

The filter has the following options:

rmatrix_filename (string, required)
    File path of the ancillary file containing the observation uncertainties.
err_variable (string, required)
    Must be either "latitude" or "average_temperature".
n_horiz (integer, optional, default: 1)
    This option only applies with the ROPP 2D operator.  The current method for dealing with 2D operators is to specify :code:`n_horiz` geovals for every observation.  If this method is used in the operator, then this routine also needs the same value.
allow_extrapolation (logical, optional, default: false)
    Whether to allow the uncertainties to be extrapolated in the vertical.  If false the relative error at the extreme points will be persisted, if true then linear extrapolation will be used.
use_profile (logical, optional, default: false)
    Whether to determine the uncertainties on a profile basis?  If true the observations will be arranged into profiles, and the latitude or average temperature of the bottom observation in the profile will be used as the predictor for the whole profile.
verbose_output (logical, optional, default: false)
    Produce verbose output?

The ancillary files are in fortran namelist format.  The file can contain up to 1000 namelist entries, with each defining an R-matrix.  Each namelist entry within the file should contain certain entries:

satid (integer, required)
    The satellite identifier of the LEO satellite receiving the occulted signals
origc (integer, required)
    The originating centre (processing centre) for these observations
obs_errors (list float, required)
    The observation uncertainties defined at given atmospheric heights.  These are fractional errors which will be interpolated in the vertical.
heights (list float, metres, required)
    The impact height of the given observation uncertainties.  The uncertainties will be interpolated between the given heights.
min_error (float, radians, optional, default: 0)
    The minimum observation uncertainty.  If the interpolated value falls below this, then this value will be used.  Specified in radians, not a relative error.
clen (float, optional, not used yet, default: 1E10)
    The inverse of a vertical correlation length-scale.  In order to specify a vertical correlation matrix, a correlation length-scale could be used.  May be used when JEDI has a method for non-diagonal correlations.

The user can choose to have an R-matrix based on either average temperature or latitude.  Whichever of these is chosen by the user then the associated entry in the namelist file is required (a file can contain both types of matrix, but they are typically written separately):

latitude (float, degrees)
    The latitude associated with the R-matrix.  The R-matrix whose latitude is closest to the observation latitude will be chosen.
av_temp (float, K)
    The average temperature in the lowest 20km of the atmosphere associated with the R-matrix.  The matrices will be interpolated to the average temperature associated with the observation.

.. code-block:: yaml

  - filter: ROobserror
    filter variables:
    - name: bending_angle
    errmodel: MetOffice
    err_variable: latitude
    rmatrix_filename: ../resources/rmatrix/gnssro/gnssro_ba_rmatrix_latitude.nl
    use profile: true
    allow extrapolation: true
    verbose output: true
    defer to post: true

NBAM (refractivity)
*******************

Similar to the NBAM bending angle uncertainty model, the NBAM refractivity uncertainty model also uses predefined fitting functions, which vary with impact heights. However, there is no latitude or mission dependency considered for this refractivity uncertainty model.


Observation error covariances in UFO
====================================

Diagonal observation error covariance
-------------------------------------

The :doc:`diagonal observation error covariance implemented in OOPS <../oops/generic-implementations/obserror>` can be used in all applications that use UFO.

Observation error covariance with cross-variable (cross-channel) correlations
-----------------------------------------------------------------------------

The observation error covariance can be set up to use cross-variable (cross-channel) correlations from a file. In this case correlations between variables (channels) are the same at all locations and are read from the file specified in the configuration. Observation error standard deviations are read from the :code:`ObsError` group of the observation space, similar to the diagonal observation error covariances.

The full observation error covariance matrix is :math:`R = D^{1/2} * C * D^{1/2}` where :math:`D^{1/2}` is a diagonal matrix with the observation error standard deviations (:code:`ObsError` group) on the diagonal, and :math:`C` is the correlation matrix.

This type of observation error covariance is set up using the following options:

* :code:`input file`: filename for the input file containing cross-variable correlations or covariances (the file has to contain only one of those).

.. important::
  Input files are always used to set up correlations, and not covariances. If the input file contains covariances, they would be converted to correlations.

.. code-block:: yaml

 obs error:
   covariance model: cross variable covariances
   input file: obserror_correlations.nc4

Observation error correlations file format
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The input file for the observation error correlations must have the following dimensions and groups:

* :code:`nvars` or :code:`nchannels` dimension -- number of variables or channels
* :code:`variables` (string, size :code:`nvars`) or :code:`channels` (int, size :code:`nchannels`) variable: variable names, or channels numbers.
* :code:`obserror_correlations` or :code:`obserror_covariances` (float, size :code:`nvars, nvars`, or :code:`nchannels, nchannels`) variable: cross-variable or cross-channel correlations or covariances. The file has to contain only one of these variables.  Covariances will be converted to correlations.

If a particular assimilated variable or channel is missing from the input correlations file, its correlation with other variables or channels will be set to zero.

Specifying observation error standard deviations
------------------------------------------------

For all of the supported observation error covariance matrices, observation error standard deviations are read from the :code:`ObsError` group of the observation file. Observation filters can change those values, and inflate or assign observation error standard deviations using :doc:`filter actions <qcfilters/FilterOptions>`.
