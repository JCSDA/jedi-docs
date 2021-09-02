.. _top-mpas-jedi-build:

Building and Testing MPAS-JEDI
==============================

This section describes how to build MPAS-JEDI and confirm that your build is working by running the ctests.

MPAS-BUNDLE
-----------

In order to build MPAS-JEDI and its associated repositories and dependencies it is recommended to use
MPAS-BUNDLE, available at https://github.com/JCSDA/mpas-bundle

MPAS-BUNDLE is always built using :code:`ecbuild`. Full details on how to build a JEDI bundle are
provided :doc:`elsewhere </using/building_and_running/building_jedi>`, and it is recommended
to become familiar with those instructions before continuing here.

Building and testing MPAS-BUNDLE on Cheyenne
--------------------------------------------

Most development and testing of MPAS-JEDI has been performed on NCAR's Cheyenne HPC, and custom
scripts for creating the required build environment on Cheyenne are provided in MPAS-BUNDLE. After
cloning MPAS-BUNDLE from Github, you can find these scripts in :code:`mpas-bundle/env-setup`.
Before executing the :code:`ecbuild` command, :code:`source` the script appropriate for your choice of
compiler-mpi and shell.

After building the mpas-bundle, it is recommended to run the ctests. This suite of tests confirm that
your build is functioning as expected.

So the entire build-test process on Cheyenne would look like:

.. code-block:: bash

    cd <src-directory>
    git clone https://github.com/JCSDA/mpas-bundle.git
    source mpas-bundle/env-setup/<desired environment script>
    cd <build-directory>
    ecbuild <src-directory>/mpas-bundle
    make update
    make -j4
    cd mpasjedi
    ctest

Note: the :code:`gnu-openmpi` environment has been more extensively tested than the :code:`intel-impi`
environment on Cheyenne.

Building MPAS-BUNDLE in Singularity
-----------------------------------

MPAS-BUNDLE is also regularly tested in the JEDI Singularity containers. See
:doc:`here </using/jedi_environment/singularity>` for full instructions on using Singularity.

(Note: in the Singularity containers it is not necessary to source any script to set up the
environment since the container provides the environment. Otherwise, the build/test process
described above is the same.)


.. _controltesting-mpas:

Controlling the testing
-----------------------

You will likely find it helpful to familiarize yourself with the :code:`ctest` command options and logs
documented :doc:`here </inside/developer_tools/cmake>`.

The ctests also serve as examples and templates for using mpas-jedi in larger scale experiments. For more
information on the individual ctests, see
:doc:`the documentation for their yaml configuration files </inside/jedi-components/mpas-jedi/data>`.
