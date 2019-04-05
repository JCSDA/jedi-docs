.. JEDI Documentation documentation master file, created by
   sphinx-quickstart on Tue Mar  6 11:51:45 2018.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

JEDI Documentation
==================

Welcome to JEDI!

This documentation will help you get started with JEDI whether you are a user or a developer.

Table of Contents
-----------------

.. toctree::
   :maxdepth: 2
   
   background/index.rst
   working-practices/index.rst
   developer/developer_tools/index.rst
   developer/jedi_environment/index.rst
   developer/building_and_testing/index.rst
   jedi-components/index.rst


Background
^^^^^^^^^^

The long term objective of the Joint Effort for Data assimilation Integration (JEDI) is to
provide a unified data assimilation framework for research and operational use, for
different components of the Earth system, and for different applications, with the
objective of reducing or avoiding redundant work within the community and increasing
efficiency of research and of the transition from development teams to operations.

See the following links for additional background information.

* `High-level requirements for JEDI <background/requirements.html>`_
* `General methodology for JEDI <background/methodology.html>`_

Working Practices
^^^^^^^^^^^^^^^^^

Nowadays, software development is a collaborative activity, between members of a team
and across teams, locally or spread over different cities or countries.
Developers working on common software might even never physically meet.
Nevertheless, work needs to be coordinated efficiently to avoid wasted effort.
Modern software engineering practices make this routine achievement in the
software industry.
The infrastructure proposed here in the context of weather forecasting and
related developments relies on those modern software engineering practices.
It enables fast and easy engagement, flexible code management and proper control
of operational releases.

This section describes the working practices and governance for collaborative code
development using the GitHub ecosystem (`GitHub <https://github.com/>`_ and
`ZenHub <https://www.zenhub.com/>`_) and the
`git flow <http://nvie.com/posts/a-successful-git-branching-model/>`_ workflow.
GitHub is a git management tool with online interface and repositories and
ZenHub is a planning and issue tracking tool that links with git repositories.
These tools are all cross connected to form an ecosystem that has become an
industry standard.
They provide the means for easy access and fast engagement while still allowing
proper control at all levels.

This document is fairly general and most of it can be applied to any collaborative
code development.
Practical aspects for developers to start with the system are described separately.

See the following links for more details on the JEDI working practices.

* `Branching and merging code <working-practices/branch-merge-code.html>`_
* `Forking and cloning repositories <working-practices/fork-clone-repos.html>`_
* `Reviewing code <working-practices/reviewing-code.html>`_
* `Testing <working-practices/testing.html>`_
* `Creating documentation <working-practices/creating-docs.html>`_

Governance of a community system
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The decision to include code or not into a community system depends on several
criteria.
Of course scientific and technical quality are among the criteria, but usefulness
to the community is another very important one.
It is in fact the most important.
For every community project, there should be a governance body to make that decision,
based on that sole criteria.
The review process determines if the scientific and technical quality are sufficient
at any point in time.

The decision not to include a certain aspect in the community code is not a
judgment on its scientific excellence.
It could be that aspects that are critical for one user are useful only for that user.
In that case, the code should be kept in a separate repository and it is the build
system that brings the codes together and includes what is required for a given
application without affecting the others.
In that respect, current efforts to modernise software architecture in the data
assimilation and forecasting system are absolutely essential because previous
programming technology did not make this possible.

In old style Fortran, separating code that was specific to a user from a community
code meant that some subroutine calls would be left dangling and possibly some
global variables would be left in a unknown state.
This was addressed with dummy routines that would be provided with the common code.
Unfortunately, this approach doesn’t scale and quickly becomes unmanageable.
The solution was then to include everything in the shared code, which quickly became
bloated, difficult to manage, and unpopular.

In modern programming this is common practice.
On one hand, a specialised sub-class in an inheritance structure leaves no trace
behind when it is removed.
Examples can be the use of specific observation types in a DA system, or a specific
physics package in a model and many other circumstances are possible.
On the other side of the spectrum, a high level application constructed from a
collection of objects does not have any impact on other applications using all or
some of the same objects.
Software packages might have only low level extensions (e.g. browsers or
applications like photoshop that support plugins) or high level extensions
(system libraries or MPI) or both (JEDI is in that category).

However, this will only work if the interfaces in the middle layer are stable.
If interfaces of a base class change, all subclasses will need to adapt.
If interfaces of the objects used by high level applications change all those
applications will need to change.
If that happens often, the system will quickly become unpopular.
It is the second role of a governance body for a community unified data assimilation
and forecasting system: ensure that changes in the interfaces are infrequent and
fully justified, documented and communicated if they become necessary.

The last role of the governance body is to provide guidelines regarding who has
authorization to review and administer code at each level, most importantly at the
release preparation level.
Typically, this means designating a small pool of reviewers for each main component
of the code, and a criterion, such as a minimum number of reviewers approving the
pull request, for accepting it.
The size of the pool of reviewers and number of approvals should ensure enough
scrutiny, while maintaining an efficient process.
As explained above, reviewers should be trusted to add other reviewers or delegate
their roles on a case by case basis, in particular for small changes.

Roles and Responsibilities
^^^^^^^^^^^^^^^^^^^^^^^^^^

**Governance board:** The board comprises representatives from the organizations
involved in the collaboration and the project lead(s).
It makes high level decisions about the directions of development and designates
the administrators of the central repository and senior reviewers.

**Project lead:** leads and coordinate code developments in the directions given
by the board.
Reports on progress and issues to the board.

**Administrators** (a.k.a. gatekeepers, project maintainers): are responsible for
giving access at the repository or branch level to relevant collaborators.
The administrators have the authority to merge pull requests after it has been
approved by reviewers.
Administrators can give advice and help developers when merging conflicts arise.
Each forked repository should have at least one administrator.

**Reviewers:** check that a proposed pull request follows all the minimum
requirements for the level at which it is to be merged, including coding standards,
passing of relevant tests (that have been run by the developer) and scientific
evaluation if applicable.
In principle all developers should be involved in reviewing other developer’s code.
Senior reviewers can be designated by the board to oversee reviews in particular
areas of the code.

**Developers:** anybody who edits the code.
Developers have the responsibility to document their developments, to update them
to the level of the develop branch and to test them before submitting a pull request.

Conclusion
^^^^^^^^^^

The code management structure described here provides mechanisms for a unified
data assimilation and forecasting system that is open to the wider scientific
community as well as tightly controlled for operational use.

The organisation structure provides clear roles for developers, reviewers and
the governance body as well as guidelines for interactions between those roles,
thus ensuring efficiency of the continuous development process.

Indices and tables
==================

* :ref:`genindex`
* :ref:`search`
