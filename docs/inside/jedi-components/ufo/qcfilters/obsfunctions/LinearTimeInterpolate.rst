.. _LinearTimeInterpolate:

LinearTimeInterpolate
=====================

The :code:`LinearTimeInterpolate` ObsFunction performs piecewise linear interpolation (or
extrapolation) of input values based on some set of associated timestamps, evaluated at a target
datetime for each observation.

This is useful when values are available at fixed reference times (e.g. SYNOP
reports) and need to be interpolated to other observation times as part of a QC
procedure.

How it works
------------

Input variables and timestamps are paired by index: the *i*-th element of :code:`input variables`
corresponds to the *i*-th element of :code:`input timestamps`. A :code:`target datetime` variable is
specified (default: :code:`MetaData/dateTime`) to indicate the time to interpolate to for each
observation.

The algorithm:

1. For each observation location, compute the time offset of each input timestamp relative to
   the target datetime at that location.
2. Discard any inputs with missing values.
3. Sort the remaining (time-offset, value) pairs by time offset.
4. Find the two points that bracket the target time (or the two nearest for extrapolation).
5. Perform linear interpolation (or extrapolation) using those two points.

The interpolation (or extrapolation) at target time :math:`t` between points
:math:`(t_1, v_1)` and :math:`(t_2, v_2)`, where :math:`v_1` and :math:`v_2`
are the values at times :math:`t_1` and :math:`t_2`, is given by:

.. math::

   \text{result} = v_1 + (v_2 - v_1) \times \frac{t - t_1}{t_2 - t_1}

Specifying timestamps
---------------------

Timestamps are always provided through :code:`input timestamps`.

All elements of :code:`input timestamps` must be of the same kind:

- Either all datetime variable references (e.g. :code:`MetaData/dateTime00`), or
- all literal timestamp strings.

Mixing datetime variable references and literal timestamp strings in the same
list is not allowed.

Supported literal timestamp formats are:

- **Time-only format**: :code:`THH:MM:SSZ` (e.g. :code:`T01:00:00Z`).
  Only the time-of-day is used for interpolation — date components are ignored.

- **Full datetime format**: :code:`YYYY-MM-DDTHH:MM:SSZ`
  (e.g. :code:`2025-12-16T01:10:20Z`).

When using literal timestamps, all input timestamps must use the same format
(either all time-only or all full datetime).

Missing data handling
---------------------

The :code:`allow gap interpolation` option controls how missing input values are treated:

- **true** (default): Missing input values are skipped. Interpolation/extrapolation uses
  the nearest available valid points, even if there are gaps in the time series.

- **false**: Interpolation across gaps is disallowed. If the time range between the two
  points being used for interpolation contains any missing values, the output is set to
  missing.

**Example**: Input variables at times T1, T2, T3, T4 where T3 has a missing value.

- With :code:`allow gap interpolation: true`: A target between T2 and T4 interpolates
  using T2 and T4 directly.
- With :code:`allow gap interpolation: false`: A target between T2 and T4 returns missing
  (gap detected at T3).

Duplicate timestamp handling
----------------------------

If multiple input values have identical timestamps:

- **Same value**: Treated as a single point (duplicates ignored).
- **Different values**: Output is set to missing and a warning is logged.

Options
-------

* :code:`input variables` *(required)*: List of variables to interpolate between.
  At least 2 required. Each element corresponds to the same-indexed element in
  :code:`input timestamps`.

* :code:`input timestamps` *(required)*: List of timestamps corresponding to the
  input variables. Must have the same number of elements as :code:`input variables`.
  Entries must be all datetime variable references or all literal timestamp
  strings in one of the supported formats (mixing is not allowed).

* :code:`target datetime` *(optional, default: MetaData/dateTime)*: The datetime
  variable to interpolate to.

* :code:`allow gap interpolation` *(optional, default: true)*: If false, output is
  set to missing when interpolating across a gap containing missing input values.

Examples
--------

Example 1 — explicit timestamps
...............................

Interpolate between two temperature bias fields using explicit datetime variables:

.. code-block:: yaml

   - filter: Variable Assignment
     assignments:
       - name: MetaData/airTemperatureInterpolated
         type: float
         function:
           name: ObsFunction/LinearTimeInterpolate
           options:
             input variables:
               - name: ObsBias/airTemperature2
               - name: ObsBias/airTemperature1
             input timestamps:
               - MetaData/dateTime2
               - MetaData/dateTime1
             target datetime: MetaData/dateTime

Here, there are a pair of interpolation points for each observation for each
location in the obs space :math:`i`:

.. math::

    (t_1, v_1)_i &= (\text{MetaData/dateTime1}[i], \text{ObsBias/airTemperature1}[i]) \\
    (t_2, v_2)_i &= (\text{MetaData/dateTime2}[i], \text{ObsBias/airTemperature2}[i])

with interpolation done to the target datetime

.. math::

    t_i = \text{MetaData/dateTime}[i].

Example 2 - literal timestamps (full datetime)
..............................................

