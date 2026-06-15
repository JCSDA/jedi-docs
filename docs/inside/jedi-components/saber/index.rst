#####
SABER
#####

SABER is the **System Agnostic Background Error Representation**.

It provides generic software utilities for computing and working with the
background error covariance matrix, often referred to as the **B** matrix.

As the acronym is meant to suggest, SABER covariances are generally generic
and can be used with -- little modification -- most earth-system models (for
which a jedi-model interface exists).

.. toctree::
   :maxdepth: 2

   SABER_intro.rst
   SABER_BlocksIndex.rst
   SABER_BlockChainGuide.rst
   SABER_Applications.rst
   SABER_calibration.rst
   SABER_tests.rst
..  Interface_with_VADER.rst

Final Notes:
------------

As an additional debugging tool, TotalView is available for BUMP when SABER/JEDI is built in debug mode.
TotalView is a powerful parallel debugger for C/C++, Fortran, and mixed C/C++ and python codes.

A low-level description of the classes, functions, and subroutines is also available, produced by means of the `Doxygen document generator <https://www.doxygen.nl/index.html>`_.

+-----------------------------------------------------------------------------------------+
| `Doxygen Documentation <http://data.jcsda.org/doxygen/Release/saber/1.2.0/index.html>`_ |
+-----------------------------------------------------------------------------------------+
