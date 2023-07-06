.. _saber_testing:

SABER block testing
===================

Each outer SABER block can be tested for adjoint testing and inverse testing.
Each central SABER block can be tested for self-adjointness.
These blocks are run during the construction of the SABER error covariance, after initialization of each SABER block.

SABER block parameters used for testing
----------------------------------------


- :code:`adjoint tolerance`: the tolerance of the adjoint test. Only relevant if the :code:`adjoint test` flag has been activated at the error covariance level. Default is 1e-12. 
- :code:`skip inverse test`: boolean flag to skip the inverse test. Only relevant if the :code:`inverse test` flag has been activated at the error covariance level. Default is :code:`false`.
- :code:`inner inverse tolerance`: the tolerance of the inner inverse test UT (Ux) == (Ux), where U is the :code:`multiply()` operator and T is the :code:`leftInverseMultiply()` operator. Default is 1e-12.
- :code:`outer inverse tolerance`: the tolerance of the outer inverse test TU (Tx) == (Tx), where U is the :code:`multiply()` operator and T is the :code:`leftInverseMultiply()` operator. Default is 1e-12.
- :code:`inner variables to compare`: list of variables that are compared during **outer** inverse test TU (Tx) == (Tx). Default is all inner active variables.  
- :code:`outer variables to compare`: list of variables that are compared during **inner** inverse test TU (Tx) == (Tx). Default is all outer active variables. 

Custom inverse testing
----------------------

Each outer SABER block inherits utility methods from the outer block base class which are used for inverse testing: :code:`generateInnerFieldSet`, :code:`generateOuterFieldSet` and :code:`compareFieldSets`. 
These methods have a default implementation that can be overriden for each block if need be. 