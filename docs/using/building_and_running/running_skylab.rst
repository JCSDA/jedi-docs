.. _build-run-skylab:

Building and running SkyLab
===========================

List of spack, software, and AMIs
---------------------------------

Versions used:

- spack-stack-1.1.0 from October 6, 2022

  * https://github.com/NOAA-EMC/spack-stack/tree/1.1.0 

  * https://spack-stack.readthedocs.io/en/1.1.0

- AMIs

  - Ubuntu 20.04 with gnu-10.3.0 and mpich-4.0.2:

    AMI Name skylab-2.0.0-ubuntu20

    AMI ID ami-02e7b2df53af9596b

    Recommend using t2.2xlarge instance or M5 instance with 32 cores (expensive …)

  - Red Hat 8 with gnu-11.2.1 and openmpi-4.1.4:

    AMI Name skylab-2.0.0-redhat8

    AMI ID ami-0f6b5f8a07d2f4350

    Recommend using t2.2xlarge instance or M5 instance with 32 cores (expensive …)


Developer section
-----------------
Note. To follow this section, one needs read access to the JCSDA-internal GitHub org.

1- Load modules
^^^^^^^^^^^^^^^
First, you need to load all the modules needed to build jedi-bundle and solo/r2d2/ewok.
Note loading modules only set up the environment for you. You still need to build
jedi-bundle, run ctests, and install solo/r2d2/ewok/simobs.

Please note that currently we only support Orion, Discover, and AWS platforms.
If you are working on a system not specified below please follow the instructions on
`JEDI Portability <https://jointcenterforsatellitedataassimilation-jedi-docs.readthedocs-hosted.com/en/1.4.0/using/jedi_environment/index.html>`_ .

Users are responsible for setting up their GitHub and AWS credentials on the platform they are using.

Orion - Intel-2022.0.2
""""""""""""""""""""""

.. code-block:: bash

  module purge
  module use /work/noaa/da/role-da/spack-stack/modulefiles
  module load miniconda/3.9.7
  module load ecflow/5.8.4
  module use /work/noaa/da/role-da/spack-stack/spack-stack-v1/envs/skylab-2.0.0-intel-2022.0.2/install/modulefiles/Core
  module load stack-intel/2022.0.2
  module load stack-intel-oneapi-mpi/2021.5.1
  module load stack-python/3.9.7
  module load jedi-ewok-env/1.0.0 jedi-fv3-env/1.0.0 soca-env/1.0.0 sp/2.3.3


Orion - gnu-10.2.0
""""""""""""""""""

.. code-block:: bash

  module purge
  module use /work/noaa/da/role-da/spack-stack/modulefiles
  module load miniconda/3.9.7
  module load ecflow/5.8.4
  module use /work/noaa/da/role-da/spack-stack/spack-stack-v1/envs/skylab-2.0.0-gnu-10.2.0/install/modulefiles/Core
  module load stack-gcc/10.2.0
  module load stack-openmpi/4.0.4
  module load stack-python/3.9.7
  module load jedi-ewok-env/1.0.0 jedi-fv3-env/1.0.0 soca-env/1.0.0 sp/2.3.3

Discover - intel-2022.0.1
"""""""""""""""""""""""""

.. code-block:: bash

  module purge
  module use /discover/swdev/jcsda/spack-stack/modulefiles
  module load miniconda/3.9.7
  module load ecflow/5.8.4
  module use /gpfsm/dswdev/jcsda/spack-stack/spack-stack-v1/envs/skylab-2.0.0-intel-2022.0.1/install/modulefiles/Core
  module load stack-intel/2022.0.1
  module load stack-intel-oneapi-mpi/2021.5.0
  module load stack-python/3.9.7
  module load jedi-ewok-env/1.0.0 jedi-fv3-env/1.0.0 soca-env/1.0.0 sp/2.3.3

Discover - gnu-10.1.0
"""""""""""""""""""""

.. code-block:: bash

  module purge
  module use /discover/swdev/jcsda/spack-stack/modulefiles
  module load miniconda/3.9.7
  module load ecflow/5.8.4
  module use /gpfsm/dswdev/jcsda/spack-stack/spack-stack-v1/envs/skylab-2.0.0-gnu-10.1.0/install/modulefiles/Core
  module load stack-gcc/10.1.0
  module load stack-openmpi/4.1.3
  module load stack-python/3.9.7
  module load jedi-ewok-env/1.0.0 jedi-fv3-env/1.0.0 soca-env/1.0.0 sp/2.3.3


