.. _SABER_blocks:

SABER blocks
============

Specification
^^^^^^^^^^^^^
A SABER block encapsulates a linear operator that can be used to model covariance or localization matrices.
A sequence of SABER blocks can be specified in the yaml configuration file:

  .. code-block:: yaml

    covariance model: SABER
    saber central block:
      {saber block 1
      ...}
    saber outer blocks:
    - {saber block 2
      ...}
    - ...
    - {saber block N
      ...}

First, the adjoints of the outer blocks are applied in reverse order. 
Then, the central block, which is considered as auto-adjoint, is applied.
Then, the direct outer blocks are applied in forward order:

.. image:: fig/figure_saber_blocks_2.jpg
   :align: center
   :scale: 20%

Each covariance model should have at least a central block. 
The simplest SABER covariance model is thus the Identity matrix:

.. code-block:: yaml

  covariance model: SABER
  saber central block: 
  - saber block name: ID


The examples above are for a covariance matrix, but the behavior is identical for a localization matrix:

  .. code-block:: yaml

    covariance model: ensemble
    localization:
       localization method: SABER
       saber central block:
         {...}
       saber outer blocks:
         {...}

In some specific cases, a chain of SABER blocks can be nested within a SABER block. 
For instance, the :code:`Ensemble` SABER block uses a localization matrix prescribed as follows:

  .. code-block:: yaml

    covariance model: SABER
    saber central block:
      block name: Ensemble      
      localization:
        saber central block:
          {...}
        saber outer blocks:
          {...}
    saber outer blocks:
      {...}
        
  
The list of available SABER blocks can be found in :ref:`SABER components <SABER_components>`.

Interfaces
^^^^^^^^^^
All SABER blocks have a constructor that takes as input arguments:

- a oops GeometryData,
- a list of outer variables,
- a configuration with elements on the SABER error covariance,
- a set of SABER block parameters (see next section),
- a background,
- a first guess,
- a valid time.

A single Atlas FieldSet is passed as argument for all the SABER block application methods, which makes them interoperable in any order. These four methods are:

- :code:`randomize`: Fill the input Atlas FieldSet with a a random vector of centered Gaussian distribution of unit variance and multiply by the "square-root" of the block. For central blocks only. 
- :code:`multiply`: apply the block to an input Atlas FieldSet. Required for all blocks.
- :code:`multiplyAD`: apply the adjoint of the block to an input Atlas FieldSet. For outer blocks only.
- :code:`leftInverseMultiply`: apply the inverse of the block to an input Atlas FieldSet. For outer blocks only.

Other methods are used to glue the blocks together when building a SABER error covariance, from the outermost block to the innermost: 

- :code:`innerGeometryData()`: returns the oops GeometryData for the next block. For outer blocks only. 
- :code:`innerVars()`: returns the oops Variables for the next block. For outer blocks only. 


Methods that are only used to calibrate an error covariance model are presented in the :ref:`section on calibration <calibration>`. 

Among the other methods, note that the :code:`read()` method should be used to read any calibration data, i.e. block data that can be estimated from an ensemble of forecasts.

Base parameters
^^^^^^^^^^^^^^^
.. _SABER_blocks_parameters:

All SABER blocks share some common base parameters, and have their own specific parameters (see :ref:`SABER components <SABER_components>`). These base parameters are:

- :code:`saber block name`: the name of the SABER block. Only parameter that is not optional.
- :code:`active variables`: variables modified by the block. This should include at least the variables returned by the :code:`mandatoryActiveVars()` block method.
- :code:`read`: a configuration to be used by the block at construction time. If a configuration is given, the block is used in read mode. Cannot be used with :code:`calibration`.
- :code:`calibration`: a configuration to be used by the block at construction time. If a configuration is given, the block is used in calibration mode. Cannot be used with :code:`read`.
- :code:`ensemble transform`: transform parameters, for the :code:`Ensemble` block only.
- :code:`localization`: localization parameters, for the :code:`Ensemble` block only.
- :code:`skip inverse`: boolean flag to skip application of the inverse in calibration mode. Defaults is :code:`false`.
- :code:`state variables to inverse`: state variables to be interpolated at construction time from one functionSpace to another. To be used for interpolation blocks only, when the outer and inner Geometry differ. Default is no variables.

Other parameters related to testing are listed in :ref:`SABER block testing <saber_testing>`.
