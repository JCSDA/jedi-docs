Installing the jedicluster app
==============================

After you have :doc:`gained access to the JCSDA AWS resources <overview>`, the next step is to install and configure the `AWS Command Line interface (CLI) <https://docs.aws.amazon.com/cli/index.html>`_.  This will allow you to launch either a single compute node or a multi-node cluster from your computer.  After you have created a compute instance or a cluster, you can then log into it and proceed to build and run JEDI.

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

Now you are ready to install the :code:`jedicluster` application.  This is a python tool developed by JCSDA in order to facilitate the creation of an AWS node or cluster that is ready to run JEDI.  In particular, the compute nodes that you create with :code:`jedicluster` will already be provisioned with all the software applications and libraries you need to build and run JEDI, including the gnu compiler suite, openmpi, netcdf, git-lfs, and much more.

To install :code:`jedicluster` on your computer, navigate to an appropriate directory (of your choice) and enter these commands:

.. code:: bash

    git clone https://github.com/JCSDA/jedi-tools
    cd jedi-tools/AWS/python
    make install

This builds the :code:`jedicluster` executable and installs it somewhere in your home directory.  On most Mac and linux systems you can find it in :code:`~/.local/bin` but if it's not there you might try :code:`~/Library/Python/<version>/bin`.  In any case, just make sure that directory is included in your :code:`PATH` environment variable.  If not, you can add it as follows (bash syntax; you may wish to add this to your :code:`~/.bashrc` file so it is available automatically whenever you start a new shell):

.. note::

   The :code:`make install` command uses the python tool :code:`easy_install-<version>` where :code:`<version>` is the python version.  If you get a message that that is not found, then you can install it with pip: `pip3 install --user setuptools`.  If that still doesn't work then you can try editing the Makefile to remove the python version, since some python versions vary on how they name it.  That is, replace :code:`easy_install-${PYTHON_VERSION}` with :code:`easy_install`.

.. code:: bash

    export PATH=$HOME/.local/bin:$PATH

    
   
Once the :code:`jedicluster` app is installed on your system, you may use it as much as you wish; in principle you only need to follow this procedure once.  However, occasionally the jedi stack is updated with new packages or new versions of old packages.  These compiled packages are stored in what is called an Amazon Machine Image (AMI), from which the EC2 instances and clusters are created.  So, if there is a change in the AMIs, then you'll have to pull the latest version of :code:`jedi-tools` and re-install: 

.. code:: bash

    cd <path>/jedi-tools/AWS/python
    git pull
    make install

Changes in the jedi-stack will generally be announced on the `GitHub JEDI team discussion board <https://github.com/orgs/JCSDA/teams/jedi>`_.  However, even if you follow that page, it is good practice to occasionally update your jedicluster app to ensure that it is compatible with the latest JEDI code, particularly if you run into build problems.
