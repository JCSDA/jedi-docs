.. _pullrequest-top:

PREMELT your GitHub Pull Requests
=================================

According to the :doc:`Git flow paradigm <gitflow>` followed by JEDI, all changes to the develop branch must meet the following conditions:

* They must pass all tests
* They must be reviewed by other developers

These requirements are achieved by means of Pull Requests on Github.

When your feature or bugfix branch is ready to be merged into develop, the first thing for you to do is to push it to GitHub by issuing a :code:`git push` command.

Then, from the GitHub web console, you can navigate to the repository in question and select your feature branch from the drop-down menu.  Near the branch name you should see a button called **New Pull Request**.  Select this to begin the process of merging your branch into develop.

.. hint ::

   If you want to see the changes you are proposing before issuing the pull request, look for the **Compare** button on the right of the web console, just below the green **Clone or download** button.

The action of creating a pull request will trigger a number of automated tests.  These will compile and run the code with different compilers and MPI libraries and it will check to see that the code you have added is actually executed by the tests (code coverage).  Your branch will not be merged until it passes all of these tests.  So, if you see any test failures, you should work to understand and fix them.

When you create a pull request, you should fill it in completely, as suggested by the PREMELT mnemonic:

  * **P**: Pipeline
  * **R**: Reviewers
  * **E**: Epic
  * **M**: Milestone
  * **E**: Estimate
  * **L**: Label
  * **T**: Title/Description

The same Mneumonic also applies to creating tasks as ZenHub issues.  However, in that case, the **Reviewers** item would be replaced by **Assignees**, identifying those responsible for carrying out the task.

To appreciate the mnemonic, consider the following screenshot; something like this should appear when you create a new pull request:

.. image:: images/PullRequest.png

We'll start with the last item in the PREMELT mnemonic: **T** for Title and description.  Give your pull request an appropriate title and a description that is thorough enough to give reviewers a good idea for **what** has been changed and **why**.  In other words, an overview of the changes that have been made and the motivation behind them.

The **R** in PREMELT stands for **Reviewers**.  Though any JEDI team member can review your pull request, some may not be aware of it.  If you explicitly ask someone to review it, they will get an email notification and they are more likely to review it in a timely manner.  **All pull requests require at least two approvals from reviewers before they can be merged**.

Reviewers may offer comments or questions on specific lines of code or in the general **Conversation** area of the GitHub Pull Request console.  It **your responsibility** to respond to these comments and questions and, if applicable, make appropriate changes in the code.

The *P* in PREMELT stands for the Pipeline.  This refers to the corresponding ZenHub project board that categorizes and organizes all tasks, including pull requests (documentation coming soon).  Most Zenhub workspaces include a **Review/QA** pipeline.  This is where Pull Requests should generally be placed.

Next in line come **E** for Epics and **M** for Milestones.  These are valuable tools for record keeping and project management.  Filling these out will greatly facilitate the tracking of core and in-kind contributions and will earn you the eternal gratitude of the JEDI team.

The difference between Epics and Milestones has to do with scope and time limits.  For JEDI, Epics are generally linked to the JCSDA Annual Operating Plan (AOP).  As such, Epics describe long-term project objectives that may span months of work.  If your feature branch contributes to one or more of these long-term objectives, you should make this known to the reviewers and project managers by selecting the appropriate Epic from the searchable drop-down in the right column of the Pull Request GUI.

By contrast, Milestones refer to project goals that are to be carried out over a specific time frame of a month or less.  This includes designated code sprints, so if your feature branch contributes to a sprint, this is where you would indicate that.  More generally, all JCSDA projects also define monthly milestones so you should add this to the appropriate project and month.

The second **E** stands for Estimate - how much work did this feature branch involve?  This is notoriously difficult to get right and it is often acknowledged that all estimates are wrong to some degree.  Nevertheless, it is important to distinguish between minor changes that took only an afternoon to complete and major refactoring of code that may have taken several weeks.  This is essential for project management, both for retrospective reporting and for planning future code sprints and milestones; project managers need to know roughly how much work their team can complete over a given time frame.

The numerical scale you see when you select the drop-down menu for Estimate is nonlinear.  There is little rationale behind this scale other than the idea that some tasks are much harder than others.  The most accurate way to assign a numerical value to an amount of work is to collaboratively compare it to other tasks as an agile team.  But, in the absence of this process, a good rule of thumb is 1 point for half a day's work.  So, if this feature branch only took an afternoon to implement, give it a story point of 1.  If it took a week or so of dedicated work, maybe give it an 8 or a 13.  Note that this need not mean it was done in a week because it is likely that not all your time has been solely dedicated to this particular feature branch.

For much more information on Epics, Milestones, and Estimates see the excellent documentation available from the `ZenHub Help Center <https://help.zenhub.com/support/home>`_.

Last but not least, the **L** in PREMELT refers to giving your pull request a label.  Again, this is a drop-down menu of labels that are standardized across JCSDA repositories.   Examples include **bug** if this fixes a problem or **enhancement** if it adds a new feature.