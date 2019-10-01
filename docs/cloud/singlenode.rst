.. _singlenode-top:

Running JEDI on a Single Compute Node
=====================================

Often a single `EC2 compute node <https://aws.amazon.com/ec2>`_ is sufficient to run JEDI applications and tests.  This is particularly the case for code development.  A single AWS node can provide as many as 36 compute cores that can each be assigned an MPI task.

As described elsewhere in :doc:`this chapter <index>`, there are several steps you need to take before you are ready to launch your very own compute node and run jedi:

1. :doc:`Gain access to the JCSDA AWS Account <overview>`
2. :doc:`Create an ssh key pair so you can log into your instances <overview>`
3. :doc:`install the jedicluster app <jedicluster>`

When you have completed these three steps, you are ready to launch your node with the following command:

.. code:: bash

    jedicluster start --stack-name <name> --key <ssh-key> --spot

.. warning::

   The jedicluster AMIs are currently located in the us-east-1 region on AWS.  So, make sure you choose an ssh key that is available in that region.

The first (required) option is :code:`--stack-name`.  It's good practice to include somthing to identify you, the user, such as your initials or user name, as well as some information about the application and/or the date (dashes and underscores are not allowed).  This will help you distinguish your node from others when you view it from the AWS console.

The next argument is also required and specifies the name of the ssh key that you will use to log into your instance.

The (optional) :code:`--spot` argument asks AWS to reduce costs by running the instance in the `spot market <https://aws.amazon.com/ec2/spot/>`_.  Though this can be a substantial cost savings, spot instances run the risk of being interrupted.  Furthermore, unlike on-demand instances, they cannot be stopped and started at will.  For more information see :ref:`Running JEDI on a Multi-Node Cluster <spot-pricing>` and :ref:`Suspending or terminating your compute node <stop-ec2>`.

To see other options, enter

.. code:: bash

    jedicluster start --help

Note in particular :code:`--ec2type` which allows you to specify the EC2 instance type.  For further information see :ref:`Choosing a Different EC2 Instance Type <aws-instance-types>` below.

.. warning::

   If your stack fails to form for any reason, with a ROLLBACK_COMPLETE message, then change the name if you resubmit it.  AWS remembers the names of your previous stacks until they are manually deleted and won't let you submit a stack with the same name.  Also, it's good practice to manually delete any failed stacks: see :ref:`Suspending or terminating your compute node <stop-ec2>`.

Note also the :code:`--disk-size` option which allows you to specify the size (in GB) of the root disk (mounted as :code:`/`).  This can be useful when running applications that produce and/or ingest large amounts of data.  The minimum size of the root disk is 40 GB, which is also the default (there is also a 60 GB :code:`/opt` volume that houses the compilers and modules).

The syntax for all options is as above, with only a space separating the option and its value.  For example:

.. code:: bash

    jedicluster start --stack-name <name> --key <ssh-key> --spot --ec2type c4.4xlarge --disk-size 100

If you log into the AWS console (not required), you will see your compute node listed both on the `EC2 Dashboard <https://console.aws.amazon.com/ec2>`_ and on the `CloudFormation Dashboard <https://console.aws.amazon.com/cloudformation>`_.
       
.. _aws-ssh:

Logging in
----------

After running the :code:`jedicluster` command as described above you will likely see multiple messages like this:

.. code:: bash
   
    CREATE_IN_PROGRESS: IP address is not assigned yet, please wait...

These are repeated for the several minutes it takes for AWS to create your node by means of the **CloudFormation** and **EC2** services.  When your compute node is ready you may get a message like this:

.. code:: bash
   
    CREATE_IN_PROGRESS: Cluster started:
    ssh -A ubuntu@3.221.253.217
    The head node may still be booting and SSH may not work immediately,
    but should be available within the next couple minutes.

As advised here, you may wish to wait a few more minutes to make sure the node is fully booted.

Note that the single-node configuration described here is really just a special case of a cluster with :code:`--nodes 1`.  So, don't be mislead by the phrasing: "Cluster started" really just means that your compute node (EC2 instance) has started.  And, the "head node" refers to the EC2 instance itself; in this case there are no additional compute nodes.

Similarly, the :code:`-A` option for ssh isn't really needed for a single node; this tells AWS to forward your ssh key so the nodes of a cluster can communicate with one another without further authentication.  Otherwise, the notification tells you how to log in to your node via :code:`ssh`.  In particular, the user name is :code:`ubuntu` and the ip address, hereafter expressed as :code:`<ip-address>`, appears after the :code:`@` symbol.  Depending on how you set up your :doc:`ssh key pair <overview>`, you may also need to pass ssh a :code:`.pem` file that contains your key.  For example,

.. code:: bash

    ssh -i <pem-file> ubuntu@<ip-address>	  

:code:`ssh` may warn you that the authenticity of the host can't be established and may ask you whether you wish to continue to connect.  Enter :code:`yes` at the prompt.    
    
If all went as planned, you should now be logged into your compute node.
    
.. _jedi-ami:

Working with the JEDI AMI
-------------------------

The JEDI AMI uses `Lmod environment modules <https://lmod.readthedocs.io/en/latest/>`_ to set up the jedi environment.

To see what modules you can load at any time, enter

.. code:: bash

    module avail

You'll see many modules but most important are the so-called meta-modules of the form :code:`jedi/<compiler>-<mpi>`.  Loading only a single one of these modules will load the full set of dependencies you need to build and run JEDI.

For example, if you want to build JEDI using the gnu 7.4 compiler suite, you would enter this:

.. code:: bash

    module purge
    module load jedi/gnu-openmpi

Alternatively, if you want to use the intel compiler suite, default version 17.0.1, then you would enter this:

.. code:: bash

    module purge
    module load jedi/intel-impi

Note that this loading this module switches the GNU compilers to version 5.5.  So, you might notice a comment about this.  This is because the intel C and C++ compilers make use of GNU header files and Intel version 17 is incompatible with GNU version 7.4.   For further information on how Intel uses gcc, see the `Intel documentation <https://software.intel.com/en-us/cpp-compiler-developer-guide-and-reference-gcc-compatibility-and-interoperability>`_.

There is also an Intel version 19.0.4 stack available that you can load as follows:

.. code:: bash

    module purge
    module load jedi/intel19-impi

And, a :code:`clang` stack that uses :code:`gfortran` v7.4 for Fortran files:

.. code:: bash

    module purge
    module load jedi/clang-openmpi

After you have loaded one of these options for the :code:`jedi/<compiler>-<mpi>` stack, you can see the modules you have loaded by entering

.. code:: bash

    module list

You should see the full jedi stack, including :code:`boost-headers`, :code:`netcdf`, :code:`eckit`, :code:`ecbuild`, etc.    

Now you are ready to :doc:`build and run JEDI <../developer/building_and_testing/building_jedi>`.    

Note that versions of :code:`ufo-bundle` and :code:`fv3-bundle` are already included in the :code:`~/jedi` directory.  These are intended to make it easier on the user because a fresh clone of some of the repositories such as :code:`crtm`, :code:`ioda`, and :code:`fv3-jedi` can take some time.  If most of the data files are already there, a :code:`git pull` will only download those files that have been added or modified, making the build much more efficient.  Still, make sure you do a :code:`make update` when you build these bundles to ensure that you have the latest versions of the repositories; they have likely changed since the AMI was created.

.. _stop-ec2:


Suspending or terminating your compute node
-------------------------------------------

When you are finished working with your node, it is easiest to terminate it from the command line using the :code:`stop` function of the :code:`jedicluster` tool:

.. code:: bash

    jedicluster stop --stack-name <name>

It will take a few minutes to fully terminate.

