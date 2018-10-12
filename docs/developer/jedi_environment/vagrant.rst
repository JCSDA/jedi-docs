Vagrant (Mac only)
==================================

In order to set up the JEDI environment with :doc:`Singularity <singularity>`, you'll need an operating system (OS) that is capable of running Singularity.  The operating system that is best equipped for this is linux.

So, if you're using a Mac or Windows computer, you will want to set up a local, self-contained linux environment within your broader operating system.  This is commonly called a **virtual machine** (VM).  Once you have a linux VM up and running, you will be able to installl :doc:`Singularity <singularity>` and triumphantly enter the :ref:`JEDI Singularity Container <build_env>`.

This can all be achieved using an application called `Vagrant <https://www.vagrantup.com/>`_, which is developed and distributed by a company called Hashicorp.  Though we will sometimes refer to Vagrant as the virtual machine provider, the actual linux operating system is ultimately provided by Oracle's `VirtualBox <https://www.virtualbox.org/>`_ software package.  Vagrant is essentially a tool will allow you to build, configure, and manage a VirtualBox operating system.  In particular, we will use Vagrant and VirtualBox to create an Ubuntu (currently version 16.04) virtual machine on your Mac workstation or laptop.  We'll then populate that linux VM with specific JEDI software tools (compilers, ecbuild, etc.) using :doc:`Singularity <singularity>`.

From this brief introduction, it is clear that you do not need to worry about Vagrant or VirtualBox if your working machine (whether it is a workstation, laptop, or HPC system) is already running linux and/or is already running Singularity.  By *working machine* we mean whatever machine you plan to compile and run JEDI on.

You *do* need Vagrant and VirtualBox (or something equivalent) if you wish to run JEDI from a Mac or Windows machine.  Though you can use Vagrant for both platforms, we focus here on Mac OS X.  We refer Windows users to the documentation on `how to install Singularity on Windows systems <http://singularity.lbl.gov/install-windows>`_.

So if you're using a Mac, read on.  Otherwise, feel free to skip this document.

Installing and Configuring Vagrant
----------------------------------

The following instructions on how to install Vagrant on a Mac follow the `Singularity Mac installation page <http://singularity.lbl.gov/install-mac>`_, but from the perspective of an aspiring JEDI master.

Before you begin you should install or update :doc:`Homebrew <../developer_tools/homebrew>`.  You'll need a relatively recent verision in order to use the :code:`cask` extension.  Once you have done this, you can proceed with the following steps.

A: Install Vagrant and VirtualBox
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code:: bash

  brew cask install virtualbox
  brew cask install vagrant
  brew cask install vagrant-manager

B: Create a home for the Singularity container
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
This is just an example: you can choose any path you like

.. code:: bash

  mkdir $HOME/singularity-vm  
  cd $HOME/singularity-vm

C: Initialize Vagrant
^^^^^^^^^^^^^^^^^^^^^

There are two options here, as noted on Singularity's `Mac installation page <http://singularity.lbl.gov/install-mac>`_.  The simplest is to initialize using the Singularityware Vagrant box provided by the makers of Singularity:

.. code:: bash

   # Configuration Option 1
   vagrant init singularityware/singularity-2.4

The second is to obtain the ubuntu OS from one of a selection of `bento boxes <https://app.vagrantup.com/bento>`_ provided by Vagrant:

.. code:: bash

   # Configuration Option 2
   vagrant init bento/ubuntu-16.04

Either option will create a configuration file in the current directory called :code:`Vagrantfile`.  The main difference is that Option 1 will install Singularity by default.  For option 2, you will have to enter a few :ref:`additional commands <install-sing-from-vagrant>` to explicitly install Singularity.


D: Allocate Sufficient Resources for the Virtual Machine
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
We have noticed that the default memory size (1 GB) specified in Vagrantfile is not enough to run some tests and applications (e.g. MAPS, FV3).  Since this is comparable to the size of the Singularity image file, you may even run into problems just entering the container.

Furthermore, some of the tests require 6 MPI threads.  This is particularly true for FV3 but it also holds for some tests in ufo that are designed to assess parallel IO. 

So, you will need to edit the Vagrantfile.  Look for the following section that specifies the provider-specific configuration (in our case this is virtualbox).  Change the :code:`vb.memory` (in MB) and :code:`vb.cpus` fields as shown here:

.. code:: bash

   config.vm.provider "virtualbox" do |vb|
     # Display the VirtualBox GUI when booting the machine
     # vb.gui = true
 
     # Customize the amount of memory on the VM:
     vb.memory = "4096"

     # Customize the number of cores in the VM:
     vb.cpus = "6"

     # [...]
     
   end

This (4GB) should be sufficient to run ufo-bundle.  Some of the other bundle test suites may require as much as 16 GB.

E: Enable file transfer between your Mac and the virtual machine
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

By default, one cannot exchange files between the host (Mac OS) and guest (Vagrant virtual machine) machines. Fortunately, Vagrant provides a means for this type of access.

Edit the Vagrantfile and find the section for a **synced folder**:

.. code:: bash

    # Share an additional folder to the guest VM. The first argument is
    # the path on the host to the actual folder. The second argument is
    # the path on the guest to mount the folder. And the optional third
    # argument is a set of non-required options.
    #config.vm.synced_folder "../vagrant_data", "/vagrant_data"

Uncomment the config.vm.synced_folder command and set the paths to the desired locations of the directories on the host and guest machines, for example:

.. code:: bash

    config.vm.synced_folder  "./vagrant_data", "/vagrant_data"

**Note - you need to make sure that both of these directories exist before starting Singularity.**  In fact, you need to create the host directory even **before you start up Vagrant**, so let's start with that one.  

In the above example, the host directory is the first argument, :code:`./vagrant_data`.  The path is relative to the location of the Vagrantfile.  So, Let's say that you have installed vagrant in :code:`$HOME/singularity-vm`. This is where your Vagrantfile resides and this is the directory you will start vagrant from.  

So, in this example, our next step would be to create a directory on our Mac (the host machine) called :code:`$HOME/singularity-vm/vagrant_data`.

We also need to create the guest directory, which is the second argument in the example above, :code:`/vagrant_data`.  However, we will do this from within the Vagrant VM so we will defer this to Step F below.

For now we'll just leave you with a tip: **Use an absolute path for your guest directory**.  Vagrant will complain if you use a relative path, such as :code:`./vagrant_data`.  You should have permission to create a directory that branches off the root directory as in this example.  If this gives you problems or if you just prefer to have the vagrant data directory branch from your home directory, you can set your guest directory to be :code:`/home/vagrant/vagrant_data`.

On a related note: your default user name when you enter Vagrant will be :code:`vagrant` and your home directory will be :code:`/home/vagrant`.  If you want to change this you can do so by adding a line like this to your Vagrantfile:

.. code:: bash

   config.ssh.username = 'vagabond'	  

For more information, and more options, see the `Vagrant documentation <https://www.vagrantup.com/docs/vagrantfile/ssh_settings.html>`_.

Once both of these directories are created and synchronized, all the contents of the guest directory :code:`/vagrant_data` (within the Vagrant virtual machine) will be accessible from the host directory :code:`$HOME/singularity-vm/vagrant_data` (on your Mac).  So, you will be able to transfer files at will.

.. _create-vm:

F: Create your virtual machine and install Singularity
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
According to the `Vagrant web site <https://www.vagrantup.com/docs/cli/up.html>`_, the most important command in Vagrant is the :code:`vagrant up` command.  This is what creates and configures the virtual machine.  Or, if you have already created the virtual machine previously and then shut it down with the :code:`vagrant halt` command (see :ref:`below <vagrant-jedi>`), then :code:`vagrant up` will re-establish it.   Once it is established, you can log into your virtual machine with the :code:`vagrant ssh` command.  So, enter this to create and log in to your linux VM:  

.. code:: bash

    vagrant up
    vagrant ssh

You are now in a linux Ubuntu operating system; the Vagrant VM.

The next step is to create the guest directory that was discussed in Step E.  So, in the example used there, we would enter:

.. code:: bash

    mkdir /vagrant_data

Now we are finally ready for Singularity.  If you used configuration option 1 (singularityware) in Step C, then Singularity is already installed and you can proceed to Step G.  If you used configuration option 2 above (Ubuntu bento box), you can now proceed to install Singularity as described in our :ref:`Singularity installation instructions <install-sing-from-vagrant>`.  For convenience we repeat those instructions here (you may wish to copy and paste this into your terminal):

.. code:: bash

    # from a Vagrant linux virtual machine
    sudo apt-get update
    sudo apt-get -y install build-essential curl git sudo man vim autoconf libtool
    git clone https://github.com/singularityware/singularity.git
    cd singularity
    ./autogen.sh
    ./configure --prefix=/usr/local
    make
    sudo make install

    
.. _mac-x-forwarding:


G: Enable X Forwarding (Optional)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
If you'd like to use graphical tools such as :ref:`kdbg <kdbg>` or :code:`emacs` from within the Singularity container, you will need to set up X forwarding.  For this you will need to first install `XQuartz <https://www.xquartz.org/>`_, if it's not already installed.

After XQuartz is up and running, it's best to proceed from inside the :ref:`JEDI Singularity container <build_env>`.  If you have installed Singularity as described in Step F, then you can download the JEDI image file and enter the Singularity container as described :ref:`here <build_env>`:

.. code:: bash

   singularity pull shub://JCSDA/singularity
   singularity shell --bind /vagrant_data -e JCSDA-singularity-master-latest.simg

Now, from within the Singularity container, you need to set your :code:`DISPLAY` environment variable.  The appropriate value depends on which configuration option you chose in Step C.  If you chose option 1 (singularityware), then you should set your display as follows:

.. code:: bash

   #Configuration option 1 (singularityware)
   export DISPLAY=localhost:10.0

If you chose option 2 (ubuntu bento box), then you should set your display as follows:

.. code:: bash

   #Configuration option 2 (bento/ubuntu-16.04)
   export DISPLAY=10.0.2.2:0.0

