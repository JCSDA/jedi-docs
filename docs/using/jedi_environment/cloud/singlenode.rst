.. _singlenode-top:

Running JEDI on a Single Compute Node
=====================================

Often a single `EC2 compute node <https://aws.amazon.com/ec2>`_ is sufficient to run JEDI applications and tests.  This is particularly the case for code development.  A single AWS node can nowadays provide more than 100 compute cores that can each be assigned an MPI task.

As described elsewhere in :doc:`this chapter <index>`, there are several steps you need to take before you are ready to launch your very own compute node and run jedi:

1. :doc:`Gain access to the JCSDA AWS Account <overview>`
2. :doc:`Create an ssh key pair so you can log into your instances <overview>`

When you have completed these steps, you are ready to launch a single JEDI EC2 instance through the `EC2 Dashboard <https://console.aws.amazon.com/ec2>`_ on the AWS console.

As part of this release, an Amazon Media Image (AMI) is available that has the necessary `spack-stack-1.5.1` environment for `skylab-6.1.0` pre-installed. For more information on how to find this AMI, refer to :doc:`Building and running SkyLab <../../building_and_running/running_skylab>` in this documentation.


.. _singlenode-launch:

Launching instance
------------------

This section provides detailed instructions on how to build and use an EC2 instance based on an existing AMI. The AMI can be thought of as a pre-built template that provides a software stack, and just needs the configuration details of the EC2 instance (such as the number of cores, the amount of memory, etc.).

The following example uses the ``skylab-6.1.0-redhat8`` AMI.

1. Log into the AWS Console and select the EC2 service. In the sidebar on the left, scroll down to the Images section and click on the "AMIs" option. Select ``"skylab-6.1.0-redhat8`` from the list of AMIs. Click on "Launch instance from AMI".
2. Give your instance a meaningful name so that you can identify it later in the list of running instances.
3. Select an instance type that has enough memory for your experiment. For available options see, https://aws.amazon.com/ec2/instance-types. Note that because you only have one node you will need a large amount of memory when running higher resolution experiments. For low resolution experiments, instances like c6i.2xlarge may be sufficient, but for c96 experiments instances with at least 512GB memory are required.

.. note:: Because the ``skylab`` AMIs come with a precompiled software stack and because ``spack`` optimizes the code for the hardware it is compiling on, instances of the same (processor) family or of a newer, compatible family are required for these AMIs. Here is a list of currently available ``skylab`` AMIs and the instance type they were built on:

+-----------------------------------------+---------------------------------+--------------------------+
| AMI name                                | Instance type used for building | Processor                |
+=========================================+=================================+==========================+
| ``skylab-1.0.0-{ubuntu20,redhat8}``     | t2.2xlarge                      | Intel Haswell E5-2676 v3 |
+-----------------------------------------+---------------------------------+--------------------------+
| ``skylab-2.0.0-{ubuntu20,redhat8}``     | t2.2xlarge                      | Intel Haswell E5-2676 v3 |
+-----------------------------------------+---------------------------------+--------------------------+
| ``skylab-3.0.0-{ubuntu20,redhat8}``     | c6i.4xlarge                     | Intel Ice Lake 8375C     |
+-----------------------------------------+---------------------------------+--------------------------+
| ``skylab-4.0.0-redhat8``                | c6i.4xlarge                     | Intel Ice Lake 8375C     |
+-----------------------------------------+---------------------------------+--------------------------+
| ``skylab-5.0.0-{ubuntu20,redhat8}``     | c6i.4xlarge                     | Intel Ice Lake 8375C     |
+-----------------------------------------+---------------------------------+--------------------------+
| ``skylab-6.0.0-redhat8``                | c6i.4xlarge                     | Intel Ice Lake 8375C     |
+-----------------------------------------+---------------------------------+--------------------------+
| ``skylab-6.1.0-redhat8``                | c6i.4xlarge                     | Intel Ice Lake 8375C     |
+-----------------------------------------+---------------------------------+--------------------------+

4. Select an existing key pair (for which you hold the private key on your machine) or create a new key pair and follow the process.
5. Check the entries under "Network settings". Make sure that the network is correct (usually the default is), that the subnet is public (usually indicated by the name), and that "Auto-assign public IP" enabled. Choose the existing security group  "Global SSH" or create a new security group that allows SSH traffic from anywhere so that you can connect to the instance from your local machine.
6. Make sure that you request enough storage for your instance. For testing purposes, the default/minimum for the AMI is usually sufficient.
7. Click on "Launch instance" on the bottom right.

