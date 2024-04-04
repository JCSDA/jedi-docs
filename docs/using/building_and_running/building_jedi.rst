.. _build-jedi:

Building and compiling JEDI
=============================

As described in detail :ref:`cmake_devtools`, the procedure for building and compiling JEDI rests heavily on the software tools :code:`CMake` and :code:`ecbuild`, which make your life much easier.  A typical workflow proceeds in the following steps, which are described in more detail in the sections that follow:

1. Clone the desired JEDI :ref:`bundle <bundle>`
2. Optionally edit the :code:`CMakeLists.txt` file in the bundle to choose the code branches you want to work with
3. :code:`cd` to the build directory and run :code:`ecbuild` to generate the Makefiles and other infrastructure
4. Run :code:`make update` to pull the latest, up-to-date code from GitHub (optional) and :code:`make` to compile the code
5. Run :code:`ctest` to verify that the bundle is working correctly

In terms of the actual commands you would enter, these steps will look something like this:

.. code-block:: bash

    cd <src-directory>
    git clone https://github.com/JCSDA/fv3-bundle.git
    cd <build-directory>
    # See build step 3 for possible ways of detecting the correct
    # Python3 interpreter in the ecbuild command
    ecbuild <src-directory>/fv3-bundle
    make update
    make -j4
    ctest

In this document we describe Steps 1 through 4, including the various options you have available to you at each step.  For a description of Step 5, see our page on :ref:`jedi-testing`.

You will probably only need to do Step 1 once.  However, if you are a developer who is making changes to one or more JEDI repositories, you will likely find it useful to execute Steps 2 through 5 multiple times, with progressively increasing frequency.  For example, if you are working with a single repository, you may only need to do Step 2 once in order to tell ecbuild to compile your local branch.  And, you'll only need to run :code:`ecbuild` (Step 3) occasionally, when you make changes that affect the directory tree or compilation (for example, adding a file that was not there previously or substantially altering the dependencies).  By comparison, you will likely execute Steps 4 and 5 frequently as you proceed to make changes and test them.

.. _git-config:

Precursor: System Configuration
-------------------------------

Before jumping into the actual building of JEDI, we highly recommend that you read this section.  This information will let you avoid the need to enter your GitHub password many times during the JEDI build process, which can be annoying to say the least.  And, it will allow you to avoid errors when using a bundle that requires multiple MPI threads.

All JEDI repositories are stored and distributed by means of `GitHub <https://github.com>`_.   If you have used :code:`git` before, then you probably already have a :code:`.gitconfig` configuration file in your home directory.  If you have not already done so at some point in the past, you can create a git configuration file by specifying your GitHub username and email as follows:

.. code-block:: bash

   git config --global user.name <username-for-github>
   git config --global user.email <email-used-for-github>

This is a recommended action for any user of GitHub since it governs how you access GitHub with :code:`git`.  However, there is another action that you may not have set up previously but that will be immensely useful to all JEDI users and developers: tell GitHub to cache your GitHub credentials:

.. code-block:: bash

   git config --global credential.helper 'cache --timeout=3600'

This tells GitHub to keep your GitHub login information for an hour, i.e. 3600 seconds (feel free to increase this time if you wish).  If you don't do this, you may regret it - you'll have to enter your GitHub password repeatedly throughout the build process as ecbuild proceeds to clone multiple GitHub repositories.

The statement above should be sufficient on most systems.   However, on some systems (particularly HPC systems with stringent security protocols), it may be necessary to explicitly give git permission to store your GitHub password unencrypted on disk as follows:

.. code-block:: bash

    git config --global --add credential.helper 'store'

As for all your files, your password will still be protected by the security protocols necessary to simply access the system as a whole and your own filesystem in particular.  So, this should still be pretty secure on HPC systems but you might want to use it with caution in less secure environments such as laptops or desktops.  For other alternatives, see the documentation on `git credentials <https://git-scm.com/docs/gitcredentials>`_.

Before building the jedi code, you should also make sure that git is configured to interpret files that are stored on :ref:`git-lfs-devtools`:

.. code-block:: bash

    git lfs install --skip-repo

This only needs to be done once, and it is required even if you are running in a container.

Another thing to keep in mind is that many JEDI tests likely require more MPI tasks to run than the number of processor cores on your system.  For example, may laptops have two or four processor cores but the minimum number of MPI tasks needed to run fv3-bundle is 6.  That's no problem - you just have to tell Openmpi that it is ok to run more than one MPI task on each core.  To do this, run these commands:

.. code-block:: bash

    mkdir -p ~/.openmpi
    echo "rmaps_base_oversubscribe = 1" > ~/.openmpi/mca-params.conf


.. _bundle:

Step 1: Clone the Desired JEDI Bundle
-------------------------------------

JEDI applications are organized into high-level **bundles** that conveniently gather together all the git repositories necessary for JEDI applications to run.  Often a bundle is associated with a particular model, such as **FV3** or **MPAS**.

