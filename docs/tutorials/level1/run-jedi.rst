.. _top-tut-run-jedi:

Tutorial: Run JEDI in a Container
=================================

Learning Goals:
 - How to download and run/enter a JEDI application container
 - Introduction to the JEDI source code and directory structure
 - How to run a jedi application inside the container
 - How to view an increment
 - How to modify a configuration file to alter program execution

Prerequisites:
 - read the :doc:`tutorial overview <../index>`


Step 1: Download and Enter the JEDI Container
---------------------------------------------

The first step in this and all JEDI tutorials is to download the appropriate JEDI tutorial Singularity container.  In this activity we'll use the ``jedi-tutorial`` container:

.. code-block:: bash

   singularity pull library://jcsda/public/jedi-tutorial

If you get an error message that singularity is not found then you'll have to install it or otherwise gain access to it.  For further information see the :doc:`tutorials overview <../index>`.

If the pull was successful, you should see a new file in your current directory with the name ``jedi-tutorial_latest.sif``.  If it has a different name or a different extension you may have an older version of Singularity.  It is recommended that you use Singularity version 3.0 or later.

If you wish, you can verify that the container came from JCSDA by entering:

.. code-block:: bash

   singularity verify jedi-tutorial_latest.sif

Now you *enter the container* with the following command:

.. code-block:: bash

   singularity shell -e jedi-tutorial_latest.sif

To exit the container at any time (not now), simply enter

.. code-block:: bash

   exit

.. _meet-the-container:

Step 2: Get to know the Container
---------------------------------

When you ran the ``singularity shell`` command at the end of Step 1, you entered a new world, or at least a new computing environment.  Take a moment to explore it.

First, notice that you are in the same directory as before:

.. code-block:: bash

  echo $PWD

So, things may look the same, though your command line prompt has likely changed.  And, you can see that your username is the same as before and your home directory has not changed:

.. code-block:: bash

  whoami
  echo $HOME
  cd ~
  ls


You are still the same person.  And, more importantly from a system administrator's perspective, you still have the same access permissions that you did outside of the container.  You can still see all the files in your home directory.  And, you can still edit them and create new files (give it a try).  But things have indeed changed.  Enter this:

.. code-block:: bash

  lsb_release --all

This tells you that you are now running an ubuntu 18.04 operating system, regardless of what host computer you are on and what operating system it has.  Furthermore, take a look at some of the system directories such as:

.. code-block:: bash

   ls /usr/local/lib

There you will see a host of JEDI dependencies, such as netcdf, lapack, and eckit, that may not be installed on your host system.  Thus, singularity provides its own version of system directories such as ``/usr`` but shares other directories with the host system, such as ``$HOME``.  If you're familiar with any of these libraries, you can run some commands, for example:

.. code-block:: bash

   nc-config --all

You can find the JEDI code in the ``/jedi`` directory:

.. code-block:: bash

   cd /jedi
   ls

