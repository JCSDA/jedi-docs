.. _reconditioning:

Obs Error Reconditioning
========================

UFO includes a :code:`ObsErrorReconditioner` class.

Since an :math:`R`-matrix is a covariance matrix it must be positive definite because
the eigenvalues of the :math:`R`-matrix measure variance, which is always positive.
Therefore the eigenvalues of a covariance matrix should always be positive (or zero
if there is linear dependence within a set of variables). Also, if all of the eigenvalues
of a matrix are greater than zero, the matrix is invertible. The invertibility of an
:math:`R`-matrix is required when calculating the numerical value of the cost function
in data assimilation.

Some methods for modeling an :math:`R`-matrix won't guarantee an operator that is
invertible; for example, the :math:`R`-matrix model may have very small (or even
negative) eigenvalues which result in instabilities when inverting. For these cases
*reconditioning* the matrix can be an appropriate solution. Reconditioning is a
process of inflating, removing, or otherwise adjusting small eigenvalues in order
to make the matrix inversion more stable.

When reconditiong a matrix, the **condition number**, the ratio of the largest divided
by the smallest eigenvalue is an important quantity:

.. math::

    \kappa = \dfrac{\lambda_{max}}{\lambda_{min}}


Some UFO Observation Error operators (i.e., :math:`R`-matrix models) include this
reconditioning feature which provides two reconditioning options each with adjustable
parameters which a user can use to tune the level of reconditioning. The
:ref:`ridge-reconditioning` and :ref:`mini-eigenval` reconditioning options are
described below.

Currently, the Obs Error classes which have this feature are:

* :ref:`obsErrorCrossVar`
* :ref:`obsErrorWithinGroup`

.. note::

  For any choice of reconditioning, the UFO reconditioner initially does a check on
  :math:`R` for any eigenvalues less than or equal. If an eigenvalue equal to zero
  is found, a small quantity is added to make it positive. If an eigenvalue is less
  than zero, it will be turned positive and inflated by a small factor.


.. _ridge-reconditioning:

Ridge Regression
----------------

Ridge regression reconditioning handles small eigenvalues by diagonalizing the matrix,
then adding a small value to each eigenvalue:

.. math::

  R = U \Sigma V^T \rightarrow U (\Sigma + \alpha I) V^T

where the matrices :math:`U` and :math:`V^T` transform :math:`R` into its eigen-representation,
:math:`\Sigma` is a diagonal matrix with the eigenvalues of R along the diagonal, :math:`\alpha`
is a small constant, and :math:`I` is the identity matrix. In this method, every eigenvalue will
be adjusted.

A user can specify the magnitude of the :math:`\alpha` inflation constant by setting one of two
YAML options: :code:`fraction` or :code:`shift` (both cannot be set).

If the :code:`fraction` parameter is set, the reconditioner will calculate:

.. math::

  \kappa_{max} = \kappa * fraction_value

Then, if :math:`kappa_{max}` is greater than 1, calculate the additive :math:`\alpha` constant according to:

.. math::

  \alpha = \dfrac{(\lambda_{max} -\lambda_{min})*\kappa_{max}}{\kappa_{max} - 1}.

If the :code:`shift` value is set, the reconditioner will use take this value as :math:`\alpha`.

To apply the Ridge Regression reconditioning to an obs error operator:

.. code-block:: yaml

    obs error:
    covariance model: <OBS ERROR MODEL>
    ...
    reconditioning:
      recondition method: Ridge Regression
      fraction: 0.9   # or, alternatively 'shift: '

.. _mini-eigenval:

Minimum Eigenvalue
------------------

Minimum Eigenvalue reconditioning handles small (or negative) eigenvalues by setting a threshold
for the lowest allowable numerical value eigenvalues can be. In this method, only problematic
eigenvalues will be adjusted.

A user can set this threshold by setting one of two YAML options: :code:`threshold` or
:code:`fraction` (both cannot be set).

Setting the :code:`threshold` parameter will result in eigenvalues less than this threshold
being set to the threshold value.

Setting :code:`fraction` will calculate:

.. math::

  \kappa_{max} = \kappa * fraction_value

And if :math:`\kappa_{max}` is greater than 1, the eigenvalue threshold will be:

.. math::

  threshold = \dfrac{\lambda_{max}}{\kappa_{max}}

and eigenvalues smaller than this threshold will be set to the threshold.

.. code-block:: yaml

    obs error:
    covariance model: <OBS ERROR MODEL>
    ...
    reconditioning:
      recondition method: Ridge Regression
      threshold: 2.0   # or, alternatively 'fraction: '
