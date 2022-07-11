.. _singlenode-top:

Running JEDI on a Single Compute Node
=====================================

Often a single `EC2 compute node <https://aws.amazon.com/ec2>`_ is sufficient to run JEDI applications and tests.  This is particularly the case for code development.  A single AWS node can nowadays provide as many as 96 compute cores that can each be assigned an MPI task.

As described elsewhere in :doc:`this chapter <index>`, there are several steps you need to take before you are ready to launch your very own compute node and run jedi:

1. :doc:`Gain access to the JCSDA AWS Account <overview>`
2. :doc:`Create an ssh key pair so you can log into your instances <overview>`

When you have completed these steps, you are ready to launch a single JEDI EC2 instance through the `EC2 Dashboard <https://console.aws.amazon.com/ec2>`_ on the AWS console.

As part of this release, two Amazon Media Images (AMIs) are available that have the necessary `spack-stack-1.0.1` environment
for `skylab-1.0.0` pre-installed. For more information on how to find these AMIs,
refer to the `spack-stack documentation <https://spack-stack.readthedocs.io/en/spack-stack-1.0.1/Platforms.html#amazon-web-services-ubuntu-20-04>`_.

.. _aws-ssh:

Logging in
----------

After launching the instance through the AWS console, select the instance and click on "Connect", then choose "SSH client" to obtain the necessary command to log into the instance from the command line. After logging in, follow the **FRIENDLY USER INSTRUCTIONS THAT NEED TO BE ADDED SOMEWHERE** to set up the environment compiling and running Skylab experiments. To help you identify your instance, you can give it a label by hovering over the instance description in the console and selecting the pencil icon that appears in the field just to the right of the selection box (this box is blue when selected).

Suspending or terminating your compute node
-------------------------------------------

When an EC2 instance is running, it will incur charges to JCSDA.  So, it is requested that you not leave it running overnight or at other times when you are not actively working with it.

When you are finished working with your instance for the day, you have the option of either stopping it temporarily or terminating it permanently.  You can do this by navigating to the `EC2 Dashboard <https://console.aws.amazon.com/ec2>`_ on the AWS console.  You should see your node among the running instances. You should be able to identify it by the label that you assigned to it, the ssh key name and the launch time. 

After selecting your node, you can stop or terminate it by selecting **Instance State** from the **Actions** drop-down menu at the top of the Dashboard display.  If you terminate your node, then the compute instance will be shut down and all changes you have made to the disks will be deleted.  You have permanently destroyed all compute resources and you will not be able to retrieve them.

If you launched your instance using the :code:`--spot` option, then termination is currently your only option.  It is possible to define persistent spot instances that can be stopped but this needs careful attention because your instance may automatically start up again without you realizing it and this could incur unexpected charges.  So, the jedinode tool is currently configured to avoid this.

But, if you started an on-demand instance (without the :code:`--spot` option), then you have the option to come back to your instance at another time and pick up where you left off.  Just select :code:`Stop` from the **Actions->Instance State** drop-down menu.  This will shut down the compute instance and its associated hardware, but it will save the contents of the disks and preserve the current state of the computing environment.

Later, when you want to work with the node again, you can go back to the EC2 Dashboard, select the instance, and again access the :code:`Action` menu.  There select :code:`Instance State` and then :code:`Start`.  It will take a few minutes to reboot.  When it does, it will be assigned a different IP address.  You can find its new IP address by looking in the :code:`IPv4 Public IP` column of the table or by selecting the node and viewing the :code:`Description` information at the bottom of the window.

When an EC2 instance is stopped, this incurs a minimal cost for the associated storage space but JCSDA is not charged for compute time.

.. _aws-instance-types:

Choosing a different EC2 Instance Type
--------------------------------------

AWS offers `a variety of EC2 instance types <https://aws.amazon.com/ec2/instance-types/>`_ that differ in the number of compute cores, memory, disk storage, and network bandwidth.  Not surprisingly, higher-performance nodes are more expensive, so JEDI users are encouraged to **choose an instance that is no less but no more than what you need for your application or workflow.**

The recommended and most tested option for this release is type ``t2.2xlarge``. Always consult `the AWS documentation <https://aws.amazon.com/ec2/pricing/on-demand/>`_ for the most up-to-date pricing information.

There are also a number of other nodes available that optimize compute and or memory and or IO bandwidth: See the `AWS documentation <https://aws.amazon.com/ec2/instance-types/>`_ for details.
