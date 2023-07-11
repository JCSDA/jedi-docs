.. _saber_testing:

SABER block testing
===================

Each outer SABER block can be tested for adjoint testing and inverse testing.
Each central SABER block can be tested for self-adjointness.
These tests are run during the construction of the SABER error covariance, after initialization of each SABER block.
Tests only run if activated in the yaml configuration at the error covariance level.

SABER Error Covariance parameters used for testing
--------------------------------------------------

- :code:`adjoint test`: boolean flag to run adjoint test on all SABER blocks in the error covariance. Default is false.
- :code:`adjoint tolerance`: Relative tolerance for adjoint test. Default is 1e-12.
- :code:`inverse test`: boolean flag to run inverse tests (inner and outer, see below) on all SABER block. Default is false.
- :code:`inverse tolerance`: Relative tolerance for inverse test. Default is 1e-12.

SABER block parameters used for testing
----------------------------------------

In general, these parameters at block level should not be used unless one knows precisely why the tests don't pass with the parameters specified at the covariance level.

- :code:`adjoint tolerance`: Overrides for this SABER block the adjoint tolerance specified at the error covariance level. Only relevant if the :code:`adjoint test` flag has been activated at the error covariance level. 
- :code:`skip inverse test`: boolean flag to skip the inverse test. Only relevant if the :code:`inverse test` flag has been activated at the error covariance level. Default is :code:`false`.
- :code:`inner inverse tolerance`: the tolerance of the inner inverse test UT (Ux) == (Ux), where U is the :code:`multiply()` operator and T is the :code:`leftInverseMultiply()` operator. If provided, overrides the inverse tolerance prescribed at the error covariance level. 
- :code:`outer inverse tolerance`: the tolerance of the outer inverse test TU (Tx) == (Tx), where U is the :code:`multiply()` operator and T is the :code:`leftInverseMultiply()` operator. If provided, overrides the inverse tolerance prescribed at the error covariance level. 
- :code:`inner variables to compare`: list of variables that are compared during **outer** inverse test TU (Tx) == (Tx). Default is all inner active variables.  
- :code:`outer variables to compare`: list of variables that are compared during **inner** inverse test TU (Tx) == (Tx). Default is all outer active variables. 

Example yaml configuration
--------------------------
We detail here an example testing configuration.
The tests actually run for each block and the tolerance used are shown in commented text:

.. code-block:: yaml

  covariance model: SABER
  adjoint test: true
  inverse test: true
  adjoint tolerance: 1e-13
  saber central block:
    saber block name: spectral covariance
    adjoint tolerance: 1e-12
    {...}
    # Self-adjoint test runs with 1e-12 relative tolerance.
  saber outer blocks:
  - saber block name: spectral to gauss
    outer inverse tolerance: 1e-8
    {...}
    # Adjoint test runs with 1e-13 relative tolerance.
    # Inner inverse test runs with 1e-12 absolute tolerance.
    # Outer inverse test runs with 1e-8 absolute tolerance.
  - saber block name: gauss winds to geostrophic pressure
    skip inverse test: true
    # Adjoint test runs with 1-e13 relative tolerance
  - saber block name: mo_hydrostatic_exner
    outer inverse tolerance: 1e-9
    inner variables to compare: 
    - unbalanced_pressure_levels_minus_one
    - geostrophic_pressure_levels_minus_one
    {...}
    # Adjoint test runs with 1-e13 relative tolerance
    # Inner inverse test runs with 1e-12 absolute tolerance.
    # Outer inverse test runs with 1e-9 absolute tolerance and 
    #                   comparing the two above variables only. 



Custom inverse testing
----------------------

Each outer SABER block inherits utility methods from the outer block base class which are used for inverse testing: :code:`generateInnerFieldSet`, :code:`generateOuterFieldSet` and :code:`compareFieldSets`. 
These methods have a default implementation that can be overriden for each block if need be:

- :code:`generateInnerFieldSet`: the default is to create random normal fields with zero mean and unit variance. 
  In some cases, one may want to have smoother fields with some correlation structure (e.g. for interpolation blocks), or fields with values prescribed within some bounds.
- :code:`generateOuterFieldSet`: same default implementation as `generateOuterFieldSet`, but is used to generate random fields on the outer geometry. 
- :code:`compareFieldSets`: the default implementation is to compare all variables in the given Atlas FieldSets, using the given tolerance as an *absolute* tolerance. 