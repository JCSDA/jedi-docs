Vagrant (for Mac and Windows)
=============================

In order to set up the JEDI environment with :doc:`Singularity <singularity>`,
you'll need to first set up a Linux operating system. We will often focus on
Ubuntu for illustration purposes but if you prefer other varieties of Linux,
these are also available from the Virtualbox provider that we describe below.

So, if you're using a Mac or Windows computer, you will want to set up a local,
self-contained Linux environment within your broader operating system. This is
commonly called a **virtual machine** (VM). Once you have a linux VM up and running,
you will be able to install :doc:`Singularity <singularity>`
and triumphantly enter the corresponding JEDI Container.

This can all be achieved using an application called `Vagrant <https://www.vagrantup.com/>`_,
which is developed and distributed by a company called Hashicorp. Though we will
sometimes refer to Vagrant as the virtual machine provider, the actual Linux
operating system is ultimately provided by Oracle's `VirtualBox <https://www.virtualbox.org/>`_ software package.
Vagrant is essentially a tool will allow you to build, configure, and manage a VirtualBox operating system.
In particular, we will use Vagrant and VirtualBox to create an Ubuntu virtual
machine on your Mac workstation or laptop. We'll then populate that Linux VM with
specific JEDI software tools (compilers, ecbuild, etc.) using :doc:`Singularity <singularity>`.

From this brief introduction, it is clear that you do not need to worry about
Vagrant or VirtualBox if your working machine (whether it is a workstation,
laptop, or HPC system) is already running Linux and/or is already running Singularity.
By *working machine* we mean whatever machine you plan to compile and run JEDI on.

You *do* need Vagrant and VirtualBox (or something equivalent) if you wish to
run JEDI from a Mac or Windows machine. Though you can use Vagrant for both platforms,
we focus here on macOS.

We refer Windows users to the `Vagrant download page <https://www.vagrantup.com/downloads.html>`_
where you can download a binary implementation for windows and install it using the
Windows package manager. After installing Vagrant, you may wish to return to this
document for tips on how to configure it for JEDI (skipping Step A of the next section).

.. warning::

    On macOS at least, the virtualization that underpins the container environments can have heavily
    degraded performance with MPI oversubscription (running more tasks than cores (virtual cores in
    this case)). As an example, a ctest using 12 MPI processes on a VM providing 6 virtual cores can
    take hundreds of times longer to run than in a native environment.

Installing and Configuring Vagrant
----------------------------------

A: Install Vagrant and VirtualBox
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

As with Windows, you can install Vagrant on a Mac by downloading a pre-compiled binary
package from the `Vagrant Download Page <https://www.vagrantup.com/downloads.html>`_.
However, we recommend that you install with Homebrew as described below to give
you more flexibility in managing both vagrant and virtualbox.

Before you begin you should install or update :doc:`Homebrew </inside/developer_tools/homebrew>`.
You'll need a relatively recent version in order to use the :code:`cask` extension.
Once you have done this, you can proceed as follows:

.. code-block:: bash

  brew cask install virtualbox
  brew cask install vagrant
  brew cask install vagrant-manager

B: Download JEDI Configuration File
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Now we need to tell Vagrant what type of virtual machine we want to create and how to
provision it with the software we need.  This is done by means of a configuration
file that goes by the default name of :code:`Vagrantfile`.

So, to proceed, you should first create a directory where you will place your
Vagrantfile. This is where you will launch your virtual machine.  **You should also
create a subdirectory called** :code:`vagrant_data` **that we will use**.
If you don't create this directory, you will get an error when vagrant tried to mount it.


You can call the parent directory whatever you wish but if you change the name of
the :code:`vagrant_data` directory then you will also have to :ref:`change the Vagrantfile <vagrant-customize>`.

.. code-block:: bash

  mkdir $HOME/jedi-vm
  cd $HOME/jedi-vm
  mkdir vagrant_data

In what follows, we will refer to this as the home directory of your Vagrant Virtual Machine (VM).

