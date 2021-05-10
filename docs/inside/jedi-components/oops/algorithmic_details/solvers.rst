.. _top-oops-solvers:

OOPS linear equations solvers
=============================

This note describes the linear equation solvers implemented in OOPS. The solvers are designed to be as generic as possible, to allow their use with a variety of different vector and matrix classes.

Generic code design
-------------------

The solvers are implemented as generic (templated) functions. The functions are templated on a type VECTOR and one or more matrix types (AMATRIX, PMATRIX, etc.). Thus, we require that all vector arguments are of the same class, but the matrices do not have to be derived from a single class.

In addition to the vector and matrix arguments, there are two arguments specifying the maximum number of iterations to be performed, and the required reduction in residual norm. Iteration will stop when either the iteration limit is reached or the residual norm is reduced below the required factor. The return value from all the solvers is the achieved reduction in residual norm.

As a typical example, consider the IPCG solver:

.. code-block:: C++

    template <typename VECTOR,
              typename AMATRIX,
              typename PMATRIX>

    double IPCG (VECTOR & x,
                 const VECTOR & b,
                 const AMATRIX & A,
                 const PMATRIX & precond,
                 const int maxiter,
                 const double tolerance );

For all the solvers, VECTOR is expected to implement basic linear algebra operations:

.. code-block:: C++

    double dot_product(VECTOR &, VECTOR &);
    operator(=)
    operator(+=)
    operator(-=)
    operator(*=) // double times VECTOR
    axpy // u.axpy(a,v) sets u = u + a*v

The matrix classes are expected to implement:

.. code-block:: C++

    void apply(const VECTOR&, VECTOR&) const

This function represents application (multiplication) of the matrix to the first argument, with the result returned in the second. For all the current algorithms, application of the preconditioner may be approximate, for example as the result of an iterative solution method.

The algorithms
--------------

The following algorithms are available:

* IPCG: Inexact-Preconditioned Conjugate Gradients.
* DRIPCG: "Derber-Rosati" Inexact-Preconditioned Conjugate Gradients.
* GMRESR.
* DRGMRESR: A "Derber-Rosati" version of GMRESR.

IPCG
^^^^
Inexact Preconditioned Conjugate Gradients :cite:`GolubYe99` is a slight variation on the well-known Preconditioned Conjugate Gradients (PCG) algorithm. Given an initial vector :math:`\mathbf{x}_0`, a symmetric, positive definite matrix :math:`\mathbf{A}`, and preconditioners :math:`\mathbf{E}_k \approx \mathbf{A}^{-1}`, IPCG solves :math:`\mathbf{A}\mathbf{x} = \mathbf{b}` as follows:

.. math::
  :label: IPCG-precond-eqn

    \begin{eqnarray}
      \mathbf{s}_k &=& \mathbf{E}_k \mathbf{r}_k \\
      \beta_k &=&
               \frac{ \mathbf{s}_k^{\rm T} (\mathbf{r}_k -\mathbf{r}_{k-1})}
                    { \mathbf{s}_k^{\rm T} \mathbf{r}_{k-1} }
                                       \qquad\mbox{for $k>0$} \\
      \mathbf{d}_k &=& \left\{
           \begin{array}{ll}
               \mathbf{s}_k & \qquad\mbox{if $k=0$} \\
               \mathbf{s}_k + \beta_k \mathbf{d}_{k-1}
                                       & \qquad\mbox{if $k>0$}
           \end{array} \right. \\
      \mathbf{w}_k &=& \mathbf{A} \mathbf{d}_k \\
      \alpha_k &=& (\mathbf{s}_k^{\rm T} \mathbf{r}_k )/(\mathbf{d}_k^{\rm T} \mathbf{w}_k )\\
      \mathbf{x}_{k+1} &=& \mathbf{x}_k + \alpha_k \mathbf{d}_k \\
      \mathbf{r}_{k+1} &=& \mathbf{r}_k - \alpha_k \mathbf{w}_k
    \end{eqnarray}

The algorithm differs from PCG only in the definition of :math:`\beta_k`, which PCG defines as:

.. math::

  \begin{equation}
    \beta_k = \frac{\mathbf{s}_k^{\rm T} \mathbf{r}_k }
                   {\mathbf{s}_k^{\rm T} \mathbf{r}_{k-1} }
                                     \qquad\mbox{for $k>0$}. \\
  \end{equation}

This slight modification requires additional storage for the vector :math:`\mathbf{r}_{k-1}`, but has the advantage of significantly improving the convergence properties of the algorithm in the case that the preconditioner varies from iteration to iteration. In particular, :math:`\mathbf{s}_k` in equation :eq:`IPCG-precond-eqn` can be determined as the result of a truncated iterative solution of the equation :math:`\mathbf{\tilde A} \mathbf{s}_k = \mathbf{r}_k`, for some approximation :math:`\mathbf{\tilde A} \approx \mathbf{A}`.

Convergence results for IPCG are presented by :cite:`GolubYe99`. Further results are given by :cite:`Knyazev08`.

DRIPCG
^^^^^^

In many applications in variational data assimilation, the matrix :math:`\mathbf{A}` takes the particular form:

.. math::

     \mathbf{A} = \mathbf{B}^{-1} + \mathbf{C}

Furthermore, the matrix :math:`\mathbf{B}^{-1}` may be ill-conditioned or unavailable. In this case, :cite:`DerberRosati89` showed that the PCG algorithm could be modified in such a way that application of :math:`\mathbf{B}^{-1}` is not required during the iterations. The algorithm requires an additional initial vector, :math:`\mathbf{\hat x}_0 = \mathbf{B}^{-1} \mathbf{x}_0`. However application of :math:`\mathbf{B}^{-1}` can be avoided for the initial vector if the initial guess is taken as :math:`\mathbf{x}_0 = \mathbf{0}`, or if both :math:`\mathbf{x}_0`
and :math:`\mathbf{\hat x}_0` are retained from a previous application of the algorithm.

:cite:`DerberRosati89` modified PCG. However, their approach can be applied more widely to a range of linear equation solvers. The essence of the approach is to introduce auxiliary vectors:

.. math::

    \mathbf{\hat x}_k &=& \mathbf{B}^{-1} \mathbf{x}_k \\
    \mathbf{\hat s}_k &=& \mathbf{B}^{-1} \mathbf{s}_k \\
    \mathbf{\hat d}_k &=& \mathbf{B}^{-1} \mathbf{d}_k

Defining :math:`\mathbf{F}_k = \mathbf{B}^{-1} \mathbf{E}_k`, and :math:`\mathbf{r}_0 = \mathbf{b} - \mathbf{\hat x}_0 - \mathbf{C}\mathbf{x}_0` (i.e. :math:`\mathbf{r}_0 =\mathbf{b} -\mathbf{A}\mathbf{x}_0`), we can write the IPCG algorithm as:

.. math::
    :label: DRIPCG-eqn-for-x

    \begin{eqnarray}
      \mathbf{\hat s}_k &=& \mathbf{F}_k \mathbf{r}_k \\
      \mathbf{s}_k &=& \mathbf{B} \mathbf{r}_k \\
      \beta_k &=&
               \frac{ \mathbf{s}_k^{\rm T} (\mathbf{r}_k -\mathbf{r}_{k-1})}
                    { \mathbf{s}_k^{\rm T} \mathbf{r}_{k-1} }
                                       \qquad\mbox{for $k>0$} \\
      \mathbf{d}_k &=& \left\{
           \begin{array}{ll}
               \mathbf{s}_k & \qquad\mbox{if $k=0$} \\
               \mathbf{s}_k + \beta_k \mathbf{d}_{k-1}
                                       & \qquad\mbox{if $k>0$}
           \end{array} \right. \\
      \mathbf{\hat d}_k &=& \left\{
           \begin{array}{ll}
               \mathbf{\hat s}_k & \qquad\mbox{if $k=0$} \\
               \mathbf{\hat s}_k + \beta_k \mathbf{\hat d}_{k-1}
                                       & \qquad\mbox{if $k>0$}
           \end{array} \right. \\
      \mathbf{w}_k &=& \mathbf{\hat d}_k + \mathbf{C} \mathbf{d}_k \\
      \alpha_k &=& (\mathbf{s}_k^{\rm T} \mathbf{r}_k )/(\mathbf{d}_k^{\rm T} \mathbf{w}_k )\\
      \mathbf{x}_{k+1} &=& \mathbf{x}_k + \alpha_k \mathbf{d}_k \\
      \mathbf{\hat x}_{k+1} &=& \mathbf{\hat x}_k + \alpha_k \mathbf{\hat d}_k \\
      \mathbf{r}_{k+1} &=& \mathbf{r}_k - \alpha_k \mathbf{w}_k
    \end{eqnarray}

Note that no applications of :math:`\mathbf{B}^{-1}` are required during the iteration. Note also that :math:`\mathbf{x}_k` is not used during the iteration, so that the equation for :math:`\mathbf{x}_{k+1}` can be removed. After some number :math:`N` of iterations, we can recover :math:`\mathbf{x}_N` from :math:`\mathbf{\hat x}_N` by multiplying the latter by :math:`\mathbf{B}`.

The Derber Rosati algorithm is sometimes called "Double" PCG. We have adopted this nomenclature for algorithms that include similar modifications. thus, we call the algorithm described above Derber-Rosati Inexact-Preconditioned Conjugate Gradients, or DRIPCG. The algorithm is closely related to CGMOD (Gratton, personal communication).

DRIPCG is algebraically equivalent to IPCG provided that the preconditioners are related by :math:`\mathbf{F}_k = \mathbf{B}^{-1} \mathbf{E}_k`. A common preconditioning is to choose :math:`\mathbf{E}_k = \mathbf{B}`, in which case :math:`\mathbf{F}_k = \mathbf{I}`.

GMRESR
^^^^^^

GMRESR :cite:`VanDerVorst94` is a robust algorithm for square, non-symmetric systems. Like IPCG, it allows the preconditioner to vary from iteration to iteration. The algorithm starts with :math:`\mathbf{r}_0 = \mathbf{b} - \mathbf{A}\mathbf{x}_0`, and iterates the following steps for :math:`k=0,1,2,\ldots`.

.. math::

    \begin{eqnarray}
      \mathbf{z} &=& \mathbf{E}_k \mathbf{r}_k \\
      \mathbf{c} &=& \mathbf{A}\mathbf{z} \\
      && \mbox{for} \quad j = 0,1,\ldots,k-1 \nonumber \\
      && \qquad \alpha = \mathbf{c}_j^{\rm T} \mathbf{c} \\
      && \qquad \mathbf{c} = \mathbf{c} - \alpha \mathbf{c}_j \\
      && \qquad \mathbf{z} = \mathbf{z} - \alpha \mathbf{u}_j \\
      && \mbox{end for} \nonumber \\
      \mathbf{c}_k &=& \frac{\mathbf{c}}{\Vert \mathbf{c} \Vert_2} \\
      \mathbf{u}_k &=& \frac{\mathbf{z}}{\Vert \mathbf{c} \Vert_2} \\
      \beta_k &=& \mathbf{c}_k^{\rm T} \mathbf{r}_k \\
      \mathbf{x}_{k+1} &=& \mathbf{x}_k + \beta_k \mathbf{u}_k \\
      \mathbf{r}_{k+1} &=& \mathbf{r}_k - \beta_k \mathbf{c}_k
    \end{eqnarray}

For a symmetric matrix and constant symmetric positive definite (SPD) preconditioner, GMRESR is algebraically equivalent to PCG. In this case, the explicit orthogonalization of :math:`\mathbf{c}_k` against earlier vectors mitigates the effects of rounding error, resulting in somewhat faster convergence and a preservation of the super-linear convergence properties of PCG.

The storage requirements of GMRESR are significant, since the vectors :math:`\mathbf{c}_k` and :math:`\mathbf{u}_k` must be retained for all subsequent iterations. Note that this is twice the storage required for a fully-orthogonalizing PCG algorithm such as CONGRAD :cite:`Fisher98`.

DRGMRESR
^^^^^^^^

A "Derber-Rosati" version of GMRESR is easy to derive. As in the case of DRIPCG, we define :math:`\mathbf{F}_k = \mathbf{B}^{-1} \mathbf{E}_k`, and calculate the starting point as :math:`\mathbf{r}_0 = \mathbf{b} - \mathbf{\hat x}_0 - \mathbf{C}\mathbf{x}_0`, where :math:`\mathbf{\hat x}_0 = \mathbf{B}^{-1} \mathbf{x}_0`. Defining also the auxilliary vectors:

.. math::

    \mathbf{\hat z} &=& \mathbf{B}^{-1} \mathbf{z} \\
    \mathbf{\hat u}_k &=& \mathbf{B}^{-1} \mathbf{u}_k \\

we have:

.. math::

    \begin{eqnarray}
      \mathbf{\hat z} &=& \mathbf{F}_k \mathbf{r}_k \\
      \mathbf{z} &=& \mathbf{B} \mathbf{\hat z}_k \\
      \mathbf{c} &=& \mathbf{\hat z} + \mathbf{C}\mathbf{z} \\
      && \mbox{for} \quad j = 0,1,\ldots,k-1 \nonumber \\
      && \qquad \alpha = \mathbf{c}_j^{\rm T} \mathbf{c} \\
      && \qquad \mathbf{c} = \mathbf{c} - \alpha \mathbf{c}_j \\
      && \qquad \mathbf{z} = \mathbf{z} - \alpha \mathbf{u}_j \\
      && \qquad \mathbf{\hat z} = \mathbf{\hat z} - \alpha \mathbf{\hat u}_j \\
      && \mbox{end for} \nonumber \\
      \mathbf{c}_k &=& \frac{\mathbf{c}}{\Vert \mathbf{c} \Vert_2} \\
      \mathbf{u}_k &=& \frac{\mathbf{z}}{\Vert \mathbf{c} \Vert_2} \\
      \mathbf{\hat u}_k &=& \frac{\mathbf{\hat z}}{\Vert \mathbf{c} \Vert_2} \\
      \beta_k &=& \mathbf{c}_k^{\rm T} \mathbf{r}_k \\
      \mathbf{\hat x}_{k+1} &=& \mathbf{\hat x}_k + \beta_k \mathbf{\hat u}_k \\
      \mathbf{r}_{k+1} &=& \mathbf{r}_k - \beta_k \mathbf{c}_k
    \end{eqnarray}

As in the case of DRIPCG, after :math:`N` iterations, we can recover the solution :math:`\mathbf{x}_N` from :math:`\mathbf{\hat x}_N` by multiplying the latter by :math:`\mathbf{B}`.
