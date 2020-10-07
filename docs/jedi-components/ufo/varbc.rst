.. _top-ufo-varbc:

.. role:: raw-html(raw)
  :format: html

Variation Bias Correction in UFO
==================================

VarBC implementation
+++++++++++++++++++++++++

Using 3DVAR as example
-----------------------

Genral 3DVAR form
^^^^^^^^^^^^^^^^^^^^^^

  .. math::
      :label: costf3

      J(x) = \frac{1}{2} ( \vec{x}- \vec{x}_b ) )^T \textbf{B}^{-1} ( \vec{x} - \vec{x}_b ) +
             \frac{1}{2} ( H(\vec{x}) - \vec{y} )^T \textbf{R}^{-1} ( H(\vec{x}) -\vec{y} )

  define :math:`\vec{\delta{x}} = \vec{x} -\vec{x}_b`, called *Increment*
  
  thus, based on *Taylor expansion*

    .. math::

      H(\vec{x}) = H(\vec{x}_b) + \mathcal{H} (\vec{\delta{x}})

  where :math:`\mathcal{H} = \frac{\partial H}{\partial \vec{x}} \Bigg \vert_{\vec{x}=\vec{x}_b}`, called *Linear observation operator*

Incremental 3DVAR form
^^^^^^^^^^^^^^^^^^^^^^^^

  :eq:`costf3` can be written as incremental form

    .. math::
      :label: Incremental3dvar

      J(\vec{\delta{x}}) & = \frac{1}{2} \vec{\delta{x}}^T \textbf{B}^{-1} \vec{\delta{x}} + \frac{1}{2} ( H(\vec{x}_b) + \mathcal{H} (\vec{\delta{x}}) - \vec{y} )^T \textbf{R}^{-1} ( H(\vec{x}_b) + \mathcal{H} (\vec{\delta{x}}) - \vec{y} ) \\
       & = \frac{1}{2} \vec{\delta{x}}^T \textbf{B}^{-1} \vec{\delta{x}} + \frac{1}{2} ( \mathcal{H} (\vec{\delta{x}}) - \vec{d} )^T \textbf{R}^{-1} ( \mathcal{H} (\vec{\delta{x}}) - \vec{d} ) \\
       & = \frac{1}{2} \vec{\delta{x}}^T ( \textbf{B}^{-1} + \mathcal{H}^T \textbf{R}^{-1} \mathcal{H}) \vec{\delta{x}} -
           \vec{\delta{x}}^T \mathcal{H}^T \textbf{R}^{-1} \vec{d} + \frac{1}{2} \vec{d}^T \textbf{R}^{-1} \vec{d}

  where :math:`\vec{d} = \vec{y} - H(\vec{x}_b)`, called *Innovation*


3DVAR gradient
^^^^^^^^^^^^^^^^^

  :eq:`Incremental3dvar` is a `quadratic equataion <https://en.wikipedia.org/wiki/Quadratic_equation>`_, then, to find the :math:`\vec{\delta{x}}` which minimizeds :math:`J`

    .. math::

      \nabla J = ( \textbf{B}^{-1} + \mathcal{H}^T \textbf{R}^{-1} \mathcal{H}) \vec{\delta{x}} - \mathcal{H}^T \textbf{R}^{-1} \vec{d} = 0


