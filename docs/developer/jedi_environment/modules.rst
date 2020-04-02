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

Hera
-----

Hera is an HPC system located in NOAA's NESCC facility in Fairmont, WV.  On Hera, users can access the installed jedi modules by first entering

.. code :: bash

  module use -a /scratch1/NCEPDEV/jcsda/Ryan.Honeyager/jedi/modules/

Currently the intel 18 module is preferred:

.. code :: bash

  module load jedi-stack/intel-impi-18.0.5

Also, it is recommended that you specify :code:`srun` as your mpi process manager when building, like so:
  
.. code:: bash

   ecbuild -DMPIEXEC_EXECUTABLE=`which srun` -DMPIEXEC_NUMPROC_FLAG="-n" <path-to-bundle>
   make -j4

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
   module load jedi/intel19-impi # Intel 19.0.5 compiler suite and Intel mpi

Run ecbuild and pull the latest code.  Note - because of space limitations on your home directory, it's a good idea to locate your build directory on glade:

.. code:: bash

    cd /glade/work/<username>	  
    mkdir jedi/build; cd jedi/build
    ecbuild <path-to-jedi-bundle>
    make update

Use multiple threads to speed up the compilation

.. code:: bash

    make -j4

.. warning::

    Please do not use too many threads to speed up the compilation, Cheyenne system administrator might terminate your login node.

The system configuration on Cheyenne will not allow you to run mpi jobs from the login node.  So, if you try to run :code:`ctest` from here, the mpi tests will fail.  So, to run the jedi unit tests you will have to either submit a batch job or request an interactive session with :code:`qsub -I`.  The following is a sample batch script to run the unit tests for ufo-bundle.  Note that some ctests require up to 6 MPI tasks so requesting 6 cores should be sufficient.

.. code:: bash

    #!/bin/bash
    #PBS -N ctest-impi
    #PBS -A <account-number>
    #PBS -l walltime=00:20:00
    #PBS -l select=1:ncpus=6:mpiprocs=6
    #PBS -q regular
    #PBS -j oe
    #PBS -m abe
    #PBS -M <your-email>

    source /glade/u/apps/ch/opt/lmod/7.2.1/lmod/lmod/init/bash
    module purge
    export OPT=/glade/work/miesch/modules
    module use $OPT/modulefiles/core
    module load jedi/intel19-impi

    # cd to your build directory.  Make sure that these binaries were built
    # with the same module that is loaded above, in this case jedi/intel-impi
    
    cd /glade/work/<username>/jedi/ufo-bundle/build-intel-impi

    # now run ctest
    ctest
    
    
Discover
--------

`Discover <https://www.nccs.nasa.gov/systems/discover>`_ is 90,000 core supercomputing cluster capable of delivering 3.5 petaflops of high-performance computing for Earth system applications from weather to seasonal to climate predictions.

As of March, 2020, JCSDA users of Discover have been encouraged to migrate to the new SLES-12 (SuSE Linux Enterprise Server version 12) operating system.  To access these nodes, login to Discover as you normally would and then enter

.. code :: bash

   ssh discover-sles12

During NASA's transition period, it can be tricky to remember whether you are logged in to the old SLES-11 or the new SLES-12 because they share many of the same filesystems, including your home directory and your ``/discover/nobackup`` work directory.  So, at any time, if you want to make sure you are logged into the SLES-12 system, you can enter this:

.. code :: bash

   cat /etc/os-release

If you are on the SLES-12 system, this will let you know.

To access the jedi modules on Discover SLES-12, it is recommended that you add this to your ``$HOME/.bashrc`` file (or the equivalent if you use another shell):

.. code :: bash

   export OPT=/discover/swdev/jcsda/modules
   module use $OPT/modulefiles

Currently two stacks are maintained (choose only one)

.. code :: bash

   module load apps/jedi/intel-impi # aka apps/jedi/intel-impi/20.0.0.166
   module load apps/jedi/gnu-impi # aka apps/jedi/9.2.0

   
Despite the name (``20.0.0.166``), the first loads version 19.1.0.166 of the intel compiler and mpi suite.

The second option may seem a little surprising, pairing the gnu 9.2.0 compiler suite with the intel 19.1.0.166 mpi library.  However, this is intentional.  Intel MPI is currently the recommended MPI library on SLES-12 for both Intel and gnu compilers.  Note that OpenMPI is not yet available on SLES-12, though they do have hpcx, which is a proprietary variant of OpenMPI from Mellanox.

Each of these jedi modules defines the environment variable ``MPIEXEC`` which points to the recommended ``mpirun`` executable and which should then be explicitly specified when you build jedi:

.. code :: bash

   ecbuild -DMPIEXEC_EXECUTABLE=$MPIEXEC -DMPIEXEC_NUMPROC_FLAG="-np" <path-to-bundle>

There is also another module that is built from the ESMA ``baselibs`` libraries.  To use this, enter:

.. code :: bash

    module purge
    module load apps/jedi/baselibs/intel-impi

Currently only ``intel-impi/19.1.0.166`` is the only baselibs option available but more may be added in the future.  Specify the MPI excutable explicitly when you build as with the previous modules.

.. code:: bash

    ecbuild -DMPIEXEC_EXECUTABLE=$MPIEXEC -DMPIEXEC_NUMPROC_FLAG="-np" <path-to-bundle>
    make -j4

Whichever module you use, after building you will want to run the ``get`` tests from the login node to get the test data from AWS S3:

.. code:: bash

    ctest -R get

To run the remaining tests, particularly those that require MPI, you'll need to acquire a compute node.  You can do this interactively with

.. code:: bash

    salloc --nodes=1 --time=30

Or, you can submit a batch script to the queue through ``sbatch`` as described in the S4 instructions below.    

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
   ecbuild -DMPIEXEC_EXECUTABLE=/usr/bin/srun -DMPIEXEC_NUMPROC_FLAG="-n" <path-to-bundle>
   make -j4

As is standard JEDI practice, :code:`fckit` is not included in the :code:`jedi/intel17-impi` module and should be built within the bundle.  Note also that you have to tell ecbuild to use :code:`srun` as its mpi executable, as shown above.

To run parallel jobs, you'll need to create a batch script (a file).  For example, to run ctest you can create a file similar to this (call it what you wish: for example ``ctest-ufo.sh``):

.. code:: bash
   
	  #!/usr/bin/bash
	  #SBATCH --job-name=<name>
	  #SBATCH --nodes=1
	  #SBATCH --cpus-per-task=1
	  #SBATCH --time=0:10:00
	  #SBATCH --mail-user=<email-address>

	  source /etc/bashrc
	  module purge
	  export OPT=/data/users/mmiesch/modules
	  module use $OPT/modulefiles/core
	  module load jedi/intel17-impi
	  module list
	  ulimit -s unlimited

          export SLURM_EXPORT_ENV=ALL
          export HDF5_USE_FILE_LOCKING=FALSE	  

	  cd <path-to-bundle-build-directory>
          ctest
	  
	  exit 0

Note that the options specified with ``#SBATCH`` include the number of nodes but not the number of tasks needed.  This is most appropriate for running ``ctest`` because some tests require a different number of MPI tasks than others.  However, if you run an application individually, you should specify ``#SBATCH --ntasks <number>`` instead of ``#SBATCH --nodes=<number>``, as shown in the following example.  The slurm job scheduler will then determine how many nodes you need.  For example, if you are running with the ivy partition as shown here, then each node has 20 cpu cores.  So, if your application takes more than 20 MPI tasks, slurm will allocate more than one node.  Specifying ``--ntasks`` instead of ``--nodes`` in the ``#SBATCH`` header commands will ensure that your computing allocation will only be charged for what you use.  So, this is preferable for more computationally intensive jobs:

.. code:: bash
   
	  #!/usr/bin/bash
	  #SBATCH --job-name=<name>
	  #SBATCH --partition=ivy
	  #SBATCH --ntasks=4
	  #SBATCH --cpus-per-task=1
	  #SBATCH --time=0:10:00
	  #SBATCH --mail-user=<email-address>

	  source /etc/bashrc
	  module purge
	  export OPT=/data/users/mmiesch/modules
	  module use $OPT/modulefiles/core
	  module load jedi/intel17-impi
	  module list
	  ulimit -s unlimited

          export SLURM_EXPORT_ENV=ALL
          export HDF5_USE_FILE_LOCKING=FALSE	  

	  # make sure the number of tasks it requires matches the SBATCH --ntasks specification above
	  cd <path-to-bundle-build-directory>/test/ufo
	  srun --ntasks=4 --cpu_bind_core --distribution=block:block test_ufo_radiosonde_opr testinput/radiosonde.yaml

	  exit 0
   
Then you can submit and monitor your jobs with these commands

.. code:: bash

	  sbatch <batch-script>
	  squeue -u <your-user-name>

You can delete jobs with the :code:`scancel` command.  For further information please consult `the S4 user documentation <https://groups.ssec.wisc.edu/groups/S4/>`_.	  
