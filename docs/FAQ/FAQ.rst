###########################################################
Frequently Asked Questions Regarding Building JEDI Software
###########################################################

Why do I get segmentation faults when I try to run tests?
----------------------------------------------------------

This can be caused by a stack-overflow if the stack size has been limited.  On Linux systems, ensure the stack size and
virtual memory limits are set to unlimited:

.. code:: bash

    $ ulimit -s unlimited
    $ ulimit -v unlimited

On MacOS(OSX) systems the Mach-based kernel typically enforces a hard upper limit which can be queried by :code:`ulimit -Hs`.
To set the stack size to this maximum allowable limit use:

.. code:: bash

    $ ulimit -s $(ulimit -Hs)

How can I disable the building of a package in an ECBuild bundle?
------------------------------------------------------------------

Set the CMake variable :code:`BUNDLE_SKIP_<PKGNAME>=1`, where ``PKGNAME`` is the all upper-case version of the package
named in the :code:`ecbuild_bundle(PROJECT pkgname ...)` command. For example to disable building :code:`fckit:`

.. code:: bash

    $ ecbuild -DBUNDLE_SKIP_FCKIT=1 <other-args>


How can I force CMake to disable finding an optional package?
--------------------------------------------------------------

The :code:`CMake find_package(PkgName)` command can be disabled by setting the CMake variable
:code:`CMAKE_DISABLE_FIND_PACKAGE_PkgName=1` where *PkgName* matches the case used in :code:`find_package()`. For
example, :code:`oops/CMakeLists.txt calls find_package(OpenMP)`. This represents an optional package dependency for
*oops* because there is no :code:`REQUIRED` argument. If desired, the entire search for :code:`OpenMP` can be
disabled, causing oops to be built without :code:`OpenMP` support enabled.

.. code:: bash

    $ cmake -DCMAKE_DISABLE_FIND_PACKAGE_OpenMP=1 <other-args>


How can I force CMake to find a package at a specific prefix?
--------------------------------------------------------------

Set either an environment variable or a CMake variable with the value ``PkgName_ROOT=<pkg-install-prefix>``,
where ``PkgName`` matches the case exactly as used in the ``find_package(PkgName)`` command. For example, to force
the ``find_package(eckit)`` command to look in ``/opt/eckit``, you would set an environment variable:

.. code:: bash

    $ export eckit_ROOT=/opt/eckit
    $ ecbuild <normal-args>

or use a CMake variable:

.. code:: bash

    $ ecbuild -Deckit_ROOT=/opt/eckit <normal-args>

CMake says it wasn't able to compile a test program with my compilers.  What is wrong?
---------------------------------------------------------------------------------------

At the very beginning of the CMake configuration step when the

.. code:: bash

    project( foo LANGUAGES C CXX Fortran )

line of code at the top of the CMakeLists.txt is processed, CMake will attempt to find the compilers based on
the ``LANGUAGES`` specified. To set the compilers, CMake will first use the ``FC``, ``CC``, and ``CXX`` environment
variables. Set these to known working compiler names for your system. If CMake says it can't compile a simple
test program, there is likely something wrong with the compiler paths or environment variables. This is a good time
to use the :code:`cmake --debug-trycompile` flag. This will cause CMake to more verbosely print out what it is trying
to compile, and it will save the attempted test-builds under ``<bindir>/CMakeFiles/CMakeTmp``.
See: `try_compile <https://cmake.org/cmake/help/latest/command/try_compile.html>`_


My build failed on the CMake configure phase. How can I debug?
-------------------------------------------------------------------

Within the CMake build directory, CMake will store a variable cache called :code:`CMakeCache.txt`. This file can be
searched for problem package names. All packages found with :code:`find_package()` will set variables in the cache
and if these variables have ``incorrect`` locations, you have found the problem. Also, the
:code:`cmake -LA` command can print out all the CMAKE cache variables (it must be run from the build
directory).

CMake has several useful flags to aid debugging:

   * ``--log-level=debug`` - print more logging info. This also helps with ``ecbuild`` internal errors.
   * ``--debug-find`` - use this if you can't find a package.
   * ``--debug-trycompile`` - save the directories of test-compilations performed by ``cmake``.
   * ``--trace`` - log/print all actions; very verbose.

My build failed during the compilation phase. How should I debug?
------------------------------------------------------------------

First, build with ``-j1`` to ensure that the build will fail on the first error. Also, set the ``VERBOSE=1``
environment variable to cause the ``make`` to print out each command it executes.

.. code:: bash

    $ VERBOSE=1 make -j1

If the problem cannot be solved and a github issue must be created, the entire failing compiler line and error
messages should be posted verbatim.

I don't have internet access on my build machine.  Can I still build a JEDI bundle?
------------------------------------------------------------------------------------

