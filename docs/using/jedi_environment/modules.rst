.. _top-modules:

Using spack-stack modules to build and run JEDI
===============================================

The instructions in this section are specific to the use of spack-stack environment modules (``lmod/lua`` or ``tcl/tk``) for building and running JEDI applications. For general information on using spack-stack to build and run software, see the `spack-stack documentation <https://spack-stack.readthedocs.io/en/1.4.0>`_.

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


General Tips for HPC Systems
----------------------------

Many HPC systems do not allow you to run MPI jobs from the login nodes. So, after building JEDI, you'll have to run the tests either in batch mode through a job submission program such as :code:`slurm` via :code:`sbatch` directives, or by accessing a batch compute node interactively through a program such as :code:`salloc`. Often these batch nodes do not have access to the internet; after you build JEDI, you may need to run the following command from a login node:

.. code-block:: bash

    ctest -R get_

This runs several tests. The purpose of these tests is to download data files from the cloud that are then used by many of the other tests. If the :code:`get_*` tests are successful, then the data was downloaded successfully and you can proceed to run the remainder of the tests in batch using :code:`sbatch`, :code:`salloc`, or the equivalent process management command on your system.


Orion
-----

Orion is an HPC system located at Mississippi State University for the purpose of furthering NOAA’s scientific research and collaboration.

Follow the instructions in https://spack-stack.readthedocs.io/en/1.4.0/PreConfiguredSites.html#msu-orion to load the basic spack-stack modules for Intel or GNU. Proceed with loading the appropriate modules for your application, for example for the ``skylab-4.0`` release:

.. code-block:: bash

   module load jedi-fv3-env/unified-dev
   module load ewok-env/unified-dev
   module load soca-env/unified-dev


After loading the appropiate modules, you need to clone the jedi-bundle, create a build directory, configure, and build the bundle.

.. code-block:: bash

    git clone https://github.com/jcsda/<jedi-bundle>
    mkdir -p build; cd build
    ecbuild <path-to-bundle>
    make -j4

The next step is to run ctests. We do not recommand running the ctests on login nodes because of the computational requirements of these tests. Instead you can submit ctests as a batch job or use an interactive node. Here is a sample `slurm <https://slurm.schedmd.com/>`_ batch script for running ctest. Note that you will need to add appropriate :code:`#SBATCH` directives for specifying a computing account, quality of service, job partition, and so on; please consult `the Orion Usage and Guidelines documentation <https://intranet.hpc.msstate.edu/helpdesk/resource-docs/cluster_guide.php#orion-use>`_.

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

An alternative to using the batch script is to request an interactive session on Orion and run the ctests there. To request an interactive session you can run:

.. code-block:: bash

   salloc -N1 -n 24 -A <account> --qos=batch --partition=orion --time=480 -I

Make sure you use the correct account number. This command requests for one node with 24 MPI tasks.


Discover
--------

`Discover <https://www.nccs.nasa.gov/systems/discover>`_ is 90,000 core supercomputing cluster capable of delivering 3.5 petaflops of high-performance computing for Earth system applications from weather to seasonal to climate predictions.

Follow the instructions in https://spack-stack.readthedocs.io/en/1.4.0/PreConfiguredSites.html#nasa-discover to load the basic spack-stack modules for Intel or GNU. Proceed with loading the appropriate modules for your application, for example for the ``skylab-4.0`` release:

.. code-block:: bash

   module load jedi-fv3-env/unified-dev
   module load ewok-env/unified-dev
   module load soca-env/unified-dev

Note that the existing toolchain for Discover in ``jedi-cmake`` is outdated and cannot be used. Also, different methods are needed for Intel and GNU.

For Intel, when using ``ecbuild``, use ``ecbuild -DMPIEXEC_EXECUTABLE="/usr/local/intel/oneapi/2021/mpi/2021.5.0/bin/mpirun"`` ``-DMPIEXEC_NUMPROC_FLAG="-np"``. After building, you will want to run the ``get_`` tests from the login node to download the test data:

.. code-block:: bash

    ctest -R get_

To run the remaining tests, particularly those that require MPI, you'll need to acquire a compute node.  You can do this interactively with

.. code-block:: bash

    salloc --nodes=1 --time=30 --constraint="cas"

Or, you can submit a batch script to the queue through ``sbatch`` as described in the Orion instructions above.

For GNU, when using ``ecbuild``, use ``ecbuild -DMPIEXEC_EXECUTABLE="/usr/bin/srun" -DMPIEXEC_NUMPROC_FLAG="-n"``. Then run all tests directly from the login node.

Discover is a heterogeneous system with different CPU architectures and operating systems on the login and compute nodes. The default login node is of the newest Intel Cascade Lake generation, and we recommend requesting the same node type when running interactive jobs or batch jobs, which is accomplished by the argument ``--constraint="cas"``. If older node types are used (Skylake, Haswell), users may see warnings like "no version information available" for certain libraries in the default location ``/usr/lib64``. For more information, see https://www.nccs.nasa.gov/nccs-users/instructional/using-slurm/best-practices.

