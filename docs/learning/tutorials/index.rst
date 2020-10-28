################
JEDI Tutorials
################

Tutorial Overview
-----------------

This chapter of the JEDI Documentation contains a series of tutorials that new users and developers can work through at their own pace.

In these tutorials, the JEDI code and its dependencies are made available by means of a :doc:`Singularity <../../using/jedi_environment/singularity>` :ref:`software container <Software-Containers>`.  For more information about software containers and why we use them, see our :doc:`portability discussion <../../using/jedi_environment/index>`.

So, to do any of these tutorials, we recommend that you gain access to Singularity.  If you are working on a laptop or workstation and if you have administrative (root) privileges, then you can :ref:`install Singularity yourself <Singularity-install>`.  If you are working on an HPC cluster then you may have to ask your system administrators to install Singularity.

However, with a little creativity, the tutorials can also be done using :doc:`HPC environment modules <../../using/jedi_environment/modules>`.  But, keep in mind that things may work a little differently.  For example, most HPC facilities will not permit you to run parallel mpi jobs from the command line of a login node.  So, to run JEDI tests and applications (many of which are parallel) you may have to request compute resources through an interactive or batch job (e.g. ``salloc`` or ``sbatch`` if your HPC system uses `SLURM <https://slurm.schedmd.com/>`_).  Also, python plotting tools such as `cartopy <https://scitools.org.uk/cartopy/docs/latest/>`_ are typically not included in the environment modules so you may have to install them yourself in your own python user space through ``pip`` or ``conda``.

Another option is to use the Amazon cloud.  If you have an account on AWS (Amazon Web Services), then we provide a public Amazon Machine Image (AMI) called ``jcsda-jedi-tutorial`` (currently only available in the N. Virginia region, us-east-1).  This has Singularity version 3.5 pre-installed so you can just launch it and proceed to your tutorial of choice.  We recommend a node type with at least 8 vCPUS and at least 20 GB of memory such as c4.4xlarge or c5.4xlarge.

This is a work in progress - we will continue to add new tutorials and revise existing tutorials as time goes on.  Most tutorials need not be done in sequential order, though some require pre-requisites.  You can choose what you wish to learn - some topics may be of interest to some users and developers and others may not. However, we do suggest that you start with :doc:`run JEDI in a Container <level1/run-jedi>` in order to familiarize yourself with how to download and "enter" the brave new world of the JEDI container.

**System Requirements:**

- At least 16 GB memory; more is better
- At least 4 compute processor cores.  If you are running Singularity in a Vagrant virtual machine, we recommend setting the number of virtual cores to 18; see our :doc:`Vagrant documentation <../../using/jedi_environment/vagrant>` for details.
- At least 8 GB of free disk space
- A reasonably fast internet connection (at least 5 Mbps)

.. toctree::
   :maxdepth: 2

   level1/index
   level2/index
   level3/index
