.. _gitflowapp-top:

Git flow (Application)
======================

As described :doc:`elsewhere <../practices/gitflow>` git flow is both a paradigm and an application.  Here we describe the application.

The `git flow primer <http://nvie.com/posts/a-successful-git-branching-model>`_ describes
how to use native git commands to implement the flow.
Since the writing of the primer, several modules have been created that provide git
extensions that bundle native git commands into much simpler commands for each of the
steps in git flow.

The cheat sheet below includes instructions on how to install :code:`git-flow` as an extension to :code:`git`, as well as tips on how to use it.

    `Click here for a git flow cheat sheet <https://danielkummer.github.io/git-flow-cheatsheet/>`_

The primer and cheat sheet both assume that you have permission to push commits
into the develop branches of the remote GitHub repository.  In JEDI we do not follow this approach; all changes to the :code:`develop` and :code:`master` branches of a repository must only be done through :doc:`GitHub pull requests <../practices/pullrequest>`.

Installing git flow
-------------------

This only needs to be done once on each machine.
Following the instructions on the cheat sheet for the Mac:

.. code:: bash

  brew install git-flow-avh

Initializing your local repository
----------------------------------

These steps only need to be done once when you start a local repository.

.. code:: bash

  git clone <path_to_remote_repository>        # create local repository

  git checkout --track develop                 # checkout and track develop branch

  git flow init -d                             # initializes git flow with default values

It is possible to initialize git flow with different values but using all default values is required for JEDI.

.. _gitflow-branches:

Working with git-flow branches
------------------------------

Implementing a planned change is called "adding a feature" in the git flow terminology.
This is a common operating mode and would include improvements, new features,
and non-emergency defect repair.

For instructions on how to create a feature branch, make changes, and merge them back into the develop branch see :ref:`Life Cycle of a Feature Branch <gitflow-lifecycle>`.

Feature branches are intended for exactly that - new features or enhancements of existing code.  If instead you want to fix a known bug in some branch of the repository, you should create a :code:`bugfix` or :code:`hotfix` branch.

The difference between bugfix and hotfix has to do with where they fit into the :ref:`git flow workflow <gitflow-top>`.  These branches are created and finalized :ref:`just like feature branches <gitflow-lifecycle>`:

.. code:: bash

   git flow bugfix start wrongoutput # branches off of develop

.. code:: bash

   git flow hotfix start wrongoutput # branches off of master

The default base for a bugfix branch is develop but you can also fix a bug in a feature branch as follows.

.. code:: bash

   git flow bugfix start wrongoutput feature/myfeature # branches off of myfeature


Bugfix and hotfix branches can be published and finalized :ref:`as described elsewhere for feature branches <gitflow-lifecycle>`, for example:

.. code:: bash

   git flow bugfix publish wrongoutput

Once your branch is on GitHub, you can issue a pull request to merge it in to the relevant branch (master, develop, or feature).  Our standard workflow is to delete the bugfix or hotfix branch on GitHub after it has been merged by an appropriate JEDI master.

Once it is successfully integrated into the desired branch, you may wish to delete your local branch manually using the standard git command:

.. code:: bash

   git branch -d bugfix/wrongoutput

And/or, you can run this command periodically which will remove (:code:`-p` is for *prune*) any of your local branches that no longer exist on GitHub:

.. code:: bash

   git remote update -p
