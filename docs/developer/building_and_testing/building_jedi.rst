.. _build-jedi:

Building and compiling JEDI
=============================

As described in detail :doc:`elsewhere <../developer_tools/cmake>`, the procedure for building and compiling JEDI rests heavily on the software tools :code:`CMake` and :code:`ecbuild`, which make your life much easier.  A typical workflow proceeds in the following steps:

1. Clone the desired JEDI **bundle**
2. Optionally edit the :code:`CMakeLists.txt` file in the bundle to choose the code branches you want to work with
3. :code:`cd` to the build directory and run :code:`ecbuild` to generate the Makefiles and other infrastructure
4. Run :code:`make` to compile the code
5. Run :code:`ctest` to verify that the bundle is working correctly

In terms of the actual commands you would enter, these steps will look something like this:

.. code:: bash

    cd <src-directory>
    git clone https://github.com/JCSDA/ufo-bundle.git
    cd <build-directory>
    ecbuild <src-directory>/ufo-bundle
    make -j4
    ctest

In this document we describe Steps 1 through 4, including the various options you have available to you at each step.  For a description of Step 5, see our page on :doc:`JEDI unit testing <unit_testing>`.

You will probably only need to do Step 1 once.  However, if you are a developer who is making changes to one or more JEDI repositories, you will likely find it useful to execute Steps 2 through 5 multiple times, with progressively increasing frequency.  For example, if you are working with a single repository, you may only need to do Step 2 once in order to tell ecbuild to compile your local branch.  And, you'll only need to run :code:`ecbuild` (Step 3) occasionally, when you make changes that affect the directory tree or complilation (for example, adding a file that was not there previously or substantially altering the dependencies).  By comparison, you will likely execute Steps 4 and 5 frequently as you proceed to make changes and test them.


.. _git-config:

Precursor: System Configuration
---------------------------------

Before jumping into the actual building of JEDI, we highly recommend that you read this section.  This information will let you avoid the need to enter your GitHub password many times during the JEDI build process, which can be annoying to say the least.  And, it will allow you to avoid errors when using a bundle that requires multiple MPI threads.

All JEDI repositories are stored and distributed by means of `GitHub <https://github.com>`_.   If you have used :code:`git` before, then you probably already have a :code:`.gitconfig` configuration file in your home directory.  If you have not already done so at some point in the past, you can create a git configuration file by specifying your GitHub username and email as follows:

.. code:: bash
	  
   git config --global user.name <username-for-github>
   git config --global user.email <email-used-for-github>

This is a recommended action for any user of GitHub since it governs how you access GitHub with :code:`git`.  However, there is another action that you may not have set up previously but that will be immensely useful to all JEDI users and developers: tell GitHub to cache your GitHub credentials:

.. code:: bash
	  
   git config --global credential.helper 'cache --timeout=3600'
   
This tells GitHub to keep your GitHub login information for an hour, i.e. 3600 seconds (feel free to increase this time if you wish).  If you don't do this, you may regret it - you'll have to enter your GitHub password repeatedly throughout the build process as ecbuild proceeds to clone multiple GitHub repositories.

The statement above should be sufficient on most systems.   However, on some systems (particularly HPC systems with stringent security protocols), it may be necesary to explicitly give git permission to store your GitHub password unencrypted on disk as follows:

.. code:: bash

    git config --global --add credential.helper 'store'

As for all your files, your password will still be protected by the security protocols necessary to simply access the system as a whole and your own filesystem in particular.  So, this should still be pretty secure on HPC systems but you might want to use it with caution in less secure environments such as laptops or desktops.  For other alternatives, see the documentation on `git credentials <https://git-scm.com/docs/gitcredentials>`_.

Another action that might make your life easier is to set the following environment variable:

.. code:: bash

    export FC=mpifort

