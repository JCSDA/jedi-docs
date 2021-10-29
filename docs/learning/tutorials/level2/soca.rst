.. _top-tut-soca:

Tutorial: Running the SOCA tutorial
===================================

Learning Goals:
 - Perform all the necessary steps to run a low resolution variational data assimilation system with SOCA

Prerequisites:
 - :doc:`Build and Test the MOM6 interface to JEDI (SOCA) <dev-container_soca>`

Overview
--------

In this tutorial we will be running several different applications that are necessary to run one cycle
of a 3DVar system and 3 cycles of a 3DVar FGAT.

The scenario of the tutorial is as follows,
generate synthetic observations from a perturbed MOM6 forecast and subsequently
assimilate the synthetic observations using the unperturbed background as
initial conditions.

After succesfully compiling SOCA, in the build directory, you should see a ``tutorial`` folder. ``cd`` into it.

.. code-block:: console

   cd soca/tutorial

along with ``cmake`` related files, it should contain the folowing scripts and yaml configuration files
needed to run the tutorial

.. code-block:: console

  ├── bin                                  # symbolic link to the JEDI executables
  ├── config                               # static yaml configurations
  │   ├── 3dvar.yaml                       # 3DVAR configuration example
  │   ├── gridgen.yaml                     # `soca` grid generation
  │   ├── pert_ic.yaml                     # B-matrix randomization
  │   ├── staticb.yaml                     # horizontal convolution
  │   └── synthetic_obs.yaml               # generate synthetic obs
  ├── Data                                 # folder containing static MOM6 and SOCA files
  ├── tutorial_3dvarfgat.sh                # 3DVAR FGAT driver for multiple cycles
  ├── tutorial_3dvar.sh                    # 3DVAR driver, analysis only
  ├── tutorial_bump_op.sh                  # initialize the horizontal convolution
  ├── tutorial_gridgen.sh                  # generate the grid and save it to disk
  ├── tutorial_make_observations.sh        # generate synthetic observations
  ├── tutorial_perturb_ic.sh               # perturb IC by randomizing the B-matrix
  ├── tutorial_plot.py                     # observation and state space plotting tools
  ├── tutorial_synthetic_observations.py   # generate random locations for synthetic observations
  └── tutorial_tools.sh                    # generate dynamic yaml configurations

Step 1: Grid Generation
-----------------------
This step is required in order to save the `MOM6` geometry in a file for subsequent use.
To generate the grid, run

.. code-block:: console

  ./tutorial_gridgen.sh

if you open the ``tutorial_gridgen.sh`` script, you will see that it executes the ``soca_gridgen.x``
application on two cores

.. code-block:: bash

   OMP_NUM_THREADS=1 mpirun -np 2 ../bin/soca_gridgen.x ../config/gridgen.yaml

with the yaml file ``gridgen.yaml`` as argument:

.. code-block:: yaml

  geometry:
    geom_grid_file: soca_gridspec.nc        # name of the output file that contains the geometry information
    save_local_domain: true                 # save the local FMS domains if true
    full_init: true                         # directive to the MOM6 initialization. The grid generation process
                                            # needs a complete initialization of MOM6
    mom6_input_nml: ./inputnml/input.nml    # location of the FMS Fortran namelist
    fields metadata: ./fields_metadata.yml  # location of the field metatdata yaml file

The ``tutorial_gridgen.sh`` script will create a ``scratch_gridgen``
folder in which the application is executed, as well as create
a ``./static/soca_gridspec.nc`` NetCDF grid file. Using ``ncdump`` to investigate the metadata will
show that the file contains a subset of the usual MOM6 geometry definition.

Under ``scratch_gridgen`` you will also find two NetCDF files, ``geom_output_00000.nc`` and
``geom_output_00001.nc`` which contain the local FMS geometry, one file per MPI worker. This output is controlled
by the yaml key ``save_local_domain`` and can be turned off by setting it to ``false``
or simply commenting it out.

While running the tutorial applications, you will see this type of warnings from ``MOM6``:

.. code-block:: console

    WARNING from PE     0: ...

They can be ignored.

Step 2: Initialize the correlation operator using the NICAS method
------------------------------------------------------------------
This step is a core part of the background error covariance model that will be used in the next steps
of this tutorial. To generate the horizontal correlation operator, run

.. code-block:: console

  ./tutorial_bump_op.sh

The files necessary to subsequently initialize this operator are saved under ``static/bump/``.
These files are currently layout dependent. If you were to modify the number of processors used to run this
applications, all subsequent applications making use of this operator will have to be run on the same number
of cores.

The ``tutorial_bump_op.sh`` scripts executes the following JEDI applications on two cores

.. code-block:: console

  OMP_NUM_THREADS=1 mpirun -np 2 ../bin/soca_staticbinit.x ../config/staticb.yaml

with the yaml file ``staticb.yaml`` as argument. A relevant snippet of that yaml file
that controls the horizontal correlation operator is shown below:

.. code-block:: yaml

  analysis variables: &ana_vars [socn, tocn, ssh] # yaml anchor defining the control variables

  background error:
    covariance model: SocaError                # name of the covariance factory in soca
    analysis variables: *ana_vars              # variables for which a correlation operator will be implemented
    date: *date                                # date of the background

    [...]

    correlation:
    - name: ocn                      # horizontal correlation for the ocean
      base value: 300.0e3            # minimum decorrelation length scale
      rossby mult: 1.0               # sets the decorrelation scale to base value + rossby mult * Rossby radius
      min grid mult: 2.0             # impose the minimun decorrelation to span at least 2 grid boxes
      min value: 200.0e3             # minimum value for the decorrelation (not used in this case)
      variables: [tocn, socn, ssh]   # variables on which to apply the correlation operator

