##########################
Branching and merging code
##########################

Following the :doc:`git flow structure </inside/practices/gitflow>`, repositories contain two special branches:
the master branch which contains released versions of the code, and the develop
branch which will contain all developments to be included in future releases.
The branching model also provides three categories for other branches: feature
branches where most developments happen, release branches for preparing new code
releases and hotfix branches for bug fixes in already released code.
This is different from older common working practices where master and develop
are in the same branch (trunk) which is also where preparation of releases happen
and where bugs are fixed.

A typical development will start by creating a feature branch (named feature/great_new_stuff)
where the development work will happen.
In most cases, this branch is created from the develop branch.
Once the feature has been developed and tested, the new code is merged back in the
develop branch.

As work happens in parallel, other developments might have been merged into the develop
branch in the meantime.
It is in principle the responsibility of the developer to first merge the develop
branch into the feature branch and resolve conflicts.
If the conflicts are simple to resolve this will be the case.
If the conflicts are more complex to resolve, this is done in collaboration with the
developer who introduced the conflicting change, or as a last recourse, by
gatekeepers of the overall code.

For early detection of conflicts and easier resolution, modern practice recommend
frequent merges of feature branches into the develop branch and frequent merges of
the develop branch into the feature branch as work progresses.
It is much more efficient to fix several small conflicts one after the other than
large conflicts coming from several independent developments all at once after long
periods of disconnect work.
Early detection encourages discussions between developers to plan merging of future
code changes before merges become too difficult.

Modern software design will also help in reducing conflicts in the development
and merging process (explained below).

At some point, it will become necessary to prepare releases of the code.
This process happens in specific releasebranches.
Once a release is ready and fully tested it is merged into both the master and
develop branches and tagged.
Typically, the tag will contain the release number (for example 2.0 for a major
release, or 2.1 for a minor one).
The masterbranch then contains the new official release and development work
continues in the develop branch based on the release.

Despite all the care being taken in the testing, there will always be (hopefully rare)
bugs needing fixing in any software.
When such a bug is detected in a release, a hotfix branch is created from the
master branch to implement and test the fix.
Once a satisfactory fix is implemented, the bug fix branch is merged into both
the master and develop branches and the release number is incremented (a new tag
is created with a minor version number increased, for example from 2.1.0 to 2.1.1).
For reproducibility, an existing tag should never be moved.

See the guide for
`getting started with git-flow <../developer/developer_tools/getting-started-with-gitflow.html>`_
for more details.
