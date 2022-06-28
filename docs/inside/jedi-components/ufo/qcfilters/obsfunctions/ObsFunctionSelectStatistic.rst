.. _ObsFunctionSelectStatistic:

ObsFunctionSelectStatistic
-----------------------------------------------------------------

The output is all 0's except for 1 in locations corresponding (or closest) to optionally the minimum, maximum, median or mean of the given input variable, within each record. Only supports float-type input, and outputs int-type only.

Required input parameters:
~~~~~~~~~~~~~~~~~~~~~~~~~~

variable
  The input variable. May be a multi-channel variable, in which case both the name of the variable and the channels must be given. Only one variable should be specified, otherwise the filter will stop with an error.

Optional input parameters:
~~~~~~~~~~~~~~~~~~~~~~~~~~

select minimum
  If true, output will contain 1 in one location per record where the input variable is minimum within that record. Default: false.

select maximum
  If true, output will contain 1 in one location per record where the input variable is maximum within that record. Default: false.

select median
  If true, output will contain 1 in one location per record where the input variable is closest to the median of all values of the input variable within that record. Default: false.

select mean
  If true, output will contain 1 in one location per record where the input variable is closest to the mean computed from values of the input variable within that record. Default: false.

force select
  If true, a record for which all values of the input variable are missing will still result in a 1 at the first location in each record. Default: false, the output would be all 0's at locations of a record with all missing values of the input variable.

Note that any or all of the :code:`select ...` options can be set to :code:`true` - the output could then contain multiple 1's per record. The 1's do not add: for example, if selecting both mean and median, and they happen to be in the same location in one record, that location is still 1 in the output. If none of the :code:`select ...` options are :code:`true`, the output is all 0's.

The :ref:`"where" <where-statement>` option is supported. By default, this ObsFunction only ignores missing values in the input variable. If some locations are required to be excluded from calculation of the statistic(s) to be selected, where the ObsValue is missing or a QC flag is set, then this must be made explicit in a :code:`where` clause.

  
Example configuration:
~~~~~~~~~~~~~~~~~~~~~~

An example with a multi-channel variable:

.. code-block:: yaml

  obs function:
    name: SelectStatistic@IntObsFunction
    options:
      where:
      - variable:
          name: ObsValue/var1
        is_defined:
      - variable:
          name: QCflagsData/var2
        is_in: 0
      variable:
      - name: MetaData/input_data
        channels: 1-3
      select minimum: true
      select maximum: true

Assuming the observations have been grouped into records (an example of grouping can be found in :ref:`Profile consistency checks <profconcheck_filtervars>`), this will return a 3-channel output with 1 in the locations of the minimum and maximum values of :code:`MetaData/input_data` in each channel of each record. This excludes locations with missing values of :code:`ObsValue/var1`, and locations where :code:`ObsValue/var2` has not passed QC so far. That is, 1 is only written to the locations where :code:`MetaData/input_data` is lowest and highest out of the subset in each channel, each record, that satisfy both :ref:`"where" <where-statement>` conditions.

The variable assigned an output from this ObsFunction can then be used in a variety of ways:

E.g.1. as a :code:`priority variable` in a :ref:`Gaussian Thinning filter <GaussianThinningFilter>`;

E.g.2. in a :ref:`"where" <where-statement>` clause to pick out a particular value, such as the deepest depth in each ocean profile:

.. code-block:: yaml

  - filter: Variable Assignment  # mask to select bottom level
    assignments:
    - name: DerivedMetaData/bottom_level
      type: int
      function:
        name: SelectStatistic@IntObsFunction
        options:
          variable:
          - name: MetaData/ocean_depth
          select maximum: true
          force select: true
  - filter: Variable Assignment   # bottom depth
    where:
    - variable:
        name: DerivedMetaData/bottom_level
      is_in: 1
    assignments:
    - name: DerivedMetaData/bottom_depth
      type: float
      source variable: MetaData/ocean_depth
  - filter: Variable Assignment   # bottom depth zeroes
    where:
    - variable:
        name: DerivedMetaData/bottom_level
      is_in: 1
    - variable:
        name: DerivedMetaData/number_of_levels
      is_in: 0
    assignments:
    - name: DerivedMetaData/bottom_depth
      type: float
      value: 0

This produces :code:`DerivedMetaData/bottom_depth` which is all missing except for the largest value of :code:`MetaData/ocean_depth` in each record; for records with all depths missing, :code:`DerivedMetaData/bottom_depth` has 0 written to the first level of such records. (Assuming :code:`DerivedMetaData/number_of_levels` has been produced previously using :ref:`ProfileLevelCount <ProfileLevelCount>`.) This is thanks to the use of :code:`force select: true`, otherwise records with all depths missing would be all missing values in :code:`DerivedMetaData/bottom_depth`.

E.g.3. to un-flag certain locations after a QC filter has been applied:

.. code-block:: yaml

  - filter: Variable Assignment # un-flag surface level in each profile
    assignments:
    - name: surface_level@DerivedMetaData
      type: int
      function:
        name: SelectStatistic@IntObsFunction
        options:
          variable: ocean_depth@MetaData
          select minimum: true
  - filter: Perform Action
    where:
    - variable:
        name: surface_level@DerivedMetaData
      is_in: 1
    actions:
    - name: unset
      flag: LevelSubsampleReject
    - name: accept

So if a previous filter that had set the Diagnostic Flag :code:`LevelSubsampleReject` had rejected the surface level in any profiles, the surface level would be reinstated in those profiles, and everything else would be left untouched.