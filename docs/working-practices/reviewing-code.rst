.. _reviewing-code-top:

##############
Reviewing Code
##############

The role of the review process is to control the contents of branches, especially the develop and main branches of a repository. Discussions and decisions of a scientific nature should happen at the ZenHub level, before reaching the level of pull requests (PRs) and code reviews.

What is a Code Review?
^^^^^^^^^^^^^^^^^^^^^^

A **Code Review** is the systematic examination of software source code, intended to find potential bugs, examine logic, and improve code base health. A code review occurs as part of a  **Pull Request (PR)** submission.

Creating a Good Pull Request
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

A Pull Request (PR) is a public record of what change is being made and why it was made. It becomes a permanent part of a repository's version control history. 

It is often in the best interests of both developers and reviewers to review and merge code often in small incremental changes rather than massive changes at one time. This exposes code earlier to other developers who could be impacted and facilitates the merging process. This is often done by `creating a draft PR <https://github.blog/2019-02-14-introducing-draft-pull-requests/>`_.

Once a PR is ready for submission and review,  JEDI developers follow `this process to create and submit a PR <https://jointcenterforsatellitedataassimilation-jedi-docs.readthedocs-hosted.com/en/latest/developer/practices/pullrequest.html>`_, and the **code review** process begins.

The Standard of Code Review
^^^^^^^^^^^^^^^^^^^^^^^^^^^

The review process is an integral part of the development work and should be considered from the beginning. The primary purpose of code review is to make sure that the overall health and quality of a code base is improving over time; that is, code clarity, functionality, efficiency, portability, and extensibility are advanced. This requires trade-offs:

* Developers need to make progress; timely code reviews helps developers.
* Reviewers must make sure that PR are of such a quality that overall code base health increases; they must also own and be responsible for code being reviewed to ensure consistency and maintainability.

The **Expected Standard** of a code review is to favor approval of a PR when it definitely improves overall code health, even if it’s not perfect. There isn’t *perfect* code, just *better* code. Reviewers should balance the need to make forward progress compared to the importance of suggested changes -- a reviewer should seek continuous improvement. A PR that improves the functionality, maintainability, readability, and understandability of the system is appropriate for merging into the code base.

Benefits of Code Reviews
^^^^^^^^^^^^^^^^^^^^^^^^^

* **Sharing knowledge / increase knowledge transfer:** Teams are better able to collaborate on software development when more persons are aware of both the "big picture" and smaller details.
* **Improve development process:** Developer and team velocity increases as code reviewers are exposed to product complexity, known issues, and areas of concern in a code base, creating multiple informed contributors.
* **Mentoring of all team members:** Code reviews facilitate conversations about a code base, often leading to hidden knowledge surfacing and ensuring new insights tempered with that knowledge.

As code reviews expose developers to new ideas and technologies, they write better and better code.

Code reviews should integrate with a team’s existing process. For example, if a team is using task branching workflows, initiate a code review after all the code has been written and existing test suites have been manually run and passed, but before the code is merged upstream. This ensures the code reviewer’s time is spent checking for things machines miss, and prevents poor coding decisions from polluting the main line of development.

What to look for in a Code Review
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

* **Design:** Do code interactions make sense? Are there logic errors in the code? Are issue requirements fully implemented? In other words, is the issue's **Defintion of Done** met?
* **Functionality:** Does the PR do what is intended? Are changes good for both end-users and developers?
* **Complexity:** Is the code asily understood by the reviewer?
* **Testing:** Are unit / integration / end-to-end tests appropriate for the PR? Will tests fail when the code is broken? Will the tests generate false positives if underlying code changes? Do existing tests continue to pass as expected?
* **Comments:** Are comments both clear *and* necessary? Comments explain a *why*, not a *what* in the code.
* **Style and consistency:** If a Style Guide is applicable, do code changes adhere to it?
* **Documentation:** If a PR's code changes behavior or instructions, accompanying documentation must be updated to reflect these changes.

How Fast Should Code Reviews Be?
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

**Code Reviews Take Time**...but they can be fast! This apparent dichotomy really isn't such -- optimize for the speed at which a product is created, not for the speed at which individuals write code. In other words, a team's *overall development velocity* is paramount, and timely code reviews aid that process. When code reviews are **not timely**:

* **Team velocity is decreased**. New features and bug fixes are delayed as each PR waits for review.
* **Developers protest the code review process**. Relatively quick reviwer responses are paramount to continue progress. *Most complaints about code review processes are  resolved by making the process faster*.
* **Code health can be impacted**. Slow reviews  discourage code cleanups, refactorings, and further improvements to existing PRs.

**Timely** code reviews can be a balancing act:

* **Speed vs. Interruption:** If you are not in the middle of a focused task, *you should do a code review shortly after it comes in*. If you are in the middle of a focused task, such as writing code, don’t interrupt yourself to do a code review. 
* **Fast Responses:** We are concerned with response time, as opposed to how long it takes a PR to get through the whole review and be merged. The whole process should also be fast, but it’s  more important for individual responses to come quickly than it is for the whole process to happen rapidly. If you're too busy to do a full review on a PR, send a quick response that lets the developer know when you will get to it, suggest other reviewers who might be able to respond more quickly, or provide some initial broad comments.
* **Share the load:** Many teams require two at least reviews of any code before it's checked into the code base. This sounds like a lot of overhead, but it's not. When an author selects reviewers, they cast a wide net across the team. Any two (or more) team members can give input. This decentralizes the process so that no one is a bottleneck, and ensures good coverage for code review across the team.

Comments in a code review
^^^^^^^^^^^^^^^^^^^^^^^^^

Comments in a code review help the developer of the PR further refine and improve their code, and thus the overall health of the project code base. Components of good comments include:

* **Courtesy:** It is important to be courteous and respectful while also being very clear and helpful to the developer whose code you are reviewing.
* **Explanation of reasoning:** Don't simply point out problems, provide explanation around the intent of a comment -- how it improves code health, for example.
* **Appropriate guidance:** Strike a balance between pointing out issues and giving direct instructions; it’s the author's job to fix a PR. Note the things done well, and why (not just the changes you may suggest).

Give and Take in a Code Review
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

There are times when code reviews undergo suggested changes and revisions. What we might consider to be *pushback* is a healthy process in code development. Consider these topics:

* **Who is right?** Developers and reviewers would do well to consider all comments and suggestions – do they make sense? It's incumbent on everyone to provide a good explanation for suggestions and replies. If a suggestion will improve code health, that justifies the additional work requested. *Improving code health tends to happen in small steps*.
* **“Clean it up later”** Developers want to get work done; that is not justification to delay immediately relevant follow-up or follow-on work. As time passes, this work is less likely to get done. *"Cleaning things up later"* is a recipe for codebases to degenerate.
* **Conflicts:** If conflicts arise between developers and reviewers, remember the **Standard of a Code Review**: *Reviewers should favor approving a PR where it improves overall code health of a system, even if it’s not perfect. There is no perfect code, just better code*.

  - technical facts and data overrule opinions and personal preferences
  - a Style Guide (if applicable) is absolute authority
  - software design aspects are not style issues or personal preferences -- they are underlying principles

Good code reviews leverage advantages of the Agile software development methodology: rapid and continuous delivery of useful software leading to customer satisfaction, close cooperation between customers and developers, attention to excellence and design, and adaptability to changing circumstances. This, in turn, leads to increases in team development velocity, creating more team capacity for work and ideally, more product functionality. It also improves a team's estimation and planning capabilities, which again, in turn, helps improve team velocity and capacity.

An important aspect in the multiple level forking model is that code reviews should happen at every level, thus providing several levels of control over correctness and quality of the code. When developers create a PR to another organization’s repository, the code is again reviewed as described above. Another PR  will be issued from the organization to its central repository, triggering another level of review. Depending on the level of the changes, the first or second review may be more or less important -- this is an issue-dependent occurrence. Regardless, discussion and documentation related to the feature will  be visible in both levels.

There is yet another chance to review changes when preparing to release a product. As with any other code branch, a release branch may contain code modifications, and should be reviewed as such. Reviews at every level should be treated seriously.

Modern data assimilation and forecasting systems are very complex. As we enter an era when coupled system  become the norm, complexity increases even more. It is important to recognize this, and recognize that nobody can understand and control the whole system. This is why it is important that code reviews are shared between people with different areas of expertise. It distributes the work and makes the process more efficient.
