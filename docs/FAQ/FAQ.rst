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
