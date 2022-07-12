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
   module use module use /work/noaa/da/jedipara/spack-stack/modulefiles
   module load miniconda/3.9.7
   module load ecflow/5.8.4

For ``spack-stack-1.0.1`` with Intel, load the following modules after loading miniconda and ecflow:

.. code-block:: bash

   module use /work/noaa/da/role-da/spack-stack/spack-stack-v1/envs/skylab-1.0.0-intel-2022.0.2/install/modulefiles/Core
   module load stack-intel/2022.0.2
   module load stack-intel-oneapi-mpi/2021.5.1
   module load stack-python/3.9.7
   module available

For ``spack-stack-1.0.1`` with GNU, load the following modules after loading miniconda and ecflow:

.. code-block:: bash

   module use /work/noaa/da/role-da/spack-stack/spack-stack-v1/envs/skylab-1.0.0-gnu-10.2.0-openmpi-4.0.4/install/modulefiles/Core
   module load stack-gcc/10.2.0
   module load stack-openmpi/4.0.4
   module load stack-python/3.9.7
   module available

For both Intel and GNU, proceed with loading the appropriate modules for your application, for example for the ``skylab-1.0`` release:

.. code-block:: bash

   module load jedi-fv3-env/1.0.0
   module load jedi-ewok-env/1.0.0
   module load nco/5.0.6

Orion uses the `slurm <https://slurm.schedmd.com/>`_ task manager for parallel mpi jobs.  Though some slurm implementations allow you to use the usual mpi job scripts :code:`mpirun` or :code:`mpiexec`, these may not function properly on orion. Instead, you are advised to use the slurm run script :code:`srun`; an appropriate ``jedi-cmake`` toolchain is available to set this up: Pass the following toolchain to :code:`ecbuild`, and use multiple threads to speed up the compilation:

.. code-block:: bash

    git clone https://github.com/jcsda/<jedi-bundle>
    mkdir -p build; cd build
    ecbuild --toolchain=${$jedi_cmake_ROOT}/share/jedicmake/Toolchains/jcsda-Orion-Intel.cmake <path-to-bundle>
    make -j4

Alternatively, you can specify the MPI executable directly on the command line:

.. code-block:: bash

   ecbuild -DMPIEXEC_EXECUTABLE=/opt/slurm/bin/srun -DMPIEXEC_NUMPROC_FLAG="-n" <path-to-bundle>
   make -j4

Note that specifying :code:`srun` as the MPI executable is really only necessary for the ctests.  If you run an application directly (outside of ctest), you may simply use :code:`srun`.

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

Note that the options specified with ``#SBATCH`` include the number of nodes but not the number of tasks needed.  This is most appropriate for running ``ctest`` because some tests require a different number of MPI tasks than others.  However, if you run an application individually, you should specify ``#SBATCH --ntasks <number>`` instead of ``#SBATCH --nodes=<number>``, as shown in the following example.  The slurm job scheduler will properly determine how many nodes your job requires. Specifying ``--ntasks`` instead of ``--nodes`` in the ``#SBATCH`` header commands will mandate that your computing allocation will only be charged for what you use.  This is preferable for more computationally intensive jobs:

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
   srun --ntasks=4 --cpu_bind=core --distribution=block:block test_ufo_radiosonde_opr testinput/radiosonde.yaml

   exit 0

Submit and monitor your jobs with these commands

.. code-block:: bash

	  sbatch <batch-script>
	  squeue -u <your-user-name>

You can delete jobs with the :code:`scancel` command.  For further information please consult `the Orion Cluster Computing Basics documentation <https://intranet.hpc.msstate.edu/helpdesk/resource-docs/clusters_getting_started.php>`_.


Discover
--------

`Discover <https://www.nccs.nasa.gov/systems/discover>`_ is 90,000 core supercomputing cluster capable of delivering 3.5 petaflops of high-performance computing for Earth system applications from weather to seasonal to climate predictions.

The following bash shell commands are necessary to access the installed spack-stack modules (substitute equivalent csh shell commands as appropriate):


.. code-block:: bash

   module purge
   module use /discover/swdev/jcsda/spack-stack/modulefiles
   module load miniconda/3.9.7
   module load ecflow/5.8.4

For ``spack-stack-1.0.1`` with Intel, load the following modules after loading miniconda and ecflow:

.. code-block:: bash

   ulimit -s unlimited
   module use /discover/swdev/jcsda/spack-stack/spack-stack-v1/envs/skylab-1.0.0-intel-2022.0.1/install/modulefiles/Core
   module load stack-intel/2022.0.1
   module load stack-intel-oneapi-mpi/2021.5.0
   module load stack-python/3.9.7
   module available

For ``spack-stack-1.0.1`` with GNU, load the following modules after loading miniconda and ecflow:

.. code-block:: bash

   ulimit -s unlimited
   module use /gpfsm/dswdev/jcsda/spack-stack/spack-stack-v1/envs/skylab-1.0.0-gnu-10.1.0/install/modulefiles/Core
   module load stack-gcc/10.1.0
   module load stack-intel-oneapi-mpi/2021.4.0
   module load stack-python/3.9.7
   module available

For both Intel and GNU, proceed with loading the appropriate modules for your application, for example for the ``skylab-1.0`` release:

.. code-block:: bash

   module load jedi-fv3-env/1.0.0
   module load jedi-ewok-env/1.0.0
   module load nco/5.0.6

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

.. note:: spack-stack is not yet available on Hera. The instructions below refer to the previous jedi-stack modules that will be replaced with spack-stack modules over the next few weeks.

Hera is an HPC system located in NOAA's NESCC facility in Fairmont, WV. The following bash shell commands are necessary to access the installed JEDI modules:

.. code-block:: bash

   export JEDI_OPT=/scratch1/NCEPDEV/jcsda/jedipara/opt/modules
   module use $JEDI_OPT/modulefiles/core

If you use tcsh, use these commands:

.. code-block:: bash

   setenv JEDI_OPT=/scratch1/NCEPDEV/jcsda/jedipara/opt/modules
   module use $JEDI_OPT/modulefiles/core

If you wish to use the intel compiler suite, the preferred jedi modules are those from 2020.2:

.. code-block:: bash

   module purge
   module load jedi/intel-impi/2020.2

If you wish to use the gnu compiler suite with the openmpi library, enter:

.. code-block:: bash

   module purge
   module load jedi/gnu-openmpi

It is not required, but if you wish to use version 18 of the intel compilers and mpi libraries, we also maintain modules for that.  To use the intel 18 modules, enter the following commands **in addition to** the corresponding ``JEDI_OPT`` commands described above:

.. code-block:: bash

   # replace with setenv if you use tcsh, as above
   export JEDI_OPT2=/home/role.jedipara/opt/modules
   module use $JEDI_OPT2/modulefiles/core
   module purge
   module load jedi/intel-impi/18

It is important to note that the JEDI modules may conflict with other modules provided by other developers on
Hera, particularly for installations of HDF5 and NetCDF. The Hera sysadmins have provided their own builds of
HDF5 and NetCDF (in ``/apps/modules/modulefamilies/intel``) and netcdf-hdf5parallel
(in ``/apps/modules/modulefamilies/intel_impi``). Unfortunately, these libraries have incompatible versions and compile-time
options that conflict with the JEDI components. For a JEDI-related project, use our modules.
If modules have been mixed, you can unload all modules and start over with ``module purge``.

Also, it is recommended that you specify :code:`srun` as your mpi process manager when building, like so:

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

.. note:: spack-stack is not yet available on Cheyenne. The instructions below refer to the previous jedi-stack modules that will be replaced with spack-stack modules over the next few weeks.

`Cheyenne <https://www2.cisl.ucar.edu/resources/computational-systems/cheyenne/cheyenne>`_ is a 5.34-petaflops, high-performance computer built for NCAR by SGI. On Cheyenne, users can access the installed jedi modules by first entering

.. code-block:: bash

   module purge
   export JEDI_OPT=/glade/work/jedipara/cheyenne/opt/modules
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

   Please do not use too many threads to speed up the compilation, Cheyenne system administrator might terminate your login node.

However, if you choose to compile with the :code:`jedi/intel-impi` module you must use a toolchain.  This is required in order enable C++14 and to link to the proper supporting libraries.

First clone the :code:`jedi-cmake` repository:

.. code-block:: bash

   git clone git@github.com:jcsda/jedi-cmake.git

Then pass this toolchain to :code:`ecbuild`:

.. code-block:: bash

   ecbuild --toolchain=<path-to-jedi-cmake>/jedi-cmake/cmake/Toolchains/jcsda-Cheyenne-Intel.cmake <path-to-bundle>

.. note::

   If you cloned the ``jedi-cmake`` repository as part of building a jedi bundle, then the name of the repository may be ``jedicmake`` instead of ``jedi-cmake``.
   In all subsequent ``ecbuild`` commands you must continue to pass the toolchain file.

The system configuration on Cheyenne will not allow you to run mpi jobs from the login node.  If you try to run :code:`ctest` from here, the mpi tests will fail.  To run the jedi unit tests you will have to either submit a batch job or request an interactive session with :code:`qsub -I`.  The following is a sample batch script to run the unit tests for ``ufo-bundle``.  Note that some ctests require up to 6 MPI tasks so requesting 6 cores should be sufficient.