We at JCSDA provide a Vagrantfile that can be used to create a virtual machine
that is pre-configured to build and run JEDI, with both Singularity pre-installed.

    `Download the JEDI Vagrantfile here <http://data.jcsda.org/containers/Vagrantfile>`_

Or, alternatively, you can retrieve it with

.. code-block:: bash

	  wget http://data.jcsda.org/containers/Vagrantfile


Place this Vagrantfile in the home directory of your Vagrant VM.

.. warning::

   If you already have a Vagrant VM installed and you want to install a new one
   (particularly using a Vagrantfile in the same directory as before), then you may
   have to fully delete the previous VM first to avoid any conflicts.
   Instructions on how to do this are provided in the :ref:`Deleting a Vagrant VM <vagrant-destroy>` section below.

.. note::

   If you have problems with this JEDI Vagrantfile, there `an alternative Vagrantfile
   that you can download <http://data.jcsda.org/containers/Vagrantfile_centos>`_
   that expands the disk storage using the :code:`disksize` plugin to Vagrant.
   This also comes with Singularity pre-installed.  After downloading this file,
   it's easiest to change its name to :code:`Vagrantfile` and then run :code:`vagrant up` again.
   However, before trying this make sure that you either :ref:`destroy your previous VM <vagrant-destroy>`
   or create the new VM from a different directory and give it a different
   name (edit the Vagrantfile and search for **jedibox**).

C: Launch your Virtual Machine
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Now you are ready to create your virtual machine by running this command:

.. code-block:: bash

	  vagrant up

The first time you run this command, it will take several minutes.
Vagrant is installing Singularity and a few other supporting software packages.
Once created, these will be part of your virtual machine and they do not need to
be re-installed (unless you explicitly tell vagrant to do so).

So, when this command finishes, you can log into your virtual machine with

.. code-block:: bash

	  vagrant ssh

Now you are in a linux environment (CentoOS 7). From here you can pull the JEDI container of your choice,

* :ref:`Click here to proceed with JEDI Singularity Container <build_env>`

Depending on which Vagrantfile you use, your VM may run either the Ubuntu or the
CentOS operating system. However, you shouldn't need to be too concerned about
this because you'll be working mostly in the Singularity container which runs Ubuntu.
So, if you work within the container, you will be in an Ubuntu environment regardless of
which OS your vagrant VM is running.

.. _vagrant-jedi:

D: Exit Container and Vagrant
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Normally you will be spending your time working in the Singularity container.
When you're finished working for the day, it's important to remember to
enter :code:`exit` twice, once to exit the container and once to log out of the
Vagrant virtual machine:

.. code-block:: bash

   exit # to exit Singularity
   exit # to exit Vagrant

Now, to temporarily shut down your virtual machine, enter

.. code-block:: bash

   vagrant halt

Note that this is very different than the :code:`vagrant destroy` command,
which should be used with caution.  As the name of the command suggests, vagrant
destroy will completely destroy the virtual machine along with all the files and data it contains.
So, if you do this, you will have to re-create the virtual machine and re-install
any JEDI bundles that you are working with. And, you will lose any files that
you have been editing. By contrast, vagrant halt will merely shut down the virtual machine,
retaining all your files. This will allow you to gracefully log out of your workstation
or laptop without harming your JEDI environment. For further details see the `Vagrant
command reference <https://www.vagrantup.com/docs/cli/halt.html>`_.

.. _mac-x-forwarding:


E: Enable X Forwarding (Optional)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
If you'd like to use graphical tools such as :code:`emacs` from within the
Singularity container, you will need to set up X forwarding. If you're doing this
on a Mac, you will first need to install `XQuartz <https://www.xquartz.org/>`_,
if it's not already installed.

After XQuartz is up and running, you can create and enter your VM as described
in step C above. Next you will have to set your :code:`DISPLAY` environment variable
to use your local machine. This is best done from within the container because
environment variables set outside the container may not be accessible from within.

