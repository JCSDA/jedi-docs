.. _TimeBinner:

TimeBinner
==========

The :code:`TimeBinner` ObsFunction assigns each observation to a discrete time bin, returning
an integer bin number that is consistent across all MPI ranks. Optionally, a bin label timestamp
can be written back to the ObsSpace, giving all observations in the same bin an identical
timestamp.

This function is registered as an :code:`IntObsFunction` and must be referenced as
:code:`IntObsFunction/TimeBinner`.

Bin labels and bin windows
--------------------------

Each bin is identified by a *bin label timestamp* — a whole multiple of the bin interval unit
(e.g. a whole hour, midnight UTC). An observation is assigned the label of whichever bin's window
it falls into, where each bin's window is the inclusive interval:

.. math::

   [\text{bin label} + \text{window lower bound},\; \text{bin label} + \text{window upper bound}]

For example, with an :code:`hour` interval and window
:code:`-PT25M` to :code:`PT25M`, the timestamp ``2018-04-17 01:20:02 UTC`` falls within the
window of the ``01:00`` bin [``00:35``, ``01:25``], so it receives the label ``2018-04-17 01:00:00 UTC``, as
does ``2018-04-17 00:50:00 UTC``. All observations within that window share the same bin number.

Similarly, with a :code:`day` interval and window :code:`-PT6H` to :code:`PT6H`, the same
timestamp falls within the midnight bin [``2018-04-16 18:00``, ``2018-04-17 06:00``] and receives the
label ``2018-04-17 00:00:00 UTC``.

Bin windows do not need to be symmetric around the bin label. For example, a window of
:code:`-PT30M` to :code:`PT0M` covers the 30 minutes *ending* at the hour boundary.

Bin windows do not need to include the bin label timestamp — :code:`bin window lower bound`
can be positive (window starts *after* the label) or :code:`bin window upper bound` can be negative
(window ends *before* the label). For example, a window of :code:`PT1S` to :code:`PT1H` spans
the hour *following* each label: with an :code:`hour` interval an observation at ``11:00 UTC`` would
be assigned to the bin labelled ``10:00 UTC``.

Any observation falling outside every bin window is assigned the missing integer value.

**Constraints** (validated at construction time):

* :code:`bin window lower bound` ≤ :code:`bin window upper bound`
* Window width (:code:`upper bound − lower bound`) < bin interval unit (prevents overlap between adjacent bins)
* :code:`|bin window lower bound|` ≤ bin interval unit, and :code:`|bin window upper bound|` ≤ bin interval unit where :code:`| . |` denotes the absolute value.

Bin numbering
-------------

Bin numbers are non-negative integers starting from 0:

* **Forward order** (default): bin ``0`` is the bin whose label contains the earliest
  observation (across all MPI ranks) that falls within a bin window; bin numbers increase with time.
* **Reverse chronological order** (:code:`reverse chronological order: true`): bin ``0`` is the bin
  whose label contains the latest observation (across all MPI ranks) that falls within a bin
  window; bin numbers increase going *back* in time.

.. note::
   When :code:`bin window lower bound` is positive, a gap exists between each bin label timestamp and the
   opening of its window. If **forward order** is being used then any observation that falls within
   this gap for the first bin (the earliest observations) will recieve a missing bin number, even
   though a hypothetical "bin −1" window would cover it. For example, with an :code:`hour` interval,
   :code:`bin window lower bound: PT30M`, and :code:`bin window upper bound: PT1H20M`, an initial
   observation exactly ``00:15 UTC`` would receive a missing bin number, even though it falls at
   the hypothetical "bin −1" window [``23:30``, ``00:20``] associated with the ``23:00`` label.
   See :ref:`Example D <example-d-window-starting-after-the-bin-label>`
   for an illustration of this scenario.

Options
-------

* :code:`bin interval unit` *(required)*: Granularity of the bins.
  Accepted values: :code:`second`, :code:`seconds`, :code:`minute`, :code:`minutes`,
  :code:`hour`, :code:`hours`, :code:`day`, :code:`days`.

* :code:`bin window lower bound` *(required)*: Lower bound of the bin window as an ISO 8601 duration relative
  to the bin label (e.g., :code:`-PT30M` for 30 minutes before the label, :code:`PT1S` for
  1 second after). May be negative, zero, or positive.

* :code:`bin window upper bound` *(required)*: Upper bound of the bin window as an ISO 8601 duration relative
  to the bin label (e.g., :code:`PT0M` for exactly the label, :code:`PT30M` for 30 minutes
  after). Must be ≥ :code:`bin window lower bound`.

* :code:`input timestamp variable` *(optional, default:* :code:`MetaData/dateTime` *)*:
  The ObsSpace variable containing the timestamps to bin.

