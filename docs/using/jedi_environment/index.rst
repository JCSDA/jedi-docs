################
JEDI Portability
################

As emphasized :doc:`elsewhere <../../overview/index>`, one of our motivating visions behind JEDI is to make it generic, powerful, and efficient enough to be used for a wide range of applications from pedagogical and experimental toy models to coupled NWP systems capable of cutting-edge research and operational forecasting.  This means that JEDI users will use a wide range of computing platforms, from laptops and workstations to cloud platforms to HPC facilities at national centers.

But JEDI does not exist in a vacuum.  Like any modern, sophisticated software package, it leverages a number of `third-party libraries and applications <https://github.com/JCSDA/jedi-stack>`_ to enhance functionality and performance.  Examples include libraries to read and write NetCDF data files (NetCDF, HDF5, PNetCDF), to perform linear algebra computations (LAPACK, Eigen3), to communicate among processors through the message passing interface (MPI), and even to build the code itself (C++/C/Fortran compilers, cmake, ecbuild).  Sorting out all these dependencies can be frustrating for a user who just wants to get straight to the science.

In order to help JEDI users and developers quickly create a productive and consistent computing environment, the JEDI team provides a number of portability tools.  These include:

* Sofware Containers (:ref:`Docker <docker_overview>`, :doc:`Singularity <singularity>`, :doc:`Charliecloud <charliecloud>`)
* Machine images for cloud computing  (e.g. AMIs for `Amazon Web Services <https://aws.amazon.com>`_)
* :doc:`Environment modules <modules>` for selected HPC systems

These portability tools are themselves unified in order to further promote common computing environments across systems.  Our approach is summarized in the following diagram.

.. image:: images/portability.png

The (public) JCSDA `jedi-stack repository <https://github.com/JCSDA/jedi-stack>`_ contains common build scripts that specify the software packages, versions, and configuration options that are required to build and run jedi.  Tagged versions of the jedi-stack will be coordinated with public JEDI releases when they become available.  These build scripts are used to build a :ref:`Docker container <docker_overview>` that is in turn used to build Singularity and Charliecloud containers that can be run on laptops, workstations, cloud platforms, and HPC systems.  Alternatively, we also use the jedi-stack directly to build environment modules on cloud platforms (e.g. AMIs) and HPC systems.  We also leverage the Docker containers for continuous integration testing by means of `Amazon CodeBuild <https://aws.amazon.com/codebuild/>`_ and `Travis-CI <https://travis-ci.org/>`_

In the remainder of this section, we describe in a bit more detail the rationale behind the use of software containers and how we use Docker.  :doc:`Singularity <singularity>`, :doc:`Charliecloud <charliecloud>`, :doc:`AWS cloud environement<cloud/index>` and :doc:`environment modules <modules>` are then described.

.. toctree::
   :maxdepth: 2

   containers
   singularity
   charliecloud
   vagrant
   cloud/index.rst
   modules
