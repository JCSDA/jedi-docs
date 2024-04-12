.. _build-run-skylab:

Building and running SkyLab
===========================

List of spack, software, and AMIs
---------------------------------

Versions used:

- spack-stack-1.7.0 from April 2024

  * https://github.com/JCSDA/spack-stack/tree/1.7.0

  * https://spack-stack.readthedocs.io/en/1.7.0

- AMI available in us-east-1 region (N. Virginia)

  - Red Hat 8 with gnu-11.2.1 and openmpi-4.1.5:

    AMI Name {skylab_version}-redhat8

    AMI ID ami-01147e0e00b99cbdf (https://us-east-1.console.aws.amazon.com/ec2/home?region=us-east-1#ImageDetails:imageId=ami-01147e0e00b99cbdf)

- AMI available in us-east-2 region (Ohio)

  - Red Hat 8 with gnu-11.2.1 and openmpi-4.1.5:

    AMI Name {skylab_version}-redhat8

    AMI ID ami-091ad0584d0400762 (https://us-east-2.console.aws.amazon.com/ec2/v2/home?region=us-east-2#ImageDetails:imageId=ami-091ad0584d0400762)

Note. It is necessary to use c6i.4xlarge or larger instances of this family (recommended: c6i.8xlarge when running the `skylab-atm-land-small` experiment). 

For more information about using Amazon Web Services please see :ref:`cloud_index`.

Developer section
-----------------
**To follow this section, one needs read access to the JCSDA-internal GitHub org.**

1- Load modules
^^^^^^^^^^^^^^^
First, you need to load all the modules needed to build jedi-bundle and :code:`solo/r2d2/ewok/simobs/skylab.`
Note that loading modules only sets up the environment for you. You still need to build
jedi-bundle, run ctests, install :code:`solo/r2d2/ewok/simobs` and clone skylab.

Please note that currently we only support Orion, Hercules, Derecho, Discover, S4, and AWS platforms.
If you are working on a system not specified below please follow the instructions on :ref:`jedi_portability`.

Users are responsible for setting up their GitHub and AWS credentials on the platform they are using.
You will need to create or edit your ``~/.aws/config`` and ``~/.aws/credentials`` to make sure they contain:


      .. code-block:: bash

         [default]
         region=us-east-1

         # NOAA AWS account configuration for the ``jcsda-noaa-aws-us-east-1`` R2D2 Data Hub
         [jcsda-noaa-aws-us-east-1]
         region=us-east-1

         # USAF AWS account configuration for the ``jcsda-usaf-aws-us-east-2`` R2D2 Data Hub
         [jcsda-usaf-aws-us-east-2]
         region=us-east-2


      .. code-block:: bash

         # NOAA AWS account credentials if default in config is us-east-1
         [default]
         aws_access_key_id=***
         aws_secret_access_key=***

         # NOAA AWS account credentials for the ``jcsda-noaa-aws-us-east-1`` R2D2 Data Hub
         [jcsda-noaa-aws-us-east-1]
         aws_access_key_id=***
         aws_secret_access_key=***

         # USAF AWS account credentials for the ``jcsda-usaf-aws-us-east-2`` R2D2 Data Hub
         [jcsda-usaf-aws-us-east-2]
         aws_access_key_id=***
         aws_secret_access_key=***

.. tip::

  Make sure to protect your AWS config and credentials via:

  .. code-block:: bash

        chmod 400 ~/.aws/config
        chmod 400 ~/.aws/credentials

The commands for loading the modules to compile and run SkyLab are provided in separate sections for :doc:`HPC platforms <../jedi_environment/modules>` and :doc:`AWS instances (AMIs) <../jedi_environment/cloud/singlenode>`. Users need to execute these commands before proceeding with the build of ``jedi-bundle`` below.

.. warning::

  If you are using ``spack-stack 1.4.0`` or ``spack-stack 1.4.1`` you need to unload the CRTM v2.4.1-jedi module after loading the Spack-Stack modules.

  .. code-block:: bash

        module unload crtm


  Make sure you are building CRTMV3 within the jedi-bundle using the `ecbuild_bundle command <https://github.com/JCSDA-internal/jedi-bundle/blob/5.0.0/CMakeLists.txt#L38>`_. 

.. warning::

  If you are using ``spack-stack 1.7.0``, different versions of ``mapl`` are used with different variants, depending on the version of the compiler and whether the system is used for UFS or GEOS.
  Please reference `spack-stack 1.7.0 documentation <https://spack-stack.readthedocs.io/en/1.7.0/PreConfiguredSites.html>`_ in a note and table under "3.1. Officially supported spack-stack installations" for more information.

.. _build-jedi-bundle:

2- Build jedi-bundle
^^^^^^^^^^^^^^^^^^^^

Once the stack is installed and the corresponding modules loaded, the next step
is to get and build the JEDI executables.

The first step is to create your work directory. In this directory you will clone
the JEDI code and all the files needed to build, test, and run JEDI and SkyLab.
We call this directory :code:`JEDI_ROOT` throughout this document.

The next step is to clone the code bundle to a local directory. To clone the publicly available repositories use:

.. code-block:: bash

  mkdir $JEDI_ROOT
  cd $JEDI_ROOT
  git clone https://github.com/jcsda/jedi-bundle


Alternatively, developers with access to the internal repositories should instead clone the development branch. For that use:

.. code-block:: bash

  mkdir $JEDI_ROOT
  cd $JEDI_ROOT
  git clone https://github.com/jcsda-internal/jedi-bundle

The example here is for jedi-bundle, the instructions apply to other bundles as well.

From this point, we will use two environment variables:

* :code:`$JEDI_SRC` which should point to the base of the bundle to be built (i.e. the directory that was cloned just above, where the main CMakeLists.txt is located or :code:`$JEDI_ROOT/jedi-bundle`). :code:`$JEDI_SRC=$JEDI_ROOT/jedi-bundle`

* :code:`$JEDI_BUILD` which should point to the build directory or :code:`$JEDI_ROOT/build`. Create the directory if it does not exist. :code:`$JEDI_BUILD=$JEDI_ROOT/build`

Note:

It is recommended these two directories are not one inside the other.

- Orion: it’s recommended to use :code:`$JEDI_ROOT=/work2/noaa/jcsda/${USER}/jedi`.

- Discover: it’s recommended to use :code:`$JEDI_ROOT=/discover/nobackup/${USER}/jedi`.

- On AWS Parallel Cluster, use :code:`$JEDI_ROOT=/mnt/experiments-efs/USER.NAME/jedi`.

- On the preconfigured AWS AMIs, use :code:`$JEDI_ROOT=$HOME/jedi`.


Building JEDI then can be achieved with the following commands:

.. code-block:: bash

  mkdir $JEDI_BUILD
  cd $JEDI_BUILD
  ecbuild $JEDI_SRC
  make -j8

Feel free to have a coffee while it builds. Once JEDI is built, you should check
the build was successful by running the tests (still from :code:`$JEDI_BUILD`):

.. code-block:: bash

   	ctest

If you are on an HPC you may need to provide additional flags to the ecbuild
command, or login to a compute node, or submit a batch script for running the
ctests. Please refer the :ref:`hpc_users_guide` for more details.

Running the tests may take up to 2 hours depending on your system, so you might
want to take another coffee break. If all the expected tests pass, congratulations!
You have successfully built JEDI!

.. warning::

  If you are running on your own machine you will also need to clone the :code:`static-data` repo for some skylab experiments.

  .. code-block:: bash

    cd $JEDI_SRC
    git clone https://github.com/jcsda-internal/static-data

.. note::

  Run :code:`ctest --help` for more information on the test options. For even more information, see section :ref:`jedi-testing`.

3- Clone and install solo/r2d2/ewok/simobs, clone skylab only
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
We recommend that you use a python3 virtual environment (venv) for
building :code:`solo/r2d2/ewok/simobs`. As indicated above in the note about
the :code:`$JEDI_SRC` and :code:`$JEDI_BUILD` environment variables, 
clone these repos *inside* the clone of the jedi-bundle repo.

.. code-block:: bash

  cd $JEDI_SRC
  git clone https://github.com/jcsda-internal/solo
  git clone https://github.com/jcsda-internal/r2d2
  git clone https://github.com/jcsda-internal/ewok
  git clone https://github.com/jcsda-internal/simobs
  git clone https://github.com/jcsda-internal/skylab

Or for the latest release of ``{skylab_v}``, clone the corresponding workflow repository branches:

.. code-block:: bash

  cd $JEDI_SRC
  git clone --branch 1.2.0 https://github.com/jcsda-internal/solo
  git clone --branch 2.3.0 https://github.com/jcsda-internal/r2d2
  git clone --branch 0.7.0 https://github.com/jcsda-internal/ewok
  git clone --branch 1.5.0 https://github.com/jcsda-internal/simobs
  git clone --branch 7.0.0 https://github.com/jcsda-internal/skylab

Continue with setting up a virtual environment.

.. code-block:: bash

  cd $JEDI_ROOT
  python3 -m venv --system-site-packages venv
  source venv/bin/activate

You can then proceed with

.. code-block:: bash

  cd $JEDI_SRC/solo
  python3 -m pip install -e .
  cd $JEDI_SRC/r2d2
  python3 -m pip install -e .
  cd $JEDI_SRC/ewok
  python3 -m pip install -e .
  cd $JEDI_SRC/simobs
  python3 -m pip install -e .

.. note::

  If you are using ``spack-stack 1.7.0``, when installing ``r2d2`` you might recieve the following error:

  .. code-block::

    ERROR: pip's dependency resolver does not currently take into account all the packages that are installed. This behaviour is the source of the following dependency conflicts.
    cylc-flow 8.2.3 requires protobuf<4.22.0,>=4.21.2, but you have protobuf 3.20.1 which is incompatible.
    Successfully installed protobuf-3.20.1 r2d2-2.3.0

  You can ignore this for now and note that is says ``Successfully installed protobuf-3.20.1 r2d2-2.3.0``

Note: You need to run :code:`source venv/bin/activate` every time you start a
new session on your machine.

4- Setup SkyLab
^^^^^^^^^^^^^^^

Create and source $JEDI_ROOT/setup.sh
""""""""""""""""""""""""""""""""""""""""
We recommend creating this bash script and sourcing it before running the experiment.
This bash script sets environment variables such as :code:`JEDI_BUILD`, :code:`JEDI_SRC`,
:code:`EWOK_WORKDIR` and :code:`EWOK_FLOWDIR` required by ewok. A reference setup script that reflects
the lastest developmental code is available at https://github.com/JCSDA-internal/jedi-tools/blob/develop/buildscripts/setup.sh.

The script contains logic for loading the required spack-stack modules
on configurable platforms (i.e. where :code:`R2D2_HOST=LOCALHOST`, see below),
and it pulls in spack-stack configurations for supported platforms. These are located in
https://github.com/JCSDA-internal/jedi-tools/blob/develop/buildscripts/setup/ for the latest
developmental code.

Users may set :code:`JEDI_ROOT`, :code:`JEDI_SRC`, :code:`JEDI_BUILD`, :code:`EWOK_WORKDIR` and
:code:`EWOK_FLOWDIR` to point to relevant directories on their systems
or use the default template in the sample script. Note that these locations are experiment specific,
i.e. you can run several experiments at the same time, each having their own definition for these variables.

The user further has to set two environment variables :code:`R2D2_HOST` and :code:`R2D2_COMPILER` in the script.
:code:`R2D2_HOST` and :code:`R2D2_COMPILER` are required by r2d2 and ewok. They are used to initialize the
location :code:`EWOK_STATIC_DATA` of the static data used by skylab and bind r2d2 to your current environment.
:code:`EWOK_STATIC_DATA` is staged on the preconfigured platforms. On generic platforms, the script sets
:code:`EWOK_STATIC_DATA` to :code:`${JEDI_SRC}/static-data/static`.

Please don’t forget to source this script after creating it: :code:`source $JEDI_ROOT/setup.sh`

Please see :ref:`hpc_users_guide` for more information on specifics for editing this :code:`setup.sh` script
and other general instructions and notes for running skylab on supported HPC systems.

The script also sets the variable :code:`ECF_PORT` to a constant value that depends on your user ID
on the system. Please make sure that the resulting value for :code:`ECF_PORT` is somewhere between
5000 and 20000. On some systems (e.g. your own macOS laptop), the user ID is a large integer well
outside the allowed port range. Note that changing your :code:`ECF_PORT` will require you to reconnect
the ecflow server, so keeping it constant will keep your ecflow server connected.

5- Setup R2D2 (for MacOS and AWS Single Nodes)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

If you are running skylab locally on the MacOS or an AWS single node instance,
you will also have to setup R2D2. This step should be skipped if you are on any
other supported platform. As with the previous step, it is recommended to complete
these steps inside the python virtual environment that was activated above.

Clone the r2d2-data Repo
""""""""""""""""""""""""

As with the other repositories, clone this inside your :code:`$JEDI_SRC` directory.

.. code-block:: bash

  cd $JEDI_SRC
  git clone https://github.com/jcsda-internal/r2d2-data

Create a local copy of the R2D2 data store:

.. code-block:: bash

  mkdir $HOME/r2d2-experiments-localhost
  cp -R $JEDI_SRC/r2d2-data/r2d2-experiments-tutorial/* $HOME/r2d2-experiments-localhost


Install, Start, and Configure the MySQL Server
""""""""""""""""""""""""""""""""""""""""""""""

Execution of R2D2 on MacOS and AWS single nodes requires that MySQL is installed, started,
and configured properly. For new site configurations see the 
`spack-stack instructions <https://spack-stack.readthedocs.io/en/latest/NewSiteConfigs.html#newsiteconfigs>`_
for the needed prerequisites for macOS, Ubuntu, and Red Hat. Note, if you are reading these
instructions, it is likely you have already setup the spack-stack environment.

You should have installed MySQL when you were setting up the spack-stack environment. To
check this, enter :code:`brew list` to the terminal and check the output for :code:`mysql`.

Follow the directions for setting up the MySQL server found in the R2D2 tutorial starting
at the `Prerequisites for MacOS and AWS Single Nodes Only
<https://github.com/JCSDA-internal/r2d2/blob/develop/TUTORIAL.md#prerequisites-for-hpc-macos-and-aws-single-nodes>`_
section. (If the link doesn't work, the directions can be found in the :code:`TUTORIAL.md` file in the r2d2 repository).

Note: The command used to setup the the local database should be run from the :code:`$JEDI_SRC/r2d2` directory. And
the :code:`r2d2-experiments-tutorial.sql` file is in :code:`$JEDI_SRC/r2d2-data`.


6- Run SkyLab
^^^^^^^^^^^^^
Now you are ready to start an ecflow server and run an experiment. Make sure you are in your python virtual environment (venv).

First, start the ecflow server. Note that this may already be done by your `setup.sh` script if you are using the reference script mentioned in the previous sections.

.. code-block:: bash

  ecflow_start.sh -p $ECF_PORT

Note: On Discover, users need to set ECF_PORT manually:

.. code-block:: bash

  export ECF_PORT=2500
  ecflow_start.sh -p $ECF_PORT

Please note “Host” and “Port Number” here. Also note that each user must use a
unique port number (we recommend using a random number between 2500 and 9999)

To view the ecflow GUI:

.. code-block:: bash

  ecflow_ui &

When opening the ecflow GUI flow for the first time you will need to add your
server to the GUI. In the GUI click on “Servers” and then “Manage servers”.
A new window will appear. Click on “Add server”. Here you need to add the Name,
Host, and Port of your server. For “Host” and “Port” please refer to the last
section of output from the previous step.

To stop the ecflow server:

.. code-block:: bash

  ecflow_stop.sh -p $ECF_PORT

To start your ewok experiment:

.. code-block:: bash

  create_experiment.py $JEDI_SRC/skylab/experiments/your-experiment.yaml

Note for MacOS Users:
"""""""""""""""""""""
If attempting to start the ecflow server on the MacOS gives you an error message like this:

.. code-block::

  Failed to connect to <machineName>:<PortNumber>. After 2 attempts. Is the server running ?

  ...

  restart of server failed

You will need to edit your :code:`/etc/hosts` file (which will require sudo access). Add the name of
your machine on the :code:`localhost` line. So if the name of your local machine is :code:`SATURN`,
then edit your :code:`/etc/hosts` to:

.. code-block:: bash

  ##
  # Host Database
  #
  # localhost is used to configure the loopback interface
  # when the system is booting. Do not change this entry.
  ##
  127.0.0.1	localhost SATURN
  255.255.255.255	broadcasthost
  ::1       localhost


7- Existing SkyLab experiments
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

At the moment there are four SkyLab flagship experiments:

* skylab-aero.yaml

* skylab-atm-land.yaml

* skylab-marine.yaml

* skylab-trace-gas.yaml

To read a more in depth description of the parameters available and the setup for these experiments,
please read our page on the :doc:`SkyLab experiments description </inside/jedi-components/skylab/skylab_description>`.
