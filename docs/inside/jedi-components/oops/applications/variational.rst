.. _top-oops-var:

Variational data assimilation in OOPS
=====================================

The variational application is a generic application for running incremental variational data assimilation.

Supported cost functions and minimizers are described below.

Supported cost functions
------------------------

3D-Var
^^^^^^

Uses 3D state in the update and in the observer. Does not require model TL/AD.

4D-Ens-Var
^^^^^^^^^^

4DEnVar uses ensembles for estimating ensemble background error covariances. Does not require model TL/AD.

4D-Var
^^^^^^

The 4D-Var cost function name is reserved for the strong-constraint (perfect model) 4DVar. Requires model TL/AD.

.. note::

   Special case: 3D-FGAT. One could use 4D-Var cost function for running 3DVar-FGAT (first guess at appropriate time) by using an identity tangent-linear model. The resulting analysis increment would be located at the beginning of the assimilation window.

4D-Var-Weak
^^^^^^^^^^^

This name is reserved for weak-constraint 4DVar. Two options are available:

* using model error forcing control variable

* using 4D model state control variable.


Any of the above cost functions could be run with any of the supported minimizers:

Supported minimizers
--------------------

Primal Minimizers
^^^^^^^^^^^^^^^^^

* PCG : Preconditioned Conjugate Gradients solver
* IPCG : Inexact-Preconditioned Conjugate Gradients (G.H. Golub and Q. Ye 1999/00, SIAM J. Sci. Comput. 21(4) 1305-1320)
* MINRES : minimal residual method, based on implementation following C. C. Paige and M. A. Saunders, 1975.
* GMRESR : generalized minimal residual method (H.A. Van der Vorst and C. Vuik, 1994, Numerical Linear Algebra with Applications, 1(4), 369-386)
* PLanczos : standard Preconditioned Lanczos algorithm

Derber-Rosati Minimizers
^^^^^^^^^^^^^^^^^^^^^^^^

All the minimizers in this section are based on J. Derber and A. Rosati, 1989, J. Phys. Oceanog. 1333-1347

* DRPCG : Derber-Rosati Preconditioned Conjugate Gradients. For details see S. Gurol, PhD Manuscript, 2013.
* DRIPCG : Derber-Rosati IPCG Minimizer
* DRGMRESR : Derber-Rosati GMRESR: "double" version of GMRESR (Van der Vorst & Vuik) following Derber and Rosati.
* DRPLanczos : Derber-Rosati Preconditioned Lanczos
* DRPFOM : Preconditioned Full Orthogonal Method (FOM): generalization of the Lanczos method to the unsymmetric case.

Left B Preconditioned Minimizer
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

* LBGMRESR : Left B Preconditioned GMRESR solver

Dual minimizers
^^^^^^^^^^^^^^^

* RPCG : Augmented Restricted Preconditioned Conjugate Gradients. Based on the algorithm proposed in Gratton and Tshimanga, QJRMS, 135: 1573-1585 (2009).
* RPLanczos : Augmented Restricted Lanczos. Lanczos version of RPCG. Based on the algorithm from Gurol, PhD Manuscript, 2013.

SaddlePoint minimizer
^^^^^^^^^^^^^^^^^^^^^

Variational application yaml structure
--------------------------------------

The following block of code gives the main components of the yaml file needed to run a 3d-var:

.. _yaml-da:

.. code-block:: yaml

    ---
    cost function:
      cost type: #one of the supported cost functions
      window begin: #beginning of the data assimilation window
      window length: #length of the data assimilation window
      analysis variables: #variables used for the analysis
      geometry:
        #geometry of the model
      background:
        #background file
      background error:
        #one of the supported background error covariance matrix
      observations:
        obs perturbations: #switch for observation perturbations (default false)
        observers:
          #list of observation files
    variational:
      minimizer:
        algorithm: #one of the supported minimizers
      iterations: #each item of this list defines an outer loop
      - diagnostics: #(optional)
          departures: ombg #will save 'observations - H(background)' in the output file
        gradient norm reduction: #target norm for the minimization of the gradient
        ninner: #maximum number of iterations in this outer loop
        geometry:
          #geometry of the model
      - #another outer loop
        [...]
    final:
      diagnostics: #(optional)
        departures: oman #will save 'observations - H(analysis)' in the output file
    output:
      #path, file name, ... to save the analysis
