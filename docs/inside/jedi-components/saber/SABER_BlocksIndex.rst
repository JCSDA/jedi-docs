.. _SABER_blocks:

SABER Blocks
============

SABER blocks implement several key of operations that can be applied to an
:code:`oops::FieldSet3D` (wrapper for an :code:`atlas::FieldSet`) representing
an analysis increment (see :ref:`SABER-block-interface` below).

SABER includes blocks for generic/basic operations as well as blocks for more
specialized covariance models like BUMP, Spectral Filtering, Explicit Diffusion,
and GSI (Gridpoint Statistical Interpolation). See 
:ref:`SABER Block Index <SABER-block-index-start>` for more information on specific
blocks.

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

.. _SABER-block-interface:

SABER block interface
^^^^^^^^^^^^^^^^^^^^^

All SABER blocks have a constructor that takes as input arguments:

- a oops GeometryData,
- a list of outer variables,
- a configuration with elements on the SABER error covariance,
- a set of SABER block parameters (see next section),
- a background,
- a first guess

A single :code:`oops::FieldSet3D` is passed as argument for all the SABER block application
methods. Blocks are sometimes interoperable in any order, though, coordinate transformations
and interpolations are not generally interoperable. Both **Central** and **Outer** blocks
implement a :code:`multiply(oops::FieldSet3D)`, and see :ref:`central-interface` and 
:ref:`outer-interface` sections for more information.

Methods that are only used to calibrate an error covariance model are presented in
the :ref:`section on calibration <calibration>`.

Among the other methods, note that the :code:`read()` method should be used to read any
calibration data, i.e. block data that has been pre-calculated/fit (from an ensemble of
forecasts, explicitly pre-scribed, or otherwise computed).

.. _central-interface:

Central block interface
"""""""""""""""""""""""

SABER **Central** blocks inherit from the :code:`SaberCentralBlockBase` base class. The default
design outlined by the base class is for a specific (derived) central block to implement a set
of ``Sqrt`` methods:

- :code:`multiplySqrtAD()`: factorization of the block, in adjoint direction (transforms
  from analysis to control vector space).
- :code:`multiplySqrt()`: factorization of the block, in forward direction (transforms
  from control to analysis vector space).
- :code:`ctlVecSize()`: returns the size (length) of the control vector.
- :code:`randomCtlVec()`: creates a random control vector (a default implementation is
  provided - see warning).

.. warning::

   This default implementation of :code:`randomCtlVec` will NOT produce identical results across
   different MPI layouts. Such a property can only be obtained with an overriding implementation
   that is specific to each block.

If these methods are implemented in a derived central block, the base class provides the default
implementation of the following methods:

- :code:`multiply()`: applies the block (by first applying :code:`multiplySqrtAD()` then
  applying :code:`multiplySqrt()`) to an input FieldSet3D.
- :code:`randomize()`: fills a FieldSet3D with a centered Gaussian random sample with the
  covariance of the block (using the :code:`randomCtlVec()` and :code:`multiplySqrt()` methods).

However, depending on the intended use of the block the base class :code:`multiply()` and
:code:`randomize()`:can be directly overwritten in a derived class (instead of implementing
the full set of ``Sqrt`` methods). 

For multivariate assimilation (e.g., variable-dependent localization), multiple different central blocks
can be wrapped into a single 'meta'-central block. This 'meta'-central block (similar to the
:code:`SaberCentralBlockBase` base class) contains default implementations for some methods mentioned
above, which can be optionally overridden by a specific **Central** block own implementations. Please
note that the ``crossed`` multivariate strategy (see :ref:<documentation arriving soon>) CANNOT use
overridding :code:`multiply()` and :code:`randomize()`, and needs to use the default implementation
(via the ``Sqrt`` methods) of the 'meta'-central block instead. 


.. _outer-interface:

Outer block interface
"""""""""""""""""""""

SABER **Outer** blocks inherit from the :code:`SaberOuterBlockBase` base class which requires
a specific **Outer** block to implement the following methods:

- :code:`multiply()`: apply the block in the forward direction.
- :code:`multiplyAD`: apply the adjoint of the block to an input FieldSet3D.
- :code:`innerGeometryData()`: returns the :code:`oops::GeometryData` for the next block.
- :code:`innerVars()`: returns the :code:`oops::Variables` for the next block.

The last two methods :code:`innerGeometryData()` and :code:`innerVars()` help link blocks together in a
block-chain. They return the variables and geometry the block will pass to the following block in the adjoint
direction (:code:`multiplyAD()`); which are the same as the variables/geometry the block accepts in the
forward direction (:code:`multiply()`).

In some special cases (like block calibration), the following operations may also need to be implemented:

- :code:`leftInverseMultiply()`: apply the inverse of the block on the left of an input FieldSet3D.
- :code:`rightInverseMultiply()`: apply the inverse of the block on the right of an input FieldSet3D.


.. _SABER_blocks_parameters:

Base parameters
^^^^^^^^^^^^^^^

All SABER blocks share some common base parameters:

- :code:`saber block name`: the name of the SABER block. The only *required* parameter.
- :code:`active variables`: variables modified by the block. This should include at least the variables returned by the :code:`mandatoryActiveVars()` block method.
- The block's mode configuration (the two options are mutually exclusive):

  - :code:`read`: In this mode, a SABER block will be constructed and its training/fit parameters will be read from a file specified in the configuration. Cannot be used with :code:`calibration`.

  - :code:`calibration`: In this mode, a SABER block will be constructed and its training/fit parameters will be calculated at runtime. Cannot be used with :code:`read`.

- :code:`fieldsMetaData`: a configuration containing metadata such as a vertical coordinate or geographic mask. 
- :code:`skip inverse`: boolean flag to skip application of the inverse in calibration mode. Defaults is :code:`false`.
- :code:`state variables to inverse`: state variables to be interpolated at construction time from one functionSpace to another. To be used for interpolation blocks only, when the outer and inner Geometry differ. Default is no variables.

Other parameters related to testing are listed in :ref:`SABER block testing <saber_block_testing>`.

Most SABER blocks also have their own specific parameters. See the documentation of each specific block for more information.


.. _SABER-block-index-start:

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