These are the addresses that Vagrant uses for the local host (i.e. your Mac) by default.  You may wish to add the appropriate display definition to an initialization script  that you can run every time you enter the singularity container as described :ref:`here <startup-script>`.

Now you have to tell your Mac to accept graphical input from the virtual machine.  The default address that Vagrant uses for the virtual machine is :code:`127.0.0.1`.  So, you can go to a window that is running your local Mac OS and enter

.. code:: bash

   #On your Mac
   xhost + 127.0.0.1
   
To test the display, you can start a graphical application.  For example:

.. code:: bash

   emacs & 

This should work for most users (meaning it should bring up the emacs GUI).  If it does, then **you are done with this section** and you can proceed to the :ref:`next section <vagrant-jedi>`.  If the display still does not work, then you may need to explicitly grant Singularity access to your display through :code:`xauth` as we now describe.

Exit singularity and vagrant.  Then edit your Vagrantfile and add these two lines (at the bottom, just before the :code:`end` in the main :code:`Vagrant.configure("2") do |config|` loop will do)

.. code:: bash

   config.ssh.forward_agent = true
   config.ssh.forward_x11 = true

Then recreate your vagrant VM, log in, and enter the Singularity container:

.. code:: bash

   vagrant halt # restart vagrant	  
   vagrant up 
   vagrant ssh
   singularity shell --bind /vagrant_data -e <singularity-image-file>

Now create an :code:`.Xauthority` file and generate an authorization key for your display:

.. code:: bash

   touch ~/.Xauthority
   xauth generate 10.0.2.2:0.0 . trusted
   
You can list your new authorization key as follows:

.. code:: bash

   xauth list
   
There should be at least one entry, corresponding to the display you entered in the :code:`xauth generate` commmand above (you can ignore other entries, if present).  For example, it should look something like this:  

.. code:: bash

   10.0.2.2:0  MIT-MAGIC-COOKIE-1  <hex-key>
   
where :code:`<hex-key>` is a hexadecimal key with about 30-40 digits.  Now, copy this information and paste it onto the end of the :code:`xauth add` command as follows:
   
.. code:: bash

   xauth add 10.0.2.2:0  MIT-MAGIC-COOKIE-1  <hex-key>

If all worked as planned, this should grant permission for singularity to use your display.   
   
.. _vagrant-jedi:

H: Exit Singularity and Vagrant
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
If you did the optional Step G then you are now in the singularity container.  To return to your Mac OS, you have to enter :code:`exit` twice, once to exit the Singularity container and once to log out of the Vagrant virtual machine:

.. code:: bash

   exit # to exit Singularity
   exit # to exit Vagrant

Now, to temporarily shut down your virtual machine, enter

.. code:: bash

   vagrant halt

Note that this is very different than the :code:`vagrant destroy` command, which is dangerous and should be used with great caution.  As the name of the command suggests, vagrant destroy will completely destroy the virtual machine along with all the files and data it contains.  So, if you do this, you will have to re-create the virtual machine and re-install Singularity, along with any JEDI bundles that you are working with.  And, you will lose any files that you have been editing.  By contrast, vagrant halt will merely shut down the virtual machine, retaining all your files.  This will allow you to gracefully log out of your workstation or laptop without harming your JEDI environment.  For further details see the `Vagrant documentation <https://www.vagrantup.com/docs/cli/halt.html>`_.


Working with Vagrant and Singularity
------------------------------------

Once you have Vagrant and Singularity all set up as discussed above, your daily workflow may be as follows.  You might start by going to the directory where you put your Vagrantfile.  Then fire up and log in to your virtual machine.

.. code:: bash

  cd $HOME/singularity-vm
  vagrant up
  vagrant ssh
  
From there you can enter the Singularity container and (optionally) run your startup script:

.. code:: bash

  singularity shell --bind /vagrant_data -e JCSDA-singularity-master-latest.simg
  source startup.sh

Now you're in the Singularity container and you can do whatever you wish: edit files, build, compile and run JEDI, etc.  If you want to use X-forwarding you'll have to explicitly tell your Mac to accept graphical input from the Vagrant VM as described in :ref:`Step G <mac-x-forwarding>` above:

.. code:: bash

   #On your Mac
   xhost + 127.0.0.1

You may be tempted to automate this so you don't have to enter this command every time you start up your virtual machine.  However, this is more subtle than you might expect.  Since this is the IP address of localhoat, placing this command in your :code:`.bash_profile` file might cause your terminal application to hang when you first start it up because localhost is not yet defined.  You can avoid this by adding :code:`xhost +` to your :code:`.bash_profile` but be careful with this because it may open you up to security vulnerabilities by allowing clients to connect to your machine from any remote host.  Entering the explicit command above or putting it in a bash script that you execute manually every time you log in is somewhat inconvenient but much safer.

When you're done for the day you can exit and shut down the VM:

.. code:: bash

   exit # to exit Singularity
   exit # to exit Vagrant
   vagrant halt # to shut down the virtual machine
