.. _spack-stack-modules:

Building spack-stack modules for JEDI
=====================================

The instructions in this section are specific to building spack-stack environments to support the JEDI applications (SkyLab v3.0 release). For general information on using spack-stack to build and run software, see the `spack-stack documentation <https://spack-stack.readthedocs.io/en/1.3.0>`_.

spack-stack currently requires a basic Python version 3.8-3.10 that has nothing but the "poetry" build tool installed. On your Macbook, if your Python installation has lots of packages installed that are available by default (e.g. because you installed Python with homebrew and additional packages with homebrew or manually inside the homebrew environment), you may run into trouble. Before making any changes to the homebrew environment or otherwise modifying ``/usr/local``, make sure to take a backup of that directory so that you can put it back if needed. The same goes for Linux.

.. note:: See https://spack-stack.readthedocs.io/en/1.3.0/index.html for general information on how to build your own spack stack on your platform. Make sure you have read through the documentation before attempting to build your own stack. The commands below only highlight the differences to the general documentation, steps in between that are not written down here are identical.

Supported in this release are macOS with ``clang`` (``ewok`` graphics dependencies don’t build with ``gcc``), Red Hat with ``gcc``, Ubuntu with ``gcc``.

Before building the spack-stack modules on macOS, you must first install homebrew and update the local path to your homebrew installation. See https://brew.sh/ and https://spack-stack.readthedocs.io/en/latest/NewSiteConfigs.html#homebrew-notes for more specific information on this task. It is recommended to start with a fresh homebrew installation before setting up the spack-stack prerequisites. See https://docs.brew.sh/FAQ#how-do-i-uninstall-homebrew for information on how to uninstall homebrew from your current environment.

Install the prerequisites:

Go to https://spack-stack.readthedocs.io/en/latest/NewSiteConfigs.html#prerequisites-one-off for instructions.

Check out the code:

.. code-block:: bash

   git clone -b 1.3.0 --recursive https://github.com/noaa-emc/spack-stack spack-stack-1.3.0

Go into the ``spack-stack-1.3.0`` directory and source the spack-stack ``setup.sh`` script:

.. code-block:: bash

   cd spack-stack-1.3.0
   source setup.sh

Use the following command to create the spack-stack environment for ``skylab-4.0``:

.. code-block:: bash

   spack stack create env --site=linux.default --template=skylab-dev --name=skylab-4.0.0

Replace ``linux.default`` with ``macos.default`` as required for your system.

Activate the ``skylab-4.0`` spack-stack environment:

.. code-block:: bash

   spack env activate [-p] envs/skylab-4.0.0

Export ``SPACK_SYSTEM_CONFIG_PATH``:

.. code-block:: bash

   export SPACK_SYSTEM_CONFIG_PATH="$PWD/envs/skylab-4.0.0/site"

Build the ``skylab-4.0`` spack-stack environment:

Go to https://spack-stack.readthedocs.io/en/latest/Platforms.html#creating-a-new-environment for instructions starting with Step 3.

In the :doc:`next section <modules>` we describe in details how to use spack-stack modules to build and run JEDI on different platforms.
