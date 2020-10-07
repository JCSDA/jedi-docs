.. _singlenode-top:

Running JEDI on a Single Compute Node
=====================================

Often a single `EC2 compute node <https://aws.amazon.com/ec2>`_ is sufficient to run JEDI applications and tests.  This is particularly the case for code development.  A single AWS node can provide as many as 36 compute cores that can each be assigned an MPI task.

As described elsewhere in :doc:`this chapter <index>`, there are several steps you need to take before you are ready to launch your very own compute node and run jedi:

1. :doc:`Gain access to the JCSDA AWS Account <overview>`
2. :doc:`Create an ssh key pair so you can log into your instances <overview>`
3. :doc:`Install the python modules that will allow you to access AWS from your command line<jedicluster>`

When you have completed these steps, you are ready to launch a single JEDI EC2 instance or a multi-node cluster.  In this section we'll focus on launching a single EC2 instance.

to clone the :code:`jedi-tools` GitHub repository from JCSDA:

.. code:: bash

    git clone https://github.com/jcsda/jedi-tools.git
    cd jedi-tools/AWS/jedi

There you will find a script called :code:`jedinode.py`.  This is what you'll use to launch a single AWS node that is equipped with the following features:

- Intel compilers and accompanying jedi-stack environment modules
- gnu compilers, openmpi, and accompanying jedi-stack environment modules
- Singularity, for running containers

For usage information, enter

.. code:: bash

    jedinode.py --help

For most options we recommend using the defaults.  However, one required option is to specify your personal ssh key that you will use to log in to your node (see item 2 above).  So, to launch an EC2 instance, enter:

.. code:: bash

    jedinode.py --key=<your-ssh-key>

Note that :code:`<your-ssh-key>` should not be your local pem file.  Rather, it should be the name of the public key as listed in the "key pairs" section of the EC2 Dashboard on AWS.  So, for example, if your private pem file is :code:`~/.ssh/mykey.pem` then you should enter :code:`jedinode.py --key=mykey`.  In other words, omit the path and the `.pem` extension.

.. warning::

   The JEDI AMIs and snapshots may not be available in all AWS regions.  Unless otherwise advised by a JEDI master, we recommend that you use the default region, which is us-east-1.  So, make sure you choose an ssh key that is available in that region.

The (optional) :code:`--spot` argument asks AWS to reduce costs by running the instance in the `spot market <https://aws.amazon.com/ec2/spot/>`_.  Though this can be a substantial cost savings, spot instances run the risk of being interrupted.  Furthermore, unlike on-demand instances, they cannot be stopped and started at will (though it is possible to configure spot instances that can be stopped and started, :ref:`the jedi launch script is deliberately not configured for this - see below <stop-ec2>`).

Another notable option is :code:`--type`, which allows you to specify the EC2 instance type.  For further information see :ref:`Choosing a Different EC2 Instance Type <aws-instance-types>` below.  Specifying the node type should be sufficient for most use cases.  If you specify an instance type that is unfamiliar, you may get a message asking you to also specify the number of compute cores for that node type, which you can do with the :code:`--ncores` option.  This information is needed in order to disable hyperthreading, which improves performance.

The syntax for all options is as above, with only an :code:`=` separating the option and its value.  For example:

.. code:: bash

    jedinode.py --key <ssh-key> --spot --type=r5.4xlarge

If you log into the AWS console (not required), you will see your compute node listed on the `EC2 Dashboard <https://console.aws.amazon.com/ec2>`_.

.. _aws-ssh:

Logging in
----------

After running the :code:`jedinode.py` command as described above you will likely see multiple messages like this:

.. code:: bash

    Node is not ready yet, please wait

These are repeated for the several minutes it takes for AWS to create your node by means of the **EC2** service.  When your compute node is ready you may get a message like this:

.. code:: bash

    Node is ready.  To log in enter
    ssh -i ~/.ssh/<key>.pem ubuntu@<ip-address>

The notification tells you how to log in to your node via :code:`ssh`.  In particular, the user name is :code:`ubuntu` and the public ip address that was assigned by AWS appears after the :code:`@` symbol.  Depending on how you set up your :doc:`ssh key pair <overview>`, you may not need the :code:`-i` option above.  Or, if you put your :code:`.pem` file somewhere other than :code:`~/.ssh`, you'll need to change the command accordingly.

:code:`ssh` may warn you that the authenticity of the host can't be established and may ask you whether you wish to continue to connect.  Enter :code:`yes` at the prompt.

If all went as planned, you should now be logged into your compute node.

.. _jedi-ami:

Working with the JEDI AMI
-------------------------

The JEDI AMI uses (tcl) `environment modules <https://modules.readthedocs.io/en/latest/>`_ to set up the jedi environment.

To see what modules you can load at any time, enter

.. code:: bash

    module avail

You'll see many modules but most important are the so-called meta-modules of the form :code:`jedi/<compiler>-<mpi>`.  Loading only a single one of these modules will load the full set of dependencies you need to build and run JEDI.

For example, if you want to build JEDI using the gnu compiler suite and openmpi mpi library, you would enter this:

.. code:: bash

    module purge
    module load jedi/gnu-openmpi

Alternatively, if you want to use the intel compiler suite, then you would enter this:

.. code:: bash

    module purge
    module load jedi/intel-impi

