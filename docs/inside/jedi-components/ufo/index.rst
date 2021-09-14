###
UFO
###

UFO is the **Unified Forward Operator**.

It provides the observational operators needed to compute departures and innovations.  In other words, it enables the comparison between model forecasts and observations that lies at the heart of the data assimilation process.  UFO also provides related functionality related to observations such as quality control (QC) filters and variational bias correction.

These documents give a high-level overview of the UFO code repository.  A low-level description of the classes, functions, and subroutines is also available, produced by means of the `Doxygen document generator <https://www.doxygen.nl/index.html>`_.

+----------------------------------------------------------------------------------------+
| `Doxygen Documentation <http://data.jcsda.org/doxygen/Release/ufo/1.2.0/index.html>`_  |
+----------------------------------------------------------------------------------------+

.. toctree::
   :maxdepth: 2

   obsops.rst
   newobsop
   qcfilters/index.rst
   variabletransforms/index.rst
   varbc
