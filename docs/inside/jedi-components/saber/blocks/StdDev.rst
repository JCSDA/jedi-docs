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
    stddev scale factor: 2.0 # (optional) if given, must be greater than 0
    read:
      atlas file:
        filepath: <path to coefficients data>

Remember, the :code:`stddev scale factor` and coefficients from file will be applied twice.

An alternative mode -- which is mostly used for testing, demonstration, or tutorials -- for
the block is to apply distinct standard deviations to each control variable in your background
error model. This :code:`standard deviations:` key **WILL NOT** work with the :code:`read:` key.
If both keys are present, the coefficients from the file will be read, but the :code:`stddev`
values will **NOT** be applied.

.. code-block:: yaml

    saber outer blocks:
  - saber block name: StdDev
    standard deviations: # DO NOT include `read:` key with this
    - variable: <control_var_1>
      stddev: 2.0
    - variable: <control_var_2>
      stddev: 5.0

As in the other mode, each :code:`stddev` value will be applied twice within a block-chain.
For the unusual case in which a user would want to apply both coefficients from a model file
and variable-specific standard deviations, two separate :code:`StdDev` blocks can be used in
a single block-chain.
