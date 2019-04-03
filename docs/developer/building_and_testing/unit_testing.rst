JEDI Testing
=============================

Each JEDI bundle has it's own suite of tests.  To run them, first build and compile the bundle as described in our :doc:`bundle build page <building_jedi>`.  Step 5 in that building and compiling procedure is to test the code with **ctest**.  This step is described in the :ref:`following section <running-ctest>`.

After describing the basic functionality of ctest, we proceed to give a more detailed overview of how tests are organized and implemented in JEDI.  This is a prelude to the :doc:`next document <adding_a_test>`, which describes how you -- yes *you!*  -- can implement your own JEDI unit tests.

.. _running-ctest:

Running ctest
-------------

The standard practice after :doc:`building and compiling a JEDI bundle <building_jedi>` is to run ctest with no arguments in order to see if the bundle is operating correctly:

.. code:: bash

   cd <build-directory>
   ctest

This will run all tests in the test suite for that bundle. This can take a while so be patient.  When the tests are complete, ctest will print out a summary, highlighting which tests, if any, failed.  For example:

.. code:: bash

    98% tests passed, 2 tests failed out of 130

    Label Time Summary:
    boost         = 2253.85 sec (75 tests)
    executable    = 2253.85 sec (75 tests)
    fv3jedi       = 2241.67 sec (10 tests)
    mpi           = 2242.21 sec (11 tests)
    oops          =  28.63 sec (111 tests)
    script        =  26.18 sec (55 tests)
    ufo           =   9.73 sec (9 tests)

    Total Test time (real) = 2280.20 sec

    The following tests FAILED:
  	    123 - test_fv3jedi_aninit (Failed)
	    130 - test_fv3jedi_localization (Timeout)
    Errors while running CTest

If you want to run a single test or a subset of tests, you can do this with the :code:`-R` option, for example:

.. code:: bash

   ctest -R test_fv3jedi_linearmodel # run a single test
   ctest -R test_qg* # run a subset of tests
   
The output from these tests (stdout) will be printed to the screen but, to allow for greater scrutiny, it will also be written to the file **LastTest.log** in the directory :code:`<build-directory>/Testing/Temporary`.  In that same directory you will also find a file called **LastTestsFailed.log** that lists the last tests that failed.  This may be from the last time you ran ctest or, if all those tests passed, it may be from a previous invocation.

If you're not happy with the information in LastTest.log and you want to know more, you can ask ctest to be **verbose** 

.. code:: bash

   ctest -V -R test_fv3jedi_linearmodel

...or even **extra-verbose** (hypercaffeinated mode):

.. code:: bash

   ctest -VV -R test_fv3jedi_linearmodel

   
The :code:`-V` and even :code:`-VV` display the output messages on the screen in addition to writing them to the LastTest.log file.  However, sometimes the amount of information written to LastTest.log isn't much different than if you were to run ctest without these options, particularly if all the tests pass.

Another way to get more information is to set one or both of these environment variables before you run ctest:

.. code:: bash

   export OOPS_DEBUG=1
   export OOPS_TRACE=1
   
The first enables debug messages within the JEDI code that would not otherwise be written.  The second produces messages that follow the progress of the code as it executes.  Both tools are provided by :doc:`eckit <../developer_tools/cmake>`.   Though higher values of these variables could in principle be set, few JEDI routines exploit this functionality.  So, setting these variables to values greater than 1 will make little difference.  Both can be disabled by setting them to zero.

**ctest** also has an option to only re-run the tests that failed last time:
   
.. code:: bash   
   
   ctest --rerun-failed

To see a list of tests for your bundle without running them, enter   
   
.. code:: bash   
   
   ctest -N

For a complete list of ctest options, enter :code:`man ctest`, :code:`ctest --help`, or check out our :doc:`JEDI page on CMake and CTest <../developer_tools/cmake>`.  As described there, CTest is a component of CMake, so you can also consult the `CMake online documentation <https://cmake.org/documentation/>`_ for the most comprehensive documentation available.

.. _manual-testing:


Manual Execution
----------------

You can also run the executable test files directly, without going through ctest.  To do this, first find the executable in the build directory. Unit tests are typically found in one of the :code:`test` directories that branch off each repository name.  For example, :code:`test_qg_state` can be found in :code:`<build-directory>/oops/qg/test` and :code:`test_ufo_geovals` can be found in :code:`<build-directory>/ufo/test`.  Then just :code:`cd` to that directory and run the executable from the command line, specifying the appropriate input (configuration) file, e.g.

