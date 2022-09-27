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
        - air_temperature (K)
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
      filter variables: air_temperature
      minvalue: 230
      action:
        name: reject # this is the default action, specified explicitly for clarity
      where:
      - variable:
          name: latitude@MetaData
        minvalue: -30
        maxvalue:  30
    
This would cause the filter to be applied only to air temperature observations `selected` by the :code:`where` statement, i.e. meeting the specified condition :code:`-30 <= latitude@MetaData <= 30`. Please note this does not mean all these observations would be rejected; rather, it means the Bounds Check filter would inspect only these observations and apply its usual criteria (in this case, "is the air temperature below the minimum allowed value of 230 K?") to decide whether any of them should be rejected. In our example, only observation 1 would be rejected, since this is the only observation (a) taken in the range of latitudes selected by the :code:`where` statement and (b) with a value lying below the minimum value passed to the Bounds Check filter.

The list passed to the :code:`where` keyword can contain more than one item, each representing a separate condition imposed on a particular variable. The filter is applied only to observations meeting all of these conditions. The following kinds of conditions are accepted:

- :code:`minvalue` and/or :code:`maxvalue`: filter applied only to observations for which the condition variable lies in the specified range. The upper and lower bounds can be floating-point numbers or datetimes in the ISO 8601 format. If any date/time components are set to `*`, they are disregarded. See :ref:`Example 2 <where-example-2>` below on where this can be useful.  Each of these strings must be 20 characters long so defining 'any year' would be indicated by `****`.
- :code:`is_defined`: filter applied only to observations for which the condition variable has a valid value (not a missing data indicator).
- :code:`is_not_defined`: filter applied only to observations for which the condition variable is set to a missing data indicator.
- :code:`is_in`: filter applied only to observations for which the condition variable is set to a value belonging to the given whitelist.
- :code:`is_close_to_any_of`: filter applied only to observations for which the condition variable (a float) is close to any of the variables in the given reference list.  Two variables are defined as close if they differ by less than a provided tolerance.  The tolerance must be provided and can either be absolute (:code:`absolute_tolerance`) or relative (:code:`relative_tolerance`).
- :code:`is_not_in`: filter applied only to observations for which the condition variable is set to a value not belonging to the given blacklist.
- :code:`is_not_close_to_any_of`: filter applied only to observations for which the condition variable (a float) is not close to any of the variables in the given reference list.  Two variables are defined as close if they differ by less than a provided tolerance.  The tolerance must be provided and can either be absolute (:code:`absolute_tolerance`) or relative (:code:`relative_tolerance`).
- :code:`is_true`: filter applied only to observations for which the condition variable (normally a diagnostic flag) is set to :code:`true`.
- :code:`is_false`: filter applied only to observations for which the condition variable (normally a diagnostic flag) is set to :code:`false`.
- :code:`any_bit_set_of`: filter applied only to observations for which the condition variable is an integer with at least one of the bits with specified indices set.
- :code:`any_bit_unset_of`: filter applied only to observations for which the condition variable is an integer with at least one of the bits with specified indices unset (i.e. zero).
- :code:`matches_regex`: filter applied only to observations for which the condition variable is a string that matches the specified regular expression or an integer whose decimal representation matches that expression. The regular expression should conform to the ECMAScript syntax described at http://www.cplusplus.com/reference/regex/ECMAScript.
- :code:`matches_wildcard`: filter applied only to observations for which the condition variable is a string that matches the specified wildcard pattern or an integer whose decimal representation matches that pattern. The following wildcards are recognized: :code:`*` (matching any number of characters, including zero) and :code:`?` (matching any single character).
- :code:`matches_any_wildcard`: filter applied only to observations for which the condition variable is a string that matches at least one of the specified wildcard patterns, or an integer whose decimal representation matches at least one of these patterns. The same wildcards are recognized as for :code:`matches_wildcard`.

