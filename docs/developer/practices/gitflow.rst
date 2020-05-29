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
