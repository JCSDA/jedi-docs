.. _top-Singularity:

Singularity
=======================

In order to appreciate what `Singularity <https://www.sylabs.io/docs/>`_ is and why we use it, it is best to begin with its purpose.  From a JEDI perspective, the purpose of Singularity is to provide a uniform computing environment (software tools, libraries, etc) that will enable users like you to easily build, compile, and run JEDI across a wide range of computing platforms, from laptops and workstations running Mac OS X or linux to parallel High-Performace Computing (HPC) systems such as Theia (NOAA), Discover (NASA), or Cheyenne (NCAR).

The computing environment that Singularity creates is called a **container**.  There are other container providers as well, the most well-known being `Docker <https://www.docker.com/>`_.  An advantage of Singularity over these other alternatives is that it was specifically designed to address the challenges associated with HPC systems and collaborative software development efforts that require full control over your own software stack (see `this article in HPCWire <https://www.hpcwire.com/2018/02/08/startup-brings-hpc-containers-enterprise/>`_ and `this article in "Cloud Computing for Science and Engineering" <https://cloud4scieng.org/singularity-a-container-system-for-hpc-applications/>`_).

In contrast to virtual machines, containers do not include the necessary software to build an entire operating system.  Rather, they work with the host operating system to provide the desired functionality, including the libraries, applications, and other software tools that your code needs to run.  So containers generally require much less memory to store and to set up than virtual machines.  Singularity encapsulates your software environment in a single disk **image file** that can be copied to and invoked on any system on which Singularity itself is installed.  The JEDI environment is contained in one such image file (see :ref:`below <build_env>`).

.. _Singularity-install:

Installing Singularity
----------------------

If you're running JEDI on an HPC system, the chances are good that Singularity is already installed.  If it is not, you'll have to ask the support staff to install it for you and make it available for users (unless you happen to have root privileges).   Direct them to the *Download/Installation* menu on the left frame of the main `Singularity <https://www.sylabs.io/docs/>`_ site.  You can check to see if Singularity is already installed (and if it is, which version is installed) by typing

.. code:: bash

  singularity --version

Version 2.4.5 was released recently, on March 19, 2018.  You'll need **at least version 2.4.2** (released Dec 5, 2017) to run JEDI.

If an up-to-date version of Singularity is already installed on your system, you can skip ahead to :ref:`Building the JEDI Environment <build_env>`.  The instructions that follow are mainly intended to help you install Singularity on your own workstation or laptop.

**We recommend that you install Singularity version 3.0 as described in the** `Singularity Documentation <https://www.sylabs.io/guides/3.0/user-guide/quick_start.html#quick-installation-steps>`_.

Alternatively, we now describe how to install Singularity 2.6.

As noted :ref:`above <top-Singularity>`, Singularity is not a virtual machine so it does not build its own operating system.  Instead, it must work with the host operating system and it is currently configured to work best with linux.

If you are running Mac OS X or Windows, then you must first set up a linux operating system.  This requires a proper virtual machine (VM).  The recommended VM provider is `Vagrant <https://www.vagrantup.com/intro/index.html>`_ by HashiCorp, which can build and configure an appropriate linux operating system using Oracle's `VirtualBox <https://www.virtualbox.org/>`_ software package.

  :doc:`If you have a Mac, go here first to install Vagrant, then return to this page <vagrant>`

In short, Vagrant and VirtualBox provide the linux operating system while Singularity provides the necessary software infrastructure for running JEDI (compilers, cmake, ecbuild, etc) by means of the :ref:`JEDI singularity image <build_env>`.

If you configure Vagrant using the **singularityware** Vagrant box (Option 1 in our :doc:`Vagrant documentation <vagrant>`) then no further action is needed - singularity is already installed and ready to go.  Alternatively, you can configure Vagrant using a bento box that establishes a more basic linux environment such as ubuntu (Option 2).  Then you can :ref:`log in to your vagrant VM <create-vm>` with :code:`vagrant ssh` and proceed as described below for linux.  

Installing on linux systems is relatively easy.  The first step is to make sure you have the correct dependencies.  On ubuntu systems, you can install them by copying and pasting this:

.. code:: bash

    # for ubuntu
    sudo apt-get update
    sudo apt-get -y install build-essential curl git sudo man vim autoconf libtool

Now you can get the source code from GitHub, checkout version 2.6, make, and install Singularity as follows:

.. code:: bash

    # for linux systems
    git clone https://github.com/singularityware/singularity.git
    cd singularity
    git fetch --all
    git checkout 2.6.0
    ./autogen.sh
    ./configure --prefix=/usr/local
    make
    sudo make install
    
