Adding a New Test
======================

So, you've developed a new feature in some JEDI repository and now you want to test it.  You have come to the right place.

This document is a step-by-step guide on how to add a test to JEDI.  Here we focus on unit tests but in the final section we include some guidance on how you might proceed to :ref:`Add an Application test <add-app-test>`.

The first thing to emphasize is that there are many levels of sophistication on how you might wish to proceed.  The simplest case is to use the existing unit test infrastructure.  If you go this route, then you may just have to create an appropriate configuration file and then register your test with CMake and CTest (Steps 7-8).  Or, you may wish to add a new test to an existing test suite, to create a new test suite, or even to establish the proper directory structure.

Wherever you are on this spectrum of possibilities, we hope this document will be useful.  Just be aware that **you are under no obligation to follow all the steps**.  If the infrastructure for that step is already in place, then feel free to proceed to the next step.

In any case, it is imperative that you first :doc:`read this document that describes how tests are organized, implemented and executed within JEDI <unit_testing>`.  In particular, please read :ref:`our vision <test-framework>` on how we would like the developmont of the JEDI testing framework to proceed.

Step 1: Create a File for your Test Application
-----------------------------------------------

The goal of the :ref:`JEDI Testing Framework <test-framework>` is to have the test directory mirror the source directory such that each of the main C++ classes defined in the source directory has a corresponding test.

So let's say that there is a file in some JEDI repository called :code:`src/mydir/MyClass.h` that defines a C++ class called :code:`MyClass`.  And, let's say that we want to define a unit test suite to test the various methods and constructors in :code:`MyClass`.  The first thing we would want to do is to create a file called :code:`test/mydir/MyClass.h` that will contain the test application.

If you're working in a well-established JEDI directory then this file may already exist.  If that's the case, then you can probably move on to Step 3.  On the other hand, if you're adding a new model to JEDI, it's possible that the directory won't exist yet, let alone the file.  So, create the directory and the file as needed.

Before proceeding we should emphasize again that there is another option.  Often the existing test applications defined within :code:`oops/src/test/interface` will be sufficient to test your new feature.  If this is the case, then you can skip ahead to Step 6.  There you will see an example where this is done for FV3.

Or, even better - sometimes the test infrastructure will already exist within the JEDI repository you are working with.  Often you can reuse an existing test and just specify a different configuration that activates your new feature.  In that case all you have to do is to create an appropriate configuration file and you can proceed directly to Step 7!

If you're still in this section, read on for some tips on how to write the application file :code:`test/mydir/MyClass.h`.

What MyClass.h **Should** Contain
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

As a prelude to the steps that follow, we note that the main purpose of :code:`test/mydir/MyClass.h` is to define :code:`test::MyClass` as a sub-class of :code:`oops::Test`.  As a sub-class of :code:`oops::Test`, :code:`test::MyClass` will also be a sub-class of :code:`oops::Application`.  That is, it will be an Application object that can be executed by :ref:`passing it to an oops::Run object <init-test>`.  In addition to declaring and defining :code:`test::MyClass`, our file might also define a :code:`MyClassFixture` class to help with accessing the configuration file (Step 2).  Necessary components of :code:`test/mydir/MyClass.h` include one or more functions that define the unit tests as well as a :code:`register_tests()` method within :code:`test::MyClass` that adds these tests to the master test suite.

Since we'll be building off of :code:`oops::Test` and the eckit unit test suite, one necessary item in the header of our MyClass.h file is:

.. code:: C++

   #define ECKIT_TESTING_SELF_REGISTER_CASES 0
  
And the contents of the file should be encapsulated within the :code:`test` namespace, to distinguish it from the corresponding class of the same name in the :code:`src` directory.
   
What MyClass.h **Should not** Contain
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

As described :ref:`elsewhere <init-test>`, the unit tests are initialized and executed by means of the :code:`execute()` method in :code:`oops::Test`.  As a sub-class of :code:`oops::Test`, the :code:`test::MyClass` object will have access to this method and it is best **not** to re-define it.  Doing so may disrupt how eckit executes the tests.


Step 2: Define A Test Fixture
-----------------------------

In JEDI, test fixtures are generally used to create objects as directed by the relevant sections of the :doc:`configuration file <configuration>`, for use with the unit tests.  As an example, consider this code segment in :code:`oops/src/test/interface/Increment.h`:

