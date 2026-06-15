.. _block-chain-guide:

SABER Blockchain Guide
======================

At the source code level, SABER implements a :code:`ParametricBlockChain`,
an :code:`EnsembleBlockChain`, a :code:`OuterBlockChain`, and a
:code:`HybridBlockChain` which are all derived from the abstract
:code:`SaberBlockChainBase` base class. The base class sets up the base level
functionality all derived block chains must implement.

The interface set up by the base class includes these public methods:

- ``void randomize(oops::FieldSet4D &)``
- ``void multiply(oops::FieldSet4D &)``
- ``size_t ctlVecSize()``
- ``void multiplySqrt(const atlas::Field &, oops::FieldSet4D &, const size_t &)``
- ``void multiplySqrtAD(const oops::FieldSet4D &, atlas::Field &, const size_t &)``
- ``atlas::FunctionSpace & outerFunctionSpace()``
- ``oops::Variables & outerVariables()``

From a user's perspective, highly specific details of how the blockchains are
implemented may not be as interesting and important as how to set up their desired
**B** matrix model with SABER, but this section will provide some insight
into the (sometimes intricate and esoteric) structure of a **B** matrix yaml
configuration.

Static, ensemble, and hybrid are the standard _flavors_ of a **B** matrix model, and
their general outline is described in :ref:`blockchain-intro`.

<MORE TO COME LATER>