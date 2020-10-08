.. _top-fv3-jedi-build:

Building FV3-JEDI
=================

This section describes the options that can be used when building FV3-JEDI.

FV3-BUNDLE
----------

In order to build FV3-JEDI and its associated repositories and dependencies it is recommended to use
FV3-BUNDLE, available at https://github.com/jcsda/fv3-bundle

FV3-BUNDLE is always built using ecbuild. When issuing the initial ecbuild command FV3-JEDI can
accept a number of optional directives, prepended with :code:`-D`. For example

.. code::

   ecbuild -DFV3_FORECAST_MODEL_BUILD=FV3CORE ../

The various options that FV3-JEDI can accept are described below.

It is recommended that the |location_link| on various supported platforms are followed
closely when building FV3-BUNDLE.

.. |location_link| raw:: html

   <a href="https://jointcenterforsatellitedataassimilation-jedi-docs.readthedocs-hosted.com/en/latest/developer/building_and_testing/building_jedi.html" target="_blank">instructions for building</a>

Choosing a Model
----------------

FV3-JEDI depends on the FV3 dynamical core and cannot be built without some version of it being
included. Currently there are three models that can be used to provide FV3 as well as the potential
to make forecasts in-core with FV3-JEDI:

- The JCSDA fork of GFDL_atmos_cubed_sphere (https://github.com/JCSDA/GFDL_atmos_cubed_sphere)
- The ufs-weather-model built with CMake (https://github.com/ufs-community/ufs-weather-model)
- GEOSgcm built with CMake (https://github.com/GEOS-ESM/GEOSgcm)

Building with GFDL_atmos_cubed_sphere is the default mode and it provides everything necessary to
run any data assimilation systems that do not involve executing a forecast of the model in-core.
GFDL_atmos_cubed_sphere contains only the FV3 dynamical core and none of the model physics or model
infrastructure.

Whether to build with the standalone dynamical core, UFS or GEOS is controlled with the build option
:code:`-DFV3_FORECAST_MODEL_BUILD`. The standalone dynamical core is the default so is chosen by
either not providing :code:`-DFV3_FORECAST_MODEL_BUILD` or setting to:

.. code::

   -DFV3_FORECAST_MODEL_BUILD=FV3CORE

Building with GEOS is triggered by instead specifying:

.. code::

   -DFV3_FORECAST_MODEL_BUILD=GEOS

When building with GEOS (and UFS) is is also necessary to pass the path where GEOS is installed.
This is controlled by the flag:

.. code::

   -DFV3_FORECAST_MODEL_ROOT==/path/to/model/install

FV3-JEDI will build certain tests when GEOS is used but a directory where GEOS can run from must be
provided and is passed to the build as follows:

.. code::

   -DFV3_FORECAST_MODEL_RUNDIR=/path/to/model/run/directory

Note that users should not provide the path where GEOS can be run from themselves since the
test has been designed with a certain expected result. Consult FV3-JEDI developers for a suitable
path. GEOS typically only runs on Discover and there the test path to be provided is:

.. code::

   -DFV3_FORECAST_MODEL_RUNDIR=/discover/nobackup/drholdaw/JediData/ModelRunDirs/geos-c24

Building with ufs-weather-model is triggred with:

.. code::

   -DFV3_FORECAST_MODEL_BUILD=UFS

When building with UFS it is also necessary to pass :code:`DFV3_FORECAST_MODEL_ROOT` and
:code:`DFV3_FORECAST_MODEL_RUNDIR`. In addition the following flags are required:

.. code::

   -DFV3_FORECAST_MODEL_SRC=/path/to/ufs/source/code
   -DFV3_FORECAST_MODEL_BUILD=/path/to/ufs/build/directory

These two arguments provide additional include paths in order to build with UFS. It is anticipated
that these will not be needed in the long term as the CMake version of UFS matures.

The FV3 dynamical core can be built in either single or double precision, double is the default
behavior. When using GEOS or UFS the choice needs to match the choice that was made when the model
was installed. When building with FV3CORE the choice can be made at the same time as building
FV3-BUNDLE. This choice is controlled with:

.. code::

   -DFV3_PRECISION=SINGLE
   -DFV3_PRECISION=DOUBLE

As with the nonlinear version of FV3 the tangent linear and adjoint versions of FV3 can also be
built in both single or double precision, with double being the default. This is controlled with:

.. code::

   -DFV3LM_PRECISION=SINGLE
   -DFV3LM_PRECISION=DOUBLE


Optional observation operators
------------------------------

There are two optional UFO observation operators that FV3-JEDI can be used with. These are the ROPP
GNSSRO operator from EUMETSAT and the GEOS_AERO AOD operator from NASA. These operators are not
available without signing a license agreement so default to off but can be be built by turning the
option to skip them to :code:`OFF`:

.. code::

   -DBUNDLE_SKIP_GEOS-AERO=OFF
   -DBUNDLE_SKIP_ROPP=OFF


Controlling the testing
-----------------------

FV3-JEDI comes with tiered testing. The level of testing that will be compiled is chosen by setting
the environment variable :code:`FV3JEDI_TEST_TIER`. The value can be set to 1 or 2. All tests
up to including the value in :code:`FV3JEDI_TEST_TIER` will be built. Note that it is not necessary
to manually run ecbuild again after changing the environment variable. It would be sufficient to
touch one of the CMakeLists.txt files in FV3-JEDI, which will trigger cmake automatically.

Most of the tests that run in FV3-JEDI require 6 processors, 1 per face of the cube. Some of the
ensemble or parallel tests use a larger number, in some cases as many as 24. It is possible to skip
these tests on systems that may not be able to support them. This is achieved with:

.. code::

   ecbuild -SKIP_LARGE_TESTS=ON
