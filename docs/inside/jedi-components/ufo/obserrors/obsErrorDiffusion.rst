.. _ufoObsErrorDiffusion:

Correlated Observation Error Covariance with Diffusion
======================================================

The diffusion-based correlated R operator in UFO applies the :code:`oops::Diffusion`
capability similar to how it is implemented in SABER by the :ref:`diffusion` block.
Both operators use a forward stepping finite-difference method to propagate error
covariances to nearby locations (see :cite:`Weaver2020` for more details of the
implementation, though the paper discusses *implicit* diffusion the calibration
process discussed in the reference is implemented by this operator).

When initialized, the UFO operator constructs a mesh from the observation locations
read from the observations' :code:`ioda::ObsSpace` (see figure :ref:`below <mesh_fig>`).
Diffusion will occur along edges that connect observation locations. 

.. _mesh_fig:
.. figure:: images/mesh.png
   :scale: 25%
   :align: center

   Meshing produced from a thinned set of geostationary ``brightnessTemperature`` observations.
   See figure :ref:`below <diffusionDirac_fig>` for the spatial locations of the observations


The result of the application of the operator to a single observation (but with the mesh produced
from the full set of observations shown in figure :ref:`below <mesh_fig>`) is shown below:

.. _diffusionDirac_fig:
.. figure:: images/diffusionDirac.png
   :scale: 40%
   :align: center

   The result of the diffusion operator being applied to a 'dirac' obsVector (a vector of all zero except for a single one) using the mesh from :ref:`above <mesh_fig>`.

The options for the operator include:

* :code:`correlation variable names`: the names of variables to which the operator will be applied. **Currently, this operator is only supported for use with a single variable.**
* :code:`correlation lengthscale`: length scale corresponding to the standard deviation of the guassian profile this operator will emulate applying.
* :code:`normalization iterations`: number of iterations used to calculate the set of grid-dependent normalization coefficients. See the documentation of the SABER :ref:`diffusion` block for more details on the normalization procedure. For an operational/scientifically valid situation a value of at least ~10000 is recommended.

Below is an example of a YAML configuration of the diffusion-based R operator:  

.. code-block:: yaml

  obs error:
    covariance model: diffusion
    correlation variable names: [brightnessTemperature]
    obs channels: [11]  #redundant with channels in obsSpace parameters
    correlation lengthscale: 200000. # meters
    normalization iterations: 10000