Another way to terminate your compute node is through the AWS console.  However, **make sure you do this from the** `CloudFormation Dashboard <https://console.aws.amazon.com/cloudformation>`_ **as opposed to the** `EC2 Dashboard <https://console.aws.amazon.com/ec2>`_.

Though it is possible to launch a single-node EC2 instance from the JEDI AMI without the use of CloudFormation, that is not the way the :code:`jedicluster` application is set up.  So, if you launched your compute node using :code:`jedicluster` as described above, merely terminating the EC2 instance will leave a residual CloudFormation stack.  However, if you select the stack in the CloudFormation Dashboard and then select :code:`Delete`, then this will terminate both the CloudFormation stack and the associated EC2 instance.

If your node is on demand, then it is also possible to suspend your node and return to it again later (spot instances cannot be stopped and retarted).  When an EC2 instance is running, it will incur charges to JCSDA.  So, it is requested that you not leave it running overnight or at other times when you are not actively working with it.  When you delete your stack using :code:`jedicluster stop` or through the CloudFormation Dashboard as described above, you have permanently destroyed all compute resources and you will not be able to retrieve them.

Instead, to temporarily suspend your node, go to the EC2 Dashboard and select the EC2 instance.  Then, under the :code:`Actions` menu on the top of the window, select :code:`Instance State` and then :code:`Stop`.  This will shut down the instance but it will preserve the current state of the computing environment and disk.

Later, when you want to work with the node again, you can go back to the EC2 Dashboard, select the instance, and again access the :code:`Action` menu.  There select :code:`Instance State` and then :code:`Start`.  It will take a few minutes to reboot.  When it does, it will be assigned a different IP address.  You can find its new IP address by looking in the :code:`IPv4 Public IP` column of the table or by selecting the node and viewing the :code:`Description` information at the bottom of the window.

When a node is stopped, it incurs a minimal cost for the associated storage space but JCSDA is not charged for compute time.
    
.. _aws-instance-types:

Choosing a different EC2 Instance Type
--------------------------------------

AWS offers `a variety of EC2 instance types <https://aws.amazon.com/ec2/instance-types/>`_ that differ in the number of compute cores, memory, disk storage, and network bandwidth.  Not surprisingly, higher-performance nodes are more expensive, so JEDI users are encouraged to **choose an instance that is no less but no more than what you need for your application or workflow.**

Recommended options include but are not limited to the following.  The prices listed are for on-demand use and are not necessarily up to date; they are intended to give the user a feel for the difference in price between these instances.  Always consult `the AWS documentation <https://aws.amazon.com/ec2/pricing/on-demand/>`_ for the most up-to-date pricing information.

* **m5.2xlarge** ($0.38 per hour)
  This is a good, inexpensive choice for code development, equipped with 4 compute cores, 32 GiB memory, and reasonable network bandwidth (up to 10 Gbps). This is the default if the :code:`--ec2type` option is omitted from the call to :code:`jedicluster start`.
  
* **c4.4xlarge** ($0.80 per hour)
  With 8 compute cores and high network performance, these nodes can handle more computationally expensive tests and applications than the m5.2xlarge nodes.  As such, they can be a good choice for running models such as FV3 or MPAS for development or training purposes (these are the nodes used for the JEDI Academy).
  
* **c5n.18xlarge** ($3.89 per hour)
  These currently provide the highest single-node performance and can be used for intermediate-sized applications that are still small enough to fit on a single node.  This could enhance performance by avoiding communication across nodes which is often inferior to the single-node bandwidth.  They offer dedicated use of a 36-core compute node with 192 GiB memory and 100 Gbps network bandwith. They also offer 14 Gbps IO bandwith to (EBS) disk.
  
There are also a number of other nodes available that optimize memory or IO bandwith for a given core count: See the `AWS documentation <https://aws.amazon.com/ec2/instance-types/>`_ for details.