.. code:: bash

    test_qg_state testinput/interfaces.yaml 
	  
You can determine which executable and which configuration file each test uses by viewing the :code:`CMakeLists.txt` file in the corresponding :code:`test` directory of the repository.  If you're running the ufo bundle, then the relevant :code:`CMakeLists.txt` files for the examples above would be :code:`<src-directory>/ufo-bundle/oops/qg/test` and :code:`<src-directory>/ufo-bundle/ufo/test`.  Just open the relevant :code:`CMakeLists.txt` file and search on the name of the test.  See :doc:`Adding a New Test <adding_a_test>` for further details on how to interpret the syntax.

If you do run the tests without ctest, keep in in mind a few tips.  First, the test name is not always the same as the executable name.  Second, since the the integration and system tests generally focus on JEDI Applications (other than :code:`oops::Test` objects - see :ref:`below <test-apps>`) they usually have a :code:`.x` extension.  Furthermore, these executables are generally located in the :code:`<build-directory>/bin` directory as opposed to the :code:`test` directories.  For example, to run :code:`test_qg_truth` from the :code:`<build-directory>/oops/qg/test` directory, you would enter the following:

.. code:: bash

    ../../../bin/qg_forecast.x testinput/truth.yaml 


.. _jedi-tests:

The JEDI test suite
-------------------

What lies "*under the hood*" when you run **ctest**?  Currently, there are two types of tests implemented in JEDI:

1. Unit tests 
2. Integration and system tests (aka Application tests) 

This does not include other types of system and acceptance testing that may be run outside of the ctest framework, by individual developers and testers.  Integration and system tests are refereed to as **Application tests** for reasons that will become clear in the :ref:`next section <test-apps>`.   

**Unit tests** are currently implemented in JEDI using eckit unit testing framework for initializing and organizing our suite of unit tests, and for generating appropriate status and error messages.  :ref:`See below <init-test>` for further details on how tests are implemented.

Unit testing generally involves evaluating one or more Boolean expressions during the execution of some particular component or components of the code.  For example, one can read in a model state from an input file and then check whether some measure of the State norm agrees with a known value to within some specified tolerance.  Or, one can test whether a particular variable is positive (such as temperature or density) or whether a particular function executes without an error.

By contrast, **Application tests** check the operation of some application as a whole.  Some may make use of eckit Boolean tests but most focus on the output that these applications generate.  For example, one may wish to run a 4-day forecast with a particular model and initial condition and then check to see that the result of the forecast matches a well-established solution.  This is currently done by writing the output of the test to a file (typically a text file) and comparing it to an analogous output file from a previous execution of the test.  Such reference files are included in many JEDI repositories and can generally be found in a :code:`test/testoutput` subdirectory.

Comparisons between output files are currently done by means of the **compare.sh** bash script which can be found in the :code:`test` subdirectory in many JEDI repositories.  This script uses standard unix parsing commands such as :code:`grep` and :code:`diff` to assess whether the two solutions match.  For further details see the section on :ref:`Integration and System testing <app-testing>` below.

.. warning::

  **The compare.sh testing procedure is provisional and is likely to be modified in the future.**

As mentioned above, each JEDI bundle has its own suite of tests and you can list them (without running them) by entering this from the build directory:

.. code:: bash   
   
   ctest -N

Though all tests in a bundle are part of the same master suite, they are defined within each of the bundle's individual repositories.  Furthermore, you can generally determine where each test is defined by its name.  For example, all :code:`test_qg_*` tests are defined in :code:`oops/qg`; all :code:`test_ufo_*` tests are defined in :code:`ufo`; all :code:`test_fv3jedi_*` tests are defined in the :code:`fv3-jedi` repo, and so on.

With few exceptions, all JEDI repositories contain a :code:`test` directory that defines the tests associated with that repository.  oops itself is one exeception because it orchestrates the operation of the code as a whole but there you will find archetypical test directores within the :code:`qg` and :code:`l95` model directories.

Within each :code:`test` directory you will find a file called :code:`CMakeLists.txt`.  This is where each test is added, one by one, to the suite of tests that is executed by **ctest**.  As described in the `CMake documentation <https://cmake.org/documentation/>`_, this is ultimately achieved by repeated calls to the CMake :code:`add_test()` command.

However, the :doc:`ecbuild package <../developer_tools/cmake>` offers a convenient interface to CMake's :code:`add_test()` command called :code:`ecbuild_add_test()`. Application tests are added by specifying :code:`TYPE SCRIPT` and :code:`COMMAND "compare.sh"` to :code:`ecbuild_add_test()`. For further details on how to interpret this argument list see :doc:`Adding a New Unit Test <adding_a_test>`.

