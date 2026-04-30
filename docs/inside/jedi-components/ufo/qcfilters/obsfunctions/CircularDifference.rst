.. _CircularDifference:

CircularDifference
==================

The :code:`CircularDifference` ObsFunction computes the minimum (shortest-path) difference between two
values defined on a circular (cyclic) domain, accounting for wrap around at the circular boundary.

For two values :math:`A` (:code:`variable start`) and :math:`B` (:code:`variable end`) of a circular
quantity, the circular difference is :math:`B - A` normalised to the range :math:`[-P/2,\, P/2)` where
:math:`P` is the circular period.
Of the two such possible differences (the shortest path and longest paths around the circle) the shortest path is returned.

If :code:`signed` is :code:`true`, the signed difference in the range :math:`[-P/2,\, P/2)` is returned:

* Positive values indicate :math:`B` is ahead of :math:`A` in the direction of increasing values (clockwise for angles).
* Negative values indicate :math:`B` is behind :math:`A` in the direction of increasing values (counter-clockwise for angles).

If :code:`signed` is :code:`false`, the absolute (unsigned) difference is returned, always in
the range :math:`[0,\, P/2]`.

Similarly for days in the week, if :code:`P = 7` and :math:`A = 6` (Saturday) and :math:`B = 1`
(Monday), the circular difference is :math:`-2` if :code:`signed` is :code:`true` (indicating that
Monday is 2 days before Saturday), and :math:`2` if :code:`signed` is :code:`false`.

Missing values in either input variable propagate to the output.

Options
-------

* :code:`variable start` *(required)*: The start variable :math:`A` (the reference value).
* :code:`variable end` *(required)*: The end variable :math:`B` (the value being compared).
* :code:`signed` *(optional)*: If :code:`true`, return the signed difference in :math:`[-P/2,\, P/2)`.
  If :code:`false`, return the absolute difference in :math:`[0,\, P/2]`. Defaults to :code:`true`.
* :code:`circular period` *(required)*: The period :math:`P` of the circular quantity (e.g.
  :code:`360.0` for wind directions in degrees, :code:`6.283185307` for angles in radians,
  :code:`24` for hours in the day). Must be positive.

Examples
--------

The following examples illustrate the sign convention using wind directions (:math:`P = 360°`) as
a concrete case. Note how the signed difference gives a negative value when :math:`B` and :math:`A`
are on opposite sides of the 0°/360° boundary. The same would happen with hours in the day if the
values were separated by 12 hours.

.. list-table::
   :header-rows: 1
   :widths: 20 20 30 30

   * - :math:`A` (°)
     - :math:`B` (°)
     - Signed difference (°)
     - Unsigned difference (°)
   * - 10
     - 350
     - −20
     - 20
   * - 350
     - 10
     - 20
     - 20
   * - 0
     - 180
     - -180
     - 180
   * - 90
     - 270
     - -180
     - 180

The following YAML computes both the signed and unsigned circular difference between two wind
direction variables, using the :code:`Variable Assignment` filter:

.. code-block:: yaml

   obs filters:
     # Signed circular difference (windDirectionB - windDirectionA)
     - filter: Variable Assignment
       assignments:
         - name: MetaData/signedWindDirectionCircularDiff
           type: float
           function:
             name: ObsFunction/CircularDifference
             options:
               variable start: ObsValue/windDirectionA
               variable end: ObsValue/windDirectionB
               signed: true
               circular period: 360.0
     # Unsigned (absolute) circular difference |windDirectionB - windDirectionA|
     - filter: Variable Assignment
       assignments:
         - name: MetaData/unsignedWindDirectionCircularDiff
           type: float
           function:
             name: ObsFunction/CircularDifference
             options:
               variable start: ObsValue/windDirectionA
               variable end: ObsValue/windDirectionB
               signed: false
               circular period: 360.0
