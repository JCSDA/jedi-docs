.. _build-run-skylab:

Building and running SkyLab
===========================

List of spack, software, and AMIs
---------------------------------

Versions used:

- spack-stack-1.3.0 from April 10, 2023

  * https://github.com/NOAA-EMC/spack-stack/tree/1.3.0

  * https://spack-stack.readthedocs.io/en/1.3.0/

- AMIs available in us-east-1 region (N. Virginia)

  - Red Hat 8 with gnu-11.2.1 and openmpi-4.1.4:

    AMI Name skylab-4.0.0-redhat8

    AMI ID ami-098a3fdd801055c14


- AMIs available in us-east-2 region (Ohio)

  - Red Hat 8 with gnu-11.2.1 and openmpi-4.1.4:

    AMI Name skylab-4.0.0-redhat8

    AMI ID ami-039759644cac741eb


    It is necessary to use c6i.2xlarge or larger instances of this family.

Developer section
-----------------
Note. To follow this section, one needs read access to the JCSDA-internal GitHub org.

1- Load modules
^^^^^^^^^^^^^^^
First, you need to load all the modules needed to build jedi-bundle and solo/r2d2/ewok.
Note loading modules only set up the environment for you. You still need to build
jedi-bundle, run ctests, and install solo/r2d2/ewok/simobs.

Please note that currently we only support Orion, Discover, S4, and AWS platforms.
If you are working on a system not specified below please follow the instructions on
`JEDI Portability <https://jointcenterforsatellitedataassimilation-jedi-docs.readthedocs-hosted.com/en/1.7.0/using/jedi_environment/index.html>`_.

Users are responsible for setting up their GitHub and AWS credentials on the platform they are using.
You will need to create or edit your ``~/.aws/credentials`` and ``~/.aws/config`` to make sure they contain:

      .. code-block:: bash

         [default]
         aws_access_key_id=***
         aws_secret_access_key=***

         [jcsda-noaa-us-east-1]
         aws_access_key_id=***
         aws_secret_access_key=***

         [jcsda-usaf-us-east-2]
         aws_access_key_id=***
         aws_secret_access_key=***


      .. code-block:: bash

         [default]
         region = us-east-1


The commands for loading the modules to compile and run Skylab are provided in separate sections for :doc:`HPC platforms <../jedi_environment/modules>` and :doc:`AWS instances (AMIs) <../jedi_environment/cloud/singlenode>`. Users need to execute these commands before proceeding with the build of ``jedi-bundle`` below.

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
  git clone --branch 4.0.0 https://github.com/jcsda/jedi-bundle


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
ctests. Please refer the `documentation <https://jointcenterforsatellitedataassimilation-jedi-docs.readthedocs-hosted.com/en/1.6.0/using/jedi_environment/modules.html#general-tips-for-hpc-systems>`_ for more details.

(You might have another coffee.) You have successfully built JEDI!

.. warning::

  Even if you are a master builder and don’t need to check your build, if you
  intend to run experiments with ewok, you still need to run a few of the tests
  that download data (this is temporary) and generate static files. You can run
  these tests with:

  .. code-block:: bash

        ctest -R get_
        ctest -R bumpparameters

3- Build solo/r2d2/ewok/simobs
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
We recommend that you use a python3 virtual environment (venv) for
building solo/r2d2/ewok/simobs

.. code-block:: bash

  cd $JEDI_SRC
  git clone --branch 1.1.0 https://github.com/jcsda-internal/solo
  git clone --branch 1.2.0 https://github.com/jcsda-internal/r2d2
  git clone --branch 0.3.1 https://github.com/jcsda-internal/ewok
  git clone --branch 1.1.0 https://github.com/jcsda-internal/simobs

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

The user further has to set the environment variable :code:`R2D2_HOST` in the script
on pre-configured platforms, or unset this variable on generic platforms.
:code:`R2D2_HOST` is required by r2d2, ewok, and to determine the location :code:`EWOK_STATIC_DATA`
of the static data used by ewok. This data is staged on the preconfigured platforms.
On generic platforms, the script sets :code:`EWOK_STATIC_DATA` to :code:`${JEDI_ROOT}/static`.

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

  # On Orion:
  export R2D2_HOST=orion
  # On Discover:
  export R2D2_HOST=discover
  # On Cheyenne:
  export R2D2_HOST=cheyenne
  # On S4:
  export R2D2_HOST=s4
  # On AWS Parallel Cluster
  export R2D2_HOST=aws-pcluster
  # On your local machine / AWS single node
  unset R2D2_HOST

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
  export PYTHONPATH="${JEDI_BUILD}/lib/python${PYTHON_VERSION}/pyioda:${PYTHONPATH}"

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

  if [[ x"${R2D2_HOST}" == "x" ]]; then
    export EWOK_STATIC_DATA=${JEDI_ROOT}/static
  else
    case $R2D2_HOST in
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
        echo "Unknown host name $R2D2_HOST"
        exit 1
        ;;
    esac
  fi

5- Run SkyLab
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

  create_experiment.py $JEDI_SRC/ewok/experiments/your-experiment.yaml
