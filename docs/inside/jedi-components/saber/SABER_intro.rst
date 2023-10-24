.. _SABER_intro:

Introduction to SABER Error Covariance Model
============================================

In variational data assimilation (VAR), the background error covariance matrix **B** plays an important role in
calculating the analysis (i.e., the best guess for the present state given a set of observations). For a
linear observation operator :math:`\textbf{H}`, the analysis :math:`\textbf{x}^a` is the sum of the background state
:math:`\textbf{x}^b` and an update increment :math:`\delta \textbf{x}`

.. math::
  :label: eq-inc
    
   \delta \textbf{x} = \textbf{B}\textbf{H}^T (\textbf{R} + \textbf{H}\textbf{B}\textbf{H}^T)^{-1} (\textbf{y}^o - H(\textbf{x}^b)),
  
where :math:`\textbf{y}^o` is a set of observations.

Conceptually, the **B** matrix contains the covariations in the errors between all pairs of elements in the
background state vector (:math:`\textbf{x}^b`). So, if a state vector has :math:`N = 10^9` entries, the full **B** matrix
will have :math:`N^2 = 10^{18}` entries. Storing a matrix of this size in memory is computationally prohibitive, so
instead most algorithms implement **B** as a matrix-like operator which modifies an increment vector.

A conceptual obstacle to understanding the **B** matrix is that, in a standard frequentist notion,
a covariation between a pair of variables is calculated through a sum over some number of matched pairs of draws
from the two variables. But, in basic VAR there is only one :math:`\textbf{x}^b`, so there is only one 'draw' and thus no
sum over which a covariation can be calculated. Thus, the covariances stored in **B** are better interpreted in
a Bayesian sense as our 'degree of belief' and represent the level of uncertainty in the background state of the
system: a larger covariance means there is a larger uncertainty in the background state. Covariances are also
responsible for spreading information across variables.

Another important consideration to keep in mind about the **B** matrix is that it is the covariances between
*errors* in state variables. The errors :math:`\boldsymbol{\eta}` can be defined as the difference between the "true state"
:math:`\textbf{x}^{\text{t}}` and our guess for the background state

.. math::

    \boldsymbol{\eta} = \textbf{x}^{\text{t}} - \textbf{x}^b,

where it is assumed that the background errors :math:`\boldsymbol{\eta}` are unbiased.
In practice, we can never actually know the true state. If we could there wouldn't be a need to do data
assimilation! But with this definition we can define **B** (with a frequentist definition) as

.. math::
    
    \textbf{B} = \dfrac{1}{N-1} \sum^{N}_{i=1} \boldsymbol{\eta}_i \boldsymbol{\eta}_i^{T}

where :math:`i` represents a member in an ensemble of :math:`N` appropriate 'guesses' (or forecasts)
:math:`\textbf{x}^b_i` for one specific true state. Since the scalar covariance is a commutative operation
(i.e., :math:`\text{Cov}(A,B) = \text{Cov}(B,A)`), **B** will be a symmetric matrix (see :cite:`Bannister2008Pt1`
for more details).

The block chain model
^^^^^^^^^^^^^^^^^^^^^

Mathematically, a covariance matrix can be split into a correlation part **C** and a variance part :math:`\boldsymbol{\Sigma}^2`.

.. math::

    \textbf{B} = \boldsymbol{\Sigma} \textbf{C} \boldsymbol{\Sigma}

The correlation matrix **C**, in general, is non-diagonal as there could be error correlations between any pair
of state variables. :math:`\boldsymbol{\Sigma}`, however, is a diagonal matrix with the standard deviations in
the errors of each variable along the diagonal.

Generally, it is convenient to work in the eigenrepresentation, a basis in which the error correlations/covariances have
been block diagonalized. This can be accomplished with a unitary transformation :math:`\textbf{V}` which will transform
both the variables and the **B** matrix from the 'model representation' to the eigenrepresentation (indicated with the
hats):

.. math::
    
    \begin{cases}
    \hat{x}  = \textbf{V}^T x \\
    \hat{\textbf{B}} = \textbf{V}^T \textbf{B} \textbf{V}
    \end{cases}

Additionally, a balance operator **K**, a linear transformation which enforces physical constraints (such as hydrostatic or
geostrophic balance) is included in the model **B** :cite:`Bannister2008Pt1`.

Also, an interpolation operator **T** may be included to transform from the grid used for modeling **B** to the model grid.
This will make a general model for **B** a series of matrix multiplications similar to the one shown below:

.. math::
  :label: eq-modelB
  
  \textbf{B} = \textbf{TVK} \boldsymbol{\Sigma} \textbf{C} \boldsymbol{\Sigma} \textbf{K}^T \textbf{V}^T \textbf{T}^T

