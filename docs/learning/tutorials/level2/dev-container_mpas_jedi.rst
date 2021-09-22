.. _top-tut-dev-container-mpas:

Tutorial: Build and Test JEDI-MPAS
==================================

Learning Goals:
 - How to download and run/enter a JEDI development container
 - How to build the JEDI code from source
 - How to run the JEDI unit test suite

Prerequisites:
 - read the :doc:`tutorial overview <../index>`

Overview:  Use *Development Container* for JEDI-MPAS
----------------------------------------------------

The :doc:`Run JEDI-FV3 in a Container <../level1/run-jedi>` tutorial used an
:doc:`application container <../../../using/jedi_environment/index>` that includes the
compiled source code, ready to use.

But that's not the way most JEDI developers, and many users, use JEDI.  Instead, JEDI is set
up so that users and developers have easy access to a version of the source code that they
can download, build, and even modify themselves.  This encourages community members to make
changes and potentially contribute to the project through :doc:`pull requests to the main
JEDI repositories <../../../inside/practices/pullrequest>`.

So, to do this, you need a *development container*.
In contrast to an application container, a development container does not include the JEDI code.  
But, it does include everything you need to acquire and build the JEDI code. 


In this approach (which you would also follow when using :doc:`environment modules
<../../../using/jedi_environment/modules>`), we will download the JEDI code from `GitHub
<https://github.com>`_ and compile it.  Then we will run the JEDI test suite.

Step 1: Download and Enter the Development Container
----------------------------------------------------

You can obtain the JEDI development container with the following command:

.. code-block:: bash

   singularity pull library://jcsda/public/jedi-gnu-openmpi-dev

This is the version of the development container that uses gnu compilers and the openmpi MPI library.  :ref:`Other development containers are also available <available_containers>` but the ``gnu-openmpi`` container is the only one that is currently equipped with plotting tools such as ``cartopy`` that are used in some of the tutorials (not this one).  Still, you may wish to repeat this tutorial with the ``clang-mpich-dev`` container.

You should now see a new file in your current directory with the name ``jedi-gnu-openmpi-dev_latest.sif``.  If it has a different name or a different extension you may have an older version of Singularity.  It is recommended that you use Singularity version 3.6 or later.

If you wish, you can verify that the container came from JCSDA by entering:

.. code-block:: bash

   singularity verify jedi-gnu-openmpi-dev_latest.sif

.. note::

   The verification implementation was changed in Singularity version 3.6.  So if you use a version of Singularity earlier than 3.6, you may get a warning when you run this ``verify`` command.  It is OK to ignore it and proceed.

Now you can enter the container with the following command:

.. code-block:: bash

   singularity shell -e jedi-gnu-openmpi-dev_latest.sif

To exit the container at any time (not now), simply enter

.. code-block:: bash

   exit

Before proceeding, you may wish to take a few moments to :ref:`get to know the container <meet-the-container>`.

Step 2: Build mpas-bundle
-------------------------

JEDI packages are organized into bundles. Each bundle identifies the different GitHub repositories that are needed to run the applications and orchestrates how all of these repositories are built and linked together.

In this tutorial we will build ``mpas-bundle``.

But, before we do so, it's a good idea to configure ``git`` so that it will not ask you for your login credentials for every repository it downloads.   So, if you haven't done so already on your computer, run the following commands:

.. code-block:: bash

   git config --global credential.helper 'cache --timeout=3600'
   git config --global --add credential.helper 'store'

This stores your git credentials in your home directory for one hour (3600 seconds).  And, since the container and the host environment share the same home directory, it does not matter if you run these commands inside or outside the container.

You will also have to enable git large file service (LFS) with this command before you clone any JEDI repositories (see :ref:`the FAQ for further information <faq-netcdf-unknown-file-format>`):

.. code-block:: bash

   git lfs install

Now we will put the code in a directory coming off your home directory (e.g., ``$HOME/jedi``).   Feel free to change the location if you wish.


You can get the MPAS-JEDI code from GitHub with the following commands

.. code-block:: bash

   mkdir -p $HOME/jedi
   cd $HOME/jedi
   git clone https://github.com/jcsda/mpas-bundle.git

This will create a new directory called ``$HOME/jedi/mpas-bundle``.


To see which code repositories will be built, ``cd`` to the ``mpas-bundle`` directory and view the
file ``CMakeLists.txt``.  Look for the lines that begin with ``ecbuild-bundle``.

The command :doc:`ecbuild <../../../inside/developer_tools/cmake>` is a collection of `CMake
<https://cmake.org>`_ utilities that forms the basis of the JEDI build system.  The
``ecbuild-bundle()`` function calls specify different GitHub repositories and integrate them
into the building of the bundle, in order of dependency.

You will see references there to core JEDI repositories like :doc:`OOPS
<../../../inside/jedi-components/oops/index>`, :doc:`SABER
<../../../inside/jedi-components/saber/index>`, :doc:`IODA
<../../../inside/jedi-components/ioda/index>`, and :doc:`UFO
<../../../inside/jedi-components/ufo/index>`. You will also see references to repositories
used to construct observation operators, such as JCSDA's `Community Radiative Transfer Model
(CRTM) <https://github.com/jcsda/crtm>`_.  And, finally, you will see references to GitHub
repositories that contain code needed to build the MPAS model and integrate it with JEDI.
It is the :doc:`MPAS-JEDI repository <../../../inside/jedi-components/mpas-jedi/index>` that
provides the interface between JEDI and models based on the MPAS dynamical core.

