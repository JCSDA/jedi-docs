Additional QC Filter Options
============================


.. _where-statement:

Where Statement
---------------

By default, filters are applied to all observations of the variables specified in the :code:`filter variables` list (or if this list is not present, all simulated variables). The :code:`where` keyword can be used to apply a filter only to observations meeting certain conditions.

Consider the following set of observations:

.. list-table::
    :header-rows: 1

    * - Obs. index
        - latitude
        - longitude
        - airTemperature (K)
    * - 0
        - 0
        - 50
        - 300
    * - 1
        - 20
        - 60
        - 200
    * - 2
        - 40
        - 70
        - 290
    * - 3
        - 60
        - 80
        - 260
    * - 4
        - 80
        - 90
        - 220

and suppose that we want to reject air temperature observations below 230 K taken in the tropical zone (between 30°S and 30°N). We could do this using the Bounds Check filter with a :code:`where` statement:

.. code-block:: yaml
    
    - filter: Bounds Check
      filter variables: airTemperature
      minvalue: 230
      action:
        name: reject # this is the default action, specified explicitly for clarity
      where:
      - variable:
          name: MetaData/latitude
        minvalue: -30
        maxvalue:  30
    
This would cause the filter to be applied only to air temperature observations `selected` by the :code:`where` statement, i.e. meeting the specified condition :code:`-30 <= MetaData/latitude <= 30`. Please note this does not mean all these observations would be rejected; rather, it means the Bounds Check filter would inspect only these observations and apply its usual criteria (in this case, "is the air temperature below the minimum allowed value of 230 K?") to decide whether any of them should be rejected. In our example, only observation 1 would be rejected, since this is the only observation (a) taken in the range of latitudes selected by the :code:`where` statement and (b) with a value lying below the minimum value passed to the Bounds Check filter.

The list passed to the :code:`where` keyword can contain more than one item, each representing a separate condition imposed on a particular variable. The filter is applied only to observations meeting all of these conditions. The following kinds of conditions are accepted:

- :code:`minvalue` and/or :code:`maxvalue`: filter applied only to observations for which the condition variable lies in the specified range. The upper and lower bounds can be floating-point numbers or datetimes in the ISO 8601 format. If any date/time components are set to `*`, they are disregarded. See :ref:`Example 2 <where-example-2>` below on where this can be useful.  Each of these strings must be 20 characters long so defining 'any year' would be indicated by `****`.
- :code:`value: is_valid`: filter applied only to observations for which the condition variable has a valid value (not a missing data indicator).
- :code:`value: is_not_valid`: filter applied only to observations for which the condition variable is set to a missing data indicator.
- :code:`is_in`: filter applied only to observations for which the condition variable is set to a value belonging to the given whitelist.
- :code:`is_close_to_any_of`: filter applied only to observations for which the condition variable (a float) is close to any of the variables in the given reference list.  Two variables are defined as close if they differ by less than a provided tolerance.  The tolerance must be provided and can either be absolute (:code:`absolute_tolerance`) or relative (:code:`relative_tolerance`).
- :code:`is_not_in`: filter applied only to observations for which the condition variable is set to a value not belonging to the given blacklist.
- :code:`is_not_close_to_any_of`: filter applied only to observations for which the condition variable (a float) is not close to any of the variables in the given reference list.  Two variables are defined as close if they differ by less than a provided tolerance.  The tolerance must be provided and can either be absolute (:code:`absolute_tolerance`) or relative (:code:`relative_tolerance`).
- :code:`value: is_true`: filter applied only to observations for which the condition variable (normally a diagnostic flag) is set to :code:`true`.
- :code:`value: is_false`: filter applied only to observations for which the condition variable (normally a diagnostic flag) is set to :code:`false`.
- :code:`any_bit_set_of`: filter applied only to observations for which the condition variable is an integer with at least one of the bits with specified indices set.
- :code:`any_bit_unset_of`: filter applied only to observations for which the condition variable is an integer with at least one of the bits with specified indices unset (i.e. zero).
- :code:`matches_regex`: filter applied only to observations for which the condition variable is a string that matches the specified regular expression or an integer whose decimal representation matches that expression. The regular expression should conform to the ECMAScript syntax described at http://www.cplusplus.com/reference/regex/ECMAScript.
- :code:`matches_wildcard`: filter applied only to observations for which the condition variable is a string that matches the specified wildcard pattern or an integer whose decimal representation matches that pattern. The following wildcards are recognized: :code:`*` (matching any number of characters, including zero) and :code:`?` (matching any single character).
- :code:`matches_any_wildcard`: filter applied only to observations for which the condition variable is a string that matches at least one of the specified wildcard patterns, or an integer whose decimal representation matches at least one of these patterns. The same wildcards are recognized as for :code:`matches_wildcard`.