After you have loaded one of these options for the :code:`jedi/<compiler>-<mpi>` stack, you can see the modules you have loaded by entering

.. code:: bash

    module list

You should see the full jedi stack, including :code:`boost-headers`, :code:`netcdf`, :code:`eckit`, :code:`ecbuild`, etc.

Now you are ready to :doc:`build and run JEDI <../developer/building_and_testing/building_jedi>`.

Note that one or more bundles may already be present in the :code:`~/jedi` directory.  These are intended to make it easier on the user because a fresh clone of some of the repositories can take some time.  If most of the data files are already there, a :code:`git pull` will only download those files that have been added or modified, making the build much more efficient.  Still, make sure you do a :code:`make update` when you build these bundles to ensure that you have the latest versions of the repositories; they have likely changed since the AMI was created.

The JEDI AMI also comes with **Singularity**, **Docker**, and **Charliecloud** pre-installed.  So, you can also use your node to run inside a container.  For example, if you wish to do some development using the clang C and C++ compilers and the mpich MPI library, then you can pull that container and enter it:

.. code:: bash

    singularity pull library://jcsda/public/jedi-clang-mpich-dev
    singularity shell -e jedi-clang-mpich-dev_latest.sif

.. _stop-ec2:

Suspending or terminating your compute node
-------------------------------------------

When an EC2 instance is running, it will incur charges to JCSDA.  So, it is requested that you not leave it running overnight or at other times when you are not actively working with it.

When you are finished working with your instance for the day, you have the option of either stopping it temporarily or terminating it permanently.  You can do this by navigating to the `EC2 Dashboard <https://console.aws.amazon.com/ec2>`_ on the AWS console.  You should see your node among the running instances.  You should be able to identify it by the ssh key name and the launch time.  If you are still having trouble identifying it, you can filter by the :code:`jedi:development` tag.

After selecting your node, you can stop or terminate it by selecting **Instance State** from the **Actions** drop-down menu at the top of the Dashboard display.  If you terminate your node, then the compute instance will be shut down and all changes you have made to the disks will be deleted.  You have permanently destroyed all compute resources and you will not be able to retrieve them.

If you launched your instance using the :code:`--spot` option, then termination is currently your only option.  It is possible to define persistent spot instances that can be stopped but this needs careful attention because your instance may automatically start up again without you realizing it and this could incur unexpected charges.  So, the jedinode tool is currently configured to avoid this.

But, if you started an on-demand instance (without the :code:`--spot` option), then you have the option to come back to your instance at another time and pick up where you left off.  Just select :code:`Stop` from the **Actions->Instance State** drop-down menu.  This will shut down the compute instance and its associated hardware, but it will save the contents of the disks and preserve the current state of the computing environment.  To help you identify your instance, you can give it a label by hovering over the instance description in the console and selecting the pencil icon that appears in the field just to the right of the selection box (this box is blue when selected).

Later, when you want to work with the node again, you can go back to the EC2 Dashboard, select the instance, and again access the :code:`Action` menu.  There select :code:`Instance State` and then :code:`Start`.  It will take a few minutes to reboot.  When it does, it will be assigned a different IP address.  You can find its new IP address by looking in the :code:`IPv4 Public IP` column of the table or by selecting the node and viewing the :code:`Description` information at the bottom of the window.

When an EC2 instance is stopped, this incurs a minimal cost for the associated storage space but JCSDA is not charged for compute time.

.. _aws-instance-types:

Choosing a different EC2 Instance Type
--------------------------------------

AWS offers `a variety of EC2 instance types <https://aws.amazon.com/ec2/instance-types/>`_ that differ in the number of compute cores, memory, disk storage, and network bandwidth.  Not surprisingly, higher-performance nodes are more expensive, so JEDI users are encouraged to **choose an instance that is no less but no more than what you need for your application or workflow.**

Recommended options include but are not limited to the following.  The prices listed are for on-demand use and are not necessarily up to date; they are intended to give the user a feel for the difference in price between these instances.  Always consult `the AWS documentation <https://aws.amazon.com/ec2/pricing/on-demand/>`_ for the most up-to-date pricing information.

* **r5.2xlarge** ($0.504 per hour on demand)
  This is a good, inexpensive choice for code development, equipped with 4 compute cores, 64 GiB memory, and reasonable network bandwidth (up to 10 Gbps).

* **c5.4xlarge** ($0.864 per hour)
  With 8 compute cores and high network performance, these nodes can handle more computationally expensive tests and applications than the r5.2xlarge nodes.  As such, they can be a good choice for running models such as FV3 or MPAS for development or training purposes (these are the nodes used for the JEDI Academy). This is the default if the :code:`--type` option is omitted from the call to :code:`jedinode.py`.

* **c5.24xlarge** ($4.08 per hour)
  These currently provide the highest single-node performance and can be used for intermediate-sized applications that are still small enough to fit on a single node.  This could enhance performance by avoiding communication across nodes which is often inferior to the single-node bandwidth.  They offer dedicated use of a 48-core compute node with 192 GiB memory and 25 Gbps network bandwidth. They also offer 14 Gbps IO bandwidth to (EBS) disk.  Due to high demand, it's possible that these nodes may not be available at a given time.

There are also a number of other nodes available that optimize memory or IO bandwidth for a given core count: See the `AWS documentation <https://aws.amazon.com/ec2/instance-types/>`_ for details.
