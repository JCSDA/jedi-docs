.. _gitflow-top:     

Git flow
=============================

The `git flow primer <http://nvie.com/posts/a-successful-git-branching-model>`_ describes
how to use native git commands to implement the flow.
Since the writing of the primer, several modules have been created that provide git
extensions that bundle native git commands into much simpler commands for each of the 
steps in git flow.

The cheat sheet below includes instructions on how to install git flow, as well as how
to use git flow.

    `Click here for a git flow cheat sheet <https://danielkummer.github.io/git-flow-cheatsheet/>`_

The primer and cheat sheet both assume that you have permission to push commits
into the develop branches of the remote GitHub repository.
The typical case will be that in which the developer does not have such push permission, and
instead must issue pull requests to get their code merged into the develop branch.
The following steps are included to describe how to use git flow when you will be issuing
pull requests (instead of directly pushing commits into the GitHub develop branch).

Installing git flow
-------------------

This only needs to be done once on each machine.
Following the instructions on the cheat sheet for the Mac:

.. code:: bash

  brew install git-flow-avh

Initializing your local repository
----------------------------------

These steps only need to be done once when you start a local repository.
Answer the questions from "git flow init" as shown below.

.. code:: bash

  git clone <path_to_remote_repository>                      # create local repository
  
  git flow init                                              # set up for git flow
    > Branch name for production releases: [master]          # hit return for default value
    > Branch name for "next release" development: [develop]  #  which is shown in square braces
    > How to name your supporting branch prefixes?
    > Feature branches? [feature/]
    > Bugfix branches? [bugfix/]
    > Release branches? [release/]
    > Hotfix branches? [hotfix/]
    > Support branches? [support/]
    > Version tag prefix? []
    > Hooks and filters directory? [<path_to_local_repo>/.git/hooks]

You may have noticed that accepting all default values is recommended, and git flow init
provides an option (-d) to do just that.

.. code:: bash

  git flow init -d   # Automatically accept all default values
  
  # Check what the above command put in for default values. Sometimes, the default
  # values don't match what's shown above, and you want to end up with the values
  # shown above. If the values don't match, you can force the initialization to be
  # re-run using the -f option.

  git flow init -f   # Force initialize when 'git flow init' has already been run.

  
.. _gitflow-feature:     

  
Adding a feature
----------------

Implementing a planned change is called "adding a feature" in the git flow terminology.
This is a common operating mode and would include improvements, new features,
and non-emergency defect repair.

The idea is to repeat the following sequence for each feature:
  #. Make the change in your local repository in a new "feature" branch.
  #. Push the new feature branch to the remote GitHub repository.
  #. Issue a pull request on GitHub to merge the new feature branch into the develop branch in the remote repository.
      The owner of the GitHub repository will review and merge in your new feature branch
  #. After your new feature branch is merged in, sync up with the remote GitHub repository.

In git flow, the "feature" command is used to assist with this process.
Let's say you want to call your new feature "perf-enhance" since you are working on
performance enhancements.

.. code:: bash

  git flow feature start perf-enhance  # a new branch called feature/perf-enhance
                                       # is created and checked out
  
  # make edits, test code, etc.

  git flow feature publish perf-enhance   # this pushes your new branch
                                          # onto the GitHub remote repo

On git hub switch to your new branch feature/perf-enhance, and issue a pull request by hitting
the "pull request" button.
When the pull request screen comes up, make sure that you have your "feature/perf-enhance"
branch designated as the "compare" branch and "develop" designated as the "base" branch.

    `Click here to see details for creating a pull request on GitHub <https://help.github.com/articles/creating-a-pull-request/>`_

The owner of the GitHub repository will work with you to review and make any adjustments
necessary as part of the process of accepting your changes.
Once approved, the owner will merge in your "feature/perf-enhance" branch into the
"develop" branch in the GitHub repository.
Note that since "feature/perf-enhance" on the remote repository is no longer needed
(it has been merged into the "develop" branch), it will be deleted in the remote
repository (but not in you local repository).

Once the merge on the remote GitHub repository has occurred, you need to get your local
repository back in sync with the remote repository.
This can be done by running the following:

.. code:: bash

  git remote udpate -p   # This syncronizes the metadata describing the changes that have
                         # been done on the remote repository. The -p option "prunes" branches
                         # that have been deleted on the remote repository which will include
                         # your "feature/perf-enhance" branch.

  git checkout develop   # Switch to the develop branch in the local repository

  git pull origin develop  # Sync up the local repository with changes in the remote
                           # repository (which will include your feature/perf-enhance changes).

  git branch -d feature/perf-enhance  # Remove feature/perf-enhance branch from your
                                      # local repository. Don't need the feature/perf-enhance
                                      # branch anymore since those changes are included in
                                      # the develop branch.


Staying in sync with the remote GitHub repository
-------------------------------------------------

All of the work to add in new features is done on the develop branch in the git flow
methodology.
Since there will be multiple people contributing to the develop branch, it is a good idea
to sync up often to the develop branch (of the remote GitHub repository).
A reason for doing this is to make sure that changes other people make are compatible with
the code you are developing (and vice versa).
One way to get into the habit is to sync up every morning before getting started on your
work.

Let's say you are midway through the work on your feature/perf-enhance branch and you decide
it's a good time to sync up with the GitHub develop branch.

.. code:: bash

  git checkout develop                 # Switch to the develop branch
                                       # in your local repository.

  git pull origin develop              # Bring in the changes, if any, from the
                                       # remote GitHub repository.

  git checkout feature/perf-enhance    # Go back to the local feature/perf-enhance branch.

  git merge develop                    # Merge in the changes that were just
                                       # pulled into the local develop branch.
                                       # Note that this command is not necessary
                                       # if the pull command above did not modify
                                       # the develop branch.


bugfix and hotfix branches
--------------------------

Feature branches are intended for exactly that - new features or enhancements of existing code.  If instead you want to fix a known bug in some branch of the repository, you should create a :code:`bugfix` or :code:`hotfix` branch.

The difference between bugfix and hotfix has to do with where they fit into the :ref:`git flow workflow <gitflow-top>`:

* **bugfix**: branches off of the :code:`develop` branch or a specified :code:`feature` branch
* **hotfix**: branches off of the :code:`master` branch

These branches are created and finalized :ref:`as described above <gitflow-feature>` for feature branches, e.g.:

.. code:: bash

   git flow bugfix start wrongoutput # branches off of develop

.. code:: bash

   git flow hotfix start wrongoutput # branches off of master
   
The default base for a bugfix branch is develop but you can also fix a bug in a feature branch as follows.  

.. code:: bash

   git flow bugfix start wrongoutput feature/myfeature # branches off of myfeature
   

Bugfix and hotfix branches can be published and finalized :ref:`as described above <gitflow-feature>` for feature branches, for example:

.. code:: bash

   git flow bugfix publish wrongoutput
   
Once your branch is on GitHub, you can issue a pull request to merge it in to the relevant branch (master, develop, or feature).  Once it is sucessfully integrated into the desired branch, you may wish to delete your local branch using the standard git command:

.. code:: bash

   git branch -d bugfix/wrongoutput

   
