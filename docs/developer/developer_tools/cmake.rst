
CMake, CTest, and ecbuild
=========================

The JEDI manufacturing system (build, test and package) is based on the
`CMake <https://cmake.org/>`_ tool suite.
CMake is open source and it's purpose is to facilitate the creation of make files that
can be used to compile, test and install your software.
For example, you can tell CMake that you need the netcdf and openmpi libraries, and it
will automatically find those on your machine and place necessary paths, in the
make files it generates, for compiling and linking your source code.
CMake is in widespread use and the CMake website includes
`documentation and tutorials <https://cmake.org/documentation/>`_ to help you get started.

CTest is the part of CMake that handles testing your code.
CTest allows for an easy way to run your newly built programs with various argument
and option settings, and then check the results against expected output.
This system is well suited for short, fast running tests that tend to be in the unit
level testing category.
We may need to go beyond CTest to address our large scale system testing that is geared
more toward performance benchmarking and verifying functionality on HPC systems.

`Ecbuild <https://github.com/UCAR/ecbuild>`_ is a set of CMake macros provided by the
ECMWF that assist with the specification of the manufacturing processes.
For example, ecbuild provides enhancement of CTest by linking in the
`Boost test framework <https://www.boost.org/doc/libs/1_67_0/libs/test/doc/html/index.html>`_.
Along with ecbuild we are using two ECMWF libraries called
`eckit <https://github.com/UCAR/eckit>`_ and `fckit <https://github.com/UCAR/fckit>`_.
Eckit is a C++ library that provides utilites including logging, MPI, configuration
file (JSON, YAML) parsing and math functions.
Fckit is a Fortran tool kit that provides similar utilities as eckit, plus helper functions
to convert strings and arrays between Fortran and C/C++, and extending the unit test
framework to Fortran.


CMake and CTest
---------------

The CMake developers provide a single package for CMake and CTest. Documentation and
downloads are available at the `CMake website <https://cmake.org/>`_.

Installing CMake and CTest
^^^^^^^^^^^^^^^^^^^^^^^^^^

This step is only necessary if you are working outside the
:ref:`Singularity container <build_env>`.

For the Mac, use `homebrew <https://brew.sh/>`_ to install CMake.

.. code:: bash

    brew install cmake

For Windows and Linux systems, see the `CMake downloads website <https://cmake.org/download/>`_
for packages and instructions.

Using CMake and CTest
^^^^^^^^^^^^^^^^^^^^^

At the heart of CMake are the CMakeLists.txt files.
These files are where the specification takes place for all manufacturing processes.
This specification may include items such as where the source code lives, dependencies
for that source code, what libraries to link in, configuration of tests and the selection
of programs and scripts for installation.
Here is a `CMake tutorial <https://cmake.org/cmake-tutorial/>`_ that is helpful for
getting an idea of what goes into a CMakeLists.txt file.
 
Once the CMakeLists.txt for a project are created, all one does to build, test and install
your software is:

.. code:: bash

    cmake <dir_where_toplevel_CMakeLists.txt_file>   # generate the make files

    make              # compile everthing
    ctest             # run the tests
    make install      # install the programs and scripts

In the example above, the <dir_where_toplevel_CMakeLists.txt_file> argument to cmake
is the Linux path to wherever the top level CMakeLists.txt file exists (only the
directory part of the path).
This path can be relative or absolute.
Here are some examples for running cmake:

.. code:: bash

    cmake .      # top level CMakeLists.txt is in the current directory

    cmake ..     # top level CMakeLists.txt is one up from the current directory

    cmake $HOME/projects/my-project   # top level CMakeLists.txt file lives
                                      # in $HOME/project/my-project

Output from the cmake command is captured in the following files:

.. code:: bash

    ./CMakeFiles/CMakeOutput.log   # messages from cmake
    ./CMakeFiles/CMakeError.log    # errors and warnings from cmake

The ctest command without arguments will run the entire set of tests.
In the case that you want to run a specific test or you want more information on tests
that failed, you can run individual tests using ctest as shown below.

.. code:: bash

    ctest -R test_ufo_radiosonde  # this runs just the one test

    ctest -R test_ufo_*           # file globbing and regular expression can be
                                  # applied to select a subset of tests to run

    ctest -V -R test_ufo_radiosonde   # -V increases the verbosity of output

Test output is captured in the files:

.. code:: bash

    ./Testing/Temporary/LastTest.log          # output from the last invocation of ctest
    ./Testing/Temporary/LastTestsFailed.log   # names of the tests that failed during
                                              # the last invocation of ctest

.. note::

  It is highly recommended that you build your code in a directory that is separate from
  the directory where the source code lives.
  CMake does not restrict you to do this, but doing so will keep the source directories free
  from all of the clutter that the build process produces such as object files, the
  generated make files, and additional CMake configuration and log files.
  If you build in a separate directory, one simple remove command will clean up the entire
  build area (without danger of removing source files) and keep the source git repository
  clear of extra files that you do not want to check into the repository.

