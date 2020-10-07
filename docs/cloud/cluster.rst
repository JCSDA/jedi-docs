Running JEDI on a Multi-Node Cluster
====================================

The prerequisites for running a cluster are the same as for running a :doc:`single node <singlenode>`:

1. :doc:`Gain access to the JCSDA AWS Account <overview>`
2. :doc:`Create an ssh key pair so you can log into your instances <overview>`
3. :doc:`install the required python tools, including AWS ParallelCluster <jedicluster>`

When you have completed these three steps, you are ready to launch a cluster using the `AWS ParallelCluster application <https://docs.aws.amazon.com/parallelcluster/latest/ug/what-is-aws-parallelcluster.html>`_.

.. _awspc-config:

Configuring Parallel Cluster
----------------------------

The first step is to set up a ParallelCluster configuration file that is equipped to run a multi-node jedi application efficiently.  We provide such a configuration file in the jedi-tools repository on GitHub.  The easiest way to proceed is to clone the jedi-tools repository and copy this configuration file over as your default configuration:

.. code:: bash

    git clone https://github.com/jcsda/jedi-tools.git
    cp jedi-tools/AWS/jedi/config ~/.parallelcluster/config

.. note::

    Alternatively, if you do not wish to over-write your default configuration file, you can give this a different name and then specify the filename using the :code:`--config` option to :code:`pcluster create`.

Now you should edit the config file to customize it for your personal use.  There is only one entry you need to change.  Find the :code:`key_name` item and replace the :code:`<key-name>` text with your personal ssh key name.  As for the :doc:`single node case <singlenode>`, omit the :code:`.pem` extension if you are using a pem file.  Note the aws region specified at the top of the config file.  Make sure your ssh key is available in that region.

Take a look at the other entries in the config file.  As you become a more experienced user, there are other things you may wish to change.  Note in particular where the EC2 instance types are specified for the master and the compute nodes.  Note also the :code:`max_queue_size` which specifies the maximum number of compute nodes in your cluster (see the description of autoscaling below).

Notice also the entry :code:`enable_efa = compute`.  This creates a cluster that is equipped with Amazon's `elastic fabric adapter <https://aws.amazon.com/hpc/efa/>`_, a high-performance network interface that rivals the infiniband interconnects on HPC systems.

Note that the EFA is not available for all EC2 instance types, so your possible choices for :code:`compute_instance_type` are limited.  For high performance, it is recommended that you use the default value specified in the config file.

By default, your cluster will launch in the `spot market <https://aws.amazon.com/ec2/spot/>`_, which takes advantage of idle resources.  This can be a substantial cost savings but is :doc:`subject to interruption and termination if others out-bid you for the resources <singlenode>`.  If you would instead like to use on demand, you can edit the configuration file and replace :code:`cluster_type = spot` with :code:`cluster_type = ondemand`.  Note that this specification only applies to the compute nodes.  The Master node is always of type :code:`ondemand`.

If your JEDI spot cluster is interrupted, the nodes will be terminated and you will lose any data you have.  Interruption is rare for some :ref:`EC2 instance types <aws-instance-types>` but is more common for high-performance nodes like c5n.18xlarge which are often in high demand.  Therefore, we recommend that you use on demand pricing for time-critical production runs.  For more information, `Amazon has a nice description of how the spot market works <https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-spot-instances.html>`_.

You can also configure your cluster to use an `Amazon FSx Lustre filesystem <https://aws.amazon.com/fsx>`_ for optimal IO performance.  Currently the minimum file system size is 1.2 TB and it is more expensive per GB-hour than the root (NFS-mounted) EBS file system so FSx should only be used for computationally intensive applications.  You can attach an FSx volume by means of a `straightforward modification of the config file <https://aws-parallelcluster.readthedocs.io/en/latest/configuration.html#fsx>`_.