Variation Observation Bias correction
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  Define the augmented control vector

    .. math::

      \vec{z}^T = \lbrack \vec{x}^T \vec{\beta}^T \rbrack

  Therefore, the cost function to be minimized

    .. math::

      J(\vec{z}) = \frac{1}{2} (\vec{z}_b - \vec{z})^T \textbf{Z}^{-1} (\vec{z}_b - \vec{z}) +  \frac{1}{2} (\vec{y} - \tilde{H}(\vec{z}))^T \textbf{R}^{-1} (\vec{y} - \tilde{H}(\vec{z}))

  where

    .. math::

      \tilde{H}(\vec{z}) & =  \begin{bmatrix}
                                H & P  \\
                              \end{bmatrix} \cdot
                              \begin{bmatrix}
                                 \vec{x} \\
                                 \vec{\beta} \\
                              \end{bmatrix} \\
                          & = H(\vec{x}) + P(\vec{x}) \vec{\beta}

    :math:`P(\vec{x})` is called *predictor*.
    
  In general the parameter estimation errors will be correlated with the state estimation errors, because they depend on the same data. We know of no practical way to account for this statistical dependence, and therefore take

    .. math::

      \textbf{Z} = \begin{bmatrix}
                      \textbf{B}_x & 0 \\
                      0 & \textbf{B}_{\beta}
                    \end{bmatrix}

  where :math:`\textbf{B}_x` denotes the usual (state) background error covariance, and :math:`\textbf{B}_\beta` the parameter background error covariance.

  We take :math:`\textbf{B}_\beta` diagonal:
  
  Also define :math:`\vec{\delta{z}} = \vec{z} -\vec{z}_b`, then the *Increment form* is:

    .. math::
      :label: Incremental3dvarVarBC

      J(\vec{\delta{z}}) = \frac{1}{2} \vec{\delta{z}}^T ( \textbf{Z}^{-1} + \tilde{\mathcal{H}}^T \textbf{R}^{-1} \tilde{\mathcal{H}}) \vec{\delta{z}} -
           \vec{\delta{z}}^T \tilde{\mathcal{H}}^T \textbf{R}^{-1} \vec{\tilde{d}} + \frac{1}{2} \vec{d}^T \textbf{R}^{-1} \vec{\tilde{d}}


  The gradient is

    .. math::

      \nabla J = ( \textbf{Z}^{-1} + \tilde{\mathcal{H}}^T \textbf{R}^{-1} \tilde{\mathcal{H}} ) \vec{\delta{z}} - \tilde{\mathcal{H}}^T \textbf{R}^{-1} \vec{\tilde{d}}

  where:

    - Linear observation operator

      .. math::

        \tilde{\mathcal{H}}(\vec{\delta{z}}) & = \begin{bmatrix}
                                                   \mathcal{H} \vert_{\vec{x}_b} & P \vert_{\vec{x}_b} \\
                                                 \end{bmatrix} \cdot
                                                 \begin{bmatrix}
                                                   \vec{\delta{x}} \\
                                                   \vec{\delta{\beta}} \\
                                                 \end{bmatrix} \\
             & = \mathcal{H} \vert_{\vec{x}_b} \vec{\delta{x}} + P \vert_{\vec{x}_b} \vec{\delta{\beta}}

    - Innovation

      .. math::

        \vec{\tilde{d}} & = \vec{y} - \tilde{H}(\vec{z}_b) \\
                        & = \vec{y} - H(\vec{x}_b) - P(\vec{x}_b) \vec{\beta}_b

Adaptive bias correction
+++++++++++++++++++++++++

  .. note::

    Summarized from :

      - :cite:`ZhuVarBC14`
      - :cite:`DDVarBC04`

    
  The scheme is based on a separation of the biases into scan-angle dependent and state dependent components. It is assumed that the data :math:`\vec{y}` in a given channel are related to the true model state :math:`\vec{x}` at the observed time and location by

    .. math::

      \vec{y} & = H(\vec{x}) + \vec{b}^{scan} + \vec{b}^{air}(\vec{x}, \vec{\beta}) + \tilde{\vec{e}_o} , \qquad \langle \tilde{\vec{e}_o} \rangle = 0 \\
              & = H(\vec{x}) + \vec{b}^{scan} + \beta_0 + \sum_{i=1}^{N} \beta_i p_i(\vec{x}) + \tilde{\vec{e}_o} 

  with scalar coefficients :math:`\beta_i, i = 0, . . . ,N` . The selection of predictors :math:`p_i(\vec{x}), i = 1, . . . ,N`  is flexible and depends on the instrument and channel.

  Including the scan bias correction in the variational analysis

    .. math::

        \vec{y} = H(\vec{x}) + \sum_{i=0}^{N} \beta_i p_i(\vec{x}) + \tilde{\vec{e}_o} 


Augmented control variable
+++++++++++++++++++++++++++++++++++

  Define the augmented control vector

    .. math::

      \vec{z}^T = \lbrack \vec{x}^T \vec{\beta}^T \rbrack

  Therefore, the cost function to be minimized

    .. math::

      J(\vec{z}) = \frac{1}{2} (\vec{z}_b - \vec{z})^T \textbf{Z}^{-1} (\vec{z}_b - \vec{z}) +  \frac{1}{2} (\vec{y} - \tilde{H}(\vec{z}))^T \textbf{R}^{-1} (\vec{y} - \tilde{H}(\vec{z}))

  where

    .. math::
      :label: Hop

      \tilde{H}(\vec{z}) = H(\vec{x}) + \sum_{i=0}^{N} \beta_i p_i(\vec{x})

