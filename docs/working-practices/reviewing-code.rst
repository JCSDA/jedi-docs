#########################################
Reviewing code
#########################################

We now discuss procedures to control the contents of branches, especially the
develop and master branches.
This is the role of the review process.

The functionality offered by GitHub and ZenHub will be used to increase the efficiency
and reliability of the review process.
The merging of branches should happen through a pull request within the GitHub environment.
Each pull request should be assigned reviewers and the review should happen within the
environment.
Discussions and comments will be stored within the system and can be referred to later
if needed.
This is different from older common working practices where reviews happen by email
and are almost impossible to trace later on.

The review process is an integral part of the development work and should be considered
from the start.
As a result, at the beginning of each development, it is assigned a ZenHub issue where
discussion and documentation can happen during the development process and can be
referred to during the review process and later if required. 

Reviewers should be assigned for any new development as soon as it starts; assignments
are done through ZenHub.
Reviewers should be aware of what is coming ahead of time and not be surprised by
unannounced massive changes.
Reviewers can be reassigned so that the most relevant people are involved at any
point in time.
The number of reviewers is not fixed.
For a trivial bug fix or very local changes that do not affect the rest of the system,
one reviewer is enough.
For more complex modifications, more reviewers should be included.
It is suggested that a list of default potential reviewers is designated and maintained
for each large components of the code (B matrix, observation operators, etc…) to
assist in the process and that regular developers are also involved in reviewing
each other’s code as an excellent way to promote a common culture and knowledge of the code. 

It is in the interest of both developers and reviewers to review and merge code often
in small incremental changes rather than massive changes at once.
This facilitates the process, exposes code earlier to other developers who could be
affected and facilitates the merging.
In case of merge conflict, the developer should try to fix them first.
If the conflict is complicated to resolve, the developer should liaise with and
resolve the situation with the developer who has merged the conflicting changes.
GitHubs and ZenHub provide the tools for that type of communication directly in
the system.
This will promote a common culture and knowledge of the code.
Other developers or overall maintainers of the system can be brought into the
discussion if it cannot be resolved by the two initial developers.

Once code has been reviewed and accepted in the review mechanism, it is merged as
is without further modifications, clean-up or other improvements.
Because the developers should have merged their branch up to the current level of
the develop branch, the merge will be automatic and without conflict.
Even gatekeepers should have their code reviewed.

Decisions in the review process could include scientific and technical aspects and it
is possible to assign different reviewers for each aspect.
However, in principle, discussions of a scientific nature should happen at the level
of the ZenHub issue and before branches reach the level of the pull request.

An important aspect in the multiple level forking model is that review should happen
at every level, thus giving several levels of control on the code.
When developers create a pull request to the organisation’s repository, the code
should be reviewed as described above.
Then, another pull request will be issued from the organisation to the central
repository, triggering another level of review.
Depending on the level of the changes, the first or second review will be more or
less important.
In any case, discussions and documentation related to the feature (through the
reviews and the ZenHub system) should be visible in both levels.

There is yet another chance to review changes when preparing a release.
As any branch, a release branch can contain code modifications and should be reviewed.
Git provides tools that help removing a given commit (merge or other) that is
decided should not have been included.
It is easier than it was in the past but it is not perfect and it should be the
exception, not be the norm.
Reviews at every level should be treated seriously.

Finally, as it is good practice to merge often, the review process should be efficient.
Modern tools help but reviewers should make code reviews a priority.
As an example, some teams in the Agile/Scrum methodology do not allow developers
to start work on a new issue as long as there are reviews pending.
Although we cannot go that far, incentives to prioritize code reviews should be discussed.

Modern data assimilation and forecasting systems are very complex.
As we enter an era when coupled system will become the norm, complexity will increase
even more.
It is important to recognise this and to accept that nobody can understand and
control the whole system.
This is why it is important that the reviewing of code is shared between people
with different areas of expertise.
It will also distribute the work and make the process more efficient.
