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

Module Usage
------------

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

General Tips for HPC Systems
----------------------------

Many HPC systems do not allow you to run MPI jobs from the login nodes.  So, after building JEDI, you'll have to run the tests either in batch mode through a job submission program such as :code:`slurm` via :code:`sbatch` directives, or by accessing a batch compute node interactively through a program such as :code:`salloc`.  Often these batch nodes do not have access to the internet; after you build JEDI, you may need to run the following command from a login node:

.. code :: bash

    ctest -R get_

This runs several tests. The purpose of these tests is to download data files from the cloud that are then used by many of the other tests.  If the :code:`get_*` tests are successful, then the data was downloaded successfully and you can proceed to run the remainder of the tests in batch using :code:`sbatch`, :code:`salloc`, or the equivalent process management command on your system.


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


Orion
-----

Orion is an HPC system located at Mississippi State University for the purpose of furthering NOAA’s scientific research and collaboration.

A few steps are necessary to access the installed jedi modules.  The first is to include these commands in your :code:`.bashrc` file (or implement their c-shell equivalents):

.. code :: bash

   export JEDI_OPT=/work/noaa/da/grubin/opt/modules
   module use $JEDI_OPT/modulefiles/core
   

Currently there are two sets of compiler / MPI module suites available (choose only one): 

Intel compiler suite v20.0.166 and associated Intel MPI:

.. code :: bash

   module load jedi/intel-impi # Intel compiler suite v20.0.166 with Intel MPI
 
 
and GNU compilers v8.3.0 and OpenMPI v4.0.2

.. code :: bash

   module load jedi/gnu-openmpi # GNU compiler suite v8.3.0 with OpenMPI v4.0.2


Orion uses the `slurm <https://slurm.schedmd.com/>`_ task manager for parallel mpi jobs.  Though some slurm implementations allow you to use the usual mpi job scripts :code:`mpirun` or :code:`mpiexec`, these may not function properly on orion.  Instead, you are advised to use the slurm run script :code:`srun`; an appropriate jedi cmake toolchain is available to set this up.

First, clone the :code:`jedi-cmake` repository:

.. code:: bash

   git clone git@github.com:jcsda/jedi-cmake.git

Then pass the following toolchain to :code:`ecbuild`, and use multiple threads to speed up the compilation:

.. code:: bash

    git clone https://github.com/jcsda/<jedi-bundle>
    mkdir -p jedi/build; cd jedi/build
    ecbuild --toolchain=<path-to-jedi-cmake>/jedi-cmake/cmake/Toolchains/jcsda-Orion-Intel.cmake <path-to-bundle>
    make -j4
   

Alternatively, you can specify the MPI executable directly on the command line:

.. code:: bash

   ecbuild -DMPIEXEC_EXECUTABLE=/opt/slurm/bin/srun -DMPIEXEC_NUMPROC_FLAG="-n" <path-to-bundle>
   make -j4


Note that this specifying :code:`srun` as the MPI executable is really only necessary for the ctests.  If you run an application directly (outside of ctest), you may simply use :code:`srun`.

Here is a sample `slurm <https://slurm.schedmd.com/>`_ batch script for running ctest. Note that you will need to add appropriate :code:`#SBATCH` directives for specifying a computing account, quality of service, job partition, and so on; please consult `the Orion Usage and Guidelines documentation <https://intranet.hpc.msstate.edu/helpdesk/resource-docs/cluster_guide.php#orion-use>`_.

.. code:: bash

   #!/usr/bin/bash
   #SBATCH --job-name=<name>
   #SBATCH --nodes=1
   #SBATCH --account <account>
   #SBATCH --partition <partition>
   #SBATCH --qos <qos>
   #SBATCH --time=0:10:00
   #SBATCH --mail-user=<email-address>

   source /etc/bashrc
   module purge
   export JEDI_OPT=/work/noaa/da/grubin/opt/modules
   module use $JEDI_OPT/modulefiles/core
   module load jedi/intel-impi
   module list
   ulimit -s unlimited

   export SLURM_EXPORT_ENV=ALL
   export HDF5_USE_FILE_LOCKING=FALSE

   cd <path-to-bundle-build-directory>
   ctest -E get_

   exit 0

Note that the options specified with ``#SBATCH`` include the number of nodes but not the number of tasks needed.  This is most appropriate for running ``ctest`` because some tests require a different number of MPI tasks than others.  However, if you run an application individually, you should specify ``#SBATCH --ntasks <number>`` instead of ``#SBATCH --nodes=<number>``, as shown in the following example.  The slurm job scheduler will properly determine how many nodes your job requires. Specifying ``--ntasks`` instead of ``--nodes`` in the ``#SBATCH`` header commands will mandate that your computing allocation will only be charged for what you use.  This is preferable for more computationally intensive jobs:

