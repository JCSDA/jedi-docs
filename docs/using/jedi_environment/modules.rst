.. _top-modules:

Using spack-stack modules to build and run JEDI
===============================================

The instructions in this section are specific to the use of spack-stack environment modules (``lmod/lua`` or ``tcl/tk``)
for building and running JEDI applications. For general information on using spack-stack to build and run software,
see the `spack-stack documentation <https://spack-stack.readthedocs.io/en/spack-stack-1.0.1>`_.

One of the big advantages of spack-stack is that it automatically generates modules for all compiled packages and Python
packages and works in exactly the same way on HPCs, on the cloud, and on a personal computer.
Environment modules are available on basically all HPC systems and any modern macOS or Linux distribution,
and are an easy and effective way to manage software libraries. There are two main flavors, the older ``tcl/tk`` modules
and the newer ``lmod/lua`` modules, with the latter being superior and therefore preferred, if available.
The two implementations share similar commands, such as:

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

For further information (and more commands) you can refer to
the `Lmod <https://lmod.readthedocs.io/en/latest/010_user.html>`_
and `Environment Modules <https://modules.readthedocs.io/en/latest/>`_ documentation.

We currently offer spack-stack modules for JEDI on several HPC systems, as described below.
Consult the appropriate section for instructions on how to access the JEDI modules on each system.

These modules provide all of the software libraries necessary to build and run JEDI.
It is highly recommended that users start with a clean environment, i.e. that they do not load modules or modify
search paths etc. in the automatically source `.bashrc`, `.bash_profile` etc. scripts.
After loading the appropriate modules, users can proceed to :doc:`compile and run the JEDI bundle of
their choice </using/building_and_running/building_jedi>`.


General Tips for HPC Systems
----------------------------

Many HPC systems do not allow you to run MPI jobs from the login nodes.  So, after building JEDI, you'll have to run the tests either in batch mode through a job submission program such as :code:`slurm` via :code:`sbatch` directives, or by accessing a batch compute node interactively through a program such as :code:`salloc`.  Often these batch nodes do not have access to the internet; after you build JEDI, you may need to run the following command from a login node:

.. code-block:: bash

    ctest -R get_

This runs several tests. The purpose of these tests is to download data files from the cloud that are then used by many of the other tests.  If the :code:`get_*` tests are successful, then the data was downloaded successfully and you can proceed to run the remainder of the tests in batch using :code:`sbatch`, :code:`salloc`, or the equivalent process management command on your system.


Orion
-----

Orion is an HPC system located at Mississippi State University for the purpose of furthering NOAA’s scientific research and collaboration.

The following bash shell commands are necessary to access the installed spack-stack modules (substitute equivalent csh shell commands as appropriate):

.. code-block:: bash

   module purge
   module use /work/noaa/da/role-da/spack-stack/modulefiles
   module load miniconda/3.9.7
   module load ecflow/5.8.4

For ``spack-stack-1.1.0`` with Intel, load the following modules after loading miniconda and ecflow:

.. code-block:: bash

   module use /work/noaa/da/role-da/spack-stack/spack-stack-v1/envs/skylab-2.0.0-intel-2022.0.2/install/modulefiles/Core
   module load stack-intel/2022.0.2
   module load stack-intel-oneapi-mpi/2021.5.1
   module load stack-python/3.9.7
   module available

For ``spack-stack-1.0.1`` with GNU, load the following modules after loading miniconda and ecflow:

.. code-block:: bash

   module use /work/noaa/da/role-da/spack-stack/spack-stack-v1/envs/skylab-2.0.0-gnu-10.2.0/install/modulefiles/Core
   module load stack-gcc/10.2.0
   module load stack-openmpi/4.0.4
   module load stack-python/3.9.7
   module available

For both Intel and GNU, proceed with loading the appropriate modules for your application, for example for the ``skylab-2.0`` release:

.. code-block:: bash

   module load jedi-fv3-env/1.0.0
   module load jedi-ewok-env/1.0.0
   module load soca-env/1.0.0
   module load sp/2.3.3


After loading the appropiate modules, you need to clone the jedi-bundle, create a build directory, configure, and build the bundle.
   
.. code-block:: bash

    git clone https://github.com/jcsda/<jedi-bundle>
    mkdir -p build; cd build
    ecbuild <path-to-bundle>
    make -j4

