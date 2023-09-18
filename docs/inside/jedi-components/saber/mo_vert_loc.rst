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
        pressure file name: testdata/ptheta_bar_mean.nc  # Optional
        pressure field name in pressure file: Ptheta_bar_Mean  # Optional
      number of vertical modes: 7
      output file name: testdata/vertical_localization.nc  # Optional

The :code:`localization data` section gives the input information on the vertical localization :math:`\mathbf{L}` to apply.
The netcdf file provided to :code:`localization matrix file name` should have :math:`\mathbf{L}` as a 2D variable (:code:`localization field name in file`) of shape :math:`n_z\times n_z` where :math:`n_z` is the number of vertical levels. 
No check is done to check that the provided localization is symmetric, or that it has a unit diagonal. 

The localization matrix provided is then decomposed as :math:`\mathbf{L}=\mathbf{UU}^T`.
Only the :math:`m` leading eigenvectors in :math:`\mathbf{U}` are kept, where :math:`m` is specified from yaml by :code:`number of vertical modes`, :math:`1\leq  m\leq n_z`.
The percentage of explained variance (in the pressure-weighted space, see next section) is printed to the info log. 

Pressure weights
----------------
Optionally, different weights can be given to different vertical levels in the selection of leading eigenvectors. 
In this case, a low-rank reconstruction of the vertical localization matrix is more accurate for levels with higher weigths, but less accurate for levels with lower weights.

The weights :math:`\mathbf{w}` are computed as the square root of the air mass associated to each layer.
This air mass is computed from the :code:`pressure field name in pressure file` variable of the `pressure file name` netcdf file. 
This variable should have a shape of :math:`n_z+1`, and the air mass for one level is computed from the pressure differences. 

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

Possible further improvements
-----------------------------
This SABER block could be improved by allowing the vertical localization to be analytically defined from a list of vertical localization lengths. 

For efficiency, we could have a (very) slight gain at construction time by directly reading the square root of the localization matrix instead of computing it from the full localization. 