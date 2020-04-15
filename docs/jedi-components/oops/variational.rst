.. _top-oops-var:

Variational data assimilation in OOPS
=====================================

Variational application is a generic application for running incremental variational data assimilation.

Variational minimization can be run with any of the :doc:`supported minimizers<minimizers>`.

It supports the following cost functions:

3D-Var
------

Uses 3D state in the update and in the observer. Does not require model TL/AD.

4D-Ens-Var
----------

4DEnVar is using ensembles for estimating ensemble background error covariances. Does not require model TL/AD.

4D-Var
------

4D-Var cost function name is reserved for the strong-constraint (perfect model) 4DVar. Requires model TL/AD.

Special case: 3D-FGAT
^^^^^^^^^^^^^^^^^^^^^

One could use 4D-Var cost function for running 3DVar-FGAT (first guess at appropriate time) by using an identity tangent-linear model. Note: the resulting analysis increment would be located at the beginning of the assimilation window.

4D-Var-Weak
-----------

This name is reserved for weak-constraint 4DVar. Two options are available:

* using model error forcing control variable

* using 4D model state control variable.

