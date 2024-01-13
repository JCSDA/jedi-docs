.. warning::
    This section is out of date!! A further review will be completed in the near future. Sorry for the inconvenience.

.. _top-mpas-jedi-intro:  [note: comments are new paragraphs that start with "dot dot space", the explicit markup start]

Introduction
============

Overview
--------

MPAS-JEDI is the interface between the generic components of the JEDI system and the atmospheric component
of the Model for Prediction Across Scales (MPAS).  The MPAS computational framework is jointly developed
by Los Alamos National Laboratory and the National Center for Atmospheric Research (NCAR), and NCAR has
lead responsibility for the atmospheric component.

The user is referred to documentation for `MPAS <https://mpas-dev.github.io/>`_ and `MPAS-Atmosphere <https://mpas-dev.github.io/atmosphere/atmosphere.html>`_ for user guides and other information about those model components.

MPAS-JEDI provides the source code needed to implement JEDI for the MPAS mesh and atmospheric model variables,
as well as a suite of tests that can be run automatically as part of continuous integration, configurations
for those tests, and other coarse mesh-spacing examples.


Applications currently possible with MPAS-JEDI
----------------------------------------------
* HofX
* 3DVar with multivariate background error covariance
* 3D/4DEnVar
* Hybrid-3DEnVar
* EDA

Each of these applications can be configured to use MPAS variable-resolution or regional meshes, in addition
to global, quasi-uniform meshes like those in the test suite and tutorial examples.  MPAS-JEDI's data assimilation applications can
also be configured to employ analysis increments and ensemble-forecast input at a different, coarser
mesh-spacing than the background forecast and analysis (to be referred to as dual-resolution or dual-mesh applications elsewhere in this documentation). MPAS-JEDI is distributed with python-based
diagnostic and plotting utilities. There is an additional cylc-based workflow repository
(`MPAS-Workflow <https://github.com/NCAR/MPAS-Workflow>`_) available, which has only been used on NCAR's Derecho HPC.
Eventually those independent post-processing and workflow tools will be merged with or replaced by shared JEDI
capabilities as those capabilities mature.

MPAS-JEDI and MPAS-A
---------------------------------------------

Important elements of MPAS-JEDI are adopted directly from MPAS-A, including mesh definitions and decompositions, in-memory data structures, and the utilities to construct and manipulate them. Together with the MPAS-A development team at NCAR, we often enhance MPAS-A to facilitate its use for data assimilation and within JEDI.  These enhancements reside in a fork of MPAS-Dev/MPAS-Model until they can be merged there.
