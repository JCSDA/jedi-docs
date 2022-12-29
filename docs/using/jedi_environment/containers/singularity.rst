.. _top-Singularity:

Singularity
===========

`Singularity <https://www.sylabs.io/docs/>`_ is arguably the leading provider of
software containers for HPC applications. It was originally developed at
Lawrence Berkeley Labs but then branched off into its own enterprise that is
now called SyLabs.  It is designed to be used for scientific applications on
HPC systems, and to support general scientific use cases.  Singularity encapsulates
your software environment in a single disk **image file** that can be copied to
and invoked on any system on which Singularity itself is installed.
The JEDI environment is contained in one such image file (see :ref:`below <build_env>`).

**For these reasons, Singularity is the recommended container platform for JEDI users and developers on HPC.**

However, Singularity requires root privileges to install. This may not be a
problem on your laptop or PC, but it can be an issue on HPC systems where such
installations can only be done by the system administrator. So, if you are on an
HPC or other system where you do not have root access, we recommend that you
first check to see if Singularity is already installed. It may be.
If not, the next step would be to ask your system administrators to install it.

.. _Singularity-install:

Installing Singularity
----------------------

If you are using a Vagrant virtual machine that you created with the JEDI
Vagrantfile as described on our :doc:`Vagrant page <vagrant>`, then you can
skip this step: Singularity 3.0 is already installed.  Or, if you're running
JEDI somewhere other than your personal computer, Singularity may already be installed.

You can check to see if Singularity is already installed (and if it is, which version is installed) by typing

.. code-block:: bash

  singularity --version

**To use the JEDI container, you'll need Singularity version 3.0 or later.**
If an up-to-date version of Singularity is already installed on your system,
you can skip ahead to :ref:`Using the JEDI Singularity Container <build_env>`.

If an up-to-date version is not available, then you can ask your system administrator
to install or update it. Alternatively, if you have root privileges, then you
can install it yourself as described in the remainder of this section.

As noted :ref:`above <top-Singularity>`, Singularity is not a virtual machine so
it does not build its own operating system. Instead, it must work with the host operating system.
Singularity relies on Linux mount namespaces in order to set up application
environments that are isolated from the host.
Neither Mac OS X nor Windows currently supports mount namespaces.

So, if you are running Mac OS or Windows, then you must first set up a Linux environment.
This requires a proper virtual machine (VM).
The recommended VM provider is `Vagrant <https://www.vagrantup.com/intro/index.html>`_ by HashiCorp,
which can build and configure an appropriate Linux operating system using
Oracle's `VirtualBox <https://www.virtualbox.org/>`_ software package.

  :doc:`If you have a Mac or Windows machine, go here first to install Vagrant, then return to this page <vagrant>`

In short, Vagrant and VirtualBox provide the linux operating system while Singularity
provides the necessary software infrastructure for running JEDI (compilers, cmake, ecbuild, etc)
by means of the :ref:`JEDI singularity image <build_env>`.

Singularity offers comprehensive installation instructions and we refer the reader
there for the most up-to-date information and troubleshooting. To access these
instructions, `first navigate to the Singularity documentation site <https://sylabs.io/docs/>`_.
From there, choose the version of Singularity you wish to install and select the corresponding **HTML** link.
We recommend version 3.0 or later.  Then navigate to **Quick Start - Quick Installation Steps**.

Briefly, the installation process consists of first installing required system
dependencies such as :code:`libssl-dev`, :code:`uuid-dev`, and :code:`squashfs-tools`.
Then the next step is to install and configure the `Go programming language <https://golang.org/doc/install>`_,
which Singularity 3.0 requires.  After following the steps as described on the
Singularity documenation, you can enter :code:`go help` to see if your installation worked.
After you've set up the proper dependencies, you can then download a tar file containing
the Singularity source code, configure it, compile it, and install it.
As described above, this requires root privileges.

.. _build_env:

Using the JEDI Singularity Container
------------------------------------

Once singularity is installed on your system, the rest is easy. The next step is
to download one of the **JEDI Singularity images** from the Sylabs Cloud.
You can do this with the following command:

.. code-block:: bash

   singularity pull library://jcsda/public/jedi-<name>
   962.73 MiB / 962.73 MiB [========================================================================================================] 100.00% 11.26 MiB/s 1m25s

.. note::

   If you're using version 3.3 or earlier of Singularity, you may get a warning during the pull that the :code:`Container might not be trusted...`.
   You can either ignore this warning or suppress it (in future pulls) with the :code:`-U` option to :code:`singularity pull`.
   In either case, you can always verify the signature by running :code:`singularity verify` as described below.

.. note::

   You can optionally add :code:`:latest` to the name of the container in the
   above ``singularity pull`` command.  This is the tag.  If omitted, the default
   tag is :code:`latest`.

Here :code:`<name>` is the name of the container you wish to download.
Available names include :code:`gnu-openmpi-dev` and :code:`clang-mpich-dev`.
Both of these are development containers, as signified by the :code:`-dev` extension.
This means that they have the compilers and JEDI dependencies included, but they
do not have the JEDI code itself, which developers are expected to download and build.
By contrast, application containers (not yet available) are designated by :code:`-app`.
For further information :doc:`see the JEDI portability document <index>`.
The first component of the name reflects the compiler used to build the dependencies,
in this case :code:`gnu` or :code:`clang` (note: the clang containers currently
use gnu :code:`gfortran` as the Fortran compiler). The second component of the
name reflects the MPI library used, in this case :code:`openmpi` or :code:`mpich`.
For a list of available containers, see `https://cloud.sylabs.io/library/jcsda <https://cloud.sylabs.io/library/jcsda>`_.