.. code:: C++

    template <typename> class IncrementFixture : private boost::noncopyable {
    typedef oops::Geometry<MODEL>       Geometry_;

    public:
     static const Geometry_       & resol()   {return *getInstance().resol_;}
     static const oops::Variables & ctlvars() {return *getInstance().ctlvars_;}
     static const util::DateTime  & time()    {return *getInstance().time_;}

    private:
     static IncrementFixture<MODEL>& getInstance() {
       static IncrementFixture<MODEL> theIncrementFixture;
       return theIncrementFixture;
     }

     IncrementFixture<MODEL>() {
    //  Setup a geometry
       const eckit::LocalConfiguration resolConfig(TestEnvironment::config(), "Geometry");
       resol_.reset(new Geometry_(resolConfig));

       const eckit::LocalConfiguration varConfig(TestEnvironment::config(), "Variables");
       ctlvars_.reset(new oops::Variables(varConfig));

       time_.reset(new util::DateTime(TestEnvironment::config().getString("TestDate")));
     }

     ~IncrementFixture<MODEL>() {}

     boost::scoped_ptr<Geometry_>       resol_;
     boost::scoped_ptr<oops::Variables> ctlvars_;
     boost::scoped_ptr<util::DateTime>  time_;
     };

Note that this, like other oops test objects, is a class template, with a different instance for each model.  This may not be necessary for your test if it is model-specific.  The main point here is that the :code:`resol()`, :code:`ctlvars()`, and :code:`time()` methods of :code:`test::IncrementFixture<MODEL>` access the "Geometry", "Variables", and "TestDate" sections of the configuration file and use this information to create objects of type :code:`oops::Geometry<MODEL>`, :code:`oops::Variables`, and :code:`util:DateTime`.  These methods are then used repeatedly by the various unit tests that are included in :code:`test::Increment`.   The :code:`TestEnvironment::config()` calls in the code above provide a way to pass global configuration data to the test fixtures.

So, proceeding with our example, it would be advisable to begin by defining a :code:`test::MyClassFixture` class in :code:`test/mydir/MyClass.h` to facilitate the creation of useful objects as specified in the configuration file.  For many more examples see the various files in :code:`oops/src/test/interface`.

Step 3: Define Your Unit Tests
-------------------------------

Now the next step would be to define the unit tests themselves as functions within :code:`test/mydir/MyClass.h`.  As a guide you can use the illustrative example in :ref:`Anatomy of a Unit Test <unit-test>` or the many examples to be found in :code:`oops/src/test/interface`.    The possibilites are endless, but just remember two things:

   1. Include one or more calls to :ref:`eckit check functions <unit-test>`
   2. Use your test fixture to create objects based on the information in the configuration file

Step 4: Register your Unit Tests with eckit
-------------------------------------------