The elements of both whitelists and blacklists can be strings, non-negative integers or ranges of non-negative integers. It is not necessary to put any value after the colon following :code:`is_defined` and :code:`is_not_defined`. Bits are numbered from zero starting from the least significant bit.

By default, if multiple conditions are used in a :code:`where` statement then the logical :code:`and` of the results is used to determine which locations are selected by the statement. The logical operator used to combine the results can be chosen explicitly with the :code:`where operator` parameter; the permitted operators are :code:`and` and :code:`or`. The use of the :code:`or` operator is illustrated in :ref:`Example 11 <where-example-11>`. Note that it is possible to use the :code:`where operator` option without the :code:`where` statement. The option has no impact in that case.

The following examples illustrate the use of these conditions.

Example 1
^^^^^^^^^

.. code-block:: yaml
    
    where:
    - variable:
        name: sea_surface_temperature@GeoVaLs
      minvalue: 200
      maxvalue: 300
    - variable:
        name: latitude@MetaData
      maxvalue: 60.
    - variable:
        name: height@MetaData
      is_defined:
    - variable:
        name: station_id@MetaData
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
        name:  datetime@MetaData
      minvalue: "****-01-01T00:00:00Z"
      maxvalue: "****-25-05T00:00:00Z"
    - variable:
        name:  datetime@MetaData
      minvalue: "****-**-**T09:00:00Z"
      maxvalue: "****-**-**T18:00:00Z"
    
In this example, the filter will be applied only to observations taken between 09:00:00 and 18:00:00, between 1st January and 25th May of every year (end inclusive).  Note that datetime components are not yet 'loop aware'.  That is, a where clause between May and February for example would require two filters: one covering the Jan-Feb period and a second to cover the May-Dec period.

Example 3
^^^^^^^^^

.. code-block:: yaml
    
    where:
    - variable:
        name: mass_concentration_of_chlorophyll_in_sea_water@PreQC
      any_bit_set_of: 0, 1
    
In this example, the filter will be applied only to observations for which the :code:`mass_concentration_of_chlorophyll_in_sea_water@PreQC` variable is an integer whose binary representation has a 1 at position 0 and/or position 1. (Position 0 denotes the least significant bit -- in other words, bits are numbered "from right to left".)
    
Example 4
^^^^^^^^^

.. code-block:: yaml
    
    where:
    - variable:
        name: mass_concentration_of_chlorophyll_in_sea_water@PreQC
      any_bit_set_of: 4
    - variable:
        name: mass_concentration_of_chlorophyll_in_sea_water@PreQC
      any_bit_unset_of: 10-12
    
In this example, the filter will be applied only to observations for which the :code:`mass_concentration_of_chlorophyll_in_sea_water@PreQC` variable is an integer whose binary representation has a 1 at position 4 and a 0 at any of positions 10 to 12.
    
Example 5
^^^^^^^^^

.. code-block:: yaml
    
    where:
    - variable:
        name: station_id@MetaData
      matches_regex: 'EUR[A-Z]*'
    
In this example, the filter will be applied only to observations taken by stations whose IDs match the regular expression :code:`EUR[A-Z]*`, i.e. consist of the string :code:`EUR` followed by any number of capital letters.
    
Example 6
^^^^^^^^^

.. code-block:: yaml
    
    where:
    - variable:
        name: station_id@MetaData
      matches_wildcard: 'EUR??TEST*'
    
In this example, the filter will be applied only to observations taken by stations whose IDs match the wildcard pattern :code:`EUR??TEST*`, i.e. consist of the string :code:`EUR` followed by two arbitrary characters, the string :code:`TEST` and any number of arbitrary characters.
    
Example 7
^^^^^^^^^

.. code-block:: yaml
    
    where:
    - variable:
        name: observation_type@MetaData
      matches_any_wildcard: ['102*', '103*']
    
In this example, assuming that :code:`observation_type@MetaData` is an integer variable, the filter will be applied only to observations whose types have decimal representations starting with :code:`102` or :code:`103`.

Example 8
^^^^^^^^^

