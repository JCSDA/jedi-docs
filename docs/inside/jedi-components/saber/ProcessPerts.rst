.. _ProcessPerts:

The *ProcessPerts* Application
==============================

.. toctree::
   :hidden:

   SPECTRALB_analyticalFilter.rst
   SPECTRALB_sphericalHarmonicTransform.rst

Main idea
---------

The main idea is to calculate processed background perturbations and write them to files. This calculation can occur before the time critical part of the operational scheme of a weather forecasting cycling system.  Then the processed perturbations can be read into the ensemble part of the background error covariance model in the standard oops *variational* application.

Inputs
------

The initial implementation supports either background perturbations being read in, or an ensemble of states being read. With the latter we calculate the ensemble mean first and calculate the raw background perturbations by subtracting each ensemble member state from the ensemble mean.

Note that there are error traps in the application to ensure that we don't read both ensemble perturbations and an ensemble of states.

Bands
-----

Band options
^^^^^^^^^^^^

A sequence of bands is defined by the user, each band containing:

- A filter, mandatory except the last band (see :ref:`Missing filter <missing-filter>`) and the filter options
- Output options to perform diagnostics and write out the processed perturbations into files.

Each filter is a SABER outer blockchain. The geometry and variables in processed perturbations can thus be different from geometry and variables in the input perturbations.

.. _missing-filter:

Missing filter
^^^^^^^^^^^^^^

For the last band, the filter is optional. If it is missing, the residual of all the previous filters is used instead:

.. math::
  F_n = I - (F_1 + F_2 + ... + F_{n-1})

This ensures that the sum of all the bands in processed perturbation is equal to the input perturbation.

Recursive filters
^^^^^^^^^^^^^^^^^

At the root level, the key :code:`recursive filters: true` indicates that each filter is applied on the residual of the previous filter. Starting from the input perturbation :math:`x_0`:

.. math::
  x_1 &= F_1 x_0 \\
  x'_1 &= (I - F_1) x_0 \\
  x_2 &= F_2 x'_1 \\
  x'_2 &= (I - F_2) x'_1 \\
  x_3 &= F_3 x'_2 \\
  x'_3 &= (I - F_3) x'_2 \\
  ... & \\
  x_n &= F_n x'_{n-1} \\

This option can be useful (although not necessary) if a sequence of low-pass or high-pass filters are used, instead of band-pass filters.

Parameters at filter level
^^^^^^^^^^^^^^^^^^^^^^^^^^
At the filter level, it is possible to use the key :code:`use residual from filter: true` to apply :math:`I - F_i` instead of the filter :math:`F_i` on the input perturbation.

This options can be useful to transform a low-pass filter (e.g. diffusion-based) into a high-pass filter.

Parameters at outer block level
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Two useful parameters available for the outer blocks within a filter block chain are:

- :code:`right inverse: true`: apply the right inverse of the outer block
- :code:`reuse already created block: true`: reuse an outer block that has already been created (outer blocks are created in backward order), to avoid duplication. This key can be combined with :code:`right inverse` key: shared blocks can be used in direct or right inverse mode independently.

Examples of yaml files
----------------------

Spectral analytical filter as a low-pass filter
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: yaml

  geometry:
    ... #this sets the 'outer most' geometry (coming from the ensemble)
  background:
    ...
  ensemble:
    members:
      ...
  input variables: [list-of-vars]
  bands:
  - band:
      filter:
      - saber block name: <INTERPOLATION FROM GAUSSIAN TO MODEL GRID>
        right inverse: true
        reuse already created block: true
      - saber block name: spectral to gauss
        right inverse: true
        reuse already created block: true
      - saber block name: spectral analytical filter
        function:
          horizontal daley length: 5000e3 # filter length scale
      - saber block name: spectral to gauss
      - saber block name: <INTERPOLATION FROM GAUSSIAN TO MODEL GRID>
    output:
      model write:
        filepath: <output_directory_for_application>/low_pass_%MEM%
        member pattern: '%MEM%'
  - output:
      model write:
        filepath: <output_directory_for_application>/high_pass_%MEM%
        member pattern: '%MEM%'

See this SABER test for the full example: `process_perts_from_csdual_states_1.yaml <https://github.com/JCSDA/saber/blob/develop/test/testinput/process_perts_from_csdual_states_1.yaml>`_

In the example above we have 2 bands. The first band has 5 outer blocks, but actually 3 independent outer blocks:

- `<INTERPOLATION FROM GAUSSIAN TO MODEL GRID>`: an interpolation from the Gaussian grid to the model grid. We first apply the right inverse of this block to go from the model grid to the Gaussian grid with :code:`right inverse: true`, and with the :code:`reuse already created block: true` activated to share an already created block. The second occurrence in the blockchain is applied in direct mode, and is the block actually created. For a specific example, let us denote the interpolation from a Gaussian mesh to a cubed-sphere mesh as :math:`I_{g2cs}`. The right inverse in this case is only approximate :math:`I_{cs2g}` as it is an interpolation from a cubed-sphere mesh to a Gaussian mesh.
- :ref:`spectral to gauss <spectralb_spherical_harmonic_transform>`: this block is also present twice, as the previous one. The first occurrence is a right inverse (direct spectral transform) and the second occurrence is a direct application (inverse spectral transform). Let the transformation from spectral space to Gaussian grid be :math:`S_H`  and the inverse :math:`S_H^{-1}`
- :ref:`spectral analytic filter <spectralb_analytical_filter>`: this diagonal matrix in spectral space is denoted :math:`S_F`. Here it is setup as a low-pass filter with a given filtering length-scale.

Let :math:`x_0` be the input perturbation, the filtered perturbation :math:`x_1` from the first band is:

.. math::

  x_1 =  I_{g2cs} S_H  S_F S_H^{-1}  I_{cs2g} x_0

Since the second band has no :code:`band` section and thus no filter, the residual of the previous bands is applied:

.. math::

  x_2 =  x_0 - x_1

Spectral analytical filter as a recursive high-pass filter
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: yaml

  geometry:
    ... #this sets the 'outer most' geometry (coming from the ensemble)
  background:
    ...
  ensemble:
    members:
      ...
  input variables: [list-of-vars]
  bands:
  - band:
      filter:
      - saber block name: <INTERPOLATION FROM GAUSSIAN TO MODEL GRID>
        right inverse: true
        reuse already created block: true
      - saber block name: spectral to gauss
        right inverse: true
        reuse already created block: true
      - saber block name: spectral analytical filter
        function:
          horizontal daley length: 2000e3 # filter length scale
      - saber block name: spectral to gauss
      - saber block name: <INTERPOLATION FROM GAUSSIAN TO MODEL GRID>
      use residual from filter: true
    output:
      model write:
        filepath: <output_directory_for_application>/band_1_%MEM%
        member pattern: '%MEM%'
  - band:
      filter:
      - saber block name: <INTERPOLATION FROM GAUSSIAN TO MODEL GRID>
        right inverse: true
        reuse already created block: true
      - saber block name: spectral to gauss
        right inverse: true
        reuse already created block: true
      - saber block name: spectral analytical filter
        function:
          horizontal daley length: 5000e3 # filter length scale
      - saber block name: spectral to gauss
      - saber block name: <INTERPOLATION FROM GAUSSIAN TO MODEL GRID>
      use residual from filter: true
    output:
      model write:
        filepath: <output_directory_for_application>/band_2_%MEM%
        member pattern: '%MEM%'
  - output:
      model write:
        filepath: <output_directory_for_application>/band_3_%MEM%
        member pattern: '%MEM%'
  recursive filters: true

In this case the 3 bands are used recursively, with:

- A first high-pass filter (complementary of a low-pass filter of length-scale 2000 km).
- A second high-pass filter (complementary of a low-pass filter of length-scale 5000 km).
- A last band complementary to the two previous ones.

Spectral analytical filter as a band-pass filter
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: yaml

  geometry:
    ... #this sets the 'outer most' geometry (coming from the ensemble)
  background:
    ...
  ensemble:
    members:
      ...
  input variables: &vars [list-of-vars]
  bands:
  - band:
      filter:
      - saber block name: <INTERPOLATION FROM GAUSSIAN TO MODEL GRID>
        right inverse: true
        reuse already created block: true
      - saber block name: spectral to gauss
        right inverse: true
        reuse already created block: true
      - saber block name: spectral analytical filter
        function:
          shape: waveband filter
          ... # filter parameters (min/peak/max) for lowest waveband
        preserving variance: true
        active variables: *vars # set at "input variables" using '&' 
      - saber block name: spectral to gauss
      - saber block name: write fields
        output path: <output_directory_for_application>/
        multiply fset filename: wb1_F14_inc # root name of file written by
                                            # multiply() method write fields block
      - saber block name: <INTERPOLATION FROM GAUSSIAN TO MODEL GRID>
    output:
      model write:
        filepath: <output_directory_for_application>/wb1_<GRID_INFO>_mb%MEM%_inc
        member pattern: '%MEM%'
  - band: #BAND 2
      filter:
      - saber block name: <INTERPOLATION FROM GAUSSIAN TO MODEL GRID>
        right inverse: true
        reuse already created block: true
      - saber block name: spectral to gauss
        right inverse: true
        reuse already created block: true
      - saber block name: spectral analytical filter
        function:
          shape: waveband filter
          ... # filter parameters (min/peak/max) for middle waveband
        preserving variance: true
        active variables: *vars
      - saber block name: spectral to gauss
        active variables: *vars
      - saber block name: write fields
        output path: <output_directory_for_application>
        multiply fset filename: wb2_F14_inc # root name of file written by
                                            # multiply() method write fields block
      - saber block name: <INTERPOLATION FROM GAUSSIAN TO MODEL GRID>
    output:
      model write:
        filepath: <output_directory_for_application>/wb2_<GRID_INFO>_mb%MEM%_inc
        member pattern: '%MEM%'
  - band: #BAND 3
      filter:
      - saber block name: <INTERPOLATION FROM GAUSSIAN TO MODEL GRID>
        right inverse: true
        reuse already created block: true
      - saber block name: spectral to gauss
        right inverse: true
        reuse already created block: true
      - saber block name: spectral analytical filter
        function:
          shape: waveband filter
          ... # filter parameters (min/peak/max) for highest waveband
          waveband max: <2N - 1> # last waveband max need to be 2N - 1, where N
                                 # is gaussian grid resolution e.g. F<N> or N<N>
        preserving variance: true
        complement filter: true
        active variables: *vars
      - saber block name: spectral to gauss
        active variables: *vars
      - saber block name: <INTERPOLATION FROM GAUSSIAN TO MODEL GRID>
      use residual from filter: true
    output:
      generic write:
        filepath: <output_directory_for_application>/wb3_%GRID%_mb%MEM%_inc
        member pattern: '%MEM%'
        grid pattern: '%GRID%'

