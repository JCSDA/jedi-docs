Sphinx
======

Sphinx is a Python package that can be used to create documentation in various formats that
include HTML, LaTex and man pages.
For input Sphinx uses reStructuredText which is a variety of markdown language.
Markdown is a simple, easy to use textual representation of a complex markup language such
as HTML.

    `Click here for details on Sphinx <http://www.sphinx-doc.org/en/master/index.html>`_

Installing Sphinx
-----------------

This step only needs to be done once for each repository when starting sphinx.
Note that the JCSDA/jedi-docs repository has already had this step run.

Assuming that you have Python installed, do the following to install Sphinx:

.. code-block:: bash

  pip  install -U sphinx  # for Python 2
  pip3 install -U sphinx  # for Python 3


Initial Configuration for Using Sphinx
--------------------------------------

To set up for using sphinx in a repository:

.. code-block:: bash

  cd my-repo
  mkdir docs   # using the name "docs" will allow ReadTheDocs to find and process your files
  cd docs
  sphinx-quickstart       # Answer queries as shown below
    > Separate source and build directories (y/n) [n]:        # hit return for default which
    > Name prefix for templates and static dir [_]:           # is shown in square brackets
    > Project name: MyProject
    > Author name(s): Your Name                               # spaces are okay
    > Project release []: 1.0.0                               # software version number
    > Project language [en]:                                  # hit return for default (English)
    > Source file suffix [.rst]:
    > Name of your master document (without suffix) [index]:
    > Do you want to use the epub builder (y/n) [n]:
    > autodoc: automatically insert docstrings from modules (y/n) [n]:
    > doctest: automatically test code snippets in doctest blocks (y/n) [n]:
    > intersphinx: link between Sphinx documentation of different projects (y/n) [n]:
    > todo: write "todo" entries that can be shown or hidden on build (y/n) [n]:
    > coverage: checks for documentation coverage (y/n) [n]:
    > imgmath: include math, rendered as PNG or SVG images (y/n) [n]:
    > mathjax: include math, rendered in the browser by MathJax (y/n) [n]:
    > ifconfig: conditional inclusion of content based on config values (y/n) [n]:
    > viewcode: include links to the source code of documented Python objects (y/n) [n]:
    > githubpages: create .nojekyll file to publish the document on GitHub pages (y/n) [n]: y
    > Create Makefile? (y/n) [y]:
    > Create Windows command file? (y/n) [y]: n

This creates a configuration file (conf.py, which can be subsequently edited), a Makefile for
creating you document in different formats (e.g., HTML) and an initial index.rst file.
Also, directories are created for holding the output of make (_build), custom HTML templates
(_templates) and custom stylesheets (_static).

Sphinx has different "themes" which set the style of your html pages.
ReadTheDocs can pick up on these themes and if the theme is called "default", then
ReadTheDocs will substitute its own page style.
However, sphinx-quickstart writes the conf.py file with a theme called "alabaster".
To change the theme to default (which looks nice in both Sphinx and ReadTheDocs), do
the following:

.. code-block:: bash

  vi conf.py  # substitute your favorite editor
    # find the line: html_theme = 'alabaster'
    # change 'alabaster' to 'default'

Writing Your Document
---------------------

Take a look in the index.rst file that was created by sphinx-quickstart.
It has a table of contents, specified by the "toctree" directive.
Whenever you add another .rst file, place a reference to that file in the table of contents.
Note that the string you entered for your project's name appears in several places in the
index.rst file.
At the bottom, note the creation of an index ("genindex" directive).
Entries in the index are created wherever you place an "index" directive in the text of your
.rst files.

reStructuredText is easy to use, yet it has an extensive set of features.
Probably the best way to get going is to look up examples on the web.
Also, the sphinx website has a great primer for reStructuredText which can be viewed by
clicking the link below.

    `Details on reStructuredText <http://www.sphinx-doc.org/en/master/rest.html>`_

Once you are ready to build your documentation, run:

.. code-block:: bash

  cd my-repo/docs  # the directory you were in when you ran sphinx-quickstart
  make html        # create web pages
  make latex       # create a LaTex manual
  make latexpdf    # create pdf from the LaTex files
  make man         # create man pages

After running make, the output will appear in the _build directory in a subdirectory
corresponding to the output format you selected (e.g., _build/html for the output of
``make html``).

HTML pages can be viewed using the URL file form.
If you built your HTML in the directory

    /users/me/my-repo/docs/_build/html

then use the following URL to view your pages

    \file:://users/me/my-repo/docs/_build/html/index.html



More Help with Getting Started
------------------------------

See the following link for more details on building documents with sphinx:

    `Details on document building <http://www.sphinx-doc.org/en/master/usage/quickstart.html>`_