The next step is to run ctests. We do not recommand running the ctests on login nodes because of the computational requirements of these tests. Instead you can submit ctests
as a batch job or use an interactive node. 
Here is a sample `slurm <https://slurm.schedmd.com/>`_ batch script for running ctest. Note that you will need to add appropriate :code:`#SBATCH` directives for specifying a computing account, quality of service, job partition, and so on; please consult `the Orion Usage and Guidelines documentation <https://intranet.hpc.msstate.edu/helpdesk/resource-docs/cluster_guide.php#orion-use>`_.

.. code-block:: bash

   #!/usr/bin/bash
   #SBATCH --job-name=<name>
   #SBATCH --nodes=1
   #SBATCH --account <account>
   #SBATCH --partition <partition>
   #SBATCH --qos <qos>
   #SBATCH --time=0:10:00
   #SBATCH --mail-user=<email-address>

   source /etc/bashrc

   # Insert the module purge and load statements in here

   module list
   ulimit -s unlimited
   ulimit -v unlimited

   export SLURM_EXPORT_ENV=ALL
   export HDF5_USE_FILE_LOCKING=FALSE

   cd <path-to-bundle-build-directory>
   ctest -E get_

   exit 0

Note that the options specified with ``#SBATCH`` include the number of nodes but not the number of tasks needed.  This is most appropriate for running ``ctest`` because some tests require a different number of MPI tasks than others.  However, if you run an application individually, you should specify ``#SBATCH --ntasks <number>`` instead of ``#SBATCH --nodes=<number>``, as shown in the following example.  The slurm job scheduler will properly determine how many nodes your job requires. Specifying ``--ntasks`` instead of ``--nodes`` in the ``#SBATCH`` header commands will mandate that your computing allocation will only be charged for what you use.  This is preferable for more computationally intensive jobs.

.. code-block:: bash

   #!/usr/bin/bash
   #SBATCH --job-name=<name>
   #SBATCH --ntasks=4
   #SBATCH --cpus-per-task=1
   #SBATCH --time=0:10:00
   #SBATCH --mail-user=<email-address>

   source /etc/bashrc

   # Insert the module purge and load statements in here

   ulimit -s unlimited
   ulimit -v unlimited

   export SLURM_EXPORT_ENV=ALL
   export HDF5_USE_FILE_LOCKING=FALSE

   # make sure the number of tasks it requires matches the SBATCH --ntasks specification above
   cd <path-to-bundle-build-directory>
   # Note that --ntasks=4 below is not needed in this case - srun will use what's in the SBATCH line above
   srun --ntasks=4 --cpu_bind=core --distribution=block:block test_ufo_radiosonde_opr testinput/radiosonde.yaml

   exit 0

.. note::
   JEDI applications (like most NWP applications) require a decent amount of memory, in which case asking for just a fraction of a node may fail with out of memory errors. This can be avoided by asking for an entire node (or, for larger jobs, more nodes) and running with fewer MPI tasks than each node provides by using ``#SBATCH --nodes=1`` and ``srun --ntasks=4``, for example.

Submit and monitor your jobs with these commands

.. code-block:: bash

	  sbatch <batch-script>
	  squeue -u <your-user-name>

You can delete jobs with the :code:`scancel` command.  For further information please consult `the Orion Cluster Computing Basics documentation <https://intranet.hpc.msstate.edu/helpdesk/resource-docs/clusters_getting_started.php>`_.

An alternative to using the batch script is to request an interactive session on Orion and run the ctests there.
To request an interactive session you can run:

.. code-block:: bash

   salloc -N1 -n 24 -A <account> --qos=batch --partition=orion --time=480 -I

Make sure you use the correct account number. This command requests for one node with 24 MPI tasks.


Discover
--------

`Discover <https://www.nccs.nasa.gov/systems/discover>`_ is 90,000 core supercomputing cluster capable of delivering 3.5 petaflops of high-performance computing for Earth system applications from weather to seasonal to climate predictions.

The following bash shell commands are necessary to access the installed spack-stack modules (substitute equivalent csh shell commands as appropriate):


.. code-block:: bash

   module purge
   module use /discover/swdev/jcsda/spack-stack/modulefiles
   module load miniconda/3.9.7
   module load ecflow/5.8.4

For ``spack-stack-1.1.0`` with Intel, load the following modules after loading miniconda and ecflow:

.. code-block:: bash

   module use /gpfsm/dswdev/jcsda/spack-stack/spack-stack-v1/envs/skylab-2.0.0-intel-2022.0.1/install/modulefiles/Core
   module load stack-intel/2022.0.1
   module load stack-intel-oneapi-mpi/2021.5.0
   module load stack-python/3.9.7
   module available

For ``spack-stack-1.1.0`` with GNU, load the following modules after loading miniconda and ecflow:

.. code-block:: bash

   module use /gpfsm/dswdev/jcsda/spack-stack/spack-stack-v1/envs/skylab-2.0.0-gnu-10.1.0/install/modulefiles/Core
   module load stack-gcc/10.1.0
   module load stack-openmpi/4.1.3
   module load stack-python/3.9.7
   module available

For both Intel and GNU, proceed with loading the appropriate modules for your application, for example for the ``skylab-2.0`` release:

.. code-block:: bash

   module load jedi-fv3-env/1.0.0
   module load jedi-ewok-env/1.0.0
   module load soca-env/1.0.0
   module load sp/2.3.3

Note that the existing toolchain for Discover in ``jedi-cmake`` is outdated and cannot be used. Also, different methods are needed for Intel and GNU.

For Intel, when using ``ecbuild``, use ``ecbuild -DMPIEXEC_EXECUTABLE="/usr/local/intel/oneapi/2021/mpi/2021.5.0/bin/mpirun"`` ``-DMPIEXEC_NUMPROC_FLAG="-np"``. After building, you will want to run the ``get`` tests from the login node to download the test data:

.. code-block:: bash

    ctest -R get_

To run the remaining tests, particularly those that require MPI, you'll need to acquire a compute node.  You can do this interactively with

.. code-block:: bash

    salloc --nodes=1 --time=30

Or, you can submit a batch script to the queue through ``sbatch`` as described in the Orion instructions above.

For GNU, when using ``ecbuild``, use ``ecbuild -DMPIEXEC_EXECUTABLE="/usr/bin/srun" -DMPIEXEC_NUMPROC_FLAG="-n"``. Then run all tests directly from the login node.

Hera
-----

Hera is an HPC system located in NOAA's NESCC facility in Fairmont, WV. The following bash shell commands are necessary to access the installed spack-stack modules (substitute equivalent csh shell commands as appropriate):


.. code-block:: bash

   module purge
   module use /scratch1/NCEPDEV/jcsda/jedipara/spack-stack/modulefiles
   module load miniconda/3.9.12
   module load ecflow/5.5.3

For ``spack-stack-1.1.0`` with Intel, load the following modules after loading miniconda and ecflow:

.. code-block:: bash

   module use /scratch1/NCEPDEV/global/spack-stack/spack-stack-v1/envs/skylab-2.0.0-intel-2021.5.0/install/modulefiles/Core
   module load stack-intel/2021.5.0
   module load stack-intel-oneapi-mpi/2021.5.1
   module load stack-python/3.9.12
   module available

For ``spack-stack-1.1.0`` with GNU, load the following modules after loading miniconda and ecflow:

.. code-block:: bash

   module use /scratch1/NCEPDEV/global/spack-stack/spack-stack-v1/envs/skylab-2.0.0-gnu-9.2.0/install/modulefiles/Core
   module load stack-gcc/9.2.0
   module load stack-openmpi/3.1.4
   module load stack-python/3.9.12
   module available

For both Intel and GNU, proceed with loading the appropriate modules for your application, for example for the ``skylab-2.0`` release:

.. code-block:: bash

   module load jedi-fv3-env/1.0.0
   module load jedi-ewok-env/1.0.0
   module load soca-env/1.0.0
   module load sp/2.3.3

It is recommended that you specify :code:`srun` as your mpi process manager when building, like so:

.. code-block:: bash

   ecbuild -DMPIEXEC_EXECUTABLE=`which srun` -DMPIEXEC_NUMPROC_FLAG="-n" <path-to-bundle>
   make -j4

To run tests with slurm and :code:`srun`, you also need to have the following environment variables defined:

.. code-block:: bash

   export SLURM_ACCOUNT=<account you can run slurm jobs under>
   export SALLOC_ACCOUNT=$SLURM_ACCOUNT
   export SBATCH_ACCOUNT=$SLURM_ACCOUNT

Cheyenne
--------