.. code:: bash

   #!/usr/bin/bash
   #SBATCH --job-name=<name>
   #SBATCH --ntasks=4
   #SBATCH --cpus-per-task=1
   #SBATCH --time=0:10:00
   #SBATCH --mail-user=<email-address>

   source /etc/bashrc
   module purge
   export JEDI_OPT=/work/noaa/da/grubin/opt/modules
   module use $JEDI_OPT/modulefiles/core
   module load jedi/intel-impi
   module list
   ulimit -s unlimited

   export SLURM_EXPORT_ENV=ALL
   export HDF5_USE_FILE_LOCKING=FALSE

   # make sure the number of tasks it requires matches the SBATCH --ntasks specification above
   cd <path-to-bundle-build-directory>
   srun --ntasks=4 --cpu_bind_core --distribution=block:block test_ufo_radiosonde_opr testinput/radiosonde.yaml

   exit 0

Submit and monitor your jobs with these commands

.. code:: bash

	  sbatch <batch-script>
	  squeue -u <your-user-name>

You can delete jobs with the :code:`scancel` command.  For further information please consult `the Orion Cluster Computing Basics documentation <https://intranet.hpc.msstate.edu/helpdesk/resource-docs/clusters_getting_started.php>`_.


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
   module load jedi/intel-impi # Intel 19.0.5 compiler suite and Intel mpi

Because of space limitations on your home directory, it's a good idea to locate your build directory on glade:

.. code:: bash

    cd /glade/work/<username>
    mkdir jedi/build; cd jedi/build

If you choose the :code:`jedi/gnu-openmpi` module, you can proceed run ecbuild as you would on most other systems:

.. code:: bash

   ecbuild <path-to-bundle>
   make update
   make -j4

.. warning::

   Please do not use too many threads to speed up the compilation, Cheyenne system administrator might terminate your login node.

However, if you choose to compile with the `jedi/intel-impi` module you must use a toolchain.  This is required in order enable C++14 and to link to the proper supporting libraries.

So, first clone the :code:`jedi-cmake` repository:

.. code:: bash

   git clone git@github.com:jcsda/jedi-cmake.git

Then pass this toolchain to :code:`ecbuild`:

.. code:: bash

   ecbuild --toolchain=<path-to-jedi-cmake>/jedi-cmake/cmake/Toolchains/jcsda-Cheyenne-Intel.cmake <path-to-bundle>

The system configuration on Cheyenne will not allow you to run mpi jobs from the login node.  So, if you try to run :code:`ctest` from here, the mpi tests will fail.  So, to run the jedi unit tests you will have to either submit a batch job or request an interactive session with :code:`qsub -I`.  The following is a sample batch script to run the unit tests for ufo-bundle.  Note that some ctests require up to 6 MPI tasks so requesting 6 cores should be sufficient.

.. code:: bash

    #!/bin/bash
    #PBS -N ctest-ufo-gnu
    #PBS -A <account-number>
    #PBS -l walltime=00:20:00
    #PBS -l select=1:ncpus=6:mpiprocs=6
    #PBS -q regular
    #PBS -j oe
    #PBS -m abe
    #PBS -M <your-email>

    source /glade/u/apps/ch/opt/lmod/8.1.7/lmod/lmod/init/bash
    module purge
    export OPT=/glade/work/miesch/modules
    module use $OPT/modulefiles/core
    module load jedi/gnu-openmpi
    module list

    # cd to your build directory.  Make sure that these binaries were built
    # with the same module that is loaded above, in this case jedi/intel-impi

    cd <build-directory>

    # now run ctest
    ctest -E get_


Discover
--------

`Discover <https://www.nccs.nasa.gov/systems/discover>`_ is 90,000 core supercomputing cluster capable of delivering 3.5 petaflops of high-performance computing for Earth system applications from weather to seasonal to climate predictions.

To access the jedi modules on Discover, it is recommended that you add this to your ``$HOME/.bashrc`` file (or the equivalent if you use another shell):

.. code :: bash

   export JEDI_OPT=/discover/swdev/jcsda/modules
   module use $JEDI_OPT/modulefiles/core
   module use $JEDI_OPT/modulefiles/apps

Currently two stacks are maintained (choose only one)

.. code :: bash

   module load jedi/intel-impi
   module load jedi/gnu-impi


The second option may seem a little surprising, pairing the gnu 9.2.0 compiler suite with the intel 19.1.0.166 mpi library.  However, this is intentional.  Intel MPI is currently the recommended MPI library on SLES-12 for both Intel and gnu compilers.  Note that OpenMPI is not yet available on SLES-12, though they do have hpcx, which is a proprietary variant of OpenMPI from Mellanox.

Each of these jedi modules defines the environment variable ``MPIEXEC`` which points to the recommended ``mpirun`` executable and which should then be explicitly specified when you build jedi:

.. code :: bash

   ecbuild -DMPIEXEC_EXECUTABLE=$MPIEXEC -DMPIEXEC_NUMPROC_FLAG="-np" <path-to-bundle>

There is also another module that is built from the ESMA ``baselibs`` libraries.  To use this, enter:

.. code :: bash

    module purge
    module load jedi/baselibs/intel-impi

Currently only ``intel-impi/19.1.0.166`` is the only baselibs option available but more may be added in the future.  Specify the MPI executable explicitly when you build as with the previous modules.

.. code:: bash

    ecbuild -DMPIEXEC_EXECUTABLE=$MPIEXEC -DMPIEXEC_NUMPROC_FLAG="-np" <path-to-bundle>
    make -j4

Whichever module you use, after building you will want to run the ``get`` tests from the login node to get the test data from AWS S3:

.. code:: bash

    ctest -R get_

To run the remaining tests, particularly those that require MPI, you'll need to acquire a compute node.  You can do this interactively with

.. code:: bash

    salloc --nodes=1 --time=30

Or, you can submit a batch script to the queue through ``sbatch`` as described in the S4 instructions below.

S4
--
S4 is the **Satellite Simulations and Data Assimilation Studies** supercomputer located at the University of Wisconsin-Madison's Space Science and Engineering Center.

The S4 system currently only supports intel compilers.  Furthermore, S4 uses the `slurm <https://slurm.schedmd.com/>`_ task manager for parallel mpi jobs.  Though some slurm implementations allow you to use the usual mpi job scripts :code:`mpirun` or :code:`mpiexec`, these may not function properly on S4.  Instead, you are advised to use the slurm run script :code:`srun`.

So, to load the JEDI intel module you can use the following commands (as on other systems, you can put the first two lines in your :code:`~/.bashrc` file for convenience):

.. code:: bash

   export JEDI_OPT=/data/users/mmiesch/modules
   module use $JEDI_OPT/modulefiles/core
   module load jedi/intel-impi

The recommended way to compile JEDI on S4 is to first clone the :code:`jedi-cmake` repository, which contains an S4 toolchain:

.. code:: bash

   git clone git@github.com:jcsda/jedi-cmake.git

Then pass this toolchain to :code:`ecbuild`:

.. code:: bash

   ecbuild --toolchain=<path-to-jedi-cmake>/jedi-cmake/cmake/Toolchains/jcsda-S4-Intel.cmake <path-to-bundle>

Alternatively, you can specify the MPI executable directly on the command line:

.. code:: bash

   ecbuild -DMPIEXEC_EXECUTABLE=/usr/bin/srun -DMPIEXEC_NUMPROC_FLAG="-n" <path-to-bundle>
   make -j4

Note that this specifying :code:`srun` as the MPI executable is only really necessary for the ctests.  If you run an application directly (outside of ctest), you can just use :code:`srun`.

Here is a sample slurm batch script for running ctest.

.. code:: bash

   #!/usr/bin/bash
   #SBATCH --job-name=<name>
   #SBATCH --nodes=1
   #SBATCH --cpus-per-task=1
   #SBATCH --time=0:10:00
   #SBATCH --mail-user=<email-address>

   source /etc/bashrc
   module purge
   export JEDI_OPT=/data/users/mmiesch/modules
   module use $JEDI_OPT/modulefiles/core
   module load jedi/intel-impi
   module list
   ulimit -s unlimited

   export SLURM_EXPORT_ENV=ALL
   export HDF5_USE_FILE_LOCKING=FALSE

   cd <path-to-bundle-build-directory>
   ctest -E get_

   exit 0

Note that the options specified with ``#SBATCH`` include the number of nodes but not the number of tasks needed.  This is most appropriate for running ``ctest`` because some tests require a different number of MPI tasks than others.  However, if you run an application individually, you should specify ``#SBATCH --ntasks <number>`` instead of ``#SBATCH --nodes=<number>``, as shown in the following example.  The slurm job scheduler will then determine how many nodes you need.  For example, if you are running with the ivy partition as shown here, then each node has 20 cpu cores.  So, if your application takes more than 20 MPI tasks, slurm will allocate more than one node.  Specifying ``--ntasks`` instead of ``--nodes`` in the ``#SBATCH`` header commands will ensure that your computing allocation will only be charged for what you use.  So, this is preferable for more computationally intensive jobs:

.. code:: bash

   #!/usr/bin/bash
   #SBATCH --job-name=<name>
   #SBATCH --ntasks=4
   #SBATCH --cpus-per-task=1
   #SBATCH --time=0:10:00
   #SBATCH --mail-user=<email-address>

   source /etc/bashrc
   module purge
   export JEDI_OPT=/data/users/mmiesch/modules
   module use $JEDI_OPT/modulefiles/core
   module load jedi/intel-impi
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
