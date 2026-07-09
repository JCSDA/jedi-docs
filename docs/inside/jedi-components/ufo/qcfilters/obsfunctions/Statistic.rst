.. _Statistic:

Statistic
---------

The :code:`Statistic` ObsFunction computes a global summary statistic (arithmetic mean,
harmonic mean, median, mode, weighted mean, standard deviation, or variance) by
gathering all non-missing values from the input variable across all MPI ranks. **The
same scalar value is computed for all locations and assigned to all locations in the
output**.

Unlike the :ref:`SelectStatistic <ObsFunctionSelectStatistic>` ObsFunction,
:code:`Statistic` calculates a statistic and outputs it at all locations, rather than
highlighting the location(s) in the obs space where the input variable has, or is
closest to, a desired statistic value.

The :code:`Statistic` ObsFunction **cannot** be used to compute statistics
over a subset of observations directly — see the :ref:`detailed example <statistic-subset>` below
for how to compute a statistic over a subset of observations by first isolating the subset in a
separate variable with the :ref:`Variable Assignment filter <VariableAssignmentFilter>`.

Only :code:`float`-type input variables are currently supported.

.. note::

  The :code:`Statistic` ObsFunction currently performs a global MPI gather of
  all non-missing values of the input variable to each rank for computation.
  This may cause memory issues for large datasets. Future versions may implement
  a more scalable parallel algorithm.

Required input parameters:
~~~~~~~~~~~~~~~~~~~~~~~~~~~

variable
  The input variable over which the statistic is computed. Missing values are
  excluded from all calculations.

statistic
  The type of statistic to compute. Allowed values are:

  :code:`arithmetic mean`
    Arithmetic (simple) mean of all non-missing values.

  :code:`harmonic mean`
    Harmonic mean of all non-missing values. By default throws an exception if
    any non-missing value is zero or negative (controlled by
    :code:`abort if invalid operation` parameter). If that parameter is set to
    :code:`false`, returns missing and logs a warning instead.

  :code:`median`
    Median of all non-missing values. For an even number of values the average of
    the two central values is returned.

  :code:`mode`
    Most frequently occurring value. Returns missing if all values are unique (no
    mode exists). If multiple values share the highest frequency (multimodal data),
    the smallest such value is returned.

  :code:`weighted mean`
    Weighted arithmetic mean. The :code:`weight variable` parameter is required when
    this statistic is selected. Returns missing if there are no valid
    value/weight pairs or if the sum of valid weights is not positive.

  :code:`standard deviation`
    Population or sample standard deviation, governed by :code:`delta degrees of
    freedom`. Returns missing if the number of valid values does not exceed
    :code:`delta degrees of freedom`.

  :code:`variance`
    Population or sample variance, governed by :code:`delta degrees of freedom`.
    Returns missing if the number of valid values does not exceed
    :code:`delta degrees of freedom`.


Optional input parameters:
~~~~~~~~~~~~~~~~~~~~~~~~~~~

weight variable
  The variable supplying per-location weights for the :code:`weighted mean` statistic.
  This parameter is required when :code:`statistic: weighted mean` is specified and
  ignored otherwise. A location contributes to the weighted mean only if *both* the
  input variable *and* the weight variable are non-missing at that location.

delta degrees of freedom
  Integer adjustment to the degrees of freedom used by the :code:`standard deviation`
  and :code:`variance` computations, analogous to NumPy's
  `ddof parameter <https://numpy.org/doc/stable/reference/generated/numpy.std.html>`_.
  Must be non-negative.

  - :code:`0` (default) — population statistic.
  - :code:`1` — sample statistic.

abort if invalid operation
  Boolean flag controlling behavior of :code:`harmonic mean` when encountering zero or
  negative values. Default is :code:`true`.

  - :code:`true` (default) — raise an exception when zero or negative value is encountered.
  - :code:`false` — return missing and log a warning instead.


Example configurations:
~~~~~~~~~~~~~~~~~~~~~~~~

Arithmetic mean — assigned to all locations
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: yaml

  - filter: Variable Assignment
    assignments:
      - name: MetaData/meanPressure
        type: float
        function:
          name: ObsFunction/Statistic
          options:
            statistic: arithmetic mean
            variable: ObsValue/pressure


.. _statistic-where-example:

Understanding where clauses with Statistic
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The :code:`Statistic` ObsFunction computes a global summary statistic from
**all non-missing values** in the input variable, regardless of where clauses,
as is the case for most ObsFunctions like :ref:`Arithmetic <Arithmetic>`.

When a :code:`where` clause is applied to the Variable Assignment filter, it
controls *which locations receive the computed value*, not which values are
included in the statistic.

For example, this configuration computes the **global mean pressure** (from all
stations) and writes it only at Station 0 locations:

.. code-block:: yaml

  - filter: Variable Assignment
    assignments:
      - name: MetaData/meanPressure
        type: float
        function:
          name: ObsFunction/Statistic
          options:
            statistic: arithmetic mean
            variable: ObsValue/pressure
    where:
      - variable: { name: MetaData/stationIdentification }
        matches_regex: "Station0"

Station 1 locations remain missing. The statistic is **NOT** computed from Station 0
pressures only — it uses all non-missing pressures from all stations. If you need
to compute a statistic over a subset, see the next section.


.. _statistic-subset:

Computing a statistic over a subset of observations
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

To compute a statistic using *only* observations that satisfy some condition, first
copy the values of interest into a new variable (missing elsewhere), then apply
:code:`Statistic` to that new variable.

.. code-block:: yaml

  # Step 1: extract Station 0 pressures (missing at all other stations)
  - filter: Variable Assignment
    assignments:
      - name: MetaData/station0Pressure
        type: float
        source variable: ObsValue/pressure
    where:
      - variable: { name: MetaData/stationIdentification }
        matches_regex: "Station0"

  # Step 2: mean of Station 0 pressures only, assigned to all locations
  - filter: Variable Assignment
    assignments:
      - name: MetaData/meanStation0Pressure
        type: float
        function:
          name: ObsFunction/Statistic
          options:
            statistic: arithmetic mean
            variable: MetaData/station0Pressure


Weighted mean
^^^^^^^^^^^^^

.. code-block:: yaml

  - filter: Variable Assignment
    assignments:
      - name: MetaData/weightedMeanPressure
        type: float
        function:
          name: ObsFunction/Statistic
          options:
            statistic: weighted mean
            variable: ObsValue/pressure
            weight variable: MetaData/weights


Population and sample standard deviation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: yaml

  - filter: Variable Assignment
    assignments:
      - name: MetaData/populationStdTemperature
        type: float
        function:
          name: ObsFunction/Statistic
          options:
            statistic: standard deviation
            variable: ObsValue/temperature
            # delta degrees of freedom: 0  # default — population std dev
      - name: MetaData/sampleStdTemperature
        type: float
        function:
          name: ObsFunction/Statistic
          options:
            statistic: standard deviation
            variable: ObsValue/temperature
            delta degrees of freedom: 1  # sample std dev