The elements of both whitelists and blacklists can be strings, non-negative integers or ranges of non-negative integers. Bits are numbered from zero starting from the least significant bit.

By default, if multiple conditions are used in a :code:`where` statement then the logical :code:`and` of the results is used to determine which locations are selected by the statement. The logical operator used to combine the results can be chosen explicitly with the :code:`where operator` parameter; the permitted operators are :code:`and` and :code:`or`. The use of the :code:`or` operator is illustrated in :ref:`Example 11 <where-example-11>`. Note that it is possible to use the :code:`where operator` option without the :code:`where` statement. The option has no impact in that case.

The following examples illustrate the use of these conditions.

Example 1
^^^^^^^^^

.. code-block:: yaml
    
    where:
    - variable:
        name: GeoVaLs/sea_surface_temperature
      minvalue: 200
      maxvalue: 300
    - variable:
        name: MetaData/latitude
      maxvalue: 60.
    - variable:
        name: MetaData/height
      value: is_valid
    - variable:
        name: MetaData/stationIdentification
      is_in: 3, 6, 11-120
    
In this example, the filter will be applied only to observations for which all of the following four criteria are met:

- the sea surface temperature is within the range of [200, 300] K,
- the latitude is <= than 60°N,
- the observation location's altitude has a valid value (is not set to a missing data indicator), and
- the station id is one of the ids in the whitelist.

.. _where-example-2:

Example 2
^^^^^^^^^

.. code-block:: yaml
    
    where:
    - variable:
        name: MetaData/datetime
      minvalue: "****-01-01T00:00:00Z"
      maxvalue: "****-25-05T00:00:00Z"
    - variable:
        name: MetaData/datetime
      minvalue: "****-**-**T09:00:00Z"
      maxvalue: "****-**-**T18:00:00Z"
    
In this example, the filter will be applied only to observations taken between 09:00:00 and 18:00:00, between 1st January and 25th May of every year (end inclusive).  Note that datetime components are not yet 'loop aware'.  That is, a where clause between May and February for example would require two filters: one covering the Jan-Feb period and a second to cover the May-Dec period.

Example 3
^^^^^^^^^

.. code-block:: yaml
    
    where:
    - variable:
        name: PreQC/chlorophyllMassConcentration
      any_bit_set_of: 0, 1
    
In this example, the filter will be applied only to observations for which the :code:`PreQC/chlorophyllMassConcentration` variable is an integer whose binary representation has a 1 at position 0 and/or position 1. (Position 0 denotes the least significant bit -- in other words, bits are numbered "from right to left".)
    
Example 4
^^^^^^^^^

.. code-block:: yaml
    
    where:
    - variable:
        name: PreQC/chlorophyllMassConcentration
      any_bit_set_of: 4
    - variable:
        name: PreQC/chlorophyllMassConcentration
      any_bit_unset_of: 10-12
    
In this example, the filter will be applied only to observations for which the :code:`PreQC/chlorophyllMassConcentration` variable is an integer whose binary representation has a 1 at position 4 and a 0 at any of positions 10 to 12.
    
Example 5
^^^^^^^^^

.. code-block:: yaml
    
    where:
    - variable:
        name: MetaData/stationIdentification
      matches_regex: 'EUR[A-Z]*'
    
In this example, the filter will be applied only to observations taken by stations whose IDs match the regular expression :code:`EUR[A-Z]*`, i.e. consist of the string :code:`EUR` followed by any number of capital letters.
    
Example 6
^^^^^^^^^

.. code-block:: yaml
    
    where:
    - variable:
        name: MetaData/stationIdentification
      matches_wildcard: 'EUR??TEST*'
    
In this example, the filter will be applied only to observations taken by stations whose IDs match the wildcard pattern :code:`EUR??TEST*`, i.e. consist of the string :code:`EUR` followed by two arbitrary characters, the string :code:`TEST` and any number of arbitrary characters.
    
