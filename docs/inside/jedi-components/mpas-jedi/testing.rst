.. _top-mpas-jedi-testing:

.. _testing-mpas:

More on Testing
===============

MPAS-JEDI comes with an extensive suite of ctests. These tests are designed to ensure that
as much as possible of the source code is regularly exercised, and that generic applications
used in larger scale experiments are tested. Testing is an integral aspect of the
development and experiment process. It is recommended that the tests are run every time the
code is :doc:`built </inside/jedi-components/mpas-jedi/build>`. Developers working on a new
feature in the MPAS-JEDI repository should ensure that all existing tests pass before
submitting a pull request to github. We also request that some attempt is made to ensure
that new code is exercised by an existing test or a new test. There are exceptions for code
that is exercised extensively and continually in cycling experiments with verification, and
for diagnostic tools that are not automatically tested yet.

.. _ci-mpas:

Continuous integration
----------------------

MPAS-JEDI is instrumented with a continuous integration (CI) suite running on Amazon Web
Services.  Each time a pull request is issued against the :code:`develop` branch in the
JCSDA-internal repository, the MPAS-JEDI part of the MPAS-BUNDLE package is built with
Intel, GNU, and Clang compilers. Then all the MPAS-JEDI ctests are executed. A failure from
any of the ctests blocks the pull request from being merged. At this time, MPAS-JEDI is
not instrumented with a code coverage report.

.. _addtest-mpas:

Adding a test to MPAS-JEDI
--------------------------

When new codes that prove concepts or implement new features are added to MPAS-JEDI and
MPAS-Model repositories used in the MPAS-BUNDLE, corresponding ctests should be added into
the standard ctest set. This ensures that future modifications to either of those two
repositories, or to the repositories on which MPAS-JEDI depends (i.e., OOPS, SABER, IODA,
UFO, CRTM), do not break existing functionalities that are critical to users' scientific
experiments.


All the ctesting in MPAS-JEDI is controlled through :code:`mpas-jedi/test/CMakeLists.txt`.
A ctest may be either a unit test, which exercises an individual method in a given class, or
an application test that executes a generic application.  Benchmark results are provided
accompanying the ctests. A unit ctest contains results in a referene log file based
on analytical solutions or accurate numerical studies. Each application ctest has an
associated reference based on a previous execution of the same test.  To determine the pass
or failure for a ctest, the actual output is compared against the reference log file within
a prescribed small tolerance.


To simplify adding tests to MPAS-JEDI, two macro functions are provided ---
:code:`add_mpasjedi_unit_test` adds a new unit test and
:code:`add_mpasjedi_application_test` adds a new application test. The reader is referred to
:code:`mpas-jedi/test/CMakeLists.txt`, where numerous examples exist for both.  Note that the
name of the yaml and reference files must match the name of the ctest, e.g.,
:code:`test_mpasjedi_forecast` uses the configuration stored in
:code:`mpas-jedi/test/testinput/forecast.yaml` and is compared to the reference stored in
:code:`mpas-jedi/test/testoutput/forecast.ref`.


If a PR made to one of the repositories used by MPAS-BUNDLE causes the reference values of
many tests to change, it is useful to use the :code:`RECALIBRATE_CTEST_REFS` option in
:code:`mpas-jedi/test/CMakeLists.txt`.


..
  _ this is commented out
  Each ctest runs by executing a MPAS-JEDI C++ program, followed by running a Python script to
  detect ctest failures. The C++ program is mainly built upon and interfaced through
  :code:`oops`, and the output is printed using :code:`oops::Log::test()`. The Python script
  is located in the build directory at :code:`bin/compare.py`, which compares the output with
  the log reference file as mentioned above. As discernible differences are expected on
  various HPC systems, the :code:`FLOAT_TOL` and :code:`INT_TOL` parameters are provided in
  :code:`bin/compare.py` to set limits on differences for tests. In
  :code:`test_mpasjedi_forecast`, for example, such tolerance parameters set bounds for the
  difference for time integration in the Model class.


.. TODO: add tiered testing to build process, then document here

.. _mmmtest:

Additional automated testing on Cheyenne
----------------------------------------

There are two additional testing mechanisms in place on Cheyenne that provide 
automated test coverage.

(1) A daily cron job builds MPAS-JEDI from :code:`JCSDA-internal/mpas-bundle::develop`
branch, then runs the standard ctest suite.  To keep MPAS-JEDI up to date with the latest
development from JEDI infrastructure, the develop branch from JEDI-core repos, including 
:code:`OOPS`, :code:`SABER`, :code:`IODA`, :code:`UFO` and :code:`CRTM`, are checked out to
build the code. This allows us to promptly identify any changes in upstream repositories
that break MPAS-BUNDLE.


(2) A weekly cron job builds the :code:`JCSDA-internal/mpas-bundle::develop` branch, then
runs a 6-day 120-km resolution cycling DA experiment. The experiment uses 3DEnVar to
assimilate conventional observations (sondes, aircraft, gnssro refractivity, satwind,
surface pressure) and AMSUA clear-sky radiances (aqua, noaa-15, noaa-18, noaa-19, and
metop-a). The results are automatically analyzed for statistical comparison to GFS analyses.
This test ensures that the MPAS-BUNDLE performance does not diverge far from a benchmark.
