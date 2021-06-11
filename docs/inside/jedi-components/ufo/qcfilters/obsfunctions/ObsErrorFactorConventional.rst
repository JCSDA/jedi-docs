.. _ObsErrorFactorConventional:

ObsErrorFactorConventional
---------------------------------------------------------------------------------------------------------------------------------

This obsFunction is designed to mimic the NCEP GDAS observer code (i.e., subroutine errormod in
qcmod.f90) to computate the observation error inflation factor based on vertical spacing (in pressure). 
If there are multiple observations within one model pressure interval, the observation error factors will be computed
based on vertical intervals above and below each observation.
This error inflation obsFunction is used in NCEP GDAS for temperature, moisture, and winds from
conventional obs as well as some satellite retrievals.

Required input parameter:
~~~~~~~~~~~~~~~~~~~~~~~~~

inflate variables
  Variable names to be inflated. It can include multiple variables if this obsFunction is used independently.
  If this obsFunction is used as part of a QC filter, it can only include one variable for each use.

Optional input parameters:
~~~~~~~~~~~~~~~~~~~~~~~~~~

test QCflag
  Currently, the only possible input is :code:`PreQC`, which is provided inside the JEDI_GDAS observation files.
  If not defined, the obsFunction will use QCflagsData from prior filters.

test QCthreshold
  This parameter is only used for :code:`test QCflag: PreQC`. Default is 3.
  The observations with PreQC flags <=3 will be used for this ObsFunction.  

Example configurations:
~~~~~~~~~~~~~~~~~~~~~~~

Here is an example to use this obsFunction to inflate observation errors of specific humidity:

.. code-block:: yaml

  - filter: BlackList
    filter variables:
    - name: specific_humidity
    action:
      name: inflate error
      inflation variable:
        name: ObsErrorFactorConventional@ObsFunction
        options:
          test QCflag: PreQC
          inflate variables: [specific_humidity]

Note: 
If using this obs function in a filter (as shown in the example), please make sure :code:`name` of :code:`filter variables` and 
:code:`inflate variables` have the same variable name. 
Due to the current constraint with obsFunctions, only one variable can be used
for each filter using this obsFuction.  
If using this obsFunction independely from any filters, for example, running test_ObsFunction.x to test this obsFunction, :code:`inflate variables` can include multiple variables. 

Note: This obs function requires each of the obs profiles are sorted by pressure
in descending order (from bottom to top levels). The following shows an 
example configuration for grouping observations based on :code:`station_id` and :code:`datetime` and sort the data
accordingly in descending :code:`air_pressure` order.

.. code-block:: yaml

  - obs operator:
      name: VertInterp
    obs space:
      name: test
      obsdatain:
        obsfile: testdata
       obsgrouping:
         group variables: ["station_id", "datetime"] # Choose parameteres to identify each of
                                                     # the obs profiles
         sort variable: "air_pressure"
         sort order: "descending"