For descriptions and examples of other configuration options, see the `AWS documentation <https://aws-parallelcluster.readthedocs.io/en/latest/configuration.html>`_.

.. tip::

   If the :code:`cluster_type` is set to :code:`spot`, then the default spot price is the on demand price.  This means that you are willing to pay no more than the on demand price for your resources.  However, in some circumstances, you may not even want to pay this.  You may wish to tell AWS to wait until the spot price is no more than 80 percent of the on demand price before launching your cluster.  To achieve this you can add a line to the config file (right after the :code:`cluster_type` specification) that reads :code:`spot_bid_percentage = 80`.

.. _awspc-create:

Creating a Parallel Cluster
---------------------------

If you installed ParallelCluster in a python virtual environment as recommended, then the next step is to activate your virtual environment with a command like this (this may vary if your install location is different):

.. code:: bash

     source ~/apc-ve/bin/activate


To see the ParallelCluster commands available to you, you can then enter

.. code:: bash

    pcluster --help

And, for further information on any one of these commands, you can request help for that particular command, e.g.:

.. code:: bash

    pcluster create --help

Since most of your specifications and customizations are in the config file, there is not much you need to specify on the command line.  All you really have to do is to give your cluster a name.  You may wish to include your initials and a date.  Avoid special characters like dashes and periods.  It's best to stick to letters and numbers.

So, when you are ready, create your cluster with

.. code:: bash

    pcluster create <name>

It will take up to 5-10 minutes to create your cluster so be patient.  AWS must provision the required resources and configure the JEDI environment.

.. tip::

   If the :code:`cluster_type` is set to :code:`spot` (either in the config file or on the command line with the :code:`-p` option as shown above), then the default spot price is the on demand price.  This means that you are willing to pay no more than the on demand price for your resources.  However, in some circumstances, you may not even want to pay this.  You may wish to tell AWS to wait until the spot price is no more than 80 percent of the on demand price before launching your cluster.  To achieve this you can add the :code:`-p '{"spot_bid_percentage":"80"}'` option to :code:`pcluster create` (or add it to the config file).

ParallelCluster will print messages detailing its progress.  You can also follow the progress of your cluster creation on the `EC2 Dashboard <https://console.aws.amazon.com/ec2>`_ and the `CloudFormation Dashboard <https://console.aws.amazon.com/cloudformation>`_.  When you cluster is ready, you should see a message like this from :code:`pcluster`:

.. code:: bash

    Status: parallelcluster-<name> - CREATE_COMPLETE
    ClusterUser: ubuntu
    MasterPrivateIP: <private-ip-address>

Do not worry at this point about the size or the cost of your cluster.  ParallelCluster makes use of the `AWS autoscaling <https://aws.amazon.com/autoscaling/>`_ capability.  This means that the number of nodes in your cluster will automatically adjust to the workload you give it.

.. note::

    In this document we refer to **nodes** and **EC2 instances** interchangeably.  The nodes of your cluster are just EC2 instances that you can see on your `EC2 Dashboard <https://console.aws.amazon.com/ec2>`_ like any other instances.  But, these nodes are tied together using placement groups that coordinate their physical location and a virtual private cloud that isolates their networking.  This is all orchestrated through the `AWS CloudFormation service <https://aws.amazon.com/cloudformation/>`_, which is what ParallelCluster uses to create your cluster.

Note this line in the config file:

.. code:: bash

   initial_queue_size = 0

This means that the cluster will boot up with only the master node.  It will not create any compute nodes until you ask it to by submitting a batch job (see :ref:`below <awspc-run>`).  Furthermore, the Master node is typically a smaller, less expensive instance type than the compute nodes so charges should be comparable to the :doc:`single-node <singlenode>` case until you actually run something substantial across multiple nodes.

.. _awspc-login:

Logging in and Building JEDI
----------------------------

To log in to your cluster from your python virtual environment, enter

.. code:: bash

    pcluster ssh <name> -i ~/.ssh/<key>.pem

Or, alternatively, you can navigate to the `EC2 Dashboard <https://console.aws.amazon.com/ec2>`_ and find your node there.  It should be labelled :code:`Master` and have a tag of :code:`Application:parallelcluster-<name>`.  Then you can find the public IP address in the instance description and log into it as you would a :doc:`single EC2 instance <singlenode>`.

After logging in (enter "yes" at the ssh prompt), enter this and follow the instructions:

.. code:: bash

    jedi-setup.sh

This will set up your git/GitHub configuration in preparation for building JEDI.

Now you can choose which compiler/mpi combination you with to use and load the appropriate module.  Currently two options are available (choose only one):

.. code:: bash

    module load jedi/gnu-openmpi # choose only one
    module load jedi/intel-impi  # choose only one

If you switch from one to the other you should first run :code:`module purge`.  You can disregard any error messages you see about being unable to locate modulefiles.

Now you are ready to :doc:`build your preferred JEDI bundle <../developer/building_and_testing/building_jedi>`.  You can run :code:`ctest` as usual but it will only run on one node.  To run across multiple nodes, read on.

.. _awspc-run:

Running JEDI Applications across nodes
--------------------------------------

The ParallelCluster AMI used for JEDI employs the `Slurm workload manager <https://slurm.schedmd.com/documentation.html>`_ to launch and coordinate modules and applications across multiple compute nodes.  Working with slurm will likely be familiar to any JEDI users who have experience running parallel jobs on HPC systems.

So, after compiling your bundle, you will want to create a run directory and create a slurm batch script within it.  A slurm batch script is just a file with contents similar to the following example:

.. code:: bash

    #!/bin/bash
    #SBATCH --job-name=<job-name>
    #SBATCH --ntasks=216
    #SBATCH --cpus-per-task=1
    #SBATCH --time=0:30:00
    #SBATCH --mail-user=<email-address>

    source /usr/share/modules/init/bash
    module purge
    export $JEDI_OPT=/optjedi/modules
    module use $JEDI_OPT/modulefiles/core
    module load jedi/intel-impi
    module list

    ulimit -s unlimited
    ulimit -v unlimited

    export SLURM_EXPORT_ENV=ALL
    export OMP_NUM_THREADS=1

    export I_MPI_FABRICS=shm:ofi
    export I_MPI_OFI_PROVIDER=efa

    JEDIBIN=<jedi-build-dir>/bin

    cd <run-dir>

    mpiexec -np 216 ${JEDIBIN}/fv3jedi_var.x Config/3dvar.yaml

    exit 0

