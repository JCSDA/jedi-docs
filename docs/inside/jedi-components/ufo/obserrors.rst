.. _top-ufo-obserrors:

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
