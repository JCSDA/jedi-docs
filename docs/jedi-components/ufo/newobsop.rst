.. _top-ufo-newobsop:

Creating new Observation Operator in UFO
========================================

Existing Observation Operators
------------------------------

Before implementing a new observation operator, check if one of the observation operators already implemented in UFO is suitable:

1. Interface to CRTM for radiances and aerosol optical depth (:code:`ufo/src/ufo/crtm/` , “CRTM” for radiances, “AOD” for aod in the config files)
2. Linear vertical interpolation in log pressure for the variables specified in the config file (:code:`ufo/src/ufo/atmvertinterp`, “Radiosonde”, “Aircraft”, “Satwind”, more names could be added to :code:`ObsAtmVertInterp.cc`). 
3. Identity observation operator for 2D fields (takes the result of the horizontal interpolation from the geovals and returns it as H(x)) (:code:`ufo/src/ufo/identity`, “Surface”, more names could be added to :code:`ObsIdentity.cc`)
4. Several GNSSRO observation operators.

Creating files for a new Observation Operator
---------------------------------------------

If your observation operator is different from the above, you may need to create a new observation operator. Typically, all the files for a new observation operator are in a new directory under :code:`ufo/src/ufo`.

The new observation operator has to have a C++ interface, because all observation operators have to be accessed by a generic data assimilation layer written in C++ in oops. Most of the observation operators, however, are written in Fortran. The directory for the observation operator consists of the following files (example from atmvertinterp):

1. :code:`ObsAtmVertInterp.cc`, :code:`ObsAtmVertInterp.h`: C++ files defining the ObsOperator class. The methods (functions) there call Fortran subroutines.
2. :code:`ObsAtmVertInterp.interface.F90`, :code:`ObsAtmVertInterp.interface.h`: C++ and Fortan files defining interfaces between Fortran and C++.
3. :code:`ufo_atmvertinterp_mod.F90` - Fortran module containing the code to run observation operator.

Most of the time you’d only need to modify the Fortran module (3), and the files from (1-2) can be generated automatically.

To generate the ObsOperator files, you can run the following script: :code:`ufo/tools/new_obsop/create_obsop_fromexample.sh ObsOperatorName path/to/obsoperator`

:code:`ObsOperatorName` is an UpperCamelCase name you’d like your obs operator to go by. :code:`path/to/obsoperator` is relative to :code:`ufo/src/ufo`. Examples for existing obsoperators: atmvertinterp, crtm, identity.

Example of calling :code:`create_obsop_fromexample.sh`:

.. code:: bash

   $> ./create_obsop_fromexample.sh MyOperator myoperator

After the directory with the new obsoperator is created, add it to :code:`ufo/src/ufo/CMakeLists.txt`:

.. code:: bash

   add_subdirectory( identity )
   add_subdirectory( <path/to/obsoperator> )
   list( APPEND ufo_src_files
        ${identity_src_files}
        ${obsoperator_src_files}

and try to compile/build the code.

Adding an Observation Operator test
-----------------------------------

After this skeleton code is generated, you may wish to create a test for your new observation operator. Even if the test fails because of missing data or a mismatch between computed and provided values, the test will still call your operator and any print statements or other calls you perform within the Fortran subroutines will execute. Please see <wherever these instructions are, or rewrite them here?> for details on how to create a UFO test for your new type of observation operator.

Adding substance to the new Observation Operator
------------------------------------------------

To implement the Observation Operator, one needs to:

* Specify input variable names (requested from the model) and output variable names (simulated by the observation operator) in :code:`ufo_obsoperator_mod.F90`, subroutine :code:`ufo_obsoperator_setup`. The input variable names need to be saved in :code:`self%varin` (set :code:`self%nvars_in` and allocate accordingly), the output variables in :code:`self%varout` (set :code:`self%nvars_out` and allocate accordingly). See examples in :code:`ufo/src/ufo/atmvertinterp/ufo_atmvertinterp_mod.F90` and :code:`ufo/src/ufo/crtm/ufo_radiancecrtm_mod.F90`. The variables can be hardcoded or controlled from the config file depending on your observation operator.

* Fill in :code:`ufo_obsoperator_simobs` routine. This subroutine is for calculating H(x). Inputs: :code:`geovals` (horizontally interpolated to obs locations model fields for the variables specified in :code:`self%varin` above), :code:`obss` (observation space, can be used to request observation metadata). Output: :code:`hofx` (obs vector to hold H(x)). Note that the vector was allocated before the call to :code:`ufo_obsoperator_simobs`, and only needs to be filled in. 