In the SABER model, **C** is called the central block, which will be present in all block chains. All the other matrices
are referred to as outer blocks, and their transposes are called adjoints (AD). 

In the calculation of the analysis increment (see Eq. :eq:`eq-inc`), **B** is applied
at the front of the expression for the increment vector. In the block chain model, this matrix multiplication
is implemented as the application, from left to right, of the series of blocks in Eq. :eq:`eq-modelB`. So, 
first the adjoints of the outer blocks are applied in reverse order. 
Then, the central block, which is considered to be auto-adjoint, is applied.
Then, the direct outer blocks are applied in forward order (indicated as TL: tangent linear):

.. image:: fig/figure_saber_blocks_2.jpg
   :align: center
   :scale: 20%


Block chain specification
^^^^^^^^^^^^^^^^^^^^^^^^^

A SABER block encapsulates a linear operator -- which can represent a covariance, transformation,
localization, etc. matrix -- that is part of the block chain described above (see Eq. :eq:`eq-modelB`).

The list of available blocks for constructing a block chain in SABER can be found in :ref:`SABER blocks <SABER_blocks>`.

The most basic model for the background covariance is have a **B** that is constant in time which, in SABER, is an example
of a parametric **B**. Sometimes referred to as a "static" **B** in the literature, a parametric model for **B** could be a model
which does not evolve with time or a model that introduces some flow-dependence through dependence on the background state.
The implementation of a parametric **B** will directly match the expression in Eq. :eq:`eq-modelB`. Alternatively, **B**
could modeled using an ensemble of forecasts (e.g. similar to what is done in an Ensemble Kalman Filter). This Ensemble
**B** will allow the background covariances to evolve in time. Finally, the parametric and ensemble models can be combined
into a hybrid **B** using a weighted sum. These models are described in the following sections.

Parametric **B**
----------------

To setup a model for a parametric **B**, a user must specify their desired sequence of SABER blocks 
in the yaml configuration file for their experiment following this general outline:

  .. code-block:: yaml

    covariance model: SABER
    saber central block:
      - saber block name: <central block name>
        ...
    saber outer blocks:
      - saber block name: <outer block 1>
          ...
      - ...
      - saber block name: <outer block N>
          ...

Each covariance model should have at least a central block, and may or may not have outer blocks. 
Thus, the simplest SABER covariance model is just the Identity matrix:

.. code-block:: yaml

  covariance model: SABER
  saber central block: 
  - saber block name: ID

.. When the :code:`covariance model` is set as :code:`SABER`, a parametric block chain is used

Ensemble **B**
--------------

An ensemble **B** model (:math:`\textbf{P}^f_e`) includes a matrix generated from the ensemble members :math:`\textbf{B}_{\text{ens}}` and a localization
matrix :math:`\boldsymbol{\mathcal{L}}` which is applied in an element-wise multiplication (a Schur product) to :math:`\textbf{B}_{\text{ens}}` to enforce
zero covariance between distantly separated grid points :cite:`Lorenc2003`.

.. math::

    \textbf{P}^f_e = \boldsymbol{\mathcal{L}} \circ \textbf{B}_{\text{ens}}

When setting up an experiment with an ensemble **B**, both the localization matrix and :math:`\textbf{B}_{\text{ens}}`
can be defined in the experiment yaml configuration file with the covariance model set as :code:`ensemble`.

The setup a localization matrix is very similar to the setup for the parametric **B** described in the previous section as the computational
implementation of both :math:`\boldsymbol{\mathcal{L}}` and parametric **B** are identical. One difference is the addition of the :code:`localization` heading under
the :code:`covariance model`:


  .. code-block:: yaml

    covariance model: ensemble
    localization:
      localization method: SABER
      saber central block:
        - saber block name: <central block>
           ...
      saber outer blocks:
        - saber block name: <outer block>
          ...
        ...

When setting up an ensemble model, the localization will form the central block inside the full ensemble
block chain, and so will be nested inside the chain of outer blocks.

  .. code-block:: yaml

    covariance model: SABER
    saber central block:
      block name: Ensemble      
      localization:
        ...
        saber central block:
          - saber block name: <central block for localization>
             ...
        saber outer blocks:
          - saber block name: <outer block for localization>
            ...
        ...
    saber outer blocks:
      - saber block name: <outer block for ensemble>
        ...
      ...

For example, a series of outer blocks in the outer block chain (i.e., blocks that would take the place of the
:code:`<outer block for ensemble>` in the code outline above) may be needed to transform or interpolate from
variables used in the localization to variables in the analysis increment/model.