Since it relies on the net result of an application, each Application test is typically associated with a single **ctest** excecutable.  However, applications of type :code:`oops::Test` (see :ref:`next section <test-apps>`) will typically execute multiple unit tests for each executable, or in other words each item in the ctest suite.  So, in this sense, the suite of unit tests is nested within each of the individual tests defined by **ctest**.  And, it is this nested suite of unit tests. (see :ref:`below <init-test>`).


.. _test-apps:

Tests as Applications
---------------------

The JEDI philosophy is to exploit high-level abstraction in order to promote code flexibility, portability, functionality, efficiency, and elegance.  This abstraction is achieved through object-oriented design principles.

As such, the execution of the JEDI code is achieved by means of an :code:`Application` object class that is defined in the :code:`oops` namespace.  As illustrated in the following class heirarchy, :code:`oops::Test` is a sub-class of the :code:`oops::Application` class, along with other applications such as individual or ensemble forecasts:

.. image:: images/Application_class.png
    :height: 600px
    :align: center		    

Unit tests are implemented through :code:`oops::Test` objects as described in this and the following sections.  The other type of test in the :ref:`JEDI test suite <jedi-tests>`, namely Application tests, generally check the operation of JEDI applications as a whole - the same applications that are used for production runs and operational forecasting.  In other words, application tests are used to test the operation of the Application classes in the diagram above that are *not* sub-classes of :code:`oops::Test`.

To appreciate how a JEDI Application is actually run, consider the following program, which represents the entire (functional) content of the file :code:`oops/qg/test/executables/TestState.cc`:

.. code:: C++

   int main(int argc,  char ** argv) {
     oops::Run run(argc, argv);
     test::State<qg::QgTraits> tests;
     run.execute(tests);
     return 0;
   };

This program begins by defining an object of type :code:`oops::Run`, passing the constructor the arguments from the command line.  These command-line arguments generally include a :doc:`configuration file <configuration>` that specifies the parameters, input files, and other information that is necessary to run the application (in this case, a test).

Then the program proceeds to define an object of type :code:`test::State<qg::QgTraits>` called :code:`tests`, which is a sub-class of :code:`oops::Test` as illustrated here:

.. image:: images/Test_class.png
    :height: 1000px
    :align: center		    

Since :code:`test::State<qg::QgTraits>` is a sub-class of :code:`oops::Test` (through the appropriate instantiation of the :code:`test::State<MODEL>` template), then the :code:`tests` object is also an Application (:code:`oops::Application`).

So, after defining each of the objects, the program above proceeds to pass the Application object (:code:`tests`) to the :code:`execute()` method of the :code:`oops::Run` object.  Other applications are executed in a similar way.

Source code for the executable unit tests in a given JEDI repository can typically be found in a sub-directory labelled :code:`test/executables` or :code:`test/mains`.  Similarly, the source code for executable JEDI Applications that are not :code:`oops::Test` objects can typically be found in a :code:`mains` directory that branches from the top level of the repository.


.. _init-test:

Initialization and Execution of Unit Tests
------------------------------------------

As described :ref:`above <test-apps>`, an :code:`oops::Test` object is an application that is passed to the :code:`execute()` method in an :code:`oops::Run` object.  To describe what happens next, we will continue to focus on the :code:`test_qg_state` example introduced in the previous section as a representative example.

First, it is important to realize that the :code:`test::State<Model>` class is not the same as the :code:`oops::State<Model>` class.  The former is an application as described in the previous section whereas the latter contains information about and operations on the current model state.

Second, as an application, a :code:`test::State<Model>` object also has an :code:`execute()` method, which is called by the :code:`execute()` method of the :code:`oops::Run` object as shown here (code excerpt from :code:`oops/src/oops/runs/Run.cc`):

