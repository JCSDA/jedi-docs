.. _top-ufo-newobsop:

Creating a new Observation Operator in UFO
==========================================

Existing Observation Operators
------------------------------

Before implementing a new observation operator, check if one of the :doc:`observation operators already implemented in UFO <obsops>` is suitable.

Creating files for a new Observation Operator
---------------------------------------------

If the observation operator is not on the list of already implemented observation operators, it may have to be implemented and added to UFO. Typically, all the files for a new observation operator are in a new directory under :code:`ufo/src/ufo`.

New observation operators can be written in C++ or in Fortran.

All the observation operators written in Fortran have to have a C++ interface, because all observation operators have to be accessed by a generic data assimilation layer written in C++ in oops. A directory for an observation operator written in Fortran typically consists of the following files (example from atmvertinterp):

1. :code:`ObsAtmVertInterp.cc`, :code:`ObsAtmVertInterp.h`: C++ files defining the ObsOperator class. The methods (functions) there call Fortran subroutines.
2. :code:`ObsAtmVertInterp.interface.F90`, :code:`ObsAtmVertInterp.interface.h`: C++ and Fortan files defining interfaces between Fortran and C++.
3. :code:`ufo_atmvertinterp_mod.F90` - Fortran module containing the code to run observation operator.

For new observation operators written in Fortran, files from (1-2) can be generated, and the developer would only need to modify the Fortran module (3).

To generate the ObsOperator files, one can run the following script: :code:`ufo/tools/new_obsop/create_obsop_fromexample.sh <ObsOperatorName> <directory>`

:code:`<ObsOperatorName>` is the name of the obs operator in UpperCamelCase format. :code:`<directory>` is a directory name in :code:`ufo/src/ufo`. Examples for existing obsoperators: atmvertinterp, crtm, identity.

Example of calling :code:`create_obsop_fromexample.sh`:

.. code-block:: bash

   $> ./create_obsop_fromexample.sh MyOperator myoperator

After the directory with the new obsoperator is created, add it to :code:`ufo/src/ufo/CMakeLists.txt`:

.. code-block:: cmake

   add_subdirectory( identity )
   add_subdirectory( myoperator )
   list( APPEND ufo_src_files
        ${identity_src_files}
        ${myoperator_src_files}

and try to compile/build the code.

Adding an Observation Operator test
-----------------------------------

After this skeleton code is generated, create a test for your new observation operator. Even if the test fails because of missing data or a mismatch between computed and provided values, the test will still call your operator and any print statements or other calls you perform within the Fortran subroutines will execute.

For observation operator test one needs a sample observation file and a corresponding geovals file.

All observation operator tests in UFO use the OOPS ObsOperator test. To create a new one, add an entry to :code:`ufo/test/CMakeLists.txt` similar to:

.. code-block:: cmake

    ecbuild_add_test( TARGET  test_ufo_opr_myoperator     # test name
                      COMMAND ${CMAKE_BINARY_DIR}/bin/test_ObsOperator.x  # test executable name
                      ARGS    "testinput/myoperator.yaml" # config file
                      ENVIRONMENT OOPS_TRAPFPE=1
                      DEPENDS test_ObsOperator.x
                      TEST_DEPENDS ufo_get_ioda_test_data ufo_get_ufo_test_data )

Other changes required in :code:`ufo/test/CMakeLists.txt`:

Link the :doc:`config file </using/building_and_running/config_content>` you will be using for the test:

.. code-block:: cmake

   list( APPEND ufo_test_input
           testinput/myoperator.yaml

To configure the test, create config file :code:`ufo/test/testinput/myoperator.yaml` and fill appropriately. For examples see :code:`ufo/test/testinput/amsua_crtm.yaml`, :code:`ufo/test/testinput/radiosonde.yaml`.


Adding substance to the new Observation Operator
------------------------------------------------

To implement the Observation Operator, one needs to:

* Specify input variable names (requested from the model) in :code:`ufo_obsoperator_mod.F90`, subroutine :code:`ufo_obsoperator_setup`. The input variable names need to be saved in :code:`self%geovars`. The variables that need to be simulated by the observation operator are already set in :code:`self%obsvars` (these are the variables from :code:`obs space.simulated variables` section of configuration file. See examples in :code:`ufo/src/ufo/atmvertinterp/ufo_atmvertinterp_mod.F90` and :code:`ufo/src/ufo/crtm/ufo_radiancecrtm_mod.F90`. The variables can be hard-coded or controlled from the config file depending on your observation operator.

* Fill in :code:`ufo_obsoperator_simobs` routine. This subroutine is for calculating H(x). Inputs: :code:`geovals` (horizontally interpolated to obs locations model fields for the variables specified in :code:`self%geovars` above), :code:`obss` (observation space, can be used to request observation metadata). Output: :code:`hofx(nvars, nlocs)` (obs vector to hold H(x), :code:`nvars` are equal to the size of :code:`self%obsvars`). Note that the :code:`hofx` vector was allocated before the call to :code:`ufo_obsoperator_simobs`, and only needs to be filled in.

Observation Operator test
-------------------------

All observation operator tests in UFO use the OOPS ObsOperator test from :code:`oops/src/test/interface/ObsOperator.h`.

There are two parts of this test:

:code:`testConstructor`: tests that ObsOperator objects can be created and destroyed


:code:`testSimulateObs`: tests observation operator calculation in the following way:

* Creates observation operator, calls :code:`ufo_obsoperator_setup`
* Reads "GeoVaLs" (vertical profiles of relevant model variables, interpolated to observation lat-lon location) from the geovals file
* Computes H(x) by calling :code:`ufo_obsoperator_simobs`
* Reads reference and compares the result to the reference. Options for specifying reference:

  - if full vector reference H(x) available in the obs file:

    :code:`vector ref` entry in the config specifies variable name for the reference H(x) in the obs file.
    Test passes if the norm(benchmark H(x) - H(x)) < tolerance, with tolerance defined in the config by :code:`tolerance`.

    :code:`norm ref` entry in the config specifies variable name for the reference H(x) in the obs file.
    Test passes if the norm((benchmark H(x) - H(x))/H(x)) < tolerance, with tolerance defined in the config by :code:`tolerance`.

  - otherwise, the expected reference norm(H(x)) can be specified in the :code:`rms ref` entry in the config. Test passes
    if reference norm is close to the norm(H(x)) with tolerance defined in the config by :code:`tolerance`:
