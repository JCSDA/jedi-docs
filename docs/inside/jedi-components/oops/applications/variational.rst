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
Background, background error covariance and analysis increment are all defined at a single time in the middle of the assimilation window.

3D-FGAT
^^^^^^^

3D-FGAT (First Guess at Appropriate Time). The model (including pseudo model) is run to generate the background trajectory, so
the observer can use model states at several times throughout the assimilation window. Background error covariance and
analysis increment are still defined at a single time in the middle of the assimilation window.

To turn on linear time interpolation of observation operators, set the following option in the yaml file for each 
of the observation types that need it:

.. code-block:: yaml

    observers:
      ...
      get values:
        time interpolation: linear

4D-Ens-Var
^^^^^^^^^^

4DEnVar uses ensembles for estimating 4-dimensional ensemble background error covariances. Does not require model TL/AD.

To configure 4DEnVar in the yaml file, use the following structure:

.. code-block:: yaml

    cost type: 4D-Ens-Var
    time window:
      begin: ...
      length: PT6H
    subwindow: PT1H
    parallel subwindows: true    # optional, default is true

The number of subwindows is determined from the time window length and the subwindow length. 
If "parallel subwindows" is set to true, the subwindows are processed in parallel, and the number of MPI tasks needs to be a multiple of the number of subwindows.
Configuring 4DEnVar requires specifying backgrounds and ensemble backgrounds (for ensemble background error covariances) for each of the subwindows, e.g.:

.. code-block:: yaml

    cost function:
      cost type: 4D-Ens-Var
      time window:
        begin: 2010-01-01T00:00:00Z
        length: PT6H
      subwindow: PT3H
      background:
        states:
        - date: 2010-01-01T00:00:00Z
          ...
        - date: 2010-01-01T03:00:00Z
          ...
        - date: 2010-01-01T06:00:00Z
          ...
      background error:
        covariance model: ensemble
        localization:
          ...
        members from template:
          template:
            states:
            - date: 2010-01-01T00:00:00Z
              ...
            - date: 2010-01-01T03:00:00Z
              ...
            - date: 2010-01-01T06:00:00Z
              ...
          pattern: '%mem%'  # remove apostrophes around %mem% if using this in a JEDI application
          nmembers: 100


4D-Var
^^^^^^

The 4D-Var cost function name is reserved for the strong-constraint (perfect model) 4DVar. Requires model TL/AD.

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
      time window:
         begin: # beginning of the data assimilation window
         length: # length of the data assimilation window
         bound to include: end # which window bound is inclusive (options: begin, end (default)).
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
