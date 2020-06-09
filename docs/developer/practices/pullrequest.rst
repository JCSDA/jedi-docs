.. _pullrequest-top:

TRIPLE the impact of your GitHub Pull Requests
==============================================

According to the :doc:`Git flow paradigm <gitflow>` followed by JEDI, all changes to the develop branch must meet the following conditions:

* They must pass all tests
* They must be reviewed by other developers

These requirements are achieved by means of Pull Requests on Github.

When your feature or bugfix branch is ready to be merged into develop, the first thing for you to do is to push it to GitHub by issuing a :code:`git push` command.

Then, from the GitHub web console, you can navigate to the repository in question and select your feature branch from the drop-down menu.  Near the branch name you should see a button called **New Pull Request**.  Select this to begin the process of merging your branch into develop.

.. hint ::

   If you want to see the changes you are proposing before issuing the pull request, look for the **Compare** button on the right of the web console, just below the green **Clone or download** button.

The action of creating a pull request will trigger a number of automated tests.  These will compile and run the code with different compilers and MPI libraries and it will check to see that the code you have added is actually executed by the tests (code coverage).  Your branch will not be merged until it passes all of these tests.  So, if you see any test failures, you should work to understand and fix them.

The title of this section refers to **TRIPLE**, which is actually a mnemonic analogous to the :ref:`PLEATED mnemonic described in the context of issues <pleated>`:

  * **T**: Title/Description
  * **R**: Reviewers
  * **I**: Issue
  * **P**: Pipeline
  * **L**: Label
  * **E**: Epic

All the items in the mnemonic refer to metadata that can be specified through the window that appears when you create a pull request:

.. image:: images/PullRequest.png

We'll start with the first item in the TRIPLE mnemonic: **T** for Title (and description).  Give your pull request an appropriate title and a description that is thorough enough to give reviewers a good idea for **what** has been changed and **why**.  In other words, an overview of the changes that have been made and the motivation behind them.

The **R** in TRIPLE stands for **Reviewers**.  Though any JEDI team member can review your pull request, some may not be aware of it.  If you explicitly ask someone to review it, they will get an email notification and they are more likely to review it in a timely manner.  **All pull requests require at least two approvals from reviewers before they can be merged**.

Reviewers may offer comments or questions on specific lines of code or in the general discussion thread in of the GitHub Pull Request console.  It is **your responsibility** to respond to these comments and questions and, if applicable, make appropriate changes in the code.

Each pull requests *does* something - for example, it may fix a bug or implement a new feature.  Thus, most pull requests do not appear spontaneously.  Rather, they reflect code changes that were implemented to address some previously idenfied :doc:`Issue <issues>`.

If that is the case, then there is an button below the description box that lets you **Connect this pull request with an existing issue**.  This is what the **I** in TRIPLE refers to.

Another way to connect a previously-existing issue to a pull request is to reference the issue in the pull request description and/or one of the commit messages together with a GitHub-recognized keyword such as **closes** or **fixes**.  References are made through the :code:`#` character followed by the number of the pull request.  For example, if you include the text :code:`closes #32` in your pull request description, then it this will connect issue number 32 in the current repository with the pull request.  And, when the pull request is merged, it will close the issue.  This can be extended to more than one issue, for example: :code:`closes #32, fixes #38`.  For further information, see GitHub's documentation on `Linking a pull request to an issue <https://help.github.com/en/github/managing-your-work-on-github/linking-a-pull-request-to-an-issue>`_.

Occasionally you may generate a pull request that does not address a pre-existing issue.  This is particularly common for small tasks like fixing a bug that might have arisen spontaneously and that may be fixed on the spot without taking the time to create a separate issue.  If this is the case, then you should replace the **I** with **E** - give the task an **Estimate** that reflects the amount of effort, as described in our document on :doc:`creating issues <issues>`.

Just be sure not to double-count; the total amount of effort should be reflected by the sum of the estimates in the issue (if applicable) and the pull request that addresses it.

The remaining items in TRIPLE remind you to assign this pull request a **Pipeline**, a **Label**, and an **Epic**, :doc:`as described in the context of Issue creation <issues>`.

The Epic and the initial label(s) should generally be the same as the corresponding items in the issue that the pull request is connected to.  However, as the code review procees proceeds, more labels may be added that reflect the state of the pull request.  For example: **changes requested** or **Waiting for other repos**.

The Pipeline for pull requests should generally be set to **Review/QA**.
