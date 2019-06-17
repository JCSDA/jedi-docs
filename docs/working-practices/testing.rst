#######
Testing
#######

Testing is a mandatory step of the development process and no branch should
be merged without prior testing.

To assist developers and reviewers in their roles, the ecosystem includes
facilities for testing the code.
This entails two aspects: tests have to be developed and the environment should
make it easy to add and run them.

Although some tests exist for various systems, it should be considered part of
the development process to add tests to the existing collection.
Developers are the best persons to write tests for their code and every major
development should be included with its associated tests.
The tests should be reviewed as any other part of the system and any by-passing
or relaxing of a test criterion should be fully justified and documented.

An automated test system (e.g., `Go CD <https://www.gocd.org/>`_,
`Travis <https://travis-ci.org/>`_) will be used.
This system can be configured to automatically run a test suite on certain actions.
For example, tests can run automatically for every push on a repository.
Tests can also be run automatically every night or every weekend and can be
configured to run on several platforms and with several compilers.

Running a full operational suite as a test is very expensive and also not the most
helpful to prevent bugs from entering the system.
A hierarchy of tests will be developed and provided, ranging from unit testing,
regression testing, to low and high resolution application testing.
Some tests will include code performance criteria to prevent unintentional or
unnoticed creep of computational costs in the system.
Scripts checking the conformance of the source code to a set of defined coding norms
will also be included in the testing to facilitate the reviewing process.

The environment will be configured to run tests automatically and pull requests will
be disabled until all tests in a predetermined suite pass without failure.
For efficiency and cost reasons, this cannot include all levels of tests.
Additional more expensive tests will be run regularly on the develop branch and
issues reported back to developers as they are discovered.
This ensures issues are detected early which will facilitate and accelerate the
preparation of new releases to the master branch.

Although tests will run automatically on certain actions or at predetermined times,
developers can run them manually at any time on their branch.
They will be encouraged to do this regularly to detect potential problems early and
fix them early.
