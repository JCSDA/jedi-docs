#####
SABER
#####

SABER is the **System Agnostic Background Error Representation**.

It provides generic software utilities for computing and working with the
background error covariance matrix, often referred to as the **B** matrix.

SABER Error Covariance Model
----------------------------

The **B** matrix is generally modeled as a series of linear operators,
represented in SABER by "SABER blocks". Such blocks, even if they come from
different components of SABER, are often interoperable. The full series of
blocks (linear operators) used in a model for **B** is referred to as a
"block-chain".

A block-chain is composed of a central block surrounded, symmetrically, by a
'backward' AKA 'adjoint' outer block chain on the left and a 'forward' AKA
'tangent linear' outer block chain on the right. The forward and backward outer
block-chains are always mirrored images of each other as shown in
:numref:`blockchainfig`. When reading a block-chain in a YAML configuration,
saber blocks are listed from top-to-bottom in the 'forward' order, but are first
applied to an incoming model increment in the backwards (bottom-to-top) order.

.. _blockchainfig:
.. figure:: fig/figure_saber_blocks_2.jpg
   :scale: 20%
   :align: center

   An outline of a SABER block-chain.

The **B** matrix can be modeled in one of several ways, depending on the needs
of the user. SABER has options for setting up parametric, ensemble, or hybrid
background error covariances. A parametric **B**, sometimes called a "static"
**B** in the literature, could be a model which does not evolve with time or a
model that introduces some flow-dependence through dependence on the background
state. An ensemble **B** uses an ensemble of forecasts to update/evolve the
background error in time. A hybrid **B** combines a set of parametric and ensemble
models using a weighted sum.
 
More details here: 

.. toctree::
   :maxdepth: 1

   SABER_intro.rst
..  Interface_with_VADER.rst


SABER blocks
------------
.. _SABER_blocks:

SABER blocks can encapsulate various components:

.. toctree::
   :maxdepth: 2
   :titlesonly:

   BUMP: Background error on an Unstructured Mesh Package<BUMP>
   GSI: interface to the GSI covariance<GSI>
   ID: identity operator<ID>
   SPECTRALB: spectral covariance/correlation<SPECTRALB>
   FakeLevels: fake levels convolution<FakeLevels>
   StdDev: standard-deviation application<StdDev>
   DuplicateVariables: outer block to duplicate one variable into others<DuplicateVariables>
   Interpolation blocks<Interpolations>
   UKMO-specfic saber blocks<UKMO>
 
SABER applications
------------------
.. _SABER_applications:

There are currently only two applications.  The main application runs most of the functionality of saber and is called `ErrorCovarianceToolbox`.  In addition we have an application that reads either an ensemble of states or perturbations. It then processes / filters the transformed increments, dumping them to file. More details are in

.. toctree::
   :maxdepth: 1

   ProcessPerts.rst
   ErrorCovarianceToolbox.rst


Calibration of SABER error covariance
-------------------------------------

A SABER error covariance can be calibrated from ensemble data:

.. toctree:: 
   :maxdepth: 1

   calibration.rst

SABER testing
-------------

SABER has its own pseudo-model for testing purposes, called **QUENCH**. Also, SABER has an automated testing
process which will require a few more steps for adding new tests.

For more details here: 

.. toctree::
   :maxdepth: 1

   QUENCH
   SABER block testing<SABER_testing>
   Adding a SABER test<SABER_test>

As an additional debugging tool, TotalView is available for BUMP when SABER/JEDI is built in debug mode.
TotalView is a powerful parallel debugger for C/C++, Fortran, and mixed C/C++ and python codes.

A low-level description of the classes, functions, and subroutines is also available, produced by means of the `Doxygen document generator <https://www.doxygen.nl/index.html>`_.

+-----------------------------------------------------------------------------------------+
| `Doxygen Documentation <http://data.jcsda.org/doxygen/Release/saber/1.2.0/index.html>`_ |
+-----------------------------------------------------------------------------------------+
