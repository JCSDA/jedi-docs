.. _top-ufo-newobsop:

Creating new Observation Operator in UFO
========================================

Existing Observation Operators
------------------------------

Before implementing a new observation operator, check if one of the observation operators already implemented in UFO is suitable:

1. Interface to CRTM for radiances and aerosol optical depth (:code:`ufo/src/ufo/crtm/` , "CRTM" for radiances, "AOD" for aod in the config files)
2. Linear vertical interpolation in log pressure for the variables specified in the config file (:code:`ufo/src/ufo/atmvertinterp`, "Radiosonde", "Aircraft", "Satwind", more names could be added to :code:`ObsAtmVertInterp.cc`).
3. Identity observation operator for 2D fields (takes the result of the horizontal interpolation from the geovals and returns it as H(x)) (:code:`ufo/src/ufo/identity`, "Surface", more names could be added to :code:`ObsIdentity.cc`)
4. Several GNSSRO observation operators.

Creating files for a new Observation Operator
---------------------------------------------

If your observation operator is different from the above, you may need to create a new observation operator. Typically, all the files for a new observation operator are in a new directory under :code:`ufo/src/ufo`.

The new observation operator has to have a C++ interface, because all observation operators have to be accessed by a generic data assimilation layer written in C++ in oops. Most of the observation operators, however, are written in Fortran. The directory for the observation operator consists of the following files (example from atmvertinterp):

1. :code:`ObsAtmVertInterp.cc`, :code:`ObsAtmVertInterp.h`: C++ files defining the ObsOperator class. The methods (functions) there call Fortran subroutines.
2. :code:`ObsAtmVertInterp.interface.F90`, :code:`ObsAtmVertInterp.interface.h`: C++ and Fortan files defining interfaces between Fortran and C++.
3. :code:`ufo_atmvertinterp_mod.F90` - Fortran module containing the code to run observation operator.

Most of the time you’d only need to modify the Fortran module (3), and the files from (1-2) can be generated automatically.

To generate the ObsOperator files, you can run the following script: :code:`ufo/tools/new_obsop/create_obsop_fromexample.sh <ObsOperatorName> <directory>`

:code:`<ObsOperatorName>` is an UpperCamelCase name you’d like your obs operator to go by. :code:`<directory>` is a directory name in :code:`ufo/src/ufo`. Examples for existing obsoperators: atmvertinterp, crtm, identity.

Example of calling :code:`create_obsop_fromexample.sh`:

.. code:: bash

   $> ./create_obsop_fromexample.sh MyOperator myoperator

After the directory with the new obsoperator is created, add it to :code:`ufo/src/ufo/CMakeLists.txt`:

.. code:: bash

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

Observation file should be added to ioda repository in :code:`ioda/test/testinput/atmosphere/`. Corresponding geovals file should be added to ufo repository in :code:`ufo/test/testinput/atmosphere/`.

All observation operator tests in UFO use the OOPS ObsOperator test. To create a new one, add an entry to :code:`ufo/test/CMakeLists.txt` similar to:

.. code:: bash

   ecbuild_add_test( TARGET  test_ufo_myoperator_opr          # test name
                     SOURCES mains/TestObsOperator.cc         # source file
                     ARGS    "testinput/myoperator.yaml"      # config file
                     LIBS    ufo )

Other changes required in :code:`ufo/test/CMakeLists.txt`:

Link the :doc:`config file <../../developer/building_and_testing/config_content>` you will be using for the test:

.. code:: bash

   list( APPEND ufo_test_input
           testinput/myoperator.yaml

Link the observations and geovals files you will be using for the test:

.. code:: bash

   list( APPEND ufo_test_data
           atmosphere/geoval_file_name.nc4

.. code:: bash

   list (APPEND ioda_obs_test_data
           atmosphere/obs_file_name.nc4

To configure the test, create config file :code:`ufo/test/testinput/myoperator.yaml` and fill appropriately. For examples see :code:`ufo/test/testinput/amsua_crtm.yaml`, :code:`ufo/test/testinput/radiosonde.yaml`.


Adding substance to the new Observation Operator
------------------------------------------------

To implement the Observation Operator, one needs to:

* Specify input variable names (requested from the model) and output variable names (simulated by the observation operator) in :code:`ufo_obsoperator_mod.F90`, subroutine :code:`ufo_obsoperator_setup`. The input variable names need to be saved in :code:`self%varin` (set :code:`self%nvars_in` and allocate accordingly), the output variables in :code:`self%varout` (set :code:`self%nvars_out` and allocate accordingly). See examples in :code:`ufo/src/ufo/atmvertinterp/ufo_atmvertinterp_mod.F90` and :code:`ufo/src/ufo/crtm/ufo_radiancecrtm_mod.F90`. The variables can be hard-coded or controlled from the config file depending on your observation operator.

* Fill in :code:`ufo_obsoperator_simobs` routine. This subroutine is for calculating H(x). Inputs: :code:`geovals` (horizontally interpolated to obs locations model fields for the variables specified in :code:`self%varin` above), :code:`obss` (observation space, can be used to request observation metadata). Output: :code:`hofx` (obs vector to hold H(x)). Note that the vector was allocated before the call to :code:`ufo_obsoperator_simobs`, and only needs to be filled in.

Observation Operator test
-------------------------

All observation operator tests in UFO use the OOPS ObsOperator test from :code:`oops/src/test/interface/ObsOperator.h`.

There are two parts of this test:

1. testConstructor: tests that ObsOperator objects can be created and destroyed

2. testSimulateObs: tests observation operator calculation in the following way:

  * Creates observation operator, calls :code:`ufo_obsoperator_setup`
  * Reads "GeoVaLs" (vertical profiles of relevant model variables, interpolated to observation lat-lon location) from the geovals file
  * Computes H(x) by calling :code:`ufo_obsoperator_simobs`
  * Reads benchmark H(x) from the obs file (netcdf variable name defined by :code:`vecequiv` entry in the config) and compares it to H(x) computed above
  * Test passes if the norm(benchmark H(x) - H(x)) < tolerance, with tolerance defined in the config by :code:`tolerance`.


