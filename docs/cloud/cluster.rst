Running JEDI on a Multi-Node Cluster
====================================

[remember to run jedi_setup.sh]

The prerequisites for running a cluster are the same as for running a :doc:`single node <singlenode>`:

1. :doc:`Gain access to the JCSDA AWS Account <overview>`
2. :doc:`Create an ssh key pair so you can log into your instances <overview>`
3. :doc:`install the jedicluster app <jedicluster>`

When you have completed these three steps, you are ready to launch your cluster with the :code:`jedicluster` command.  The syntax is the same as described for a :doc:`singlenode` but now you need to specify the number of nodes.  And, you'll likely want to choose the :ref:`EC2 instance type <aws-instance-types>` to be something other than the default.

For example, to start a 6-node cluster with 216 cores (36 cores per node) and a 200 GB (root) disk, you would enter this:

.. code:: bash

    jedicluster start --stack-name <name> --key <ssh-key> --nodes 6 --ec2type c5n.18xlarge --disk-size 200 --spot

.. warning::

   The jedicluster AMIs are currently located in the us-east-1 region on AWS.  So, make sure you choose an ssh key that is available in that region.

.. _spot-pricing:    

The (optional) :code:`--spot` argument tells AWS to run this instance in the `spot market <https://aws.amazon.com/ec2/spot/>`_ which takes advantange of idle nodes.  This can be a substantial cost savings relative to on-demand pricing.  But of course, this raises the possibility that there are not enough idle nodes sitting around to meet your request.  If that is the case, the :code:`jedicluster` command above will fail after a few minutes with messages that look something like this:

.. code:: bash

    [...]
    ROLLBACK_IN_PROGRESS: IP address is not assigned yet, please wait...
    ROLLBACK_COMPLETE: 

If you were to then go to the `CloudFormation Dashboard on the AWS console <https://console.aws.amazon.com/cloudformation>`_, select your cluster, and then select :code:`Events` you might see an error message like this:

.. code:: bash

    There is no Spot capacity available that matches your request. (Service: AmazonEC2; Status Code: 500; Error Code: InsufficientInstanceCapacity; Request ID: 892644a6-eb2f-4e20-976e-5eafa36d3cbb)

If this is the case then you have a few different courses of action available to you: you can try back later, you can try a different EC2 instance type [#]_, or you can submit your request again without the :code:`--spot` option, thus defaulting to on demand.  Still, because of the cost savings, we request that you try the spot market first.

.. [#] For example, try using c5.18xlarge instead of c5n.18xlarge.  The c5n nodes have better networking performance but if they are unavailable, the c5 nodes may be sufficient; both have 36 cores.

.. warning::

   If your stack fails to form for any reason, with a ROLLBACK_COMPLETE message, then change the name if you resubmit it.  AWS remembers the names of your previous stacks until they are manually deleted and won't let you submit a stack with the same name.  Also, it's good practice to manually delete any failed stacks: see :ref:`Suspending or Terminating your cluster <terminate-aws-cluster>` below.

   
Now you may be wondering: "if there are not enough idle nodes to meet my request then how can I get them on demand?"  The answer is that you take them from the spot market users!  In other words, when you run in the spot market, you run the risk of your cluster being interrupted if the demand for those nodes is high.  This is why it is so much less expensive.

Currently, if your JEDI spot cluster is interrupted, the nodes will be terminated and you will lose any data you have.  Interruption is rare for some :ref:`EC2 instance types <aws-instance-types>` but is more common for high-performance nodes like c5n.18xlarge which are often in high demand.  Therefore, we recommend that you use on demand pricing (omit the :code:`--spot` option) for time-critical production runs.  In the future we plan to allow for spot clusters to be temporarily stopped upon interruption and then re-started when availability allows.  However, this capability has not yet been implemented.  

For more information, `Amazon has a nice description of how the spot market works <https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-spot-instances.html>`_.

Currently, the disks mounted by :code:`jedicluster` application (root and :code:`/opt`) are `Amazon Elastic Block Store (EBS) devices <https://aws.amazon.com/ebs>`_ that are attached to the head node (node 0) and cross-mounted on all the other nodes.  This is why, when you view them on the EC2 Dashboard, you may notice a distinction between the head node and the other (compute) nodes: because of this asymmetry, they have slightly different AMIs.  However, when you run an application, all nodes will be

In the future we will add an option to :code:`jedicluster` that will allow you to mount an `Amazon FSx Lustre <https://aws.amazon.com/fsx>`_ instead of enlarging the root EBS disk.  FSx is a parallel Lustre filesystem that is mounted homogeneously across all nodes and that offers improved parallel performance over EBS (EBS is NFS mounted).  Check back on this page for updates on availability.

.. _work-jedicluster:

Logging in and Building JEDI
----------------------------

After your cluster has been successfully created, the instructions for :ref:`logging in <aws-ssh>` and :ref:`working with the JEDI AMI <jedi-ami>` are the same as for a single node.  But here you will need the :code:`-A` option for :code:`ssh`.  So, for example, after the creation process is complete, you can log in to the head node as follows:

.. code:: bash

    ssh -i <pem-file> -A ubuntu@<ip-address>	  

After you log in, you are now ready to build your JEDI bundle.  The build procedure as described for the :ref:`single node instructions <jedi-ami>`.  Simply load your :code:`jedi/<compiler>-<mpi>` module and then run :code:`ecbuild` and `make -j<n>` :doc:`as you would on any other system <../developer/building_and_testing/building_jedi>`.

As noted for the :ref:`single-node case <jedi-ami>`, we have already included a copy of :code:`ufo-bundle` and :code:`fv3-bundle` in the :code:`/data/jedi` directory of the AMI.  So, if you use these bundles, you should be able to just update these repositories instead of having to do a fresh clone from GitHub/LFS.  If you use other bundles, you may wish to copy or move some of these repos into your bundle directory, which will likely take less time than doing a fresh clone.

For example, here is the build procedure for **fv3-bundle**:

.. code:: bash
	  
    module purge
    module load jedi/gnu-openmpi
    
    cd ~/jedi/build
    rm -rf *
    ecbuild --build=Release ../fv3-bundle
    make update
    make -j4

You can run :code:`ctest` as usual but it will only run on one node.  To run across multiple nodes, read on.

.. _running-on-jedicluster:

Running JEDI on an AWS Cluster
------------------------------

The process of running jobs is is somewhat different on a multi-node cluster compared to a single node.  Ensuring that all nodes have the same modules loaded and have the same environment variables set requires the use of a parallel process manager.  For the :code:`jedicluster` we use `Slurm <https://slurm.schedmd.com/documentation.html>`_.

Working with slurm will likely be familiar to any JEDI users who have experience running parallel jobs on HPC systems.  It's best to start with an example slurm script file:

.. code:: bash

    #!/bin/bash
    #SBATCH --job-name=<job-name>     # job name
    #SBATCH --nodes=6                 # number of nodes
    #SBATCH --ntasks=216              # number of MPI tasks
    #SBATCH --cpus-per-task=1         # One task per cpu core
    #SBATCH --ntasks-per-node=36      # multiple tasks/cores per node
    #SBATCH --time=0:15:00            # optional time limit
    #SBATCH --mail-type=END,FAIL      # Mail events (NONE, BEGIN, END, FAIL, ALL)
    #SBATCH --mail-user=<your-email>  # your email

    # set up modules
    source /opt/lmod/lmod/init/bash
    module purge
    module use /opt/modules/modulefiles/core
    module load jedi/intel-impi
    module list

    # disable memory limits
    ulimit -s unlimited
    ulimit -v unlimited

    # directories for output
    mkdir -p Data/hofx
    mkdir -p Data/bump
    mkdir -p output
    
    # No hyperthreading
    export OMP_NUM_THREADS=1
    
    # path to JEDI executables
    JEDIBIN=/home/ubuntu/jedi/build/bin

    # run directory - put your config files in $JEDIRUN/conf
    # This application also requires input files in $JEDIRUN/fv3files and $JEDIRUN/Data
    JEDIRUN=/home/ubuntu/runs/example1
    
    # run job
    cd $JEDIRUN
    mpirun -np 216 $JEDIBIN/fv3jedi_parameters.x config/bumpparameters_loc_geos.yaml
    mpirun -np 216 $JEDIBIN/fv3jedi_parameters.x config/bumpparameters_cor_geos.yaml
    mpirun -np 216 $JEDIBIN/fv3jedi_var.x config/hyb-3dvar_geos.yaml

    # successful exit
    exit 0
	  

The script begins with several slurm directives that specify the number of nodes, tasks, and other options for :code:`sbatch`.  These may alternatively be specified on the command line.  There are many more options availalble; for a full list see the `sbatch man page <https://slurm.schedmd.com/sbatch.html>`_. 
	  
The slurm directives are followed by various environment commands that may include loading modules, setting environment variables, navigating to the working directory and/or other commands.  These environment commands are executed by all nodes.

After the environment is established, the slurm script executes the command using :code:`mpirun`.

You can then run this script by entering

.. code:: bash
     
   sbatch <script-file>
   
Though you are the only one in the queue, you can monitor your job in a way that is similar to what you might do on an HPC system.  Useful slurm commands include

.. code:: bash

    squeue           # to list running or pending jobs
    scancel <job-id> # to kill a job in the queue
   
The head node is the only one with a public IP address so this is the one you log in to when you connect to your cluster via :code:`ssh` as described above.  So, this is typically where you would initiate your jobs using :code:`mpirun`.  However, each compute node has a private IP address that is accessible from the head node.  You can see the private IP addresses of all the nodes of your cluster by entering :code:`cat /etc/hosts`.  Or, you can just use the aliases :code:`node`, :code:`node2`... as listed in :code:`~/hostfile`.  So, if you wish, you can log into one of them while your job is running and confirm that your job is indeed running on that node:

.. code:: bash

    ssh node2 # from the head node
    ps -e | grep fv3jedi

Note that authentication across nodes is not necessary; this is your reward for including the :code:`-A` option when you connected via :code:`ssh`. 

After your job completes, successfully or not, a log file named :code:`slurm-<job-id>.out` will be written to the run directory.  For more slurm commands and usage tips, see `Slurm's quickstart page <https://slurm.schedmd.com/quickstart.html>`_.

.. _slurm-commands:

Working with slurm
------------------

Sometimes your job may hang.  Or, you may change your mind and want to stop your job.  You can cancel a job as follows:

.. code:: bash

    scancel <job-id>

Then wait a few moments for the job to terminate.  You can check the status of your nodes with:

.. code:: bash

    sinfo -l
    

Ideally, all your nodes should be in an :code:`idle` state.  This means they are ready to run a new job.  Sometimes, in the :code:`state` column you may see another value such as :code:`drain` or :code:`down`.  You can usually reset a problem node as follows (example is for node1):

.. code:: bash

    sudo scontrol update nodename=node1 state=idle

Then you should be ready to go.  If not, the `slurm troubleshooting guide <https://slurm.schedmd.com/troubleshoot.html>`_ has some good tips for helping to figure out what is wrong.  For example, if you wish to find more information about a node you can enter

.. code:: bash

    scontrol show node node1	  

.. _terminate-aws-cluster:

Suspending or terminating your cluster
--------------------------------------

When you are finished working with your cluster, you can terminate it with the command:

.. code:: bash

    jedicluster stop --stack-name <name>

It will take a few minutes to fully terminate.

You can also terminate your cluster from a web browser through the AWS console.  Navigate to the `CloudFormation Dashboard <https://console.aws.amazon.com/cloudformation>`_, select your cluster and select :code:`Delete`.

It is also possible to suspend your node and return to it again later.  When an EC2 instance is running, it will incur charges to JCSDA.  So, it is requested that you not leave it running overnight or at other times when you are not actively working with it.

When you delete your stack using :code:`jedicluster stop` or through the CloudFormation Dashboard as described above, you have permanently destroyed all compute resources and you will not be able to retrieve them.  As mentioned for the :ref:`single-node case <stop-ec2>`, you can also suspend your cluster and restart it later.  However, you can only do this if you created your cluster with on-demand pricing.  If you used the :code:`--spot` option then you will not be able to stop it and restart it.

To suspend an on-demand cluster, navigate to the `EC2 Dashboard <https://console.aws.amazon.com/cloudformation>`_.  Then manually select each node of your cluster and from the **Actions** drop-down menu at the top, select **Instance State** and then **Stop**.  Then, when you want to restart it later, again select all the nodes, and then **Actions -> Instance State -> Start**.

When a node is stopped, it incurs a minimal cost for the associated storage space but JCSDA is not charged for compute time.



