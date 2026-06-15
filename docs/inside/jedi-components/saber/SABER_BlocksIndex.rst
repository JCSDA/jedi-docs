.. _SABER_blocks:

SABER Blocks
============

SABER blocks implement several key of operations that can be applied to an
:code:`oops::FieldSet3D` (wrapper for an :code:`atlas::FieldSet`) representing
an analysis increment (see :ref:`SABER-block-interface` below).

SABER includes blocks for generic/basic operations as well as blocks for more
specialized covariance models like BUMP, Spectral Filtering, Explicit Diffusion,
and GSI (Gridpoint Statistical Interpolation).

Central vs Outer SABER Blocks
-----------------------------

SABER blocks are either a **Central** block or an **Outer** block, though some blocks
(e.g. correlation operators which can be used in ensemble filtering) support
implementations as both. A typical block chain may have at most one **Central** block,
but may have many **Outer** blocks (see :eq:`eq-modelB`). The most important operations
performed by a Block are the :code:`multiply()`/:code:`multiplyAD()`, and blocks are
generally named for what they do in these methods.

A **Central** block represents a correlation operator/matrix. **Outer** blocks could
represent a number of mathematical operations such as interpolation, scaling, or
coordinate transformations. They may also perform utility operations (which leaves
a fieldset unchanged) such as writing the fieldset passed to the block.

A key distinction between **Central** and **Outer** blocks is that **Central**
blocks have no :code:`multiplyAD()`. A **Central** block is applied once, where
as **Outer** blocks are typically applied first as and adjoint, then later using
the forward :code:`multiply()`.

Generic blocks
--------------

.. toctree::
   :maxdepth: 2
   :titlesonly:

   ID: identity operator<blocks/ID>
   StdDev: standard-deviation application<blocks/StdDev>
   ShadowLevels: shadow levels convolution<blocks/ShadowLevels>
   DuplicateVariables: outer block to duplicate one variable into others<blocks/DuplicateVariables>
   Write Fields<blocks/writeFields>
   Write Variances (calibration diagnostic)<blocks/calibration_writeVariances>

Interpolation blocks
--------------------

.. toctree::
   :maxdepth: 2
   :titlesonly:

   Interpolation blocks<blocks/Interpolations>

BUMP blocks
-----------

.. toctree::
   :maxdepth: 2
   :titlesonly:

   BUMP: Background error on an Unstructured Mesh Package<blocks/BUMP>


Spectral blocks
---------------

.. toctree::
   :maxdepth: 2
   :titlesonly:

   SPECTRALB: spectral covariance/correlation<blocks/SPECTRALB>


Diffusion blocks
----------------

.. toctree::
   :maxdepth: 2
   :titlesonly:

   Explicit Diffusion<blocks/explicitDiffusion>


ML Balance Operator
-------------------

.. toctree::
   :maxdepth: 2
   :titlesonly:

   Torch Balance<blocks/torchBalance>


GSI blocks
----------

.. toctree::
   :maxdepth: 2
   :titlesonly:

   GSI: interface to the GSI covariance<blocks/GSI>


UK Met Office specific blocks
-----------------------------

.. toctree::
   :maxdepth: 2
   :titlesonly:

   UKMO-specfic saber blocks<blocks/UKMO>


.. _SABER-block-interface:

Interfaces
----------

All SABER blocks have a constructor that takes as input arguments:

- a oops GeometryData,
- a list of outer variables,
- a configuration with elements on the SABER error covariance,
- a set of SABER block parameters (see next section),
- a background,
- a first guess

A single Atlas FieldSet is passed as argument for all the SABER block application methods.
Blocks are sometimes interoperable in any order. Coordinate transformations
and interpolations, however, are not generally interoperable. SABER blocks will implement each of
the four following methods (except central blocks which will only implement the first two methods):

- :code:`randomize`: Fill the input Atlas FieldSet with a random vector of centered Gaussian distribution of unit variance and multiply by the "square-root" of the block. For central blocks only.
- :code:`multiply`: apply the block to an input Atlas FieldSet. Required for all blocks.
- :code:`multiplyAD`: apply the adjoint of the block to an input Atlas FieldSet. For outer blocks only.
- :code:`leftInverseMultiply`: apply the inverse of the block on the left of an input Atlas FieldSet. For outer blocks only.
- :code:`rightInverseMultiply`: apply the inverse of the block on the right of an input Atlas FieldSet. For outer blocks only.

Other methods are used to glue the blocks together when building a SABER error covariance, from the outermost block to the innermost:

- :code:`innerGeometryData()`: returns the oops GeometryData for the next block. For outer blocks only.
- :code:`innerVars()`: returns the oops Variables for the next block. For outer blocks only.


Methods that are only used to calibrate an error covariance model are presented in the :ref:`section on calibration <calibration>`.

Among the other methods, note that the :code:`read()` method should be used to read any calibration data, i.e. block data that can be estimated from an ensemble of forecasts.

Base parameters
^^^^^^^^^^^^^^^
.. _SABER_blocks_parameters:

All SABER blocks share some common base parameters:

- :code:`saber block name`: the name of the SABER block. The only *required* parameter.
- :code:`active variables`: variables modified by the block. This should include at least the variables returned by the :code:`mandatoryActiveVars()` block method.
- The block's mode configuration (the two options are mutually exclusive):

  - :code:`read`: a configuration to be used by the block at construction time. If a configuration is given, the block is used in read mode. Cannot be used with :code:`calibration`.

  - :code:`calibration`: a configuration to be used by the block at construction time. If a configuration is given, the block is used in calibration mode. Cannot be used with :code:`read`.

- :code:`fieldsMetaData`: a configuration containing metadata such as a vertical coordinate or geographic mask. 
- :code:`skip inverse`: boolean flag to skip application of the inverse in calibration mode. Defaults is :code:`false`.
- :code:`state variables to inverse`: state variables to be interpolated at construction time from one functionSpace to another. To be used for interpolation blocks only, when the outer and inner Geometry differ. Default is no variables.

Other parameters related to testing are listed in :ref:`SABER block testing <saber_block_testing>`.

Most SABER blocks also have their own specific parameters. See the documentation of each specific block for more information.
