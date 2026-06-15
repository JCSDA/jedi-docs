.. _torchBalance:

Torch Balance
=============

Overview
--------

``TorchBalance`` is a SABER outer block that implements a variable balance operator
driven by Jacobians provided by TorchScript models. It is designed to introduce
cross-variable correlations into the background error covariance — for example,
linking sea surface temperature to air temperature and water vapour. The models
can be anything that can be compiled to TorchScript: analytical functions, physics
parameterisations, machine learning emulators, or any combination thereof.

The operator applies the linearised balance transform :math:`K`, whose off-diagonal
blocks are assembled from one or more TorchScript models. Each model provides the
cross-variable Jacobians of one output variable with respect to a set of other input
variables; the diagonal blocks of :math:`K` are implicitly identity since no model
maps a variable to itself. The transform is applied **independently at each
horizontal grid node**: no spatial cross-correlations are introduced by this block.

**Requires PyTorch (minimum) v2.8.0 and up to (maximum) v2.10.0**

.. note::

   **Current limitation — single-level Jacobians only.**
   The initial motivation for ``TorchBalance`` is coupled atmosphere–ocean–ice
   background error modelling, where the cross-variable relationships of interest
   (e.g. SST ↔ near-surface air temperature) act between single model levels.
   Consequently, each TorchScript model is currently required to return a
   single-level Jacobian (the ``output_levels`` attribute must contain exactly
   one entry). Support for multi-level Jacobians may be added in a future release.

Jacobian field naming convention
---------------------------------

Internally, each Jacobian is stored as an Atlas field named according to the pattern:

.. code-block:: none

   d{output_variable}_div_d{input_variable}

For example, the Jacobian of ``air_temperature`` with respect to
``sea_water_potential_temperature`` is stored as:

.. code-block:: none

   dair_temperature_div_dsea_water_potential_temperature

This naming convention is used throughout the C++ code
(``parseJacobianName``, ``getJacobianLevels``) and must be matched by the emulator
configuration.

TorchScript model interface
---------------------------

Each model must be a TorchScript file (``.ts``) that exposes the following
attributes and method:

* ``input_names`` — list of input variable names (strings)
* ``input_levels`` — list of level indices for each input variable (ints)
* ``output_names`` — list of output variable names (must have exactly one entry)
* ``output_levels`` — list of level indices for the output variable (ints)
* ``jac_physical(inputs, mask)`` — returns the Jacobian tensor of shape
  ``[nnodes, 1, num_inputs]``, where ``jac[i, 0, j]`` is
  :math:`\partial \text{output} / \partial \text{input}_j` at node ``i``

The ``mask`` argument is always provided as a ``[nnodes, 1]`` float tensor;
pass a tensor of ones for no masking, or provide a field-derived mask to suppress
Jacobian contributions (e.g. over land for a sea surface model).

A reference Python script showing how to create a conforming TorchScript model
(using a simple linear function as an example) is provided at
:code:`saber/src/saber/torchbalance/create_test_emulator.py`.

YAML configuration
------------------

The block is configured under ``saber outer blocks`` with
``saber block name: TorchBalance``. The required parameters are:

.. list-table::
   :widths: 25 10 65
   :header-rows: 1

   * - Parameter
     - Required
     - Description
   * - ``surface emulators``
     - Yes
     - List of TorchScript model configurations (see below)
   * - ``save jacobians``
     - No
     - If ``true``, write the assembled Jacobian FieldSet to disk for debugging
       (default: ``false``)

Each entry in ``surface emulators`` accepts:

.. list-table::
   :widths: 25 10 65
   :header-rows: 1

   * - Parameter
     - Required
     - Description
   * - ``name``
     - Yes
     - Name of the output variable provided by this model
   * - ``path``
     - Yes
     - Path to the TorchScript model file (``.ts``)
   * - ``jacobian wrt``
     - Yes
     - List of input variable names the Jacobian is computed with respect to
   * - ``jacobian masking.variable``
     - No
     - Name of a background field to use as a mask (e.g. ``sea_area_fraction``)
   * - ``jacobian masking.level``
     - No
     - Level index of the masking variable (default: ``0``)

Example configuration
---------------------

The following example configures two TorchScript models: one providing the Jacobian of
``sea_water_potential_temperature`` with respect to ``air_temperature`` and
``water_vapor_mixing_ratio_wrt_moist_air``, and another providing the Jacobian of
``air_temperature`` with respect to ``sea_water_potential_temperature`` and
``water_vapor_mixing_ratio_wrt_moist_air``:

.. code-block:: yaml

   background error:
     covariance model: SABER
     adjoint test: true
     saber outer blocks:
     - saber block name: TorchBalance
       save jacobians: false
       surface emulators:
       - name: sea_water_potential_temperature
         path: ./testdata/sst_emulator.ts
         jacobian wrt:
         - air_temperature
         - water_vapor_mixing_ratio_wrt_moist_air
       - name: air_temperature
         path: ./testdata/air_temperature_emulator.ts
         jacobian wrt:
         - sea_water_potential_temperature
         - water_vapor_mixing_ratio_wrt_moist_air
     saber central block:
       saber block name: ID

With Jacobian values :math:`\partial T / \partial \text{SST} = 0.3`,
:math:`\partial T / \partial q = 0.2`, :math:`\partial \text{SST} / \partial T = 0.4`,
:math:`\partial \text{SST} / \partial q = 0.1`, the full :math:`K` matrix has the
structure:

.. code-block:: none

                          sst    qv    tair
     sst              [   I    0.1   0.4  ]
     qv               [   0     I     0   ]
     tair             [ 0.3   0.2    I    ]

Building SABER with PyTorch
---------------------------

Building SABER with PyTorch enabled requires downloading the LibTorch C++ library. On
a linux machine run this command:

.. code-block:: bash

    wget https://download.pytorch.org/libtorch/cpu/libtorch-shared-with-deps-2.8.0%2Bcpu.zip


Then un-zip the download in a logical location like in a new :code:`libs` directory in your :code:`JEDI_ROOT`

.. code-block:: bash

    unzip libtorch-shared-with-deps-2.8.0%2Bcpu.zip


For good measure, export a :code:`Torch_ROOT` environment variable. Then, when you :code:`ecbuild`
your jedi-bundle, include a :code:`Torch_ROOT` build flag:

.. code-block:: bash

    export Torch_ROOT=$JEDI_ROOT/libs/libtorch  # or wherever the library was unzipped
    cd $JEDI_BUILD
    ecbuild $JEDI_SRC -DTorch_ROOT=$JEDI_ROOT/libs/libtorch

