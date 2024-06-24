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
or relaxing of a test criterion should be fully justified and documented. You can
find more details about adding a new test in the
:doc:`Adding a New Test <../inside/testing/adding_a_test>` section.

As the software industry favored frequent and small modifications to the code
(agile methodology) as a development approach, the need for frequent automated
testing became paramount. The automated testing framework in JEDI is integrated
with GitHub and uses webhooks to perform various tasks, including testing based
on the Github event type. For example, a new change to a repository
can trigger a certain set of tests.

The automated testing framework in JEDI is designed to build the application and
run the tests with every new pull request (PR) against the develop branch,
and every push to an existing PR on the GitHub repository. The status
of the tests are shown on the PR page for the developers and reviewers.
Passing all tests ensures the developers that the new feature is compatible with
all the JEDI components and can be added to the repository. With automated
testing, any error or incompatibility in the new scripts can be caught at the
early stages of the development, and can aid in running the development pipeline
more efficiently. Automated testing can help make the review process shorter
and to add new features to the repository more quickly.

`Docker containers <https://jointcenterforsatellitedataassimilation-jedi-docs.readthedocs-hosted.com/en/1.3.0/using/jedi_environment/containers.html>`_
are used to
test the system in different prebuilt environments. Currently, we use three
compiler-MPI combinations for automated testing of JEDI repositories: *GNU with openMPI*,
*CLANG with mpich* and *Intel with impi* containers.
GNU and CLANG containers are publicly available from
`JCSDA DockerHub <https://hub.docker.com/u/jcsda>`_.

In the automated testing framework, two different methods are used for building
the code: building using bundle (recommended for JEDI users) and building using
the `jedi-build-package <https://github.com/jcsda/jedi-build-package>`_.
Jedi-build-package allows us to create and save cache on a designated S3 bucket
for faster build and test of the system. Please refer to jedi-build-package
`README <https://github.com/JCSDA/jedi-build-package/blob/develop/README.rst>`_
file for more information.

Currently, `Travis-CI <https://travis-ci.com>`_ and
`AWS CodeBuild <https://aws.amazon.com/codebuild/>`_ automated testing services are
implemented in the JEDI core repositories. Both of these services provide customers
with cloud computing resources to run tests automatically and in parallel.
With every new commit to each repository, source code is downloaded from the
GitHub repository onto the automated testing server.
Docker containers are used to provide all the necessary
libraries and packages required to build and run the application. The next stage
is to build and run the tests inside the Docker environment and on the automated
testing server, and to report the test status on the PR GitHub page.
Almost all the scripts that are used by the automated testing framework are located in
the “CI” directory, except for :code:`.travis.yml` that is located in the base directory.

GitHub Automated Testing
-------------
Most repositories in the JEDI Bundle are tested using a test automation system
built on AWS Batch that automatically provisions a fresh environment and
launches tests on the Clang, GNU, or Intel containers. One environment will be
provisioned randomly, although the environment can be configured with
annotations added to your pull request description.

Full documentation for CI configuration and pull request annotations are
provided in the test output attached to the pull request. Just click the
"details" link on the check run.

Note that check runs will not execute for draft pull requests unless you add a
line to your pull request description that reads "run-ci-on-draft=true". In
order to re-launch a test you can push an empty commit.

.. code:: bash

  git commit --allow-empty -m 'trigger CI' && git push

Testing Development across Multiple Repositories
------------------------------------------------
Sometimes the development of a new feature requires changes in multiple
repositories. You can test this new feature in JEDI CI using annotations in
your pull request description. The annotations must link to pull requests
in other JCSDA-internal repositories.


.. code:: plaintext

  This is my generic pull request description. My change requires coordinated
  changes in oops and saber. My tests won't pass unless your bundle contains the
  matching changes.

  build-group=https://github.com/JCSDA-internal/oops/pull/123
  build-group=https://github.com/JCSDA-internal/saber/pull/456


Tips on How to Use Automated Testing Tools
------------------------------------------
* Automated testing tools are to be used after you have ensured the successful
  build of your new feature. It is not meant to be used for debugging.

* Please limit the number of pushes to an existing pull request. Automated
  testing tools build and run all the tests with every push to an existing PR.
  Pushing each commit individually can congest the queue and slow tests for all
  users. You can reduce the number of tests run by converting your pull request
  to a draft, or by pushing multiple commits together instead of one at a time.