.. code-block:: bash

    #!/bin/bash
    #PBS -N ctest-ufo-gnu
    #PBS -A <account-number>
    #PBS -l walltime=00:20:00
    #PBS -l select=1:ncpus=6:mpiprocs=6
    #PBS -q regular
    #PBS -j oe
    #PBS -k eod
    #PBS -m abe
    #PBS -M <your-email>

    source source /etc/profile.d/modules.sh
    module purge
    export JEDI_OPT=/glade/work/jedipara/cheyenne/opt/modules
    module use $JEDI_OPT/modulefiles/core
    module load jedi/gnu-openmpi
    module list

    # cd to your build directory.  Make sure that these binaries were built
    # with the same module that is loaded above, in this case jedi/intel-impi

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
    #PBS -l select=1:ncpus=6:mpiprocs=6
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

.. note:: spack-stack is not yet available on S4. The instructions below refer to the previous jedi-stack modules that will be replaced with spack-stack modules over the next few weeks.

S4 is the **Satellite Simulations and Data Assimilation Studies** supercomputer located at the University of Wisconsin-Madison's Space Science and Engineering Center.

The S4 system currently only supports intel compilers.  Furthermore, S4 uses the `slurm <https://slurm.schedmd.com/>`_ task manager for parallel mpi jobs.  Though some slurm implementations allow you to use the usual mpi job scripts :code:`mpirun` or :code:`mpiexec`, these may not function properly on S4.  Instead, you are advised to use the slurm run script :code:`srun`.

To load the JEDI intel module you can use the following commands (as on other systems, you can put the first two lines in your :code:`~/.bashrc` file for convenience):

.. code-block:: bash

   export JEDI_OPT=/data/prod/jedi/opt/modules
   module use $JEDI_OPT/modulefiles/core
   module load jedi/intel-impi

The recommended way to compile JEDI on S4 is to first clone the :code:`jedi-cmake` repository, which contains an S4 toolchain:

.. code-block:: bash

   git clone git@github.com:jcsda/jedi-cmake.git

Then pass this toolchain to :code:`ecbuild`:

.. code-block:: bash

   ecbuild --toolchain=<path-to-jedi-cmake>/jedi-cmake/cmake/Toolchains/jcsda-S4-Intel.cmake <path-to-bundle>

.. note::

   If you cloned the ``jedi-cmake`` repository as part of building a jedi bundle, then the name of the repository may be ``jedicmake`` instead of ``jedi-cmake``.

Alternatively, you can specify the MPI executable directly on the command line:

.. code-block:: bash

   ecbuild -DMPIEXEC_EXECUTABLE=/usr/bin/srun -DMPIEXEC_NUMPROC_FLAG="-n" <path-to-bundle>
   make -j4

Note that this specifying :code:`srun` as the MPI executable is only really necessary for the ctests.  If you run an application directly (outside of ctest), you can just use :code:`srun`.

Here is a sample slurm batch script for running ctest.

.. code-block:: bash

   #!/usr/bin/bash
   #SBATCH --job-name=<name>
   #SBATCH --nodes=1
   #SBATCH --cpus-per-task=1
   #SBATCH --time=0:10:00
   #SBATCH --mail-user=<email-address>

   source /etc/bashrc
   module purge
   export JEDI_OPT=/data/prod/jedi/opt/modules
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

.. code-block:: bash

   #!/usr/bin/bash
   #SBATCH --job-name=<name>
   #SBATCH --ntasks=4
   #SBATCH --cpus-per-task=1
   #SBATCH --time=0:10:00
   #SBATCH --mail-user=<email-address>

   source /etc/bashrc
   module purge
   export JEDI_OPT=/data/prod/jedi/opt/modules
   module use $JEDI_OPT/modulefiles/core
   module load jedi/intel-impi
   module list
   ulimit -s unlimited

   export SLURM_EXPORT_ENV=ALL
   export HDF5_USE_FILE_LOCKING=FALSE

   # make sure the number of tasks it requires matches the SBATCH --ntasks specification above
   cd <path-to-bundle-build-directory>/test/ufo
   srun --ntasks=4 --cpu_bind=core --distribution=block:block test_ufo_radiosonde_opr testinput/radiosonde.yaml

   exit 0

Then you can submit and monitor your jobs with these commands

.. code-block:: bash

	  sbatch <batch-script>
	  squeue -u <your-user-name>

You can delete jobs with the :code:`scancel` command.  For further information please consult `the S4 user documentation <https://groups.ssec.wisc.edu/groups/S4/>`_.

AWS AMIs
--------
For more information about using Amazon Web Services please see :doc:`JEDI on AWS <./cloud/index>`.

As part of this release, two Amazon Media Images (AMIs) are available that have the necessary `spack-stack-1.0.1` environment
for `skylab-1.0.0` pre-installed. For more information on how to find these AMIs,
refer to https://spack-stack.readthedocs.io/en/spack-stack-1.0.1/Platforms.html#amazon-web-services-ubuntu-20-04.
