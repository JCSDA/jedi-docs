.. _gitflow-top:

Follow the Git flow Paradigm
============================

The term **git flow** refers to several distinct but related concepts.

Most importantly, it refers to a strategy or paradigm for managing code branches in a way that best promotes both innovation and continuous delivery of functional software.  These are both core principles in agile software development with proven results.

Git flow may also refer to an application; an extension to the git command line tool that helps developers to follow the git flow paradigm.  The git-flow application and its use is :doc:`described in a separate document <../developer_tools/getting-started-with-gitflow>`.

JEDI developers are not required to use the git-flow application.  However, all JEDI developers **are** expected to comply with the git-flow paradigm as described below.

The git flow paradigm was introduced in 2010 in a `brief but compelling blog post by the software engineer and project manager Vincent Driessen <http://nvie.com/posts/a-successful-git-branching-model>`_.  **We strongly recommend that all JEDI developers take a few moments to read this article.**

Furthermore, we recommend that all JEDI developers keep `the git flow diagram <https://nvie.com/files/Git-branching-model.pdf>`_ handy as a (virtual) desktop reference.

In the git flow model, the code is organized into the following branches that are maintained using the `git version control system <https://git-scm.com/>`_:

- :code:`master` branch
   - One permanent master branch that is used for releases only
   - Must pass all tests at all times
   - Direct code changes (commits and pushes) not allowed: all changes are made through GitHub pull requests and subject to code reviews
   - All changes are tagged with a release number
- :code:`develop` branch
   - One permanent develop branch that is used for development
   - Must pass all tests at all times
   - Direct code changes (commits and pushes) not allowed: all changes are made through GitHub pull requests and subject to code reviews
- :code:`feature/*` branches
   - multiple branches implementing specific code changes
   - where most development work happens
   - Branch off of develop
   - Merge back into develop
   - Temporary: deleted after they are merged
- :code:`bugfix/*` branches
   - For correcting errors or omissions
   - Branch off of develop
   - Merge back into develop
   - Temporary: deleted after they are merged
- :code:`hotfix/*` branches
   - For correcting errors or omissions
   - Branch off of master
   - Merge back into master and develop
   - Temporary: deleted after they are merged
- :code:`release/*` branches
   - For refinement, bug fixes, and documentation leading up to a release
   - Branch off of develop
   - Merge into master and develop
   - Temporary: deleted after they are merged

One of the most important principles of agile software development is to:

   **Keep your feature branches as small and focused as possible**

Ideally, feature branches should exist for no more than a week or two.  You should break large changes into small parts that can be implemented sequentially, tested, and readily reviewed by your peers.  Then, after those changes are reviewed and merged, you can proceed to the next stage of changes.

Large feature branches that exist for weeks and change dozens of files become too cumbersome to review and will likely diverge from the develop branch, leading to multiple conflicts when it finally comes time to merge.

Life Cycle of a Feature Branch
------------------------------

Under the git flow paradigm, and using the git flow application, the typical life cycle of a feature branch is as described below.  If you do not wish to use the git flow application, you can achieve the same steps just with standard :code:`git`.  For example, :code:`git flow feature start newstuff` is equivalent to:

.. code::

   git checkout develop
   git branch feature/newstuff
   git checkout feature/newstuff

.. note::

   If you haven't previously, you may need to initialize git flow for the repository by running :code:`git flow init`

Step 1: Start the feature branch
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code:: bash

   git flow feature start newstuff

This creates a new branch called feature/newstuff that branches off of develop.  Then you can edit files and commit them as you would with any other :code:`git` repository:

.. code:: bash

   git add *
   git commit

Step 2. Push your branch to GitHub for the first time
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

After making one or more commits, you can push your branch to GitHub as follows:

.. code:: bash

   git flow feature publish newstuff

Now there is a copy of your branch on the web, within GitHub, in addition to the copy on your computer.

Step 3. Additional commits and pushes as needed
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Now typically you will make multiple commits as you add a feature and repeatedly :doc:`recompile the code and test your changes <../building_and_testing/building_jedi>`.  Don't forget to :doc:`add a test <../building_and_testing/adding_a_test>` that specifically checks the code you have added.

.. code:: bash

   git commit -a
   git push

Each time you do a :code:`git push`, this will transfer your changes from your computer to the copy of your branch that exists on GitHub.

If someone else is working on the same branch, you can do a :code:`git pull` to retrieve the latest code from GitHub and merge it with the version that is on your computer.  Note that this may occasionally lead to code conflicts that must be resolved.  See the `GitHub Guides <https://guides.github.com/>`_ for tutorials and examples on how to work with git and GitHub.

Step 4: Keep your branch up to date with develop
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Step 4 does not really come after Step 3 - it should accompany it - they should be executed together.

As you make changes to the code, you don't want you feature branch to diverge too much from the develop branch.  If it does, then when you try to merge it you may find many conflicts.  Furthermore, as noted above, feature branches with multiple changes are difficult to review by your peers.  You want to make it easier on them by making sure that the changes you intend to merge into develop are only the changes you've added, not previous code that is left over from past versions of develop.

So, every day or two, you should execute these commands to merge in the latest changes from the develop branch on GitHub:

.. code ::

   git checkout develop
   git pull
   git checkout feature/newstuff
   git merge develop

Step 5: Finish the feature branch with a GitHub Pull Request
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

When your feature branch is finished, it should be merged into the :code:`develop` branch.  *Finished* means that the feature is implemented, the code compiles and all tests pass.

Though the git flow application has a :code:`finish` function to do this, you should not use it.  Instead, as noted :ref:`above <gitflow-top>`, all changes to the develop branch must be reviewed by other developers through GitHub pull requests.

For tips on properly issuing a GitHub pull request, :doc:`see the next item in our list of Best Practices for Developers <pullrequest>`.

After your feature branch is triumphantly merged into develop, the remote branch (on GithHub) will be deleted.  But, it will still exist on your computer.  To bring your computer up to date, you can issue the following commands:

.. code:: bash

   git remote update -p
   git branch -D feature/newstuff
