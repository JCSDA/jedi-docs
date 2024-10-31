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

   time window:
     begin: 2018-04-14T21:00:00Z
     end: 2018-04-15T03:00:00Z

   observations:
     observers:
     - obs space:
         name: test_relative_humidity1
         obsdatain:
           engine:
             type: H5File
             obsfile: Data/ioda/testinput_tier_1/sfc_obs_2018041500_metars_small.nc
         simulated variables: [specificHumidity, airTemperature, stationPressure]
       obs filters:
       - filter: Variable Transforms
         Transform: ["RelativeHumidity"]
         Method: UKMO


The :code:`Variable Transforms` filter has the following available yaml settings:
 - **Transform**: name of the variable transform that need to be performed.
   (see :ref:`available-variable-transforms`).
 - **Method**: [*Optional* | *default = default*] Method or "recipe" used for the variable transformation.
   Often this refers to a Met Center.
   Any method in the list of all possible variable transform methods can be specified, but in many cases this will result in a default method being used.
   For example, the method :code:`GoffGratchLandoltBornsteinIceWater` can be specified for any variable transform, but will cause a default method to be used in all cases but the relative and specific humidity variable transforms.
   See individual :ref:`available-variable-transforms` for default methods, possible choices and definitions.
 - **UseValidDataOnly**: [*Optional* | *default = true*]
   If *true*, the variable transform is only applied to valid data.
 - **FillMissingDerivedFromOriginal** [*Optional* | *default = false*]
   If *true*, fill any missing entries of a vector in a Derived group (e.g. DerivedObsValue) with
   the non-missing entries of the vector in the equivalent original group (e.g. ObsValue).
 - **SkipWhenNoObs** [*Optional* | *default = true*]
   If *true*, the variable transform will not be performed on a core if there are no observations on that core. If creating a new
   variable it might be pertinent to set to false as the code may fail when saving that variable.

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

**Adjusted height**

.. toctree::
   :maxdepth: 1

   transforms/adjustedheight

**Height from pressure**

.. toctree::
   :maxdepth: 1

   transforms/heightfrompressure

**Humidity**

.. toctree::
   :maxdepth: 2

   transforms/humidity

**Logarithm**

.. toctree::
   :maxdepth: 1

   transforms/logarithm

**Ocean Conversions**

.. toctree::
   :maxdepth: 1

   transforms/oceanconversions

**PotentialTemperature**

.. toctree::
   :maxdepth: 2

   transforms/potentialtemperature

**Pressure from height**

.. toctree::
   :maxdepth: 2

   transforms/pressure

**Profile horizontal drift**

.. toctree::
   :maxdepth: 1

   transforms/profilehorizontaldrift

**Radar beam geometry**

.. toctree::
   :maxdepth: 1

   transforms/radarbeamgeom

**Remap scan position**

.. toctree::
   :maxdepth: 1

   transforms/remapscanposition

**Satellite brightness temperature from radiance**

.. toctree::
   :maxdepth: 1

   transforms/btfromrad

**Satellite radiance from scaled radiance**

.. toctree::
   :maxdepth: 1

   transforms/radfromscaledrad

**Satellite zenith angle correction**

.. toctree::
   :maxdepth: 1

   transforms/satzencorrection

**Surface pressure**

.. toctree::
   :maxdepth: 2

   transforms/surfacepressure

**Surface wind scaling for height coordinate**

.. toctree::
   :maxdepth: 1

   transforms/surfacewindscalingheight

**Surface wind scaling for pressure coordinate**

.. toctree::
   :maxdepth: 1

   transforms/surfacewindscalingpressure

**Surface wind scaling for combined height-pressure coordinate**

.. toctree::
   :maxdepth: 1

   transforms/surfacewindscalingcombined

**Wind**

.. toctree::
   :maxdepth: 2

   transforms/wind


Symbols
=======

Table listing all the symbols used

.. toctree::
   :maxdepth: 2

   symbol
