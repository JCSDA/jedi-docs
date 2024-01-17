.. _spack-stack-modules:

Building spack-stack modules for JEDI
=====================================

The instructions in this section are specific to building spack-stack environments to support the JEDI applications
({skylab_v} release). For general information on using spack-stack to build and run software, see the
`spack-stack documentation <https://spack-stack.readthedocs.io/en/1.5.1/>`_. Make sure you have read through
the documentation before attempting to build your own stack. The commands below only highlight the differences
to the general documentation, steps in between that are not written down here are identical.

Supported in this release are macOS with ``clang`` (``ewok`` graphics dependencies don’t build with ``gcc``), Red Hat with
``gcc``, Ubuntu with ``gcc``, Ubuntu with ``intel``.

Before building the spack-stack modules on macOS, you must first install homebrew and update the local path to your
homebrew installation. See https://brew.sh/ and https://spack-stack.readthedocs.io/en/1.5.1/NewSiteConfigs.html#homebrew-notes
for more specific information on this task. It is recommended to start with a fresh homebrew installation before setting up
the spack-stack prerequisites. See https://docs.brew.sh/FAQ#how-do-i-uninstall-homebrew for information on how to uninstall
homebrew from your current environment.

Install the prerequisites:

For macOS, follow the instructions `in the spack-stack docs <https://spack-stack.readthedocs.io/en/1.5.1/NewSiteConfigs.html>`_.
Be sure to start at the top of the page and read the notes about the macOS and Intel Arm platform particularly if your machine
has a newer M1 or M2 chip.

Later in the same document you can find prerequisite install instructions for `Red Hat <https://spack-stack.readthedocs.io/en/1.5.1/NewSiteConfigs.html##prerequisites-red-hat-centos-8-one-off>`_.

Check out the code:

.. code-block:: bash

   git clone -b 1.5.1 --recursive https://github.com/JCSDA/spack-stack spack-stack-1.5.1

Go into the ``spack-stack-1.5.1`` directory and source the spack-stack ``setup.sh`` script:

.. code-block:: bash

   cd spack-stack-1.5.1
   source setup.sh

Use the following command to create the spack-stack environment for ``{skylab_version}``:

.. code-block:: bash

   spack stack create env --site=linux.default --template=skylab-dev --name={skylab_version}

Replace ``linux.default`` with ``macos.default`` as required for your system.

Activate the ``{skylab_version}`` spack-stack environment:

.. code-block:: bash

   spack env activate [-p] envs/{skylab_version}

Export ``SPACK_SYSTEM_CONFIG_PATH``:

.. code-block:: bash

   export SPACK_SYSTEM_CONFIG_PATH="$PWD/envs/{skylab_version}/site"

Build the ``{skylab_version}`` spack-stack environment:

Go to https://spack-stack.readthedocs.io/en/latest/NewSiteConfigs.html#creating-a-new-environment for instructions starting with Step 3.

In the :doc:`next section <modules>` we describe in details how to use spack-stack modules to build and run JEDI on different platforms.
