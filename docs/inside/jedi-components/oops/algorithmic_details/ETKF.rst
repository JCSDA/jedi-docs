.. _top-oops-ETKF:

Local volume solvers 
======================

This note describes the formulation of local volume ensemble transform solvers and the implementations available in OOPS. A more detailed description of the deterministic solvers implemented in can be found in :cite:`FrolovEnKF24`, though note that, whilst the equations are equivilent, they are not identical as this documentation descibes the current equations implemented in the code. Further general details on stochastic solvers and for a comprehensive review of ensemble Kalman fitlers can be found in :cite:`BuehnerEnKF20` and :cite:`HoutekamerEnKF16` respectivly, though note that these refernces do not describe the specific JEDI implementations. 

We begin by providing a generic description and notation, and then describe the specific algebra applicable for each of the solvers currently in JEDI. These solvers are: 

* Stochastic Local Ensemble Transform Kalman filter (Stochastic LETKF)
* Deterministic Local Ensemble Transform Kalman filter (Deterministic LETKF)
* Stochastic Gain form of the local Ensemble Transform Kalman filter (Stochastic GETKF)
* Deterministic Gain form of the local Ensemble Transform Kalman filter (Deterministic GETKF)

General description and notation 
----------------------------------------------

In general, ensemble Kalman filters aim to provide a set of analysis ensemble state vectors :math:`\{\mathbf{x}_j^a\}` with :math:`j=1 \ldots N_e` members by assimilating the vector :math:`\mathbf{y}` of :math:`p` observations, into the set of ensemble background state vectors, :math:`\{\mathbf{x}_j^b\}`. Note, here we describe only the update step at a single time, and assume that all vectors and matrices described are valid at this time. 

The key vectors and matrices used in the ensemble Kalman filters are: 

* The matrix of ensemble members, 

  .. math::
    \mathbf{X} = [\mathbf{x}_1, \mathbf{x}_2, \ldots, \mathbf{x}_{N_e}], 

  of size :math:`m \times N_e`, where :math:`m` is the size of the state vector. 

* The ensemble mean, 

  .. math::

    \overline{\mathbf{x}} = \frac{1}{N_e}\sum_{j=1}^{N_e} \mathbf{x}_j, 
  
  of size :math:`m`.  

* The mean of the model-observation equivalents, 

  .. math::

    \overline{\mathbf{y}} = \frac{1}{N_e}\sum_{j=1}^{N_e} {\mathcal H}(\mathbf{x}_j), 

  of size :math:`p`, where :math:`{\mathcal H}` is the possibly non-linear observation operator. 