.. code-block:: yaml
    
    where:
    - variable:
        name: model_elevation@GeoVaLs
      is_close_to_any_of: [0.0, 1.0]
      absolute_tolerance: 1.0e-12
    
In this example, assuming that :code:`model_elevation@GeoVaLs` is a float variable, the filter will be applied only to observations whose :code:`model_elevation` is within :code:`1.0e-12` of either :code:`0.0` or :code:`1.0`.

Example 9
^^^^^^^^^

.. code-block:: yaml
    
    where:
    - variable:
        name: model_elevation@GeoVaLs
      is_not_close_to_any_of: [100.0, 200.0]
      relative_tolerance: 0.1
    
In this example, assuming that :code:`model_elevation@GeoVaLs` is a float variable, the filter will be applied only to observations whose :code:`model_elevation` is not within 10 % of either :code:`100.0` or :code:`200.0`.

Example 10
^^^^^^^^^^

.. code-block:: yaml

    where:
    - variable:
        name: DiagnosticFlags/ExtremeValue/air_temperature
      is_true:
    - variable:
        name: DiagnosticFlags/ExtremeValue/relative_humidity
      is_false:

In this example, the filter will be applied only to observations with the :code:`ExtremeValue` diagnostic flag set for the air temperature, but not for the relative humidity.

.. _where-example-11:

Example 11
^^^^^^^^^^

.. code-block:: yaml

    where:
    - variable:
        name: latitude@MetaData
      minvalue: 60.
    - variable:
        name: latitude@MetaData
      maxvalue: -60.
    where operator: or

In this example, the filter will be applied only to observations for which either of the following criteria are met:

- the latitude is further north than 60°N,
- the latitude is further south than 60°S.


.. _obs-function-and-obs-diagnostic-suffixes:

ObsFunction and ObsDiagnostic Suffixes
--------------------------------------

In addition to, e.g., :code:`@GeoVaLs`, :code:`@MetaData`, :code:`@ObsValue`, :code:`@HofX`, there are two new suffixes that can be used.

- :code:`@ObsFunction` indicates that a particular variable should be a registered :code:`ObsFunction` (:code:`ObsFunction` classes are defined in the :code:`ufo/src/ufo/filters/obsfunctions` folder).  One example of an :code:`ObsFunction` is :code:`Velocity@ObsFunction`, which uses the 2 wind components to produce wind speed and can be used as follows:

.. code-block:: yaml

    - filter: Domain Check
      filter variables:
      - name: eastward_wind
      - name: northward_wind
      where:
      - variable: Velocity@ObsFunction
        maxvalue: 20.0

Warning: ObsFunctions are evaluated for all observations, including those that have been unselected by previous elements of the :code:`where` list or rejected by filters run earlier. This can lead to problems if these ObsFunctions incorrectly assume they will always be given valid inputs.

- :code:`@ObsDiagnostic` will be used to store non-H(x) diagnostic values from the :code:`simulateObs` function in individual :code:`ObsOperator` classes.  The :code:`ObsDiagnostics` interface class in OOPS is used to pass those diagnostics to the :code:`ObsFilters`.  Because the diagnostics are provided by :code:`simulateObs`, they can only be used in filters that implement the :code:`postFilter` function (currently only Background Check and Met Office Buddy Check).  The :code:`simulateObs` interface to :code:`ObsDiagnostics` will be first demonstrated in CRTM.
- In order to set up :code:`ObsDiagnostics` for use in a filter, the following changes need to be made:

  - In the constructor of the filter, ensure that the diagnostic is added to the :code:`allvars_` variable.  For instance: :code:`allvars_ += Variable("refractivity@ObsDiag");`.  This step informs the code to set up the object, ready for use in the operator.
  - In the observation operator, make sure that the :code:`ObsDiagnostics` object is received, check that this contains the variables that you are expecting to save, and save the variables.  An example of this (in Fortran) is in `Met Office GNSS-RO operator <https://github.com/JCSDA-internal/ufo/blob/develop/src/ufo/gnssro/BendMetOffice/ufo_gnssro_bendmetoffice_mod.F90#L95>`_
  - Use the variable in the filter via the :code:`data_.get()` routine.  For instance add::
  
      Variable refractivityVariable = Variable("refractivity@ObsDiag");
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

