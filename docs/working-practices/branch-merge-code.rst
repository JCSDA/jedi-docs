##########################
Branching and merging code
##########################

Following the :doc:`git flow structure </inside/practices/gitflow>`, repositories contain two special branches:
the main branch, which contains released versions of the code, and the develop
branch, which contains developments to be included in future releases.
The branching model also includes three other branch categories: feature
branches for adding developments, release branches for preparing new code
releases, and hotfix branches for bug fixes in already released code.
This is different from older working practices where main and develop
are in the same branch (trunk) which is also where preparation of releases happens
and where bugs are fixed.

A typical feature development will start by creating a feature branch (named feature/great_new_stuff)
where the development work will happen.
In most cases, this branch is created from the develop branch.
Once the feature has been developed and tested, the new code is merged back in the
develop branch.

Since work happens in parallel in the repository, other developments might have been merged into the develop
branch in the meantime.
It is in principle the responsibility of the developer to first merge the develop
branch into the feature branch and resolve conflicts before adding a feature to the develop branch.
If the conflicts are simple to resolve this can be done by the developer alone.
If the conflicts are more complex to resolve, this is done in collaboration with the
developer who introduced the conflicting change or, as a last recourse, by
gatekeepers of the overall code.

For early detection of conflicts and easier resolution it is best to do
frequent merges of feature branches into the develop branch and frequent merges of
the develop branch into the feature branch as work progresses.
It is much more efficient to fix several small conflicts one after the other than
large conflicts all at once after long periods of disconnected work.
Early detection also encourages discussions between developers to plan merging of future
code changes before merges become too difficult.

At some point it will become necessary to prepare releases of the code.
This process happens in specific release branches.
Once a release is ready and fully tested it is merged into both the main and
develop branches and tagged.
Typically, the tag will contain the release number (for example 2.0 for a major
release, or 2.1 for a minor one).
The main branch then contains the new official release and development work
continues in the develop branch based on the release.

Despite all the care being taken in the testing, there will always be (hopefully rare)
bugs needing fixing in any software.
When such a bug is detected in a release a hotfix branch is created from the
main branch to implement and test the fix.
Once a satisfactory fix is implemented the hot fix branch is merged into both
the main and develop branches, and the release number is incremented (a new tag
is created with a minor version number increased, for example from 2.1.0 to 2.1.1).
For reproducibility, an existing tag should never be moved.

See the guide for :doc:`getting started with git-flow </inside/practices/gitflow>` for more details.
