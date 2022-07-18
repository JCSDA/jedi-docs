.. _build-run-skylab:

Building and running SkyLab
===========================

List of spack, software, and AMIs
---------------------------------

Versions used:

- spack-stack-1.0.1 from July 5, 2022

  * https://github.com/NOAA-EMC/spack-stack/tree/spack-stack-1.0.1

  * https://spack-stack.readthedocs.io/en/spack-stack-1.0.1


- AMIs

  - Ubuntu 20.04 with gnu-9.4.0 and mpich-4.0.2:

    AMI Name skylab-1.0.0-ubuntu20

    AMI ID ami-04ea7b39d9af755b5

    Recommend using t2.2xlarge instance or M5 instance with 32 cores (expensive …)


  - Red Hat 8 with gnu-11.2.1 and openmpi-4.1.3:

    AMI Name skylab-1.0.0-redhat8

    AMI ID ami-0875d0395b6c95e0b

    Recommend using t2.2xlarge instance or M5 instance with 32 cores (expensive …)

  - **For DEMO only:** Red Hat 8 with gnu-11.2.1 and openmpi-4.1.3:

    AMI Name skylab-1.0.0-redhat8-demo

    AMI ID ami-0c147be434f4215e2

    Requires using m6i.32xlarge instance with 1TB of disk space (expensive …)

      If only running l95, qg and c12 experiments, use t2.2xlarge (should work)


Demo section
------------
This section provides detailed instructions on how to build and use an EC2 instance
based on an existing AMI. The AMI can be thought of as a pre-built template that provides
a software stack, and just needs the configuration details of the EC2 instance
(such as the number of cores, the amount of memory, etc.).

The following example uses the :code:`skylab-1.0.0-redhat8-demo` AMI.

1- Create and launch the instance from the AMI

Login to the AWS Console and select the EC2 service.
In the sidebar on the left, scroll down to the Images section and click on
the “AMIs” option.

Search for and select :code:`skylab-1.0.0-redhat8-demo` from the list of AMIs.
If the AMI does not show up, contact JCSDA (dom.heinzeller@ucar.edu) and provide
your AWS ID to be granted access.

Click on “Launch instance from AMI”.
A page will be presented which allows you to configure the instance.
Scroll up and down to find the boxes with the following titles and enter the suggested changes.

In the "Name and tags" box, enter a name for your instance with something easy to remember
such as <your initials>-skylab-redhat8-demo.

In the "Instance type" box, select the :code:`m6i.32xlarge` instance type, which has enough memory
for running the c96 experiments. Use the search bar to quickly find the instance selection.
Note that these instances are expensive,
i.e. please make sure to properly shut down or terminate the instance once no longer needed.

In the "Key pair" box, select your key pair (PEM) file.
Again use the search bar to quickly find your file.
  Note you will need a PEM file containing your private SSH key.
  Contact a JEDI Infrastructure team member if you need to set this up.

In the "Network settings" box, click on the "Select existing security group" button and select "Global SSH".
The "Global SSH" security group allows SSH from all IP addresses (“global SSH”) which will allow you to ssh from your
local machine to the instance

In the "Configure storage" box, enter an amount that is near 1TB which is plenty for demo purposes.
Note, as of the writing on this document the default amount is 995 GB which should be fine.

At the bottom of the page, review the "Summary" box, review the configuration and make any necessary corrections.

Once satisfied with the configuration, click on the "Launch instance" button.

