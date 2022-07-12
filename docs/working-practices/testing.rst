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

Travis-CI
---------
Travis-CI computational `resources <https://docs.travis-ci.com/user/reference/overview/#virtualisation-environment-vs-operating-system>`_
are limited which makes this tool more suitable for
less computationally expensive tests. Travis-CI builds JEDI inside the CLANG
container. :code:`.travis.yml` in each repository includes instruction for
Travis-CI on pulling the docker container, building the code, and running the tests.
The status of the Travis-CI job will be printed under the “Check” section in each
PR page. The status line has a link to the build and test output.
All users can view the output to get more information
about the build and debug their code.

AWS CodeBuild
-------------
For AWS CodeBuild, instances with different CPU and memory sizes are available
to choose from based on the computational needs. Currently, CodeBuild is
set to use the three Clang, GNU, and Intel containers testing the main JEDI repositories.
With every new PR or a new commit to an existing PR, the three CodeBuild projects
get triggered to build and test the code. YAML files with building and testing
instructions for CodeBuild projects are located under the “CI” directory in each repository.

CodeCov
-------
After building JEDI and running the tests, CodeCov is used to create a report on
the test coverage. The test coverage report highlights the sections of the code
that are not fully tested so developers can focus on writing tests for these
sections. CodeCov also calculates how much new changes (with pull requests) impacts
the test coverage and reports it to the GitHub pull request page. You can find more
information about test coverage and using gcov to generate test coverage report on
your local machine :doc:`here <../inside/developer_tools/gcov>`.

Testing Development across Multiple Repositories
------------------------------------------------
Sometimes the development of a new feature requires changes in multiple
repositories. You can test this new feature with Travis-CI and AWS CodeBuild by using the
same branch name when creating a new branch in each repository.
When you invoke the automated testing tools by creating a PR or pushing a commit
to an existing PR, the tools will search for branches with a similar name as the branch
that is being tested. If such branches exist in repositories in the bundle, it
will build and test your code using these branches. For example, if you create a PR in UFO
from a branch named :code:`feature/a`  automated testing tool will search in all the
repositories listed in ufo-bundle/CMakeLists.txt i.e. fckit, atlas, oops, saber, etc.
for :code:`feature/a` branch and use those branches for testing.

Searching for branches with similar names also happens for dependent repositories,
and the results will be printed on the PR page under the “Check” section.
For example, if you are issued a PR from your branch :code:`feature/b` in IODA repository,
automated testing tool will search in all dependent repositories including UFO,
and all the models for :code:`feature/b` branch. If this branch exists it will add a new line under
“Check” with a pending status stating the repository name. This feature will remind
users to test dependent repositories before merging a PR into the develop branch.


Testing Downstream Repositories with AWS CodePipeline
-----------------------------------------------------
In some cases, comprehensive testing of downstream repositories, including the
models, is required. Let’s say you are adding a new feature to the OOPS repository.
You know that the new changes will impact downstream repositories such as SABER and
UFO, and you want to test your code using automated testing tools in your PR.
In this case, you can trigger the downstream tests by pushing a commit with the
message “trigger pipeline”. You can submit an empty commit using the command below:

.. code:: bash

  git commit --allow-empty -m “trigger pipeline”

AWS CodePipeline is designed to start multiple CodeBuild projects to build and test
downstream repositories when the commit message contains the phrase
“trigger pipeline." This feature is currently implemented only for the OOPS repository,
but will be implemented for JEDI core repositories (e.g. SABER, IODA, and UFO) as well.
The OOPS pipeline is set to invoke building and testing IODA, SABER, UFO, and SOCA
after OOPS CodeBuild-CLANG is finished (more downstream repositories will be added).
The status for building and testing each of these repositories will be printed under
the “Check” section on the PR page.

.. warning::
  This feature is currently in progress. Please test it and let us know if you have any suggestions for improving this feature.


Tips on How to Use Automated Testing Tools
------------------------------------------
* Automated testing tools such as Travis-CI and CodeBuild are to be used after you have ensured the successful build of your new feature. It is not meant to be used for debugging.

* Please limit the number of pushes to an existing pull request. Automated testing tools build and run all the tests with every push to and existing PR. Pushing every commit to an existing pull request can congest the queue and slow down the process for all users. You can reduce the number of pushes by pushing multiple commits together instead of just one commit at a time.
