.. _SABER_applications:

SABER applications
==================

There are currently two applications. The `ErrorCovarianceToolbox` is the primary
application which runs most of the functionality of SABER needed to train/calibrate
blocks, generate a random ensemble, and to run dirac tests. More information is
provided in the page linked below.

Additionally, the `ProcessPerts` application reads either an ensemble of
states or perturbations. It then processes/filters the transformed increments,
(optionally) writing them to file. More details are in

.. toctree::
   :maxdepth: 1

   applications/ErrorCovarianceToolbox.rst
   applications/ProcessPerts.rst
