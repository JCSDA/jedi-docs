.. _ModelLevelIndex:

ModelLevelIndex
---------------

This ObsFunction returns an integer at each location corresponding to the model level in which an observation lies.

The following parameters govern the behavior of the ObsFunction:

* :code:`observation vertical coordinate`: observation vertical coordinate variable name in the ObsSpace.
* :code:`model vertical coordinate`: model vertical coordinate variable name in the ObsSpace.
* :code:`observation vertical coordinate group` (default: :code:`MetaData`): the group in the ObsSpace containing the :code:`observation vertical coordinate` variable.
* :code:`select closest model index` (default: :code:`false`): If true, the model level index returned is that of the closest model level to the observation. If false, the model level index corresponds to the floor (the numerically lower model level when an observation is between levels).
* :code:`invert model index` (default: :code:`false`): The model index returned by default is from the top of the atmosphere to the surface. In the case where the user wants the model index to be from the surface to the top of the atmosphere, this option should be set to true.
* :code:`index model levels from one` (default: :code:`false`): If true, model level indices returned are 1-based. If false, model level indices returned are 0-based (i.e. the index of the first model level is 0).

If the observation value is missing, or outside either bound of the corresponding model column, the model level index is set to the missing integer value.
Treatment of values at level boundaries is governed by the underlying vertical interpolation code.

Example
~~~~~~~

This example determines the level index of the variable :code:`MetaData/height` in the :code:`height` GeoVaL at each location.

.. code-block:: yaml

  - filter: Variable Assignment
    assignments:
    - name: MetaData/modelLevelIndex
      type: int
      function:
        name: IntObsFunction/ModelLevelIndex
        options:
          observation vertical coordinate: height
          model vertical coordinate: height

This example determines the closest level index of the variable :code:`ObsValue/pressure` in the :code:`air_pressure` GeoVaL at each location. The model index is then inverted so that it is bottom to top and the index is from one rather than zero.

.. code-block:: yaml

  - filter: Variable Assignment
    assignments:
    - name: MetaData/modelLevelIndex
      type: int
      function:
        name: IntObsFunction/ModelLevelIndex
        options:
          observation vertical coordinate: pressure
          model vertical coordinate: air_pressure
          observation vertical coordinate group: ObsValue
          select closest model index: true
          invert model index: true
          index model levels from one: true
          
          
          