* The ensemble perturbation matrix, 
  
  .. math::

    \begin{eqnarray}
    \mathbf{X}' &=& [\mathbf{x}_1 - \overline{\mathbf{x}}, \mathbf{x}_2 - \overline{\mathbf{x}}, \ldots, \mathbf{x}_{N_e} - \overline{\mathbf{x}}], \\
                &=& [\mathbf{x}'_1, \mathbf{x}'_2, \ldots, \mathbf{x}'_{N_e}], \\
    \end{eqnarray}

  of size :math:`m \times N_e`. 

* The ensemble perturbation matrix in observation space, 

  .. math::
    \mathbf{Y} = [{\mathcal H}(\mathbf{x}_1) - \overline{\mathbf{y}}, {\mathcal H}(\mathbf{x}_2) - \overline{\mathbf{y}}, \ldots, {\mathcal H}(\mathbf{x}_{N_e}) - \overline{\mathbf{y}}]

  of size :math:`p \times N_e`. 

Note that the above states can be either the background or analysis vectors, denoted by the addition of the :math:`b` and :math:`a` superscripts respectively. The mean of the model-observation equivalents and the ensemble perturbation matrix in observation space are typically only calculated for the background, so we omit the superscripts for these. 

Currently all ensemble Kalman filters in OOPS are local volume solvers. The local volume solvers update the background iteratively, with each grid point/column updated individually using observations from within the observation space localization radius. For each grid point/column, :math:`i`, there are three main steps: 

#. Calculate the relevant local matrices and vectors 

   These local quantities, defined by including a subscript :math:`l` to the above quantities, can be defined as sub-matrices of the full matrices. They are calculated by applying a selection matrix :math:`\mathbf{\Phi}\{i\}` that selects only the rows of the matrices relevant to observations within a given distance, :math:`\delta`, of grid point/column :math:`i`. For example the local ensemble perturbation matrix in observation space can be calculated as :math:`\mathbf{Y}_l\{i\} = \mathbf{\Phi}\{i\}\mathbf{Y}` and is of dimension :math:`p_l \times N_e`, where :math:`p_l` is the number of local observations in the local domain. In addition to selecting only the relevant information, the observation error covariance matrix, :math:`\mathbf{R}_l`, can be further modified to down-weight observations based on their distance from the grid point/column. 

#. Calculate the local weights 
#. Apply the local weights to the local background ensemble perturbations to produce the analysis increments. 

The specific calculation and application of local weights for each grid point/column is dependent on the specific choice of filter, and these are described in the following sections. 

Local Ensemble Transform Kalman filter (LETKF)
---------------------------------------------------------------------

Both deterministic and stochastic LETKFs are implemented. For the LETKFs both horizontal and vertical localization are applied in observation space and local updates are applied at a single grid point. For both forms, the first step in the generation of the weights is the calculation of the ensemble space analysis error covariance matrix, :math:`\mathbf{P^a}` of size :math:`N_e \times N_e` from its inverse :math:`\mathbf{A}`, 

.. math::
    :label: LETKF_ComputeP

    \begin{eqnarray}
    && \mathbf{A} = \mathbf{Y}_l^T\mathbf{R}_l^{-1}\mathbf{Y}_l + \frac{N_e - 1}{\rho}\mathbf{I}, \\
    && \mathbf{A} \xrightarrow[\text{eigen}]{} \mathbf{C}\mathbf{\Gamma}\mathbf{C}^T, \\
    && \mathbf{P^a} = \mathbf{C}\mathbf{\Gamma}^{-1}\mathbf{C}^T,  
    \end{eqnarray}

where :math:`\mathbf{C}` is the matrix of orthogonal eigenvectors and :math:`\mathbf{\Gamma}` the diagonal matrix constructed from the corresponding eigenvalues whose ordering matches that of the eigenvector matrix. Note that :math:`\rho` is an inflation factor. Once this matrix is calculated, the generation of the weights is dependent on the nature of the solver. 

Stochastic version 
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
For the stochastic LETKF the correct analysis error covariance matrix is retained by adding a vector of random perturbations, :math:`\boldsymbol{\varepsilon}`, drawn from the observation error distribution, to the innovation vector. A single weight matrix is calculated and applied to the ensemble perturbations in order to update each ensemble member. The weight matrix, :math:`\mathbf{W}` of size :math:`N_e \times N_e` is calculated as follows: 

.. math::
    :label: Sto_LETKF_Weights

    \mathbf{W} = \mathbf{C}\mathbf{\Gamma}^{-1}\mathbf{C}^T \mathbf{Y}_l^T\mathbf{R}_l^{-1}(\boldsymbol{\mathcal{Y}}_l - \boldsymbol{\mathcal{E}} - ({\mathcal H}(\mathbf{X}))_l), 

where :math:`\boldsymbol{\mathcal{Y}}_l` is a matrix of size :math:`p_l \times N_e` of repeated local observation vectors and :math:`\boldsymbol{\mathcal{E}}` is a matrix of size :math:`p_l \times N_e` of repeated random perturbation vectors. 

This weights matrix is then applied to the background ensemble perturbations and added to the background ensemble to provide the analysis ensemble, 

.. math::
    :label: Sto_LETKF_ApplyWeights

    \begin{eqnarray}
      \mathbf{X}_l^a = \mathbf{X}_l^b + {\mathbf{X}'}_l^b\mathbf{W}.
    \end{eqnarray}


Deterministic version
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
For the deterministic LETKF, rather than updating the full ensemble, updates are applied to the background ensemble mean and to the background perturbations. This requires the computation of two weights matrices, the mean update weights, :math:`\mathbf{w}` of size :math:`N_e \times 1`, and the perturbation update weights, :math:`\mathbf{W}` of size :math:`N_e \times N_e`, 

.. math::
  :label: Det_LETKF_weights

    \begin{eqnarray}
      \mathbf{w} &=& \mathbf{C}\mathbf{\Gamma}^{-1}\mathbf{C}^T {\mathbf{Y}_l}^T\mathbf{R}_l^{-1}(\mathbf{y}_l - \overline{\mathbf{y}}_l), \\
      \mathbf{W} &=& \sqrt{N_e - 1}\mathbf{C}\mathbf{\Gamma}^{\frac{-1}{2}}\mathbf{C}^T. 
    \end{eqnarray}

The :math:`\mathbf{w}` matrix is then applied to the background mean and added to the background ensemble mean to provide the analysis ensemble mean; the :math:`\mathbf{W}` matrix is applied to the background perturbations and added to the analysis ensemble mean to provide the analysis ensemble, 

.. math::
    :label: Det_LETKF_ApplyWeights

    \begin{eqnarray}
      \overline{\mathbf{x}^a_l} &=& \overline{\mathbf{x}^b_l} + {\mathbf{X}'}_l^b\mathbf{w}, \\
      \mathbf{X}^a_l &=& \overline{\boldsymbol{\mathcal{X}}^a_l} + {\mathbf{X}'}_l^b\mathbf{W}, 
    \end{eqnarray}

where :math:`\overline{\boldsymbol{\mathcal{X}}^a_l} = [\overline{\mathbf{x}^a_l}, \ldots, \overline{\mathbf{x}^a_l}]` is a matrix of size :math:`m \times N_e` of repeated local analysis ensemble means. 

Gain form of the Local Ensemble Transform Kalman filter (GETKF)
---------------------------------------------------------------------

Both deterministic and stochastic GETKFs are implemented. For the GETKFs, horizontal localization is applied in observation space with the local updates applied for an entire grid column. The vertical localization is applied in model space allowing improved assimilation of observations that provide information integrated over a column. The model space localization is applied by modulating the ensemble; this is achieved using the vertical localization matrix :math:`\mathbf{C}_{vert} = \mathbf{L}_{vert}\mathbf{L}_{vert}^T`, where :math:`\mathbf{L}_{vert}` is the symmetric square root of :math:`\mathbf{C}_{vert}` consisting of :math:`N_{eig}` eigenvector columns, :math:`\mathbf{l}_{j_{vert}}`, of :math:`\mathbf{C}_{vert}`. Note that the number of eigenvectors, :math:`N_{eig}`, can account for all eigenvectors of :math:`\mathbf{C}_{vert}`, or the eigenvalues can be ordered and :math:`N_{eig}` can be reduced to account for a desired percentage of the sum of all eigenvalues. The modulated ensemble :math:`\mathbf{Z}^b` of size :math:`m \times N_eN_{eig}` is computed by taking the Schur product, :math:`\circ`, of each column of :math:`\mathbf{L}_{vert}` with each column of :math:`\mathbf{X}'^b`, 

.. math::
    :label: Mod_ens

    \begin{eqnarray}
      {\mathbf{Z}'}^b &=& [\mathbf{l}_{1} \circ {\mathbf{x}'}^b_{1}, \ldots, \mathbf{l}_{1} \circ {\mathbf{x}'}^b_{N_e} , \ldots, \mathbf{l}_{N_{eig}} \circ {\mathbf{x}'}^b_{1}, \ldots,  \mathbf{l}_{N_{eig}} \circ {\mathbf{x}'}^b_{N_e}], \\
      &=& [\mathbf{z}'_1, \mathbf{z}'_2, \ldots, \mathbf{z}'_{N_eN_{eig}}].
    \end{eqnarray}

In the case of the GETKFs, as well as the ensemble perturbation matrix in observation space, :math:`\mathbf{Y}`, it is also necessary to compute the modulated ensemble perturbation matrix in observation space, :math:`\mathbf{Y}^{mod}` of size :math:`p \times N_eN_{eig}`, 

.. math::
  :label: Mod_obs_ens

  \mathbf{Y}^{mod} = [{\mathcal H}({\mathbf{z}'}^b_1 + \overline{\mathbf{x}^b})- \overline{\mathbf{y}}, \ldots, {\mathcal H}({\mathbf{z}'}^b_{N_eN_{eig}} + \overline{\mathbf{x}^b})- \overline{\mathbf{y}}].

Note that here the observation operator is applied to the modulated perturbations added to the background ensemble mean. 

As with the LETKF, for both forms of GETKF the first step in the generation of the weights is the calculation of the analysis error covariance matrix in modulated ensemble space, :math:`\mathbf{P^a}` of size :math:`N_e N_{eig} \times N_e N_{eig}` from its inverse :math:`\mathbf{A}`, 

.. math::
    :label: GETKF_ComputeP

    \begin{eqnarray}
    && \mathbf{A} = {{\mathbf{Y}^{mod}_l}}^T\mathbf{R}_l^{-1}\mathbf{Y}^{mod}_l + \frac{N_e - 1}{\rho}\mathbf{I}, \\
    && \mathbf{A} \xrightarrow[\text{eigen}]{} \mathbf{C}\mathbf{\Gamma}\mathbf{C}^T, \\
    && \mathbf{P^a} = \mathbf{C}\mathbf{\Gamma}^{-1}\mathbf{C}^T. 
    \end{eqnarray}

where :math:`\mathbf{C}`, :math:`\mathbf{\Gamma}` and  :math:`\rho` are defined as in equation :eq:`LETKF_ComputeP`. Note that :math:`\mathbf{C}` used here differs from :math:`\mathbf{C}_{vert}` used in the modulation process. Once :math:`\mathbf{P^a}` is calculated, the generation of the weights is dependent on the nature of the solver. 

Stochastic version 
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
The stochastic GETKF is similar to the stochastic LETKF, other than the use of the modulated ensemble. The innovation vector is modified by adding random perturbations, :math:`\mathbf{\varepsilon}`, drawn from the observation error distribution. A single weight matrix is calculated and applied to the perturbations in order to update each ensemble member. The weight matrix :math:`\mathbf{W}`, of size :math:`N_eN_{eig} \times N_e`, is calculated as follows: 

.. math::
    :label: Sto_GETKF_Weights

    \mathbf{W} = \mathbf{C}\mathbf{\Gamma}^{-1}\mathbf{C}^T {\mathbf{Y}^{mod}_l}^T\mathbf{R}_l^{-1}(\boldsymbol{\mathcal{Y}}_l - \boldsymbol{\mathcal{E}} - ({\mathcal H}(\mathbf{X}))_l).

This matrix is then applied to the background ensemble perturbations and added to the background ensemble to provide the analysis ensemble, 

.. math::
    :label: Sto_GETKF_ApplyWeights

    \begin{eqnarray}
      \mathbf{X}^a_l = \mathbf{X}^b_l + {\mathbf{Z}'}_l^b\mathbf{W}.
    \end{eqnarray}


Deterministic version
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
The deterministic GETKF requires updates to both the ensemble mean and perturbations. The weights calculations differ from the LETKF in that they make use of the modulated ensemble; they also require a particular form of reduced Kalman gain that allows only the original ensemble members (rather than the full modulated ensemble) to be updated. In this case the mean update weights, :math:`\mathbf{w}` of size :math:`N_eN_{eig} \times 1`, and the perturbation update weights, :math:`\mathbf{W}` of size :math:`N_eN_{eig} \times N_e`, are given by, 

.. math::
  :label: Det_GETKF_weights

    \begin{eqnarray}
      \mathbf{w} &=& \mathbf{C}\mathbf{\Gamma}^{-1}\mathbf{C}^T {\mathbf{Y}^{mod}_l}^T\mathbf{R}_l^{-1}(\mathbf{y}_l - \overline{\mathbf{y}}_l), \\
      \mathbf{W} &=& \mathbf{C}[(\sqrt{N_e - 1}\mathbf{\Gamma}^{-1/2} - \mathbf{I})(\mathbf{\Gamma} - \frac{N_e - 1}{\rho}\mathbf{I})^{-1}]\mathbf{C}^T{\mathbf{Y}^{mod}_l}^T\mathbf{R}_l^{-1} {\mathbf{Y}_l}. 
    \end{eqnarray}

These matrices are then applied to the background mean and ensemble perturbations and added to the background ensemble to provide the analysis ensemble, 

.. math::
    :label: Det_GETKF_ApplyWeights

    \begin{eqnarray}
      \overline{\mathbf{x}^a_l} &=& \overline{\mathbf{x}^b_l} + {\mathbf{Z}'}_l^b\mathbf{w}, \\
      \mathbf{X}^a_l &=& \overline{\boldsymbol{\mathcal{X}}^a_l} + {\mathbf{X}'}_l^b + {\mathbf{Z}'}_l^b\mathbf{W}.
    \end{eqnarray}

