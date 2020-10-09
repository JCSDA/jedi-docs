JEDI Quick Start
================

So, you :doc:`already know what JEDI is <overview/what>` and you are eager to start using it.  You have come to the right place.  Let's get started.  If you run into any problems along the way, you may wish to consult the :doc:`FAQ <FAQ/FAQ>` or the `JEDI forums <https://forums.jcsda.org>`_.

Step 1: Acquire JEDI dependencies
---------------------------------

The first thing you will need is to gain access to the external libraries that are needed to build JEDI: The **JEDI Dependencies**.  These include C++, C, and Fortran compilers, an MPI Library, build tools like `CMake <https://cmake.org>`_ and `ecbuild <https://github.com/jcsda/ecbuild>`_, linear algebra libraries like LAPACK (or Intel MKL), and `EIGEN3 <https://eigen.tuxfamily.org/dox/>`_, IO utilities like `HDF5 <https://www.hdfgroup.org/solutions/hdf5/>`_ and `NETCDF <https://www.unidata.ucar.edu/software/netcdf/>`_, compression tools like `SZIP <http://www.compressconsult.com/szip/>`_ and `ZLIB <zlib.net>`_, and a few other general-purpose utilities like the `Boost C++ headers <https://boost.org>`_ and the `udunits collection of physical constants and units <https://www.unidata.ucar.edu/software/udunits/>`_.  You'll also need the git version control system to obtain the JEDI code from `GitHub <https://github.com>`_.  For a complete, up-to-date list of JEDI dependencies consult the `jedi-stack build system <https://github.com/jcsda/jedi-stack>`_.

There are several ways to gain access to these JEDI dependencies.  If you are fortunate enough to be working on an HPC system managed by one of our `JCSDA partner organizations <https://www.jcsda.org/partners>`_, you may already have access to JEDI environment modules.  For a list of HPC systems currently supported by the JEDI team see :doc:`our document on JEDI Environment Modules <developer/jedi_environment/modules>`.  Select the appropriate system and follow the instructions for loading the jedi module of your choice, based on your preferred compiler.

If you do not have access to one of these systems, then we recommend you use a software container.  JEDI distributes a series of Docker, Singularity, and Charlicloud containers.  We recommend using Singularity if is available on your system.  Like the environment modules, the containers are categorized by the compiler and MPI library.  So, for example, if you wish to use the gnu compiler suite (:code:`gcc`, :code:`g++`, and :code:`gfortran`) and the `Open MPI library <https://www.open-mpi.org/>`_, you would download and enter the JEDI singularity container as follows:

.. code:: bash

   singularity pull library://jcsda/public/jedi-gnu-openmpi-dev
   singularity shell -e jedi-gnu-openmpi-dev.sif

For further details on how to use Singularity and how to install it, see :doc:`our Singularity document <developer/jedi_environment/singularity>`.  If you are unable to access or install Singularity, :doc:`Charliecloud <developer/jedi_environment/charliecloud>` may be your best option.  For further information see our :doc:`JEDI Portability overview <developer/jedi_environment/portability>`.

Another alternative is to `build your own environment modules using the jedi-stack build system <https://github.com/jcsda/jedi-stack>`_.  However, this is only recommended for experienced developers.

.. _quick-start-build:

Step 2: Download and build a JEDI Bundle
----------------------------------------

JEDI packages are organized into *bundles*.  A bundle includes a collection of GitHub repositories needed to build and run JEDI with a particular model.

All JEDI bundles include the base JEDI repositories of of :doc:`OOPS <jedi-components/oops/index>`, :doc:`SABER <jedi-components/saber/index>`, :doc:`IODA <jedi-components/ioda/index>`, and :doc:`UFO <jedi-components/ufo/index>`, as well as the `Community Radiative Transfer Model (CRTM) <https://github.com/jcsda/crtm>`_.  Most will also include additional repositories that provide the forecast model and the physics packages or software infrastructure that supports it.  Some bundles may also include supplementary repositories that support different observation types, such as an alternative radiative transfer model or tools for working with radio occultation measurements from global navigation satellite systems.

Which JEDI bundle you build depends on which atmospheric or oceanic model you plan to work with.  For new users, a good place to start is :code:`ufo-bundle`.  This has all of the JEDI base repositories and, through OOPS, it also contains several illustrative :doc:`toy models <jedi-components/oops/toy-models>` that can be used to run fundamental data assimilation applications.

When you have your JEDI dependencies all set, you can build ufo-bundle with the following commands:

.. code:: bash

   cd <jedi-path>
   git clone git@github.com/jcsda/ufo-bundle.git
   mkdir build
   cd build
   ecbuild --build=Release ../ufo-bundle
   make update
   make -j4

:code:`<jedi-path>` represents a directory of your choice - wherever you want to download, build, and run the JEDI code.  If you're working on your laptop, this might be your home directory or if you're working on an HPC system it might be some designated work filesystem.  The :code:`-j4` option asks :code:`make` to use four parallel processes; if you have a larger system you may wish to use more.  The optional :code:`--build=Release` option tells :code:`ecbuild` to build an optimized version of the code.  If omitted the code will still build but applications may run somewhat slower.  The :code:`make update` step is not strictly necessary the first time you build a bundle but it's good to get in the habit of running it.  This updates your code to the latest release versions on GitHub.

For further details on build options and working with bundles see :doc:`Building and Running JEDI <developer/building_and_testing/building_jedi>`.

Step 3: Run the JEDI test suite
-------------------------------

The JEDI code uses a `CMake <https://cmake.org>`_ build system and the JEDI test suite is implemented through CMake's :code:`ctest` utility.

The default JEDI test suite is designed to thoroughly and efficiently test the JEDI code components.  If you're working from your own laptop or workstation, you can run the tests by simply typing this on the command line, after running :code:`ecbuild` and :code:`make` as described :ref:`above <quick-start-build>`:

.. code:: bash

   ctest

Thus, :code:`ctest` is typically executed from the build directory - the same directory where you ran :code:`ecbuild` and :code:`make`.  This will run several hundred tests, even for the relatively simple :code:`ufo-bundle`.

If you are running on an HPC system at a research supercomputing facility or an operational forecast center, running the test suite may take a bit more effort.  The JEDI software is designed to run on parallel computing architectures and many of the JEDI tests use more than one MPI task.  Many HPC platforms do not allow you to run parallel jobs from the command line on a login node.  So, you will have to follow the conventions of your facility and run the tests either with an interactive allocation or with a batch script.  For examples and tips on running JEDI on selected HPC machines, see :doc:`Environment Modules <developer/jedi_environment/modules>` and scroll down to your system of choice.

For further details on running ctest, such as selecting which subset of tests to run, see :doc:`JEDI Testing <developer/building_and_testing/unit_testing>`.