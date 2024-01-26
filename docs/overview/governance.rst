Governance of a Community System
================================

The decision on whether to add code to a community system is based on several
criteria, including scientific and technical quality. Usefulness
to the community, though, is the most important consideration.  Within the context of a community data assimilation and forecast system, the first role of the governance framework is to make these decisions, with well-defined responsibilities within the decision-making process for the internal project leads, JCSDA management, and community oversight.

The review process determines if the scientific and technical quality of the code are sufficient.  However, the decision not to include a certain aspect in the community code is not a
judgement on its scientific excellence;
It could be that aspects that are critical for one user are useful only for that user.
In that case, the code should be kept in a separate repository and it is the responsibility of the build system to include what is required for a given
application without affecting the others.
In that respect, modern software development architectures are absolutely essential to provide this level of functionality in a data assimilation and forecasting system. Previous
programming technology simply did not make this possible.

In old style Fortran, separating user-specific code from a community
code meant that some subroutine calls would be left dangling and possibly some
global variables would be left in a unknown state.
This was addressed with dummy routines that would be provided with the common code.
Unfortunately, this approach doesn't scale and quickly becomes unmanageable.
The solution was then to include everything in the shared code, but this resulted in code that was
bloated, difficult to manage, and unpopular.

With modern programming this situation can be avoided.  Common practices such as modularity, generic programming, and separation of concerns permit more versatile and efficient workflows.

Structure of JEDI
-----------------

In the old code style, a specialized sub-class in an inheritance structure leaves no trace
behind when it is removed.
On the other side of the spectrum, a high-level application constructed from a
collection of objects does not have any impact on other applications using all or
some of the same objects.
Software packages might have only low level extensions (e.g. browsers or
applications like photoshop that support plugins) or high level extensions
(system libraries or MPI) or both.  JEDI is in the latter category.

However, this will only work if the interfaces in the middle layer are stable.
If interfaces of a base class change, all subclasses will need to adapt.
If interfaces of the objects used by high level applications change, all those
applications will need to change.
If that happens often, the system will quickly become unpopular.
The second role of a governance framework for a community unified data assimilation
and forecasting system is to ensure that changes in the interfaces are infrequent and
fully justified.  If a change is justified, then it must be documented and communicated.

The third role of the governance framework is to establish who has
authorization to review and administer code at each level, most importantly at the
release preparation level.
Typically, this means designating a small pool of reviewers for each main component
of the code and a criterion, such as a minimum number of reviewers approving the
pull request, for accepting it.
The size of the reviewer pool and number of approvals needed for a pull request should ensure enough
scrutiny without sacrificing the process's efficency.
Reviewers should be trusted to add other reviewers or delegate
their roles on a case by case basis, particularly for small changes.


JEDI Roles and Responsibilities: Our Governance Framework
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Management Oversight Board (MOB)
--------------------------------

The `JCSDA MOB <https://www.jcsda.org/team>`_ is made up of representatives from `JCSDA partner organizations <https://www.jcsda.org/partners>`_ and the broader community.  The MOB is responsible for the approval of policies, goals and priorities of the JCSDA, including recommendations on observing systems planned for operational use.  The MOB also ensures cooperation among sponsoring organizations and institutions, and in extreme cases makes project decisions if the normal community-based process breaks down.

The MOB provides oversight of the scope, vision, and direction of the project, including strategic collaborations with other organizations, overarching policies, and general management issues.  They make high-level decisions when regular community discussion doesn't produce consensus in a reasonable time frame.

Executive Team (ET)
-------------------

The JCSDA Executive Team (ET) consists of Associate Directors who work with the JCSDA Director.  The role of the ET is to ensure the long-term well-being of the project, both technically and as a community.

It is the responsibility of the ET to assist the JCSDA Director and the MOB in making decisions about the overall scope, vision and direction of the JEDI project, including strategic collaborations and policies. Because of their expert knowledge of the project software and services the ET members are also expected to provide guidance to potentially less experienced contributors.

Project Leads
-------------
Direct management responsibility of The JEDI Project lies primarily with the Project Leads.  This includes the JEDI Project Leader as well as subordinate project team leaders responsible for Software Infrastructure, Model and Observational Interfaces, Data Assimilation, and Cloud Infrastructure.

The project leads are responsible for managing the JEDI project according to the tenets identified in the JCSDA Software Governance and Oversight document Rev 1, in coordination with the JCSDA Director and Associate Directors, and with those JCSDA Partners that have a direct interest in the success and ultimate application of the project.

The project leads assume responsibility for delivery of the JEDI software to the various stakeholders and for coordinating the efforts of both core and in-kind contributors, as identified in the JCSDA Annual Operating Plan (AOP) and any individually designated work plans.  This includes generating requirements, responding to stakeholders, initiating collaborative efforts, identifying parallel efforts, reducing duplication of effort, bringing new partners on board, and assisting partners with implementation, testing, development, and technical support.  It also includes quarterly reports to the MOB and the ET and the execution of code sprints and training events.

In terms of direct software development, project leads serve as contributors, reviewers, and administrators for the GitHub repositories that host the JEDI code.  Administrators are responsible for controlling access to the repositories and merging pull requests after they pass code reviews, following the do-no-harm approach.  No code is merged until other developers attest to its scientific and technical quality and verify that it satisfies coding standards, is well documented, and passes all tests.

Contributors
------------

A contributor is anyone who writes code, documentation, or designs, or adds other work to the project; they become a developer when their pull request is accepted.  This includes JCSDA core staff, in-kind staff, and external contributors or contractors.  Contributors participate in the JEDI project by submitting, reviewing and discussing GitHub pull requests and issues and participating in open and public project discussions on GitHub and other channels. 

Developers have the responsibility to document their developments, to update them to the level of the develop branch, and to test them before submitting a pull request. In principle all developers should be involved in reviewing other developer's code.

The JEDI Community also includes users, who are the largest group within the community. Contributors work on behalf of and are responsible to the larger JEDI Community and we strive to keep the barrier between contributors and users as low as possible.
