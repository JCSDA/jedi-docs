.. _top-oops-toymodels-model_qg:

Quasi-geostrophic model
=======================

Introduction
------------

This section describes the multi-layer quasi-geostrophic model, intended for use as a toy system with which to conduct idealized studies of data assimilation methods. In developing the model, the emphasis has been placed on speed and convenience rather than accuracy and conservation.

The continuous equations
------------------------

The equations of the two-level model are given by Fandry and Leslie (1984) (see also Pedlosky, 1979). A multi-layer version is given in Carton *et al.* (2004). They are based on the conservation of potential vorticity in each of the :math:`n_z` layers:

.. math::
  \frac{{\rm D}q_i}{{\rm D}t} = 0
  :label: eq:toy-model_qg_conservation

where :math:`q_i` denote the quasi-geostrophic potential vorticity in each layer:

.. math::
  q_i = \nabla^2 \psi_i + \mathcal{F}_{i,i-1} (\psi_{i-1} -\psi_i) + \mathcal{F}_{i,i+1}(\psi_{i+1}-\psi_i) + \beta y + R_i
  :label: eq:toy-model_qg_q

Here, :math:`\beta` is the northward derivative of the Coriolis parameter, and :math:`R_i` represents orography or heating for the bottom layer (zero for other layers). The :math:`\mathcal{F}` factor is given by:

.. math::
   \mathcal{F}_{i,i \pm 1} = (-1)^{\pm 1} \frac{f_0^2 \theta_0}{g H_i(\theta_{i \pm 1} - \theta_i)}

where :math:`f_0` is the central Coriolis parameter, :math:`\theta_0` the average potential temperature, :math:`\theta_i` the potential temperature of each layer, :math:`g` the gravity and :math:`H_i` the thickness of each layer. In our setup, the potential temperature difference between successive layers is assumed to be constant: :math:`\theta_{i \pm 1} - \theta_i = \pm \Delta \theta`.

Potential vorticity inversion
-----------------------------

Equation :eq:`eq:toy-model_qg_q` can be rewritten in vector/matrix form, where each element of the vectors represents a given layer:

.. math::
  \mathbf{q} = \nabla^2 \boldsymbol{\psi} + \mathbf{F} \boldsymbol{\psi} + \beta y \mathbf{1} + \mathbf{R}
  :label: eq:toy-model_qg_q_vec

where :math:`\mathbf{1}` is a vector with all elements equal to 1 and :math:`\mathbf{F}` is the matrix defined as follows:

* For :math:`i = 1`:

.. math::
  F_{1,1} & = -\mathcal{F}_{1,2} \\
  F_{1,2} & = \mathcal{F}_{1,2}

* For :math:`1 < i < n_z`:

.. math::
  F_{i,i-1} & = \mathcal{F}_{i,i-1} \\
  F_{i,i} & = -(\mathcal{F}_{i,i-1}+\mathcal{F}_{i,i+1}) \\
  F_{i,i+1} & = \mathcal{F}_{i,i+1}

* For :math:`i = n_z`:

.. math::
  F_{n_z,n_z-1} & = \mathcal{F}_{n_z,n_z-1} \\
  F_{n_z,n_z} & = -\mathcal{F}_{n_z,n_z-1}

The matrix :math:`\mathbf{F}` can be diagonalized into:

.. math::
  \mathbf{F} = \mathbf{P} \mathbf{D} \mathbf{P}^{-1}

Keeping all :math:`\boldsymbol{\psi}`-related elements of equation :eq:`eq:toy-model_qg_q_vec` on the left-hand side and left-multiplying by :math:`\mathbf{P}^{-1}`, we get:

.. math::
  \nabla^2 \mathbf{P}^{-1} \boldsymbol{\psi} + \mathbf{D} \mathbf{P}^{-1} \boldsymbol{\psi} = \mathbf{P}^{-1} (\mathbf{q} - (\beta y \mathbf{1} + \mathbf{R}))

which can be written:

.. math::
  \nabla^2 \boldsymbol{\psi}' + \mathbf{D} \boldsymbol{\psi}' = \mathbf{r}
  :label: eq:toy-model_qg_2d_helmholtz_eqn_vec

where the new variable is :math:`\boldsymbol{\psi}' = \mathbf{P}^{-1} \boldsymbol{\psi}` and the right-hand side is given by :math:`\mathbf{r} = \mathbf{P}^{-1} (\mathbf{q} - (\beta y \mathbf{1} + \mathbf{R}))`. Since :math:`\mathbf{D}` is diagonal, equation :eq:`eq:toy-model_qg_2d_helmholtz_eqn_vec` can be written for each layer:

.. math::
  \nabla^2 \psi'_i + D_{i,i} \psi'_i = r_i
  :label: eq:toy-model_qg_2d_helmholtz_eqn

