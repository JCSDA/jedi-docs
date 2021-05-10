.. _top-oops-weak_4D:

Weak-constraint 4D-Var
======================

Nonlinear Cost Function
-----------------------

This note describes the formulation of weak constraint 4D-Var, and its implementation in OOPS.

Let :math:`\mathbf{J}` denote the cost function and :math:`\mathbf{x}_k` denote the state at time :math:`t_k`.  The weak constraint 4D-Var cost function (equation :eq:`cost-nonlin`) is a function a set of model states :math:`\mathbf{x}_k` defined at regular intervals over a time window :math:`[ t_0 , t_N )`. We refer to this set of states as the "four-dimensional state vector". Note that there are :math:`N` sub-windows and that the four-dimensional state vector contains the :math:`N` states :math:`\mathbf{x}_0 , \ldots , \mathbf{x}_{N-1}`.

.. math::
    :label: cost-nonlin

    \begin{eqnarray}
    &&  J( \mathbf{x}_0 , \mathbf{x}_1 , \ldots , \mathbf{x}_{N-1} ) = \\
    &&\qquad \phantom{+}
               \frac{1}{2} \left( \mathbf{x}_0 - \mathbf{x}_b \right)^{\rm T}
                          \mathbf{B}^{-1}
                           \left( \mathbf{x}_0 - \mathbf{x}_b \right) \nonumber \\
    &&\qquad + \frac{1}{2} \sum_{k=0}^{N-1} \sum_{j=0}^{M-1}
                 \left( \mathbf{y}_{k,j} - {\cal H}_{k,j} (\mathbf{x}_{k,j} ) \right)^{\rm T}
                          \mathbf{R}_{k,j}^{-1}
                 \left( \mathbf{y}_{k,j} - {\cal H}_{k,j} (\mathbf{x}_{k,j} ) \right)
                            \nonumber \\
    &&\qquad + \frac{1}{2} \sum_{k=1}^{N-1}
                           \left( \mathbf{q}_k - \mathbf{\bar q}  \right)^{\rm T}
                          \mathbf{Q}_k^{-1}
                           \left( \mathbf{q}_k - \mathbf{\bar q}  \right)
                            \nonumber
    \end{eqnarray}

The cost function has three terms. The first term penalizes departures of :math:`\mathbf{x}_0` from a prior estimate (the "model background"), :math:`\mathbf{x}_b`. The matrix :math:`\mathbf{B}` is the covariance matrix of background error.

The second term of the cost function penalizes the discrepancies between observations :math:`\mathbf{y}_{k,j}` and their model equivalents, :math:`\mathbf{x}_{k,j}`. Here, the double subscript denotes a time such that (for :math:`j=1 \ldots M-1`) :math:`t_{k,j} \in [t_k , t_{k+1} )`. We assume that :math:`t_{k,0} = t_k` and :math:`t_{k,M} = t_{k+1}`. We refer to the interval :math:`[t_k , t_{k+1} )` as a "sub-window", and the times :math:`t_{k,j}` as "observation time slots". The operator :math:`{\cal H}_{k,j}` is the (nonlinear) observation operator, and :math:`\mathbf{R}_{k,j}` is the covariance matrix of observation error.

The final term in the cost function penalizes departures of model error :math:`\mathbf{q}_k`, defined at the boundaries between sub-windows, from a separately-estimated systematic model error, :math:`\mathbf{\bar q}`. The matrix :math:`\mathbf{Q}_k` is the covariance matrix of model error.

The states at times :math:`t_{k,j}` are given by an un-forced integration of the model:

.. math::
  :label: nonlin-propagate-eqn

    \begin{equation}
       \mathbf{x}_{k,j} = {\cal M}_{k,j} (\mathbf{x}_{k,j-1} )
    \end{equation}

for :math:`k=0, \ldots, N-1` and :math:`j=1 , \ldots, M`.

The model errors are determined as the difference between the state at the start of a sub-window and the corresponding state at the end of the preceding sub-window. There are :math:`N-1` model errors corresponding to the :math:`N-1` boundaries between sub-windows:

.. math::
  :label: nonlin-model-error-eqn

    \begin{equation}
       \mathbf{q}_k = \mathbf{x}_{k,0} - \mathbf{x}_{k-1,M}
                   \qquad\mbox{for $k=1 , \ldots , N-1$}.
    \end{equation}

Linear (Incremental) Cost Function
----------------------------------