`Cheyenne <https://www2.cisl.ucar.edu/resources/computational-systems/cheyenne/cheyenne>`_ is a 5.34-petaflops, high-performance computer built for NCAR by SGI.

The following bash shell commands are necessary to access the installed spack-stack modules (substitute equivalent csh shell commands as appropriate):

.. code-block:: bash

   module purge
   module unuse /glade/u/apps/ch/modulefiles/default/compilers
   export MODULEPATH_ROOT=/glade/work/jedipara/cheyenne/spack-stack/modulefiles
   module use /glade/work/jedipara/cheyenne/spack-stack/modulefiles/compilers
   module use /glade/work/jedipara/cheyenne/spack-stack/modulefiles/misc
   module load ecflow/5.8.4
   module load miniconda/3.9.12

For ``spack-stack-1.1.0`` with Intel, load the following modules after loading miniconda and ecflow:

.. code-block:: bash

   module use /glade/work/jedipara/cheyenne/spack-stack/spack-stack-v1/envs/skylab-2.0.0-intel-19.1.1.217/install/modulefiles/Core
   module load stack-intel/19.1.1.217
   module load stack-intel-mpi/2019.7.217
   module load stack-python/3.9.12
   module available

For ``spack-stack-1.1.0`` with GNU, load the following modules after loading miniconda and ecflow:

.. code-block:: console

   module use /glade/work/jedipara/cheyenne/spack-stack/spack-stack-v1/envs/skylab-2.0.0-gnu-10.1.0/install/modulefiles/Core
   module load stack-gcc/10.1.0
   module load stack-openmpi/4.1.1
   module load stack-python/3.9.12
   module available

For both Intel and GNU, proceed with loading the appropriate modules for your application, for example for the ``skylab-2.0`` release:

.. code-block:: bash

   module load jedi-fv3-env/1.0.0
   module load jedi-ewok-env/1.0.0
   module load soca-env/1.0.0
   module load sp/2.3.3

Because of space limitations on your home directory, it's a good idea to build your code on the `glade <https://www2.cisl.ucar.edu/resources/storage-and-file-systems/glade-file-spaces>`_ filesystems (`work` or `scratch`):

.. warning::

   Please do not use too many threads to speed up the compilation, Cheyenne system administrator might terminate your login node.

The system configuration on Cheyenne will not allow you to run mpi jobs from the login node.  If you try to run :code:`ctest` from here, the mpi tests will fail.  To run the jedi unit tests you will have to either submit a batch job or request an interactive session with :code:`qsub -I`.  The following is a sample batch script to run the unit tests for ``ufo-bundle``.  Note that some ctests require up to 6 MPI tasks so requesting 6 cores should be sufficient.

.. code-block:: bash

    #!/bin/bash
    #PBS -N ctest-ufo-gnu
    #PBS -A <account-number>
    #PBS -l walltime=00:20:00
    #PBS -l select=1:ncpus=24:mpiprocs=24
    #PBS -q regular
    #PBS -j oe
    #PBS -k eod
    #PBS -m abe
    #PBS -M <your-email>

    # Insert the appropriate module purge and load commands here

    # cd to your build directory.  Make sure that these binaries were built
    # with the same module that is loaded above

    cd <build-directory>

    # now run ctest
    ctest -E get_

Casper
------

.. note:: spack-stack is not yet available on Casper. The instructions below refer to the previous jedi-stack modules that will be replaced with spack-stack modules over the next few weeks.

The `Casper <https://www2.cisl.ucar.edu/resources/computational-systems/casper>`_ cluster is a heterogeneous system of specialized data analysis and visualization resources, large-memory, multi-GPU nodes, and high-throughput computing nodes. On Casper, users can access the installed jedi modules by first entering

.. code-block:: bash

   module purge
   export JEDI_OPT=/glade/work/jedipara/casper/opt/modules
   module use $JEDI_OPT/modulefiles/core

Current options for setting up the JEDI environment include (choose only one)

.. code-block:: bash

   module load jedi/gnu-openmpi # GNU compiler suite and openmpi
   module load jedi/intel-impi # Intel 19.0.5 compiler suite and Intel mpi

Because of space limitations on your home directory, it's a good idea to locate your build directory on the `glade <https://www2.cisl.ucar.edu/resources/storage-and-file-systems/glade-file-spaces>`_ filesystems:

.. code-block:: bash

    cd /glade/work/<username>
    mkdir jedi/build; cd jedi/build