Example 7
^^^^^^^^^

.. code-block:: yaml
    
    where:
    - variable:
        name: MetaData/observationTypeNum
      matches_any_wildcard: ['102*', '103*']
    
In this example, assuming that :code:`MetaData/observationTypeNum` is an integer variable, the filter will be applied only to observations whose types have decimal representations starting with :code:`102` or :code:`103`.

Example 8
^^^^^^^^^

.. code-block:: yaml
    
    where:
    - variable:
        name: GeoVaLs/model_elevation
      is_close_to_any_of: [0.0, 1.0]
      absolute_tolerance: 1.0e-12
    
In this example, assuming that :code:`GeoVaLs/model_elevation` is a float variable, the filter will be applied only to observations whose :code:`model_elevation` is within :code:`1.0e-12` of either :code:`0.0` or :code:`1.0`.

Example 9
^^^^^^^^^

.. code-block:: yaml
    
    where:
    - variable:
        name: GeoVaLs/model_elevation
      is_not_close_to_any_of: [100.0, 200.0]
      relative_tolerance: 0.1
    
In this example, assuming that :code:`GeoVaLs/model_elevation` is a float variable, the filter will be applied only to observations whose :code:`model_elevation` is not within 10 % of either :code:`100.0` or :code:`200.0`.

Example 10
^^^^^^^^^^

.. code-block:: yaml

    where:
    - variable:
        name: DiagnosticFlags/ExtremeValue/airTemperature
      value: is_true
    - variable:
        name: DiagnosticFlags/ExtremeValue/relativeHumidity
      value: is_false

In this example, the filter will be applied only to observations with the :code:`ExtremeValue` diagnostic flag set for the air temperature, but not for the relative humidity.

.. _where-example-11:

Example 11
^^^^^^^^^^

.. code-block:: yaml

    where:
    - variable:
        name: MetaData/latitude
      minvalue: 60.
    - variable:
        name: MetaData/latitude
      maxvalue: -60.
    where operator: or

In this example, the filter will be applied only to observations for which either of the following criteria are met:

- the latitude is further north than 60°N,
- the latitude is further south than 60°S.


.. _obs-function-and-obs-diagnostic-suffixes:

ObsFunction and ObsDiagnostic Suffixes
--------------------------------------

In addition to, e.g., :code:`GeoVaLs/`, :code:`MetaData/`, :code:`ObsValue/`, :code:`HofX/`, there are two new suffixes that can be used.

- :code:`ObsFunction/` indicates that a particular variable should be a registered :code:`ObsFunction` (:code:`ObsFunction` classes are defined in the :code:`ufo/src/ufo/filters/obsfunctions` folder).  One example of an :code:`ObsFunction` is :code:`ObsFunction/Velocity`, which uses the 2 wind components to produce wind speed and can be used as follows:

.. code-block:: yaml

    - filter: Domain Check
      filter variables:
      - name: windEastward
      - name: windNorthward
      where:
      - variable: ObsFunction/Velocity
        maxvalue: 20.0

Warning: ObsFunctions are evaluated for all observations, including those that have been unselected by previous elements of the :code:`where` list or rejected by filters run earlier. This can lead to problems if these ObsFunctions incorrectly assume they will always be given valid inputs.

- :code:`ObsDiagnostic/` will be used to store non-H(x) diagnostic values from the :code:`simulateObs` function in individual :code:`ObsOperator` classes.  The :code:`ObsDiagnostics` interface class in OOPS is used to pass those diagnostics to the :code:`ObsFilters`.  Because the diagnostics are provided by :code:`simulateObs`, they can only be used in filters that implement the :code:`postFilter` function (currently only Background Check and Met Office Buddy Check).  The :code:`simulateObs` interface to :code:`ObsDiagnostics` will be first demonstrated in CRTM.
- In order to set up :code:`ObsDiagnostics` for use in a filter, the following changes need to be made:

  - In the constructor of the filter, ensure that the diagnostic is added to the :code:`allvars_` variable.  For instance: :code:`allvars_ += Variable("ObsDiag/refractivity");`.  This step informs the code to set up the object, ready for use in the operator.
  - In the observation operator, make sure that the :code:`ObsDiagnostics` object is received, check that this contains the variables that you are expecting to save, and save the variables.  An example of this (in Fortran) is in `Met Office GNSS-RO operator <https://github.com/JCSDA-internal/ufo/blob/develop/src/ufo/gnssro/BendMetOffice/ufo_gnssro_bendmetoffice_mod.F90#L95>`_
  - Use the variable in the filter via the :code:`data_.get()` routine.  For instance add::
  
      Variable refractivityVariable = Variable("ObsDiag/refractivity");
      data_.get(refractivityVariable, iLevel, inputData);

    in the main filter body


