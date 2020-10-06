JEDI Quick Start
================

So, you :doc:`already know what JEDI is <overview/what>` and you are eager to start using it.

The first thing you will need is to gain access to the external libraries that are needed to build JEDI: The **JEDI Dependencies**.  These include C++, C, and Fortran compilers, an MPI Library, build tools like `CMake <https://cmake.org>`_ and `ecbuild <https://github.com/jcsda/ecbuild>`_, linear algebra libraries like LAPACK (or Intel MKL), and `EIGEN3 <https://eigen.tuxfamily.org/dox/>`_, IO utilities like `HDF5 <https://www.hdfgroup.org/solutions/hdf5/>`_ and `NETCDF <https://www.unidata.ucar.edu/software/netcdf/>`_, compression tools like `SZIP <http://www.compressconsult.com/szip/>`_ and `ZLIB <zlib.net>`_, and a few other general-purpose utilities like the `Boost C++ headers <https://boost.org>`_ and the `udunits collection of physical constants and units <https://www.unidata.ucar.edu/software/udunits/>`_.  You'll also need the git version control system to obtain the JEDI code from `GitHub <https://github.com>`_.  For a complete, up-to-date list of JEDI dependencies consult the `jedi-stack build system <https://github.com/jcsda/jedi-stack>`_.

There are several ways to gain access to these JEDI dependencies.  

JCSDA Partner
https://www.jcsda.org/partners