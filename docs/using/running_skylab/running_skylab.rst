.. _build-run-skylab:

Building and running SkyLab
===========================

List of spack, software, and AMIs
---------------------------------

Versions used:

- spack-stack-1.9.1 from March 2025

  * https://github.com/JCSDA/spack-stack/tree/release/1.9.0

  * https://spack-stack.readthedocs.io/en/1.9.1

- AMI available in us-east-2 region (Ohio)

  - Ubuntu 24.04 with gcc and oneapi:

    AMI ID ami-0e1056b9bfde93698 (https://us-east-2.console.aws.amazon.com/ec2/v2/home?region=us-east-2#ImageDetails:imageId=ami-0e1056b9bfde93698)

.. note::

    It is necessary to use c6i.4xlarge or larger instances of this family
    (recommended: c6i.8xlarge when running the `skylab-atm-land-small` experiment).

For more information about using Amazon Web Services please see
:ref:`cloud_index`.

Developer Section
-----------------
**To follow this section, one needs read access to the JCSDA-internal GitHub
organization.**

Prerequisites
^^^^^^^^^^^^^

The following prerequisites will only need to be completed once on each HPC or
platform you are planning on running JEDI-Skylab on.

1. Set up your AWS credentials on the platform you are using.

  You will need to create or edit your ``~/.aws/config`` and
  ``~/.aws/credentials`` to make sure they contain:

  .. code-block:: ini
    :caption: ~/.aws/config

    [default]
    region=us-east-1

    # NOAA AWS acct config for the ``jcsda-noaa-aws-us-east-1`` R2D2 Data Hub
    [profile jcsda-noaa-aws-us-east-1]
    region=us-east-1

    # USAF AWS acct config for the ``jcsda-usaf-aws-us-east-2`` R2D2 Data Hub
    [profile jcsda-usaf-aws-us-east-2]
    region=us-east-2

  .. code-block:: ini
    :caption: ~/.aws/credentials

    # NOAA AWS acct credentials if default in config is us-east-1
    [default]
    aws_access_key_id=***
    aws_secret_access_key=***

    # NOAA AWS acct creds for the ``jcsda-noaa-aws-us-east-1`` R2D2 Data Hub
    [jcsda-noaa-aws-us-east-1]
    aws_access_key_id=***
    aws_secret_access_key=***

    # USAF AWS acct creds for the ``jcsda-usaf-aws-us-east-2`` R2D2 Data Hub
    [jcsda-usaf-aws-us-east-2]
    aws_access_key_id=***
    aws_secret_access_key=***

  .. tip::

    Make sure to protect your AWS config and credentials via:

    .. code-block:: bash

      chmod 400 ~/.aws/config
      chmod 400 ~/.aws/credentials

2. Set up your GitHub credentials following instructions at :ref:`git-config`.

Quickstart Build Guide
^^^^^^^^^^^^^^^^^^^^^^

This quickstart guide will walk you through setting up JEDI Skylab using
automation scripts developed and maintained by the JEDI team. If you would
prefer more manual control while building, skip to the :ref:`manual-build`.
This is the best way to make sure you are using the most recent spack-stack
modules, loading the correct environment variables, and building JEDI along
with the required JEDI workflow applications. This section can be used on a
supported HPC and on your localhost. If needed, more information can be found
in the `jedi-tools README <https://github.com/JCSDA-internal/jedi-tools/blob/develop/README.md>`_.

**1. Clone jedi-tools inside $JEDI_ROOT**

  :code:`$JEDI_ROOT` is the directory you will clone the JEDI code and all the files
  needed to build, test, and run JEDI and SkyLab.

  .. code-block:: bash

    export JEDI_ROOT=/path/to/where/you/want/JEDI
    mkdir $JEDI_ROOT
    cd $JEDI_ROOT
    git clone https://github.com/JCSDA-internal/jedi-tools.git

**2. Copy, edit, and source the setup script**

  In order to set up the spack-stack modules, JEDI-Skylab environment
  variables, and initialize your virtual environment you will use
  :code:`jedi-tools/buildscripts/setup.sh`. This script is designed to be
  reused each time you need to setup your environment and it is recommended to
  place in :code:`$JEDI_ROOT`. Edit the file header to set :code:`JEDI_ROOT`,
  :code:`HOST`, :code:`COMPILER`, :code:`R2D2_USER`, :code:`R2D2_API_KEY`,
  and optional :code:`WORKFLOW_ROOT`. If you are running on localhost, uncomment
  the spack-stack module statements and fill in for your local spack-stack location.

  .. note::

    The default for :code:`WORKFLOW_ROOT` get's set to :code:`JEDI_ROOT` and
    you can update this location as needed for your JEDI-Skylab set up.

  .. code-block:: bash

    cp $JEDI_ROOT/jedi-tools/buildscripts/setup.sh $JEDI_ROOT/
    vi $JEDI_ROOT/setup.sh
    # Edit the header for JEDI_ROOT, HOST, COMPILER, R2D2_USER, R2D2_API_KEY
    # and optional WORKFLOW_ROOT
    # If on localhost, uncomment and fill out your spack-stack information
    source $JEDI_ROOT/setup.sh

**3. Build JEDI-Skylab**

  Now that your environment is configured correctly you can build JEDI-Skylab.
  The build script provided will build the develop version of jedi-bundle.
  Feel free to look inside that file and specify the desired repository branch
  names. Alternatively, if you want to only build the workflow applications and
  use Skylab's experiment option of :code:`build_jedi: True` you can follow
  :ref:`quickstart-supp` provided at the end of this section.

  .. code-block:: bash

    bash $JEDI_ROOT/jedi-tools/buildscripts/build_jedi_skylab.sh

  Sit back, relax, and have a coffee while this script runs.

**4. Run JEDI ctests**

  Once the build completes, you can run the JEDI ctests. This can be done
  manually from :code:`$JEDI_BUILD` or you can use the Skylab experiment
  :code:`jedi-ctest.yaml`. If using Skylab to run ctests, you will need to
  start the ECFLOW UI.

  .. code-block:: bash
    :caption: Manual ctest example

    cd $JEDI_BUILD
    ctest

  .. code-block:: bash
    :caption: Skylab ctest example

    ecflow_ui &
    create_experiment.py $JEDI_WORKFLOW/skylab/experiments/jedi-ctest.yaml

  Congrats, you are ready to now run JEDI-Skylab experiments!

.. _quickstart-supp:

Supplemental Instructions
"""""""""""""""""""""""""

**Build only JEDI-Skylab workflow applications**

  If you got to Step 3 above and decided that you will be building JEDI during
  your Skylab experiment. You only need to build the workflow applications
  needed for the JEDI Skylab Environment which include simobs, r2d2-client,
  ewok, skylab, and the related data repositories r2d2-data and static-data.
  This is automated in :code:`jedi-tools/buildscripts/build_workflow_apps.sh`
  script. The default branches are set to develop, but if you need to specify
  different branches you can edit the file to set the branch names at the top.
  Then just run the script. The repositories will be built and installed in the
  :code:`$JEDI_WORKFLOW` directory.

  .. code-block:: bash

    bash $JEDI_ROOT/jedi-tools/buildscripts/build_workflow_apps.sh

.. _manual-build:

Manual Build Guide
^^^^^^^^^^^^^^^^^^

1 - Load modules
""""""""""""""""

First, you need to load all the modules needed to build jedi-bundle and the
jedi workflow applications, :code:`r2d2-client/ewok/simobs/skylab.`
Loading modules only sets up the environment for you. You still need
to build jedi-bundle, run ctests, install :code:`r2d2-client/ewok/simobs` and
clone skylab.

Currently we only support Orion, Hercules, Derecho, Discover, S4, and AWS
platforms. If you are working on a system not specified below please
follow the instructions on :ref:`jedi_portability`.

The commands for loading the modules to compile and run SkyLab are provided in
separate sections for :doc:`HPC platforms <../jedi_environment/modules>`
and :doc:`AWS instances (AMIs) <../jedi_environment/cloud/singlenode>`.
Users need to execute these commands before proceeding with the build of
``jedi-bundle`` below.

.. warning::

  If you are using ``spack-stack 1.7.0``, different versions of ``mapl`` are
  used with different variants, depending on the version of the compiler and
  whether the system is used for UFS or GEOS. Please reference
  `spack-stack 1.7.0 documentation <https://spack-stack.readthedocs.io/en/1.7.0/PreConfiguredSites.html>`_
  in a note and table under "3.1. Officially supported spack-stack
  installations" for more information.

.. _build-jedi-bundle:

2 - Build jedi-bundle
"""""""""""""""""""""

Once the stack is installed and the corresponding modules loaded, the next step
is to get and build the JEDI executables.

The first step is to create your work directory. In this directory you will clone
the JEDI code and all the files needed to build, test, and run JEDI and SkyLab.
We call this directory :code:`JEDI_ROOT` throughout this document.

The next step is to clone the code bundle to a local directory. To clone the
publicly available repositories use:

.. code-block:: bash

  mkdir $JEDI_ROOT
  cd $JEDI_ROOT
  git clone -b 8.0.0 https://github.com/JCSDA/jedi-bundle.git

Alternatively, developers with access to the internal repositories should
instead clone the development branch. For that use:

.. code-block:: bash

  mkdir $JEDI_ROOT
  cd $JEDI_ROOT
  git clone https://github.com/jcsda-internal/jedi-bundle

The example here is for jedi-bundle, the instructions apply to other bundles
as well.

From this point, we will use three environment variables:

* :code:`$JEDI_SRC` which should point to the base of the bundle to be built (i.e. the directory that was cloned just above, where the main CMakeLists.txt is located or :code:`$JEDI_ROOT/jedi-bundle`).

  .. code-block:: bash

    export JEDI_SRC=$JEDI_ROOT/jedi-bundle

* :code:`$JEDI_BUILD` which should point to the build directory or :code:`$JEDI_ROOT/build`. Create the directory if it does not exist.

  .. code-block:: bash

    export JEDI_BUILD=$JEDI_ROOT/build

* :code:`$JEDI_WORKFLOW` which should point to the base directory containing the JEDI-Skylab workflow applications of EWOK, R2D2-Client, SIMOBS, and Skylab. (ie :code:`$JEDI_ROOT/jedi-workflow`). Note, you are also able to still place these repos inside :code:`$JEDI_SRC` but make sure :code:`$JEDI_WORKFLOW` still gets set to that location.

  .. code-block:: bash

    export JEDI_WORKFLOW=$JEDI_ROOT/jedi-workflow

Note:

It is recommended these two directories are not one inside the other.

- Orion: it’s recommended to use :code:`$JEDI_ROOT=/work2/noaa/jcsda/${USER}/jedi`.

- Discover: it’s recommended to use :code:`$JEDI_ROOT=/discover/nobackup/${USER}/jedi`.

- On AWS Parallel Cluster, use :code:`$JEDI_ROOT=/mnt/experiments-efs/USER.NAME/jedi`.

- On the preconfigured AWS AMIs, use :code:`$JEDI_ROOT=$HOME/jedi`.

Before building JEDI, set up a python virtual environment based on the
spack-stack python installation and activate it.

Note the use of the ``python_ROOT`` variable which, at this point, should be
set to the python3 executable installed in your spack-stack environment.
This is important since it will ensure the python3 installation you will be
using is in sync with the spack-stack python modules (eg. py-numpy).

.. code-block:: bash

  cd $JEDI_ROOT
  $python_ROOT/bin/python3 -m venv --system-site-packages venv
  source venv/bin/activate

.. note::
  You need to activate this virtual environment every time you start a new
  session on your machine. Note below that the creation and usage (sourcing)
  of the :code:`$JEDI_ROOT/setup.h` script will cover this requirement.

Run the build of JEDI

.. code-block:: bash

  mkdir $JEDI_BUILD
  cd $JEDI_BUILD
  ecbuild $JEDI_SRC
  make -j8

Feel free to have a coffee while it builds. Once JEDI is built, you should
check the build was successful by running the tests (still from
:code:`$JEDI_BUILD`):

.. code-block:: bash

   	ctest

If you are on an HPC you may need to provide additional flags to the ecbuild
command, or login to a compute node, or submit a batch script for running the
ctests. Please refer to the :ref:`hpc_users_guide` for more details. You can also
run ctests using a Skylab experiment. This can be executed after Section
:ref:`Run-Skylab`, using the
:code:`$JEDI_WORKFLOW/skylab/experiments/jedi_ctest.yaml`.

Running the tests may take up to 2 hours depending on your system, so you might
want to take another coffee break. If all the expected tests pass,
congratulations! You have successfully built JEDI!

.. warning::

  If you are running on your own machine you will also need to clone the
  :code:`static-data` repo for some skylab experiments.

  .. code-block:: bash

    cd $JEDI_WORKFLOW
    git clone https://github.com/jcsda-internal/static-data

.. note::

  Run :code:`ctest --help` for more information on the test options. For even
  more information, see section :ref:`jedi-testing`.

3 - Clone and install r2d2-client/ewok/simobs, clone skylab only
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

We recommend that you use a python3 virtual environment (venv) for
building :code:`r2d2-client/ewok/simobs`. As indicated above in the note about
the :code:`$JEDI_WORKFLOW` environment variable, these can be placed in a
directory your choosing and does not need to be in :code:`$JEDI_ROOT/jedi-bundle`.

.. code-block:: bash

  cd $JEDI_WORKFLOW
  git clone https://github.com/jcsda-internal/r2d2-client
  git clone https://github.com/jcsda-internal/ewok
  git clone https://github.com/jcsda-internal/simobs
  git clone https://github.com/jcsda-internal/skylab

Or for the latest release of ``{skylab_v}``, clone the corresponding workflow
repository branches:

.. code-block:: bash

  cd $JEDI_WORKFLOW
  git clone --branch 3.0.0 https://github.com/jcsda-internal/r2d2-client
  git clone --branch 0.8.0 https://github.com/jcsda-internal/ewok
  git clone --branch 1.6.0 https://github.com/jcsda-internal/simobs
  git clone --branch 8.0.0 https://github.com/jcsda-internal/skylab

You can then proceed with

.. code-block:: bash

  cd $JEDI_WORKFLOW/r2d2-client
  python3 -m pip install -e .
  cd $JEDI_WORKFLOW/ewok
  python3 -m pip install -e .
  cd $JEDI_WORKFLOW/simobs
  python3 -m pip install -e .

4 - Setup SkyLab
""""""""""""""""

**Create and source $JEDI_ROOT/setup.sh**

We recommend creating this bash script and sourcing it before running the
experiment. This bash script sets environment variables such as
:code:`JEDI_BUILD`, :code:`JEDI_SRC`, :code:`JEDI_WORKFLOW`,
:code:`EWOK_WORKDIR` and :code:`EWOK_FLOWDIR` required by ewok. A reference
setup script that reflects the latest developmental code is available at
https://github.com/JCSDA-internal/jedi-tools/blob/develop/buildscripts/setup.sh.

The script contains logic for loading the required spack-stack modules
on configurable platforms (i.e. where :code:`R2D2_HOST=LOCALHOST`, see below),
and it pulls in spack-stack configurations for supported platforms.
These are located in
https://github.com/JCSDA-internal/jedi-tools/blob/develop/buildscripts/setup/
for the latest developmental code.

Users may set :code:`JEDI_ROOT`, :code:`JEDI_SRC`, :code:`JEDI_BUILD`,
:code:`JEDI_WORKFLOW`, :code:`EWOK_WORKDIR` and :code:`EWOK_FLOWDIR` to point
to relevant directories on their systems or use the default template in the
sample script. Note that these locations are experiment specific, i.e. you can
run several experiments at the same time, each having their own definition for
these variables.

The user further has to set four environment variables :code:`R2D2_HOST`,
:code:`R2D2_COMPILER`, :code:`R2D2_USER`, and :code:`R2D2_API_KEY` in the script.
These are required by r2d2-client and ewok and are used to
initialize the location :code:`EWOK_STATIC_DATA` of the static data used by
skylab and call r2d2's REST service to your current environment. :code:`EWOK_STATIC_DATA` is
staged on the preconfigured platforms. On generic platforms, the script sets
:code:`EWOK_STATIC_DATA` to :code:`${JEDI_WORKFLOW}/static-data/static`.

Please don’t forget to source this script after creating it:
:code:`source $JEDI_ROOT/setup.sh`

Please see :ref:`hpc_users_guide` for more information on specifics for
editing this :code:`setup.sh` script and other general instructions and
notes for running skylab on supported HPC systems.

The script also sets the variable :code:`ECF_PORT` to a constant value that
depends on your user ID on the system. Please make sure that the resulting
value for :code:`ECF_PORT` is somewhere between 5000 and 20000. On some systems
(e.g. your own macOS laptop), the user ID is a large integer well outside the
allowed port range. Note that changing your :code:`ECF_PORT` will require you
to reconnect the ecflow server, so keeping it constant will keep your ecflow
server connected.

5 - Set up R2D2 (for MacOS and AWS Single Nodes)
""""""""""""""""""""""""""""""""""""""""""""""""

If you are running skylab locally on the MacOS or an AWS single node instance,
you will also have to set up R2D2's server using a Docker container.
This step should be skipped if you are on any other supported platforms.

**Clone the r2d2-data Repo**

As with the other repositories, clone this inside your :code:`$JEDI_WORKFLOW`
directory.

.. code-block:: bash

  cd $JEDI_WORKFLOW
  git clone https://github.com/jcsda-internal/r2d2-data

Create a local copy of the R2D2 data store:

.. code-block:: bash

  mkdir $HOME/r2d2-experiments-localhost
  cp -R $JEDI_WORKFLOW/r2d2-data/r2d2-experiments-localhost/* $HOME/r2d2-experiments-localhost


**Install, Start, and Configure the R2D2 Server**

Execution of R2D2 on MacOS and AWS single nodes requires Docker. If you are on macOS and have
not previously installed Docker, install it using brew:

.. code-block:: bash

  brew install docker

Then follow the instructions found in: 
https://github.com/JCSDA-internal/r2d2/tree/develop/server/README.md#localhost-docker-with-database.

.. _Run-Skylab:

6 - Run SkyLab
""""""""""""""

Now you are ready to start an ecflow server and run an experiment.
Make sure you are in your python virtual environment (venv).

First, start the ecflow server. Note that this may already be done by your
`setup.sh` script if you are using the reference script mentioned in the
previous sections from jedi-tools.

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

  create_experiment.py $JEDI_WORKFLOW/skylab/experiments/your-experiment.yaml

**Note for MacOS Users:**

If attempting to start the ecflow server on the MacOS gives you an error
message like this:

.. code-block::

  Failed to connect to <machineName>:<PortNumber>. After 2 attempts. Is the server running ?

  ...

  restart of server failed

You will need to edit your :code:`/etc/hosts` file (which will require sudo
access). Add the name of your machine on the :code:`localhost` line. So if the
name of your local machine is :code:`SATURN`, then edit your :code:`/etc/hosts`
to:

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


7 - Existing SkyLab experiments
"""""""""""""""""""""""""""""""

At the moment there are four SkyLab flagship experiments:

* skylab-aero.yaml

* skylab-atm-land.yaml

* skylab-marine.yaml

* skylab-trace-gas.yaml

To read a more in depth description of the parameters available and the setup
for these experiments, please read our page on the
:ref:`skylab-experiment-description`.
