.. _hpc_users_guide:

Skylab HPC users guide
======================

This guide contains system-specific information as well as tips and tricks for running
skylab on supported HPC systems.

.. _discover:

Discover
--------

After you have been granted access, set up your password, and can log into Discover, see the spack-stack documentation for a guide on how to access the `spack-stack environment <https://spack-stack.readthedocs.io/en/latest/PreConfiguredSites.html#nasa-discover>`_ and this guide for loading the jedi-modules on :ref:`discover-modules`.

The "scratch" directory on Discover is in the :code:`~/NOBACKUP` file system (see the `NCCS user guide <https://www.nccs.nasa.gov/nccs-users/instructional/using-discover/file-system-storage>`_). So, build JEDI and set up your :code:`JEDI_ROOT` to a directory here.

Build jedi on the login-node (with 4 or fewer processes i.e. :code:`-j4` or less), and use the special commands for running :code:`ecbuild` on intel/GNU (see: :ref:`discover-modules`). Run the :code:`get_` ctests also on the login-node, but run the rest of the tests interactively on a compute node using the :code:`salloc` command as described in the documentation on building JEDI (linked above). It will take about an hour and a half to run the tests, so be sure to request at least 90 minutes for the interactive job. FYI, it will likely take a while for the request for the interactive session to be granted.

ecflow and Discover login-nodes
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

When you log on to Discover, you will be placed onto a different login-node each time (eg, :code:`discover11`, :code:`discover12`, etc). You can't choose which login-node you get, and you cannot easily :code:`ssh` between login-nodes.

This means you will have to take a few extra steps to get your experiments to show up in the ecflow GUI properly, and you can address this in one of several ways (in all cases you will still have to manually set your :code:`ECF_PORT` environment variable):

#. (Recommended) Leave your :code:`activate.sh` script with the default of re-setting your :code:`ECF_HOST` for each new session and have an ecflow server configured on each login-node. So, when you log into a new session, you either use the server you have previously configured on that node or configure a new server if you haven't already configured one on that node. In this case, you will still have to have the same :code:`ECF_PORT` for each of the separate servers you have on different nodes (which you had to set manually as noted in the documentation). For best results, shutdown the ecflow server (:code:`ecflow_stop.sh -p $ECF_PORT`) before ending each session and logging out.

   .. note:: 
    
     With this approach, you will have several servers appear in your ecflow GUI. Jobs will run through the server running on the node you submitted the job from. Also, to help you keep track of the servers, name the server with the name of the login-node on which it is running.


#. You can start one ecflow server (with the :code:`ecflow_start.sh -p $ECF_PORT` command) on whichever login-node you are on when submitting your first experiment. For this approach, you will need to manually adjust your :code:`activate.sh` script to set your :code:`ECF_HOST` to match the login-node on which you started the server (i.e. the node you are currently on). For example:

   .. code-block:: bash

     export ECF_HOST=discover13

   .. note:: 
    
     With this approach, you will only have one server appear in your ecflow GUI. Having your :code:`ECF_HOST` hardcoded will have jobs run through the server on your original login-node, even if you submit the job from another node. This approach is not recommended since it can cause tricky-to-debug issues with environment matching, and will cause you to have to restart your ecflow server and change your :code:`activate.sh` script everytime the discover login-nodes get shutdown (e.g., for maintenance).

#. You can setup an SSH key pair and follow the directions at https://www.nccs.nasa.gov/nccs-users/instructional/logging-in to allow you to SSH between login-nodes.
