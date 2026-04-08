.. _top-ufo-obserrors:

Observation Errors in UFO
=========================

UFO provides many ways of specifying observation uncertainites (also known as observation errors).
Below is an outline of options:

.. toctree::
   :maxdepth: 2

   obsFilterErrors.rst
   obsErrorCovariances.rst

Some observation error operators have reconditioning options for cases in which the operator may not
be positive definite (which can cause instabilities when inverting the operator). For more information see:

.. toctree::
   :maxdepth: 2

   reconditioningObsErrors.rst