.. code-block:: bash

   # inside the container
   export DISPLAY=10.0.2.2:0.0

You may wish to add the appropriate display definition to an initialization script
that you can run every time you enter the singularity container as described :ref:`here <startup-script>`.
Then, enter this on your host machine (i.e. your Mac or Windows machine), to grant the VM permission to display

.. code-block:: bash

   #On your Mac
   xhost + 127.0.0.1

These are the addresses that Vagrant uses for by default. You may wish to add the
appropriate display definition to an initialization script  that you can run every
time you enter the singularity container as described :ref:`here <startup-script>`.

To test the display, you can start a graphical application.  For example:

.. code-block:: bash

   # inside the container
   emacs &

**Troubleshooting Tips**

If the above procedure did not work, there are several things to try.

First, if you have a Mac, make sure XQuartz is installed.  You may need to
re-boot your VM for a new installation to take effect.

Next, try running emacs from outside the container to see if the problem is with
Vagrant or with the container.

If you used a different Vagrant box than the one specified in the JEDI Vagrantfile
(for example, if you used one from Singularityware), if might help to set your
DISPLAY variable in the container to this instead:

.. code-block:: bash

   export DISPLAY=localhost:10.0

If the display still does not work, then you may need to explicitly grant Vagrant
access to your display through :code:`xauth` as we now describe.

Exit the container and exit vagrant. Then edit your Vagrantfile and add these
two lines (at the bottom, just before the :code:`end` in the main :code:`Vagrant.configure("2") do |config|` loop will do)

.. code-block:: bash

   config.ssh.forward_agent = true
   config.ssh.forward_x11 = true

Then recreate your vagrant VM, log in, and enter the container (for example, for Singularity):

.. code-block:: bash

   vagrant halt # restart vagrant
   vagrant up
   vagrant ssh
   singularity shell --bind ./vagrant_data -e <singularity-image-file>

Now create an :code:`.Xauthority` file and generate an authorization key for your display:

.. code-block:: bash

   touch ~/.Xauthority
   xauth generate 10.0.2.2:0.0 . trusted

You can list your new authorization key as follows:

.. code-block:: bash

   xauth list

There should be at least one entry, corresponding to the display you entered in
the :code:`xauth generate` command above (you can ignore other entries, if present).
For example, it should look something like this:

.. code-block:: bash

   10.0.2.2:0  MIT-MAGIC-COOKIE-1  <hex-key>

where :code:`<hex-key>` is a hexadecimal key with about 30-40 digits.
Now, copy this information and paste it onto the end of the :code:`xauth add` command as follows:

.. code-block:: bash

   xauth add 10.0.2.2:0  MIT-MAGIC-COOKIE-1  <hex-key>

If all worked as planned, this should grant permission for vagrant to use your display.


.. _vagrant-customize:

Customizing the Vagrantfile (optional)
--------------------------------------------

The JEDI Vagrantfile you downloaded in Step B above is already provisioned with
everything you need to run JEDI, by means of the Singularity software containers.

However, it's useful to point out a few configuration options that some users may wish to customize.

Creating your own Vagrantfile
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

First comes the choice of machine. The JEDI Vagrantfile uses a CentOS 7 operating
system but there are a number of other options available, particularly with the
well-maintained `bento boxes <https://app.vagrantup.com/bento>`_ provided by Vagrant.
You may wish to maintain multiple virtual machines with different Linux operating systems.

For example, you can create your own Vagrantfile by entering something like this:

.. code-block:: bash

   vagrant init bento/ubuntu-20.04


When you then run :code:`vagrant up`, this will create an Ubuntu 20.04 operating system.
You can then install :ref:`Singularity <Singularity-install>` manually.

The makers of Singularity also provide their own Vagrant box, with Singularity pre-installed:

.. code-block:: bash

   vagrant init sylabs/singularity-3.0-ubuntu-bionic64
   