In order for eckit to run your tests, you have to :ref:`register <init-test>` each individual test. This is achieved by means of the :code:`register_tests()` method of :code:`test::MyClass` and as this :code:`test::Increment` example (from (:code:`oops/src/test/interface/Increment.h`) demonstrates, there is little else needed to define the class:

.. code:: C++
  template <typename MODEL> class Increment : public oops::Test {
   public:
    Increment() {}
    virtual ~Increment() {}
   private:
    std::string testid() const {return "test::Increment<" + MODEL::name() + ">";}

    void register_tests() const {
      std::vector<eckit::testing::Test>& ts = eckit::testing::specification();

      ts.emplace_back(CASE("interface/Increment/testIncrementConstructor")
        { testIncrementConstructor<MODEL>(); });
      ts.emplace_back(CASE("interface/Increment/testIncrementCopyConstructor")
        { testIncrementCopyConstructor<MODEL>(); });
      ts.emplace_back(CASE("interface/Increment/testIncrementTriangle")
        { testIncrementTriangle<MODEL>(); });
      ts.emplace_back(CASE("interface/Increment/testIncrementOpPlusEq")
        { testIncrementOpPlusEq<MODEL>(); });
      ts.emplace_back(CASE("interface/Increment/testIncrementDotProduct")
        { testIncrementDotProduct<MODEL>(); });
      ts.emplace_back(CASE("interface/Increment/testIncrementAxpy")
        { testIncrementAxpy<MODEL>(); });
      ts.emplace_back(CASE("interface/Increment/testIncrementInterpAD")
        { testIncrementInterpAD<MODEL>(); });
      }
    };

So, we would proceed by defining :code:`test::MyClass` in a similar way.  Just specify the test object (here :code:`ts`) and add each of your test functions one by one using :code:`emplace_back` as shown.

Then no more action is required for :code:`test/mydir/MyClass.h`; Our :code:`test::MyClass::register_tests()` method will be executed automatically when we pass :code:`test::MyClass` as an application to :code:`oops::Run` (see :ref:`Initialization and Execution of Unit Tests <init-test>`). 

Step 6: Create an Executable
----------------------------

Executables for each test are generally located in the :code:`test/executables` directory of each JEDI repository, though sometimes this directory is called :code:`test/mains`.  This is not to be confused with the :code:`mains` directory (branching off the top level of the repository) which is typically reserved for the production-level programs.

As described in :ref:`Tests as Applications <test-apps>`, there is not much for the executable file to do.  It only really has three tasks:

   1. Create an :code:`oops::Run` object
   2. Create an :code:`oops::Application` object (in our example, this would be :code:`test::MyClass`)
   3. Pass the Application object to the :code:`execute()` method of the Run object

So, to proceed with our example, we might go to the :code:`test/executables` directory of our repository (create it if it's not there already) and create a file called :code:`TestMyClass.cc` with the following contents:

.. code:: C++

   #include "oops/runs/Run.h"
   #include "../mydir/MyClass.h"

   int main(int argc,  char ** argv) {
     oops::Run run(argc, argv);
     test::MyClass tests;
     run.execute(tests);
     return 0;
   };

That's it.  Note that the include paths for a given repository are specified in the CMakeLists.txt file in the top level of the repository.  All existing JEDI repositories will already have access to :code:`oops/src` by means of these lines, or something similar:

.. code:: CMake

    ecbuild_use_package( PROJECT oops VERSION 0.2.1 REQUIRED )
    include_directories( ${OOPS_INCLUDE_DIRS} )


So, the first include statement in the :code:`TestMyClass.cc` example above should have no problem finding :code:`oops/src/oops/runs/Run.h`, where the :code:`oops::Run` class is defined.
    
It is likely that the :code:`src` directory of the working repository is also in the include path. So, in the above example we specified the relative path of our :code:`MyClass.h` file in the :code:`test` directory so the compiler does not confuse it with the file of the same name in the :code:`src` directory.

In some situations it might be beneficial to define a modified Run object that does some additional model-specific set up.  Here is an example from :code:`fv3-jedi/test/executables/TestModel.cc`

.. code:: C++

   #include "FV3JEDITraits.h"
   #include "RunFV3JEDI.h"
   #include "test/interface/Model.h"

   int main(int argc,  char ** argv) {
     fv3jedi::RunFV3JEDI run(argc, argv);
     test::Model<fv3jedi::FV3JEDITraits> tests;
     run.execute(tests);
     return 0; 
   };

However, :code:`fv3jedi::RunFV3JEDI` is a sub-class of :code:`oops::Run` and it uses the :code:`execute()` method of its parent.  So, the execution of the test is essentially the same as the previous example.

Also, it is worth noting that the application used here is the :code:`fv3jedi::FV3JEDITraits` instance of :code:`test::Model<MODEL>`, which is already defined in :code:`oops/src/test/interface/Model.h`.  So, in this case there would be no need to create a new test application as described in Steps 1-5.    

Step 7: Create a Configuration File
-----------------------------------

Along with the executable, the :doc:`configuration file <configuration>` is the way to tell JEDI what you want it to do.  We reserve a detailed description of how to work with JEDI configuration files for :doc:`another document <configuration>`.

Here we'll just say that the proper place to put it is in the :code:`test/testinput` directory of the JEDI repository that you are working with.  Or, if your tests are located in :code:`test/mydir`, another option would be to put the associated input files in :code:`test/mydir/testinput`.  If there are already some files there, you can use them as a template for creating your own.  Or, you can look for :code:`testinput` files from other repositories that test similiar functionality.

Let's call our configuration file :code:`test/testinput/myclass.yaml`.  To proceed, we would create the file and then edit it to activate the code features that we wish to test.

As mentioned way back in Step 1, some tests do not require new infrastructure.  Some new tests only require a different configuration file to activate a different feature of the code.  If this is the case for you, then you can just duplicate an existing configuration file and modify it accordingly, skipping Steps 1-6.

Step 8: Register all files with CMake and CTest
------------------------------------------------

In steps 1-7 above we have created or modified three files, namely the source code for our tests, :code:`test/mydir/MyClass.h`, the executable :code:`test/executables/TestMyClass.cc`, and the configuration file :code:`test/testinput/myclass.yaml`.  In order for CMake to compile and run these files, we have to let CMake know they exist.

We achive this by editing the file :code:`test/CMakeLists.txt`.  This is where the tests are managed from the perspective of CMake and CTest.

We'll start with the configuration file because every new test you add is likely to have a new configuration file.  Edit the CMakeLists.txt file and look for a list of input files like this one from :code:`oops/qg/test/CMakeLists.txt`:

.. code:: CMake

   list( APPEND qg_test_input
     testinput/3dvar.yaml
     testinput/3dfgat.yaml
     testinput/4densvar.yaml
     testinput/4dvar.alpha.yaml
     [...]
     testinput/test_op_obs.yaml
     testinput/analytic_init.yaml
     testinput/analytic_init_fc.yaml
     compare.sh
   )

You would add your input file, :code:`test/testinput/myclass.yaml` to this list (note that the path is relative to the path of the :code:`CMakeLists.txt` file itself).  If you search on :code:`qg_test_input` in the file, you can see that list is later used to create a soft link for the input files in the build directory, where the tests will be run.

Finally, at long last, you can register your test with CTest.  We can do this with a call to :code:`ecbuild_add_test()` in the :code:`test/CMakeLists.txt` file.  Here is an example from :code:`oops/qg/test/CMakeLists.txt`:

.. code:: CMake

   ecbuild_add_test( TARGET  test_qg_state
                  SOURCES executables/TestState.cc
                  ARGS    "testinput/interfaces.yaml"
                  LIBS    qg )

The TARGET option defines the name of the test.  The use of TARGET, as opposed to COMMAND, tells CMake to compile the executable before running it. This requires that we specify the executable with the SOURCES argument, as shown.

The configuration file is specified using the ARGS argument to :code:`ecbuild_add_test()`.  This will be implemented as a command-line argument to the executable as described in :ref:`Manual Execution <manual-testing>`.  The LIBS argument specifies the relevant source code through a previous call to :code:`ecbuild_add_library()`.  

So, our example would look something like this:

.. code:: CMake

   ecbuild_add_test( TARGET  test_myrepo_myclass
                  SOURCES executables/TestMyClass.cc
                  ARGS    "../testinput/myclass.yaml"
                  LIBS    myrepo )

Note that this is sufficient to inform CMake of the existence of our executable so it need not appear in any other list of files (such as :code:`test_qg_input` above or similar lists of source files used to create the ecbuild libraries).  Furthermore, since the executable includes our test application file :code:`test/mydir/MyClass.h`, it will be compiled as well, as part of the compilation of the executable.  So, we're done!  Good luck with debugging!

There are many other useful arguments for :code:`ecbuild_add_test()`.  As usual, the best source for information is the file that defines the macro itself, `cmake/ecbuild_add_test.cmake <https://github.com/ecmwf/ecbuild/blob/master/cmake/ecbuild_add_test.cmake>`_ in `ECMWF's ecbuild repository <https://github.com/ecmwf/ecbuild>`_.  And, as usual, we recommend that you peruse the other JEDI repositories for relevant examples.  If you want to add input data files and/or Fortran namelists to your test configurations, have a look at how this is done in :code:`fv3-jedi/test/CMakeLists.txt`.


.. _add-app-test:

Adding an Application Test
---------------------------

The steps above are specific to Unit Tests.  You could in principle follow much of the same procedure to create an :ref:`Application test <jedi-tests>` but since these are usually used to test existing :ref:`Applications <test-apps>`, steps 1-5 would usually not be necessary.

You would have to design your application to produce a text output file as described in :ref:`Application Testing <app-testing>` and you would have to provide a reference output file to compare against.  These reference output files would be have to be added to the CMakeLists.txt file in much the same way as the input configuration files (Step 8) in order to ensure that they will be visible from the build directory; see :code:`oops/qg/test/CMakeLists.txt` for an example.

You would add your test to the appropriate CMakeLists.txt file with :code:`ecbuild_add_test()` as described in Step 8 but the argument list would be somewhat different as illustrated here:

.. code:: CMake

   ecbuild_add_test( TARGET test_qg_truth
                  TYPE SCRIPT
                  COMMAND "compare.sh"
                  ARGS "${CMAKE_BINARY_DIR}/bin/qg_forecast.x testinput/truth.yaml"
                       testoutput/truth.test
                  DEPENDS qg_forecast.x )

Here we include a TYPE SCRIPT argument and we specify :code:`command.sh` as the command to be executed.  The ARGS argument now includes the two files to be compared, namely the output of our application :code:`${CMAKE_BINARY_DIR}/bin/qg_forecast.x testinput/truth.yaml` (set off by quotes) and our reference file, :code:`testoutput/truth.test`.  We include the executable application in the DEPENDS argument to make sure that CMake knows it needs to compile this application before running the test.

However, before you add an Application test we must warn you :ref:`again <app-testing>` that the :code:`compare.sh` script may run into problems if you run your application on multiple MPI threads.  We are currently working on a more robust framework for Application testing.

		  
