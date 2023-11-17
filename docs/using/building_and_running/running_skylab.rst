.. _build-run-skylab:

Building and running SkyLab
===========================

List of spack, software, and AMIs
---------------------------------

Versions used:

- spack-stack-1.5.1 from November 2023

  * https://github.com/JCSDA/spack-stack/tree/1.5.1

  * https://spack-stack.readthedocs.io/en/1.5.1

- AMI available in us-east-1 region (N. Virginia)

  - Red Hat 8 with gnu-11.2.1 and openmpi-4.1.5:

    AMI Name skylab-6.1.0-redhat8

    AMI ID ami-06497c2e0f2ded6cf (https://us-east-1.console.aws.amazon.com/ec2/home?region=us-east-1#ImageDetails:imageId=ami-06497c2e0f2ded6cf)

- AMI available in us-east-2 region (Ohio)

  - Red Hat 8 with gnu-11.2.1 and openmpi-4.1.5:

    AMI Name skylab-6.1.0-redhat8

    AMI ID ami-0b1ce08e2fd42333b (https://us-east-2.console.aws.amazon.com/ec2/v2/home?region=us-east-2#ImageDetails:imageId=ami-0b1ce08e2fd42333b)

Note. It is necessary to use c6i.4xlarge or larger instances of this family (recommended: c6i.8xlarge when running the `skylab-atm-land-small` experiment). 

Developer section
-----------------
Note. To follow this section, one needs read access to the JCSDA-internal GitHub org.

1- Load modules
^^^^^^^^^^^^^^^
First, you need to load all the modules needed to build jedi-bundle and solo/r2d2/ewok/simobs/skylab.
Note that loading modules only sets up the environment for you. You still need to build
jedi-bundle, run ctests, install solo/r2d2/ewok/simobs and download skylab.

Please note that currently we only support Orion, Discover, S4, and AWS platforms.
If you are working on a system not specified below please follow the instructions on
`JEDI Portability <https://jointcenterforsatellitedataassimilation-jedi-docs.readthedocs-hosted.com/en/6.0.0/using/jedi_environment/index.html>`_.

Users are responsible for setting up their GitHub and AWS credentials on the platform they are using.
You will need to create or edit your ``~/.aws/config`` and ``~/.aws/credentials`` to make sure they contain:


      .. code-block:: bash

         [default]
         region=us-east-1

         [jcsda-noaa-us-east-1]
         region=us-east-1

         [jcsda-usaf-us-east-2]
         region=us-east-2


      .. code-block:: bash

         [default]
         aws_access_key_id=***      # NOAA AWS account credentials if default in config is us-east-1
         aws_secret_access_key=***

         [jcsda-noaa-us-east-1]
         aws_access_key_id=***      # NOAA AWS account credentials
         aws_secret_access_key=***

         [jcsda-usaf-us-east-2]
         aws_access_key_id=***      # USAF AWS account credentials
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



2- Build jedi-bundle
^^^^^^^^^^^^^^^^^^^^

Once the stack is installed and the corresponding modules loaded, the next step
is to get and build the JEDI executables.

The first step is to create your work directory. In this directory you will clone
the JEDI code and all the files needed to build, test, and run JEDI and SkyLab.
We call this directory ``JEDI_ROOT`` throughout this document.

The next step is to clone the code bundle to a local directory:

.. code-block:: bash

  mkdir $JEDI_ROOT
  cd $JEDI_ROOT
  git clone https://github.com/jcsda/jedi-bundle


The example here is for jedi-bundle, the instructions apply to other bundles as well.

From this point, we will use two environment variables:

* :code:`$JEDI_SRC` which should point to the base of the bundle to be built (i.e. the directory that was cloned just above, where the main CMakeLists.txt is located or :code:`$JEDI_ROOT/jedi-bundle`). :code:`$JEDI_SRC=$JEDI_ROOT/jedi-bundle`

* :code:`$JEDI_BUILD` which should point to the build directory or :code:`$JEDI_ROOT/build`. Create the directory if it does not exist. :code:`$JEDI_BUILD=$JEDI_ROOT/build`

Note:

It is recommended these two directories are not one inside the other.

- Orion: it’s recommended to use :code:`$JEDI_ROOT=/work/noaa/da/${USER}/jedi`.

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
the build was successful by running the tests (still from $JEDI_BUILD):

.. code-block:: bash

   	ctest

If you are on an HPC you may need to provide additional flags to the ecbuild
command, or login to a compute node, or submit a batch script for running the
ctests. Please refer the `documentation <https://jointcenterforsatellitedataassimilation-jedi-docs.readthedocs-hosted.com/en/6.0.0/using/jedi_environment/modules.html#general-tips-for-hpc-systems>`_ for more details.

(You might have another coffee.) You have successfully built JEDI!

.. warning::

  Even if you are a master builder and don’t need to check your build, if you
  intend to run experiments with ewok, you still need to run a few of the tests
  that download data (this is temporary). You can run these tests with:

  .. code-block:: bash

        ctest -R get_

  If you are running on your own machine you will also need to clone the static-data repo for some skylab experiments. 

  .. code-block:: bash

    cd $JEDI_SRC
    git clone https://github.com/jcsda-internal/static-data

.. note::

  Run :code:`ctest --help` for more information on the test options. Also, you may find yourself in a situation in which
  you only want to run a single test such as :code:`test_soca_lefkf` and see its verbose output, but excecuting
  :code:`ctest -VV -R test_soca_lefkf` will also run and write the output for the :code:`test_soca_letkf_split_observer`
  and :code:`test_soca_letkf_split_solver` tests. To run only the first test enter a :code:`$`
  at the end of the test name like this:

  .. code-block:: bash

    ctest -VV -R test_soca_lefkf$

3- Clone and install solo/r2d2/ewok/simobs, clone skylab only
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
We recommend that you use a python3 virtual environment (venv) for
building solo/r2d2/ewok/simobs. As indicated above in the note about
the :code:`$JEDI_SRC` and :code:`$JEDI_BUILD` environment variables, 
clone these repos *inside* the clone of the jedi-bundle repo.

.. code-block:: bash

  cd $JEDI_SRC
  git clone https://github.com/jcsda-internal/solo
  git clone https://github.com/jcsda-internal/r2d2
  git clone https://github.com/jcsda-internal/ewok
  git clone https://github.com/jcsda-internal/simobs
  git clone https://github.com/jcsda-internal/skylab

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

Note: You need to run :code:`source venv/bin/activate` every time you start a
new session on your machine.

4- Setup SkyLab
^^^^^^^^^^^^^^^

Create and source $JEDI_ROOT/activate.sh
""""""""""""""""""""""""""""""""""""""""
We recommend creating this bash script and sourcing it before running the experiment.
This bash script sets environment variables such as :code:`JEDI_BUILD`, :code:`JEDI_SRC`,
:code:`EWOK_WORKDIR` and :code:`EWOK_FLOWDIR` required by ewok. If these variables are not
defined they will be set from :code:`JEDI_ROOT`.

Users may set :code:`JEDI_SRC`, :code:`JEDI_BUILD`, :code:`EWOK_WORKDIR` and
:code:`EWOK_FLOWDIR` to point to relevant directories on their systems
or use the default template in the sample script below. Note that :code:`JEDI_SRC`,
:code:`JEDI_BUILD` and :code:`EWOK_WORKDIR` are experiment specific, i.e. you can run several
experiments at the same time, each having their own definition for these variables.

The user further has to set the environment variable :code:`R2D2_HOST` in the script.
:code:`R2D2_HOST` is required by r2d2, ewok, and to determine the location :code:`EWOK_STATIC_DATA`
of the static data used by ewok. This data is staged on the preconfigured platforms.

In the section that exports your :code:`R2D2_HOST`, **Be sure to remove all lines that
are NOT relevant to your platform.**

On generic platforms, the script sets :code:`EWOK_STATIC_DATA` to :code:`${JEDI_SRC}/static-data/static`.

Please don’t forget to source this script after creating it: :code:`source $JEDI_ROOT/activate.sh`

.. code-block:: bash

  #!/bin/bash

  # Set JEDI_ROOT

  if [ -z $JEDI_ROOT ]; then
    export JEDI_ROOT=**Set this based on your set up if JEDI_SRC, JEDI_BUILD, EWOK_WORKDIR or EWOK_FLOWDIR are not defined.**
  fi

  if [ -z $JEDI_SRC ]; then
    export JEDI_SRC=${JEDI_ROOT}/jedi-bundle
  fi

  # Set host name for R2D2/EWOK

  # On Orion
  export R2D2_HOST=orion
  # On Discover
  export R2D2_HOST=discover
  # On Cheyenne
  export R2D2_HOST=cheyenne
  # On S4
  export R2D2_HOST=s4
  # On AWS Parallel Cluster
  export R2D2_HOST=aws-pcluster
  # On your local machine / AWS single node
  export R2D2_HOST=localhost

  # Most users won't need to change the following settings

  # Source source this file for ewok ecFlow workflows
  source $JEDI_ROOT/venv/bin/activate

  if [ -z $JEDI_BUILD ]; then
    export JEDI_BUILD=${JEDI_ROOT}/build
  fi

  if [ -z $EWOK_WORKDIR ]; then
    export EWOK_WORKDIR=${JEDI_ROOT}/workdir
  fi

  if [ -z $EWOK_FLOWDIR ]; then
    export EWOK_FLOWDIR=${JEDI_ROOT}/ecflow
  fi

  # Add ioda python bindings to PYTHONPATH
  PYTHON_VERSION=`python3 -c 'import sys; version=sys.version_info[:2]; print("{0}.{1}".format(*version))'`
  export PYTHONPATH="${JEDI_BUILD}/lib/python${PYTHON_VERSION}:${PYTHONPATH}"

  # necessary user directories for ewok and ecFlow files
  mkdir -p $EWOK_WORKDIR $EWOK_FLOWDIR

  # ecFlow vars
  myid=$(id -u ${USER})
  if [[ $myid -gt 64000 ]]; then
    myid=$(awk -v min=3000 -v max=31000 -v seed=$RANDOM 'BEGIN{srand(seed); print int(min + rand() * (max - min + 1))}')
  fi
  export ECF_PORT=$((myid + 1500))

  # The ecflow hostname (e.g. a specific login node) is different from the R2D2/EWOK general host (i.e. system) name
  host=$(hostname | cut -f1 -d'.')
  export ECF_HOST=$host

  case $R2D2_HOST in
    localhost)
      export EWOK_STATIC_DATA=${JEDI_SRC}/static-data/static
      ;;
    orion)
      export EWOK_STATIC_DATA=/work/noaa/da/role-da/static
      ;;
    discover)
      export EWOK_STATIC_DATA=/discover/nobackup/projects/jcsda/s2127/static
      ;;
    cheyenne)
      export EWOK_STATIC_DATA=/glade/p/mmm/jedipara/static
      ;;
    s4)
      export EWOK_STATIC_DATA=/data/prod/jedi/static
      ;;
    aws-pcluster)
      export EWOK_STATIC_DATA=${JEDI_ROOT}/static
      ;;
    *)
      echo "Unknown host name '$R2D2_HOST'"
      exit 1
      ;;
  esac



If you are running locally you my want to pick a constant value for :code:`ECF_PORT`. As written,
the code above will generate a new, random value for your :code:`ECF_PORT` everytime this script
is sourced. Changing your :code:`ECF_PORT` will require you to reconnect the ecflow server after
everytime this script is sourced, so keeping it constant will keep your ecflow server connected.

Note: On AWS pcluster users will need to update the python version referenced in the above
:code:`source $JEDI_ROOT/activate.sh` script. The following lines under 
:code:`# ecflow and pyioda Python bindings` should be:

.. code-block:: bash

    # ecflow and pyioda Python bindings
    PYTHON_VERSION=`python3 -c 'import sys; version=sys.version_info[:2]; print("{0}.{1}".format(*version))'`
    export PYTHONPATH="${JEDI_BUILD}/lib/python${PYTHON_VERSION}:/home/ubuntu/jedi/ecflow-5.8.4/lib/python3.8/site-packages:${PYTHONPATH}"



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

To start the ecflow server:

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