There are two subdirectories here.  One is ``fv3-bundle``.  :ref:`As described in the quick start <quick-start-build>`, jedi applications are best built as part of **bundles** that include all the different JEDI code repositories needed to compile that particular application.  As its name suggests, ``fv3-bundle`` includes the source code for all the repositories require to run the `FV3 model <https://www.gfdl.noaa.gov/fv3/>`_ within JEDI, with the accompanying data assimilation capabilities of core JEDI repositories including the Object Oriented Prediction System (:doc:`OOPS <../../jedi-components/oops/index>`), the Interface for Observational Data Assimilation (:doc:`IODA <../../jedi-components/ioda/index>`, the Unified Forward Operator (:doc:`UFO <../../jedi-components/ufo/index>`) and the System-Agnostic Background Error Representation (:doc:`SABER <../../jedi-components/saber/index>`).  The interface between FV3-based models and JEDI is implemented through the :doc:`FV3-JEDI <../../jedi-components/fv3-jedi/index>` code repository.  Go into the ``fv3-bundle`` directory and look around.

Also in the ``/jedi`` directory is a subdirectory called ``build``.  This contains the compiled code, including the executables that are located in ``/jedi/build/bin``.  Again, have a look around.

The files in the ``/jedi`` directory are part of the container and cannot be readily accessed after you exit singularity.  Furthermore, the files in the container read-only.  And, since the unit tests in general produce output files, you will not be able to run the tests in the ``/jedi/build`` directory.  But, you can still look at them.

The tests for each code repository are defined within that repository.  So, they can be found within each corresponding directory, usually in a subdirectory called ``test``.  See, for example, the ``ufo/test`` and ``saber/test`` subdirectories in ``/jedi/build``.  As the top-level code component, OOPS is structured a bit differently.  Here the QG and Lorentz 95 toy models have their own test directories (``oops/qg/test`` and ``oops/l95/test`` respectively), with a few other test configurations in ``oops/src/test``.

Step 3: Run a JEDI Application
------------------------------

The container contains everything you need to run a simple application.  In addition to the executables and test data files in ``/opt/jedi/build``, there are also various configuration files in the ``/opt/jedi/fv3-bundle/tutorials`` directory.  To proceed, let's create a new directory suitable for running the application and then copy the files over for this tutorial:

.. code-block:: bash

   mkdir -p $HOME/jedi/tutorials
   cp -r /opt/jedi/fv3-bundle/tutorials/runjedi $HOME/jedi/tutorials
   cd $HOME/jedi/tutorials/runjedi

.. note::

   If you are running on an HPC system with very little space in your home directory, you could alternatively create a directory in some larger work or scratch space and then mount it in the container with:

   .. code-block:: bash

      singularity shell --bind <scratch-directory>:/worktmp -e jedi-tutorial_latest.sif


   where ``<scratch-directory`` is the path to your work directory outside the container.  This will then be mounted within the container as ``/worktmp``.  Alternatively, you could ``cd`` to your directory of choice and enter the container by specifying your current directory as your home directory inside the container:

   .. code-block:: bash

      singularity shell --home=$PWD -e jedi-tutorial_latest.sif

   For further details see :ref:`Working with Singularity <working-with-singularity>`.

Take a look at the files you just copied over.  The run script defines a workflow that is needed to run a variational data assimilation application with fv3-jedi and the B-Matrix Unstructured Mesh Package (:doc:`BUMP <../../jedi-components/saber/BUMP>`).  First BUMP is used to compute the correlation statistics and localization for the background error covariance matrix (B-Matrix).  Then the variational application is run, and a seperate application computes the increment for visualization and analysis.  Each of these applications runs with 6 MPI tasks (the minimum for fv3) and each takes only two arguments, namely a (yaml) :doc:`configuration file <../../developer/building_and_testing/configuration>`) and a filename for storing the text output messages (i.e. the log).

The ``conf`` directory contains jedi configuration files in ``yaml`` format that govern the execution of the application, including the specification of input data files, control flags, and parameter values.  If you look inside, you'll see references to where the input data files are.  For example, the ``/jedi/fv3-bundle/fv3-jedi/test/Data/fv3files`` contains namelist and other configuration files for the FV3 model and the ``/jedi/fv3-bundle/fv3-jedi/test/Data/inputs/gfs_c12`` directory contains model backgrounds and ensemble states that are used to define the grid, initialize forecasts, and compute the B-Matrix.  The ``c12`` refers to the horizontal resolution, signifying 12 by 12 grid points on each of the 6 faces of the cubed sphere grid, or 864 horizontal grid points total.  This is, of course, much lower resolution than operational forecasts but it is sufficient to run efficiently for a tutorial!

If you peruse the config files further, you may see references to the ``/jedi/build/fv3-jedi/test/Data/obs`` directory, which contains links to the observation files that are being assimilated.  Another source of input data is the ``/jedi/build/fv3-jedi/test/Data/crtm`` directory, which contains coefficients for the Community Radiative Transfer Model (CRTM) that are used to compute simulated satellite radiance observations from model states (i..e. the forward operator).

We again encourage you to explore these various directories to get a feel for how the input to jedi applications is provided.

To run a hybrid 3D variational data assimilation application, just execute the run script, specifying ``hyb-3dvar`` as the application you wish to run:

.. code-block:: bash

   ./run.bash hyb-3dvar

Now try a hybrid 4D variational application:

.. code-block:: bash

   ./run.bash hyb-4dvar

The output of each of these experiments can now be found in the ``run-hyb-3dvar`` and ``run-hyb-4dvar`` directories respectively.  A detailed investigation of this output is beyond the scope of this tutorial but you may wish to take a few moments to survey the types of output files that are produced.