* :code:`flag original and average profiles`: rejects any observations in the original profiles that have been flagged by the filter, and also rejects all observations in any averaged profile whose corresponding original profile contains at least one flagged observation. See the example below for further details.

To perform multiple actions, replace the :code:`action` option, which takes a single action, by :code:`actions`, which takes a list of actions. This list may contain at most one action altering quality control flags, namely :code:`reject`, :code:`accept` and :code:`passivate`; if present, such an action must be the last in the list. The :code:`action` and :code:`actions` options are mutually exclusive.

The default action for almost all filters (taken when both the :code:`action` and :code:`actions` keywords are omitted) is :code:`reject`. There are two exceptions: the default action of the :code:`AcceptList` filter is :code:`accept` and the :code:`Perform Action` filter has no default action (either the :code:`action` or :code:`actions` keyword must be present).

Example 1 - rejection, error inflation and assignment
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: yaml
    
    - filter: Background Check
      filter variables:
      - name: air_temperature
      threshold: 2.0
      absolute threshold: 1.0
      action:
        name: reject
    - filter: Background Check
      filter variables:
      - name: eastward_wind
      - name: northward_wind
      threshold: 2.0
      where:
      - variable: latitude@MetaData
        minvalue: -60.0
        maxvalue: 60.0
      action:
        name: inflate error
        inflation: 2.0
    - filter: BlackList
      filter variables:
      - name: brightness_temperature
      channels: *all_channels
      action:
        name: assign error
        error function:
          name: ObsErrorModelRamp@ObsFunction
          channels: *all_channels
          options:
            channels: *all_channels
            xvar:
              name: CLWRetSymmetricMW@ObsFunction
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


Example 2 - error assignment using :code:`DrawObsErrorFromFile@ObsFunction`
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Next we demonstrate deriving the observation error from a NetCDF file which defines the variance/covariance:

.. code-block:: yaml

    - filter: Perform Action
      filter variables:
      - name: air_temperature
      action:
        name: assign error
        error function:
          name: DrawObsErrorFromFile@ObsFunction
          options:
            file: <filepath>
            interpolation:
            - name: satellite_id@MetaData
              method: exact
            - name: processing_center@MetaData
              method: exact
            - name: air_pressure@MetaData
              method: linear


Example 3 - setting and unsetting a diagnostic flag
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: yaml

    - filter: Bounds Check
      filter variables:
      - name: air_temperature
      min value: 250
      max value: 350
      # Set the ExtremeValue diagnostic flag at particularly
      # hot and cold observations, but do not reject them
      action:
        name: set
        flag: ExtremeValue
    - filter: Perform Action
      filter variables:
      - name: air_temperature
      where:
      - variable:
          name: latitude@MetaData
        maxvalue: -60
      - variable:
          name: air_temperature@ObsValue
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
          name: latitude@MetaData
        minvalue: -60
        maxvalue:  60
    - filter: Bounds Check
      filter variables:
      - name: air_temperature
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
          name: latitude@MetaData
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
          name: MetaData/extended_obs_space
        is_in: 0
      action:
        name: flag original and averaged profiles

If any location in an original profile is flagged (with the ``thinned`` flag in this case),
all of the locations in the corresponding average profile are also flagged with ``thinned``.


Outer Loop Iterations
---------------------

By default, filters are applied only before the first iteration of the outer loop of the data assimilation process. Use the :code:`apply at iterations` parameter to customize the set of iterations after which a particular filter is applied. In the example below, the Background Check filter will be run before the outer loop starts ("after the zeroth iteration") and after the first iteration:

.. code-block:: yaml

    - filter: Background Check
      apply at iterations: 0,1
      threshold: 0.25
