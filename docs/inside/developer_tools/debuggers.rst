
Debugging Tools
===============


Building with Debug flags
---------------------------

When profiling or debugging, it is normally necessary to pass ``-g`` or other flags to cause the compiler to emit debugging symbols.  CMake uses a *build type* to control the compiler flags used for optimization and debugging.  The `CMAKE_BUILD_TYPE variable`_ is used to set the build type.

Currently the following build types are supported by the JEDI `ecbuild`_ bundles:

* ``CMAKE_BUILD_TYPE=Release``: Optimized for performance, disables all debugging options. **[Default]**
* ``CMAKE_BUILD_TYPE=Debug``: Enables debugging and sanitizer options that incur significant performance overhead.

If no build type is specified the ``Release`` build type will be used.  Only use the ``Debug`` build type when testing or debugging non-performance related issues, as it will significantly effect performance.

To add ``-g`` and other debugging flags to the ``Release`` builds, set the following environment variables, and the remove the build directory and rebuild the bundle completely:

::

  export CFLAGS="-g"
  export CXXFLAGS="-g"
  export FFLAGS="-g"
  export LDFLAGS="-Wl,-z,now"

.. note::

  The ``LDFLAGS="-Wl,-z,now`` flag is recommended when debugging or profiling.   From `man ld`_, the ``-z now`` option had the following effect:

    When generating an executable or shared library, mark it to tell the dynamic linker to resolve all   symbols when the program is started, or when the shared library is linked to using dlopen, instead of deferring function call resolution to the point when the function is first called.

  Allowing the default behavior of ``-z lazy`` can confuse debuggers and performance profilers, as symbol resolution and dynamic library loading will occur during debugging.

.. _ecbuild: https://github.com/ecmwf/ecbuild
.. _man ld: https://linux.die.net/man/1/ld
.. _CMAKE_BUILD_TYPE variable: https://cmake.org/cmake/help/latest/variable/CMAKE_BUILD_TYPE.html