Allocating Resources for your Virtual Machine
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The JEDI Vagrantfile comes pre-configured to allocate 16GB of memory and 18 virtual
CPUS to the VM. This is the minimum resource allocation to run many tests and applications.
Furthermore, if you create your own Vagrantfile, the default resource allocation will likely
be insufficient to run JEDI.

You can change these resource allocations by editing the Vagrantfile.
Look for the following section that specifies the provider-specific configuration (variable names may differ).
Change the :code:`vb.memory` (in MB) and :code:`vb.cpus` fields as shown here:

.. code-block:: bash

   config.vm.provider "virtualbox" do |vb|

     # [...]

     # Customize the amount of memory on the VM:
     vb.memory = "16384"

     # Customize the number of cores in the VM:
     vb.cpus = "18"

     # [...]

   end

File transfer between your Mac and the VM
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

In Step B above we created a directory called :code:`vagrant_data`.
The JEDI Vagrantfile is configured to use this directory to transfer files between
your host machine (which may be running macOS or Windows) and your VM.
Within the VM, this directory is mounted as :code:`$HOME/vagrant_data`.

To change this, you can edit the Vagrantfile and find the section for a **synced folder**:

.. code-block:: bash

    # Share an additional folder to the guest VM. The first argument is
    # the path on the host to the actual folder. The second argument is
    # the path on the guest to mount the folder. And the optional third
    # argument is a set of non-required options.
    c.vm.synced_folder "vagrant_data", "/home/vagrant/vagrant_data"


The first argument specifies the directory on the host machine, relative to the
home directory of your Vagrant VM (i.e. the directory where the Vagrantfile is).
The second specifies the path of the directory on the VM. You can change these
paths and/or names if you wish but **make sure the host directory exists before
running vagrant up** so it can be properly mounted.

It might also be necessary to create the mount point from within the vagrant VM:

.. code-block:: bash

    mkdir ~/vagrant_data # from within the VM, if necessary

And, here is another tip: **Use an absolute path for your guest directory**.
Vagrant will complain if you use a relative path, such as :code:`./vagrant_data`.
You will need root permission if you want to branch off of root (for example :code:`/vagrant_data` is
the default mounting if you run :code:`vagrant init`.)

On a related note: your default user name when you enter Vagrant will be :code:`vagrant`
and your home directory will be :code:`/home/vagrant`.
If you want to change this you can do so by adding a line like this to your Vagrantfile:

.. code-block:: bash

   config.ssh.username = 'vagabond'

For more information, and more options, see the `Vagrant documentation <https://www.vagrantup.com/docs/vagrantfile/ssh_settings.html>`_.


Working with Vagrant and the JEDI Container
-------------------------------------------

Once you have Vagrant and a container provider
all set up as discussed above, your daily workflow may be as follows.
You might start by going to the directory where you put your Vagrantfile.
Then fire up and log in to your virtual machine.

.. code-block:: bash

  cd $HOME/jedi-vm
  vagrant up
  vagrant ssh

From there you can enter the container and (optionally) run your startup script.
For example:

.. code-block:: bash

  singularity shell -e <singularity-image-file>
  source startup.sh


Now you're in the JEDI container and you can do whatever you wish: edit files,
build, compile and run JEDI, etc. If you want to use X-forwarding you'll have to
explicitly tell your Mac to accept graphical input from the Vagrant VM as
described in :ref:`Step G <mac-x-forwarding>` above:

.. code-block:: bash

   #On your Mac
   xhost + 127.0.0.1

You may be tempted to automate this so you don't have to enter this command every
time you start up your virtual machine.  However, this is more subtle than you might expect.
Since this is the IP address of localhost, placing this command in your :code:`.bash_profile`
file might cause your terminal application to hang when you first start it up because localhost is not yet defined.
You can avoid this by adding :code:`xhost +` to your :code:`.bash_profile` but be
careful with this because it may open you up to security vulnerabilities by allowing 
clients to connect to your machine from any remote host.
Entering the explicit command above or putting it in a bash script that you execute
manually every time you log in is somewhat inconvenient but much safer.