.. _filter-actions:


Filter Actions
--------------
The action taken on observations flagged by the filter can be adjusted using the :code:`action` option recognized by each filter.  The following actions are available:

* :code:`reject`: observations flagged by the filter are marked as rejected.
* :code:`accept`: observations flagged by the filter are marked as accepted if they have previously been rejected for any reason other than missing observation value, a pre-processing flag indicating rejection, or failure of the observation operator.
* :code:`passivate`: observations flagged by the filter are marked as passive.
* :code:`inflate error`: the error estimates of observations flagged by the filter are multiplied by a factor. This can be either a constant (specified using the :code:`inflation factor` option) or a variable (specified using the :code:`inflation variable` option).
* :code:`assign error`: the error estimates of observations flagged by the filter are set to a specified value. Again, this can be either a constant (specified using the :code:`error parameter` option) or a variable (specified using the :code:`error function` option).
* :code:`set` and :code:`unset`: the diagnostic flag indicated by the :code:`flag` option will be set to :code:`true` or :code:`false`, respectively, at observations flagged by the filter. These actions recognize a further optional keyword :code:`ignore`, which can be set to:

  - :code:`rejected observations` if the diagnostic flag should not be changed at observations that have previously been rejected or
  - :code:`defective observations` if the diagnostic flag should not be changed at observations that have previously been rejected because of a missing observation value, a pre-processing flag indicating rejection, or failure of the observation operator.

* :code:`set flag bit`: the bit of the bitmap diagnostic flag indicated by the :code:`bit` option will be set at observations flagged by filter.
* :code:`flag original and average profiles`: rejects any observations in the original profiles that have been flagged by the filter, and also rejects all observations in any averaged profile whose corresponding original profile contains at least one flagged observation. See the example below for further details.

To perform multiple actions, replace the :code:`action` option, which takes a single action, by :code:`actions`, which takes a list of actions. This list may contain at most one action altering quality control flags, namely :code:`reject`, :code:`accept` and :code:`passivate`; if present, such an action must be the last in the list. The :code:`action` and :code:`actions` options are mutually exclusive.

The default action for almost all filters (taken when both the :code:`action` and :code:`actions` keywords are omitted) is :code:`reject`. There are two exceptions: the default action of the :code:`AcceptList` filter is :code:`accept` and the :code:`Perform Action` filter has no default action (either the :code:`action` or :code:`actions` keyword must be present).

Example 1 - rejection, error inflation and assignment
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: yaml
    
    - filter: Background Check
      filter variables:
      - name: airTemperature
      threshold: 2.0
      absolute threshold: 1.0
      action:
        name: reject
    - filter: Background Check
      filter variables:
      - name: windEastward
      - name: windNorthward
      threshold: 2.0
      where:
      - variable: MetaData/latitude
        minvalue: -60.0
        maxvalue: 60.0
      action:
        name: inflate error
        inflation: 2.0
    - filter: BlackList
      filter variables:
      - name: brightnessTemperature
      channels: *all_channels
      action:
        name: assign error
        error function:
          name: ObsFunction/ObsErrorModelRamp
          channels: *all_channels
          options:
            channels: *all_channels
            xvar:
              name: ObsFunction/CLWRetSymmetricMW
              options:
                clwret_ch238: 1
                clwret_ch314: 2
                clwret_types: [ObsValue, HofX]
            x0:    [ 0.050,  0.030,  0.030,  0.020,  0.000,
                    0.100,  0.000,  0.000,  0.000,  0.000,
                    0.000,  0.000,  0.000,  0.000,  0.030]
            x1:    [ 0.600,  0.450,  0.400,  0.450,  1.000,
                    1.500,  0.000,  0.000,  0.000,  0.000,
                    0.000,  0.000,  0.000,  0.000,  0.200]
            err0:  [ 2.500,  2.200,  2.000,  0.550,  0.300,
                    0.230,  0.230,  0.250,  0.250,  0.350,
                    0.400,  0.550,  0.800,  3.000,  3.500]
            err1:  [20.000, 18.000, 12.000,  3.000,  0.500,
                    0.300,  0.230,  0.250,  0.250,  0.350,
                    0.400,  0.550,  0.800,  3.000, 18.000]


