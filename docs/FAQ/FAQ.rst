###########################################################
Frequently Asked Questions Regarding Building JEDI Software
###########################################################

Why do I get segmentation faults when I try run tests?
------------------------------------------------------

This is often associated with a limited stack size and is exacerbated by some compilers (e.g. intel) and some
compiler options (e.g. high optimization levels, enabling OpenMP). On linux systems, it can often be solved by
increasing the stack size as follows (it doesn't hurt to also increase the virtual memory):

.. code:: bash

    $ ulimit -s unlimited
    $ ulimit -v unlimited


How can I disable the building of a particular package in an ecbuild bundle?
----------------------------------------------------------------------------

Set the CMake variable :code:`BUNDLE_SKIP_<PKGNAME>=1`, where PKGNAME is the all upper-case version of the package
named in the :code:`ecbuild_bundle(PROJECT pkgname ...)` command. For example to disable building :code:`fckit:`

.. code:: bash

    $ ecbuild -DBUNDLE_SKIP_FCKIT=1 <other-args>


How can I force CMake (or ecbuild) to disable finding an optional package that I don't want enabled?
----------------------------------------------------------------------------------------------------

The :code:`CMake find_package(PkgName)` command can be disabled by setting the CMake variable
:code:`CMAKE_DISABLE_FIND_PACKAGE_PkgName=1` where *PkgName* matches the case used in :code:`find_package()`. For
example, :code:`oops/CMakeLists.txt calls find_package(OpenMP)`. This represents an optional package dependency for
*oops* because there is no :code:`REQUIRED` argument. If desired, the entire search for :code:`OpenMP` can be
disabled, causing oops to be built without :code:`OpenMP` support enabled.

.. code:: bash

    $ cmake -DCMAKE_DISABLE_FIND_PACKAGE_OpenMP=1 <other-args>

My bundle build failed during the CMake configure phase. What should I do to debug?
-----------------------------------------------------------------------------------

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

What should I do if CMake says it wasn't even able to compile a simple test program with my compilers?
------------------------------------------------------------------------------------------------------

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

How can I force CMake to find a package I have installed to a particular prefix?
--------------------------------------------------------------------------------

Set either an environment variable or a CMake variable with the value ``PkgName_ROOT=<pkg-install-prefix>``,
where ``PkgName`` matches the case exactly as used in the ``find_package(PkgName)`` command. For example, to force
the ``find_package(eckit)`` command to look in ``/opt/eckit``, you would set an environment variable:

.. code:: bash

    $ export eckit_ROOT=/opt/eckit
    $ ecbuild <normal-args>

or use a CMake variable:

.. code:: bash

    $ ecbuild -Deckit_ROOT=/opt/eckit <normal-args>

My bundle build failed during the compilation phase. What should I do to debug?
-------------------------------------------------------------------------------

First, build with ``-j1`` to ensure that the build will fail on the first error. Also, set the ``VERBOSE=1``
environment variable to cause the ``make`` to print out each command it executes.

.. code:: bash

    $ VERBOSE=1 make -j1

If the problem cannot be solved and a github issue must be created, the entire failing compiler line and error
messages should be posted verbatim.
