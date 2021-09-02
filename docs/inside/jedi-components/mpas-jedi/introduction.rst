.. _top-mpas-jedi-intro:  [note: comments are new paragraphs that start with "dot dot space", the explicit markup start]

Introduction
============

Overview
--------

MPAS-JEDI is the interface between the generic components of the JEDI system and the atmospheric component
of the Model for Prediction Across Scales (MPAS).  The MPAS computational framework is jointly developed
by Los Alamos National Laboratory and the National Center for Atmospheric Research (NCAR), and NCAR has
lead responsibility for the atmospheric component.

.. Add links for MPAS, MPAS-A?

As well as all the source code needed to implement JEDI for the MPAS mesh and model variables, MPAS-JEDI also
provides a suite of tests that can be run automatically as part of continuous integration, and configurations
for those tests and other low-resolution examples.


Applications currently possible with MPAS-JEDI
----------------------------------------------
- HofX
- 3DVar with multivariate background error covariance
- 3D/4DEnVar
- Hybrid-3DEnVar
- EDA

Each of these applications can be configured to use MPAS variable-resolution or regional meshes, in addition
to global, quasi-uniform meshes like those in the test suite and tutorial examples.  MPAS-JEDI application can
also be configured to employ analysis increments and ensemble-forecast input at a different, lower resolution
than the background forecast and analysis.
MPAS-JEDI includes python-based diagnostics and plotting utilities and cylc-based workflow, both of
which are planned to merge with shared JEDI capabilities as those capabilities mature.

MPAS-JEDI and MPAS-A
---------------------------------------------

MPAS-JEDI utilizes a variety of computational infrastructure directly from MPAS-A, including mesh definitions and decompositions, and data structures plus the utilities to construct and manipulate them. Together with the MPAS-A development team at NCAR, we often enhance MPAS-A to facilitate its use for data assimilation and within JEDI.  These enhancements reside in a fork of MPAS-Dev/MPAS-Model until they can be merged there.
