######################
Creating documentation
######################

For writing guides and manuals, we are using
`Sphinx <http://www.sphinx-doc.org/en/master/index.html>`_ which is a Python package.

    `Click here for tips on getting started with Sphinx <../inside/developer_tools/getting-started-with-sphinx.html>`_

`Doxygen <http://www.stack.nl/~dimitri/doxygen/>`_ will be used for automatically
generating documentation describing our code, such as inheritance diagrams, man
pages and call trees.

We have created a GitHub repository for holding documentation called :code:JCSDA/jedi-docs.
Please place your documentation in this repository and place the appropriate links and text
to your documentation in the top level index.html file.

To add your documentation to the :code:`jedi-docs` repository you need to follow
the `Git flow paradigm <../inside/practices/gitflow.html>`_.

First let's make sure you have the latest version of the code. To pull the
latest version of the develop branch run:

.. code-block:: bash

   git checkout develop  # checkout develop branch
   git pull              # get the latest develop branch


create a new :code:`feature` branch in the :code:`jedi-docs` repository
and check it out by running:

.. code-block:: bash

   git checkout -b feature/my-branch

You can check which branch you are currently on by running:

.. code-block:: bash

   git branch

After creating and checking out your feature branch you can edit (or add new) files
in the :code:`jedi-docs` repository. To edit the current documentations you can
edit :code:`.rst` files. If you want to add a new section to the documentation you
need to create a new :code:`.rst` file and also register the new file
in :code:`index.rst` in your working directory.

You can push your changes back to the repository
using :code:`git add`, :code:`git commit`, and :code:`git push` commands
as described `here <../inside/practices/gitflow.html#life-cycle-of-a-feature-branch>`_.

.. note::

   If you use `git flow`, you may need to initialize git flow for the repository by running :code:`git flow init -d`