The linear (incremental) cost function is defined by linearizing the operators in equation :eq:`cost-nonlin` around a "trajectory", to give a quadratic approximation :math:`\hat J` of the cost function. In principle, the trajectory is known at every timestep of the model. In practice, it may be necessary to assume the trajectory remains constant over small time intervals.

Let us denote by :math:`\mathbf{x}_k^t` the trajectory state at time :math:`t_k`. The approximate cost function is expressed as a function of increments :math:`\delta\mathbf{x}_k` to these trajectory states:

.. math::
  :label: cost-linear

    \begin{eqnarray}
    &&  {\hat J} ( \delta\mathbf{x}_0 , \delta\mathbf{x}_1 , \ldots ,
                                                   \delta\mathbf{x}_{N-1} ) = \\
    &&\qquad \phantom{+}
               \frac{1}{2} \left( \delta\mathbf{x}_0 + \mathbf{x}^t_0
                                                  - \mathbf{x}_b \right)^{\rm T}
                          \mathbf{B}^{-1}
                           \left( \delta\mathbf{x}_0 + \mathbf{x}^t_0
                                                  - \mathbf{x}_b \right) \nonumber \\
    &&\qquad + \frac{1}{2} \sum_{k=0}^{N-1} \sum_{j=0}^{M-1}
                 \left( \mathbf{d}_{k,j} - \mathbf{H}_{k,j} (\delta\mathbf{x}_{k,j} )
                                                            \right)^{\rm T}
                          \mathbf{R}_{k,j}^{-1}
                 \left( \mathbf{d}_{k,j} - \mathbf{H}_{k,j} (\delta\mathbf{x}_{k,j} )
                                                            \right)
                            \nonumber \\
    &&\qquad + \frac{1}{2} \sum_{k=1}^{N-1}
                           \left( \delta\mathbf{q}_k + \mathbf{q}^t_k
                                               - \mathbf{\bar q}  \right)^{\rm T}
                          \mathbf{Q}_k^{-1}
                           \left( \delta\mathbf{q}_k + \mathbf{q}^t_k
                                               - \mathbf{\bar q}  \right)
                            \nonumber
    \end{eqnarray}

Here, :math:`\mathbf{H}_{k,j}` is a linearization of :math:`{\cal H}_{k,j}` about the trajectory :math:`\mathbf{x}^t_{k,j}`. The vector :math:`\mathbf{d}_{k,j}` is defined as:

.. math::

    \begin{equation}
       \mathbf{d}_{k,j} = \mathbf{y}_{k,j} - {\cal H}_{k,j} (\mathbf{x}^t_{k,j} ) .
    \end{equation}

The increments :math:`\delta\mathbf{x}_{k,j}` satisfy a linearized version of equation
:eq:`nonlin-propagate-eqn`:

.. math::
  :label: linear-propagate-eqn

    \begin{equation}
       \delta\mathbf{x}_{k,j} = \mathbf{M}_{k,j} \delta\mathbf{x}_{k,j-1}
    \end{equation}

for :math:`k=0, \ldots, N-1` and :math:`j=1 , \ldots, M`.

The model error increments are given by:

.. math::
  :label: linear-model-error-eqn

    \begin{equation}
       \delta\mathbf{q}_k = \delta\mathbf{x}_{k,0} - \delta\mathbf{x}_{k-1,M}
                   \qquad\mbox{for $k=1 , \ldots , N-1$}.
    \end{equation}

Solution Algorithm: Outer Loop
------------------------------

The cost function (equation :eq:`cost-nonlin`) is minimized by successive quadratic approximations according to the following algorithm:

Given an initial four-dimensional state :math:`\{ \mathbf{x}_0 , \mathbf{x}_1 , \ldots , \mathbf{x}_{N-1} \}`:

#. For each sub-window, integrate equation :eq:`nonlin-propagate-eqn` from the initial condition :math:`\mathbf{x}_{k,0} = \mathbf{x}_k`, to determine the trajectory and the state :math:`\mathbf{x}_{k,M}` at the end of the sub-window.

#. Calculate the model errors from equation :eq:`nonlin-model-error-eqn`.

#. Minimize the linear cost function (equation :eq:`cost-linear`) to determine the increments :math:`\delta\mathbf{x}_k` and :math:`\delta\mathbf{q}_k`.

#. Set :math:`\mathbf{x}_k:=\mathbf{x}_k + \delta\mathbf{x}_k` and :math:`\mathbf{q}_k:=\mathbf{q}_k + \delta\mathbf{q}_k`.

