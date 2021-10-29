.. _top-soca-intro:

Introduction
============

.. _SOCA Overview:

Overview
--------

The Sea-ice, Ocean, and Coupled Assimilation project (SOCA) is the interface between the generic
components of the JEDI system and MOM6. `MOM6 <https://github.com/noaa-gfdl/mom6>`_ is developed by
NOAA's Geophysical Fluid Dynamics Laboratory (GFDL). Further documentation on the latest version of
the MOM6 model is `provided by GFDL <https://mom6.readthedocs.io/en/dev-gfdl/>`_

As well as all the source code needed to implement JEDI for the MOM6 grid and states, SOCA also
provides all the configuration for running example applications, low resolution testing states and
continuous integration.

.. _SOCA Applications currently possible with soca:

Applications currently possible with SOCA
-------------------------------------------
- Observation simulation
- 3DVar with multivariate parametric background error covariance
- EnVar and Hybrid-EnVar
- LETKF
- Biogeochemistry using BLING
- Wave analysis
- Reanalysis with the UFS and GEOS

Various types of data assimilation are supported as part of the initial release of SOCA and
testing of these are routinely executed in the SOCA ``ctest`` suite. Toy example experiments
with 5-degree resolution are provided as part of the tutorial.
