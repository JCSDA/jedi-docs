JEDI Quick Start
================

So, you :doc:`already know what JEDI is <overview/what>` and you are eager to start using it.  You have come to the right place.  Let's get started.

Step 1: Acquire JEDI Dependencies
---------------------------------

The first thing you will need is to gain access to the external libraries that are needed to build JEDI: The **JEDI Dependencies**.  These include C++, C, and Fortran compilers, an MPI Library, build tools like `CMake <https://cmake.org>`_ and `ecbuild <https://github.com/jcsda/ecbuild>`_, linear algebra libraries like LAPACK (or Intel MKL), and `EIGEN3 <https://eigen.tuxfamily.org/dox/>`_, IO utilities like `HDF5 <https://www.hdfgroup.org/solutions/hdf5/>`_ and `NETCDF <https://www.unidata.ucar.edu/software/netcdf/>`_, compression tools like `SZIP <http://www.compressconsult.com/szip/>`_ and `ZLIB <zlib.net>`_, and a few other general-purpose utilities like the `Boost C++ headers <https://boost.org>`_ and the `udunits collection of physical constants and units <https://www.unidata.ucar.edu/software/udunits/>`_.  You'll also need the git version control system to obtain the JEDI code from `GitHub <https://github.com>`_.  For a complete, up-to-date list of JEDI dependencies consult the `jedi-stack build system <https://github.com/jcsda/jedi-stack>`_.

There are several ways to gain access to these JEDI dependencies.  If you are fortunate enough to be working on an HPC system managed by one of our `JCSDA partner organizations <https://www.jcsda.org/partners>`_, you may already have access to JEDI environment modules.  For a list of HPC systems currently supported by the JEDI team see :doc:`our document on JEDI Environment Modules <developer/jedi_environment/modules>`.  Select the appropriate system and follow the instructions for loading the jedi module of your choice, based on your prefered compiler.

If you do not have access to one of these systems, then we recommend you use a software container.  JEDI distributes a series of Docker, Singularity, and Charlicloud containers.  We recommend using Singularity if is available on your system.  Like the environment modules, the containers are categorized by the compiler and MPI library.  So, for example, if you wish to use the gnu compiler suite (:code:`gcc`, :code:`g++`, and :code:`gfortran`), you would download and enter the JEDI singularity container as follows:

.. code:: bash

   singularity pull library://jcsda/public/jedi-gnu-openmpi-dev
   singularity shell -e jedi-gnu-openmpi-dev.sif

For further details on how to use Singularity and how to install it, see :doc:`our Singularity document <developer/jedi_environment/singularity>`.  If you are unable to access or install Singularity, :doc:`Charliecloud <developer/jedi_environment/charliecloud>` may be your best option.  For further information see our :doc:`JEDI Portability overview <developer/jedi_environment/portability>`.

Another alternative is to `build your own environment modules using the jedi-stack build system <https://github.com/jcsda/jedi-stack>`_.  However, this is only recommended for experienced developers.

Step 2: Download and build a JEDI Bundle
----------------------------------------

Step 3: Run the JEDI test suite
-------------------------------
