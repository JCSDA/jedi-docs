.. _saber_test:

Adding a SABER test
===================

SABER has an automated testing system which will produce a serial and a 2-processor parallel version of each test.
This helps to catch errors and bugs which are sensitive to how the the grid is partitioned. To add a new test in
SABER, follow these steps:

Create test YAML
----------------

The test :code:`YAML` file sets the test configuration. See the other tests in the :code:`test/testinput`
directory for examples.

Create :code:`testdeps` file
-----------------------------

The :code:`testdeps` is a :code:`.txt` which lists any tests on which the new test will depend. If the new
test has no dependencies, this will be a file with just one blank line. Add this in the :code:`test/testdeps`
directory.

Add test in :code:`testlist`
----------------------------

There are several lists of tests in the :code:`test/testdeps` directory. For example, there are the tier 1 tests
which are the primary set of tests which are run as part of the JEDI CI (continuous integration) in github. Add
the name of the new test to the appropriate list. There is no need to add the test to any :code:`CMakeLists.txt`
files; this will happen automatically.

Create test reference file
--------------------------

To create the reference file containing the expected results of the test, first complete the three steps above.
Then, at the end of the test configuration :code:`YAML` file, under the :code:`test:` key, add the 
:code:`test output filename` sub-key as sketched below:

.. code-block:: YAML

  test:
    reference filename: testref/<TEST_NAME>.ref
    test output filename: testref/<TEST_NAME>.test.out


And add a blank reference file with the name :code:`<TEST_NAME>.ref` in :code:`test/testref` of the **source**
directory. Next, re-configure and re-build SABER (re-run :code:`ecbuild` and :code:`make`) to build the new test.
When the new test is built, run the test, and the output will be written into the :code:`test/testref` directory in
the **build** of SABER -- as opposed to the source directory -- in a file with the :code:`.test.out` extension.

.. hint:: 
  
  If the test has no dependencies, you can run just the single test using the :code:`ctest -R <TEST_NAME>` option.
  See the guide on :ref:`jedi-testing` for more information on :code:`ctest`.


Since there was nothing in the reference file already, running the new test to produce the output will result in a
failure, but check :code:`test/testref` to see if the test output file was created. If the output looks correct,
and the test only failed due to the reference file mis-match, use this output file that was written in 
:code:`test/testref` of the **build** dirctory to overwrite the blank reference file in the **source** directory.

When you are finished developing the test and are ready to commit it, remove the
:code:`test output filename: testref/<TEST_NAME>.test.out` line from the test :code:`YAML` file before opening the
pull request.
