.. _block-chain-guide:

SABER Blockchain Guide
======================

From a user's perspective, highly specific details of how the blockchains are
implemented may not be as interesting or important as how to set up their desired
**B** matrix model with SABER, but this section will provide some insight
into the (sometimes intricate) structure of a **B** matrix yaml configuration.

Mathematical Context
--------------------

In SABER, a block chain contains the chain of blocks representing a **B**-matrix
model (or a component of a hybrid **B**-matrix which could stand alone as a
fully-functional **B**-matrix).

At the source code level, the abstract :code:`SaberBlockChainBase` class
sets up the base level functionality all derived block chains must implement.

The :code:`SaberParametricBlockChain`, :code:`SaberEnsembleBlockChain`, and the
:code:`SaberHybridBlockChain`, which all are derived from the abstract base class,
provide implementations of the following methods set up by the :code:`SaberBlockChainBase`
base class interface:

- ``void randomize(oops::FieldSet4D &)``
- ``void multiply(oops::FieldSet4D &)``
- ``size_t ctlVecSize()``
- ``void multiplySqrt(const atlas::Field &, oops::FieldSet4D &, const size_t &)``
- ``void multiplySqrtAD(const oops::FieldSet4D &, atlas::Field &, const size_t &)``
- ``atlas::FunctionSpace & outerFunctionSpace()``
- ``oops::Variables & outerVariables()``

For mathematical context behind these methods, a **B**-matrix is a covariance matrix,
so it is positive definite (all it's eigenvalues are positive). Positive definite matrixes can
be factored into the form:

.. math::

  B = UU^T

Though not strictly speaking a square root, the :math:`U` matrix is called the square root of **B** [#]_.

In the minimization of a variational cost function, the **B** matrix
gets applied to an 'increment' of analysis variables (coming from a model).

If we think of the application of the **B**-matrix in the factored form of first applying :math:`U^T` then :math:`U`,
the :math:`U` matrices represent linear transformations from the model/analysis
variable space to a **control vector** space. First for :math:`U^T`:

.. math::

  v = U^T \cdot \delta x

where :math:`\delta x` is an increment vector in the model/analysis variable space, and :math:`v` is
the control vector. The :math:`U` matrix then transforms from the control vector space back into
the model/analysis variable space.

With this context, the :code:`SaberBlockChainBase` interface can start making more sense. The
:code:`randomize()` method produces a random increment according to the **B**-matrix model contained
within the Blockchain, which is used to randomly produce an ensemble representation of **B**.
The :code:`multiply()` method mutliplies an increment (as an :code:`oops::FieldSet4D`) by the Blockchain,
which will occur in the cost-fuction minimization or in a dirac test. The :code:`ctlVecSize()` is the size
of the intermediate (control) vector :math:`v` which is the form an increment vector takes in the very
middle of a Blockchain.

The :code:`multiplySqrt()` and :code:`multiplySqrtAD()` represent the :math:`U` and :math:`U^T` matrix
transformations. The :code:`outerFunctionSpace()` method returns the :code:`atlas::FunctionSpace`
containing the model/analysis geometry and grid point connectivity information, and the
:code:`outerVariables()` is a list of the model/analysis variables passed into the **B**-matrix model.

There is also a fourth, :code:`SaberOuterBlockChain` class, but it does not derive from the
abstract :code:`SaberBlockChainBase` class. It is an auxiliary container/wrapper
used by the three other block chain classes to hold the set of Outer SABER blocks
that surround a Central block.

.. [#] This factorization is not generally unique, which ultimately means we have some flexibility in creating our **B**-matrix model.

Setting up a B-matrix with Blockchains
--------------------------------------

Static, ensemble, and hybrid are the standard *flavors* of a **B** matrix model, and
their general outline is described in :ref:`blockchain-intro`.

<MORE TO COME LATER>
