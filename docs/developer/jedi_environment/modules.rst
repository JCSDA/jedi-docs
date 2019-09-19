.. _top-modules:

JEDI Modules
============

If you are running JEDI on a personal computer (Mac, Windows, or Linux) we recommend that you use either the :doc:`JEDI Singularity container <singularity>` or the :doc:`JEDI Charliecloud container <charliecloud>`.  These provide all of the necessary software libraries for you to build and run JEDI.

If you are running JEDI on an HPC system, :doc:`Charliecloud <charliecloud>` is still a viable option.  However, on selected HPC systems that are accessed by multiple JEDI users we offer another option, namely **JEDI Modules**.

Environment modules are implemented on most HPC systems and are an easy and effective way to manage software libraries.  Most implementations share similar commands, such as:

.. code :: bash

   module list # list modules you currently have loaded
   module spider <string> # list all modules that contain <string>
   module avail # list modules that are compatible with the modules you already have loaded
   module load <package1> <package2> <...> # load specified packages
   module unload <package1> <package2> <...> # unload specified packages
   module swap <packageA> <packageB> # swap one module for another
   module purge # unload all modules


For further information (and more commands) you can refer to a specific implementation such as `Lmod <https://lmod.readthedocs.io/en/latest/010_user.html>`_.

We currently offer JEDI modules on several HPC systems, as described below.   Consult the appropriate section for instructions on how to access the JEDI modules on each system.

These modules are functionally equivalent to the JEDI Singularity and Charliecloud containers in the sense that they provide all of the software libraries necessary to build and run JEDI.  But there is no need to install a container provider or to enter a different mount namespace.  After loading the appropriate JEDI module or modules (some bundles may require loading more than one), users can proceed to :ref:`compile and run the JEDI bundle of their choice <build-jedi>`.

We begin with some general instructions on how to use modules that apply across all systems.  We then give more detailed usage tips for specific systems.

General Usage
-------------

As a first step, it is a good idea to remove pre-existing modules that might conflict with the software libraries contained in the JEDI modules.  Experienced users may wish to do this selectively to avoid disabling commonly used packages that are unrelated to JEDI.  However, a quick and robust way to ensure that there are no conflicts is to unload all modules with

.. code :: bash

   module purge

The next step is then to access the JEDI modules with:

.. code :: bash

   module use -a <module-path>

The :code:`<module-path>` where JEDI modules are installed is system-specific as described below.

All implementations will include a default jedi module that you can load with:

.. code :: bash

   module load jedi

This should be sufficient for most users.  But, some users and developers may wish to use different libraries.  For example, the default module on many systems uses the Intel compiler suite but you can switch to the GNU compiler suite by entering something like this:

.. code :: bash

   module switch jedi jedi/gnu

This is equivalent to entering

.. code :: bash

   module unload jedi
   module load jedi/gnu

Of course, this example will only work if a module named :code:`jedi/gnu` exists.  There may be name variations across platforms depending on what software has been installed.  To see what options are available for JEDI, enter

.. code :: bash

   module spider jedi

This will include alternative versions of the main jedi module (indicated with a slash as in :code:`jedi/gnu` above) and it may also include supplementary modules for specific bundles.    These are usually indicated with a hyphen.  So, in summary, the full procedure for initializing the environment for some arbitrary bundle :code:`<A>` might look like this:

.. code :: bash

   module purge
   module use -a <module-path>
   module load jedi
   module load jedi-<A> # unnecessary for ufo-bundle and most others

The jedi module is really multiple nested modules.   To list the modules you currently have loaded, enter

.. code :: bash

   module list

When you are happy with this, you are ready to :ref:`build and run your JEDI bundle <build-jedi>`.

Theia
-----

Theia is an HPC system located in NOAA's NESCC facility in Fairmont, WV.  On Theia, users can access the installed jedi modules by first entering

.. code :: bash

   module use -a /contrib/da/modulefiles

Current options for setting up the JEDI environment include (choose only one)

.. code :: bash

   module load jedi # intel compiler suite
   module load jedi/jedi-gcc-7.3.0 # GNU 7.3.0 compiler suite
   module load jedi/jedi-gcc-8.2.0 # GNU 8.2.0 compiler suite

Some system-specific tips for Theia include:

* If you are using intel compilers, run ecbuild with the following option in order to make sure you have the correct run command for parallel jobs:

.. code:: bash

    ecbuild -DMPIEXEC=$MPIEXEC <...>

* Use up to 12 MPI tasks to speed up the compilation

.. code:: bash

    make -j12



Cheyenne
--------

`Cheyenne <https://www2.cisl.ucar.edu/resources/computational-systems/cheyenne/cheyenne>`_ is a 5.34-petaflops, high-performance computer built for NCAR by SGI. On Cheyenne, users can access the installed jedi modules by first entering

.. code :: bash

   module purge
   export OPT=/glade/work/miesch/modules
   module use $OPT/modulefiles/core

Current options for setting up the JEDI environment include (choose only one)