Hera
-----

Hera is an HPC system located in NOAA's NESCC facility in Fairmont, WV. The following bash shell commands are necessary to access the installed spack-stack modules (substitute equivalent csh shell commands as appropriate):

Follow the instructions in https://spack-stack.readthedocs.io/en/1.4.0/PreConfiguredSites.html#noaa-rdhpcs-hera to load the basic spack-stack modules for Intel or GNU. Proceed with loading the appropriate modules for your application, for example for the ``skylab-4.0`` release:

.. code-block:: bash

   module load jedi-fv3-env/unified-dev
   module load ewok-env/unified-dev
   module load soca-env/unified-dev

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

Follow the instructions in https://spack-stack.readthedocs.io/en/1.4.0/PreConfiguredSites.html#ncar-wyoming-cheyenne to load the basic spack-stack modules for Intel or GNU. Proceed with loading the appropriate modules for your application, for example for the ``skylab-4.0`` release:

.. code-block:: bash

   module load jedi-fv3-env/unified-dev
   module load ewok-env/unified-dev
   module load soca-env/unified-dev

Because of space limitations on your home directory, it's a good idea to build your code on the `glade <https://www2.cisl.ucar.edu/resources/storage-and-file-systems/glade-file-spaces>`_ filesystems (`work` or `scratch`):

.. warning::

   Please do not use too many threads to speed up the compilation, Cheyenne system administrator might terminate your login node.

The system configuration on Cheyenne will not allow you to run mpi jobs from the login node.  If you try to run :code:`ctest` from here, the mpi tests will fail.  To run the jedi unit tests you will have to either submit a batch job or request an interactive session with :code:`qsub -I`.  The following is a sample batch script to run the unit tests for ``ufo-bundle``.  Note that some ctests require up to 24 MPI tasks.

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

The `Casper <https://www2.cisl.ucar.edu/resources/computational-systems/casper>`_ cluster is a heterogeneous system of specialized data analysis and visualization resources, large-memory, multi-GPU nodes, and high-throughput computing nodes.

Follow the instructions in https://spack-stack.readthedocs.io/en/1.4.0/PreConfiguredSites.html#ncar-wyoming-casper to load the basic spack-stack modules for Intel. Proceed with loading the appropriate modules for your application, for example for the ``skylab-4.0`` release:

.. code-block:: bash

   module load jedi-fv3-env/unified-dev
   module load ewok-env/unified-dev
   module load soca-env/unified-dev

Because of space limitations on your home directory, it's a good idea to locate your build directory on the `glade <https://www2.cisl.ucar.edu/resources/storage-and-file-systems/glade-file-spaces>`_ filesystems:

.. code-block:: bash

    cd /glade/work/<username>
    mkdir jedi/build; cd jedi/build

.. warning::

   Please do not use too many threads to speed up the compilation, Casper system administrator might terminate your login node.

The system configuration on Casper will not allow you to run mpi jobs from the login node. If you try to run :code:`ctest` from here, the mpi tests will fail. To run the jedi unit tests you will have to either submit a batch job or request an interactive session with :code:`execcasper`. Invoking it without an argument will start an interactive shell on the *first available HTC node*. The default wall-clock time is 6 hours. To use another type of node, include a `select` statement specifying the resources you need. The :code:`execcasper` command accepts all ``PBS`` flags and resource specifications as detailed by ``man qsub``. The following is a sample batch script to run the unit tests for ``ufo-bundle``. Note that some ctests require up to 24 MPI tasks.

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

    # Insert the appropriate module purge and load commands here

    # cd to your build directory.  Make sure that these binaries were built
    # with the same module that is loaded above

    cd <build-directory>

    # now run ctest
    ctest -E get_

S4
--

S4 is the **Satellite Simulations and Data Assimilation Studies** supercomputer located at the University of Wisconsin-Madison's Space Science and Engineering Center.

Although S4 uses the `slurm <https://slurm.schedmd.com/>`_ task manager for parallel mpi jobs, users are advised to use :code:`mpirun` or :code:`mpiexec` instead of the slurm run script :code:`srun` due to problems with the mpich library with slurm.

Once logged into S4, you must then log into s4-submit to load the spack-stack modules to build and run JEDI.

.. code-block:: bash

   ssh -Y s4-submit

Follow the instructions in https://spack-stack.readthedocs.io/en/1.4.0/PreConfiguredSites.html#uw-univ-of-wisconsin-s4 to load the basic spack-stack modules for Intel or GNU. Proceed with loading the appropriate modules for your application, for example for the ``skylab-4.0`` release:

.. code-block:: bash

   module load jedi-fv3-env/unified-dev
   module load ewok-env/unified-dev
   module load soca-env/unified-dev

For Intel and GNU, use

.. code-block:: bash

   ecbuild PATH_TO_SOURCE

After building, you will want to run the ``get`` tests from the login node to download the test data:

.. code-block:: bash

    ctest -R get_

It is recommended to run the remaining tests interactively on a compute node using

.. code-block:: bash

    salloc --nodes=1 --time=30 -I
    # Required for Intel so that serial jobs of MPI-enabled executables
    # run without having to call them through mpiexec/mpirun
    unset "${!SLURM@}"

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
    # Required for Intel so that serial jobs of MPI-enabled executables
    # run without having to call them through mpiexec/mpirun
    unset "${!SLURM@}"

   cd <path-to-bundle-build-directory>
   ctest -E get_

   exit 0

Note that the options specified with ``#SBATCH`` above include the number of nodes but not the number of tasks needed.  This is most appropriate for running ``ctest`` because some tests require a different number of MPI tasks than others. However, if you run an application individually, you should specify ``#SBATCH --ntasks <number>`` instead of ``#SBATCH --nodes=<number>``, as shown in the following example.  The slurm job scheduler will properly determine how many nodes your job requires. Specifying ``--ntasks`` instead of ``--nodes`` in the ``#SBATCH`` header commands will mandate that your computing allocation will only be charged for what you use.  This is preferable for more computationally intensive jobs.

.. code-block:: bash

   #!/usr/bin/bash
   #SBATCH --job-name=<name>
   #SBATCH --ntasks=4
   #SBATCH --cpus-per-task=1
   #SBATCH --time=0:10:00
   #SBATCH --mail-user=<email-address>

   source /etc/bashrc

   # Insert the module purge and load statements here

   ulimit -s unlimited
   ulimit -v unlimited

   export SLURM_EXPORT_ENV=ALL
   export HDF5_USE_FILE_LOCKING=FALSE

   # make sure the number of tasks it requires matches the SBATCH --ntasks specification above
   cd <path-to-bundle-build-directory>
   mpirun -np 4 test_ufo_radiosonde_opr testinput/radiosonde.yaml

   exit 0

.. note::
   JEDI applications (like most NWP applications) require a decent amount of memory, in which case asking for just a fraction of a node may fail with out-of-memory errors. This can be avoided by asking for an entire node (or, for larger jobs, more nodes) and running with fewer MPI tasks than each node provides by using ``#SBATCH --nodes=1`` and ``srun --ntasks=4``, for example.

After submitting the batch script with :code:`sbatch name_of_script`, you can monitor your jobs with these commands:

.. code-block:: bash

	  sbatch <batch-script>
	  squeue -u <your-user-name>

You can delete jobs with the :code:`scancel` command.  For further information please consult `the S4 user documentation <https://groups.ssec.wisc.edu/groups/S4/>`_.

Narwhal
-------

Narwhal is an HPE Cray EX system located at the Navy DSRC. It has 2,176 standard compute nodes (AMD 7H12 Rome, 128 cores, 238 GB) and 12 large-memory nodes (995 GB). It has 590 TB of memory and is rated at 12.8 peak PFLOPS.

Follow the instructions in https://spack-stack.readthedocs.io/en/1.4.0/PreConfiguredSites.html#navy-hpcmp-narwhal to load the basic spack-stack modules for Intel or GNU. Proceed with loading the appropriate modules for your application, for example for the ``skylab-4.0`` release:

.. code-block:: bash

   module load jedi-fv3-env/unified-dev
   module load ewok-env/unified-dev
   module load soca-env/unified-dev

Because of space limitations on your home directory, it's a good idea to build your code on Narwhal ``$WORKDIR: /p/work1/$USER``.

Clone the jedi bundle:

.. code-block:: bash

   git clone https://github.com/JCSDA/jedi-bundle.git jedi-bundle

For Intel and GNU, configure with:

.. code-block:: bash

   ecbuild -DMPIEXEC_EXECUTABLE=/opt/cray/pe/pals/1.2.2/bin/aprun -DMPIEXEC_NUMPROC_FLAG="-n" <path-to-bundle-source-directory>

Compile with:

.. code-block:: bash

   make -j 6

Download the additional data (CRTM coefficients, etc.) from a login node with:

.. code-block:: bash

   cd <path-to-bundle-build-directory>
   ctest -E get_ 2>&1 |tee ctest_wget.out

Request a full (compute) node in interactive mode:

.. code-block:: bash

   qsub -A <project_number> -q HIE -l select=1:ncpus=124:mpiprocs=124 -l walltime=06:00:00 -I

Reload the modules as described above, go to the bundle build directory and run the tests:

.. code-block:: bash

   <reload the modules>
   cd <path-to-bundle-build-directory>
   ctest -E get_ 2>&1 |tee ctest.log


AWS AMIs
--------
For more information about using Amazon Web Services please see :doc:`JEDI on AWS <./cloud/index>`.

As part of this release, an Amazon Media Image (AMI) is available that has the necessary `spack-stack-1.4.0` environment for `skylab-5.0.0` pre-installed. For more information on how to find this AMI, refer to https://spack-stack.readthedocs.io/en/1.4.0/PreConfiguredSites.html.