CMake provides many controls which are enabled through specifying the -D command line option.
See the
`CMake variables documentation <https://cmake.org/cmake/help/v3.0/manual/cmake-variables.7.html>`_
for details.
This list is extensive, and probably the most relevant is
`CMAKE_INSTALL_PREFIX <https://cmake.org/cmake/help/v3.0/variable/CMAKE_INSTALL_PREFIX.html>`_,
which is used to specify where the programs and scripts are to be installed.
By default, this is /usr/local.
However, if you don't have write permission to /usr/local, then you will need this control
to be able to do the install step.
Let's say that you want to install in your home directory in the path $HOME/tools.
Then run cmake as follows:

.. code:: bash

    cmake -DCMAKE_INSTALL_PREFIX=$HOME/tools $HOME/projects/my-project


ecbuild
-------

For now the ecbuild, eckit and fckit packages should be cloned and built from the
`UCAR GitHub repositories <https://github.com/UCAR>`_.
The UCAR repositories are simply snapshots of the ECMWF repositories, which at the time
were private repositories.
Recently, the ECMWF has made available public repositories for these tools, and we are
planning on switching to those repositories in the near future.

Ecbuild does enforce the restriction recommended above on building your project outside of the
source directories.

Installing ecbuild
^^^^^^^^^^^^^^^^^^

As before, the steps shown in this section are only necessary if you are working outside the
:ref:`Singularity container <build_env>`.

For all systems, you need to have CMake, eigen3, and boost installed before installing
ecbuild.
To install these on the Mac:

.. code:: bash

    brew install cmake              # as shown above
    brew install eigen              # this will install eigen3

    brew install --cc=gcc-7 boost   # --cc tells brew to compile C/C++ using gcc version 7

