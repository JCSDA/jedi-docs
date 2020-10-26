.. _top-tut-dev-container:

Tutorial: Simulating Observations with UFO
==========================================

Learning Goals:
 - Create simulated observations similar to those highlighted on JCSDA's `Near Real-Time (NRT)Observation Modeling web site <http://nrt.jcsda.org>`_
 - Acquaint yourself with the rich variety of observation operators now available in :doc:`UFO <../../jedi-components/ufo/index>`

Prerequisites:
 - Either :doc:`Run JEDI in a Container <run-jedi>` or :doc:`Building and Testing FV3 Bundle <dev-container>`

Overview
--------

If you have finished either the :doc:`Run JEDI in a Container <run-jedi>` tutorial or the :doc:`Building and Testing FV3 bundle <dev-container>` tutorial, you now have a version of ``fv3-bundle`` compiled and ready to use.  In the former case, it came pre-packaged inside an application container.  In the latter case, you build it yourself inside a development container.

A small clarification on the case of the development container; You built fve-bundle while inside the container but since the container and host environment share the same home directory, you should still be able to access it outside of the container.  But, if you try to run any tests or applications from outside the container you'll find that they fail.  This is because, at run time as well as at compile time, the tests and applications need to link to the libraries and executables inside the container.

The comparison between observations and forecasts is an essential component of any data assimilation (DA) system and is critical for accurate Earth System Prediction.  It is common practice to do this comparison in observation space.  In JEDI, this is done by the Unified Forward Operator (:doc:`UFO <../../jedi-components/ufo/index>`).  Thus, the principle job of UFO is to start from a model background state and to then simulate what that state would look like from the perspective of different observational instruments and measurements.

In the data assimilation literature, this procedure is often represented by the expression :math:`H({\bf x})`.  Here :math:`{\bf x}` represents prognostic variables on the model grid, typically obtained from a forecast, and :math:`H` represents the *observation operator* that generates simulated observations from that model state.  The sophistication of observation operators varies widely, from in situ measurements where it may just involve interpolation and possibly a change of variables (e.g. radiosondes), to remote sensing measurements that require physical modeling to produce a meaningful result (e.g. radiance, GNSSRO).

So, in this tutorial, we will be running an application called :math:`H({\bf x})`, which is often denoted in program and function names as ``Hofx``.  This in turn will highlight the capabilities of JEDI's Unified Forward Operator (:doc:`UFO <../../jedi-components/ufo/index>`).

The goal is to create plots comparable to JCSDA's `Near Real-Time (NRT) Observation Modeling web site <http://nrt.jcsda.org>`_  This site regularly ingests observation data for the complete set of operational instruments at NOAA.  And, it compares these observations to forecasts made through NOAA's operational Global Forecasting System (FV3-GFS) and NASA's Goddard Earth Observing System (FV3-GEOS).

But there is a caveat.  The NRT web site regularly simulates millions of observations using model backgrounds with operational resolution - and it does this every six hours!  That requires substantial high-performance computing (HPC) resources.  We want to mimic this procedure in a way that can be run on a laptop computer.  So, the model background we will use will be at a much lower horizonal resolution (c48, corresponding to about 14 thousand points in latitude and longitude) than the NRT website (GFS operational resolution of c768, corresponing to about 3.5 million points).


Step 1: Acquire input files
---------------------------

The description in the previous section gives us a good idea of what we need to run :math:`H({\bf x})`.  First, we need :math:`{\bf x}` - the model state.  In this tutorial we will use background states from the FV3-GFS model with a resolution of c48, as mentioned above.

Next, we need observations to compare our forecast to.  Observations included in this tutorial include (see our :doc:`UFO document <../../jedi-components/ufo/index>` for an explanation of acronyms; nlocs is the number of observations for each):

* Aircraft; nlocs=93933; T:43192; Q:1676; U,V:43145
* Sonde; nlocs=3090 T:276; Q:550; U,V:1916; Psfc:19
* Satwinds; nlocs=1552597; U,V:263192/2641344
* Scatwinds; nlocs=217582; U,V:212907/435088
* Vadwind; nlocs=15796; U,V:6513/31592
* Windprof; nlocs=13; U,V:9/26
* SST; nlocs=24396; SST:20828/22361
* Ship; nlocs=40312; T:3260; U,V:7843; Psfc:8888/36417
* Surface; nlocs=217289; T,Q,U,V:0; Psfc:62188/192169
* cris-npp
* cris-n20
* airs-aqua
* gome-metopa
* gome-metopb
* sbuv2-n19
* amsua-aqua
* amsua-n15
* Amsua-n18
* amsua-n19
* amsua-metopa
* amsua-metopb
* amsua-metopc
* iasi-metopa
* iasi-metopb
* seviri-m08
* seviri-m11
* mhs-metopa
* mhs-metopb
* mhs-metopc
* mhs-n19
* ssmis-f17
* ssmis-f18
* atms-n20

The script to get these background and observation files is already in fv3-bundle.  But, before we run it, we should find a good place to run our application.  If you are using an application container, ``fv3-bundle`` is inside the container so that directory is read-only; that will not do.  Or, if you are using a development container, you could write to it but it is good practice to keep the repository clean of output files.

So, whichever container you are running in, it's a good idea to copy the files you need over to your home directory that is dedicated to running the tutorial:

.. code-block:: bash

   mkdir -p $HOME/jedi/tutorials
   cp -R <path-to-fv3-bundle>/tutorials/Hofx $HOME/jedi/tutorials
   cd $HOME/jedi/tutorials/Hofx

Here ``<path-to-fv3-bundle>`` is the path to your copy of ``fv3-bundle``.  If you previously did the :doc:`Run JEDI in a Container <run-jedi>` tutorial this will be ``/opt/jedi/fv3-bundle``.  Or, if you did the :doc:`Building and Testing FV3 Bundle <dev-container>` tutorial, this may be ``$HOME/jedi/fv3-bundle``.

We'll call ``$HOME/jedi/tutorials/Hofx`` the run directory.

Now we are ready to run the script to obtain the input data (from the run directory):

.. code-block:: bash

    ./get_input.bash

You only need to run this once.  It will retrieve the background and observation files from a remote server and place them in a directory called ``input``.

You may have already noticed that there is another directory in your run directory called ``config``.  Take a look.  Here are a different type of input files, including configuration (:doc:`yaml <../../developer/building_and_testing/configuration>`) files that specify the parameters for the JEDI applications we'll run and fortran namelist files that specify configuration details specific to the FV3-GFS model.

Step 2: Run the Hofx application
--------------------------------

There is a file in the run directory called ``run.bash``.  Take a look.  This is what we will be using to run our Hofx application.

When you are ready, try it out:

.. code-block:: bash

   ./run.bash

If you get a prompt to ``Please enter the JEDI build directory`` then that probably means you built fv3-bundle yourself as part of the :doc:`Building and Testing FV3 Bundle <dev-container>` tutorial.  If that's the case then you should enter ``$HOME/jedi/build``.  This tells the script where to find the fv3-jedi executables.

