.. _ProcessPerts:

.. toctree::
   :hidden:

   SPECTRALB_analyticalFilter.rst
   SPECTRALB_sphericalHarmonicTransform.rst


The *ProcessPerts* Application
==============================

Main idea
---------

The main idea is to calculate processed background perturbations and write them to files. This calculation can occur before the time critical part of the operational scheme of a weather forecasting cycling system.  Then the processed perturbations can be read into the ensemble part of the background error covariance model in the standard oops *variational* application.

The application can run in either the :ref:`High-pass Filter Mode <high-pass-mode>` or the :ref:`Waveband Filter Mode <waveband-mode>`

Inputs
------

The initial implementation supports either background perturbations being read in, or an ensemble of states being read. With the latter we calculate the ensemble mean first and calculate the raw background perturbations by subtracting each ensemble member state from the ensemble mean.

Note that there are error traps in the application to ensure that we don't read both ensemble perturbations and an ensemble of states.

.. _high-pass-mode:

Main idea (high-pass filter mode)
---------------------------------

The first version of this application copies each background perturbation and then applies a low pass filter to it.  Thereafter the low-pass filtered perturbation is subtracted from the original perturbation to produce a high-pass filtered perturbation.  Each high-pass filtered perturbation is written to file.  Optionally, based on the yaml configuration, the low pass filtered perturbations can be also dumped to the file.


Typical yaml (high-pass filter mode)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

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
        saber central block:
          saber block name: ID
        saber outer blocks:
        - saber block name: spectral analytical filter
          function:
            horizontal daley length: 5008e3 #localization length scale
        - saber block name: spectral to gauss
          filter mode: true # instead of running the adjoint code it runs the inverse
        - saber block name: <INTERPOLATION BETWEEN MODEL & GAUSSIAN GRID>
          filter mode: true # this must be set in interopolation block to get correct results
                            # instead of running the adjoint code it runs the inverse
    output:
      model write:
        filepath: <output_directory_for_application>/low_pass_%MEM%
        member pattern: '%MEM%'
  - band:
      residual increment from previous bands: true
    output:
      model write:
        filepath: <output_directory_for_application>/high_pass_%MEM%
        member pattern: '%MEM%'

See this SABER test for the full example: `process_perts_from_csdual_states_1.yaml <https://github.com/JCSDA/saber/blob/develop/test/testinput/process_perts_from_csdual_states_1.yaml>`_


Analytical formulation (high-pass filter mode)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The *filter* section of the yaml applies the low pass filter.

In the example above we have 2 bands. The first band has 3 saber outer blocks:

- :ref:`spectral analytic filter <spectralb_analytical_filter>`: The full filter is defined by the combined effect of the main transform :math:`S_F` with its adjoint :math:`S_F^T` such that :math:`Filter = S_F S_F^T`.  
- :ref:`spectral to gauss <spectralb_spherical_harmonic_transform>`: Notice that for this block we are setting :code:`filter mode: true` which has the effect of running the left inverse i.e. the direct transform instead of the adjoint. Let the transformation from spectral space to Gaussian grid be :math:`S_H`  and the inverse :math:`S_H^{-1}`
- `<INTEROPLATION>`: an interpolation between the ensemble/model geometry to a Gaussian grid. As with `spectral to gauss`, we must have :code:`filter mode: true` so the left inverse is used instead of the adjoint. For a specific example, let us denote the interpolation from a Gaussian mesh to a cubed-sphere mesh as :math:`I_{g2cs}`. The left inverse in this case is only approximate :math:`I_{cs2g}` as it is an interpolation from a cubed-sphere mesh to a Gaussian mesh.

Let :math:`x'` be the original background perturbation.

So the low pass filtered perturbation :math:`x_l'` from the first band is:

.. math::

  x_l' =  I_{g2cs} S_H  S_F S_F^T  S_H^{-1}  I_{cs2g} x'

The high-pass filtered perturbation :math:`x_h'` is given by the second band, which subtracts the sum of all the previous bands' increments from the original increment. 

.. math::

  x_h' =  x' - x_l'

.. _waveband-mode:

Main idea (waveband filter mode)
--------------------------------

The idea here is to allow us to split the increment into more than 2 bands. In the example below there are 3 bands. The split of the bands is done in such a way that if the original increment was on a Gaussian mesh, the variance of that increment will be the sum of the variance of the associated waveband increments. (Even though the wavebands overlap we are assuming that there is no cross-covariance between the waveband increments.) The main switch enforcing this is  `preserving variance: true`.  If you want to do spatial-dependent localization without spectral localization you should set `preserving variance: false`.