.. _build_env:

Building the JEDI environment 
-------------------------------

Once singularity is installed on your system, the rest is easy.  The next step is to download the **JEDI Singularity image** from the singularity hub (shub):

.. code:: bash

   singularity pull shub://JCSDA/singularity

Strictly speaking, you only have to do this step once but in practice you will likely want to update your JEDI image occasionally as the software environment continues to evolve.  The pull statement above should grab the most recent development version of the JEDI image file.  It will take a few seconds to execute and when it is done, singularity will tell you what the name of this latest and greatest image file is and where it is located (which should be the same directory that you ran the pull statement in):

.. code:: bash

   Progress |===================================| 100.0% 
   Done. Container is at: /home/vagrant/JCSDA-singularity-master-latest.simg

Though you can execute individual commands or scripts within the singularity container defined by your image file (see the **exec** and **run** commands in the `Singularity documentation <https://www.sylabs.io/docs/>`_), for most JEDi applications you will want to invoke a **singularity shell**, as follows:

.. code:: bash

   # starting Singularity from a linux/unix system
   singularity shell -e JCSDA-singularity-master-latest.simg
   
Now you are inside the **Singularity Container** and you have access to all the software infrastructure needed to build, compile, and run JEDI.  The :code:`-e` option helps prevent conflicts between the host environment and the container environment (e.g. conflicting library paths) by cleaning the environment before running the container.  Note that this does not mean that the container is isolated from the host environment; you should still be able to access files and directories on your host computer (or on your virtual machine if you are using Vagrant) from within the Singularity container.

If you installed singularity from within a :doc:`Vagrant <vagrant>` virtual machine (Mac or Windows), then you probably set up a a :code:`/vagrant_data` directory (you may have given it a different name and/or path) that is shared between the host machine and the virtual machine.  If you want to continue to use this directory to transfer files between your host computer and your Singulairty container, then you need to tell Singularity about this directory when you start the shell.  This can be done as follows:

.. code:: bash

   # starting Singularity from a vagrant virtual machine	  
   singularity shell --bind /vagrant_data -e JCSDA-singularity-master-latest.simg
   
There is another "feature" of Singularity that is worth mentioning. Though Singularity starts a bash shell when entering the container, You may notice that it does not call the typical bash startup scripts like :code:`.bashrc`, :code:`.bash_profile` or :code:`.bash_aliases`.  Furthermore, this behavior persists even if you do not use the :code:`-e` option to :code:`singulary shell`.  This is intentional.  The creators of Singularity deliberately arranged it so that the singularity container does not call these startup scripts in order to avoid conflicts between the host environment and the container environment.   It is possible to circumvent this behavior using the :code:`--shell` option as follows:  

.. code:: bash

   # NOT RECOMMENDED!
   singularity shell --shell /bin/bash -e JCSDA-singularity-master-latest.simg

However, if you do this, you may begin to appreciate why it is not recommended.  In particular, you'll notice that your command line prompt has not changed.  So, it is not easy to tell whether you are working in the container or not.  Needless to say, this can get very confusing if you have multiple windows open!

.. _startup-script:

It is safer (and only minimally inconvenient) to put your aliases and environment variables in a shell script and then just get in the habit of sourcing that script after you enter the container, for example:

.. code:: bash

   source startup.sh

where :code:`startup.sh` contains, for example:

.. code:: bash

   #!/bin/bash
   alias Rm='rm -rf '
   export FC=mpifort
   export DISPLAY=localhost:0.0

The last two lines of this example script are particularly noteworthy.  Setting the :code:`FC` environment variable as shown is currently required to compile and run JEDI with multiple mpi threads.  And, setting the :code:`DISPLAY` environment variable as shown should enable X forwarding from the Singularity container to your computer if you are using linux/unix.  This in turn will allow you to use graphical tools such as :code:`emacs` or :ref:`kdbg <kdbg>`.

If you are invoking the singularity shell from a vagrant virtual machine, then X Forwarding is a bit more complicated; :ref:`See here for how to setup X Forwarding on a Mac <mac-x-forwarding>`.

For a full list of options, type :code:`singularity shell --help` from *outside* the container.

To exit the Singularity container at any time, simply type

.. code:: bash

   exit

If you are using a Mac, you may wish to type :code:`exit` a second time to exit Vagrant and then shut down the virtual machine with :code:`vagrant halt` (See :ref:`Working with Vagrant and Singularity <vagrant-jedi>`).
