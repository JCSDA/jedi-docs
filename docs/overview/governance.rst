Governance of a Community System
================================

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
judgement on its scientific excellence.
It could be that aspects that are critical for one user are useful only for that user.
In that case, the code should be kept in a separate repository and it is the build
system that brings the codes together and includes what is required for a given
application without affecting the others.
In that respect, current efforts to modernism software architecture in the data
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
On one hand, a specialized sub-class in an inheritance structure leaves no trace
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
