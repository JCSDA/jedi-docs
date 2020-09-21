gcov
====

*gcov* is a code coverage analysis tool, useful for determining which lines of
code got executed, and how many times. It is part of the GNU compiler suite,
so is free. It has a *man* page for general reference. *gcov* is advertised to
work only with the GNU compilers. Use with other compilers is not guaranteed.

Generating code coverage files
------------------------------
To generate coverage analysis, at the build stage, you need to pass ``DENABLE_GPROF=ON`` option to cmak and turn off the optimizations. For example, if you are using the `JSCDA GNU container <https://hub.docker.com/r/jcsda/docker-gnu-openmpi-dev>`_ you can build your bundle using the command below:

.. code:: bash

  cmake -DCMAKE_MODULE_PATH=/usr/local/share/ecbuild/cmake/ -DCMAKE_BUILD_TYPE=Debug -DENABLE_GPROF=ON ../src-bundle

Next, compiling the program and running tests will generate ``*.gcno`` and ``*.gcda`` files for each object file. These are intermediate files and include coverage and profile data and by default are stored in the same directory as the corresponding object file. The next step is to run **gcov** to generate coverage report. For ``*.gcno`` or ``*.gcda`` files you can simple run ``gcov *.gcda`` or ``gcov *.gcno`` to generate ``*.gcov`` files.

`LCOV <http://ltp.sourceforge.net/coverage/lcov.php>`_ is a graphical front-end for gcov. LCOV can create HTML pages based on coverage report (``*.gcov`` files) for multiple files. Here is an example of how to run LCOV:

.. code:: bash

  lcov --direcetory . --capture --output-file coverage.info
  genhtml coverage.info --output-directory out


gcov for Fortran files
----------------------

The following describes in step by step fashion how it can be used in the JEDI UFO
bundle to get coverage analysis for CRTM files. Note that this analysis only
involves Fortran files, so further action to include C/C++ files will be
required.

1. Edit the top level CMakeLists.txt file, add the line
``link_libraries( gcov )``
before the ``ecbuild_bundle`` commands.

2. Edit appropriate files starting with "compile_Flags_GNU\*.cmake", add the flags
``-fprofile-arcs -ftest-coverage`` so those flags will be added to the compilation
of files you want *gcov* to analyze.

3. Run the appropriate *ecbuild* command. *gcov* documentation strongly
recommends unoptimized compilation, so a *debug* JEDI build accomplishes
this.

4. Do the run you want *gcov* to analyze, using *ctest* or other means.

5. *cd* to where the .o files live that you want to profile\: For my CRTM
analysis this was\:

``% cd build_gcc_debug_shared/crtm/libsrc/CMakeFiles/crtm.dir``

In this directory there should be a number of files ending in *gcda* and
*gcno*. These were created during the run as a result of the flags added in
step 2 above.

6. Unfortunately, at least for CRTM, the JEDI compilation command does not use
standard naming for .o files, e.g. instead of CRTM_x.f90 compiling to CRTM_x.o,
it actually compiles to CRTM_X.f90.o  This confuses *gcov*, so we need to rename the
gcov-specific files which were created by the run so that when *gcov* is
run, it will find what it is looking for. To get around this problem, you may
wish to use a script such as this to provide soft link names that *gcov* understands\:

.. code:: bash

   for i in $(ls *.f90.gcda *.f90.gcno); do
    newname=$(echo $i | sed -e 's/\.f90\././1')
    if [ ! -f $newname ]; then
      ln -s $i $newname;
    fi
   done

7. Next, *gcov* needs the source files to live in this same directory as the
.o files just mentioned, which unfortunately they do not. For
CRTM, one way to get around this is to do the following
(still in the directory where the .o files live)\:

``% ln -s ../../../../../crtm/libsrc/*f90 .``

8. Now (in the same directory) run *gcov* to get the analysis\:

``% gcov *f90``

The output files ending in ``.gcov`` contain the annotated source. Lines
starting with ``####`` were never executed. Lines starting with a number
indicate the number of times that line got executed. Lines starting with
``-`` indicate that no executable code exists at that line.