Example 2 - error assignment using :code:`ObsFunction/DrawObsErrorFromFile`
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Next we demonstrate deriving the observation error from a NetCDF file which defines the variance/covariance:

.. code-block:: yaml

    - filter: Perform Action
      filter variables:
      - name: airTemperature
      action:
        name: assign error
        error function:
          name: ObsFunction/DrawObsErrorFromFile
          options:
            file: <filepath>
            interpolation:
            - name: MetaData/satelliteIdentifier
              method: exact
            - name: MetaData/dataProviderOrigin
              method: exact
            - name: MetaData/pressure
              method: linear


Example 3 - setting and unsetting a diagnostic flag
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: yaml

    - filter: Bounds Check
      filter variables:
      - name: airTemperature
      min value: 250
      max value: 350
      # Set the ExtremeValue diagnostic flag at particularly
      # hot and cold observations, but do not reject them
      action:
        name: set
        flag: ExtremeValue
    - filter: Perform Action
      filter variables:
      - name: airTemperature
      where:
      - variable:
          name: MetaData/latitude
        maxvalue: -60
      - variable:
          name: ObsValue/airTemperature
        maxvalue: 250
      # Unset the ExtremeValue diagnostic flag at cold observations
      # in the Antarctic
      action:
        name: unset
        flag: ExtremeValue


Example 4 - setting a diagnostic flag at observations rejected by a filter
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

In this example, a Domain Check filter rejecting observations outside the 60°S--60°N zonal band is followed by a Bounds Check filter rejecting temperature readings above 350 K and below 250 K. The observations rejected by the Bounds Check filter are additionally marked with the :code:`ExtremeCheck` diagnostic flag. The :code:`ignore: rejected observations` option passed to the :code:`set` action ensures that observations that fail the criteria of the Bounds Check filter, but have already been rejected by the Domain Check filter, are not marked with the :code:`ExtremeCheck` flag.

.. code-block:: yaml

    - filter: Domain Check
      where:
      - variable:
          name: MetaData/latitude
        minvalue: -60
        maxvalue:  60
    - filter: Bounds Check
      filter variables:
      - name: airTemperature
      min value: 250
      max value: 350
      # Reject particularly hot and cold observations
      # and mark them with the ExtremeValue diagnostic flag
      actions:
      - name: set
        flag: ExtremeCheck
        ignore: rejected observations
      - name: reject


Example 5 - setting a diagnostic flag at observations accepted by a filter
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

In this example, observations taken in the zonal band 30°S--30°N that have previously been rejected for a reason other a missing observation value, a pre-processing flag indicating rejection, or failure of the observation operator are re-accepted and additionally marked with the :code:`Tropics` diagnostic flag. The :code:`ignore: defective observations` option passed to the :code:`set` action ensures that the diagnostic flag is not assigned to observations that are not accepted because of their previous rejection for one of the reasons listed above.

.. code-block:: yaml

    - filter: AcceptList
      where:
      - variable:
          name: MetaData/latitude
        minvalue: -30
        maxvalue: 30
      actions:
      - name: set
        flag: Tropics
        ignore: defective observations
      - name: accept


Example 6: ``flag original and average profiles`` action
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The ``flag original and averaged profiles`` action should only be used for data sets that satisfy two criteria:

1. They have been grouped into records (profiles).
2. They have an extended section of the ObsSpace that consists of profiles that have been averaged onto model levels.

The action rejects any observations in the original profiles that have been flagged by the
filter. It also rejects all observations in any averaged profile whose corresponding original
profile contains at least one flagged observation.

This action should therefore be used for filters that are run only on the original profiles;
it enables the corresponding averaged profiles to be flagged without running the filter on them.
Doing this reduces the chance of configuration errors occurring. It may also be desirable if the
filter relies on properties of the original profiles that are not shared by the averaged
profiles or if the filter is expensive to run.
If rejecting observations in the averaged profile is not required, the standard ``reject``
action can be used instead.