Here :code:`<job-name>` is the name you wish to give to your job, :code:`<email-address>` is your email address (you'll get an email when it run), :code:`<jedi-build-bin>` is the directory where you built your jedi bundle, and :code:`<run-dir>` is your desired run directory - often the same directory where the batch script is located.

The script begins with several slurm directives that specify the number of nodes, tasks, and other options for :code:`sbatch`.  These may alternatively be specified on the command line.  There are many more options available; for a full list see the `sbatch man page <https://slurm.schedmd.com/sbatch.html>`_.

Note that this is just an example.  For it to work, you would need to ensure that all the proper configuration and input files are accessible from the run directory.

This example calls for 216 MPI tasks.  If you are using the (default) c5.18xlarge nodes, then there are 36 compute cores per node.  So, since there is one cpu per mpi task (:code:`cpus-per-task=1`), this will require 6 compute nodes (i.e. 6 EC2 instances).

The value for the :code:`--time` entry isn't important because there is no queue - you are the only user.  But, it can help to ensure that your cluster does not run indefinitely if there is a problem that causes it to hang.

This example uses the intel modules and sets some compiler flags to ensure that the EFA fabric is used for communication across nodes.

When you are ready, submit your batch script with

.. code:: bash

    sbatch <batch-script>


where :code:`<batch-script>` is the name of the file that contains your batch script.

Now slurm will trigger the autoscaling capability of AWS to create as many compute nodes as are needed to run your job.  In the example above, this would be 6.

You can follow the status of your cluster creation on the web by monitoring the EC2 Dashboard and/or through the slurm commands :code:`sinfo` and :code:`squeue`.

It is important to monitor your cluster to **make sure your cluster creation does not hang due to lack of available resources**.

For example, let's say you submitted a batch job that requires 24 nodes.  Then, after, say, 15 minutes, only 20 of them are available (as reported by :code:`sinfo`).  The reason for this may be that there are only 20 nodes of that type available at that time in the chosen AWS availability zone.  So, it may stay in this state for many minutes, even hours, until four more nodes free up.  Meanwhile, JCSDA is incurring charges for the 20 nodes that are active.  Twenty c5n.18xlarge nodes standing idle for an hour would cost more than $80.  So, don't wait for more than about 10-15 minutes: if your cluster creation seems to have stalled, then cancel the job with :code:`scancel <job-id>`.  This will terminate all of the compute nodes but it will leave the Master node up.  You can then try again at a later time.

.. _tip-autoscaling:

.. tip::

    To immediately change the number of active compute nodes to a value of your choice you do not have to wait for slurm.  You can navigate to the EC2 Dashboard and find the **Auto Scaling Groups** item all the way at the bottom of the menu of services on the left.  You find your cluster's group by name; the name should start with :code:`parallelcluster` and should contain your custom name.  Select it and then select the **Edit** button just above the list of groups.  Now change the **Desired capacity** to be the value of your choice.  You can also alter the minimum and maximum cluster size if you wish.  When you are finished, scroll all the way to the bottom of the page and select **Update**.  You should soon see your changes reflected in the EC2 Dashboard.

The head node is the only one with a public IP address so this is the one you log in to when you connect to your cluster via :code:`pcluster ssh` as described above.  So, this is where you would submit your slurm jobs.  However, each compute node has a private IP address that is accessible from the head node.  You can see the private IP addresses of all the nodes of your cluster through the :code:`NODELIST` field of :code:`sinfo`.  For example:

.. code:: bash

    ubuntu@ip-10-0-0-127:~$ sinfo
    PARTITION AVAIL  TIMELIMIT  NODES  STATE NODELIST
    compute*     up   infinite      2   idle ip-10-0-1-[193,215]

Then, if you wish, you can log into one of them while your job is running and confirm that your job is indeed running on that node:

.. code:: bash

    ssh ip-10-0-1-215 # from the head node
    ps -e | grep fv3jedi

After your job completes, successfully or not, a log file named :code:`slurm-<job-id>.out` will be written to the run directory.  For more slurm commands and usage tips, see `Slurm's quickstart page <https://slurm.schedmd.com/quickstart.html>`_ and :ref:`Working with slurm <slurm-commands>` below.

.. _awspc-sin:

Running Multi-Node JEDI Applications with Singularity
-----------------------------------------------------

You can also run multi-node JEDI applications using an HPC-ready Singularity application container.  Check with a `JEDI Master <miesch@ucar.edu>`_ for availability of suitable containers.

When you have obtained a container file, you can run applications with a batch script like this:

.. code:: bash

    #!/bin/bash
    #SBATCH --job-name=<job-name>
    #SBATCH --ntasks=216
    #SBATCH --cpus-per-task=1
    #SBATCH --time=0:30:00
    #SBATCH --mail-user=<email-address>

    source /usr/share/modules/init/bash
    module purge
    export JEDI_OPT=/optjedi/modules
    module use $JEDI_OPT/modulefiles
    module load intelmpi/2019.6.166
    module load singularityvars
    module list

    ulimit -s unlimited
    ulimit -v unlimited

    export SLURM_EXPORT_ENV=ALL
    export OMP_NUM_THREADS=1

    export I_MPI_FABRICS=shm:ofi
    export I_MPI_OFI_PROVIDER=efa

    JEDICON=/home/ubuntu
    JEDIBIN=/opt/jedi/fv3-bundle/build/bin

    cd <run-dir>

    mpiexec -np 216 singularity exec --home=$PWD $JEDICON/jedi-intel19-impi-hpc-app.sif ${JEDIBIN}/fv3jedi_var.x Config/3dvar.yaml

    exit 0

Here :code:`JEDICON` is the directory where the container image file is located.  You may be tempted to change the :code:`JEDIBIN` directory but do not do so.  This refers to a path *inside the container* where the JEDI executable lies.  Note also the use of the :code:`singularityvars` module.  This is needed to eliminate conflicts between the host environment and container environment.  Explanations for the remaining items in the batch script are similar to the :ref:`version without the container <awspc-run>`.

Terminating or stopping your cluster
------------------------------------

When you are finished with your cluster, you have the option to either stop it or terminate it.  In either case, the first step is to cancel all running or pending slurm batch jobs and log out of the Master node.

As for a :doc:`single node <singlenode>`, termination means that all computing resources and data volumes are destroyed and cannot be recovered.  So, if you want to save the results of your applications it is up to you to move them to AWS S3 or some other site.

If the autoscaling has reduced your cluster to zero compute nodes, you may be tempted to terminate your cluster by terminating your master node from the EC2 console.  **Please do not do this**.  Though this will delete the compute resources and associated charges, it will leave other (now orphaned) resources active, such as the CloudFormation stack for your cluster and its associated Virtual Private Cloud.

The proper way to terminate your cluster is the same way you created it: from the command line using the :code:`pcluster` application:

.. code::

    pcluster delete <name>

If you set up :code:`pcluster` inside a :doc:`virtual environment <jedicluster>`, then this command should be executed within that virtual environment.

Since the Master node is always :code:`ondemand` (as opposed to spot, :ref:`see above <awspc-config>`), you also have the option to stop it and restart it later.

To stop your cluster, first make sure that there are zero compute nodes active.  If you are using the default configuration file (with :code:`min_queue_size` set to zero), then you can do this by cancelling all slurm jobs and waiting for the compute nodes to terminate.  Or, you can manually reduce the size of the cluster to zero as described in the :ref:`tip above <tip-autoscaling>`.

When the size of the cluster is zero, then you can stop your cluster by navigating to the EC2 Dashboard.  There you can select the Master instance and access the **Actions** menu to choose **Instance State -> Stop**, as described for a :ref:`single compute node <stop-ec2>`.

When a node is stopped, it incurs a minimal cost for the associated storage space but JCSDA is not charged for compute time.

When you restart your Master node at a later time, it will take a few minutes to reboot.  And, it will have a different public ip address; it will also be a different physical machine.  But, the contents of your disk will have been saved so you can pick up where you left off.

.. _slurm-commands:

Working with slurm
------------------

Sometimes your job may hang.  Or, you may change your mind and want to stop your job.  You can cancel a job as follows:

.. code:: bash

    scancel <job-id>

Then wait a few moments for the job to terminate.  You can check the status of your nodes with:

.. code:: bash

    sinfo -l

Ideally, all your nodes should be in an :code:`idle` state.  This means they are ready to run a new job.  Sometimes, in the :code:`state` column you may see another value such as :code:`drain` or :code:`down`.  You can usually reset a problem node as follows (you can get the node name from the :code:`NODELIST` output of `sinfo`):

.. code:: bash

    sudo scontrol update nodename=ip-10-0-1-193 state=idle

Then you should be ready to go.  If not, the `slurm troubleshooting guide <https://slurm.schedmd.com/troubleshoot.html>`_ has some good tips for helping to figure out what is wrong.  For example, if you wish to find more information about a node you can enter

.. code:: bash

    scontrol show node ip-10-0-1-193