At this point, your new instance will start up and run. On the page that comes up there will be a message with the instance ID (in the format ``i-<long hex number>``. It is recommended to click on the instance ID which will take you to the Instance viewer showing only your newly created instance.

.. _singlenode-ssh:

Logging in
----------

After launching the instance through the AWS console, select the instance and click on "Connect", then choose "SSH client" to obtain the necessary command to log into the instance from the command line. To help you identify your instance, you can give it a label by hovering over the instance description in the console and selecting the pencil icon that appears in the field just to the right of the selection box (this box is blue when selected).

   .. note:: If you are going to run ewok, add ``-XY`` to the ssh command line arguments. After logging in, configure your AWS credentials by running ``aws configure``, or, if the AWS command line tools are not installed, by creating/editing ``~/.aws/credentials`` and pasting your amazon credentials in the following format:

      .. code-block:: bash

         [default]
         aws_access_key_id=***
         aws_secret_access_key=***

         [jcsda-noaa-us-east-1]
         aws_access_key_id=***
         aws_secret_access_key=***

         [jcsda-usaf-us-east-2]
         aws_access_key_id=***
         aws_secret_access_key=***


      Similarly, create/edit ``~/.aws/config`` and set your default region:

      .. code-block:: bash

         [default]
         region = us-east-1

**For AWS Red Hat 8:** After logging in, follow the instructions in https://spack-stack.readthedocs.io/en/1.5.1/PreConfiguredSites.html#amazon-web-services-red-hat-8 to load the basic spack-stack modules for GNU. Please note that the AMI IDs in the spack-stack 1.5.1 release documentation are incorrect - they are correct in these JEDI docs release notes. Proceed with loading the appropriate modules for your application, for example for the ``skylab-6.0.0`` release:

.. code-block:: bash

   module load jedi-fv3-env
   module load ewok-env
   module load soca-env


Note the Skylab v6 static data is synced to the AWS EC2 AMI in directory ``~/jedi/static/skylab-6.0.0/``.

There is a ``setup.sh`` template available to use with the Skylab v6 AMI. It is located at ``~/sandpit/setup.sh``.

Suspending or terminating your compute node
-------------------------------------------

When an EC2 instance is running, it will incur charges to JCSDA.  So, it is requested that you not leave it running overnight or at other times when you are not actively working with it.

When you are finished working with your instance for the day, you have the option of either stopping it temporarily or terminating it permanently.  You can do this by navigating to the `EC2 Dashboard <https://console.aws.amazon.com/ec2>`_ on the AWS console.  You should see your node among the running instances. You should be able to identify it by the label that you assigned to it, the ssh key name and the launch time.

After selecting your node, you can stop or terminate it by selecting **Instance State** from the **Actions** drop-down menu at the top of the Dashboard display.  If you terminate your node, then the compute instance will be shut down and all changes you have made to the disks will be deleted.  You have permanently destroyed all compute resources and you will not be able to retrieve them.

If you launched your instance using the :code:`--spot` option, then termination is currently your only option.  It is possible to define persistent spot instances that can be stopped but this needs careful attention because your instance may automatically start up again without you realizing it and this could incur unexpected charges.  So, the jedi node tool is currently configured to avoid this.

But, if you started an on-demand instance (without the :code:`--spot` option), then you have the option to come back to your instance at another time and pick up where you left off.  Just select :code:`Stop` from the **Actions->Instance State** drop-down menu.  This will shut down the compute instance and its associated hardware, but it will save the contents of the disks and preserve the current state of the computing environment.

Later, when you want to work with the node again, you can go back to the EC2 Dashboard, select the instance, and again access the :code:`Action` menu.  There select :code:`Instance State` and then :code:`Start`.  It will take a few minutes to reboot.  When it does, it will be assigned a different IP address.  You can find its new IP address by looking in the :code:`IPv4 Public IP` column of the table or by selecting the node and viewing the :code:`Description` information at the bottom of the window.

When an EC2 instance is stopped, this incurs a minimal cost for the associated storage space but JCSDA is not charged for compute time.

.. _aws-instance-types:

Choosing a different EC2 Instance Type
--------------------------------------

AWS offers `a variety of EC2 instance types <https://aws.amazon.com/ec2/instance-types/>`_ that differ in the number of compute cores, memory, disk storage, and network bandwidth.  Not surprisingly, higher-performance nodes are more expensive, so JEDI users are encouraged to **choose an instance that is no less but no more than what you need for your application or workflow.**

The recommended and most tested option for this release is type ``c6i.4xlarge``. Always consult `the AWS documentation <https://aws.amazon.com/ec2/pricing/on-demand/>`_ for the most up-to-date pricing information.

There are also a number of other nodes available that optimize compute and or memory and or IO bandwidth: See the `AWS documentation <https://aws.amazon.com/ec2/instance-types/>`_ for details.
