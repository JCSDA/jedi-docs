.. _RadarScanEdgeFlag:

RadarScanEdgeFlag
-----------------

This ObsFunction is used to apply two QC methods that are specific to PPI (plan position indicator) radar scans:

* Laplace filter: remove observation values that do not agree with their neighbours.
* (Double) edge cleaning: remove observation values at the edge of rainy areas. Gates at the edge of rainy areas may be partially filled with rain.

To achieve this, each radar scan is divided into smaller cells, each of which is bounded in the azimuthal and radial directions. The number of observations in each cell, and the values of those observations, are used in the filtering methods as detailed below.

This ObsFunction takes the following options:

* :code:`where`: Conditions used to select locations at which the RadarScanEdgeFlag ObsFunction should be applied. If not specified, all locations will be selected.
* :code:`where operator`: Operator used to combine the results of successive `where` options at the same location. The available operators are :code:`and` and :code:`or`.
* :code:`Laplace filter threshold`: Laplace filter threshold. If the absolute difference between the observation value in a cell and the average of all of the observations in its immediate neighbourhood is above this threshold, flag the cell for removal. If this threshold is zero or negative, do not apply the filter.
* :code:`cleaning filter threshold`: Cleaning filter threshold. If the total number of observations in the immediate neighbourhood of a cell is larger than this threshold, flag the cell for removal. If this threshold is zero or negative, do not apply the filter.
* :code:`double cleaning filter threshold`: Double cleaning filter threshold. Sum the number of observations in the immediate neighbourhood of a cell, then repeat the procedure on the summed values. If the resulting integrated sum is larger than this threshold, flag the cell for removal. If this threshold is zero or negative, do not apply the filter.
* :code:`OPS compatibility mode`: OPS compatibility mode. If true, the wrapping of the observation value count and count arrays are wrapped in different ways in the azimuthal direction.

Example
~~~~~~~

This example assigns the internal record number to the variable :code:`MetaData/radarEdgeFlag`.

.. code-block:: yaml

  - filter: Variable Assignment
    assignments:
    - name: MetaData/radarEdgeFlag
      type: int
      function:
        name: IntObsFunction/RadarScanEdgeFlag
