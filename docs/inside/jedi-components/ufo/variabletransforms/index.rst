===================  
Variable transforms
===================  

Introduction
============

This section describes the various variable transforms (or conversions)
available within UFO.

All variable transforms are performed using a unique filter 
(:ref:`Observation-Filters`) called :code:`Variable Transforms`, as shown in 
the example below:

.. code-block:: yaml

   window begin: 2018-04-14T21:00:00Z
   window end: 2018-04-15T03:00:00Z

   observations:
   - obs space:
      name: test_relative_humidity1
      obsdatain:
         obsfile: Data/ioda/testinput_tier_1/sfc_obs_2018041500_metars_small.nc
      simulated variables: [specific_humidity, air_temperature, surface_pressure]
   obs filters:
   - filter: Variable Transforms
      Transform: ["RelativeHumidity"] 
      Method: UKMO            
      Formulation: Sonntag

   
The :code:`Variable Transforms` filter has the following available yaml settings:
 - **Transform**: name of the variable transform that need to be performed. 
   (see :ref:`available-variable-transforms`).
 - **Method**: [*Optional*] Method used during the variable transformation. 
   This usually refers to the different Met Center. 
   (See individual :ref:`available-variable-transforms` for possible choices and definitions)  
 - **Formulation**: [*Optional*] Name of a specific formulation used during 
   the variable transformation. 
   (See individual :ref:`available-variable-transforms` for possible choices and definitions)
 - **UseValidDataOnly**: [*Optional* | *default = true*] 
   Should the variable transform be applied only to valid data? 
 - **FillMissingDerivedFromOriginal** [*Optional* | *default = false*]
   If *true*, fill any missing entries of a vector in a Derived group (e.g. DerivedObsValue) with
   the non-missing entries of the vector in the equivalent original group (e.g. ObsValue).
   
   .. warning:: If :code:`UseValidDataOnly=true`, the variable transform is 
      **not** applied to observations that have a :code:`QCflag` equal to either
      :code:`missing` or  :code:`bounds`.

The new variable derived by the filter is then stored in the observation space within the
:code:`DerivedObsValue` group. Since variables in groups with the :code:`Derived` prefix
"overshadow" variables from corresponding groups without that prefix (see
:ref:`Derived-Variables`), these variables can normally be accessed as if they were in the
:code:`ObsValue` group.

.. warning:: Each variable transform requires a specific set of variables
   (as specified in the documentation). If any compulsory variable is missing, the code will raise
   an exception and stop.

.. _available-variable-transforms:

Variable transforms
===================

The variable transforms available are:

**Humidity**

.. toctree::
   :maxdepth: 2

   transforms/humidity


**Pressure from height**

.. toctree::
   :maxdepth: 2

   transforms/pressure

**Height from pressure**

.. toctree::
   :maxdepth: 1

   transforms/heightfrompressure

**Wind**

.. toctree::
   :maxdepth: 2

   transforms/wind

**PotentialTemperature**

.. toctree::
   :maxdepth: 2

   transforms/potentialtemperature

**Profile horizontal drift**

.. toctree::
   :maxdepth: 1

   transforms/profilehorizontaldrift

**PStar**

.. toctree::
   :maxdepth: 2

   transforms/surfacepressure


Formulations
============

The formulations available are:

.. toctree::
   :maxdepth: 2

   formulations/formula_part1 

**Table listing all the symbols used**

.. toctree::
   :maxdepth: 2

   symbol
