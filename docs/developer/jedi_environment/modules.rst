.. _top-modules:

JEDI Modules
=======================

If you are running JEDI on a personal computer (Mac, Windows, or linux) we recommend that you use either the :doc:`JEDI Singularity container <singularity>` or the :code:`JEDI Charliecloud container <charliecloud>`.  These provide all of the necessary software libraries for you to build and run JEDI.

If you are running JEDI on an HPC system, :doc:`Charliecloud <charliecloud>` is still a viable option.  However, on selected HPC systems that are accessed by multiple JEDI users we offer another option, namely **JEDI Modules**.

Modules are implemented on most HPC systems and are an easy and effective way to manage software libraries.  Most implementations share similar commands, such as:

.. code :: bash

   module list # list modules you currently have loaded
   module avail # list all available modules
   module spider <string> # search for <string> in available module names
   module load <package1> <package2> <...> # load specified packages
   module unload <package1> <package2> <...> # unload specified packages
   module swap <packageA> <packageB> # swap one module for another

The last command is equivalent to

.. code :: bash

   module unload <packageA>
   module load <packageB>

For further information (and more commands) you can refer to a specific implementation such as `Lmod <https://lmod.readthedocs.io/en/latest/010_user.html>`_.

We currently offer JEDI modules on several HPC systems, as described below.   Consult the appropriate section for instructions on how to access the JEDI modules on each system.

These modules are functionally equivalent to the JEDI Singularity and Charliecloud containers in the sense that they provide all of the necessary software libraries necessary to build and run JEDI.  But there is no need to install a container provider or to enter a different mount namespace.  After loading the appropriate JEDI module, users can proceed to :ref:`compile and run the JEDI bundle of their choice <build-jedi>`.

Theia
---------

On Theia, users can access the installed jedi modules by first entering

.. code :: bash

   module use -a /contrib/da/modulefiles

To load the default configuration that uses the intel compiler suite, enter

.. code :: bash

   module load jedi

Or, if you'd rather use GNU compilers you can enter this instead:

.. code :: bash

   module load jedi/jedi-gcc-7.3.0

To list the module you currently have loaded, enter

.. code :: bash

   module list

If you already have GNU version 7.3.0 loaded and you want to switch to version 8.2.0, you can enter

.. code :: bash

   module swap jedi/jedi-gcc-7.3.0 jedi/jedi-gcc-8.2.0

To explore other options, enter

.. code :: bash

   module spider jedi

When you are happy with this, you are ready to :ref:`build and run your JEDI bundle <build-jedi>`.  However, before proceeding, here are a few tips to keep in mind.

* If you are using intel compilers, run ecbuild with the following option in order to make sure you have the correct system-specific run command for parallel jobs:

.. code:: bash

    ecbuild -DMPIEXEC=$MPIEXEC

* Use up to 12 MPI tasks to make the compile more efficient

.. code:: bash

    make -j12
  
   
      
Cheyenne
---------
      
Discover
---------
      