Consider the case where every location in :code:`MetaData/dateTime1` is
2018-04-13T23:00:00Z, every location in :code:`MetaData/dateTime2` is
2018-04-14T02:00:00Z. If this knowledge is somehow known prior to using the
obsfunction (for example where two sets of known bias :math:`v_1^i` and
:math:`v_2^i` for all locations :math:`i` which have been read in using
:ref:`DrawValueFromFile`) then the interpolation can be configured with literal
timestamps:

.. code-block:: yaml

   - filter: Variable Assignment
     assignments:
       - name: MetaData/interpolatedTemperature
         type: float
         function:
           name: ObsFunction/LinearTimeInterpolate
           options:
             input variables:
               - name: ObsBias/airTemperatureBias1
               - name: ObsBias/airTemperatureBias2
             input timestamps:
               - 2018-04-13T23:00:00Z
               - 2018-04-14T02:00:00Z
             target datetime: MetaData/dateTime

In this case, the timestamps are provided directly in :code:`input timestamps`,
and the interpolation is performed at the target datetime for each observation
location:

.. math::

    (t_1, v_1)_i &= (\text{2018-04-13T23:00:00Z}, \text{ObsBias/airTemperatureBias1}[i]) \\
    (t_2, v_2)_i &= (\text{2018-04-14T02:00:00Z}, \text{ObsBias/airTemperatureBias2}[i])


Example 3 — piecewise interpolation with literal time-only timestamps
.....................................................................

Now consider the case where we have read in a set of known bias values for each
hour of the day, e.g. a set of four biases calculated every 6 hours at 00:00,
06:00, 12:00 and 18:00 UTC. If we want to interpolate these values to the
observation time of each observation, allowing for wrap-around at midnight, we
can use time-only literal timestamps:

.. code-block:: yaml

   - filter: Variable Assignment
     assignments:
       - name: MetaData/interpolatedTemperature
         type: float
         function:
           name: ObsFunction/LinearTimeInterpolate
           options:
             input variables:
               - name: ObsBias/airTemperature00
               - name: ObsBias/airTemperature06
               - name: ObsBias/airTemperature12
               - name: ObsBias/airTemperature18
             input timestamps:
               - T00:00:00Z
               - T06:00:00Z
               - T12:00:00Z
               - T18:00:00Z
             target datetime: MetaData/dateTime

Each observation at time :math:`t_i` is piecewise linearly interpolated between
the two bias values corresponding to the nearest times of day, with wrap-around
at midnight. For example, an observation at

.. math::
  t_i = \text{2018-04-13T23:00:00Z}

would be interpolated between the bias values at 18:00 and 00:00

.. math::
  (t_1, v_1)_i &= (\text{2018-04-13T18:00:00Z}, \text{ObsBias/airTemperature18}[i]) \\
  (t_2, v_2)_i &= (\text{2018-04-14T00:00:00Z}, \text{ObsBias/airTemperature00}[i])

whilst an observation at

.. math::
  t_j = \text{2018-04-14T01:00:00Z}

would be interpolated between the bias values at 00:00 and 06:00

.. math::
  (t_1, v_1)_j &= (\text{2018-04-14T00:00:00Z}, \text{ObsBias/airTemperature00}[j]) \\
  (t_2, v_2)_j &= (\text{2018-04-14T06:00:00Z}, \text{ObsBias/airTemperature06}[j]).

.. note::

  Piecewise interpolation can also be performed with explicit timestamps by providing
  multiple sets of input variables and input timestamps.

Example 4 — disallowing gap interpolation
.........................................

In the above example, consider the case where a bias value is missing at a
particular location :math:`j` in the obs space

.. math::

    \text{ObsBias/airTemperature06}_j = \text{missing}

If :code:`allow gap interpolation` is set to true (the default), then the
interpolation for an observation at

.. math::
  t_j = \text{2018-04-14T01:00:00Z}

would skip the missing value and interpolate directly between the values at
00:00 and 12:00:

.. math::
  (t_1, v_1)_j &= (\text{2018-04-14T00:00:00Z}, \text{ObsBias/airTemperature00}[j]) \\
  (t_2, v_2)_j &= (\text{2018-04-14T12:00:00Z}, \text{ObsBias/airTemperature12}[j])

If instead :code:`allow gap interpolation` is set to false, then the interpolation for
the same observation would return missing due to the gap detected at 06:00.

.. code-block:: yaml

   - filter: Variable Assignment
     assignments:
       - name: MetaData/interpolatedTemperature
         type: float
         function:
           name: ObsFunction/LinearTimeInterpolate
           options:
             input variables:
               - name: ObsBias/airTemperature00
               - name: ObsBias/airTemperature06
               - name: ObsBias/airTemperature12
               - name: ObsBias/airTemperature18
             input timestamps:
               - T00:00:00Z
               - T06:00:00Z
               - T12:00:00Z
               - T18:00:00Z
             target datetime: MetaData/dateTime
             allow gap interpolation: false