When you're done for the day you can exit and shut down the VM:

.. code-block:: bash

   exit # to exit Singularity
   exit # to exit Vagrant
   vagrant halt # to shut down the virtual machine

.. _vagrant-destroy:

Deleting a Vagrant VM
---------------------

When you shut down a Vagrant virtual machine (VM) with :code:`vagrant halt`, it's
like shutting down your laptop or workstation.  When you restart the VM, you can
pick up where you left off.  You'll see all the files and directories that were there before.

This is usually desirable. However, it does mean that the VM is occupying disk
space on your machine even when it is suspended. If you have created multiple VMs,
this can add up.  So, it is often useful to delete a VM if you are done using it.

To check vagrant's status at any time enter

.. code-block:: bash

    vagrant global-status

This is a useful command to know about. It will tell you all the VMs vagrant knows
about on your computer including the path where the Vagrantfile is located and the state.
A :code:`vagrant up` command will put the VM in a :code:`running` state while a :code:`vagrant halt`
command will put the VM in a **poweroff** state.

If you want to delete one or more of these VMs, the first step is to **save
any files you have on the VM that you want to preserve**. This can be done by
moving them to the :code:`~/vagrant_data` directory which will still exists on your
local computer after the VM is deleted.

Now, the best way to proceed is to go to the directory where the vagrant file is and enter:

.. code-block:: bash

    vagrant destroy # enter y at the prompt
    rm -rf .vagrant