* :code:`binned timestamp variable` *(optional)*: If provided, the bin label timestamp is written
  to this ObsSpace variable for every observation that falls within a bin window. Observations
  outside any bin window receive the missing datetime value.

* :code:`reverse chronological order` *(optional, default:* :code:`false` *)*: If :code:`true`,
  bin numbering starts from the latest observation and increases going back in time.

Examples
--------

The examples below use the :code:`Variable Assignment` filter to compute bin numbers and bin
label timestamps for hourly binning of wind observation timestamps.

Example A — window ending at the hour boundary
..............................................

Observations in the 30-minute window *ending* at each hour boundary, i.e. with timestamps :math:`t` satisfying

.. math::

   T - \text{30 min} \leq t \leq T

where :math:`T` is the bin label timestamp, are assigned to the same bin.
Observations outside this window receive missing bin numbers.

.. code-block:: yaml

   - filter: Variable Assignment
     assignments:
       - name: MetaData/binNumbers
         type: int
         function:
           name: IntObsFunction/TimeBinner
           options:
             bin interval unit: hour
             bin window lower bound: -PT30M   # 30 minutes before the hour (inclusive)
             bin window upper bound: PT0M       # up to the hour boundary (inclusive)
             binned timestamp variable: MetaData/binTimestamps  # written for in-window obs only

For the following observation timestamps, the bin numbers and bin label timestamps assigned are:

.. list-table::
   :header-rows: 1
   :widths: 35 20 35

   * - Observation timestamp
     - Bin number
     - Bin label timestamp
   * - 2018-04-16T\ :strong:`23:50`:00Z
     - ``0``
     - 2018-04-17T\ :strong:`00:00`:00Z
   * - 2018-04-17T\ :strong:`00:00`:00Z
     - ``0``
     - 2018-04-17T\ :strong:`00:00`:00Z
   * - 2018-04-17T\ :strong:`00:15`:00Z
     - ``missing``
     - ``missing``
   * - 2018-04-17T\ :strong:`00:30`:00Z
     - ``1``
     - 2018-04-17T\ :strong:`01:00`:00Z
   * - 2018-04-17T\ :strong:`00:35`:00Z
     - ``1``
     - 2018-04-17T\ :strong:`01:00`:00Z
   * - 2018-04-17T\ :strong:`01:00`:00Z
     - ``1``
     - 2018-04-17T\ :strong:`01:00`:00Z

Note that 2018-04-17T\ :strong:`00:15`:00Z falls between the windows [``23:30``, ``00:00``] and [``00:30``, ``01:00``] and so receives
a ``missing`` bin number.

Example B — window spanning the hour boundary
.............................................

A 59-minute 59-second window centred just before the hour boundary, i.e. with timestamps :math:`t` satisfying

.. math::

   T - \text{30 min} \leq t \leq T + \text{29 min 59 s},

where :math:`T` is the bin label timestamp, covers all observations without gaps
(since JEDI timestamps have 1-second resolution).

.. code-block:: yaml

   - filter: Variable Assignment
     assignments:
       - name: MetaData/binNumbers
         type: int
         function:
           name: IntObsFunction/TimeBinner
           options:
             bin interval unit: hour
             bin window lower bound: -PT30M
             bin window upper bound: PT29M59S

Using the same observation timestamps as Example A:

.. list-table::
   :header-rows: 1
   :widths: 35 20 35

   * - Observation timestamp
     - Bin number
     - Bin label timestamp
   * - 2018-04-16T\ :strong:`23:50`:00Z
     - ``0``
     - 2018-04-17T\ :strong:`00:00`:00Z
   * - 2018-04-17T\ :strong:`00:00`:00Z
     - ``0``
     - 2018-04-17T\ :strong:`00:00`:00Z
   * - 2018-04-17T\ :strong:`00:15`:00Z
     - ``0``
     - 2018-04-17T\ :strong:`00:00`:00Z
   * - 2018-04-17T\ :strong:`00:30`:00Z
     - ``1``
     - 2018-04-17T\ :strong:`01:00`:00Z
   * - 2018-04-17T\ :strong:`00:35`:00Z
     - ``1``
     - 2018-04-17T\ :strong:`01:00`:00Z
   * - 2018-04-17T\ :strong:`01:00`:00Z
     - ``1``
     - 2018-04-17T\ :strong:`01:00`:00Z

Unlike Example A, 2018-04-17T\ :strong:`00:15`:00Z now falls within the window [``23:30``, ``00:29:59``] of the ``00:00`` bin and
receives bin number ``0``.

Example C — reverse chronological order
.........................................

Same window as Example B (:math:`T - \text{30 min} \leq t \leq T + \text{29 min 59 s}`), but bin ``0``
is assigned to the latest observation; earlier observations receive increasing bin numbers.

