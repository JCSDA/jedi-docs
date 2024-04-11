.. _top-modules:

Using spack-stack modules to build and run JEDI
===============================================

The instructions in this section are specific to the use of spack-stack environment modules (``lmod/lua`` or ``tcl/tk``) for building and running JEDI applications. For general information on using spack-stack to build and run software, see the `spack-stack documentation <https://spack-stack.readthedocs.io/en/1.7.0>`_.

One of the big advantages of spack-stack is that it automatically generates modules for all compiled packages and Python packages and works in exactly the same way on HPCs, on the cloud, and on a personal computer. Environment modules are available on basically all HPC systems and any modern macOS or Linux distribution, and are an easy and effective way to manage software libraries. There are two main flavors, the older ``tcl/tk`` modules and the newer ``lmod/lua`` modules, with the latter being superior and therefore preferred, if available. The two implementations share similar commands, such as:

.. code-block:: bash

   module list # list modules you currently have loaded
   module spider <string> # list all modules that contain <string>
   module avail # list modules that are compatible with the modules you already have loaded
   module load <package1> <package2> <...> # load specified packages
   module unload <package1> <package2> <...> # unload specified packages
   module purge # unload all modules

``lmod/lua`` modules provide other convenient commands such as

.. code-block:: bash

   module swap <packageA> <packageB> # swap one module for another

and handle module dependencies, conflicts, loading and unloading better than ``tcl/tk`` modules.

For further information (and more commands) you can refer to the `Lmod <https://lmod.readthedocs.io/en/latest/010_user.html>`_ and `Environment Modules <https://modules.readthedocs.io/en/latest/>`_ documentation.

We currently offer spack-stack modules for JEDI on several HPC systems, as described below. Consult the appropriate section for instructions on how to access the JEDI modules on each system.

These modules provide all of the software libraries necessary to build and run JEDI. It is highly recommended that users start with a clean environment, i.e. that they do not load modules or modify search paths etc. in the automatically source `.bashrc`, `.bash_profile` etc. scripts. After loading the appropriate modules, users can proceed to :doc:`compile and run the JEDI bundle of their choice </using/building_and_running/building_jedi>`.


General Instructions
--------------------

This section outlines the general steps to set up spack-stack modules for the desired HPC. Please see :ref:`hpc_users_guide` for more information on how to run jobs on the different HPCs.

1. Load HPC specific modules from `spack-stack pre-configured sites documentation <https://spack-stack.readthedocs.io/en/1.7.0/PreConfiguredSites.html>`_.

2. Load appropriate modules for JEDI and the ``{skylab_v}`` release.

   .. code-block:: bash

      module load jedi-fv3-env
      module load ewok-env
      module load soca-env

3. Your environment is now set up, users can proceed to :ref:`compile and run the JEDI bundle of their choice <build-jedi>`.

JEDI and Skylab environment set up using jedi-tools
"""""""""""""""""""""""""""""""""""""""""""""""""""

Setup scripts are available in the `jedi-tools github repository <https://github.com/JCSDA-internal/jedi-tools>`_. These scripts will allow you to correctly set up your JEDI environment in order to build JEDI and also run Skylab experiments. The systems (and compilers) that are currently supported are localhost (gnu, intel, clang), aws-pcluster (gnu, intel), derecho (intel, gnu), discover (intel, gnu), hercules (intel, gnu), orion (intel, gnu), and s4 (intel).

1. On certain HPCs, like Hercules and Discover, you will need to load the ``git-lfs`` module first. You can verify by running ``module show git-lfs`` to see if the module is available. This needs to be done before you check out any JEDI repository. Note, some HPCs have ``git lfs`` installed via the OS and do not provide a git-lfs module. If that is the case, this step can be skipped.

   .. code-block:: bash

      module show git-lfs
      module load git-lfs

2. Create your ``JEDI_ROOT`` directory and clone the `jedi-tools github repository <https://github.com/JCSDA-internal/jedi-tools>`_. In ``JEDI_ROOT`` you will clone the JEDI code and all the files needed to build, test, and run JEDI and SkyLab.

   .. code-block:: bash

      mkdir $JEDI_ROOT
      cd $JEDI_ROOT
      git clone https://github.com/JCSDA-internal/jedi-tools

3. Edit the header of ``jedi-tools/buildscripts/setup.sh`` to fill in your ``JEDI_ROOT`` location, ``HOST``, and ``COMPILER``. Then source the updated ``setup.sh`` script. Note, there is more information needed to be filled out if you are running on ``localhost``.

   .. code-block:: bash

      cd jedi-tools
      vi buildscripts/setup.sh
      source buildscripts/setup.sh

4. At this point you should have all of the modules needed and loaded in your HPC environment to continue with building JEDI. Verify the modules by running :code:`module list` and proceed to :ref:`build-jedi`.

  **For HPC specific build and testing help, see** :ref:`hpc_users_guide`

