
Getting Started with Doxygen
=============================

We at JEDI use `Doxygen <http://www.stack.nl/~dimitri/doxygen/>`_ for generating man pages, inheritance diagrams, call trees and other types of documentation that is linked to specific blocks of source code such as classes or functions.  For generating web-based manuals, guides, and tutorials we use :doc:`Sphinx <getting-started-with-sphinx>`.

Doxygen is open-source software that was developed by Dimitri van Heesch and is distributed under the GNU General Public License.  For further information on the project see `the Doxygen home page <http://www.stack.nl/~dimitri/doxygen/>`_ and for extensive documentation on how to use it see:

    `The Doxygen User Manual <http://www.stack.nl/~dimitri/doxygen/manual/index.html>`_

In what follows we give practical tips on how to use Doxygen within the context of JEDI.

Installing Doxygen
------------------

Doxygen is included in the :doc:`JEDI Singularity image <../jedi_environment/singularity>` and may already be installed on your system.  To check whether it is already installed, just type this at the command line:

.. code:: bash

  doxygen --help

If it is not already installed, you can obtain binary files for Mac OS X, Linux, and Windows through the
`Doxygen web page <http://www.stack.nl/~dimitri/doxygen/download.html>`_ or you can download the source code from
`GitHub <https://github.com/doxygen/doxygen>`_ and build it yourself.

Alternatively, if you have a Mac, you can install Doxygen with :doc:`Homebrew <homebrew>` 

.. code:: bash

  brew install doxygen # (Mac only)
  

Using Doxygen
------------------

Doxygen documentation is inserted directly into the source code using specific directives.  Since these directives are located within comment blocks, they do not affect the compilation of the code.  And, since C++ and Fortran have different ways to define comment blocks, the instructions for adding Doxygen documentation to these source files are correspondingly different.  See below for instructions on how to add comments in :ref:`C++ <doxygen-Cpp>` and :ref:`Fortran 90 <doxygen-Fortran>`.

.. _doxygen-Cpp:

Documenting C++ source code
---------------------------

Doxygen documentation is inserted directly into the source code using specific directives that are inserted within comment blocks.  Since Fortran 90 and C++ have different ways to define comment blocks, the pro

.. _doxygen-Fortran:

Documenting Fortran source code
-------------------------------

The following sections describe how to go about this for both C++ files and Fortran 90 files.

*More to come - stay tuned*