the yaml key ``base value``, ``rossby mult`` and ``min grid mult`` can be adjusted to modify the
horizontal decorrelation length scale.

Step 3: Randomize a B-matrix to generate a perturbed initial condition
----------------------------------------------------------------------
To generate a perturbation we will randomize a static B-matrix. This is done by running

.. code-block:: console

  ./tutorial_perturb_ic.sh

it will generate an unrealistically large perturbed ocean state (the goal of the tutorial is not science!) that
will be used in the next step to initialize a forecast and generate synthetic observations.

The JEDI application ``soca_enspert.x`` is used inside of the ``tutorial_perturb_ic.sh`` script in the following way

.. code-block:: bash

    OMP_NUM_THREADS=1 mpirun -np 2 ../bin/soca_enspert.x ../config/pert_ic.yaml

taking the ``pert_ic.yaml`` file as argument.
One can vary the amplitude of the perturbation by editing the ``background error`` section
of the yaml file. The relevant snippet of yaml blocks is shown below.

.. code-block:: yaml

  background error:
    covariance model: SocaError
    date: *date
    analysis variables: &soca_vars [socn, tocn, ssh, hocn]
    bump:
      verbosity: main
      datadir: ./bump
      strategy: specific_univariate
      load_nicas_local: 1
    perturbation scales:
      tocn:  10.0
      socn:  10.0
      ssh:   0.0

Under the ``perturbation scales`` section of the yaml file above, the ``tocn`` and ``socn`` keys represent the
scaling of the perturbation. Choose a number on the order of 1 if you wish to generate a realistic perturbed
ocean state and re-run the ``tutorial_perturb_ic.sh`` script.

Step 4: Generate synthetic observations
---------------------------------------
In this step of the tutorial, we will generate synthetic observations by driving the
``MOM6-solo`` model using the ``soca_hofx.x`` executable. `ioda` observation files are
created at the time and locations specified
in ``tutorial_synthetic_observations.py``. This application uses generic
observation operators from the UFO repository. To generate the synthetic observations, run the
``tutorial_make_observations.sh`` script:

.. code-block:: console

  ./tutorial_make_observations.sh

A ``obs`` directory is created and should contain the following `ioda` observation files:

.. code-block:: console

  ├── adt.nc4          # absolute dynamic topography
  ├── insitu.S.nc4     # salinity profiles
  ├── insitu.T.nc4     # insitu temperature profiles
  ├── sss.nc4          # sea surface salinity
  └── sst.nc4          # sea surface temperature

Step 5: 3DVar example
---------------------
To run the 3DVAR example, execute the ``tutorial_3dvar.sh`` script:

.. code-block:: console

  ./tutorial_3dvar.sh

this script perform a 3D variational minimization using the ``soca_var.x``
executable for a 24 hour window using the observations generated above.
The executable takes ``config/3dvar.yaml`` yaml configuration file as an
argument.

The JEDI application ``soca_var.x`` is used inside of the ``tutorial_3dvar.sh`` script in the following way

.. code-block:: bash

    OMP_NUM_THREADS=1 mpirun -np 2 ../bin/soca_var.x ../config/3dvar.yaml

taking the ``3dvar.yaml`` file as argument. This file controls, among other things, the
data assimilation window length which can be adjusted by changing the value of the
``window length`` key. The relevant yaml snippet is shown below:

.. code-block:: yaml

  [...]
  cost function:
    cost type: 3D-Var                                                          # cost function type
    window begin: &date_begin 2018-04-14T12:00:00Z                             # starting date of the DA window
    window length: P1D                                                         # length of the DA window (1 day)
                                                                               # to adjust to a 6 hour window for example,
                                                                               # replace with PT6H
  [...]

A few figures of surface increments are plotted at the end of the script after
the 3DVAR step is done:

.. code-block:: console

  $ ls scratch_3dvar/*.png
  scratch_3dvar/incr.ssh.png  scratch_3dvar/incr.sss.png  scratch_3dvar/incr.sst.png

They represent increments for sea surface height, sea surface salinity and sea surface temperature,
respectively.

Step 5: 3DVar FGAT example
--------------------------
This part of the tutorial is used to show an example of configuration of a
data assimilation experiment cycling through 3 days.
The data assimilation window is 24 hours and the synthetic observations assimilated are
sea surface temperature, sea surface salinity, insitu temperature and salinity and
absolute dynamic topography.
To run the 3DVar FGAT tutorial, execute the ``tutorial_3dvarfgat.sh`` script:

.. code-block:: console

  ./tutorial_3dvarfgat.sh

The student is encouraged to have a look inside of the ``tutorial_3dvarfgat.sh`` script to follow
the steps that enable a cycling system.

Similarly to the `3DVAR` example, figures of surface increments for outer iterations 1 and 2
can be found in ``./scratch_3dvarfgat/incr.[1-2].ssh.png``,
``./scratch_3dvarfgat/incr.[1-2].sss.png`` and ``./scratch_3dvarfgat/incr.[1-2].sst.png``.

Statistics of global mean absolute error of each observation space assimilated can be found
in ``./scratch_3dvarfgat/*global_mae.png``.
