################
JEDI Portability
################

As emphasized :doc:`elsewhere <../../overview/index>`, one of our motivating visions behind JEDI is to make it generic, powerful, and efficient enough to be used for a wide range of applications from pedagogical and experimental toy models to coupled NWP systems capable of cutting-edge research and operational forecasting.  This means that JEDI users will use a wide range of computing platforms, from laptops and workstations to cloud platforms to HPC facilities at national centers.

But JEDI does not exist in a vacuum.  Like any modern, sophisticated software package, it leverages a number of third-party libraries and applications to enhance functionality and performance.  Examples include libraries to read and write NetCDF data files (NetCDF, HDF5, PNetCDF), to perform linear algebra computations (LAPACK, Eigen3), to communicate among processors through the message passing interface (MPI), and even to build the code itself (C++/C/Fortran compilers, cmake, ecbuild).  Sorting out all these dependencies can be frustrating for a user who just wants to get straight to the science.

In order to help JEDI users and developers quickly create a productive and consistent computing environment, the JEDI team provides a number of portability tools.  These include:

* A complete software stack called `spack-stack <https://github.com/jcsda/spack-stack>`_  for compiled and Python dependencies based on the open-source `spack <https://github.com/spack/spack>`_ package manager, originally developed by the `Lawrence Livermore National Laboratory (LLNL) <https://computing.llnl.gov/projects/spack-hpc-package-manager>`_, with `instructions <https://spack-stack.readthedocs.io/en/1.5.1/>`_ for building and using spack-stack on HPC, the cloud, and generic macOS and Linux systems.
* Machine images for cloud computing  (e.g. AMIs for `Amazon Web Services <https://aws.amazon.com>`_)
* :doc:`Environment modules <modules>` for selected HPC systems
* Docker and Singularity software :doc:`containers <containers/container_overview>`.

The `spack-stack repository <https://github.com/jcsda/spack-stack>`_ contains detailed instructions and spack configurations that specify the target platform, software packages, versions, and configuration options that are required to build and run jedi (and other applications). Tagged versions of the spack-stack will be coordinated with public JEDI releases when they become available. We use spack-stack to build environment modules on cloud platforms (e.g. AMIs), HPC systems, and generic macOS/Linux systems.

The spack configuration is also used to build :doc:`Docker and Singularity containers <containers/container_overview>` that can be run on laptops, workstations, cloud platforms, and HPC systems. The containers are also leveraged for continuous integration testing by means of `Amazon CodeBuild <https://aws.amazon.com/codebuild/>`_ and `Travis-CI <https://travis-ci.org/>`_

In the remainder of this section, we describe how to use spack-stack software environments for building and running JEDI applications.

.. toctree::
   :maxdepth: 2

   spackbuild
   modules
   containers/index.rst
   cloud/index.rst