This is required in order to run with multiple MPI threads within the JEDI :doc:`CharlieCloue <../jedi_environment/charliecloud>` and :doc:`Singularity <../jedi_environment/singularity>` containers, which uses OpenMPI.  You may wish to put this in a :ref:`startup-script <startup-script>` so you don't have to enter it manually every time you enter the Container.  If you run outside the container, some bundles include customized build scripts that will take care of this for you.  Consult the :code:`README` file in the bundle's repository for details.  If you run :code:`make` and it complains about not finding mpi-related files, try cleaning your build directory (to wipe the CMake cache), setting the :code:`FC` environment variable as indicated above, and then proceeding with :code:`ecbuild` as described in Step 3 below.

Another thing to keep in mind is that some JEDI tests require six MPI task to run.  This is just for ufo-bundle; other bundles may require even more.  Chances are good that your machine (whether it be a laptop, a workstation, a cloud computing instance, or whatever), may have fewer than six compute cores.

If your machine has fewer than six compute cores, you may need to explicitly give openmpi permission to run more than one MPI task on each core.  To do this, go to the directory :code:`~/.openmpi` (create it if it doesn't already exist).  In that directory, execute this command:

.. code:: bash

    echo "rmaps_base_oversubscribe = 1" > mca-params.conf
    

Step 1: Clone the Desired JEDI Bundle
-------------------------------------

JEDI applications are organized into high-level **bundles** that conveniently gather together all the repositories necessary for that application to run.  Often a bundle is associated with a particular model, such as **FV3** or **MPAS**.  

So, to start your JEDI adventure, the first step is to create a directory as a home for your bundle (or bundles--plural--if you're ambitious!).  Here we will use :code:`~/jedi/src` but feel free to call it whatever you wish.  Then clone the **GitHub** repository that contains the bundle you want, as demonstrated here: 

.. code:: bash

    cd ~/jedi
    mkdir src
    cd src
    git clone https://github.com/JCSDA/ufo-bundle.git

	  
Step 2: Choose your Repos
--------------------------

As executed above, Step 1 will create a directory called :code:`~/jedi/src/ufo-bundle`.  :code:`cd` to this directory and have a look (modify this as needed if you used a different path or a different bundle).  There's not much there.  There is a :code:`README` file that you might want to consult for specific information on how to work with this bundle.  But in this Step we'll focus on the :code:`CMakeLists.txt` file.  This contains a list of repositories that the application needs to run.  In the case of **ufo-bundle** that list looks like this:

.. code:: bash 

   #ecbuild_bundle( PROJECT eckit    GIT "https://github.com/ECMWF/eckit.git"        TAG 0.18.5 )
   #ecbuild_bundle( PROJECT fckit    GIT "https://github.com/ECMWF/fckit.git"        TAG 0.5.0  )
   ecbuild_bundle( PROJECT oops  GIT "https://github.com/JCSDA/oops.git"   BRANCH develop UPDATE )
   ecbuild_bundle( PROJECT crtm  GIT "https://github.com/JCSDA/crtm.git"  BRANCH develop UPDATE )
   ecbuild_bundle( PROJECT ioda  GIT "https://github.com/JCSDA/ioda.git"  BRANCH develop UPDATE )
   ecbuild_bundle( PROJECT ufo   GIT "https://github.com/JCSDA/ufo.git"   BRANCH develop UPDATE )

Note that the first two lines are commented out with :code:`#`.  This is because eckit and fckit are already installed in the JEDI :doc:`CharlieCloud <../jedi_environment/charliecloud>` and :doc:`Singularity <../jedi_environment/singularity>` containers so if you are running inside the container, there is no need to build them again.  If you are running outside of the containers and if you have not yet installed these packages on your system, then you may wish to uncomment those two lines.  Or, you may wish to install these packages yourself so you can comment these lines out in the future.  Be warned that can be a bit of a challenge if you are on an HPC system, for example, and you do not have write access to :code:`/usr/local`.  For more information on how to install these packages see our JEDI page on :doc:`ecbuild and cmake <../developer_tools/cmake>`.

As described :doc:`there <../developer_tools/cmake>`, **eckit** and **fckit** are software utilities provided by ECMWF that are currently used by JEDI to read configuration files, handle error messages, configure MPI libraries, test Fortran code, call Fortran files from C++, and perform other general tasks.  Note that the eckit and fckit repositories identified are obtained directly from ECMWF.

The lines shown above tell ecbuild which specific branches to retrieve from each GitHub repository.  **Modify these accordingly if you wish to use different branches.**  When you then run :code:`ecbuild` as described in :ref:`Step 3 <build-step3>` below, it will first check to see if these repositories already exisit on your system, within the directory of the bundle you are building.  If not, it will clone them from GitHub.  Then :code:`ecbuild` will proceed to checkout the branch specified by the :code:`BRANCH` argument, fetching it from GitHub if necessary.

If the specified branch of the repository already exists on your system, then :code:`ecbuild` will **not** fetch it from GitHub.   If you want to make sure that you are using the latest and greatest version of the branch, then there are two things you need to do.

First, you need to include the (optional) :code:`UPDATE` argument in the :code:`ecbuild_bundle()` call as shown in each of the lines above.  Second, you need to explicitly initiate the update as follows:

.. code:: bash

   cd <build-directory>
   make update

This will tell ecbuild to do a fresh pull of each of the branches that include the :code:`UPDATE` argument.  Note that :code:`make update` will not work if there is no Makefile in the build directory.  So, this command will only work *after* you have already run :code:`ecbuild` at least once.

.. warning::
   
   Running :code:`make update` will initiate a :code:`git pull` operation for each of the repositories that include the :code:`GIT` and :code:`UPDATE` arguments in the call to :code:`ecbuild_bundle()` in :code:`CMakeLists.txt`.  So, if you have modified these repositories on your local system, there may be merge conflicts that you have to resolve before proceeding.

If you are a developer, you will, by definition, be modifying the code.  And, if you are a legitimate *JEDI Master*, you will be following the :doc:`git flow <../developer_tools/getting-started-with-gitflow>` workflow.  So, you will have created a feature (or bugfix) branch on your local computer where you are implementing your changes.

For illustration, let's say we created a feature branch of ufo called :code:`feature/newstuff`, which exists on your local system.  Now we want to tell :code:`ecbuild` to use this branch to compile the bundle instead of some other remote branch on GitHub.  To achieve this, we would change the appropriate line in the CMakeLists.txt file as follows:

.. code:: bash

   ecbuild_bundle( PROJECT ufo SOURCE "~/jedi/src/ufo-bundle/ufo" )

This will use whatever branch of the specified repository that is currently checked out on your system.  As written above, ecbuild will not check out the branch for you.  This is usually not a problem because it is likely that you have the appropriate branch checked out already if you are making modifications to it.  However, if you do want to insist that ecbuild switch to a particular local branch before compiling, then there is indeed a way to do that:

.. code:: bash

   ecbuild_bundle( PROJECT ufo GIT "~/jedi/src/ufo-bundle/ufo" BRANCH feature/newstuff )

This may be all you need to know about :code:`ecbuild_bundle()` but other options are available.  For example, if you would like to fetch a particular release of a remote GitHub repository you can do this:

.. code:: bash

   ecbuild_bundle( PROJECT eckit GIT "https://github.com/ECMWF/eckit.git" TAG 0.18.5 )

For further information see the `cmake/ecbuild_bundle.cmake <https://github.com/ecmwf/ecbuild/blob/develop/cmake/ecbuild_bundle.cmake>`_ file in `ECMWF's ecbuild repository <https://github.com/ECMWF/ecbuild>`_.

.. _build-step3:
   
Step 3: Run ecbuild (from the build directory)
----------------------------------------------

After you have chosen which repositories to build, the next step is to create a build directory (if needed):

.. code:: bash

    cd ~/jedi
    mkdir build

Then, from that build directory, run :code:`ecbuild`, specifying the path to the directory that contains the source code for the bundle you wish to build:

.. code:: bash

    cd ~/jedi/build
    ecbuild ../src/ufo-bundle

Here we have used :code:`~/jedi/src` as our source directory and :code:`~jedi/build` as our build directory.  Feel free to change this as you wish, but just **make sure that your source and build directories are different**.  

This should work for most bundles but if it doesn't then check in the bundle source directory to see if there are other **build scripts** you may need to run.  This is particularly true if you are running outside of the JEDI :doc: `CharlieCloud <../jedi_environment/charliecloud>` and :doc:`Singularity <../jedi_environment/singularity>` containers.  These build scripts are customized for each bundle and instructions on how to use them can be found in the :code:`README` file in the top level of the bundle repository.

.. warning::
   
    **Some bundles may require you to run a build script prior to or in lieu of running ecbuild, particularly if you are running outside of the CharlieCloud and Singularity containers.  Check the README file in the top directory of the bundle repository to see if this is necessary, particularly if you encounter problems running ecbuild, cmake, or ctest.**

After you enter the ecbuild command, remember to practice patience, dear `padawan <http://starwars.wikia.com/wiki/Padawan>`_.  The build process may take less than a minute for ufo-bundle but for some other bundles it can take twenty minutes or more, particularly if ecbuild has to retrieve a number of large restart files from a remote :doc:`Git LFS store <../developer_tools/gitlfs>` over a wireless network.

As described :doc:`here <../developer_tools/cmake>`, ecbuild is really just a sophisticated (and immensely useful!) interface to CMake.  So, if there are any CMake options or arguments you wish to invoke, you can pass them to ecbuild and it will kindly pass them on to CMake.  The general calling syntax is:

.. code:: bash

   ecbuild [ecbuild-options] [--] [cmake-options] <src-directory>	  

Where :code:`src-directory` is the path to the source code of the bundle you wish to build.  The most useful ecbuild option is debug:

.. code:: bash

   ecbuild --build=debug ../src/ufo-bundle

This will invoke the debug flags on the C++ and Fortran compilers and it will also generate other output that may help you track down errors when you run applications and/or tests.  You can also specify which compilers you want and you can even add compiler options.  For example:

.. code:: bash

   ecbuild -- -DCMAKE_CXX_COMPILER=/usr/bin/g++ -DCMAKE_CXX_FLAGS="-Wfloat-equal -Wcast-align" ../src/ufo-bundle


Now Let's say that you're working on an HPC system where you do not have the privileges to install Singularity.  If this is the case then we recommend that your first check to see if there are :doc:`JEDI modules <../jedi_environment/modules>` installed on your system.   If your system is listed on this modules documentation page then you can simply load the JEDI module as described there and you will have access to ecbuild, eckit, and other JEDI infrastructure.

If your system is not one that is supported by the JEDI team, then a second option is to install :doc:`CharlieCloud <../jedi_environment/charliecloud>` in your home directory and run JEDI from within the Charliecloud container.

A third option is for you to install eckit on your system manually (not recommended).  If you do this, then you may have to tell ecbuild where to find it with this command line option:

.. code:: bash

   ecbuild -- -DECKIT_PATH=<path-to-eckit> ../src/ufo-bundle

For more information, enter :code:`ecbuild --help` and see our JEDI page on :doc:`ecbuild and cmake <../developer_tools/cmake>`.

Step 4: Run make (from the build directory)
----------------------------------------------

Now, at long last, you are ready to compile the code.  From the build directory, just type

.. code:: bash

    make -j4	  

    
The :code:`-j4` flag tells make to use four parallel processes.  Since many desktops, laptops, and of course HPC systems come with 4 or more compute cores, this can greatly speed up the compile time.

The most useful option you're likely to want for :code:`make` other than :code:`-j` is the verbose option, which will tell you the actual commands that are being executed in glorious detail:

.. code:: bash

    make -j4 VERBOSE=1	  

As usual, to see a list of other options, enter :code:`make --help`.

Again, the compile can take some time (10 minutes or more) so be patient.   Then, when it finishes, the next step is to :doc:`run ctest <unit_testing>`.
