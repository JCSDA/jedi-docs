.. _top-tut-dev-container:

Tutorial: Building and Testing FV3 bundle
=========================================

Learning Goals:
 - How to download and run/enter a JEDI development container
 - How to build the JEDI code from source
 - How to run the JEDI unit test suite

Prerequisites:
 - read the :doc:`tutorial overview <../index>`

Overview
--------

In the :doc:`Run JEDI in a Container <run-jedi>` tutorial we used a version of an :doc:`application container <../../../using/jedi_environment/portability>`.  This means that the container includes the compiled source code, ready to use.  The ``jedi-tutorial`` container comes pre-packaged with JEDI!

But that's not the way most JEDI developers, and many users, use JEDI.  Instead, JEDI is set up so that users and developers have easy access to a version of the source code that they can download, build, and even modify themselves.  This encourages community members to make changes and potentially contribute to the project through :doc:`pull requests to the main JEDI repositories <../../../inside/practices/pullrequest>`.

So, to do this, you need a *development container*.  In contrast to an application container, a development container does not include the JEDI code.  But, it does include everything you need to acquire and build it.

In this approach (which you would also follow when using :doc:`environment modules <../../../using/jedi_environment/modules>`), we will download the code from `GitHub <https://github.com>`_ and compile it.  Then we will run the JEDI test suite.

This tutorial parallels very closely the :doc:`JEDI Quick Start <../../quick-start>`.  However, here we will be building the more extensive ``fv3-bundle`` as opposed to the ``ufo-bundle``.

Step 1: Download and Enter the Development Container
----------------------------------------------------

You can obtain the JEDI development container with the following command:

.. code-block:: bash

   singularity pull library://jcsda/public/jedi-gnu-openmpi-dev

This is the version of the development container that uses gnu compilers and the openmpi MPI library.  :ref:`Other development containers are also available <available_containers>` but the ``gnu-openmpi`` container is the only one that is currently equipped with plotting tools such as ``cartopy`` that are used in some of the tutorials (not this one).  Still, you may wish to repeat this tutorial with the ``clang-mpich-dev`` container.

If the pull was successful, you should see a new file in your current directory with the name ``jedi-gnu-openmpi-dev_latest.sif``.  If it has a different name or a different extension you may have an older version of Singularity.  It is recommended that you use Singularity version 3.0 or later.

If you wish, you can verify that the container came from JCSDA by entering:

.. code-block:: bash

   singularity verify jedi-gnu-openmpi-dev_latest.sif

Now you can enter the container with the following command:

.. code-block:: bash

   singularity shell -e jedi-gnu-openmpi-dev_latest.sif

To exit the container at any time (not now), simply enter

.. code-block:: bash

   exit

Before proceeding, you may wish to take a few moments to :ref:`get to know the container <meet-the-container>`.

Step 2: Build fv3-bundle
------------------------

As described :ref:`elsewhere <quick-start-build>`, the JEDI code is organized into *bundles*.  Each bundle identifies the different GitHub repositories that are needed to run the applications and orchestrates how all of these repositories are built and linked together.

In this tutorial we will build ``fv3-bundle``.  In this tutorial we will put the code in a directory coming off your home directory called ``jedi``.   Feel free to change the location if you wish.

That said, you can get it from GitHub with the following commands:

.. code-block:: bash

   mkdir -p $HOME/jedi
   cd $HOME/jedi
   git clone https://github.com/jcsda/fv3-bundle.git

This should create a new directory called ``$HOME/jedi/fv3-bundle``.

To see what code repositories will be built, ``cd`` to the ``fv3-bundle`` directory and view the file ``CMakeLists.txt``.  Look for the lines that begin with ``ecbuild-bundle``.

:doc:`ecbuild <../../../inside/developer_tools/cmake>` is a collection of `CMake <https://cmake.org>`_ utilities that forms the basis of the JEDI build system.  The ``ecbuild-bundle()`` function calls specify different GitHub repositories and integrate them into the building of the bundle, in order of dependency.

You will see references there to core JEDI repositories like :doc:`OOPS <../../../inside/jedi-components/oops/index>`, :doc:`SABER <../../../inside/jedi-components/saber/index>`, :doc:`IODA <../../jedi-components/ioda/index>`, and :doc:`UFO <../../../inside/jedi-components/ufo/index>`.  You will also see references to repositories used to construct observation operators, such as JCSDA's `Community Radiative Transfer Model (CRTM) <https://github.com/jcsda/crtm>`_.  And, finally, you will see references to GitHub repositories that contain code needed to build the FV3-GFS and FV3-GEOS models and integrate them with JEDI.  These include the `linearized FV3 model <https://github.com/jcsda/fv3-jedi-linearmodel>`_ used for 4D Variational DA, and the :doc:`FV3-JEDI repository <../../../inside/jedi-components/fv3-jedi/index>` that provides the interface between JEDI and models based on the FV3 dynamical core.

