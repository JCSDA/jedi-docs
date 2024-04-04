.. _hpc_users_guide:

Skylab HPC users guide
======================

This guide contains system-specific information as well as tips and tricks for running
skylab on supported HPC systems.

General Tips for HPC Systems
----------------------------

Many HPC systems do not allow you to run MPI jobs from the login nodes. So, after building JEDI, you'll have to run the tests either in batch mode through a job submission program such as :code:`slurm` via the :code:`sbatch` command, or by accessing a compute node interactively through a command like :code:`salloc`. An advantage of submitting a job 'to the queue' through the :code:`slurm` scheduler is that you can then logout of the system, or continue to use your terminal after sumbitting your script while the tests run. The test results will be written into a :code:`slurm-<jobNumber>` file which will appear in which ever directory from which you submitted the job.

An alternative to using the batch script is to request an interactive session and run the :code:`ctests` there. After logging into the interactive session, reload the modules (:ref:`top-modules`), go to the bundle build directory and run the tests:

.. code-block:: bash

   <reload the modules>
   cd <path-to-bundle-build-directory>
   ctest 2>&1 |tee ctest.log

.. _sbatch:

SBATCH
^^^^^^

Here is a sample `slurm <https://slurm.schedmd.com/>`_ batch script for running ctest. Note that you will need to add appropriate :code:`#SBATCH` directives for specifying a computing account, quality of service, job partition, and so on.

HPCs using SBATCH: Orion, Discover, Hera, and S4

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

Note that the options specified with ``#SBATCH`` includes the number of nodes but not the number of tasks needed.  This is most appropriate for running ``ctest`` because some tests require a different number of MPI tasks than others.  However, if you run an application individually, you should specify ``#SBATCH --ntasks <number>`` instead of ``#SBATCH --nodes=<number>``, as shown in the following example.  The slurm job scheduler will properly determine how many nodes your job requires. Specifying ``--ntasks`` instead of ``--nodes`` in the ``#SBATCH`` header commands will mandate that your computing allocation will only be charged for what you use.  This is preferable for more computationally intensive jobs.

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

You can delete jobs with the :code:`scancel` command.

.. _pbs:

PBS
^^^

PBS is another way to run batch scripts for completing ctests.

HPCs that use PBS: Derecho, Casper, and Narwhal

The following is a sample batch script to run the remaining unit tests.  Note that some ctests require up to 24 MPI tasks.

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

System Specific Information
---------------------------

.. _casperGuide:

Casper
------

The `Casper <https://arc.ucar.edu/knowledge_base/70549550>`_ cluster is a heterogeneous system of specialized data analysis and visualization resources, large-memory, multi-GPU nodes, and high-throughput computing nodes.

Because of space limitations on your home directory, it's a good idea to locate your build directory on the `glade <https://www2.cisl.ucar.edu/resources/storage-and-file-systems/glade-file-spaces>`_ filesystems:

.. code-block:: bash

    cd /glade/work/<username>
    mkdir jedi/build; cd jedi/build

.. warning::

   Please do not use too many threads to speed up the compilation, Casper system administrator might terminate your login node.

The system configuration on Casper will not allow you to run mpi jobs from the login node. If you try to run :code:`ctest` from here, the mpi tests will fail. To run the jedi unit tests you will have to either submit a batch job or request an interactive session.

To request an interactive session on Casper run :code:`execcasper`. Invoking it without an argument will start an interactive shell on the *first available HTC node*. The default wall-clock time is 6 hours. To use another type of node, include a `select` statement specifying the resources you need. The :code:`execcasper` command accepts all ``PBS`` flags and resource specifications as detailed by ``man qsub``.

Casper uses PBS and an example job submission script is given :ref:`here <pbs>`.

Casper documentation:

* `Casper guide <https://arc.ucar.edu/knowledge_base/70549550>`_

.. _derechoGuide:

Derecho
-------

`Derecho <https://arc.ucar.edu/knowledge_base/74317833>`_ is a 19.87-petaflops, high-performance computer built for NCAR and hosted at the NCAR-Wyoming Supercomputing Center.

Because of space limitations on your home directory, it's a good idea to build your code on the `glade <https://www2.cisl.ucar.edu/resources/storage-and-file-systems/glade-file-spaces>`_ filesystems (`work` or `scratch`):

.. warning::

   Please do not use too many threads to speed up the compilation, Derecho system administrator might terminate your login node.

The system configuration on Derecho will not allow you to run mpi jobs from the login node.  If you try to run :code:`ctest` from here, the mpi tests will fail. To run the jedi unit tests you will have to either submit a batch job or request an interactive session.

To request an interactive session on Derecho run :code:`qsub -I`.

