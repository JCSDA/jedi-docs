.. _top-ufo-newobsop:

Creating a new Observation Operator in UFO
==========================================

Existing Observation Operators
------------------------------

Before implementing a new observation operator, check if one of the :doc:`observation operators already implemented in UFO <obsops>` is suitable.

Creating files for a new Observation Operator
---------------------------------------------

If the observation operator is not on the list of already implemented observation operators, it may have to be implemented and added to UFO. Typically, all the files for a new observation operator are in a new directory under :code:`ufo/src/ufo`.

New observation operators can be written in C++ (preferred) or can be a C++ wrapper to an implementation in Fortran or another language. All observation operators must have a C++ interface, because they interface to the generic data assimilation layer written in C++ in oops.

The source directory for an observation operator implemented in Fortran typically consists of the following files (example from VertInterp):

1. :code:`ObsVertInterp.cc`, :code:`ObsVertInterp.h`: C++ files defining the ObsOperator class. The methods (functions) there call Fortran subroutines.
2. :code:`ObsVertInterp.interface.F90`, :code:`ObsVertInterp.interface.h`: C++ and Fortan files defining interfaces between Fortran and C++.
3. :code:`ufo_vertinterp_mod.F90` - Fortran module containing the vertical interpolation code.

Other examples of this C++-to-Fortran interface pattern can be found across UFO. For example, see the Background Error Identity Operator (:code:`ufo/operators/backgrounderroridentity`) for a simple example of setting up the interface, or the Column Retrieval operator (:code:`/ufo/operators/columnretrieval`) for a more complicated example that includes tangent linear and adjoint (TL/AD) implementations.

Adding an Observation Operator test
-----------------------------------

The observation operator must have a test.

All observation operator tests in UFO use the OOPS ObsOperator test. Therefore, a new observation operator test can be added by running this executable without writing additional code. The new test will need a sample observation file (ideally a few tens of observations) and a corresponding geovals file.

It can be helpful to create the test case early in the development process. Even if the test fails because of missing data or a mismatch between computed and provided values, the test will still call your operator and any print statements or other calls you perform will execute.

To declare the new test, add an entry to :code:`ufo/test/testinput/unit_tests/operators/CMakeLists.txt` similar to:

.. code-block:: cmake

    ecbuild_add_test( TARGET  ufo_opr_myoperator     # test name
                      COMMAND ${CMAKE_BINARY_DIR}/bin/test_ObsOperator.x  # test executable name
                      ARGS    "testinput/myoperator.yaml" # config file
                      ENVIRONMENT OOPS_TRAPFPE=1
                      DEPENDS test_ObsOperator.x
                      TEST_DEPENDS ufo_get_ioda_test_data ufo_get_ufo_test_data )

Link the :doc:`config file </using/building_and_running/config_content>` you will be using for the test:

.. code-block:: cmake

   list( APPEND ufo_test_input
         ...
         testinput/myoperator.yaml
         ...

To configure the test, create config file :code:`ufo/test/testinput/unit_tests/operators/myoperator.yaml` and fill appropriately. For examples see :code:`ufo/test/testinput/unit_tests/operators/amsua_crtm.yaml`, :code:`ufo/test/testinput/unit_tests/operators/radiosonde.yaml`.

Observation Operator test
-------------------------

This setup runs the OOPS ObsOperator test from :code:`oops/src/test/interface/ObsOperator.h`.

There are two parts of this test:

:code:`testConstructor`: tests that ObsOperator objects can be created and destroyed

:code:`testSimulateObs`: tests observation operator calculation in the following way:

* Creates observation operator
* Reads "GeoVaLs" (vertical profiles of relevant model variables, interpolated to observation lat-lon locations or along custom paths specified by the observation operator) from the geovals file
* Computes H(x) by calling :code:`simulateObs`
* Reads reference and compares the result to the reference. Options for specifying reference:

  - if full vector reference H(x) available in the obs file:

    :code:`vector ref` entry in the config specifies variable name for the reference H(x) in the obs file.
    Test passes if the norm(benchmark H(x) - H(x)) < tolerance, with tolerance defined in the config by :code:`tolerance`.

    :code:`norm ref` entry in the config specifies variable name for the reference H(x) in the obs file.
    Test passes if the norm((benchmark H(x) - H(x))/H(x)) < tolerance, with tolerance defined in the config by :code:`tolerance`.

  - otherwise, the expected reference norm(H(x)) can be specified in the :code:`rms ref` entry in the config. Test passes
    if reference norm is close to the norm(H(x)) with tolerance defined in the config by :code:`tolerance`:

Operators simulating non-pointwise observations
-----------------------------------------------

Most operators assume that the location of each observation, i.e., the region of space probed by the instrument taking that observation, can be well-approximated by a point or a vertical line. If this is the case, the operator can predict the value of an observation taken at a given latitude and longitude just from the values of relevant model fields interpolated along a vertical line intersecting the point on the Earth's surface with that latitude and longitude. For certain instruments, though, this approximation may not be sufficiently accurate, and JEDI allows operators to receive values of model variables interpolated along any number of paths per observation location. By averaging these model field profiles with appropriate weights, the operator can compute an arbitrarily accurate approximation of an observation taken by an instrument probing a spatially extended region of any shape.

To specify a custom set of model variable interpolation paths, an :code:`ObsOperator` needs to override its :code:`locations()` method, which returns an :code:`oops::Locations` object mapping model variables to sets of paths along which these variables should be interpolated. An example can be found in the :code:`ObsGnssroBndROPP2D` class implementing a 2D GNSS-RO operator. Its :code:`locations()` method asks for all model variables required by this operator to be sampled along a certain number of paths per observation location; this number is user-controlled and specified in the YAML configuration file. In general, the number of interpolation paths can be location- and model-variable-dependent; for instance, it might be chosen differently for rapidly and slowly varying fields. At present, all paths must be vertical, but there are plans to add support for slanted paths in the future.

The interpolation results, i.e., model field profiles, are stored in a :code:`GeoVaLs` object and passed to the :code:`ObsOperator::simulateObs()` method. The (one-to-many) mapping between observation locations and profiles can be retrieved by calling the :code:`GeoVaLs::getProfileIndicesGroupedByLocation()` function (in C++) or by inspecting the :code:`paths_by_loc` component of the appropriate element of the :code:`sampling_method_by_var` array stored in an instance of :code:`ufo_geovals` (in Fortran).

.. tip::
   Interpolation paths can be shared across multiple observation locations. This can be useful if an observation operator wants to simulate multiple (possibly all) observations by weighted averaging of model fields interpolated along paths arranged on, for instance, an equispaced or Gaussian quadrature grid covering an area encompassing the locations of all these observations.

Apart from observation operators, GeoVaLs are also consumed by some observation filters and bias predictors. However, the latter expect the number of model variable profiles stored in a GeoVaL to match the number of observation locations. To allow such filters and bias predictors to be applied to observations handled by operators using model fields interpolated along multiple paths per observation location, the distinction between *sampled* and *reduced* GeoVaLs has been introduced. *Sampled* GeoVaLs are profiles produced by direct interpolation of a model field along an arbitrary set of paths sampling the observation locations, whereas *reduced* GeoVaLs are obtained by reducing each set of profiles associated with a single location to a single profile, typically by weighted averaging. This work is performed by the :code:`ObsOperator::computeReducedVars()` method, which needs to be overridden by observation operators that (a) require some model variables to be interpolated along multiple paths per observation location and (b) must work together with observation filters or bias predictors requiring access to the reduced representation of the GeoVaLs corresponding to these model variables.

A single :code:`ufo::GeoVaLs` object can store GeoVaLs in both the sampled and reduced formats. Clients reading or writing GeoVaLs can specify the format of interest through the :code:`format` parameter of member functions such as :code:`getProfile()` and :code:`putProfile()`. The default value of that parameter is context-dependent: it is set to *sampled* most of the time, in particular when the OOPS framework invokes the :code:`ObsOperator::simulateObs()` method, but it is switched to *reduced* when the framework invokes observation filters or bias predictors.
