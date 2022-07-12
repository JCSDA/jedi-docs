.. _top-fv3-jedi-build:

Building FV3-JEDI
=================

For most uses, it is recommended to build FV3-JEDI via the
`FV3-BUNDLE <https://github.com/jcsda/fv3-bundle>`_, which includes associated repositories and
dependencies. This page describes the options that can be configured when building FV3-JEDI via the
FV3-BUNDLE.

When using FV3-JEDI with the UFS forecast model, it is instead recommended to build via the
`UFS-BUNDLE <https://github.com/jcsda/ufs-bundle>`_. This bundle and associated documentation
are in development.

FV3-BUNDLE
----------

FV3-BUNDLE is an ecbuild (a CMake-based build system) script that will install and compile the
FV3-JEDI repositories and dependencies together. Please follow these |build_jedi_link| to configure
and build FV3-JEDI using FV3-BUNDLE.

.. |build_jedi_link| raw:: html

   <a href="https://jointcenterforsatellitedataassimilation-jedi-docs.readthedocs-hosted.com/en/
   latest/using/building_and_running/building_jedi.html"
   target="_blank">build instructions</a>

When issuing the initial ecbuild command, FV3-BUNDLE/JEDI can accept a number of options,
prepended with :code:`-D`. For example, this command selects which forecast model
to use with FV3-JEDI:

.. code::

   ecbuild -DFV3_FORECAST_MODEL=FV3CORE ../

The various options that FV3-JEDI can accept are described below.

.. _buildwithmodel:

Choosing an FV3-based model to build with
-----------------------------------------

FV3-JEDI depends on the FV3 dynamical core and cannot be built without some version of it being
included. Currently there are three models that can be used to provide FV3 as well as the potential
to make forecasts in-core with FV3-JEDI:

- The JCSDA fork of GFDL_atmos_cubed_sphere (https://github.com/JCSDA/GFDL_atmos_cubed_sphere).
  GFDL_atmos_cubed_sphere contains only the FV3 dynamical core and none of the model physics or
  model infrastructure.
- The ufs-weather-model (https://github.com/ufs-community/ufs-weather-model).
- GEOSgcm (https://github.com/GEOS-ESM/GEOSgcm).

By default FV3-BUNDLE builds with GFDL_atmos_cubed_sphere; this provides everything necessary to
run any data assimilation systems that do not involve executing a forecast of the full model with
physics in-core with FV3-JEDI. This default behavior can also be directly requested using the
following ecbuild command:

.. code::

   ecbuild -DFV3_FORECAST_MODEL=FV3CORE ../

**The instructions in the remainder of this section are for advanced uses of FV3-JEDI where it is
necessary to build with the GEOS forecast model. The below requires GEOS to be installed.**

Building with GEOS is selected by specifying:

.. code::

   -DFV3_FORECAST_MODEL=GEOS

When building with GEOS it is also necessary to pass the path where model is installed.
This is controlled by the flag:

.. code::

   -DFV3_FORECAST_MODEL_ROOT=/path/to/model/install

FV3-JEDI will build certain tests when GEOS is used but a directory where GEOS can run from must be
provided and is passed to the build as follows:

.. code::

   -DFV3_FORECAST_MODEL_RUNDIR=/path/to/model/run/directory

Note that users should not provide the path where GEOS can be run from themselves since the
test has been designed with a certain expected result. Consult FV3-JEDI developers for a suitable
path. GEOS typically only runs on Discover and there the test path to be provided is:

.. code::

   -DFV3_FORECAST_MODEL_RUNDIR=/discover/nobackup/drholdaw/JediData/ModelRunDirs/geos-c24

**For building with UFS, see the UFS-BUNDLE. Note that building with UFS is still in relatively
early development; please consult FV3-JEDI developers for more details about this functionality.**

The FV3 dynamical core can be built in either single or double precision, where double is the
default behavior. When using GEOS or UFS the choice needs to match the choice that was made when the
model was installed. When building with FV3CORE the choice can be made at the same time as building
FV3-BUNDLE. This choice is controlled with:

.. code::

   -DFV3_PRECISION=SINGLE
   -DFV3_PRECISION=DOUBLE  # default value

Optional observation operators
------------------------------

There are two optional UFO observation operators that FV3-JEDI can be used with. These are the ROPP
GNSSRO operator from EUMETSAT and the GEOS_AERO AOD operator from NASA. These operators are not
available without signing a license agreement so are omitted by default, but they can be built by
turning the option to skip them to :code:`OFF`:

.. code::

   -DBUNDLE_SKIP_GEOS-AERO=OFF
   -DBUNDLE_SKIP_ROPP-UFO=OFF

.. _controltesting:

Controlling the testing
-----------------------

FV3-JEDI comes with tiered testing. The level of testing that will be compiled is chosen by setting
the environment variable :code:`FV3JEDI_TEST_TIER`. The value can be set to 1 or 2. All tests
up to including the value in :code:`FV3JEDI_TEST_TIER` will be built. Note that it is not necessary
to manually run ecbuild again after changing the environment variable. It would be sufficient to
touch one of the CMakeLists.txt files in FV3-JEDI, which will trigger cmake automatically.

Most of the tests that run in FV3-JEDI require 6 processors, 1 per face of the cube. Some of the
ensemble or parallel tests use a larger number, in some cases as many as 24. It is possible to skip
these tests on systems that may not be able to support them with the following flag:

.. code::

   ecbuild -DBUILD_LARGE_TESTS=OFF