See this SABER test for the full example: `process_perts_from_csdual_states_2.yaml <https://github.com/JCSDA/saber/blob/develop/test/testinput/process_perts_from_csdual_states_2.yaml>`_

The idea here is to allow us to split the increment into 3 bands, with an explicit band-filter for each band. The split of the bands is done in such a way that if the original increment was on a Gaussian mesh, the variance of that increment will be the sum of the variance of the associated waveband increments. This is true even though the wavebands overlap because we are assuming that there is no cross-covariance between the waveband increments. It is activated with the key :code:`preserving variance: true`. If you want to do spatial-dependent localization without spectral localization you should set :code:`preserving variance: false` (default value).

The :ref:`spectralb_analytical_filter` uses a function ``waveband filter`` which as a default has a triangular function in terms of total wavenumber with a peak value at ``waveband peak`` that linearly drops to zero and ``waveband min`` and ``waveband max``. For the lowest waveband the wavenumbers between and including ``waveband min`` and ``waveband peak`` are constant. Similarly for any waveband that includes the highest wavenumber, the wavenumbers between  `waveband max` and `waveband peak` is constant. When ``preserving variance: true`` we use the square root of the triangular function.

In addition to this, in this yaml, there is something special done for the final waveband increment. It is called here the double subtraction method. By setting ``complement filter: true`` we first calculate not the high-pass filter directly but instead the low-pass filter complement.  Then by setting ``use residual from filter: true`` we subtract the low pass filter increment from the original increment.  The advantage of this approach is that we avoid interpolating the high-pass filter increment onto the model grid. We know that the interpolation can smooth small-scale features and we want to be able to avoid this. See the page for the :ref:`spectralb_analytical_filter` Block for more information on its filter parameters under the ``shape`` yaml key.

Note that we do not need to store all the waveband increments at the model grid resolution, we can also store the lower wavebands at lower Gaussian resolutions and reduce the size of files. For wavebands 1 to n-1 the increment from each band :math:`x_i` is:

.. math::

  x_i =  I_{g2cs} S_H  S_F^b S_F^{Tb}  S_H^{-1}  I_{cs2g} x_0

or if we express it at lower Gaussian resolutions:

.. math::

  x_i' =  S_H S_F S_H^{-1} I_{cs2g} x_0

The :code:`write fields` outer block can used to write the processed perturbation on the Gaussian grid, before the final interpolation to the model grid.

The final high-pass filtered perturbation is given by the double subraction method, namely:

.. math::

  x_n =  (I - I_{g2cs} S_H  (I - S_F)  S_H^{-1}  I_{cs2g}) x_0

Available families of filters
------------------------------

Different families of outer blocks can be used as filters:

- :code:`spectralb` family: the :code:`SpectralAnalyticalFilter` block in global spectral space, along with :code:`SpectralToGauss` block for the spectral transforms and possibly interpolations from the model grid to the Gaussian grid.

- :code:`bifourier` family: the :code:`BifourierAnalyticalFilter` block in regional spectral space, along with :code:`BifourierSpectralToGrid` and :code:`BifourierGridToSpectral` blocks for the spectral transforms.

- :code:`diffusion` family: the :code:`DiffusionFilter` block on global regular grids.

- :code:`bump` family: the :code:`BUMP_NICASFilter` on any grid, using the NICAS method with a slightly different normalization to make it a filter.