.. note::

  With settings of :code:`covariance model: hybrid` or :code:`covariance model: ensemble` computations will
  be done by OOPS. With  :code:`covariance model: SABER` computations will be done by SABER.

Hybrid **B**
------------

A hybrid **B** is a linear combination of parametric and ensemble covariance models. Thus a hybrid **B** with
one parametric component and one ensemble component could be expressed as

.. math::
  :label: eq-hybridB

  \textbf{B} = \alpha \textbf{B}_{s} + \beta \boldsymbol{\mathcal{L}} \circ \textbf{B}_{\text{ens}}.

This method is intended to use the strengths of each component model to minimize the weakness of the other. To set up a
hybrid **B** the parametric and ensemble models will both be included as :code:`components` with the :code:`covariance model`
set to :code:`hybrid` as shown below:

.. code-block:: yaml

  background error:
  covariance model: hybrid
  components:
  - covariance:
      covariance model: SABER
      saber central block:
        saber block name: <central block for parametric>
        ...
      saber outer blocks:
      - saber block name: <outer block 1 for parametric>
        ...
      - saber block name: <outer block N for parametric>
        ...
      ...
    weight:
      value: alpha
  - covariance:
      covariance model: ensemble
      ...
      localization:
        ...
        saber central block:
          - saber block name: <central block for localization>
            ...
        saber outer blocks:
          - saber block name: <outer block for localization>
          ...
      saber outer blocks:
        - saber block name: <outer block for ensemble>
          ...
      ...
    weight:
      value: beta

For an even more general model, a user can add extra terms to the sum in Eq. :eq:`eq-hybridB` by setting up additional
covariance components under the :code:`components` heading in the yaml file, as long as the weights add up to one.

.. note::

  With settings of :code:`covariance model: hybrid` or :code:`covariance model: ensemble` computations will
  be done by OOPS. With  :code:`covariance model: SABER` computations will be done by SABER.
  

Interfaces
^^^^^^^^^^
All SABER blocks have a constructor that takes as input arguments:

- a oops GeometryData,
- a list of outer variables,
- a configuration with elements on the SABER error covariance,
- a set of SABER block parameters (see next section),
- a background,
- a first guess,
- a valid time.

A single Atlas FieldSet is passed as argument for all the SABER block application methods.
Blocks are sometimes interoperable in any order. Coordinate transformations
and interpolations, however, are not generally interoperable. SABER blocks will implement each of
the four following methods (except central blocks which will only implement the first two methods):

- :code:`randomize`: Fill the input Atlas FieldSet with a a random vector of centered Gaussian distribution of unit variance and multiply by the "square-root" of the block. For central blocks only. 
- :code:`multiply`: apply the block to an input Atlas FieldSet. Required for all blocks.
- :code:`multiplyAD`: apply the adjoint of the block to an input Atlas FieldSet. For outer blocks only.
- :code:`leftInverseMultiply`: apply the inverse of the block to an input Atlas FieldSet. For outer blocks only.

Other methods are used to glue the blocks together when building a SABER error covariance, from the outermost block to the innermost: 

- :code:`innerGeometryData()`: returns the oops GeometryData for the next block. For outer blocks only. 
- :code:`innerVars()`: returns the oops Variables for the next block. For outer blocks only. 


Methods that are only used to calibrate an error covariance model are presented in the :ref:`section on calibration <calibration>`. 

Among the other methods, note that the :code:`read()` method should be used to read any calibration data, i.e. block data that can be estimated from an ensemble of forecasts.

Base parameters
^^^^^^^^^^^^^^^
.. _SABER_blocks_parameters:

All SABER blocks share some common base parameters, and have their own specific parameters (see :ref:`SABER blocks <SABER_blocks>`). These base parameters are:

- :code:`saber block name`: the name of the SABER block. Only parameter that is not optional.
- :code:`active variables`: variables modified by the block. This should include at least the variables returned by the :code:`mandatoryActiveVars()` block method.
- :code:`read`: a configuration to be used by the block at construction time. If a configuration is given, the block is used in read mode. Cannot be used with :code:`calibration`.
- :code:`calibration`: a configuration to be used by the block at construction time. If a configuration is given, the block is used in calibration mode. Cannot be used with :code:`read`.
- :code:`ensemble transform`: transform parameters, for the :code:`Ensemble` block only.
- :code:`localization`: localization parameters, for the :code:`Ensemble` block only.
- :code:`skip inverse`: boolean flag to skip application of the inverse in calibration mode. Defaults is :code:`false`.
- :code:`state variables to inverse`: state variables to be interpolated at construction time from one functionSpace to another. To be used for interpolation blocks only, when the outer and inner Geometry differ. Default is no variables.

Other parameters related to testing are listed in :ref:`SABER block testing <saber_testing>`.
