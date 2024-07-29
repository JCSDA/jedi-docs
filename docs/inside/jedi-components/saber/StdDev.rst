.. _StdDev:

StdDev
======

The **StdDev** SABER block is a diagonal matrix and therefore its own adjoint.
Since the block is auto-adjoint, it will be applied twice within a block chain
(once in the adjoint and once in the forward direction). This is analogous to
how the variance is the square of the standard deviation.

The block can be setup to read the diagonal coefficients from a model file, to
apply a constant scale factor, or both. 

An example configuration is shown below:

.. code-block:: yaml

    saber outer blocks:
  - saber block name: StdDev
    stddev scale factor: 2.0 # (optional) if given, must be greater than 0
    read:
      atlas file:
        filepath: <path to coefficients data>

Remember, the :code:`stddev scale factor` and model coefficients will be applied
twice. So in this case, setting the :code:`stddev scale factor: 2` will ultimately
result in the final B-matrix being scaled up by a factor of 4.