Now, an important tip is: **never build a bundle from the main bundle directory**.  In our example this means the top-level ``$HOME/jedi/fv3-bundle`` directory.  Building from this directory would cause cmake to create new files that conflict with the original source code.

So, we will create a new build directory and run ecbuild from there:

.. code-block:: bash

    mkdir -p $HOME/jedi/build
    cd $HOME/jedi/build
    ecbuild --build=Release ../fv3-bundle

The ``--build=Release`` builds an optimized version of the code so our applications will run a bit faster than if we were to omit it.  The only required argument of ``ecbuild`` is the directory where the bundle is.

We have not yet compiled the code; we have merely set the stage.  To appreciate part of what these commands have done, take a quick look at the bundle directory:

.. code-block:: bash

    ls ../fv3-bundle

Do you notice anything different?   The bundle directory now includes directories that contain the code repositories that were specified by all those ``ecbuild-bundle`` calls in the ``CMakeLists.txt`` file as described above (apart from a few that are optional): ``oops``, ``saber``, ``ioda``, ``ufo``, ``fv3-jedi`` etc.  If you wish, you can look in those directories and find the source code.

So, one of the things that ``ecbuild`` does is to check to see if the repositories are there.  If they are not, it will retreive (clone) them from GitHub.  Running the ``make update`` command makes this explicit:

.. code-block:: bash

   make update

Here ``ecbuild`` more clearly tells you which repositories it is pulling from GitHub and which branches.  Running ``make update`` ensures that you get the latest versions of the various branches that are on GitHub.  Though this is not necessary for tagged releases (which do not change), it is a good habit to get into if you seek to contribute to the JEDI source code.

All that remains is to actually compile the code (be sure to ``cd`` back to the build directory to run this):

.. code-block:: bash

   make -j4

The ``-j4`` option tells make to do a parallel build with 4 parallel processes.  Feel free to use more if you have more than four compute cores on your machine.

Even with a parallel build, this can take 5-10 min or more, depending on how fast your computer is.  So, go take a break and pat yourself on the back for getting this far.

Step 3: Run the JEDI test suite
-------------------------------

If you are doing this tutorial as a prerequisite to other, more advanced tutorials, then you may wish to skip this step.  But, you should do it at least once with the default (latest release) version of the code to verify that things are installed and working properly on your platform of choice.

Before running the tests, it's a good idea to make sure that our system is ready for it.  If you are running on a laptop or virtual machine, it is likely that some of the tests will require more MPI tasks than the number of compute cores you have available on your machine.  So, we have to tell OpenMPI that it is ok if some cores run more than one MPI task.

To do this, first see if the following directory exists on your system:

.. code-block:: bash

    ls $HOME/.openmpi

If it does not exist, run the following commands to create and initialize it:

.. code-block:: bash

    mkdir -p $HOME/.openmpi
    echo 'rmaps_base_oversubscribe = 1' > $HOME/.openmpi/mca-params.conf

If the ``$HOME/.openmpi`` directory already exists, edit it to make sure it contains an ``mca-params.conf`` file with the line ``rmaps_base_oversubscribe = 1``.  This turns on OpenMPI's "oversubscribe" mode.

It is interesting to note that this is something that we cannot include in the container.  When you are inside the singularity container, you have the same home directory (and user name) as you do outside of the container.  This is a Good Thing; it provides a convenient work environment that is familiar to most scientists and software engineers, where you can see the files in your home directory without having to explicitly mount it in the container (as you would with Docker).  But, it also means that some things, like this ``$HOME/.openmpi`` directory are shared by your container enviroment and your host environment.

Another common source of spurious test failure is memory faults due to an insufficient stack size.  To avoid this, run the following commands:

.. code-block:: bash

    ulimit -s unlimited
    ulimit -v unlimited

Now we're ready.  To run the full suite of JEDI unit tests, enter this command from the build directory:

.. code-block:: bash

    cd $HOME/jedi/build
    ctest

Running this gives you an appreciation for how thoroughly the JEDI code is :doc:`tested <../../../working-practices/testing>`.  The fv3-bundle has nearly 1000 tests but most of them take a fraction of a minute.  And this is only the Tier 1 tests - more computationally extensive higher-tier tests are run regularly with varying frequency.  These thoroughly test all the applications, functions, methods, class constructors, and other JEDI components.  As emphasized :doc:`elsewhere <../../../working-practices/reviewing-code>`, no code is added to JEDI unless there is a test to make sure that it is working and that it continues to work as the code evolves.

If you still get test failures you may wish to consult the :doc:`FAQ <../../FAQ/FAQ>`.