NB the ObsSpace extension is produced with the following yaml options:

.. code-block:: yaml

   extension:
     allocate companion records with length: N

where ``N`` is an integer equal to the number of levels per averaged profile.

For example, to run the ``Gaussian Thinning`` filter on all of the original profiles and
automatically flag the equivalent averaged profiles, the following yaml block can be used:

.. code-block:: yaml

    - filter: Gaussian Thinning
      where:
      - variable:
          name: MetaData/extendedObsSpace
        is_in: 0
      action:
        name: flag original and averaged profiles

If any location in an original profile is flagged (with the ``thinned`` flag in this case),
all of the locations in the corresponding average profile are also flagged with ``thinned``.

Example 7: ``Copy Flags From Extended To Original Space`` filter
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Technically this is a UFO filter and not a filter action. The intention is that after applying a filter on only the extended section of the ObsSpace (only the model levels - see example yaml snippet below), any flags thus set can be copied back to the corresponding observation levels (in original space) by calling :code:`Copy Flags From Extended To Original Space`. This is useful in cases where some filters are applied on model levels only and others on observation levels only, then consistency can be maintained throughout.

.. code-block:: yaml

    - filter: Bayesian Background Check
      where:
      - variable:
          name: MetaData/extendedObsSpace
        is_in: 1
      ...

This filter should only be used for data sets that satisfy two criteria:

1. They have been grouped into records (profiles).
2. They have an extended section of the ObsSpace that consists of profiles that have been averaged onto model levels.

See Example 6 above.

These yaml parameters are **required**:

- :code:`filter variables`: flags to copy from extended to original space. MUST be in the :code:`DiagnosticFlags` group, otherwise filter throws an error.

- :code:`observation vertical coordinate`: variable containing the observation levels (e.g. air pressure, ocean depth) in its original space.

- :code:`model vertical coordinate`: variable containing the model levels (e.g. air pressure, ocean depth) in its extended space. (One way this can be achieved is by applying the :ref:`ProfileAverage obsOperator <profileaverageoperator>` on the extended space, in combination with another obsOperator such as :ref:`VertInterp <obsops_vertinterp>` on the original space.)

Note that any diagnostic flags in the original space that are already set remain unchanged by this filter, regardless of whether the flag on the corresponding model level is set or unset; the filter can only set flags in original space that are currently unset. The filter also leaves flags unchanged in extended space. The filter does not alter any QC flags (only diagnostic flags specified by the user), nor the rejection status of any observation location. If the rejection status is also required to be set, then a subsequent :code:`Perform Action` filter should be applied, with a :ref:`where statement <where-statement>` conditional on the diagnostic flag(s) copied across by :code:`Copy Flags From Extended to Original Space`.

.. code-block:: yaml

    - filter: Copy Flags From Extended To Original Space
      where:
        - variable:
            name: ObsValue/waterPotentialTemperature
          value: is_valid
      filter variables:
        - name: DiagnosticFlags/BayBgCheckReject/salinity
        - name: DiagnosticFlags/BayBgCheckReject/waterPotentialTemperature
      observation vertical coordinate: DerivedObsValue/depthBelowWaterSurface
      model vertical coordinate: HofX/depthBelowWaterSurface

The example above matches up each observation level in the original space of :code:`DerivedObsValue/depthBelowWaterSurface` with its corresponding model level in the extended space of :code:`HofX/depthBelowWaterSurface`; for every unset observation-level flag in :code:`DiagnosticFlags/BayBgCheckReject/salinity` and :code:`DiagnosticFlags/BayBgCheckReject/waterPotentialTemperature`, for which :code:`ObsValue/waterPotentialTemperature` is non-missing (due to the 'where' statement), the flag value at the corresponding model-level overwrites it. Be wary when using 'where' statements with this filter, because the 'where' statement covers all the filter variables listed - any where-excluded locations' flag values remain unchanged.


Outer Loop Iterations
---------------------

By default, filters are applied only before the first iteration of the outer loop of the data assimilation process. Use the :code:`apply at iterations` parameter to customize the set of iterations after which a particular filter is applied. In the example below, the Background Check filter will be run before the outer loop starts ("after the zeroth iteration") and after the first iteration:

.. code-block:: yaml

    - filter: Background Check
      apply at iterations: 0,1
      threshold: 0.25
