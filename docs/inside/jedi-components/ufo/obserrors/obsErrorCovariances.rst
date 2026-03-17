.. _ObsErrorOperatorsUFO:

Observation error covariances in UFO
====================================

UFO contains several observation error covariance operators (R-matrix operators):

.. toctree::
   :maxdepth: 1

   obsErrorCrossVariable.rst
   obsErrorDiagonal.rst
   obsErrorDiffusion.rst
   obsErrorWithinGroup.rst


Specifying observation error standard deviations
------------------------------------------------

For all of the supported observation error covariance matrices, observation error standard deviations are read from the :code:`ObsError` group of the observation file. Observation filters can change those values, and inflate or assign observation error standard deviations using :ref:`filter-actions`.
