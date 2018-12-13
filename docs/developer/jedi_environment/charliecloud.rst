.. _top-charliecloud:

Charliecloud
=======================

`Charliecloud <https://hpc.github.io/charliecloud/index.html>`_ is similar to :doc:`Singularity <singularity>` in that it is a software container service.  However, it has one significant advantage over Singularity in that **it does not require root privileges** to install the Charliecloud software or to run Charliecloud containers.  This can be a huge advantage, particularly on HPC systems where users generally do not have root privileges and where system administrators are often reluctant to install singularity because of security concerns.

Charliecloud was developed and is still maintained by software developers at Los Alamos National Laboratory.  We refer you to to their `Documentation pages <https://hpc.github.io/charliecloud/index.html>`_ for further information about the project, for instructions on how to build containers and other resources, and for troubleshooting any problems.  Note in particular the `Charliecloud command reference <https://hpc.github.io/charliecloud/command-usage.html>`_.

In the documentation that follows we focus only on what you need to know as a user of JEDI.

.. warning::

   See the `Charliecloud documenation <https://hpc.github.io/charliecloud/index.html>`_ (particularly the Installation and Tutorial sections) for tips and warnings about using Charliecloud.  For example, there is a known bug on the **Cray Linux Environment** that causes nodes to crash just before exiting some Charliecloud jobs (they do have a workaround).    Also, if you have a large number of MPI processes that each invokes the same Charliecloud container, it could overwhelm a network file system.  For JEDI, we've run MPI jobs from within the container and have not yet noticed a problem with this (please let us know if you do!).

.. _Charliecloud-install:

Installing Charliecloud
------------------------

The Charliecloud Documentation pages have thorough `Installation Instructions <https://hpc.github.io/charliecloud/install.html>`_.  This is the most up-to-date documentation available and if you have any problems with the procedure describe here we refer to you that page for troubleshooting.

Installing on Mac OS and Windows systems
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Like Singularity, Charliecloud relies on linux mount namespaces to control the set of filesystem mounts that are visible to a process.  Neither Mac nor Windows operating systems currently support such mount namespaces.

So, if you are using a Mac or Windows laptop, we recommend that you install a virtual machine provider like `Vagrant <https://www.vagrantup.com/>`_.  Instructions on how to do so are provided on our :doc:`JEDI Vagrant Page <vagrant>`.  This will allow you to create a linux virtual machine on your computer where you can install Charliecloud and run JEDI.