If you choose the :code:`jedi/gnu-openmpi` module, you can proceed run :code:`ecbuild` as you would on most other systems:

.. code-block:: bash

   ecbuild <path-to-bundle>
   make update
   make -j4

.. warning::

   Please do not use too many threads to speed up the compilation, Casper system administrator might terminate your login node.

However, if you choose to compile with the :code:`jedi/intel-impi` module you must use a toolchain.  This is required in order enable C++14 and to link to the proper supporting libraries.

First clone the :code:`jedi-cmake` repository:

.. code-block:: bash

   git clone git@github.com:jcsda/jedi-cmake.git

Then pass this toolchain to :code:`ecbuild`:

.. code-block:: bash

   ecbuild --toolchain=<path-to-jedi-cmake>/jedi-cmake/cmake/Toolchains/jcsda-Casper-Intel.cmake <path-to-bundle>

.. note::

   If you cloned the ``jedi-cmake`` repository as part of building a jedi bundle, then the name of the repository may be ``jedicmake`` instead of ``jedi-cmake``.

The system configuration on Casper will not allow you to run mpi jobs from the login node.  If you try to run :code:`ctest` from here, the mpi tests will fail.  To run the jedi unit tests you will have to either submit a batch job or request an interactive session with :code:`execcasper`. Invoking it without an argument will start an interactive shell on the *first available HTC node*. The default wall-clock time is 6 hours. To use another type of node, include a `select` statement specifying the resources you need. The :code:`execcasper` command accepts all ``PBS`` flags and resource specifications as detailed by ``man qsub``.

The following is a sample batch script to run the unit tests for ``ufo-bundle``.  Note that some ctests require up to 6 MPI tasks so requesting 6 cores should be sufficient.

.. code-block:: bash

    #!/bin/bash
    #PBS -N ctest-ufo-gnu
    #PBS -A <project-code>
    #PBS -l walltime=00:20:00
    #PBS -l select=1:ncpus=24:mpiprocs=24
    #PBS -q casper
    #PBS -j oe
    #PBS -k eod
    #PBS -m abe
    #PBS -M <your-email>

    source source /etc/profile.d/modules.sh
    module purge
    export JEDI_OPT=/glade/work/jedipara/casper/opt/modules
    module use $JEDI_OPT/modulefiles/core
    module load jedi/gnu-openmpi
    module list

    # cd to your build directory.  Make sure that these binaries were built
    # with the same module that is loaded above, in this case jedi/intel-impi

    cd <build-directory>

    # now run ctest
    ctest -E get_

S4
--

S4 is the **Satellite Simulations and Data Assimilation Studies** supercomputer located at the University of Wisconsin-Madison's Space Science and Engineering Center.

The S4 system currently only supports Intel compilers.  Furthermore, S4 uses the `slurm <https://slurm.schedmd.com/>`_ task manager for parallel mpi jobs.  Though some slurm implementations allow you to use the usual mpi job scripts :code:`mpirun` or :code:`mpiexec`, these may not function properly on S4.  Instead, you are advised to use the slurm run script :code:`srun`.

Once logged into S4, you must then log into s4-submit to load the spack-stack modules to build and run JEDI.

.. code-block:: bash

   ssh -Y s4-submit

The following bash shell commands are necessary to access the installed spack-stack modules (substitute equivalent csh shell commands as appropriate):

.. code-block:: bash

   module purge
   module use /data/prod/jedi/spack-stack/modulefiles
   module load miniconda/3.9.12
   module load ecflow/5.8.4

For ``spack-stack-1.1.0`` with Intel, load the following modules after loading miniconda and ecflow:

.. code-block:: bash

   module use /data/prod/jedi/spack-stack/spack-stack-v1/envs/skylab-2.0.0-intel-2021.5.0/install/modulefiles/Core
   module load stack-intel/2021.5.0
   module load stack-intel-oneapi-mpi/2021.5.0
   module load stack-python/3.9.12
   module unuse /opt/apps/modulefiles/Compiler/intel/non-default/22
   module unuse /opt/apps/modulefiles/Compiler/intel/22
   module available

Note the two ``module unuse`` statements, that need to be run after the stack metamodules are loaded. Loading the Intel compiler meta module loads the Intel compiler module provided by the sysadmins, which adds those two directories to the module path. These contain duplicate libraries that are not compatible with our stack, such as ``hdf4``. Proceed with loading the appropriate modules for your application, for example for the ``skylab-2.0`` release:

.. code-block:: bash

   module load jedi-fv3-env/1.0.0
   module load jedi-ewok-env/1.0.0
   module load soca-env/1.0.0
   module load sp/2.3.3

When using ``ecbuild``, use ``cmake -DCMAKE_CROSSCOMPILING_EMULATOR="/usr/bin/srun;-n;1" -DMPIEXEC_EXECUTABLE="/usr/bin/srun" -DMPIEXEC_NUMPROC_FLAG="-n" PATH_TO_SOURCE``. After building, you will want to run the ``get`` tests from the login node to download the test data:

.. code-block:: bash

    ctest -R get_

You can run the remaining tests from the login node, because ``srun`` will dispatch them on a compute node.  You can also run them interactively on a compute node after running

.. code-block:: bash

    salloc --nodes=1 --time=30 -I

or you can submit a batch script to the queue through ``sbatch``. Here is a sample slurm batch script:

.. code-block:: bash

   #!/usr/bin/bash
   #SBATCH --job-name=<name>
   #SBATCH --nodes=1
   #SBATCH --cpus-per-task=1
   #SBATCH --time=0:10:00
   #SBATCH --mail-user=<email-address>

   # Insert the module purge and load statements in here

   export SLURM_EXPORT_ENV=ALL
   export HDF5_USE_FILE_LOCKING=FALSE

   cd <path-to-bundle-build-directory>
   ctest -E get_

   exit 0

Note that the options specified with ``#SBATCH`` include the number of nodes but not the number of tasks needed.  This is most appropriate for running ``ctest`` because some tests require a different number of MPI tasks than others. 

Note that the options specified with ``#SBATCH`` include the number of nodes but not the number of tasks needed.  This is most appropriate for running ``ctest`` because some tests require a different number of MPI tasks than others.  However, if you run an application individually, you should specify ``#SBATCH --ntasks <number>`` instead of ``#SBATCH --nodes=<number>``, as shown in the following example.  The slurm job scheduler will properly determine how many nodes your job requires. Specifying ``--ntasks`` instead of ``--nodes`` in the ``#SBATCH`` header commands will mandate that your computing allocation will only be charged for what you use.  This is preferable for more computationally intensive jobs.

.. code-block:: bash

   #!/usr/bin/bash
   #SBATCH --job-name=<name>
   #SBATCH --ntasks=4
   #SBATCH --cpus-per-task=1
   #SBATCH --time=0:10:00
   #SBATCH --mail-user=<email-address>

   source /etc/bashrc

   # Insert the module purge and load statements in here

   ulimit -s unlimited
   ulimit -v unlimited

   export SLURM_EXPORT_ENV=ALL
   export HDF5_USE_FILE_LOCKING=FALSE

   # make sure the number of tasks it requires matches the SBATCH --ntasks specification above
   cd <path-to-bundle-build-directory>
   # Note that --ntasks=4 below is not needed in this case - srun will use what's in the SBATCH line above
   srun --ntasks=4 --cpu_bind=core --distribution=block:block test_ufo_radiosonde_opr testinput/radiosonde.yaml

   exit 0

.. note::
   JEDI applications (like most NWP applications) require a decent amount of memory, in which case asking for just a fraction of a node may fail with out of memory errors. This can be avoided by asking for an entire node (or, for larger jobs, more nodes) and running with fewer MPI tasks than each node provides by using ``#SBATCH --nodes=1`` and ``srun --ntasks=4``, for example.

After submitting the batch script with :code:`sbatch name_of_script`, you can monitor your jobs with these commands:

.. code-block:: bash

	  sbatch <batch-script>
	  squeue -u <your-user-name>

You can delete jobs with the :code:`scancel` command.  For further information please consult `the S4 user documentation <https://groups.ssec.wisc.edu/groups/S4/>`_.

AWS AMIs
--------
For more information about using Amazon Web Services please see :doc:`JEDI on AWS <./cloud/index>`.

As part of this release, two Amazon Media Images (AMIs) are available that have the necessary `spack-stack-1.1.0` environment
for `skylab-2.0.0` pre-installed. For more information on how to find these AMIs,
refer to https://spack-stack.readthedocs.io/en/spack-stack-1.1.0/Platforms.html#amazon-web-services-ubuntu-20-04.