S4 - intel-2022.1
"""""""""""""""""

.. code-block:: bash

  module purge
  module use /data/prod/jedi/spack-stack/modulefiles
  module load miniconda/3.9.12
  module load ecflow/5.8.4
  module use /data/prod/jedi/spack-stack/spack-stack-v1/envs/skylab-2.0.0-intel-2021.5.0/install/modulefiles/Core
  module load stack-intel/2021.5.0
  module load stack-intel-oneapi-mpi/2021.5.0
  module load stack-python/3.9.12
  module load jedi-ewok-env/1.0.0 jedi-fv3-env/1.0.0 soca-env/1.0.0 sp/2.3.3


AWS Ubuntu 20
"""""""""""""

.. code-block:: bash

  module use /home/ubuntu/spack-stack-v1/envs/skylab-2.0.0-gcc-10.3.0/install/modulefiles/Core
  module load stack-gcc/10.3.0
  module load stack-mpich/4.0.2 stack-python/3.8.10
  module load jedi-ewok-env/1.0.0 jedi-fv3-env/1.0.0 soca-env/1.0.0
  module load sp/2.3.3
  module av

AWS RedHat 8
""""""""""""

.. code-block:: bash

  scl enable gcc-toolset-11 bash
  module use /home/ec2-user/spack-stack-v1/envs/skylab-2.0.0-gcc-11.2.1/install/modulefiles/Core
  module load stack-gcc/11.2.1
  module load stack-openmpi/4.1.4 stack-python/3.9.7
  module load jedi-ewok-env/1.0.0 jedi-fv3-env/1.0.0 soca-env/1.0.0
  module load sp/2.3.3

2- Build jedi-bundle
^^^^^^^^^^^^^^^^^^^^

Once the stack is installed and the corresponding modules loaded, the next step
is to get and build the JEDI executables.

The first step is to create your work directory. In this directory you will clone
the JEDI code and all the files needed to build, test, and run JEDI and SkyLab.
We call this directory ``jedi_ROOT`` throughout this document.

The next step is to clone the code bundle to a local directory:

.. code-block:: bash

  mkdir $jedi_ROOT
  cd $jedi_ROOT
  git clone --branch 2.0.0 https://github.com/jcsda/jedi-bundle


The example here is for jedi-bundle, the instructions apply to other bundles as well.

From this point, we will use two environment variables:

* :code:`$JEDI_SRC` which should point to the base of the bundle to be built (i.e. the directory that was cloned just above, where the main CMakeLists.txt is located or :code:`$jedi_ROOT/jedi-bundle`). :code:`$JEDI_SRC=$jedi_ROOT/jedi-bundle`

* :code:`$JEDI_BUILD` which should point to the build directory or :code:`$jedi_ROOT/build`. Create the directory if it does not exist. :code:`$JEDI_BUILD=$jedi_ROOT/build`

Note:

It is recommended these two directories are not one inside the other.

- Orion: it’s recommended to use :code:`$jedi_ROOT=/work/noaa/da/${USER}/jedi`.

- Discover: it’s recommended to use :code:`$jedi_ROOT=/discover/nobackup/${USER}/jedi`.

- On the preconfigured AWS AMIs, use ``$jedi_ROOT=$HOME/jedi``


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
ctests. Please refer the `documentation <https://jointcenterforsatellitedataassimilation-jedi-docs.readthedocs-hosted.com/en/1.4.0/using/jedi_environment/modules.html#general-tips-for-hpc-systems>`_ for more details.

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
  git clone --branch 1.0.0 https://github.com/jcsda-internal/solo
  git clone --branch 1.1.0 https://github.com/jcsda-internal/r2d2
  git clone --branch 0.2.0 https://github.com/jcsda-internal/ewok
  git clone --branch 1.0.0 https://github.com/jcsda-internal/simobs
  git clone --branch 1.1.0 https://github.com/jcsda-internal/r2d2-data

  cd $jedi_ROOT
  python3 -m venv --system-site-packages --without-pip venv
  source venv/bin/activate

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
Create and source $jedi_ROOT/activate.sh
""""""""""""""""""""""""""""""""""""""""
We recommend creating this bash script and sourcing it before running the experiment.
This bash script sets environment variables such as :code:`jedi_ROOT`, :code:`JEDI_BUILD`,
and :code:`JEDI_SRC` for ecflow/ewok to use. Users may set :code:`JEDI_SRC`, :code:`JEDI_BUILD`,
and :code:`EWOK_TMP` however they want (that’s why we made them different variables)
or use the default template in the sample script below. Note that :code:`JEDI_SRC`
and :code:`JEDI_BUILD` are experiment specific, i.e. you can run several experiments
at the same time, each having their own :code:`JEDI_SRC` and :code:`JEDI_BUILD`. :code:`EWOK_STATIC_DATA`
includes static data used by ewok and is available on Orion, Discover, and the AWS AMI.
Make sure you set this variable based on the platform you are using.
Please don’t forget to source this script after creating it: :code:`source $jedi_ROOT/activate.sh`