This is a two-dimensional Helmholtz equation, which can be solved for :math:`\psi'_i`. Once :math:`\psi'_i` is known for all layers, it is easy to get back to :math:`\boldsymbol{\psi} = \mathbf{P} \boldsymbol{\psi}'`.


Solution algorithm
------------------

The rectangular model domain is assumed to be cyclic in the zonal direction, and the meridional velocity is assumed to vanish one grid space to the north and south of the domain.

The prognostic variable can be either the streamfunction or the potential vorticity.

The time-stepping algorithm is designed for speed rather than accuracy, and is accurate only to first-order in :math:`\Delta t`. It has the practical advantage that a timestep may be performed given information at only a single time-level. The prognostic variable of the model can be either streamfunction or potential vorticity. The timestep is split as follows:

1. **Setup**

  At the beginning of each timestep, values of streamfunction, potential vorticity and wind must be available:

  * If the streamfunction is the prognostic variable, potential vorticity is computed using equation :eq:`eq:toy-model_qg_q`. A standard 5-point finite-difference approximation to the Laplacian operator is used.

  * If the potential vorticity is the prognostic variable, streamfunction is computed using the inversion procedure described in the previous section. Solution of the helmholtz equation is achieved using an FFT-based method. Applying a Fourier transform in the east-west direction to equation :eq:`eq:toy-model_qg_2d_helmholtz_eqn` gives a set of independent equations for each wavenumber. In the case of the five-point discrete Laplacian, these are tri-diagonal matrix equations, which can be solved using the standard (Thomas) algorithm.

  city at each gridpoint is then calculated using centered, finite-difference approximations to:

  .. math::
     u = -\frac{\partial \psi}{\partial y} \\
     v =  \frac{\partial \psi}{\partial x}

  Values of :math:`\psi` one grid-space to the north and south of the grid are required in order to calculate the :math:`u`-component of velocity on the first and last grid row. These values are user-supplied constants, and determine the mean zonal velocity in each layer, which remains constant throughout the integration. (Note that the condition that :math:`v` should vanish at the northern and southern boundaries implies that :math:`\psi` is independent of :math:`x` at the boundaries.)

2. **Potential vorticity advection**

  Potential vorticity is advected along the wind:

  * For each gridpoint, :math:`(x_{ij} ,y_{ij})`, the departure point is calculated as:

    .. math::
       x^D_{ij} = x_{ij} - \frac{\Delta t}{\Delta x} u^t_{ij} \\
       y^D_{ij} = y_{ij} - \frac{\Delta t}{\Delta y} v^t_{ij}

  * The potential vorticity field at the end of the timestep is calculated by interpolating to the departure point:

    .. math::
       q^{t+\Delta t}_{ij} = q(x^D_{ij}, y^D_{ij})

    The interpolation is bi-cubic. Advection from outside the domain is handled by assuming the potential vorticity to be constant for all points one grid-space or more outside the domain. The boundary values of potential vorticity are supplied by the user.

3. **Finalization**

  If the streamfunction is the prognostic variable, it is retrieved from :math:`q^{t+\Delta t}` using the potential vorticity inversion procedure described above.

Fake projection
---------------

Even if the model implementation is performed on a plane, the generic covariance matrix library :ref:`BUMP` requires spherical coordinates for the grid. Thus, a Mercator projection is implemented to provide these coordinates, but this projection and the geographical domain it represents have no impact on the model dynamics.

YAML parameters
---------------

The configurable Quasi-geostrophic model parameters are as follows:

* :code:`geometry`: define grid parameters

  * :code:`nx`: define the number of gridpoints in x-direction
  * :code:`ny`: define the number of gridpoints in y-direction
  * :code:`depths`: define the depths for each level

* :code:`model`:

  * :code:`name`: define the model
  * :code:`tstep`: define the time step

* :code:`forecast length`: define the length of the forecast
* :code:`initial condition`: define initial condition parameters

  * :code:`date`: define the initial date to issue a forecast
  * :code:`filename`: define the name of the file to be used as initial condition

* :code:`output`: define output parameters

  * :code:`datadir`: define the directory to save files
  * :code:`date`: define the output date
  * :code:`exp`: define an experiment identification
  * :code:`frequency`: define the frequency to save output files
  * :code:`type`: define the type of output file

* :code:`prints`: define verbose parameters

  * :code:`frequency`: define the frequency to print statistics

References
----------

* Carton, X., M. Sokolovskiy, C. Ménesguen, A. Aguiar, and  T. Meunier, 2014: Vortex stability in a multi-layer quasi-geostrophic model: application to Mediterranean Water eddies Fluid Dynamics Research, IOP Publishing, 46.

* Fandry, C.B. and L.M. Leslie, 1984: A Two-Layer Quasi-Geostrophic Model of Summer Trough Formation in the Australian Subtropical Easterlies.  J.A.S., 41, pp807-817.

* Pedlosky, J., 1979: Geophysical Fluid Dynamics. Springer-Verlag, pp386-393.
