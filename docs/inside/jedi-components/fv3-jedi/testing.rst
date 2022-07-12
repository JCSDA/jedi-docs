.. _top-fv3-jedi-testing:

.. _testing:

Testing
=======

FV3-JEDI comes with an extensive suite of ctests. These tests are designed to makes sure as much as
possible of the source code in FV3-JEDI is regularly exercised and that all common applications are
tested. This ensures continued functionality of the code as changes are made and saves time by not
requiring code reviewers to run all the tests themselves and instead be focused on design
implications.

.. _ci:

Continuous integration
----------------------

FV3-JEDI has an extensive continuous integration (CI) suite running on Amazon Web Services. Each
time a pull request is issued against develop in the JCSDA public repository the FV3-JEDI part of
the FV3-BUNDLE package is built with Intel, GNU and Clang compilers and all the FV3-JEDI tests are
executed. Unless all the tests pass a failure blocks the pull request from being merged. In addition
to running all the tests the CI includes a code coverage report. The main purpose of the code
coverage test is to make sure that any changes to the code are included in one of the tests that
run. If the coverage of the code that is added through the pull request is less than the coverage of
the existing code it will issue a failure that blocks the merge.

.. _addtest:

Adding a test to FV3-JEDI
-------------------------

Having the CI means that developers are responsible for adding a test that covers any code they wish
to add to the system. All the testing in FV3-JEDI is controlled through
fv3-jedi/test/CMakeLists.txt. Broadly there are two kinds of ctests in FV3-JEDI, and JEDI in
general. The first is a so-called interface test. These kinds of tests measure individual methods
(units) in each class. It might have an expected result or allow for a result to within some
tolerance. The other kind of ctest is an application test, where an entire application is run. In
these application tests there is a reference log file that is compared with the actual output,
usually with some tolerance to allow for small differences.

Adding a test to FV3-JEDI will typically involve at least three files, source code for the test, an executable, and a configuration file. A fourth file, a reference file, must be supplied in the case of application tests, see below. Tests need to be registered with CTest which we can do with a call to :code:`ecbuild_add_test()` in the :code:`test/CMakeLists.txt` file which may look something like the call below.  


.. code::
   
   ecbuild_add_test( TARGET   fv3jedi_test    #name of the test
                     MPI      6    #number of MPI tasks                           
                     ARGS     testinput/mytest.yaml    #configuration file
                     COMMAND  fv3jedi_test.x    #executable to run
                     TEST_DEPENDS other_test_name #other test this one may depend on )
                    
The `TARGET` option defines the name of the test, while the `COMMAND` option specifies the executable to be run. `ARGS` specifies the configuration file to be used while the `MPI` option specifies the number of MPI tasks needed. If the test you are adding depends on another test this can be specified using the `TEST_DEPENDS` option. In addition, with the `ARGS` option, you can run yaml validation only and not the test with  `ARGS  --validate-only testinput/mytest.yaml` or skip the validation and run the test only with `ARGS  --no-validate testinput/mytest.yaml`. The best source for information on available arguments is the file that defines the macro itself, `cmake/ecbuild_add_test.cmake <https://github.com/ecmwf/ecbuild/blob/master/cmake/ecbuild_add_test.cmake>`_ in `ECMWF's ecbuild repository <https://github.com/ecmwf/ecbuild>`_.

In addition to registering the test with CTest, we also must let it know about the configuration file, "mytest.yaml". To do this, edit the CMakeLists.txt file and look for a list of input files like this one from :code:`fv3-jedi/test/CMakeLists.txt`:


.. code::

   list( APPEND fv3jedi_testinput
     testinput/3denvar_geos_aero.yaml
     testinput/3dvar_geos-cf.yaml
     testinput/3dvar_gfs_0obs.yaml
     testinput/3dvar_gfs_aero.yaml
     testinput/3dvar_lam_cmaq.yaml
     testinput/4denvar.yaml
     testinput/addincrement_geos.yaml
     testinput/mytest.yaml    #add your configuration file
     )

When adding an application test for which you want to compare the output of the test executable to a known solution, a test reference file, "mytest.ref", must also be provided. Reference files define the known solutions and are found in the :code:`test/testoutput`. These files must also be specified in :code:`fv3-jedi/test/CMakeLists.txt`: e.g. 

.. code::

    list( APPEND fv3jedi_testoutput
      testoutput/3dvar_geos-cf.ref
      testoutput/3dvar_lam_cmaq.ref
      testoutput/3dvar_gfs_0obs.ref
      testoutput/3dvar_gfs_aero.ref
      testoutput/3denvar_geos_aero.ref
      testoutput/4denvar.ref
      testoutput/addincrement_geos.ref
      testoutput/mytest.ref    # add your reference file
      )

If you need to generate your own reference file, the file can be generated by running the application with the
test configuration and writing the output to a log file. The below provides and example of how to
generate the log and reference file:

.. code:: shell

   # cd to test directory
   cd build/fv3-jedi/test

   # Run the application
   mpirun -np 6 ../../bin/fv3jedi_forecast.x testinput/forecast.yaml forecast.log

   # Generate the test reference file with grep 'Test     :' (five spaces followed by :)
   grep 'Test     :' forecast.log > forecast.ref    


**For more on application testing, configuring numerical tolerances and other options see the documentation here:** :ref:`Application Testing <test-apps>` . **For more detailed instructions on the pieces of adding a test see the documentation here:** :ref:`Adding A Test <adding-a-test>` .



Timing test
-----------

FV3-JEDI includes a timing test that runs as part of the :ref:`ci`. In this test the time each test
takes to run is compared with some predetermined values. If a change is made that dramatically
increases the time any of the tests take to run it will result in a failure. Reference timings for
each test are located at e.g. :code:`test/testoutput/CTestCostData.txt.awsintel.test` and the tests
for which the run times are checked are at :code:`test/testinput/test_time.yaml`.