Adjoint of the bias model
+++++++++++++++++++++++++++++

  In the incremental formulation of the variational analysis, nonlinear observation operators are linearized about the latest outer-loop estimate :math:`\overline{\vec{x}}` of :math:`\vec{x}` . Similarly, for the modified operator we use

    .. math::
      
        H(\vec{x}, \beta) \approx H(\overline{\vec{x}}, \beta) & = H(\overline{\vec{x}}) + \sum_{i=0}^{N} \beta_i p_i(\overline{\vec{x}}) \\
        & = H(\overline{\vec{x}}) + \mathcal{P}(\overline{\vec{x}}) \cdot \vec{\beta}

  where :math:`\mathcal{P}(\overline{\vec{x}})` is a :math:`m × n` predictor matrix consisting of :math:`n` predictors evaluated on :math:`m` observation locations.

  The modification to :math:`H(\vec{x})` is therefore additive and linear in the bias parameters, and its adjoint with respect to these additional control parameters is trivial to implement. 
  
  For the linear predictor model :eq:`Hop`, the derivatives with respect to the parameters are simply the values of the predictors at the observation locations

    .. math::

      \frac{\partial H }{\partial \vec{\beta}} \Bigg \vert_{\vec{\beta} = \vec{\beta}_b} = \mathcal{P}(\overline{\vec{x}})


Background error covariance
++++++++++++++++++++++++++++++

  In general the parameter estimation errors will be correlated with the state estimation errors, because they depend on the same data. We know of no practical way to account for this statistical dependence, and therefore take

    .. math::

      \textbf{Z} = \begin{bmatrix}
                      \textbf{B}_x & 0 \\
                      0 & \textbf{B}_{\beta}
                    \end{bmatrix}

  where :math:`\textbf{B}_x` denotes the usual (state) background error covariance, and :math:`\textbf{B}_\beta` the parameter background error covariance.

  We take :math:`\textbf{B}_\beta` diagonal:

    .. math::

      \textbf{B}_\beta & = diag(\sigma_{\beta_1}^2, ...., \sigma_{\beta_n}^2)  \\
                        & = \begin{bmatrix}
                              \sigma_{\beta_1}^2 & &   \\
                              & \ddots &  \\
                              & & \sigma_{\beta_n}^2
                            \end{bmatrix}   \\
                        & = \begin{bmatrix}
                              \frac{\sigma_{o_1}^2}{N_1} & &   \\
                              & \ddots &  \\
                              & & \frac{\sigma_{o_n}^2}{N_j}
                            \end{bmatrix}

  Here :math:`\beta_j` denotes the :math:`j^{th}` bias parameter, :math:`\sigma_{o_j}` is the error standard deviation of the observations associated with :math:`\beta_j`, and :math:`N_j` is a positive integer represents the number of observations.

  .. note::

    - For example, taking :math:`N_j = 10,000` for all parameters, the system will adapt quickly to changes in the bias for a clean channel generating thousands of radiances per analysis cycle. 
    - On the other hand, it will respond slowly to a cloudy channel that generates only a few hundreds of data per cycle. 


  .. note::

    - When the :math:`N_j` are sufficiently large (say, :math:`N_j >> 100` ), the effect of neglecting off-diagonal elements of the parameter background error covariance matrix should be insignificant. This is because :math:`\mathcal{O}(N_j)` observations are used to estimate just a few bias parameters; the estimation errors will be small even when the estimation is suboptimal. 
    - The situation is, of course, very different for the state estimation, which can be extremely sensitive to the specification of the background error covariances, especially in data-sparse areas. 

