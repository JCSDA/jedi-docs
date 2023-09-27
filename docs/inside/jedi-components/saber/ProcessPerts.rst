.. _ProcessPerts:

.. toctree::
   :hidden:

   SPECTRALB_analyticalFilter.rst
   SPECTRALB_sphericalHarmonicTransform.rst


The *ProcessPerts* Application
==============================


Typical yaml
------------

.. code-block:: yaml
 
  geometry:
    function space: NodeColumns
    grid:
      name: CS-LFR-15
    partitioner: cubedsphere
    groups:
    - variables: &vars
      - streamfunction
      - velocity_potential
      - unbalanced_pressure
      - moisture_control_variable
      levels: 70
    halo: 1
  background:
    date: '2010-01-01T12:00:00Z'
    state variables: *vars
  saber filter blocks:
    saber central block:
      saber block name: ID
    saber outer blocks:
    - saber block name: spectral analytical filter
      function:
        horizontal daley length: 5008e3
      normalize filter variance: false
    - saber block name: spectral to gauss
      filter mode: true # instead of running the adjoint code it runs the inverse
    - saber block name: gauss to cubed-sphere-dual
      gauss grid uid: F45
      filter mode: true # instead of running the adjoint code it runs the inverse
  date: '2010-01-01T12:00:00Z'
  input variables: *vars
  ensemble:
    members:
    - date: '2010-01-01T12:00:00Z'
      filepath: testdata/randomization_csdual_sqrtspectralb/randomized_csdual_mb1
      state variables: *vars
    - date: '2010-01-01T12:00:00Z'
      filepath: testdata/randomization_csdual_sqrtspectralb/randomized_csdual_mb2
      state variables: *vars
  low pass perturbations:
    filepath: testdata/process_perts_from_csdual_states_1/low_pass
  output perturbations:
    filepath: testdata/process_perts_from_csdual_states_1/high_pass
 
Main idea
---------
The main idea is to calculate processed background perturbations and write them to files. This calculation can occur before the time critical part of the operational scheme of a weather forecasting cycling system.  Then the processed perturbations can be read into the ensemble part of the background error covariance model in the standard oops *variational* application.

The first version of this application copies each background perturbation and then applies a low pass filter to it.  Thereafter the low pass filtered perturbation is subtracted from the  original perturbation to produce a high pass filtered perturbation.  Each high-pass filtered perturbation is written to file.  Optionally, based on the yaml configuration, the low pass filtered perturbations can be also dumped to file.


Analytical formulation
----------------------
The *saber filter blocks* section of the yaml applies the low pass filter.

In the example above we have 3 saber outer blocks:

- :ref:`spectral analytic filter <spectralb_analytical_filter>`: The full filter is defined by the combined effect of the main transform :math:`S_F` with its adjoint :math:`S_F^T` such that :math:`Filter = S_F S_F^T`.  
- :ref:`spectral to gauss <spectralb_spherical_harmonic_transform>`: Notice that for this block we are setting :code:`filter mode: true` which has the effect of running the left inverse i.e. the direct transform instead of the adjoint. Let the transformation from spectral space to gaussian grid be :math:`S_H`  and the inverse :math:`S_H^{-1}`
- `gauss to cubed-sphere interpolation`: as with  `spectral to gauss`, :code:`filter mode: true` and the left inverse is used. Let us denote the interpolation from gauss to cubed sphere as :math:`I_{g2cs}`. The left inverse in this case is only approximate :math:`I_{cs2g}` as it is an interpolation from cubed-sphere mesh to a Gaussian mesh.

Let :math:`x'` be the original background perturbation.

So the low pass filtered perturbation :math:`x_l'`  is:

.. math::

  x_l' =  I_{g2cs} S_H  S_F S_F^T  S_H^{-1}  I_{cs2g} x'

Also the high pass filtered perturbation  :math:`x_h'` is

.. math::

  x_h' =  x' - x_l'

Inputs
------

The initial implementation supports either background perturbations being read in, or an ensemble of states being read. With the latter we calculate the ensemble mean first and calculate the raw background perturbations by subtracting each ensemble member state from the ensemble mean.

Note that there are error traps in the application to ensure that we don't read both ensemble perturbations and an ensemble of states.


Future
------
The intention is to extend this application so that it can deal with waveband applications, where each background perturbation is split into multiple processed perturbations, each with a different geometry resolution.
