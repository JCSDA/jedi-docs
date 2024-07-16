.. _generic-interp:

Generic Interpolator
====================

The Generic Interpolation block provides an interpolation method that is intended
to work in most cases.

The outline of a yaml configuration for the :code:`interpolation` block is shown
below:

.. code-block:: yaml

  - saber block name: interpolation
    inner geometry:
      function space: <covariance model functionspace>
      grid:
        name: <covariance model grid>
      partitioner: (optional, default = 'equal regions')
      halo: 1
    forward interpolator: <fw interpolator name>
      ...
    inverse interpolator: <inv interpolator name>
      ...
    active variables: <vars>

The :code:`inner geometry` key specifies the geometry used by the blocks sandwiched
in between the adjoint and forward interpolation blocks in the full block chain.
Thus, it is the 'target' geometry in the adjoint (inverse) direction and the 'source'
geometry for the forward (tangent-linear) direction. The grid partitioner and halo
depth can also be specified. For most cases, the :code:`partitioner` key can be left
out (which will result in the default :code:`equal regions` partitioning), but for
some cases, a different partitioner must be specified. For example, for block chains
that involve spectral methods, the :code:`ectrans` partitioner must be used.

Also, both a :code:`forward interpolator` and an :code:`inverse interpolator` should
be specified. The :code:`forward interpolator` is used in the forward, inner-to-model
geometry direction, and the :code:`inverse interpolator` goes the opposite direction,
from model-to-inner geometry. Currently, there is a choice between between the
:code:`AtlasInterpolator` and the :code:`UnstructuredInterpolator` implementations.
See :ref:`atlasInterp` and :ref:`oopsUnstrcInterp` below for more information.

Finally, the :code:`active variables` affected by the interpolation may be specified.
If none are provided, the full set of incoming increment variables will be interpolated.

.. _atlasInterp:

Atlas Interpolator
------------------

The **Atlas Interpolator** option is a wrapper around the interpolator provided by the
`atlas <https://github.com/ecmwf/atlas>`_ library from the ECMWF. This is a more
sophisticated option that utilizes knowledge of the atlas functionspaces underlying
the geometrical grids to provide a higher fidelity interpolation. The yaml snippet
below demonstrates an example configuration for the :code:`AtlasInterpolator`

.. code-block:: yaml

    forward interpolator:  
      local interpolator type: atlas interpolator
      interpolation method:
        type: cubedsphere-bilinear

The option set as the :code:`type` will depend on the geometry of the *source*
grid. So in the forward direction it will depend on the `FunctionSpace` of the
`inner geometry` and in the adjoint (inverse) direction it will depend on the
model grid's `FunctionSpace`.

.. warning::

  There is currently an issue in atlas which will cause this interpolator to hang
  when run in parallel.

.. _oopsUnstrcInterp:

Unstructured Interpolator
-------------------------

The **Unstructured Interpolator** option is a simpler implementation that performs
a barycentric interpolation on a triangulation of the *source* grid, and has some
additional features allowing it to be used with masks (e.g., land/sea masks) and
with integer/categorical fields. The yaml configuration for the
:code:`UnstructuredInterpolator` is relatively simple and shown below:

.. code-block:: yaml

    forward interpolator:
      local interpolator type: oops unstructured grid interpolator