.. note::

   In the instructions that follow, the the :code:`fv3-bundle` will be used as an example. But it is more common to clone the :code:`jedi-bundle`.

To start your JEDI adventure, first choose a place -- and create a directory -- as a home for your bundle (or bundles--plural--if you're ambitious!). This directory will be referred to as :code:`JEDI_ROOT` throughout the JEDI documentation. You may call this directory what ever you wish, but :code:`jedi` is a good choice! Once you create this directory, export it as an environment variable for convenience:

.. code-block:: bash

   mkdir <path-to-root>/jedi
   export $JEDI_ROOT=<path-to-root>/jedi

Next, navigate into your :code:`JEDI_ROOT` and clone the **GitHub** repository that contains the bundle you want. For the publicly available bundles, clone from **https://github.com/JCSDA**:

.. code-block:: bash

   cd $JEDI_ROOT
   git clone https://github.com/JCSDA/fv3-bundle.git

Alternatively, developers with access to the internal repositories should instead clone the development branch. For the internal repositories, clone from **https://github.com/jcsda-internal**:

.. code-block:: bash

   cd $JEDI_ROOT
   git clone https://github.com/jcsda-internal/fv3-bundle.git


Step 2: Choose your Repos
-------------------------

As executed above in Step 1, cloning a bundle will create a directory :code:`<JEDI_ROOT>/<your-bundle>`. This checkout of the bundle will be referred to as the :code:`JEDI_SRC` (source). Export this as an evironment variable like you did for the :code:`JEDI_ROOT`. For the :code:`fv3-bundle`:

.. code-block:: bash

  export JEDI_SRC=$JEDI_ROOT/fv3-bundle


Navigate (:code:`cd`) into this source directory and have a look (modify this as needed if you used a different path or a different bundle).  There's not much there.  There is a :code:`README` file that you might want to consult for specific information on how to work with this bundle.  But in this Step we'll focus on the :code:`CMakeLists.txt` file.  This contains a list of repositories that the application needs to run.  In the case of **fv3-bundle** that list looks something like this:

.. code-block:: cmake

   ecbuild_bundle( PROJECT oops     GIT "https://github.com/JCSDA/oops.git"         BRANCH develop UPDATE )
   ecbuild_bundle( PROJECT gsw      GIT "https://github.com/JCSDA/GSW-Fortran.git"  BRANCH develop UPDATE )
   ecbuild_bundle( PROJECT crtm     GIT "https://github.com/JCSDA/crtm.git"         BRANCH develop UPDATE )
   ecbuild_bundle( PROJECT ioda     GIT "https://github.com/JCSDA/ioda.git"         BRANCH develop UPDATE )
   ecbuild_bundle( PROJECT ufo      GIT "https://github.com/JCSDA/ufo.git"          BRANCH develop UPDATE )


The lines above tell :code:`ecbuild` which specific branches to retrieve from each GitHub repository.  **Modify these accordingly if you wish to use different branches.**  When you then run :code:`ecbuild` as described in :ref:`Step 3 <build-step3>` below, it will first check to see if these repositories already exist on your system, within the directory of the bundle you are building.  If not, it will clone them from GitHub.  Then :code:`ecbuild` will proceed to checkout the branch specified by the :code:`BRANCH` argument, fetching it from GitHub if necessary.

If the specified branch of the repository already exists on your system, then :code:`ecbuild` will **not** fetch it from GitHub.  If you want to make sure that you are using the latest and greatest version of the branch, then there are two things you need to do.

First, you need to include the (optional) :code:`UPDATE` argument in the :code:`ecbuild_bundle()` call as shown in each of the lines above.  Second, you need to explicitly initiate the update by running :code:`make update` as described in Step 4.

This will tell ecbuild to do a fresh pull of each of the branches that include the :code:`UPDATE` argument.  Note that :code:`make update` will not work if there is no Makefile in the build directory.  So, this command will only work *after* you have already run :code:`ecbuild` at least once.

If you are a developer, you will, by definition, be modifying the code.  And, if you are a legitimate *JEDI Master*, you will be following the :ref:`gitflowapp-top` workflow.  So, you will have created a feature (or bugfix) branch on your local computer where you are implementing your changes.

For illustration, let's say we created a feature branch of ufo called :code:`feature/newstuff`, which exists on your local system.  Now we want to tell :code:`ecbuild` to use this branch to compile the bundle instead of some other remote branch on GitHub.  To achieve this, we would change the appropriate line in the CMakeLists.txt file to point to the correct branch and we would remove the :code:`UPDATE` argument:

.. code-block:: cmake

   ecbuild_bundle( PROJECT ufo GIT "<JEDI_ROOT>/fv3-bundle/ufo" BRANCH feature/newstuff )

This may be all you need to know about :code:`ecbuild_bundle()` but other options are available.  For example, if you would like to fetch a particular release of a remote GitHub repository you can do this:

.. code-block:: cmake

   ecbuild_bundle( PROJECT eckit GIT "https://github.com/ECMWF/eckit.git" TAG 0.18.5 )

For further information see the `cmake/ecbuild_bundle.cmake <https://github.com/ecmwf/ecbuild/blob/develop/cmake/ecbuild_bundle.cmake>`_ file in `ECMWF's ecbuild repository <https://github.com/ECMWF/ecbuild>`_.

.. _build-step3:

Step 3: Run ecbuild (from the build directory)
----------------------------------------------

After you have chosen which repositories to build, the next step is to create a build directory and export it as :code:`JEDI_BUILD` for convenience:

.. code-block:: bash

    cd $JEDI_ROOT
    mkdir build
    export JEDI_BUILD=$JEDI_ROOT/build

Then, from that build directory, run :code:`ecbuild`, specifying the path to the directory that contains the source code for the bundle you wish to build:

.. code-block:: bash

    cd $JEDI_ROOT/build
    ecbuild $JEDI_SRC

Here we have used :code:`$JEDI_SRC` as our source directory and :code:`$JEDI_ROOT/build` as our build directory.  Feel free to change this as you wish, but just **make sure that your source and build directories are different**. This command should work for most bundles, and in particular when working on a preconfigured HPC or AWS instance. The ecbuild command may take several minutes to run.

In case :code:`cmake` is picking up the wrong :code:`python3` interpreter, an optional argument to the :code:`ecbuild` command can be used to specify the correct :code:`python3` interpreter during the build process. When using the modules provided by :code:`spack-stack`, the argument :code:`-DPython3_EXECUTABLE=${python_ROOT}/bin/python3` will guarantee that the spack-stack :code:`python3` interpreter is getting used. A similar method can be used to point to another :code:`python3` installation.

.. warning::

    **Some bundles may require you to run a build script prior to or in lieu of running ecbuild, particularly if you are running on an HPC system. Check the README file in the top directory of the bundle repository to see if this is necessary, particularly if you encounter problems running ecbuild, cmake, or ctest.**

As described in :ref:`cmake_devtools`, ecbuild is a sophisticated interface to CMake.  So, if there are any CMake options or arguments you wish to invoke, you can pass them to ecbuild and it will kindly pass them on to CMake.  The general calling syntax is:

.. code-block:: bash

   ecbuild [ecbuild-options] [--] [cmake-options] <src-directory>

Where :code:`src-directory` is the path to the source code of the bundle you wish to build (in this case, your :code:`JEDI_SRC`).  The most useful ecbuild option is debug:

.. code-block:: bash

   ecbuild --build=debug $JEDI_SRC

This will invoke the debug flags on the C++ and Fortran compilers and it will also generate other output that may help you track down errors when you run applications and/or tests.  You can also specify which compilers you want and you can even add compiler options.  For example:

.. code-block:: bash

   ecbuild -- -DCMAKE_CXX_COMPILER=/usr/bin/g++ -DCMAKE_CXX_FLAGS="-Wfloat-equal -Wcast-align" $JEDI_SRC


If you are working on an HPC system, then we recommend that your first check to see if there are :ref:`top-modules` installed on your system.  If your system is listed on this modules documentation page then you can simply load the modules as described there and you will have access to ecbuild, eckit, and many other third-party libraries. Also, be sure to check out the :ref:`hpc_users_guide` page for more information on HPCs.

If your system is not one that is supported by the spack-stack maintainers, then refer to the spack-stack instructions on how to generate a site config and install the environment yourself.

Step 4: Run make (from the build directory)
-------------------------------------------

After running ecbuild, the next step is to make sure the code is up to date.  You can do this by running :code:`make update` from the build directory as described in Step 2:

.. code-block:: bash

    make update

.. warning::

   Running :code:`make update` will initiate a :code:`git pull` operation for each of the repositories that include the :code:`GIT` and :code:`UPDATE` arguments in the call to :code:`ecbuild_bundle()` in :code:`CMakeLists.txt`.  So, if you have modified these repositories on your local system, there may be merge conflicts that you have to resolve before proceeding.

Now, at long last, you are ready to compile the code.  From the build directory, just type

.. code-block:: bash

   make -j4

The :code:`-j4` flag tells make to use four parallel processes.  Since many desktops, laptops, and of course HPC systems come with 4 or more compute cores, this can greatly speed up the compile time.  Feel free to increase this number if appropriate for your hardware.

The most useful option you're likely to want for :code:`make` other than :code:`-j` is the verbose option, which will tell you the actual commands that are being executed in glorious detail:

.. code-block:: bash

   make VERBOSE=1 -j4

As usual, to see a list of other options, enter :code:`make --help`.

Again, the compile can take some time (10 minutes or more) so be patient.   Then, when it finishes, the next step is to run the test following the instructions in :ref:`jedi-testing`.

If the parallel compile fails, the true error may not be in the last line of the output because all processes are writing output simultaneously and some may still continue while another fails.  So, in that case, it can be useful to re-run :code:`make` with only a single process.  Omitting the :code:`-j` option is the same as including :code:`-j1`:

.. code-block:: bash

   make VERBOSE=1