Derecho uses PBS and an example job submission script is given :ref:`here <pbs>`.

Derecho documentation:

* `Derecho guide <https://arc.ucar.edu/knowledge_base/74317833>`_

.. _discoverGuide:

Discover
--------

`Discover <https://www.nccs.nasa.gov/systems/discover>`_ is 90,000 core supercomputing cluster capable of delivering 3.5 petaflops of high-performance computing for Earth system applications from weather to seasonal to climate predictions.

The "scratch" directory on Discover is in the :code:`~/NOBACKUP` file system (see the `NCCS user guide <https://www.nccs.nasa.gov/nccs-users/instructional/using-discover/file-system-storage>`_). So, build JEDI and set up your :code:`JEDI_ROOT` to a directory here.

Build jedi on the login-node (with 4 or fewer processes i.e. :code:`-j4` or less), and use the special commands for running :code:`ecbuild` on intel/GNU.

**Intel build**

For Intel, when using :code:`ecbuild`, use:

.. code-block:: bash

   ecbuild -DMPIEXEC_EXECUTABLE="/usr/local/intel/oneapi/2021/mpi/2021.5.0/bin/mpirun" -DMPIEXEC_NUMPROC_FLAG="-np"

Run the :code:`get_` ctests also on the login-node, but run the rest of the tests interactively on a compute node using the :code:`salloc` command as described in the documentation below or using :ref:`SBATCH <sbatch>`. It will take about an hour and a half to run the tests, so be sure to request at least 90 minutes for the interactive job. FYI, it will likely take a while for the request for the interactive session to be granted.

**GNU build**

For GNU, when using :code:`ecbuild`, use:

.. code-block:: bash

   ecbuild -DMPIEXEC_EXECUTABLE="/usr/bin/srun" -DMPIEXEC_NUMPROC_FLAG="-n"

Then run all ctests directly from the login node.

Discover is a heterogeneous system with different CPU architectures and operating systems on the login and compute nodes. The default login node is of the newest Intel Cascade Lake generation, and we recommend requesting the same node type when running interactive jobs or batch jobs, which is accomplished by the argument ``--constraint="cas"``. If older node types are used (Skylake, Haswell), users may see warnings like "no version information available" for certain libraries in the default location ``/usr/lib64``.

To request an interactive compute node on discover, run the following:

.. code-block:: bash

    salloc --constraint="cas" --nodes=1 --ntasks-per-node=24 --time=2:00:00

Discover uses SBATCH and an example job submission script is given :ref:`here <sbatch>`.

Discover documentation:

* `Slurm best practices on Discover <https://www.nccs.nasa.gov/nccs-users/instructional/using-slurm/best-practices>`_

* `Discover user guide <https://www.nccs.nasa.gov/nccs-users/instructional/using-discover>`_

ecflow and Discover login-nodes
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

When you log on to Discover, you will be placed onto a different login-node each time (eg, :code:`discover11`, :code:`discover12`, etc). You can't choose which login-node you get, and you cannot easily :code:`ssh` between login-nodes.

This means you will have to take a few extra steps to get your experiments to show up in the ecflow GUI properly, and you can address this in one of several ways (in all cases you will still have to manually set your :code:`ECF_PORT` environment variable):

#. (Recommended) Leave your :code:`activate.sh` script with the default of re-setting your :code:`ECF_HOST` for each new session and have an ecflow server configured on each login-node. So, when you log into a new session, you either use the server you have previously configured on that node or configure a new server if you haven't already configured one on that node. In this case, you will still have to have the same :code:`ECF_PORT` for each of the separate servers you have on different nodes (which you had to set manually as noted in the documentation). For best results, shutdown the ecflow server (:code:`ecflow_stop.sh -p $ECF_PORT`) before ending each session and logging out.

   .. note::

     With this approach, you will have several servers appear in your ecflow GUI. Jobs will run through the server running on the node you submitted the job from. Also, to help you keep track of the servers, name the server with the name of the login-node on which it is running.


#. You can start one ecflow server (with the :code:`ecflow_start.sh -p $ECF_PORT` command) on whichever login-node you are on when submitting your first experiment. For this approach, you will need to manually adjust your :code:`activate.sh` script to set your :code:`ECF_HOST` to match the login-node on which you started the server (i.e. the node you are currently on). For example:

   .. code-block:: bash

     export ECF_HOST=discover13

   .. note::

     With this approach, you will only have one server appear in your ecflow GUI. Having your :code:`ECF_HOST` hardcoded will have jobs run through the server on your original login-node, even if you submit the job from another node. This approach is not recommended since it can cause tricky-to-debug issues with environment matching, and will cause you to have to restart your ecflow server and change your :code:`activate.sh` script every time the discover login-nodes get shut down (e.g., for maintenance).

