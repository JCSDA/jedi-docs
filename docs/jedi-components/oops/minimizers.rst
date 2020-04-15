.. _top-oops-minimizers:

Minimizers
===========

OOPS provides the following minimizers.

Primal Minimizers
-------------------

PCG : Preconditioned Conjugate Gradients
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

IPCG : Inexact-Preconditioned Conjugate Gradients
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Golub-Ye Inexact-Preconditioned Conjugate Gradients solver (G.H. Golub and Q. Ye 1999/00, SIAM J. Sci. Comput. 21(4) 1305-1320)

MINRES : minimal residual method
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Based on implementation following C. C. Paige and M. A. Saunders, 1975.

GMRESR : generalized minimal residual method
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
GMRESR solver (H.A. Van der Vorst and C. Vuik, 1994, Numerical Linear Algebra with Applications, 1(4), 369-386)

PLanczos : standard Preconditioned Lanczos algorithm
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Derber-Rosati Minimizers
------------------------

J. Derber and A. Rosati, 1989, J. Phys. Oceanog. 1333-1347

DRPCG : Derber-Rosati Preconditioned Conjugate Gradients
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
This solver is based on the standard Preconditioned Conjugate Gradients solver (G. H. Golub and C. F. Van Loan, Matrix Computations), and on the Derber and Rosati double PCG algorithm (Derber & Rosati). For details see S. Gurol, PhD Manuscript, 2013.

DRIPCG : Derber-Rosati IPCG Minimizer
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Derber-Rosati Inexact-Preconditioned Conjugate Gradients solver.
This solver is based on the Golub-Ye Inexact-Preconditioned Conjugate Gradients solver, and on the Derber and Rosati double PCG algorithm

DRGMRESR : Derber-Rosati GMRESR
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
This is a "double" version of GMRESR (Van der Vorst & Vuik) following Derber and Rosati (Derber & Rosati).

DRPLanczos : Derber-Rosati Preconditioned Lanczos
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Lanczos version of the DRPCG algorithm

DRPFOM : Preconditioned Full Orthogonal Method (FOM)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Generalization of the Lanczos method to the unsymmetric case.

Left B Preconditioned Minimizer
-------------------------------

LBGMRESR : Left B Preconditioned GMRESR solver
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Dual minimizers
----------------

RPCG : Augmented Restricted Preconditioned Conjugate Gradients
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Based on the algorithm proposed in Gratton and Tshimanga, QJRMS, 135: 1573-1585 (2009).

RPLanczos : Augmented Restricted Lanczos
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Lanczos version of RPCG. Based on the algorithm from Gurol, PhD Manuscript, 2013.

SaddlePoint minimizer
----------------------
