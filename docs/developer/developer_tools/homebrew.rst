Homebrew (Mac only)
===================

If you use have an Apple computer running Mac OS X we highly recommend that you install
`Homebrew <https://brew.sh/>`_.  This will make it much easier to install a number of other
software tools that are indispensable for JEDI developers, including vagrant, git-flow, doxygen,
and many more.

To install Homebrew, copy and paste this into the command line of a bash shell:

.. code-block:: bash

  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

The installation of some JEDI tools such as Vagrant require new Homebrew features such as cask.  To make sure you are using the latest version of Homebrew, type:

.. code-block:: bash

  brew update

This updates the Homebrew application itself.  To update all the packages that have been installed by Homebrew, type:

.. code-block:: bash

  brew upgrade

