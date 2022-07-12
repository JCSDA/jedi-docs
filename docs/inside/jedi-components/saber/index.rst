#####
SABER
#####

SABER is the **System Agnostic Background Error Representation**.

It provides generic software utilities for computing and working with the background error covariance matrix, often referred to as the **B** matrix.

SABER blocks
------------
The **B** matrix is generally modeled as a series of linear operators, represented in SABER by "SABER blocks". Such blocks, even if they come from different SABER components of SABER, are interoperable.

More details here: 

.. toctree::
   :maxdepth: 1

   SABER_blocks.rst
..  Interface_with_VADER.rst


SABER components
----------------
.. _SABER_components:

SABER blocks can encapsulate various components:

.. toctree::
   :maxdepth: 1

   BUMP: Background error on an Unstructured Mesh Package<BUMP>
   GSI: interface to the GSI covariance<GSI>
   ID: identity operator<ID>
   SPECTRALB: spectral covariance/correlation<SPECTRALB>
   StdDev: standard-deviation application<StdDev>

SABER testing
-------------

SABER has its own pseudo-model for testing purposes, called **QUENCH**.

More details here: 

.. toctree::
   :maxdepth: 1

   QUENCH

A low-level description of the classes, functions, and subroutines is also available, produced by means of the `Doxygen document generator <https://www.doxygen.nl/index.html>`_.

+-----------------------------------------------------------------------------------------+
| `Doxygen Documentation <http://data.jcsda.org/doxygen/Release/saber/1.2.0/index.html>`_ |
+-----------------------------------------------------------------------------------------+