The boost libraries will not have the proper names for routines (linking won't work) unless
they are built with the same gcc version that will be used for compiling JEDI projects.
On the Mac for this example, gcc version 7 is being used for all compiling.
If, for example, your Mac has gcc version 6, then the brew command in the example code above
should be changed to :code:`brew install --cc=gcc-6 boost`.

.. note::
  Gory details about the boost install: The issue is in the name mangling of the C++
  routines.
  The manner in which names are mangled changes with different C++ standards
  (C++03, C++11, etc.).
  Different versions of gcc default to different C++ standards, so the best thing to
  do is just force the boost compile to use the same version that subsequent
  compiles will use so that you don't have to worry about which C++ standard is
  being used.

For Windows and Linux systems, see the `CMake downloads website <https://cmake.org/download/>`_,
`Eigen website <http://eigen.tuxfamily.org/>`_ and
`Boost website <https://www.boost.org/>`_ for packages and instructions.

Since ecbuild is actually a collection of CMake macros there is no compiling
required, thus no need to run make nor ctest.
In the following example, the ecbuild clone is going to be placed in $HOME/projects and
the build directory will be $HOME/projects/ecbuild/build.

.. code:: bash

    # create the ecbuild clone and make sure you are on the master branch
    cd $HOME/projects
    git clone https://github.com/UCAR/ecbuild.git     # clone from UCAR for now

    cd ecbuild
    git checkout master

    # create the build directory
    mkdir build
    cd build

    # install ecbuild
    cmake ..        # This assumes that you have write permission in /usr/local
    make install
    
    # if you don't have permission to write into /usr/local
    cmake -DCMAKE_INSTALL_PREFIX=$HOME/tools ..
    make install

Once ecbuild is installed, it can be used to build and install the eckit and fckit
libraries.
Install eckit first before working on fckit since fckit is a package that builds upon
eckit and needs it to exist before compiling.
For the following code example, assume that the clones are placed in $HOME/projects
and the build directories are subdirectories of the clones called "build".

.. code:: bash

    # create the eckit clone
    cd $HOME/projects
    git clone https://github.com/UCAR/eckit.git

    cd eckit
    git checkout master

    # create the build directory
    mkdir build
    cd build

    # build, test, install eckit
    #
    # Note the use of ecbuild in place of cmake
    #
    # If no write permission in /usr/local, add -DCMAKE_INSTALL_PREFIX=$HOME/tools
    # to the ecbuild command.
    ecbuild ..
    make
    ctest
    make install

    ######### Repeat for fckit ###########
    cd $HOME/projects
    git clone https://github.com/UCAR/fckit.git

    cd fckit
    git checkout master

    # create the build directory
    mkdir build
    cd build

    # build, test, install fckit
    #
    # If no write permission in /usr/local, add -DCMAKE_INSTALL_PREFIX=$HOME/tools
    # to the ecbuild command.
    ecbuild ..
    make
    ctest
    make install


Using ecbuild
^^^^^^^^^^^^^

The ecbuild installation provides a command called ecbuild which is a direct replacement
for the cmake command.
Ecbuild simply loads its set of macros and then passes all appropriate arguments and options
on through to a call to cmake.
For example, you can use the option :code:`-DCMAKE_INSTALL_PREFIX` with ecbuild and this
gets passed through to cmake.

Ecbuild is the workhorse for building and testing (and eventually installing) the JEDI
software.
Once ecbuild and associated libaries (eigen3, boost, eckit, fckit) are installed, all
subsequent manufacturing is done using the ecbuild command in place of cmake.
The output from ecbuild is captured in the file:

.. code:: bash

    ./ecbuild.log

Ecbuild has its own options which can be inspected by running :code:`ecbuild --help`.
Here is sample output:

.. code:: bash
    
    >> ecbuild --help

    USAGE:
    
      ecbuild [--help] [--version] [--toolchains]
      ecbuild [option...] [--] [cmake-argument...] <path-to-source>
      ecbuild [option...] [--] [cmake-argument...] <path-to-existing-build>
    
    DESCRIPTION:
    
      ecbuild is a build system based on CMake, but providing a lot of macro's
      to make it easier to work with. Upon execution,
      the equivalent cmake command is printed.
    
      ecbuild/cmake must be called from an out-of-source build directory and
      forbids in-source builds.
    
    SYNOPSIS:
    
        --help         Display this help
        --version      Display ecbuild version
        --toolchains   Display list of pre-installed toolchains (see below)
    
    
    Available values for "option":
    
        --cmakebin=<path>
              Set which cmake binary to use. Default is 'cmake'
    
        --prefix=<prefix>
              Set the install path to <prefix>.
              Equivalent to cmake argument "-DCMAKE_INSTALL_PREFIX=<prefix>"
    
        --build=<build-type>
              Set the build-type to <build-type>.
              Equivalent to cmake argument "-DCMAKE_BUILD_TYPE=<build-type>"
              <build-type> can be any of:
                 - debug : Lowest optimization level, useful for debugging
                 - release : Highest optimization level, for best performance
                 - bit : Highest optimization level while staying bit-reproducible
                 - ...others depending on project
    
        --log=<log-level>
              Set the ecbuild log-level
              Equivalent to "-DECBUILD_LOG_LEVEL=<log-level>"
              <log-level> can be any of:
                 - DEBUG
                 - INFO
                 - WARN
                 - ERROR
                 - CRITICAL
                 - OFF
              Every choice outputs also the log-levels listed below itself
    
        --static
              Build static libraries.
              Equivalent to "-DBUILD_SHARED_LIBS=OFF"
    
        --dynamic, --shared
              Build dynamic libraries (usually the default).
              Equivalent to "-DBUILD_SHARED_LIBS=ON"
    
        --config=<config>
              Configuration file using CMake syntax that gets included
              Equivalent to cmake argument "-DECBUILD_CONFIG=<config-file>"
    
        --toolchain=<toolchain>
              Use a platform specific toolchain, containing settings such
              as compilation flags, locations of commonly used dependencies.
              <toolchain> can be the path to a custom toolchain file, or a
              pre-installed toolchain provided with ecbuild. For a list of
              pre-installed toolchains, run "ecbuild --toolchains".
              Equivalent to cmake argument "-DCMAKE_TOOLCHAIN_FILE=<toolchain-file>"
    
        --cache=<ecbuild-cache-file>    (advanced)
              A file called "ecbuild-cache.cmake" is generated during configuration.
              This file can be moved to a safe location, and specified for future
              builds to speed up checking of compiler/platform capabilities. Note
              that this is only accelerating fresh builds, as cmake internally
              caches also. Therefore this option is *not* recommended.
    
        --build-cmake[=<prefix>]
              Automatically download and build CMake version 3.5.2.
              Requires an internet connection and may take a while. If no prefix
              is given, install into /Users/stephenh/projects/jedi-docs/docs.
    
        --dryrun
              Don't actually execute the cmake call, just print what would have
              been executed.
    
    
    Available values for "cmake-argument":
    
        Any value that can be usually passed to cmake to (re)configure the build.
        Typically these values start with "-D".
            example:  -DENABLE_TESTS=ON  -DENABLE_MPI=OFF  -DECKIT_PATH=...
    
        They can be explicitly separated from [option...] with a "--", for the case
        there is a conflicting option with the "cmake" executable, and the latter's
        option is requested.
    
    ------------------------------------------------------------------------
    
    NOTE: When reconfiguring a build, it is only necessary to change the relevant
    options, as everything stays cached. For example:
      > ecbuild --prefix=PREFIX .
      > ecbuild -DENABLE_TESTS=ON .
    
    ------------------------------------------------------------------------
    
    Compiling:
    
      To compile the project with <N> threads:
        > make -j<N>
    
      To get verbose compilation/linking output:
        > make VERBOSE=1
    
    Testing:
    
      To run the project's tests
        > ctest
    
      Also check the ctest manual/help for more options on running tests
    
    Installing:
    
      To install the project in location PREFIX with
           "--prefix=PREFIX" or
           "-DCMAKE_INSTALL_PREFIX=PREFIX"
        > make install
    
    ------------------------------------------------------------------------
    ECMWF"
    
    >>
It is recommended to choose one of the JEDI repositories and look through all of the
CMakeLists.txt files.
This will help you get oriented in how these files are used to piece together the build,
test and install flows.
You will notice ecbuild macros (with names starting with "ecbuild\_") along with
native cmake commands.


