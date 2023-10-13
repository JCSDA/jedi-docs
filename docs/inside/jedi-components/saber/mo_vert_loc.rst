.. _mo_vert_loc:

mo_vertical_localization
========================

The **mo_vertical_localization** SABER outer block is multiplying each model column by the *square root* of a vertical localization matrix.
For efficiency, not all modes of the vertical localization matrix have to be kept. 

Example yaml
------------

.. code-block:: yaml

    saber outer blocks:
    - saber block name: mo_vertical_localization
      active variables:
      - streamfunction
      - velocity_potential
      localization data:
        localization matrix file name: testdata/Lv.nc
        localization field name in file: Lv
        pressure file name: testdata/ptheta_bar_mean.nc        # Optional
        pressure field name in pressure file: Ptheta_bar_Mean  # Optional
      number of vertical modes: 7
      allow non-unit diagonal: true                            # Optional, default false
      output file name: testdata/vertical_localization.nc      # Optional

The :code:`localization data` section gives the input information on the vertical localization :math:`\mathbf{L}` to apply.
The netcdf file provided to :code:`localization matrix file name` should have :math:`\mathbf{L}` as a 2D variable (:code:`localization field name in file`) of shape :math:`n_z\times n_z` where :math:`n_z` is the number of vertical levels. 
No check is done to check that the provided localization is symmetric. 
An exception is thrown if it has a non-unit diagonal, except if a user override :code:`allow non-unit diagonal: true` is specified, or if we ask for renormalization to unit diagonal (:code:`renormalize to unit diagonal: true`) 

The localization matrix provided is then decomposed as :math:`\mathbf{L}=\mathbf{UU}^T`.
Only the :math:`m` leading eigenvectors in :math:`\mathbf{U}` are kept, where :math:`m` is specified from yaml by :code:`number of vertical modes`, :math:`1\leq  m\leq n_z`.
The percentage of explained variance (in the pressure-weighted space, see next section) is printed to the info log. 

Pressure weights
----------------
Optionally, different weights can be given to different vertical levels in the selection of leading eigenvectors. 
In this case, a low-rank reconstruction of the vertical localization matrix is more accurate for levels with higher weights, but less accurate for levels with lower weights.

The weights :math:`\mathbf{w}` are computed as the square root of the air mass associated to each layer.
This air mass is computed from the :code:`pressure field name in pressure file` variable of the :code:`pressure file name` netcdf file. 
This variable should give the pressure at the interfaces between the :math:`n_z` levels, so must have a shape of :math:`n_z+1`.
The air mass for one level is computed as the pressure thicknes, i.e. the pressure difference between the two associated interfaces. 

From weights :math:`\mathbf{w}`, the eigen decomposition is performed on :math:`\mathbf{WLW}` with :math:`\mathbf{W}` the diagonal matrix with diagonal :math:`\mathbf{w}`.
This may change the modes and their ordering. 

From the approximation :math:`\mathbf{WLW}\approx \mathbf{UU}^T`, we deduce the approximation :math:`\mathbf{L}\approx(\mathbf{W}^{-1}\mathbf{U})(\mathbf{W}^{-1}\mathbf{U})^T`, so the square root localization matrix is :math:`\mathbf{U}\leftarrow\mathbf{W}^{-1}\mathbf{U}`.

Visualization of the truncated localization
-------------------------------------------
If the yaml key `output file name` is provided, a netcdf file is written with variables
  - "air_mass_weights": :math:`\mathbf{w}`
  - "target_localization": :math:`\mathbf{L}`
  - "low_rank_localization": :math:`\mathbf{UU}^T`
  - "localization_square_root": :math:`\mathbf{U}`


Warnings
--------
**Vertical structure:**  this block assumes all active variables have the same vertical structure.
If this is not the case, for instance because of vertical staggering, extra top or bottom level etc, this should be taken care of outside the block. 
Possible solutions for this include:

* Run the block several times, once for each group of variables, each time with dedicated localization and active variables.
* Use a vertical interpolation outside of the localization block, to get all variables into the same vertical grid. This should ideally come with a renormalization step. 

**Multivariate localization:**  this block only performs univariate localization, i.e. removes all cross-variable signal. 
Multivariate localization is still possible by summing or duplicating variables before or after this block.


Possible further improvements
-----------------------------

1. This SABER block could be improved by allowing the vertical localization to be analytically defined from a list of vertical localization lengths. 
2. For efficiency, we could have a (very) slight gain at construction time by directly reading the square root of the localization matrix instead of computing it from the full localization. 
3. Applying different localization matrices to different variables can only be done by applying the block multiple times, sequentially, to each group of variables. A parallel implementation could be envisioned. 