#. Repeat from step 1.

Solution Algorithm: Inner Loop
------------------------------

There are several possibilities for minimizing the linear cost function. Some of these are described in the following sub-sections.

Initial State and Forcing Formulation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The initial state and forcing formulation expresses the linear cost function as a function of the initial increment :math:`\delta\mathbf{x}_0` and the model error increments :math:`\delta\mathbf{q}_1 , \ldots , \delta\mathbf{q}_{N-1}`.

The control vector for the minimization comprizes a set of three-dimensional vectors :math:`\mathbf{\chi}_k` for :math:`k=0, \ldots , N-1`, and is defined by:

.. math::
    :label: psi-to-dx0-eqn

    \begin{eqnarray}
      \mathbf{B}^{1/2} \mathbf{\chi}_0  &=&
         \left( \delta\mathbf{x}_0 + \mathbf{x}^t_0 - \mathbf{x}_b \right)
    \end{eqnarray}

.. math::
    :label: psi-to-dq-eqn

    \begin{eqnarray}
      \mathbf{Q}_k^{1/2} \mathbf{\chi}_k  &=&
         \left( \delta\mathbf{q}_k + \mathbf{q}^t_k - \mathbf{\bar q}  \right)
         \qquad \mbox{for $k=1, \ldots , N-1$}
    \end{eqnarray}

The background and observation terms of the cost function can be evaluated directly from the control vector as:

.. math::

    \begin{equation}
         J_b = \frac{1}{2} \mathbf{\chi}_0^{\rm T} \mathbf{\chi}_0 \qquad\mbox{and}\qquad
         J_q = \frac{1}{2} \sum_{k=1}^{N-1} \mathbf{\chi}_k^{\rm T} \mathbf{\chi}_k
    \end{equation}

The contribution to the gradient of the cost function from these terms is simply equal to the control vector itself.

To evaluate the observation term, we must generate the four-dimensional increment: :math:`\{\delta\mathbf{x}_k ; k=0, \ldots , N-1\}`. This is done by first calculating :math:`\delta\mathbf{x}_0` and :math:`\delta\mathbf{q}_k` from equations :eq:`psi-to-dx0-eqn` and :eq:`psi-to-dq-eqn`, and then generating :math:`\delta\mathbf{x}_k` using equations :eq:`linear-propagate-eqn` and :eq:`linear-model-error-eqn`.

The cost function is minimized, resulting in an updated control vector, corresponding to the minimum of the linear cost function. From this cost function, we must generate the four-dimensional increment required by the outer loop. This is done using equations :eq:`linear-propagate-eqn` and :eq:`linear-model-error-eqn`, and requires a integration of the tangent linear model

Four Dimensional State Formulation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

In the four dimensional state formulation, the cost function is expressed as a function of the four dimensional state, :math:`\delta\mathbf{x}_0 , \ldots , \delta\mathbf{x}_{N-1}`.

The control vector for the minimization is defined by:

.. math::

    \begin{eqnarray}
      \mathbf{B}^{1/2} \mathbf{\chi}_0  &=&
         \left( \delta\mathbf{x}_0 + \mathbf{x}^t_0 - \mathbf{x}_b \right) \\
      \mathbf{Q}_k^{1/2} \mathbf{\chi}_k  &=& \delta\mathbf{x}_k
         \qquad \mbox{for $k=1, \ldots , N-1$}
    \end{eqnarray}

With this choice for :math:`\mathbf{\chi}_0`, the background term of the cost function can be evaluated as :math:`J_b = \frac{1}{2} \mathbf{\chi}_0^{\rm T} \mathbf{\chi}_0`. However, the model error term must now be evaluated explicity as:

.. math::

    \begin{equation}
    J_q =  \frac{1}{2} \sum_{k=1}^{N-1}
                           \left( \delta\mathbf{q}_k + \mathbf{q}^t_k
                                               - \mathbf{\bar q}  \right)^{\rm T}
                          \mathbf{Q}_k^{-1}
                           \left( \delta\mathbf{q}_k + \mathbf{q}^t_k
                                               - \mathbf{\bar q}  \right)
    \end{equation}

where :math:`\delta\mathbf{q}_k` is determined from equation
:eq:`linear-model-error-eqn`.

Note that this requires that the inverse model error covariance matrix is
available, and is reasonably well conditioned.