.. code-block:: bash

  #!/bin/bash

  # Source source this file for ewok ecFlow workflows
  source $jedi_ROOT/venv/bin/activate

  if [ -z $jedi_ROOT ]; then
    export jedi_ROOT=**Set this based on your set up**
  fi

  if [ -z $JEDI_BUILD ]; then
    export JEDI_BUILD=${jedi_ROOT}/build
  fi

  # Add ioda python bindings to PYTHONPATH
  PYTHON_VERSION=`python3 -c 'import sys; version=sys.version_info[:2]; print("{0}.{1}".format(*version))'`
  export PYTHONPATH="${JEDI_BUILD}/lib/python${PYTHON_VERSION}/pyioda:${PYTHONPATH}"

  if [ -z $JEDI_SRC ]; then
    export JEDI_SRC=${jedi_ROOT}/jedi-bundle
  fi

  if [ -z $CARTOPY_DATA ]; then
    # On Orion
    export CARTOPY_DATA=/work/noaa/da/jedipara/ewok/cartopy_data
    # On Discover
    export CARTOPY_DATA=/discover/nobackup/projects/jcsda/s2127/ewok/cartopy_data
    # On AWS
    export CARTOPY_DATA=${jedi_ROOT}/cartopy_data
  fi

  if [ -z $EWOK_TMP ]; then
    export EWOK_TMP=${jedi_ROOT}/tmp
  fi

  # necessary user directories for ewok and ecFlow files
  mkdir -p $EWOK_TMP/ewok $EWOK_TMP/ecflow

  # ecFlow vars
  myid=$(id -u ${USER})
  if [[ $myid -gt 64000 ]]; then
    myid=$(awk -v min=3000 -v max=31000 -v seed=$RANDOM 'BEGIN{srand(seed); print int(min + rand() * (max - min + 1))}')
  fi
  export ECF_PORT=$((myid + 1500))

  host=$(hostname | cut -f1 -d'.')
  export ECF_HOST=$host

  # Define path to static B files (platform-dependent):
  # On orion:
  export EWOK_STATIC_DATA=/work/noaa/da/role-da/static
  # On discover:
  export EWOK_STATIC_DATA=/discover/nobackup/projects/jcsda/s2127/static/

  # On AWS:
  export EWOK_STATIC_DATA=$HOME/static

5- Run SkyLab
^^^^^^^^^^^^^
Now you are ready to start an ecflow server and run an experiment. Make sure you are in your python virtual environment (venv).

To start the ecflow server:

.. code-block:: bash

  ecflow_start.sh

Note: On Discover users need to specify port number (choose any port between 2500 and 9999)
using -p when running this command. You also need to set ECF_PORT manually on Discover:

.. code-block:: bash

  export ECF_PORT=2500
  ecflow_start.sh -p 2500

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

  ecflow_stop.sh

Note: On Discover users need to specify port number using -p when running this command.


.. code-block:: bash

	ecflow_stop.sh -p 2500

To start your ewok experiment:


.. code-block:: bash

  create_experiment.py $JEDI_SRC/ewok/experiments/your-experiment.yaml