#. You can setup an SSH key pair and follow the directions at https://www.nccs.nasa.gov/nccs-users/instructional/logging-in to allow you to SSH between login-nodes.

.. _hera:

Hera
----

Hera is an HPC system located in NOAA's NESCC facility in Fairmont, WV.

It is recommended that you specify :code:`srun` as your mpi process manager when building, like so:

.. code-block:: bash

   ecbuild -DMPIEXEC_EXECUTABLE=`which srun` -DMPIEXEC_NUMPROC_FLAG="-n" <path-to-bundle>
   make -j4

To run tests with slurm and :code:`srun`, you also need to have the following environment variables defined.

.. code-block:: bash

   export SLURM_ACCOUNT=<account you can run slurm jobs under>
   export SALLOC_ACCOUNT=$SLURM_ACCOUNT
   export SBATCH_ACCOUNT=$SLURM_ACCOUNT

Hera documentation:

* `Heradoc <https://heradocs.rdhpcs.noaa.gov>`_ (only available with NOAA SSO)

.. _hercules:

Hercules
--------

Hercules is an HPC system located at Mississippi State University for the purpose of furthering NOAA’s scientific research and collaboration.

It shares a file system and log-in credentials with :ref:`orion`, so see that section (below) for more information.

Hercules documentation:

* `MSU Cluster Computing Basics documentation <https://intranet.hpc.msstate.edu/helpdesk/resource-docs/clusters_getting_started.php>`_

.. _narwhal:

Narwhal
-------

Narwhal is an HPE Cray EX system located at the Navy DSRC. It has 2,176 standard compute nodes (AMD 7H12 Rome, 128 cores, 238 GB) and 12 large-memory nodes (995 GB). It has 590 TB of memory and is rated at 12.8 peak PFLOPS.

Because of space limitations on your home directory, it's a good idea to build your code on Narwhal ``$WORKDIR: /p/work1/$USER``.

For Intel and GNU, configure with:

.. code-block:: bash

   ecbuild -DMPIEXEC_EXECUTABLE=/opt/cray/pe/pals/1.2.2/bin/aprun -DMPIEXEC_NUMPROC_FLAG="-n" <path-to-bundle-source-directory>

Request a full (compute) node in interactive mode on Narwhal run:

.. code-block:: bash

   qsub -A <project_number> -q HIE -l select=1:ncpus=124:mpiprocs=124 -l walltime=06:00:00 -I

Narwhal uses PBS and an example job submission script is shown :ref:`here <pbs>`.

Narwhal documentation:

* `Narwhal user guide <https://www.navydsrc.hpc.mil/docs/narwhalUserGuide.html>`_

.. _orion:

Orion
-----

Orion is an HPC system located at Mississippi State University for the purpose of furthering NOAA’s scientific research and collaboration.

We do not recommend running the ctests on login nodes because of the computational requirements of these tests. Instead you can submit ctests as a batch job or use an interactive node. To request an interactive session on Orion, you can run the following. Make sure you use the correct account number. This command requests for one node with 24 MPI tasks.

.. code-block:: bash

   salloc -N1 -n 24 -A <account> --qos=batch --partition=orion --time=480 -I

Orion uses SBATCH and an example job submission script is shown :ref:`here <sbatch>`.

Orion documentation:

* `MSU Cluster Computing Basics documentation <https://intranet.hpc.msstate.edu/helpdesk/resource-docs/clusters_getting_started.php>`_

* `the Orion Usage and Guidelines documentation <https://intranet.hpc.msstate.edu/helpdesk/resource-docs/cluster_guide.php#orion-use>`_

.. _s4:

S4
---

S4 is the **Satellite Simulations and Data Assimilation Studies** supercomputer located at the University of Wisconsin-Madison's Space Science and Engineering Center.

Although S4 uses the `slurm <https://slurm.schedmd.com/>`_ task manager for parallel mpi jobs, users are advised to use :code:`mpirun` or :code:`mpiexec` instead of the slurm run script :code:`srun` due to problems with the mpich library with slurm.

Once logged into S4, you must then log into **s4-submit** to load the spack-stack modules to build and run JEDI.

.. code-block:: bash

   ssh -Y s4-submit

To request and interactive session on S4, run:

.. code-block:: bash

    salloc --nodes=1 --time=30 -I
    # Required for Intel so that serial jobs of MPI-enabled executables
    # run without having to call them through mpiexec/mpirun
    unset "${!SLURM@}"

S4 uses SBATCH and an example job submission script is :ref:`here <sbatch>`.

S4 documentation:

* `S4 user guide <https://s4doc.ssec.wisc.edu>`_
