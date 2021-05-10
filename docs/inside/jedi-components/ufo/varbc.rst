.. _top-ufo-varbc:

Variational Bias Correction in UFO
======================================
  .. note::

    Summarized from :

      - :cite:`ZhuVarBC14`
      - :cite:`DDVarBC04`

Linear combination formulation
+++++++++++++++++++++++++++++++++++++

  .. math::

    \vec{y} = H(\vec{x}) + \sum_{i=0}^{N} \beta_i p_i(\vec{x}) + \tilde{\vec{e}_o} 

  with scalar coefficients :math:`\beta_i, i = 0, . . . ,N` . The selection of predictors :math:`p_i(\vec{x}), i = 1, . . . ,N`  is flexible and depends on the instrument and channel.

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

VarBC example
+++++++++++++++++++++++++

To use the bias correction in an observation operator, add the :code:`obs bias` section as shown in the highlighted lines below.

.. code-block:: yaml
  :linenos:
  :emphasize-lines: 12-27

  observations:
  - obs space:
      name: AMSUA-NOAA19
      ...
      simulated variables: [brightness_temperature]
      channels: &channels 1-15
    obs operator:
      name: CRTM
      obs options:
        Sensor_ID: &Sensor_ID amsua_n19
      ...
    obs bias:
      input file: Data/obs/satbias_crtm_in_amsua_n19.nc4
      variational bc:
        predictors:
        - name: constant
        - name: emissivity
        - name: scan_angle
          options:
            order: 4
        - name: scan_angle
          options:
            order: 3
        - name: scan_angle
          options:
            order: 2
        - name: scan_angle

Here is the detailed explanation:

  1. Defines the predictors (required)
  
    Here, we defined 6 predictors to be used for VarBC, which are :code:`constant`, :code:`emissivity`, and 1st, 2nd, 3rd, 4th order :code:`scan_angle`, respectively. To find what predictor functions are available, please refer to directory :code:`ufo/src/ufo/predictors/`.

    .. code-block:: yaml

      variational bc:
        predictors:
        - name: constant
        - name: emissivity
        - name: scan_angle
          options:
            order: 4
        - name: scan_angle
          options:
            order: 3
        - name: scan_angle
          options:
            order: 2
        - name: scan_angle

  2. Defines the input file for the bias coefficients prior (optional)

     Usually, the prior is coming from the previous data assimilation cycle. If it is not available, all coefficients will start with zero.

    .. code-block:: yaml

      input file: Data/obs/satbias_crtm_in_amsua_n19.nc4

Static Bias Correction in UFO
=============================

Static bias correction is handled very similarly to variational bias correction. Mathematically, the only difference is that the coefficients :math:`\beta_i` of predictors used for static bias correction are kept constant and equal to 1. These predictors are defined in the :code:`obs bias.static bc` YAML section, whose syntax is identical to :code:`obs bias.variational bc`.
