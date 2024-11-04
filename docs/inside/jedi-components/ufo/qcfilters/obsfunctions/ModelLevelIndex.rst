.. _ModelLevelIndex:

ModelLevelIndex
---------------

This ObsFunction returns an integer at each location corresponding to the model level in which an observation lies.
The user specifies observed and model vertical coordinates using the parameters
:code:`observation vertical coordinate` and :code:`model vertical coordinate` respectively.
The observation vertical coordinate group is specified by the parameter :code:`observation vertical coordinate group`,
which has a default value of :code:`MetaData`.

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
