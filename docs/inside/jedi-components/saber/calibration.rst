.. _calibration:

Calibration of a SABER error covariance model
=============================================

Two options are available to calibrate a SABER error covariance: direct calibration or iterative calibration. 

Direct calibration
------------------

The SABER block method used for direct calibration is :code:`directCalibration`.
It receives a vector of Atlas FieldSets, which are all loaded in memory to calibrate the block.
There is no enforced assumption on whether the ensemble mean has already been removed from the ensemble or not, this is a choice to be made for each block by the developers.

Saber blocks with direct calibration assuming that the ensemble mean has been removed (not exhaustive list!)

- :code:`spectral covariance`: calculates vertical covariances for each  `spectral` total wavenumber.
- :ref:`write variances <calibration_write_variances>`: currently calculates variances and inter-variable cross-covariances either as a horizontal global average or per grid point. Also calculates vertical covariances or vertical cross-covariances.

Iterative calibration
---------------------

The Atlas FieldSets are loaded in memory one after another, which allows a possibly much larger ensemble to be used. 
In this context, it **cannot** be assumed that the mean has already been removed from the ensemble. 
The process is done in a single pass for both estimation of the mean and of covariances (see section 3 of `this technical note <https://github.com/benjaminmenetrier/covariance_filtering/blob/master/covariance_filtering.pdf>`_ for details on how this can be done). 
The SABER blocks are calibrated one after another, so that the full ensemble must be read for each SABER blocks. 

Iterative calibration is activated with the flag `iterative ensemble loading` at the error covariance level. 

The SABER block methods used in this context are:

- :code:`iterativeCalibrationInit()`: For instance to initialize the ensemble mean and covariances to zero.
- :code:`iterativeCalibrationUpdate`: Updates the statistic estimates from an Atlas FieldSet
- :code:`iterativeCalibrationFinal()`: For instance to normalize the statistics that need to be normalized by the ensemble size.

I/O methods
-----------

The building process of a SABER block takes different routes depending on the specified `mode`:

- `calibration mode`: if the :code:`calibration` key has been specified in the error covariance configuration, or for the :code:`Ensemble` block. 
- `read mode`: if :code:`read` has been specified in the error covariance configuration.
- `other mode`: if not in calibration mode nor in read mode.

Each block has two read methods and two write methods that can be called after construction of each block. 
Each methods come in two versions, one using the model reader/writer, and one using read and write procedures specified by each block. 

- In all three modes, model fields can be read into the block using the model reader. The read configuration and the Atlas FieldSet to read into should be specified by the block method :code:`fieldsToRead()`. Default is to read nothing.
- :code:`read()` is used in read mode only to read calibration data of the block.
- In calibration mode only, :code:`write()` is used to write the calibration data that has been computed.
- In calibration mode only, calibration data can also be written using the model writer. The write configuration and the Atlas FieldSet to write from should be specified by the block method :code:`fieldsToWrite()`. Default is to write nothing.

Index
^^^^^

.. toctree::
   :titlesonly:

   calibration_writeVariances.rst