Preconditioning
+++++++++++++++++++++

  For a quadratic cost function, the shape at the minimum is completely described by the Hessian, which is

    .. math::
      :label: HessianX

      \frac{\partial^2 J}{\partial \vec{x}^2} \Bigg{\vert}_{\vec{x} =\vec{x}_a} = \textbf{B}_{\vec{x}}^{-1} + \mathcal{H}_{\vec{x}}^T \textbf{R}^{-1} \mathcal{H}_{\vec{x}}, \qquad \mathcal{H}_{\vec{x}} = \frac{\partial H}{\partial \vec{x}} \Bigg{\vert}_{\vec{x}=\vec{x}_a}

    .. math::
      :label: HessianBeta

      \frac{\partial^2 J}{\partial \vec{\beta}^2} \Bigg{\vert}_{\vec{\beta} =\vec{\beta}_a} = \textbf{B}_{\vec{\beta}}^{-1} + \mathcal{H}_{\vec{\beta}}^T \textbf{R}^{-1} \mathcal{H}_{\vec{\beta}}, \qquad \mathcal{H}_{\vec{\beta}} = \frac{\partial H}{\partial \vec{\beta}} \Bigg{\vert}_{\vec{\beta}=\vec{\beta}_a}

  The ideal change of variable would therefore be the symmetric square root of the Hessian, since this would result in a perfectly isotropic cost function in control space.

  - For the state estimation problem

    The first term on the right-hand side of :eq:`HessianX` represents the information contained in the background, while the second  term represents the additional information provided by the observations. :raw-html:`<font color="red">The second term is, of course, unknown at the outset of the minimization, and difficult to evaluate in general</font>`. The change of variable used for preconditioning is therefore normally   defined in terms of just the background covariance operator

      .. math::

            \vec{\chi}_{\vec{x}} = \textbf{B}^{-1/2} (\vec{x}_b - \vec{x})

    Usually this works quite well, because the information in the background tends to dominate the information in the observations.

    .. note::

      When occasional convergence problems do occur, they are often associated with the use of densely spaced and/or highly accurate  observations. Such a case of poor convergence was analyzed and explained in detail by :cite:`doi:10.1002/qj.49712656512` .

  - For the parameter estimation problem

    on the other hand, observational information tends to dominate because the number of data (:math:`N_j`) per unknown (:math:`\beta_j`) is typically very large. The standard change of variable based on the background contribution alone is therefore not an effective preconditioner.

    .. note::

      The change of variable for the parameter vector should incorporate an estimate of the second term in this expression, which represents the observational contribution to the available information about the parameters.

  For the linear predictor model :eq:`Hop`, the derivatives with respect to the parameters (:math:`\mathcal{H}_{\beta}`) are simply the values of the predictors at the observation locations. The :eq:`HessianBeta` is

  .. math::

    \frac{\partial^2 J}{\partial \vec{\beta}^2} \Bigg{\vert}_{\vec{\beta}} = & \begin{bmatrix}
                                                                              \frac{1}{\sigma_{\beta_1}^2} & & \\
                                                                              & \ddots & \\
                                                                              & & \frac{1}{\sigma_{\beta_n}^2} \\
                                                                            \end{bmatrix}
                                                                            + \\
                                                                            &
                                                                            \begin{bmatrix}
                                                                              p_{1,1} & & p_{m,1} \\
                                                                              & \ddots & \\
                                                                              p_{1,n} & & p_{m,n} \\
                                                                            \end{bmatrix}
                                                                            \cdot 
                                                                            \begin{bmatrix}
                                                                              \frac{1}{\sigma_{o}^2} & & 0 \\
                                                                              & \ddots & \\
                                                                              0 & & \frac{1}{\sigma_{o}^2} \\
                                                                            \end{bmatrix}
                                                                            \cdot
                                                                            \begin{bmatrix}
                                                                              p_{1,1} & & p_{1,n} \\
                                                                              & \ddots & \\
                                                                              p_{m,1} & & p_{m,n} \\
                                                                            \end{bmatrix}

  where most likely :math:`m >> n`, :math:`m` is the number of observations; :math:`n` is the number of parameters.

  The observational contribution to the Hessian depends primarily on the number of observations (the number of rows of :math:`\mathcal{H}_{\beta}`), on the observation error variances (the diagonal of :math:`\textbf{R}`), and on the second moments of the predictors (the elements of :math:`\mathcal{H}_{\beta}^T \mathcal{H}_{\beta}`). 

  Consider a channel :math:`k`, containning :math:`m` observations with error standard deviation :math:`\sigma_{o}`. Support that the bias model for this channel is based on :math:`n` predictors, and let the :math:`n × n` matrix :math:`\textbf{C}` denote an estimate of the globally averaged covariance of those predictors. Then the ideal change of variable would be

    .. math::

      \mathcal{L}^k = {\Bigg\lbrack \textbf{B}_{\beta}^{-1} + \frac{m}{\sigma_o^2} \textbf{C} \Bigg\rbrack }^{1/2}

  where :math:`\textbf{B}_{\beta}` is the :math:`n × n` matrix of background error covariances associated with the :math:`n` bias parameters for this channel. :raw-html:`<font color="red">This expression is easy to compute prior to the minimization</font>`. We then define the change of variable for the bias parameters by

    .. math::

      \vec{\chi}_{\vec{\beta}} = \mathcal{L} (\vec{\beta}_b - \vec{\beta})

  where the operator :math:`\mathcal{L}` is block-diagonal with blocks :math:`\mathcal{L}^k, k = 1, . . . ,K`.


Bias correction of passive data
+++++++++++++++++++++++++++++++++

TODO