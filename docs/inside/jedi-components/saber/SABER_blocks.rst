.. _SABER_blocks:

SABER blocks
============

Specification
^^^^^^^^^^^^^
A SABER block encapsulates a linear operator that can be used to model covariance or localization matrices. For covariance matrices, a sequence of SABER blocks can be specified in the yaml configuration file:

  .. code-block:: yaml

    covariance model: SABER
    saber blocks:
    - {saber block 1
      ...}
    - {saber block 2
      ...}
    - ...
    - {saber block N
      ...}

First, the adjoints of the blocks are applied in reverse order. Then, the direct blocks are applied in forward order:

.. image:: fig/figure_saber_blocks_1.jpg
   :align: center
   :scale: 20%

If the first block has the key :code:`saber central block` activated, then it is considered as auto-adjoint:

.. image:: fig/figure_saber_blocks_2.jpg
   :align: center
   :scale: 20%

For localization matrices, a single SABER block is specified:

  .. code-block:: yaml

    covariance model: ensemble
    localization:
       localization method: SABER
       saber block:
         {saber block
         ...}

The list of available SABER blocks can be found in :ref:`SABER components <SABER_components>`.

Interfaces
^^^^^^^^^^
All SABER blocks have a constructor that takes as input arguments:

- a geometry,
- a set of parameters (see next section),
- a background,
- a first guess.

A single ATLAS FieldSet is passed as argument for all the SABER block methods, which makes them interoperable in any order. The five methods are:

- :code:`randomize`: apply the square-root of the block to a random vector of centered Gaussian distribution of unit variance. Required for all blocks.
- :code:`multiply`: apply the block to an input ATLAS FieldSet. Required for all blocks.
- :code:`inverseMultiply`: apply the inverse of the block to an input ATLAS FieldSet. Not required if the :code:`saber central block` and :code:`iterative inverse` keys are activated.
- :code:`multiplyAD`: apply the adjoint of the block to an input ATLAS FieldSet. Not required if the :code:`saber central block` key is activated.
- :code:`inverseMultiplyAD`: apply the adjoint of the inverse of the block to an input ATLAS FieldSet. Not required if the :code:`saber central block` key is activated.

Base parameters
^^^^^^^^^^^^^^^
.. _SABER_blocks_parameters:

All SABER blocks share some common base parameters, and have their own specific parameters (see :ref:`SABER components <SABER_components>`). These base parameters are:

- :code:`saber block name`: the name of the SABER block.
- :code:`input variables`: input variables.
- :code:`output variables`: output variables.
- :code:`active variables` [optional]: active variables modified by the block. This should be a subset of the input variables, the default value is the input variables.
- :code:`saber central block` [optional]: boolean to use this block as auto-adjoint (for the first block only). Default is :code:`false`.
- :code:`iterative inverse` [optional]: boolean to use an iterative solver to apply the inverse of this block (if :code:`saber central block` is also activated).  Default is :code:`false`.