The first command deletes all of the disks used by the virtual machine, with the
exception of the cross-mounted :code:`vagrant_data` directory which still exists
on your local computer.  The second command resets the vagrant configuration.
This is particularly important if you re-install a new VM where another VM had
been previously. If you skip this step, :code:`vagrant up` may give you errors
that complain about mounting the :code:`vagrant_data` directory ("...it seems
that you don't have the privileges to change the firewall...").

This is a start, but you're not done. As mentioned :doc:`at the top of this
document <vagrant>`, Vagrant is really just an interface to VirtualBox, which
provides the Linux OS.  The Virtualbox VM that contains the Linux OS still exists
and is still using resources on your computer. To see the VirtualBoxes that are
currently installed though Vagrant, run

.. code-block:: bash

    vagrant box list

If you used the JEDI Vagrantfile as described in Step B above, then you'll see
one or more entries with the name :code:`centos/7`. The first step here is to
prune any that are not being used any more with

.. code-block:: bash

    vagrant box prune

However, even this might not delete the VM you want to delete.
Run :code:`vagrant list` to see if it is still there and if it is, you can delete it with

.. code-block:: bash

    vagrant box remove centos/7

..or ubuntu or singularityware or whatever name is listed for the box you want to delete.

In some cases it might also help to delete the hidden :code:`.vagrant` file that
is created by vagrant in the same directory as your Vagrantfile.  So, from that directory, enter:

.. code-block:: bash

    rm -rf .vagrant

Now, this should be sufficient for most situations. Most users can stop here with
confidence that they have deleted their unwanted VMs and have freed up the resources
on their local computer.

However, it is possible that there might still be VirtualBox VMs on your machine
that Vagrant has lost track of. You might notice this if you try to create a new
VM with :code:`vagrant up` and it complains that "A VirtualBox machine with the
name jedibox already exists" (or a similar error message).

If this is the case, you can run VirtualBox directly to manage your VMs. This
can be done through the command line with the :code:`vboxmanage` command
(run :code:`vboxmanage --help` for information) but we recommend the **VirtualBox GUI**,
which is more user-friendly.

To access the GUI on a Mac or Windows machine, just go to your Applications
folder and double click on the VirtualBox icon. There you will see a complete
list of all the VirtualBox VMs installed on your system and you can delete any
that you don't want by selecting the **machine** menu item and then **remove**.

.. _tunneling-to-host-from-singularity:

Tunneling to Host from Singularity: jupyter-lab Example
-------------------------------------------------------

Tunneling from Singularity to the host can enable several useful ways of interacting
between the host and the container. The benefits are multiple but some of the syntax
for doing it could be described as obscure. A motivating example use case is
running ``jupyter-lab`` in Singularity and accessing it from the host machine.
This not only allows the user to run jupyter notebooks from the browser, a terminal
in ``jupyterlab`` can also be used to build and run JEDI repositores. The general
outlines of establishing the tunnel below are followed by a recipe for installing
python virtual environments in the container, including ``jupyter-lab``.

Tunneling starts in the Vagrantfile, search "forwarded_port" and set the following
line as follows (with your choice of port, we use 8111 throughout):

.. code-block:: bash

   config.vm.network "forwarded_port", guest: 8111, host: 8111

On the host machine, restart Vagrant (if necessary) and enter Vagrant using the special syntax:

.. code-block:: bash

   vagrant halt  # if running
   vagrant up
   vagrant ssh -- -L 8111:localhost:8111

Now inside Vagrant, start Singularity thusly:

.. code-block:: bash

   singularity shell -e jedi-clang-mpich-dev_latest.sif portmap=8111:8111/tcp

The above should establish the tunnel from the host through Vagrant to Singularity.
Next we install a python virtual environment with ``jupyter-lab`` and test the tunnel.
We choose to install our virtual environment(s) in a directory mounted into Vagrant from the host.
For example, the ``vagrant_data`` directory as specified above in the Vagrantfile:

.. code-block:: bash

    config.vm.synced_folder "./vagrant_data", "/home/vagrant/vagrant_data",
      mount_options: ["dmode=775,fmode=777"]

The following script is to be *sourced* inside Singularity, configring the ``venv_dir``
variable to install the virtual environment in a synced directory. The example
script installs a virtual environment and ``jupyter-lab`` in that resulting environment:

.. code-block:: bash

   #!/bin/bash

   # Configure where to install:
   venv_dir=~/vagrant_data/venvs/my_venv

   # ----------------------------------------------------
   (return 0 2>/dev/null) && sourced=1 || sourced=0
   if [[ sourced -eq 0 ]]; then
       echo "This script must be sourced."
       return 1
   else
       echo "Setting up virtual env: $venv_dir"
   fi

   if [ -d $venv_dir ]; then
       echo "The environment ($venv_dir) already exists, returning."
       return 2
   fi

   export PATH=$PATH:/home/vagrant/.local/bin/
   python -m pip install --user virtualenv

   # If subsequent installation troubles arise,
   # run this line to update wheels in venv and try again:
   # virtualenv --upgrade-embed-wheels True $venv_dir

   virtualenv $venv_dir
   source $venv_dir/bin/activate
   pip install jupyter jupyterlab

   return 0

The above script must be sourced in ``bash`` and will produce an error if otherwise
executed. If the script completes successfully, the virtual environment will be activated.
In future Singularity sessions, it can be activated as normal with virtual environments,
using the ``$venv_dir`` specified in the script to locate the ``activate`` script:

.. code-block:: bash

   source ~/vagrant_data/venvs/my_venv/bin/activate

Then we can navigate to the desired root directory and start ``jupyter-lab``:

.. code-block:: bash

   cd /the/path/of/choice
   jupyter-lab --no-browser --port 8111

Jupyter will print output to the terminal, including a url to use to connect from
a browser. Copy and paste the URL from jupyter into your host's browser and go!

We note that in the current containers (March 2021), the following harmless warning
is printed in the `jupyter-lab` session when the browser connects: `Could not determine
jupyterlab build status without nodejs`. Also noteworthy is that testing the tunnel
on any machine (Singularity, Vagrant, or the host) can be done via

.. code-block:: bash

   curl localhost:8111

If working, ``jupyter-lab`` will register GETs in the terminal resembling

.. code-block:: bash

   [I 2021-01-05 22:25:35.249 ServerApp] 302 GET / (::1) 0.62ms