Now, an important tip is: **never build a bundle from the main source code directory**.  In
our example this means the top-level ``$HOME/jedi/mpas-bundle`` directory.  Building from
this directory would cause cmake to create new files that conflict with the original source
code.

Instead, we will create a new build directory and run ecbuild from there:

.. code-block:: bash

    mkdir -p $HOME/jedi/mpas-build
    cd $HOME/jedi/mpas-build
    ecbuild --build=Release ../mpas-bundle

The ``--build=Release`` option builds an optimized version of the code so our applications
will run a bit faster than if we were to omit it.  The only required argument of ``ecbuild``
is the directory where the initial `CMakeLists.txt` is located.

We have not yet compiled the code; we have merely set the stage.  To appreciate part of what
these commands have done, take a quick look at the source code directory:

.. code-block:: bash

    ls ../mpas-bundle

Do you notice anything different?  The bundle directory now includes directories that
contain the code repositories that were specified by all those ``ecbuild-bundle`` calls in
the ``CMakeLists.txt`` file as described above (apart from a few that are optional):
``oops``, ``saber``, ``ioda``, ``ufo``, ``crtm``, ``mpas-jedi``, etc.  If you wish, you can
look in those directories and find the source code.

So, one of the things that ``ecbuild`` does is to check to see if the repositories are there.  If they are not, it will retrieve (clone) them from GitHub.  Running the ``make update`` command makes this explicit:

.. code-block:: bash

   make update

Here ``ecbuild`` more clearly tells you which repositories it is pulling from GitHub and which branches.  Running ``make update`` ensures that you get the latest versions of the various branches that are on GitHub.  Though this is not necessary for tagged releases (which do not change), it is a good habit to get into if you seek to contribute to the JEDI source code.

All that remains is to actually compile the code:

.. code-block:: bash

   make -j4

The ``-j4`` option tells make to do a parallel build with 4 parallel processes.  Feel free to use more if you have more than four compute cores on your machine.

Even with a parallel build, this can take 5-10 min or more, depending on how fast your computer is.  So, go take a break and pat yourself on the back for getting this far.

Step 3: Run the JEDI test suite
-------------------------------

If you are doing this tutorial as a prerequisite to other, more advanced tutorials, then you may wish to skip this step.  But, you should do it at least once with the default (latest release) version of the code to verify that things are installed and working properly on your platform of choice.

Before running the tests, it's a good idea to make sure that our system is ready for it.  If you are running on a laptop or virtual machine, it is likely that some of the tests will require more MPI tasks than the number of compute cores you have available on your machine.  So, we have to tell OpenMPI that it is OK if some cores run more than one MPI task.

To do this, first see if the following directory exists on your system:

.. code-block:: bash

    ls $HOME/.openmpi

If it does not exist, run the following commands to create and initialize it:

.. code-block:: bash

    mkdir -p $HOME/.openmpi
    echo 'rmaps_base_oversubscribe = 1' > $HOME/.openmpi/mca-params.conf

If the ``$HOME/.openmpi`` directory already exists, edit it to make sure it contains an ``mca-params.conf`` file with the line ``rmaps_base_oversubscribe = 1``.  This turns on OpenMPI's "oversubscribe" mode.

It is interesting to note that this is something that we cannot include in the container.  When you are inside the singularity container, you have the same home directory (and user name) as you do outside of the container.  This is a Good Thing; it provides a convenient work environment that is familiar to most scientists and software engineers, where you can see the files in your home directory without having to explicitly mount it in the container (as you would with Docker).  But, it also means that some things, like this ``$HOME/.openmpi`` directory are shared by your container environment and your host environment.

Another common source of spurious test failure is memory faults due to an insufficient stack size.  To avoid this, run the following commands:

.. code-block:: bash

    ulimit -s unlimited
    ulimit -v unlimited

Now we're ready.  To run the full suite of JEDI unit tests, enter this command from the build directory:

.. code-block:: bash

    cd $HOME/jedi/mpas-build
    ctest

Running this gives you an appreciation for how thoroughly the JEDI code is :doc:`tested
<../../../working-practices/testing>`.  Over 1100 tests were encompassed in the mpas-bundle
project, but many of them take less than a second to run.  And most of them are only the
Tier 1 tests --- more computationally extensive higher-tier tests are run regularly with
varying frequency.  They thoroughly test all the applications, functions, methods, class
constructors, and other JEDI components.  As emphasized :doc:`elsewhere
<../../../working-practices/reviewing-code>`, no code is added to JEDI unless there is a
test to make sure that it is working and that it continues to work as the code evolves.

If you still get test failures you may wish to consult the :doc:`FAQ <../../../FAQ/FAQ>`.

A small clarification on the case of the development container: You built mpas-bundle while
inside the container but since the container and host environment share the same home
directory, you should still be able to access it outside of the container.  But, if you try
to run any tests or applications from outside the container you'll find that they fail.
This is because, at run time as well as at compile time, the tests and applications need to
link to the libraries and executables inside the container.
