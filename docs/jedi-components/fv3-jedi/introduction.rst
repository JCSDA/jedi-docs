.. _top-fv3-jedi-intro:

Introduction
============

Overview
--------

FV3-JEDI is the interface between the generic components of the JEDI system and models that are
based on the FV3 (Finite Volume Cubed-Sphere) dynamical core. FV3 is developed by NOAA's Geophysical
Fluid Dynamics Laboratory (GFDL) and is used in NOAA's Global Forecast System (GFS) and NASA's
Goddard Earth Observing System (GEOS).

As well as all the source code needed to implement JEDI for the FV3 grid and states, FV3-JEDI also
provides all the configuration for running example applications, low resolution testing states and
continuous integration.

Applications currently possible with FV3-JEDI
---------------------------------------------
- Global NWP with GFS
- Global NWP with GEOS
- Aerosol data assimilation with GFS and GEOS
- FV3 Limited Area Model (LAM) for NWP
- FV3 Limited Area Model for Community Multiscale Air Quality (LAM-CMAQ)
- NOAA land surface model

Various types of data assimilation are supported as part of the initial release of FV3-JEDI and
testing of a these are routinely executed in the FV3-JEDI ctest suite. Realistic example experiments
with 1-degree resolution are provided or accessed through the software containers.