.. code:: C++

   void Run::execute(const Application & app) {
     int status = 1;
     Log::info() << "Run: Starting " << app << std::endl;
     try {
       status = app.execute(*config_);
     }	  
     [...]	  

The :code:`execute()` method for an :code:`oops::Test` is defined in the
file :code:`oops/src/oops/runs/Test.h`.  The main purpose of this routine is
to intialize and run the suite of unit tests. 

The :code:`execute()` method in each :code:`oops::Test` object then proceeds to register the tests with :code:`oops::Test::register_tests()` and run them with a call to eckit's :code:`run_tests()` function (:code:`argc` and :code:`argv` are parsed from the :code:`args` variable above):    

.. code:: C++      
      
    // Run the tests
      Log::trace() << "Registering the unit tests" << std::endl;
      register_tests();
      Log::trace() << "Running the unit tests" << std::endl;
      int result = eckit::testing::run_tests(argc, argv, false);
      Log::trace() << "Finished running the unit tests" << std::endl;
      Log::error() << "Finished running the unit tests, result = " << result << std::endl;

So, the real difference between different :code:`oops::Test` objects is encapsulated in the :code:`oops::Test::register_tests()` method.   Each test application (i.e. each item in ctest's list of tests) will register a different suite of unit tests. 

In the case of :code:`test::State<MODEL>` (which you may recall from the previous section is a sub-class of :code:`oops::Test`), this method is defined as follows (see :code:`oops/src/test/interface/State.h`):

.. code:: C++
  void register_tests() const {
    std::vector<eckit::testing::Test>& ts = eckit::testing::specification();

    ts.emplace_back(CASE("interface/State/testStateConstructors")
      { testStateConstructors<MODEL>(); });
    ts.emplace_back(CASE("interface/State/testStateInterpolation")
      { testStateInterpolation<MODEL>(); });
  }

This is where the eckit unit test suite is actually initiated: A :code:`ts` object is created by calling :code:`specification()`, tests are added to testing suite :code:`ts` by :code:`emplace_back`.

Note that all this occurs within the :code:`test::State<MODEL>` class template so there will be a different instance of each of these unit tests for each model.  So, our example application :code:`test_qg_state` will call :code:`test::State<qg:QgTraits>::register_tests()` whereas other models and other applications (as defined in other sub-classes of :code:`oops::Test` - see :ref:`above <test-apps>`) will register different unit tests.

So, in short, members of the **ctest** test suite are added by means of :code:`ecbuild_add_test()` commands in the appropriate :code:`CMakeLists.txt` file (see :ref:`above <jedi-tests>`) while members of the nested unit test suite are added by means of the :code:`oops::Test::register_tests()` method.

.. _unit-test:

Anatomy of a Unit Test
----------------------

Let's continue to use :code:`test_qg_state` as an example in order to illustrate how unit tests are currently implemented in JEDI.  As described in the previous two sections, the execution of this test (a single test from the perspective of **ctest**) will call :code:`test::State<qg:QgTraits>::register_tests()` to register a suite of unit tests and it will call :code:`eckit::testing::run_tests()` to run them.

As demonstrated in the previous section, this particular suite of unit tests includes two members, namely :code:`testStateConstructors<MODEL>()` and :code:`TestStateInterpolation<MODEL>()`, with :code:`MODEL` instantiated as :code:`qg:QgTraits`.  What happens when we run one of these unit tests?

Here we will focus on the first, :code:`TestStateConstructors<MODEL>()`.  Both are defined in :code:`oops/src/test/interface/State.h`, where you will find this code segment:

.. code:: C++
  template <typename MODEL> void testStateConstructors() {
    typedef StateFixture<MODEL>   Test_;
    typedef oops::State<MODEL>    State_;

    const double norm = Test_::test().getDouble("norm-file");
    const double tol = Test_::test().getDouble("tolerance");
    const util::DateTime vt(Test_::test().getString("date"));

    // Test main constructor
    const eckit::LocalConfiguration conf(Test_::test(), "StateFile");
    const oops::Variables vars(conf);
    boost::scoped_ptr<State_> xx1(new State_(Test_::resol(), vars, conf));

    EXPECT(xx1.get());
    const double norm1 = xx1->norm();
    EXPECT(oops::is_close(norm1, norm, tol));
    EXPECT(xx1->validTime() == vt);

    [...]

This starts by defining :code:`Test_` as an alias for the :code:`StateFixture<MODEL>` class.  Other test objects also have corresponding fixture classes, for example :code:`test::ModelFixture<MODEL>`, :code:`test::ObsTestsFixture<MODEL>`, etc.  These are primarily used to access relevant sections of the configuration file.  In the above example, they are used to extract a reference value for the State norm, a tolerence level for the norm test, and a reference date for the State object that is about to be created.

Then the "StateFile" section of the config file is extracted through the StateFixture and, together with information about the geometry (in :code:`Test_::resol()`), is used to create a new State object called :code:`*xx1` (:code:`boost::scoped_ptr<>` is a type of smart pointer defined by Boost similar to :code:`std::unique_ptr<>` in C++11).

Then the unit tests really begin, with multiple calls to check Boolean expressions, including exit codes.  The first call to :code:`EXPECT()` checks to see if the pointer is properly defined with the help of the :code:`get()` method of :code:`boost::scoped_ptr<>`.  In other words, it checks to see if a State object was successfully created.

The call to :code:`EXPECT(oops::is_close(norm1, norm, tol))` then checks to see if the norm that was read from the configuration file is equal to the value computed with the :code:`norm()` method of the State object, with the specified tolerance.

:code:`EXPECT()` with double equal sign is used to verify that the State object is equal to the reference value read from the configuration file.

The function above then proceeds to perform similar tests for the copy constructor (not shown).      

If any of these nested unit tests fail, **ctest** registers a failure for the parent application and an appropriate message is written to the ctest log file (as well as :code:`stdout` if **ctest** is run in verbose mode).
      
.. _app-testing:

Integration and System (Application) Testing
--------------------------------------------

Though each executable in the **ctest** test suite may run a number of unit tests as described in the previous two sections, many are also used for higher-level integration and system testing.  As described in :ref:`The JEDI Test Suite <jedi-tests>` above, these are currently implemented by comparing the output of these executables to known solutions.

Files containing summary data for these known solutions can be found in the :code:`test/testoutput` directory of many JEDI reposistories.  The :code:`test_qg_state` example that we have been using throughout this document is a unit test suite (:ref:`Type 1 <jedi-tests>`) as opposed to an Application test (:ref:`Type 2 <jedi-tests>`) so it does not have a reference output file.  However, as an Application test, :code:`test_qg_truth` does have such a file.  The name of this reference file is :code:`truth.test` and its contents are as follows:

.. code:: bash

    Test     : Initial state: 13.1
    Test     : Final state: 15.1417

This lists the norm of the initial and final states in an 18 day forecast.  So, the ostensibly sparse contents of this file are misleading: *a lot of things have to go right in order for those two data points to agree precisely*!

This and other reference files are included in the GitHub repositories but the output files themeselves are not.  They are generated in the build directory by running the test, and they follow the same directory structure as the repository itself.  Furthermore, they have the same name as the reference files they are to be compared to but with an extension of :code:`.test.out`.  Messages sent to :code:`stdout` during the execution of the test are written to another file with an extension :code:`.log.out`.

So, in our example above, the output of :code:`test_qg_truth` will be written to

.. code:: bash

      <build-directory>/oops/qg/test/testoutput/truth.test.test.out`

In the same directory you will find a soft link to the reference file, :code:`truth.test`, as well as the log file, :code:`truth.test.log.out`.

When the test is executed, the :code:`compare.sh` script in the :code:`test` directory of the repository (which also has a soft link in the build directory) will compare the output file to the reference file by first extracting the lines that begin with "Test" (using :code:`grep`) and then comparing the (text) results (using :code:`diff`).  In our example, the two files to be compared are :code:`test.truth` and :code:`test.truth.test.out`.  If these do not match, **ctest** registers a failure.

.. warning::

   The **compare.sh** script may have problems if you run with multiple processers.

.. _test-framework:

JEDI Testing Framework
----------------------

In this document we have described :ref:`how unit tests are implemented as oops::Test (Application) objects <test-apps>` and we have described how they are executed by :ref:`passing these Application objects to an oops::Run object <init-test>`.  We have focused on the :code:`oops` repository where this testing framework is currently most mature.  However, **the ultimate objective is to replicate this structure for all JEDI repositories.**

Using :code:`oops` as a model, the objective is to have the :code:`test` directory in each JEDI repository mirror the :code:`src` directory.  So, ideally, every class that is defined in the :code:`src` directory will have a corresponding test in the :code:`test` directory.  Furthermore, each of these tests is really a suite of unit tests as described :ref:`above <jedi-tests>`.   

Let's consider ufo as an example.  Here the main source code is located in :code:`ufo/src/ufo`.  In particular, the :code:`.h` and :code:`.cc` files in this directory define the classes that are central to the operation of ufo.  For each of these classes, there should be a corresponding :code:`.h` file in :code:`ufo/test/ufo` that defines the unit test suite for objects of that class.  These are not yet all in place, but this is what we are working toward.  The same applies to all other JEDI repositories.

Each unit test suite should be defined as a sub-class of :code:`oops::Test` as described :ref:`above <test-apps>`.  Then it can be passed to an :code:`oops::Run` object :ref:`as an application to be executed <test-apps>`.

For further details on how developers can contribute to achieving this vision, please see :doc:`Adding a New Test <adding_a_test>`.