The pull command above will download a singularity image file onto your computer.
The name of this file will generally be :code:`jedi-<name>_latest.sif`, though it
may be somewhat different for earlier versions of Singularity.
The :code:`.sif` extension indicates that it is a Singularity image file (in earlier
versions of Singularity the extension was :code:`.simg`). In what follows, we will
represent this name as :code:`<image-file>` - you should replace this with the name of
the file retrieved by the pull command.

Strictly speaking, you only have to execute the pull command once but in practice
you will likely want to update your JEDI image occasionally as the software environment
continues to evolve. The pull statement above should grab the most recent development
version of the JEDI image file (it may take a few minutes to execute).
Singularity also offers a signature service so you can verify that the container came from JCSDA:

.. code-block:: bash

   singularity verify <image-file>   # (optional)

You may see a name you recognize - this will generally be signed by a member of the JEDI core team.

Though you can execute individual commands or scripts within the singularity container
defined by your image file (see the **exec** and **run** commands in
the `Singularity documentation <https://www.sylabs.io/docs/>`_), for many JEDI
applications you may wish to invoke a **singularity shell**, as follows:

.. code-block:: bash

   singularity shell -e <image-file>

Now you are inside the **Singularity Container** and you have access to all the
software infrastructure needed to build, compile, and run JEDI.
The :code:`-e` option helps prevent conflicts between the host environment and
the container environment (e.g. conflicting library paths) by cleaning the
environment before running the container.
Note that this does not mean that the container is isolated from the host environment;
you should still be able to access files and directories on your host computer
(or on your virtual machine if you are using Vagrant) from within the Singularity container.

Before starting the build of JEDI in the container you need to load the Spack modules:

.. code-block:: bash
   
   export jedi_cmake_ROOT=/opt/view
   source /etc/profile.d/z10_spack_environment.sh

.. _working-with-singularity:

Working with Singularity
------------------------

If you installed singularity from within a :doc:`Vagrant <vagrant>` virtual machine
(Mac or Windows),then you probably set up a a :code:`/home/vagrant/vagrant_data`
directory (you may have given it a different name and/or path) that is shared
between the host machine and the virtual machine. Since this is mounted in your
home directory, you should be able to access it from within the container.
However, sometimes you may wish to mount another directory in the container
that is not accessible from Singularity by default.  For example, let's say that
you are working on an HPC system and you have a designated workspace in a directory
called :code:`$SCRATCH`.  We have included a mount point in the JEDI singularity
container called :code:`/worktmp` that will allow you to access such a directory.
For this example, you would mount your work directory as follows:

.. code-block:: bash

   singularity shell --bind $SCRATCH:/worktmp -e <image-file>

After you enter the container you can :code:`cd` to :code:`/worktmp` to access your workspace.

There is another "feature" of Singularity that is worth mentioning. Though
Singularity starts a bash shell when entering the container, You may notice that
it does not call the typical bash startup scripts like :code:`.bashrc`, :code:`.bash_profile` or :code:`.bash_aliases`.
Furthermore, this behavior persists even if you do not use the :code:`-e` option
to :code:`singulary shell`.  This is intentional. The creators of Singularity
deliberately arranged it so that the singularity container does not call these
startup scripts in order to avoid conflicts between the host environment and the
container environment. It is possible to circumvent this behavior using the :code:`--shell` option as follows:

.. code-block:: bash

   # NOT RECOMMENDED!
   singularity shell --shell /bin/bash -e <image-file>

However, if you do this, you may begin to appreciate why it is not recommended.
In particular, you'll notice that your command line prompt has not changed.
So, it is not easy to tell whether you are working in the container or not.
Needless to say, this can get very confusing if you have multiple windows open!

.. _startup-script:

It is safer (and only minimally inconvenient) to put your aliases and environment
variables in a shell script and then just get in the habit of sourcing that script
after you enter the container, for example:

.. code-block:: bash

   source startup.sh

where :code:`startup.sh` contains, for example:

.. code-block:: bash

   #!/bin/bash
   alias Rm='rm -rf '
   export DISPLAY=localhost:0.0

The last line of this example script is particularly noteworthy. Setting
the :code:`DISPLAY` environment
variable as shown should enable X forwarding from the Singularity container to your
computer if you are using Linux/Unix. This in turn will allow you to use graphical
tools such as :code:`emacs`.


If you are invoking the singularity shell from a vagrant virtual machine, then X
Forwarding is a bit more complicated; :ref:`See here for how to setup X Forwarding on a Mac <mac-x-forwarding>`.

For a full list of options, type :code:`singularity shell --help` from *outside* the container.

On a related note, you may have to run this in order for the JEDI code to build properly:

.. code-block:: bash

    git lfs install

This only needs to be done once, and it can be done from either inside or outside
the container.  The reason this is necessary is because Singularity does not change
your user name, your user privileges, or your home directory - you're the same person
inside and outside the container, and you have the same home directory.
The :code:`git lfs install` command modifies the git configuration in order to properly
process files that are stored on :doc:`git-lfs </inside/developer_tools/gitlfs>`.
These configuration settings are stored in a file in your home directory called :code:`~/.gitconfig`.
You would not want the container to automatically modify the files in your home
directory so it is best to enter this manually. But, you only have to run this
command once, even if you use multiple containers.

To exit the Singularity container at any time, simply type

.. code-block:: bash

   exit

If you are using a Mac, you may wish to type :code:`exit` a second time to exit
Vagrant and then shut down the virtual machine with :code:`vagrant halt` (See :ref:`Working with Vagrant and Singularity <vagrant-jedi>`).
