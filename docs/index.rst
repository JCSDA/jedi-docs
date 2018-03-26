.. JEDI Documentation documentation master file, created by
   sphinx-quickstart on Tue Mar  6 11:51:45 2018.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

JEDI Documentation
==================

Welcome to JEDI!

This documentation will help you get started with JEDI whether you are a user or a developer.

Table of Contents
-----------------

.. toctree::
   :maxdepth: 2
   
   developer/methodology/getting-started-with-gitflow
   developer/methodology/getting-started-with-sphinx


Developers
==========

If you are contributing to JEDI, take a look here for help.

Methodology
-----------

A certain amount of consistency is required on the part of the developers so that we can
maintain effecient software development.
Therefore, we have adopted several methodologies that we expect everyone to use.

Code Development
^^^^^^^^^^^^^^^^

We are using `GitHub <https://github.com/>`_ for storage of our code, and the git flow
methodology for developing that code.

    `Click here for an excellent primer on git flow <http://nvie.com/posts/a-successful-git-branching-model/>`_

    `Click here for tips on getting started with git flow <developer/methodology/getting-started-with-gitflow.html>`_

Documentation
^^^^^^^^^^^^^

For writing guides and manuals, we are using 
`Sphinx <http://www.sphinx-doc.org/en/master/index.html>`_ which is a Python package.

    `Click here for tips on getting started with Sphinx <developer/methodology/getting-started-with-sphinx.html>`_

`Doxygen <http://www.stack.nl/~dimitri/doxygen/>`_ will be used for automatically
generating documentation describing our code, such as inheritance diagrams, man
pages and call trees.

We have created a GitHub repository for holding documentation called JCSDA/jedi-docs.
Please place your documentation in this repository and place the appropriate links and text
to your documentation in the top level index.html file.

Indices and tables
==================

* :ref:`genindex`
* :ref:`search`
