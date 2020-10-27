.. _tut-overview-top:

Overview
========

This chapter of the JEDI Documentation contains a series of tutorials that new users and developers can work through at their own pace.

In these tutorials, the JEDI code and its dependencies are made available by means of a :doc:`Singularity </using/jedi_environment/singularity>` :ref:`software container <Software-Containers>`.  For more information about software containers and why we use them, see our :doc:`portability discussion </using/jedi_environment/index>`.

So, to do any of these tutorials, you will need access to Singularity.  If you are working on a laptop or workstation and if you have administrative (root) privileges, then you can :ref:`install Singularity yourself <Singularity-install>`.  If you are working on an HPC cluster then you may have to ask your system administrators to install Singularity.

Another option is to use the Amazon cloud.  If you have an account on AWS (Amazon Web Services), then we provide a public Amazon Machine Image (AMI) called ``jcsda-jedi-tutorial`` (currently only available in the N. Virginia region, us-east-1).  This has Singularity version 3.5 pre-installed so you can just launch it and proceed to your tutorial of choice.  We recommend a node type with at least 8 vCPUS and at least 20 GB of memory such as c4.4xlarge or c5.4xlarge.

This is a work in progress - we will continue to add new tutorials and revise existing tutorials as time goes on.  The tutorials need not be done in sequential order.  You can choose what you wish to learn - some topics may be of interest to some users and developers and others may not. However, we do suggest that you start with :doc:`run JEDI in an application container <run-jedi>` and :doc:`working with JEDI in a development container <dev-container>` in order to familiarize yourself with how to download and "enter" the brave new world of the JEDI container.









