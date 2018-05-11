Adding a New Unit Test
=======================

This document describes the steps you need to take to create your own unit tests within JEDI.  Before reading it, we highly recommend that you first read the :doc:`companion page on how tests are organized, implemented and executed within JEDI <unit_testing>`.

Step 1: Determine what class your test falls under
-------------------------------------------------------

As described in :doc:`JEDI Testing <unit_testing>`, JEDI unit tests are implemented as objects within the :code:`oops:Test` class.  Furthermore, as shown in the diagrams in :ref:`Tests as Applications <test-apps>`, different types of unit tests are organized into different sub-classes of :code:`oops::Test`.  Examples include :code:`test::State<MODEL>`, :code:`test::LinearModel<MODEL>`, :code:`test::ObservationSpace<MODEL>`, etc.  Each of these class templates is defined :code:`oops/src/test/interface`.  The names of the header files found there generally reflect the different sub-classes of unit tests that are available.

So, pick whichever one of these subclasses is appropriate for the test that you want to write.

Step 2: Write your high-level test
----------------------------------

When you have determined which sub-class of :code:`oops::Test` your test belongs in, then edit the corresponding header file in :code:`oops/src/test/interface`.  And, write your test as a method (member function) of the appropriate sub-class.  Be sure to include one or more calls to BOOST_CHECK(), BOOST_CHECK_CLOSE(), BOOST_CHECK_EQUAL() or :ref:`some other valid Boost test function <unit-test>`.  Consult the `Boost test documentation <https://www.boost.org/doc/libs/1_66_0/libs/test/doc/html/index.html>`_ for a complete list and remember that CHECK is only one option for <level>, along with WARN and REQUIRE.

As an example, let's say you wanted to define a new test called :code:`MyTest()` and you want to place it within the :code:`test::GeoVaLs` sub-class.  Remember that, unlike :code:`oops::GeoVaLs`, :code:`test::GeoVaLs` is an application that we will eventually execute.  However, test objects generally have access to oops objects of the same name.  For example, :code:`oops/src/test/interface/GeoVaLs.h` includes the following line:

.. code:: C++

   #include "oops/interface/GeoVaLs.h"

So, if you want to test something having to do with :code:`oops::GeoVaLs` objects, then it's probably a good idea to define your test as a method of :code:`test::GeoVaLs`.  So, let's proceed to edit the file :code:`oops/src/test/interface/GeoVaLs.h`.

Following the example of :code:`TestStateConstructors<MODEL>()` in :ref:`Anatomy of a Unit Test <unit-test>`, as well as the existing unit tests in :code:`oops/src/test/interface/GeoVaLs.h`, we might proceed as follows:

.. code:: C++

   template <typename MODEL> void MyTest() {
     typedef GeoVaLsFixture<MODEL>   Test_;
     typedef oops::GeoVaLs<MODEL>    GeoVaLs_;
     typedef oops::ObsOperator<MODEL> ObsOperator_;

     // retrieve information from the config file as needed
     // For GeoVaLs this may require iterating over multiple observation
     // types within the obseravation space.  So, first define conf
     // as an array of multiple configuration objects, corresponding to each
     // of the items listed in the Observations.ObsTypes section of the config file
     const eckit::LocalConfiguration obsconf(TestEnvironment::config(), "Observations");
     std::vector<eckit::LocalConfiguration> conf;
     obsconf.get("ObsTypes", conf);

     // iterate over the ObsTypes in the config file
     for (std::size_t jj = 0; jj < Test_::obspace().size(); ++jj) {
       ObsOperator_ hop(Test_::obspace()[jj]);

       // Access the "GeoVaLs" section within each ObsType  in the config file
       eckit::LocalConfiguration gconf(conf[jj], "GeoVaLs");

       // Create a GeoVaLs object using this information
       GeoVaLs_ gval(gconf, hop.variables());

       // Run whatever tests you wish to run, using BOOST commands
       [...]
       BOOST_CHECK_CLOSE(a,b,tol)
       [...]
       BOOST_CHECK(...)
       [...]

     }
   }


Note that the :code:`GeoVaLsFixture<MODEL>` class has a somewhat different structure than the simpler :code:`StateFixture<MODEL>` illustrated in :ref:`Anatomy of a Unit Test <unit-test>`.  The former is more complex largely because the relevant information is distributed over multiple observation types.

The salient point is that you should use the appropriate test fixture to access the relevant information in the configuration file, using other unit tests that use that fixture as a guide.  Then, you should insert one or more BOOST_CHECK statements to test whatever it is you wish to test.

You may wish to add additional messages to the debug output stream to help with debugging, as illustrated in this example from :code:`oops/src/test/interface/LinearObsOperator.h`:

.. code:: C++

    oops::Log::debug() << "Iter:" << jter << " ||(h(x+alpha*dx)-h(x))/h'(alpha*dx)||=" << test_norm << std::endl;

To do this, you will have to include this header file

.. code:: C++

   #include "util/Logger.h"

Such debug statements can be enabled by setting the environment variable :code:`OOPS_DEBUG` equal to 1 before running ctest; see :ref:`running-ctest`.

You will have no doubt noticed by now that the method we just defined is really a function template, with a different instantiation for each model.  This is true for all sub-classes of :code:`oops::Test` so you will have to :ref:`face it eventually <model-tests>`.

Step 3: Register your test
--------------------------

[this ensures that ctest will run it]

.. _model-tests:

Step 4: Define your Model Realizations
--------------------------------------

[lower-level tests but still not the lowest level, since your test may involve accessing Fortran-level code as well]

Step 5: Create a Configuration File
-----------------------------------


Step 6: Add your test to the appropriate CMakeList.txt
------------------------------------------------------