.. code :: bash

   module load jedi/gnu-openmpi # GNU compiler suite and openmpi
   module load jedi/intel-impi # Intel compiler suite and Intel mpi

* Run ecbuild with the following option

.. code:: bash

    mkdir build; cd build
    ecbuild <path_of_the_jedi_code>

* Use multiple threads to speed up the compilation

.. code:: bash

    make -j4

.. warning::

    Please do not use too many threads to speed up the compilation, Cheyenne system administrator might terminate your login node.

Discover
--------

      `Discover <https://www.nccs.nasa.gov/systems/discover>`_ is 90,000 core supercomputing cluster capable of delivering 3.5 petaflops of high-performance computing for Earth system applications from weather to seasonal to climate predictions.  On Discover, users can access the installed JEDI modules by first entering

.. code :: bash

   module use -a /discover/nobackup/projects/gmao/obsdev/rmahajan/opt/modulefiles

Current options for setting up the JEDI environment include (choose only one)

.. code :: bash

   module load apps/jedi/gcc-7.3          # GNU v7.3.0 compiler suite
   module load apps/jedi/intel-17.0.7.259 # Intel v17.0.7.259 compiler suite

* Run ecbuild with the following option to provide the correct path for :code:`MPIEXEC`

.. code:: bash

    ecbuild -DMPIEXEC=$MPIEXEC <path_of_the_jedi_source_code>

* Use up to 12 MPI tasks to speed up the compilation

.. code:: bash

    make -j12


S4
--
S4 is the **Satellite Simulations and Data Assimilation Studes** supercomputer located at the University of Wisconsin-Madison's Space Science and Engineering Center.

There are a few platform-specific features of S4 that affect how you build and run JEDI.  First, the system currently only supports intel compilers.  Second, S4 uses the `slurm <https://slurm.schedmd.com/>`_ task manager for parallel mpi jobs.  Though some slurm implementations allow you to use the usual mpi job scripts :code:`mpirun` or :code:`mpiexec`, these may not function properly on S4.  Instead, you are advised to use the slurm run script :code:`srun`.  A Third S4 feature is that mpi jobs cannot be run interactively and must instead be submitted with the slurm :code:`sbatch` command.  Finally, S4 system administrators have disabled file locking on their work disks, which can cause problems with HDF5.

So, to accommodate all of these features of the S4 system there are a few actions you need to take.  The first is to include these commands in your :code:`.bashrc` file (or implement their c shell equivalents):


.. code:: bash

    export OPT=/data/users/mmiesch/modules
    export HDF5_USE_FILE_LOCKING=FALSE
    export SLURM_EXPORT_ENV=ALL
    module use $OPT/modulefiles/core
    ulimit -s unlimited

Remember to run :code:`source ~/.bashrc` the first time you add these to make sure the changes take effect.  This should not be necessary for future logins.

The recommended compiler suite to use for JEDI is version 17.0.6.  So, you can build JEDI with these commands:

.. code:: bash

   module load jedi/intel17-impi
   ecbuild -DMPIEXEC=/bin/srun -DMPIEXEC_EXECUTABLE=/usr/bin/srun -DMPIEXEC_NUMPROC_FLAG="-n" <path-to-bundle>
   make -j4

Note that the :code:`jedi/intel17-impi` module includes a patched version of :code:`eckit` that is needed to have mpi jobs run correctly with :code:`srun`.  This patch has been communicated to ECMWF and will be included in future versions of :code:`eckit`.  As is standard JEDI practice, :code:`fckit` is not included in the :code:`jedi/intel17-impi` module and should be built within the bundle.  Note also that you have to tell ecbuild to use :code:`srun` as its mpi executable, as shown above.

To run parallel jobs, you'll need to create a batch script (a file) with contents similar to the following example:

.. code:: bash
   
	  #!/usr/bin/bash
	  #SBATCH --job-name=<name>
	  #SBATCH --partition=ivy
	  #SBATCH --nodes=1
	  #SBATCH --ntasks=4
	  #SBATCH --cpus-per-task=1
	  #SBATCH --time=0:10:00
	  #SBATCH --mail-user=<email-address>

	  source /etc/bashrc
	  module purge
	  module use /data/users/mmiesch/modules/modulefiles/core
	  module load jedi/intel17-impi
	  module list
	  ulimit -s unlimited

          export SLURM_EXPORT_ENV=ALL
          export HDF5_USE_FILE_LOCKING=FALSE	  

	  # run a particular application directly with srun
	  cd <path-to-bundle-build-directory>/test/ufo
	  srun --ntasks=4 --cpu_bind_core --distribution=block:block test_ufo_radiosonde_opr testinput/radiosonde.yaml

	  # ...or run one or more ctests - but make sure the number of tasks it requires matches the
	  # --ntasks SBATCH specification above
	  cd <path-to-bundle-build-directory>
          ctest -R <mytest>
	  
	  exit 0
   
Then you can submit and monitor your jobs with these commands

.. code:: bash

	  sbatch <batch-script>
	  squeue | grep <your-user-name>

You can delete jobs with the :code:`scancel` command.  For further information please consult the S4 user documentation.	  
