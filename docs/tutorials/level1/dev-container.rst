.. _top-tut-dev-container:

Tutorial: Building and Testing FV3 bundle
=========================================

Learning Goals:
 - How to download and run/enter a JEDI development container
 - How to build the JEDI code from source
 - How to run the JEDI unit test suite

Prerequisites:
 - read the :doc:`tutorial overview <../index>`

Overview
--------

In the :doc:`Run JEDI in a Container <run-jedi>` tutorial we used a version of an :doc:`application container <../../developer/jedi_environment/portability>`.  This means that the container includes the compiled source code, ready to use.  The ``jedi-tutorial`` container comes pre-packaged with JEDI!

But that's not the way most JEDI developers, and many users, use JEDI.  Instead, JEDI is set up so that users and developers have easy access to a version of the source code that they can download, build, and even modify themselves.  This encourages community members to make changes and potentially contribute to the project through :doc:`pull requests to the main JEDI repositories <../../developer/practices/pullrequest>`.

So, to do this, you need a *development container*.  In contrast to an application container, a development container does not include the JEDI code.  But, it does include everything you need to acquire and build it.

In this approach (which you would also follow when using :doc:`environment modules <../../developer/jedi_environment/modules>`), we will download the code from `GitHub <https://github.com>`_ and compile it.  Then we will run the JEDI test suite.

This tutorial parallels very closely the :doc:`JEDI Quick Start <../../quick-start>`.  However, here we will be building the more extensive ``fv3-bundle`` as opposed to the ``ufo-bundle``.

Step 1: Download and Enter the Development Container
----------------------------------------------------

You can obtain the JEDI development container with the following command:

.. code-block:: bash

   singularity pull library://jcsda/public/jedi-gnu-openmpi-dev

This is the version of the development container that uses gnu compilers and the openmpi MPI library.  :ref:`Other development containers are also available <available_containers>` but the ``gnu-openmpi`` container is the only one that is currently equipped with plotting tools such as ``cartopy`` that are used in some of the tutorials (not this one).  Still, you may wish to repeat this tutorial with the ``clang-mpich-dev`` container.

If the pull was successful, you should see a new file in your current directory with the name ``jedi-gnu-openmpi-dev_latest.sif``.  If it has a different name or a different extension you may have an older version of Singularity.  It is recommended that you use Singularity version 3.0 or later.

If you wish, you can verify that the container came from JCSDA by entering:

.. code-block:: bash

   singularity verify jedi-gnu-openmpi-dev_latest.sif

Now you can enter the container with the following command:

.. code-block:: bash

   singularity shell -e jedi-gnu-openmpi-dev_latest.sif

To exit the container at any time (not now), simply enter

.. code-block:: bash

   exit

Before proceeding, you may wish to take a few moments to :ref:`get to know the container <meet-the-container>`.

Step 2: Build fv3-bundle
------------------------

Step 3: Run the test suite
--------------------------

If you are doing this tutorial as a prerequisite to other, more advanced tutorials, then you may wish to skip this step.  But, you should do it at least once with the default (latest release) version of the code to verify that things are installed and working properly on your platform of choice.