Yes.  Normally this happens on a machine where the login nodes have internet access, but the compute nodes do not.
First, on a node with outside internet access, make sure the bundle and all sub-packages are cloned and have
the latest changes fetched from upstream.  A successful run of ``ecbuild`` on the bundle will get to this state.
From this point on, it will be possible to build by calling ``make`` without requiring internet access.  However, if
the branch names in the bundle's ``CMakeLists.txt`` are modified and do not match what branch is currently
checked out for that package, the next call to ``make`` will call ``git fetch`` and attempt to checkout the
specified branch.  To prevent this fetch command, either:

1. Manually ``git checkout`` the correct branch for the package.  This can be done without internet access.
2. Or, replace the ``UPDATE`` keyword with ``NOREMOTE`` in the ``ecbuild_bundle()`` command.

If at some point you need to fetch changes from a remote repository, this can be done with ``make update`` in a separate
terminal window connected to the login-node.  Once the fetch and checkout are complete, the build can proceed on
the compute node without internet access.

.. _faq-netcdf-unknown-file-format:

``Error code: NetCDF: Unknown file format`` when running tests
--------------------------------------------------------------

This probably means that you have not initialized git large file service (LFS).

JEDI test files, many of which are in NetCDF format, are not stored directly on GitHub.  This would make the size of the repositories too large.  Instead, NetCDF and other data files are stored on an external data store.  To tell git where to find them, you must enable LFS by entering the following command:

.. code-block:: bash

   git lfs install

You can run this command from anywhere, though ``git`` might give you a warning if you are not in a git repository.  It sets up global filters which you can see by running ``cat ~/.gitconfig`` or ``git config --list``.  So, you only need to do it once.  But, after enabling it, we recommend that you delete your bundle source directory, re-clone it from GitHub, and rebuild the bundle.

My test/application is running very slowly
------------------------------------------

If your test or application is running more slowly than you expect, you might try setting this environment variable to disable OpenMP threading (this is ``bash`` syntax; use ``setenv`` instead if you use ``tcsh``):

.. code-block:: bash

   export OMP_NUM_THREADS=1

This is because, on some systems, ``OpenMP`` will probe the hardware and set the number of threads equal to the number of cores.  However, currently for most JEDI applications and tests, we often wish to assign one MPI task to a core.  Redundant parallelization over both MPI tasks and OpenMP threads can lead to excessive overhead that can slow down your application.  So, this sets the number of threads to one.  In the future we will make more use of OpenMP threading but until then, setting this environment variable can speed up applications in some circumstances.

I get warnings when running ``ecbuild`` and the python tests fail
-----------------------------------------------------------------

This question is relevant if you see warnings like the following when running ``ecbuild``:

.. code-block:: bash

    runtime library [libz.so.1] in /usr/local/lib may be hidden by files in:
      /usr/local/miniconda3/lib
    runtime library [libgomp.so.1] in /usr/lib/gcc/x86_64-linux-gnu/9 may be hidden by files in:
      /usr/local/miniconda3/lib

This is often accompanied by failure of the python tests in ``ioda``.  A likely cause of this is the use of ``anaconda`` or ``miniconda3`` for python package management.

Conda installs its own packages like ``hdf5``, ``NetCDF``, and ``openssl`` that can conflict with libraries installed via the `spack-stack <https://github.com/noaa-emc/spack-stack.git>`_. This applies in particular to the `IODA Python API <https://jointcenterforsatellitedataassimilation-jedi-docs.readthedocs-hosted.com/en/develop/learning/tutorials/level3/ioda-python-api.html>`_, which is now enabled by default in ``ioda``.

These conflicts are not easily addressed since the dependencies are built into ``conda`` through `rpaths <https://en.wikipedia.org/wiki/Rpath>`_.  At this time we recommend that you avoid using conda if possible when building and running JEDI applications, and use alternative methods described in the `spack-stack documentation <https://spack-stack.readthedocs.io/en/spack-stack-1.0.1/MaintainersSection.html#testing-adding-packages-outside-of-spack>`_ instead.

Git LFS Smudge error when running ``ecbuild``
---------------------------------------------

On some systems with older versions of ``git lfs``, you might see a message like this when building the develop branch of a bundle with ``ecbuild``:

.. code-block:: bash

   Error downloading object:
   <usually-a-netcdf-file>
   ...Smudge error: Error downloading
   ...
   bash response: Rate limit exceeded

This only happens on the ``develop`` branches because this is when ``ecbuild`` downloads the :doc:`lfs-enabled <../inside/developer_tools/gitlfs>` git data repositories like ``ioda-data``, ``ufo-data``, ``saber-data``, ``fv3-data``, and ``mpas-data``.

The solution is to ``cd`` to the source directory in question.  This is usually located in the bundle source directory, e.g. ``fv3-bundle/saber-data``.  Then manually enter

.. code-block:: bash

    git lfs pull

You might have to do this several times until the command runs without giving warnings.  At that point, you may notice that ``git`` shows changes to the local files in the repo.  So, to abandon all local changes, enter:

.. code-block:: bash

   git reset --hard

You should only have to do this with your bundle once, when the data repositories are cloned for the first time.  Subsequent updates with ``make update`` should involve fewer files and are less likely to trigger that error.
