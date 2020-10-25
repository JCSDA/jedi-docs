.. _top-tut-dev-container:

Tutorial: Simulating Observations with UFO
==========================================

Learning Goals:
 - Create simulated observations similar to those highlighted on JCSDA's `Near Real-Time (NRT)Observation Modeling web site <http://nrt.jcsda.org>`_
 - Introduce yourself to the rich variety of observation operators now available in :doc:`UFO <../../jedi-components/ufo/index>`

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

But there is a caveat.  The NRT web site regularly simulates millions of observations using model backgrounds with operational resolution - and it does this every six hours!  That requires substantial high-performance computing (HPC) resources.  We want to mimic this procedure in a way that can be run on a laptop computer.  So, the model background we will use will be at a much lower horizonal resolution (c48, corresponding to about 13,824 points in latitude and longitude) than the NRT website (GFS operational resolution of c768, corresponing to about 3.5 million points).


Step 1: Acquire input files
---------------------------