Step 4: View the Increment
--------------------------

As mentioned above, the last application in the ``run.bash`` script generates an increment that can be used for visualization.  This is rendered as a netcdf file.  Our recommended tool for visualizing netcdf files, particularly those generated by fv3-jedi, is the `Panoply <https://www.giss.nasa.gov/tools/panoply/>`_ data viewer provided by NASA.

Panoply is available in the container by running the following shell script:

.. code-block:: bash

   /jedi/PanoplyJ/panoply.sh

However, this will launch a graphical user interface (GUI) which will not work unless you have X forwarding set up properly.  If you are running Singularity from a linux laptop or workstation, no further action may be required.  If instead you are running Singularity on a Mac or Windows laptop from within a vagrant virtual machine, then :ref:`setting up X forwarding may be a bit more compilicated <mac-x-forwarding>`.

In general, X forwarding from inside the Singularity container works just like it does outside of the container.  So, if you are able to launch a graphical application outside of the container (``xclock`` is often a convenient test case), then run ``echo $DISPLAY`` to see what the value of your ``DISPLAY`` environment variable is.  Then, from within the container, set the ``DISPLAY`` variable to the same value.  For example, if you're logging into a remote machine with ``ssh -Y`` then you may need to do something like this:

.. code-block:: bash

   export DISPLAY=localhost:10.0

However, we do not want you to spend too much time sorting out the details of X forwarding - that would distract us from the goals of this tutorial.  Even if you do get it to work, it may be impractical to run a GUI over the internet if you are running Singularity from a cloud computing instance or on an HPC system (it may be too slow, depending on your bandwidth).

So, if you're having trouble with Panoply in the container, we recommend that you just install it on your local computer - whatever workstation or laptop is sitting in front of you.  Panoply is free and easy to install on most linux, Mac, and Windows systems.  Just `follow follow NASA's instructions and you'll be all set <https://www.giss.nasa.gov/tools/panoply/download/>`_.  Then, you can download or copy the files from the singularity container to your local machine and view them without worrying too much about your network bandwidth.

Whether you are viewing the files from within the container or not, we recommend that you start with the increment generated when you ran the ``hyb-3dvar`` application in Step 2.  Start Panoply as described in the NASA instructions - either by running it from the command line as shown above or by otherwise opening the application.

In the finder screen, navigate to the directory that contains the increment file, select it, and then select Open. Select Temperature from the list of data sets. Then, in the upper left corner, select Create Plot. A dialog box will come up: you can leave all the settings at their default values and select Create.

Now you should be able to see the temperature increment. Note the color table on the bottom and the gray outlines that mark the edges of the cubed sphere. This shows a level at the top of the domain (level 1) by default. To see a more representative level lower down in the atmosphere, go to the Vertical level menu item at the bottom and select level 50.  Save this image by selecting **Save image** from the **File** menu.

Now play around a bit with Panoply. Explore it’s options. Scroll through the levels to see how the increment chandes with height.  Try plotting out zonal averages instead of a map. Navigate to the Map tab and try a different projection. Go back to the original window and create a new plot with a different field. Try the **Combine plots** option on the menu bar at the top.


Step 5: Change the Configuration (Optional)
-------------------------------------------

This is really a :doc:`Padawan level activity <../level2/index>` so feel free to come back to it after you've done some of the other more advanced tutorials.  But, experienced practitioners of data assimilation might wish to edit the configuration files in your local ``jedi-tutorial/conf`` directory and see how that effects the resulting increments.

Here are a few possible activities - we encourage you to come up with your own:

- change the variable list in one or more of the observations that are assimilated.   For example, you can remove ``eastward_wind`` and ``northward_wind`` from the aircraft and/or radiosonde observations, leaving only temperature.
- remove one of the observation types entirely, such as aircraft or GNSSRO refractivity measurements (*hint: you may wish to review the* `basic yaml syntax <https://learn.getgrav.org/16/advanced/yaml>`_ *to see how components of a particular yaml item are defined*).
- change the localization length scales for bump (*hint:* ``rh`` *and* ``rv`` *correspond to horizonal and vertical length scales respectively, in units of meters*)

After each change remember to run the ``run.bash`` script again to generate new output.