At this point, your new instance will start up and run. On the page that comes
up there will be a message with the instance ID (in the
format “i-<long hex number>”. It is recommended to click on the instance ID
which will take you to the Instance viewer showing only your newly created instance.
Check the report to see if the desired instance name and configuration have been created successfully.

2- Connect to the running instance from your local machine
Go to the Instance viewer and select your instance (checkbox on the left side).

Click on “Connect”
	This brings up a page with details about your running instance. Select the "SSH Client" view near the top of the "Connect to instance" box. Toward the bottom will be a sample ssh command that can be used to connect to your instance. An example of this ssh command is:

.. code-block:: bash

  ssh -i "mytopsecretkey.pem" -o ServerAliveInterval=30 -Y -X \
	ec2-user@ec2-54-226-175-109.compute-1.amazonaws.com


3- Set up the environment and start ecflow server/GUI

After logging in, run the following commands:

.. code-block:: bash

  ulimit -s unlimited
  cd skylab-demo
  source activate.sh # be patient, loading the modules takes some time

  ecflow_start.sh # Take note of the “Host” name and “Port Number”
  ecflow_ui & # wait for the GUI to start up (can take some time)


Click on “Servers” → “Manage Servers”

Uncheck the existing server and add a new server, add in the hostname and port number. Make sure this server is selected, then close the dialog. Now select the server in the GUI.


If you notice that the ecflow GUI is unable to detect the change you can restart the GUI. click on “File → Quit” and then start ecflow_ui again:

.. code-block:: bash

  ecflow_ui & # wait for the GUI to start up (can take some time)


The server (directly below File, Panels, …) should now show a refresh interval of 60s +/-

Keep the GUI open, return to the command prompt. List the available experiments:

.. code-block:: bash

  ls -1 jedi-bundle/ewok/experiments/


Run an experiment, for example:

.. code-block:: bash

  create_experiment.py jedi-bundle/ewok/experiments/gfs-3dvar-c12.yaml

Take note of the experiment id (last line of the lengthy output from the above command).

Click the refresh button in the ecflow GUI (or wait for it to refresh), and expand the experiment by clicking on the triangles. Click on the colors towards the top-right of the ecflow GUI to see what they mean. Green and yellow are good, red is bad.

Once the experiment completes successfully and the data is uploaded to the JCSDA S3 bucket, the experiment disappears from the GUI. For some of the smaller experiments, this may happen before the first automatic refresh, and you’ll never see it in the GUI! Now use your local web browser and navigate to https://experiments.jcsda.org, select the experiment ID from the list and watch your plots in awe.

4- Using a different jedi-bundle
After running activate.sh:

.. code-block:: bash

  cd /home/ec2-user/skylab-demo
  git clone --branch 1.0.0 https://github.com/jcsda/jedi-bundle \
      my-custom-jedi-bundle
  export JEDI_SRC=/home/ec2-user/skylab-demo/my-custom-jedi-bundle


After cloning, create a custom build directory, build the code and run tests (ctest). The latter is required, because some of the tests currently download data that are used by the EWOK experiments. Note that a small number of tests (2-4) fail - this is expected and not a problem.

.. code-block:: bash

  export JEDI_BUILD=/home/ec2-user/skylab-demo/my-custom-build
  mkdir $JEDI_BUILD
  cd $JEDI_BUILD
  ecbuild $JEDI_SRC 2>&1 | tee log.ecbuild
  make -j8 2>&1 | tee log.make
  ctest 2>&1 | tee log.ctest

Now you are ready to run the experiments as before, using your own jedi-bundle.

Developer section
-----------------
Note. To follow this section, one needs read access to the JCSDA-internal GitHub org.

1- Load modules
^^^^^^^^^^^^^^^
First, you need to load all the modules needed to build jedi-bundle and solo/r2d2/ewok. Note loading modules only set up the environment for you. You still need to build jedi-bundle, run ctests, and install solo/r2d2/ewok.

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
  module use /work/noaa/da/role-da/spack-stack/spack-stack-v1/envs/skylab-1.0.0-intel-2022.0.2/install/modulefiles/Core
  module load stack-intel/2022.0.2
  module load stack-intel-oneapi-mpi/2021.5.1
  module load stack-python/3.9.7
  module load jedi-ewok-env/1.0.0 jedi-fv3-env/1.0.0 nco/5.0.6


Orion - gnu-10.2.0
""""""""""""""""""

.. code-block:: bash

  module purge
  module use /work/noaa/da/role-da/spack-stack/modulefiles
  module load miniconda/3.9.7
  module load ecflow/5.8.4
  module use /work/noaa/da/role-da/spack-stack/spack-stack-v1/envs/skylab-1.0.0-gnu-10.2.0-openmpi-4.0.4/install/modulefiles/Core
  module load stack-gcc/10.2.0
  module load stack-openmpi/4.0.4
  module load stack-python/3.9.7
  module load jedi-ewok-env/1.0.0 jedi-fv3-env/1.0.0 nco/5.0.6

Discover - intel-2022.0.1
"""""""""""""""""""""""""

.. code-block:: bash

  module purge
  module use /discover/swdev/jcsda/spack-stack/modulefiles
  module load miniconda/3.9.7
  module load ecflow/5.8.4
  module use /discover/swdev/jcsda/spack-stack/spack-stack-v1/envs/skylab-1.0.0-intel-2022.0.1/install/modulefiles/Core
  module load stack-intel/2022.0.1
  module load stack-intel-oneapi-mpi/2021.5.0
  module load stack-python/3.9.7
  module load jedi-ewok-env/1.0.0 jedi-fv3-env/1.0.0 nco/5.0.6

Discover - gnu-10.1.0
"""""""""""""""""""""

.. code-block:: bash

  module purge
  module use /discover/swdev/jcsda/spack-stack/modulefiles
  module load miniconda/3.9.7
  module load ecflow/5.8.4
  module use /discover/swdev/jcsda/spack-stack/spack-stack-v1/envs/skylab-1.0.0-gnu-10.1.0/install/modulefiles/Core
  module load stack-gcc/10.1.0
  module load stack-openmpi/4.1.3
  module load stack-python/3.9.7
  module load jedi-ewok-env/1.0.0 jedi-fv3-env/1.0.0 nco/5.0.6

AWS Ubuntu 20
"""""""""""""

.. code-block:: bash

  module use /home/ubuntu/spack-stack-v1/envs/skylab-1.0.0/install/modulefiles/Core
  module load stack-gcc/9.4.0
  module load stack-mpich/4.0.2 stack-python/3.8.10
  module load jedi-ewok-env/1.0.0 jedi-fv3-env/1.0.0 nco/5.0.6
  module av

AWS RedHat 8
""""""""""""

.. code-block:: bash

  scl enable gcc-toolset-11 bash
  module use /home/ec2-user/spack-stack-v1/envs/skylab-1.0.0/install/modulefiles/Core
  module load stack-gcc/11.2.1
  module load stack-openmpi/4.1.3 stack-python/3.9.7
  module load jedi-ewok-env/1.0.0 jedi-fv3-env/1.0.0 nco/5.0.6

2- Build jedi-bundle
^^^^^^^^^^^^^^^^^^^^

Once the stack is installed and the corresponding modules loaded, the next step is to get and build the JEDI executables.

The first step is to create your work directory. In this directory you will clone the JEDI code and all the files needed to build, test, and run JEDI and SkyLab. We call this directory jedi_ROOT throughout this document.

The next step is to clone the code bundle to a local directory:

.. code-block:: bash

  mkdir $jedi_ROOT
  cd $jedi_ROOT
  git clone --branch 1.0.0 https://github.com/jcsda/jedi-bundle


The example here is for jedi-bundle, the instructions apply to other bundles as well.

From this point, we will use two environment variables:

* :code:`$JEDI_SRC` which should point to the base of the bundle to be built (i.e. the directory that was cloned just above, where the main CMakeLists.txt is located or :code:`$jedi_ROOT/jedi-bundle`). :code:`$JEDI_SRC=$jedi_ROOT/jedi-bundle`

* :code:`$JEDI_BUILD` which should point to the build directory or :code:`$jedi_ROOT/build`. Create the directory if it does not exist. :code:`$JEDI_BUILD=$jedi_ROOT/build`

Note:

It is recommended these two directories are not one inside the other.

- Orion: it’s recommended to use :code:`$jedi_ROOT=/work/noaa/da/${USER}/jedi`.

- Discover: it’s recommended to use :code:`$jedi_ROOT=/discover/nobackup/${USER}/jedi`.

- On the preconfigured AWS AMIs, use $jedi_ROOT=$HOME/jedi


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
  that download data (this is temporary) and generate static files.

3- Build solo/r2d2/ewok
^^^^^^^^^^^^^^^^^^^^^^^
We recommend that you use a python3 virtual environment (venv) for building solo/r2d2/ewok

.. code-block:: bash

  cd $JEDI_SRC
  git clone --branch 1.0.0 https://github.com/jcsda-internal/solo
  git clone --branch 1.0.0 https://github.com/jcsda-internal/r2d2
  git clone --branch 0.1.0 https://github.com/jcsda-internal/ewok
  git clone --branch 1.0.0 https://github.com/jcsda-internal/r2d2-data

  cd $jedi_ROOT
  python3 -m venv --system-site-packages --without-pip venv
  source venv/bin/activate

  cd $JEDI_SRC/solo
  python3 -m pip install -e .
  cd $JEDI_SRC/r2d2
  python3 -m pip install -e .
  cd $JEDI_SRC/ewok
  python3 -m pip install -e .

Note: You need to run :code:`source venv/bin/activate` every time you start a
new session on your machine.

4- Setup SkyLab
^^^^^^^^^^^^^^^
A - Create $jedi_ROOT/config_r2d2.yaml
""""""""""""""""""""""""""""""""""""""

In this file you specify the location of your local, shared, and cloud files
managed by R2D2. There are examples of this configuration file available on r2d2.
Please see :code:`$JEDI_SRC/r2d2/src/r2d2/config`.

Note that several databases are listed in config_r2d2.yaml. Make sure “root” is
set correctly so r2d2 can store or access these databases on your system.
You need to set :code:`r2d2_experiments_orion` to the path you want to save your
SkyLab experiment outputs to. You can also store local SkyLab input files
in :code:`r2d2_experiments_orion` before uploading them to the shared databases.


B - Create and source $jedi_ROOT/activate.sh
""""""""""""""""""""""""""""""""""""""""""""
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

  export R2D2_CONFIG=${jedi_ROOT}/config_r2d2.yaml

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

Please note “Host” and “Port Number” here.

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