You are free to choose what type of linux operating system you want to have for your Vagrant virtual machine.  In much of what follows, we will use ubuntu as as an example, and in particular ubuntu 18.04.  We recommend this environment for running Charliecloud, in part because it has a more up-to-date version of :code:`bash` than the ubuntu 16.04 bento box available from virtualbox.  However, most recent linux varieties (including ubuntu 16.04) should be sufficient, as long at they support mount namespaces (see the :ref:`linux installation section <linux-install>` for further information.

.. _linux-install:

Installing on Linux Systems
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

To install Charliecloud, you'll need a relatively recent version of linux that is capable of creating mount namespaces.  Most linux implementations from the last few years should be sufficient.  If you want to check the version of the linux kernel, you can enter:

.. code:: bash

  uname -r

Charliecloud recommends a version of 4.4 or later.

You'll also need a C compiler and some basic software tools.  These may already be installed if you are using an HPC system or a linux PC. However, if you are starting from a bare installation, such as a Vagrant virtual machine or a cloud computing instance (e.g. Amazon EC2), you may need to install these yourself.  On ubuntu or Debian systems you can do this with:

.. code:: bash

  sudo apt-get update
  sudo apt-get install build-essential python

Or, on CentOS, Fedora, Amazon Linux, and similar systems, you might instead enter:  
  
.. code:: bash

  sudo yum update
  sudo yum groupinstall "Development Tools"

These commands require root access.  If you do not have root access, chances are good that the required software is already installed.

The next step is to clone the Charliecloud repository on GitHub, build it, and install it into a directory of your choice.  Here we build and install the code into the user's home directory:

.. code:: bash

  mkdir ~/build
  cd ~/build
  git clone --recursive https://github.com/hpc/charliecloud.git
  cd charliecloud
  make
  make install PREFIX=$HOME/charliecloud

Unless there were problems, Charliecloud should now be installed in the user's home directory, in the subdirectory :code:`charliecloud`.  If you wish to test the installation (optional), `run the Bats test suite as described in the Charliecloud Documentation <https://hpc.github.io/charliecloud/test.html>`_.

Now add the Charliecloud executables to your path.  You may wish to do this interactively when you install Charliecloud for the first time but we recommend that you also put it in a startup script such as :code:`.bash_profile`.

.. code:: bash

  export PATH=$PATH:$HOME/charliecloud/bin

.. note::

   If you do decide to run the Charliecloud test suite you should be aware that some of these tests require root privileges.  If you do not have root privileges, you can disable these tests by setting this environment variable before running :code:`make test`:

   .. code:: bash

	  export CH_TEST_PERMDIRS=skip
  
.. _build_charliejedi:

Building the JEDI environment 
-------------------------------

Once Charliecloud is installed on your system, the next step is to make a home for the JEDI Charliecloud container and download it as follows (you may also have to install wget if it's not included in the developer tools mentioned above):

.. code:: bash

   mkdir -p ~/jedi/ch-container
   cd ~/jedi/ch-container
   wget http://data.jcsda.org/containers/ch-jedi-latest.tar.gz

This looks like a normal gzipped tar file.  However, **you should not upack it with** :code:`tar`! Instead, unpack it with this command:

.. code:: bash

   ch-tar2dir ch-jedi-latest.tar.gz .

This may take a few minutes so be patient.  When done, it should give you a message like :code:`./ch-jedi-latest unpacked ok` and it should have created a directory by that same name.   In our example, this directory would be located in :code:`~/jedi/ch-container/ch-jedi-latest`.

This is the JEDI Charliecloud container.  It's functionally equivalent to a Singularity image file but it appears as a directory rather than a single file.  Furthermore, that directory contains a complete, self-contained linux filesystem, complete with its own system directories like :code:`/usr/local`, :code:`/bin`, and :code:`/home`.

To enter the Charliecloud container, type:

.. code:: bash

   ch-run -c $HOME ~/jedi/ch-container/ch-jedi-latest -- bash

Let's reconstruct this command to help you understand it and customize it as you wish.   

The :code:`ch-run` command runs a command in the Charliecloud container.  

The :code:`-c $HOME` option tells Charliecloud to enter the container in the user's home directory, which is the same inside and outside the container.  If this option is omitted, you will enter the container in the root directory.  Typing :code:`cd` will then place you in your home directory.

The :code:`~/jedi/ch-container/ch-jedi-latest` argument is the name of the container you want Charliecloud to run. This is the name of the directory created by the :code:`ch-tar2dir` command above.  If you run this from the container's parent directory, in this case :code:`~/jedi/ch-container`, then you can omit the path.

Finally, we have to tell :code:`ch-run` what command we want it to run.  The command (including options and arguments) that comes after the double hyphen :code:`--` will be executed within the container.  If you were to run a single command, like :code:`-- ls -alh`, then :code:`ch-run` will enter the container, execute the command, and exit.  However, in this example, we started up a bash shell, with :code:`-- bash`.  So, **all commands that follow will be exectued inside the container.  In order to exit the container, you have to explicitly type exit.**  This brings us to this important warning:  

.. warning:: 

   **When you enter the Charliecloud container, your prompt may not change!!** So, it can be very difficult to tell whether or not you are in the Charliecloud container or not.  One trick is to enter the command :code:`eckit-version`.  If you do not have eckit installed on the host system (which may be a vagrant virtual machine or an amazon EC2 instance), then this command will only return a valid result if you are indeed inside the Charliecloud container.  Note that this is different from Singularity, which does change your prompt when you enter the container.

Now, since you are in the container, you have access to all the software libraries that support JEDI.  You can now proceed to build and run JEDI as described :doc:`elsewhere in this documentation <../building_and_testing/building_jedi>`.

For example, to run and test ufo-bundle, you can proceed as follows:

.. code:: bash

    git config --global credential.helper 'cache --timeout=3600'
    mkdir -p ~/jedi/src
    cd ~/jedi/src
    git clone https://github.com/JCSDA/ufo-bundle.git
    mkdir -p ~/jedi/build
    cd ~/jedi/build
    export FC=mpifort
    ecbuild ../src/ufo-bundle
    make -j4
    ctest

.. warning:: 

   On some systems (notably Cheyenne) it may be necessary to explicity add :code:`/usr/local/lib` to your :code:`LD_LIBRARY_PATH` environment variable within the Charliecloud container, as follows:

   .. code::
      
      LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib

Charliecloud Tips
--------------------

If you're running a Charliecloud container from within :doc:`Vagrant <vagrant>`, the most important tip when using Charliecloud (because it is easy to forget) is to **remember to type exit twice** when you are finished working; once to leave the Charliecloud container and a second time to leave Vagrant.

Another important thing to realize (whether you are running Charliecloud from Vagrant, from AWS, from an HPC system, or from anywhere else), is that many directories on the host are still visible to you from within the container.  This includes your home directory.  So, it is easy to access files from within the container - you should be able to see and edit everything in your home directory.  

In addition to the user's home directory, a few system directories are also mounted and accessible from within the container.  This includes :code:`/dev`, :code:`/proc`, and :code:`/sys`.  But, notably, it *does not* include :code:`/usr/local`; This is the whole point of the container - to re-define the software that is installed on your system without conflicting with what you have installed already. 

These mounted directories should be sufficient for many users.  However, you have the option to also mount any additional directories of your choice.  An important example is for Mac or Windows users who run Charliecloud from within a Vagrant virtual machine.  The Vagrant home directory is visible from within the Charliecloud container but this directory is typically not accessible from the host operating system, e.g. MacOS.

In our :doc:`Vagrant documentation <vagrant>` we describe how you can set up a directory that is shared between the host system (Mac OS) and the virtual machine (Vagrant).  From within Vagrant, we called this directory :code:`/home/vagrant/vagrant_data`.  Since this is in our home directory, it should be visible already from within the Charliecloud container so no explicit binding is necessary.

However, what if we were to instead mount the shared directory in :code:`/vagrant_data` (as viewed from Vagrant)?  This is the default behavior in the Vagrantfile as created by the :code:`vagrant init` command.  Since this branches off of the root directory, it would not be visible by default from within the Charliecloud container.  However, You can still mount this (or nearly any other directory of your choice) in the Charliecloud container using the :code:`-b` (or :code:`--bind`) option:

.. code:: bash

  ch-run -b /vagrant_data -c $HOME ch-jedi-latest -- bash

By default, this is mounted in the Charliecloud container as the directory :code:`/mnt/0`.  You can change the mount point **provided that the target directory already exists within the container**.

For example, if you create a directory called :code:`/home/vagrant/vagrant_data` before entering the container, then you can identify that directory as the target for the mount:

.. code:: bash

    ch-run -b /vagrant_data:/home/vagrant/vagrant_data ch-jedi-latest -- bash

Then, when you are inside the container, any files that you put in :code:`/home/vagrant/vagrant_data` will be accessible from Mac OS.  