.. code-block:: yaml

   - filter: Variable Assignment
     assignments:
       - name: MetaData/binNumbers
         type: int
         function:
           name: IntObsFunction/TimeBinner
           options:
             bin interval unit: hour
             bin window lower bound: -PT30M
             bin window upper bound: PT29M59S
             reverse chronological order: true

Using the same observation timestamps, bin ``0`` is now assigned to the latest in-window observation
(2018-04-17T\ :strong:`01:00`:00Z), so bin numbers increase going backwards in time:

.. list-table::
   :header-rows: 1
   :widths: 35 20 35

   * - Observation timestamp
     - Bin number
     - Bin label timestamp
   * - 2018-04-16T\ :strong:`23:50`:00Z
     - ``1``
     - 2018-04-17T\ :strong:`00:00`:00Z
   * - 2018-04-17T\ :strong:`00:00`:00Z
     - ``1``
     - 2018-04-17T\ :strong:`00:00`:00Z
   * - 2018-04-17T\ :strong:`00:15`:00Z
     - ``1``
     - 2018-04-17T\ :strong:`00:00`:00Z
   * - 2018-04-17T\ :strong:`00:30`:00Z
     - ``0``
     - 2018-04-17T\ :strong:`01:00`:00Z
   * - 2018-04-17T\ :strong:`00:35`:00Z
     - ``0``
     - 2018-04-17T\ :strong:`01:00`:00Z
   * - 2018-04-17T\ :strong:`01:00`:00Z
     - ``0``
     - 2018-04-17T\ :strong:`01:00`:00Z

.. note::
   :code:`reverse chronological order` only affects bin *numbering* not the extent
   of the windows in time. For example, with the same window as Example B, the 2018-04-17T\ :strong:`00:00`:00Z
   bin still covers [``23:30``, ``00:29:59``] and the 2018-04-17T\ :strong:`01:00`:00Z bin still covers [``00:30``, ``01:29:59``],
   but the 2018-04-17T\ :strong:`00:00`:00Z bin is now bin ``1`` and the 2018-04-17T\ :strong:`01:00`:00Z bin is bin ``0``.

.. _example-d-window-starting-after-the-bin-label:

Example D — window starting after the bin label
................................................

Setting :code:`bin window lower bound` to a positive value creates a gap between each bin label
timestamp and the start of its window. Observations in this gap are not covered by the bin
sharing their label — they may be covered by the *previous* bin's window, or receive a missing
bin number if no previous bin covers them.

In this example the window spans the hour *following* each label :math:`T`, excluding the label itself:

.. math::

   T + \text{1 second} \leq t \leq T + \text{1 hour}


.. code-block:: yaml

   - filter: Variable Assignment
     assignments:
       - name: MetaData/binNumbers
         type: int
         function:
           name: IntObsFunction/TimeBinner
           options:
             bin interval unit: hour
             bin window lower bound: PT1S    # one second after the label
             bin window upper bound: PT1H      # up to one hour after the label (inclusive)

Where a timestamp :math:`t` equals a bin label timestamp :math:`T`, it falls
within the upper bound of the *previous* bin's window.

In the table below, the second earliest observation (2018-04-16T\ :strong:`23:50`:00Z)
falls within the 2018-04-16T\ :strong:`23:00`:00Z bin label timestamp's window
[``23:00``, ``23:59``], so bin ``0`` is assigned the 2018-04-16T\ :strong:`23:00`:00Z label.

.. note::
   An extra timestamp has been added to the start of the hour in this example to
   illustrate the effect of this gap on the earliest observations.

.. list-table::
   :header-rows: 1
   :widths: 35 20 35

   * - Observation timestamp
     - Bin number
     - Bin label timestamp
   * - 2018-04-16T\ :strong:`23:00`:00Z
     - ``missing``
     - ``missing``
   * - 2018-04-16T\ :strong:`23:50`:00Z
     - ``0``
     - 2018-04-16T\ :strong:`23:00`:00Z
   * - 2018-04-17T\ :strong:`00:00`:00Z
     - ``0``
     - 2018-04-16T\ :strong:`23:00`:00Z
   * - 2018-04-17T\ :strong:`00:15`:00Z
     - ``1``
     - 2018-04-17T\ :strong:`00:00`:00Z
   * - 2018-04-17T\ :strong:`00:30`:00Z
     - ``1``
     - 2018-04-17T\ :strong:`00:00`:00Z
   * - 2018-04-17T\ :strong:`00:35`:00Z
     - ``1``
     - 2018-04-17T\ :strong:`00:00`:00Z
   * - 2018-04-17T\ :strong:`01:00`:00Z
     - ``1``
     - 2018-04-17T\ :strong:`00:00`:00Z

The observations at 2018-04-17T\ :strong:`00:00`:00Z and 2018-04-17T\ :strong:`01:00`:00Z
each fall outside their own bin's window but are found at the inclusive upper bound of the
previous bin's window, so they are assigned to that previous bin.
