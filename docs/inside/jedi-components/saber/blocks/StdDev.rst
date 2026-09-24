.. _StdDev:

StdDev
======

The **StdDev** SABER block is a diagonal matrix and therefore its own adjoint
(it is equal to its transpose). Since the block is auto-adjoint, there is no
difference between its application in the adjoint and forward directions, and
so it will apply its standard deviation values twice, reflecting how variance
is the square of the standard deviation.

The block can be setup several ways. Primarily, it is used to read-in the diagonal
coefficients (standard deviations) from a model file. It also can (optionally) apply
a scaling factor to all fields either in combination with a model file-read, or as a
standalone scaling factor without a file-read. An example with both a file-read and
a global scaling is below:

.. code-block:: yaml

    saber outer blocks:
  - saber block name: StdDev
    scale factor: 2.0 # (optional) if given, must be greater than 0
    read:
      atlas file:
        filepath: <path to coefficients data>

Remember, the :code:`scale factor` and coefficients from file will be applied twice.

An alternative mode -- which is mostly used for testing, demonstration, or tutorials -- for
the block is to apply distinct standard deviations to each control variable in your background
error model. In this mode, the block does not use :code:`read:` and each entry under
:code:`standard deviations:` must define a :code:`stddev` value.

.. code-block:: yaml

    saber outer blocks:
  - saber block name: StdDev
    standard deviations:
    - variable: <control_var_1>
      stddev: 2.0
    - variable: <control_var_2>
      stddev: 5.0

As in the other mode, each :code:`stddev` value will be applied twice within a block-chain.

It is also possible to combine a file-read with variable-specific scaling in the same
:code:`StdDev` block. In that case, the coefficients are first read from file and then each
variable listed under :code:`standard deviations:` is additionally multiplied by its own
:code:`scale factor`.

.. code-block:: yaml

    saber outer blocks:
  - saber block name: StdDev
    read:
      atlas file:
        filepath: <path to coefficients data>
    standard deviations:
    - variable: <control_var_1>
      scale factor: 2.0
    - variable: <control_var_2>
      scale factor: 0.5

When :code:`read:` is present, entries under :code:`standard deviations:` must use
:code:`scale factor`, not :code:`stddev`. When :code:`read:` is absent, entries under
:code:`standard deviations:` must use :code:`stddev`, not :code:`scale factor`.
