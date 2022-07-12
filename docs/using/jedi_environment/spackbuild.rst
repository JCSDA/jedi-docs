.. _spack-stack-modules:

Building spack-stack modules for JEDI
=====================================

The instructions in this section are specific to building spack-stack environments to support the
JEDI applications (SkyLab v1.0 release).
For general information on using spack-stack to build and run software,
see the `spack-stack documentation <https://spack-stack.readthedocs.io/en/spack-stack-1.0.1>`_.

spack-stack requires a basic Python version 3.6-3.9 (tested: 3.8 and 3.9) that has nothing but the "poetry" build tool installed.
On your Macbook, if your Python installation has lots of packages installed that are available by default
(e.g. because you installed Python with homebrew and additional packages with homebrew or manually inside the homebrew environment),
you may run into trouble. Before making any changes to the homebrew environment or otherwise modifying ``/usr/local``,
make sure to take a backup of that directory so that you can put it back if needed. Same goes for Linux.

.. note:: See https://spack-stack.readthedocs.io/en/spack-stack-1.0.1/index.html for general information on how to
    build your own spack stack on your platform. Make sure you have read through the documentation before attempting to
    build your own stack. The commands below only highlight the differences to the general documentation, steps in between
    that are not written down here are identical.

Supported in this release are macOS with ``clang`` (``ewok`` graphics dependencies don’t build with ``gcc``),
Red Hat with ``gcc``, Ubuntu with ``gcc``.

Check out the code:

.. code-block:: bash

   git clone -b spack-stack-1.0.1 --recursive https://github.com/noaa-emc/spack-stack spack-stack-1.0.1

Use the following command to build everything needed for ``skylab-1.0`` (including versions
of ``solo``, ``r2d2``, ``ewok`` that can be loaded if users do not want to build them):

.. code-block:: bash

   spack stack create env --site=linux.default --template=skylab-1.0.0-public --name=skylab-1.0.0

Replace ``linux.default`` with ``macos.default`` as required for your system.
JCSDA core and in-kind can choose to install from template ``skylab-1.0.0`` instead
of ``skylab-1.0.0-public``, which installs a few packages that we are not allowed to distribute to the public.

In the :doc:`next section <modules>` we describe in details how to use spack-stack modules to build and
run JEDI on different platforms.
