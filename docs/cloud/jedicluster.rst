Installing the Required Python Tools
====================================

After you have :doc:`gained access to the JCSDA AWS resources <overview>`, the next step is to install and configure the tools you will need to one or more compute nodes from the command line.

The first tool you'll need is the `AWS Command Line interface (CLI) <https://docs.aws.amazon.com/cli/index.html>`_.  This will allow you to launch either a single compute node or a multi-node cluster from your computer.  After you have created a compute instance or a cluster, you can then log into it and proceed to build and run JEDI.

The easiest way to install the AWS CLI is through a package installer.  For example, you can use Homebrew on a Mac:

.. code:: bash

   brew install awscli

or the :code:`apt` installer on a Debian-based linux OS such as Ubuntu:

.. code:: bash

    sudo apt-get install awscli

Or, since the AWS CLI is a python package, you can also install it with :code:`pip` or :code:`conda`, for example:

.. code:: bash

    pip3 install -U awscli --user

For further details see the `AWS documentation <https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html>`_.

The next step is to configure the AWS CLI to use your AWS login credentials.  When you were :doc:`granted access to JCSDA AWS resources <overview>`, a JEDI master should have given you an AWS secret access key and associated ID in addition to your username and password.  Have this secret access key and ID handy before running this command to configure your AWS CLI:

.. code:: bash

    aws configure

Enter your secret access key ID and the access key itself at the prompts.  When prompted for your default region, enter :code:`us-east-1`.  This is where most of the JEDI AMIs are currently housed.  At other prompts, including the default output format, you can just type enter to select the default (None).

In order to use the single-node launch script described in :doc:`the next section <singlenode>`, you will also need to install the following python packages using :code:`pip`, :code:`pip3`, or :code:`conda`:

- os
- click
- boto3

If you only wish to run JEDI on a single node, you can :doc:`proceed to the next section <singlenode>`.

Alternatively, if you wish to have the capability to run JEDI across multiple AWS nodes, you will also have to install `AWS ParallelCluster <https://docs.aws.amazon.com/parallelcluster/index.html>`_.  ParallelCluster is another python application that provides a user-friendly interface to the AWS CloudFormation. CloudFormation is ulimately responsible for creating and coordinating a cluster of collocated, interconnected compute nodes, which AWS calls `EC2 instances <https://aws.amazon.com/ec2/>`_.

AWS maintains `the most thorough, up-to-date instructions on how to install ParallelCluster <https://docs.aws.amazon.com/parallelcluster/latest/ug/install.html>`_ so we recommend that you follow those.