The `spectral analytical filter` uses a function `waveband filter` which as a default has a triangular function in terms of total wavenumber with a peak value at `waveband peak` that linearly drops to zero and `waveband min` and `waveband max`. For the lowest waveband the wavenumbers between and including `waveband min` and `waveband peak` are constant. Similarly for any waveband that includes the highest wavenumber, the wavenumbers between  `waveband max` and `waveband peak` is constant. When `preserving variance: true` we use the square root of the triangular function.

In addition to this, in this yaml, there is something special done for the final waveband increment. It is called here the double subtraction method. By setting `complement filter: true` we first calculate not the high-pass filter directly but instead the low-pass filter complement.  Then by setting `use residual from filter: true` we subtract the low pass filter increment from the original increment.  The advantage of this approach is that we avoid interpolating the high-pass filter increment onto the model grid. We know that the interpolation can smooth small-scale features and we want to be able to avoid this.

Note that we do not need to store all the waveband increments at the model grid resolution, we can also store the lower wavebands at lower Gaussian resolutions and reduce the size of files.

Typical yaml (waveband filter mode)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

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
  - band: #BAND 1
      filter:
        saber central block:
          saber block name: ID
        saber outer blocks:
        - saber block name: spectral analytical filter
          function:
            shape: waveband filter
            ... # filter parameters (min/peak/max) for lowest waveband
          preserving variance: true
          active variables: *vars # set at "input variables" using '&' 
        - saber block name: spectral to gauss
          active variables: *vars
          filter mode: true # instead of running the adjoint code it runs the inverse
        - saber block name: write fields
          output path: <output_directory_for_application>/
          multiply fset filename: wb1_F14_inc # root name of file written by
                                              # multiply() method write fields block
        - saber block name: <INTERPOLATION BETWEEN ENSEMBLE & GAUSSIAN GRID>
          filter mode: true # this must be set in interopolation block to get correct results
                            # instead of running the adjoint code it runs the inverse
    output:
      model write:
        filepath: <output_directory_for_application>/wb1_<GRID_INFO>_mb%MEM%_inc
        member pattern: '%MEM%'
  - band: #BAND 2
      filter:
        saber central block:
          saber block name: ID
        saber outer blocks:
        - saber block name: spectral analytical filter
          function:
            shape: waveband filter
            ... # filter parameters (min/peak/max) for middle waveband
          preserving variance: true
          active variables: *vars
        - saber block name: spectral to gauss
          active variables: *vars
          filter mode: true # instead of running the adjoint code it runs the inverse
        - saber block name: write fields
          output path: <output_directory_for_application>
          multiply fset filename: wb2_F14_inc # root name of file written by
                                              # multiply() method write fields block
        - saber block name: <INTERPOLATION BETWEEN ENSEMBLE & GAUSSIAN GRID>
          filter mode: true # this must be set in interopolation block to get correct results
                            # instead of running the adjoint code it runs the inverse
    output:
      model write:
        filepath: <output_directory_for_application>/wb2_<GRID_INFO>_mb%MEM%_inc
        member pattern: '%MEM%'
  - band: #BAND 3
      filter:
        saber central block:
          saber block name: ID
        saber outer blocks:
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
          filter mode: true # instead of running the adjoint code it runs the inverse
        - saber block name: <INTERPOLATION BETWEEN ENSEMBLE & GAUSSIAN GRID>
          filter mode: true # this must be set in interopolation block to get correct results
                            # instead of running the adjoint code it runs the inverse
      use residual from filter: true
    output:
      generic write:
        filepath: <output_directory_for_application>/wb3_%GRID%_mb%MEM%_inc
        member pattern: '%MEM%'
        grid pattern: '%GRID%'

See this SABER test for the full example: `process_perts_from_csdual_states_2.yaml <https://github.com/JCSDA/saber/blob/develop/test/testinput/process_perts_from_csdual_states_2.yaml>`_

Analytical formulation (waveband filter mode)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

For wavebands :math:`b = 1 \cdots nbands -1` the increment from each band :math:`x_b'` is (again using a Gaussian<->Cubed-Sphere interpolation as an example):

.. math::

  x_b' =  I_{g2cs} S_H  S_F^b S_F^{Tb}  S_H^{-1}  I_{cs2g} x'

if we want it in model space or

.. math::

  x_b' =  S_H  S_F^b S_F^{Tb}  S_H^{-1}  I_{cs2g} x'

if we want it at lower Gaussian resolutions. (We use the `write fields` saber block for this).

The high-pass filtered perturbation :math:`x_{nbands}'` is given by the double subraction method, namely

.. math::

  x_{nbands}' =  x' - I_{g2cs} S_H  S_F^{{*}b} S_F^{{*}b}  S_H^{-1}  I_{cs2g} x'

where the :math:`{*}` indicates that the complement filter for that waveband is used.
