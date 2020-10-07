.. _top-oops-toymodels:

Toy models
==========

OOPS includes two toy models:

* :ref:`Lorenz95 <top-oops-toymodels-model_l95>`

* :ref:`Quasi-geostrophic <top-oops-toymodels-model_qg>`

.. _top-oops-toymodels-model_l95:

Lorenz95 model
--------------

The Lorenz95 model is an application of the Lorenz (1996) chaotic dynamics. This model is governed by :math:`I` equations:

.. math::
  \frac{dx_i}{dt} = -x_{i-2} x_{i-1} + x_{i-1} x_{i+1} - x_{i} + F,
  :label: eq:toy-model_l95

where :math:`i = 1, 2, \ldots, I`, with cyclic boundary conditions, and the constant :math:`F` is independent of :math:`i`. The variables of this model may be tought of as values of some atmospheric quantity in :math:`I` locations of a latitude circle. The so-called 40-variable version of this model assumes :math:`I=40`, with :math:`i = 1, 2, \ldots, 40`, which implies to the cyclic boundary conditions being defined as: :math:`x_{0} = x_{40}`; :math:`x_{-1} = x_{39}`; and, :math:`x_{41} = x_{1}`.

How to run a truth simulation?
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

How to sample synthetic observations?
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

How to Assimilate these observations?
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


.. _top-oops-toymodels-model_qg:

Quasi-geostrophic model
-----------------------

Introduction
^^^^^^^^^^^^

This section describes the simple two-level quasi-gestrophic model, intended for use as a toy system with which to conduct idealised studies of data assimilation methods. In developing the model, the emphasis has been placed on speed and convenience rather than accuracy and conservation.

The continuous equations
^^^^^^^^^^^^^^^^^^^^^^^^

The equations of the two-level model are given by Fandry and Leslie (1984) (see also Pedlosky, 1979 pp386-393), and are expressed in terms of non-dimensionalised variables:

.. math::
  \frac{{\rm D}q_1}{{\rm D}t} = \frac{{\rm D}q_2}{{\rm D}t} = 0
  :label: eq:toy-model_qg_conservation

where :math:`q_1` and :math:`q_2` denote the quasi-geostrophic potential vorticity on each of the two layers, with a subscript 1 denoting the upper layer:

.. math::
  q_1 = \nabla^2 \psi_1 - F_1 (\psi_1 -\psi_2 ) + \beta y
  :label: eq:toy-model_qg_q_1

.. math::
  q_2 = \nabla^2 \psi_2 - F_2 (\psi_2 -\psi_1 ) + \beta y + R_s
  :label: eq:toy-model_qg_q_2

Here, :math:`\beta` is the (non-dimensionalised) northward derivative of the Coriolis parameter, and :math:`R_s` represents orography or heating.

The model domain is assumed to be cyclic in the zonal direction, and the meridional velocity is assumed to vanish one grid space to the north and south of the domain.

Details of the non-dimensionalisation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The non-dimensionalisation is standard, but is given here for completeness. We define a typical length scale :math:`L`, a typical velocity :math:`U`, the depths of the upper and lower layers :math:`D_1` and :math:`D_2`, the Coriolis parameter at the southern boundary :math:`f_0` and its northward derivative :math:`\beta_0`, the acceleration due to gravity :math:`g`, the difference in potential temperature across the layer interface :math:`\Delta\theta`, and the mean potential temperature :math:`\overline\theta`.

Denoting dimensional time, spatial coordinates and velocities with tildes, we have:

.. math::
   t = \tilde t \frac{\overline U}{L} \\
   x = \frac{\tilde x}{L} \\
   y = \frac{\tilde y}{L} \\
   u = \frac{\tilde u}{\overline U} \\
   v = \frac{\tilde v}{\overline U} \\
   F_1 = \frac{f_0^2 L^2}{D_1 g \Delta\theta / {\overline\theta}} \\
   F_2 = \frac{f_0^2 L^2}{D_2 g \Delta\theta / {\overline\theta}} \\
   \beta = \beta_0 \frac{L^2}{\overline U}

The Rossby number is :math:`\epsilon = {\overline U} / f_0 L`.

Solution algorithm
^^^^^^^^^^^^^^^^^^

The prognostic variable of the model is streamfunction, defined on a rectangular grid of dimension :math:`nx \times ny`. The grid indices increase in the eastward and northward directions.

The time-stepping algorithm is designed for speed rather than accuracy, and is accurate only to first-order in :math:`\Delta t`. It has the practical advantage that a timestep may be performed given information at only a single time-level.

In principle, a timestep could start from values of streamfunction at a single time, :math:`t`, and return values of streamfunction at :math:`t+\Delta t`. However, to make wind (and potential vorticity) available to the analysis layer (e.g., to allow assimilation of wind observations), it is more convenient to split the timestep as follows:

* **Before an integration of the model**

  Before an integration of the model, values of wind and potential vorticity are calculated by :code:`c_qg_prepare_integration`.

  The velocity at each gridpoint is calculated using centred, finite-difference approximations to:

  .. math::
     u = -\frac{\partial \psi}{\partial y} ,\qquad
     v =  \frac{\partial \psi}{\partial x} .

  Values of :math:`psi` one grid-space to the north and south of the grid are required in order to calculate the :math:`u`-component of velocity on the first and last grid row. These values are user-supplied constants, and determine the mean zonal velocity in each layer, which remains constant throughout the integration. (Note that the condition that :math:`v` should vanish at the northern and southern boundaries implies that :math:`\psi` is independent of :math:`x` at the boundaries.)

  Potential vorticity is calculated using equations :eq:`eq:toy-model_qg_q_1` and :eq:`eq:toy-model_qg_q_2`. A standard 5-point finite-difference approximation to the Laplacian operator is used.

* **Steps evaluated at every timestep**

  The following steps are repeated for each timestep:

  1. For each gridpoint, :math:`(x_{ij} ,y_{ij})`, the departure point is calculated as:

    .. math::
       x^D_{ij} = x_{ij} - \frac{\Delta t}{\Delta x} u^t_{ij} ,\qquad
       y^D_{ij} = y_{ij} - \frac{\Delta t}{\Delta y} v^t_{ij} .

  2. The potential vorticity field at the end of the timestep is calculated by interpolating to the departure point:

    .. math::
       q^{t+\Delta t}_{ij} = q(x^D_{ij}, y^D_{ij})

    The interpolation is bi-cubic. Advection from outside the domain is handled by assuming the potential vorticity to be constant for all points one grid-space or more outside the domain. The boundary values of potential vorticity are supplied by the user.

  3. The streamfunction corresponding to :math:`q^{t+\Delta t}` is determined by inverting equations :eq:`eq:toy-model_qg_q_1` and :eq:`eq:toy-model_qg_q_2`, as described below.

  4. The velocity components at time :math:`t+\Delta t` are calculated from the streamfunction.

* **Inversion of Potential Vorticity**

  Applying :math:`\nabla^2` to equation :eq:`eq:toy-model_qg_q_1` and subtracting :math:`F_1` times equation :eq:`eq:toy-model_qg_q_1` and :math:`F_2` times equation :eq:`eq:toy-model_qg_q_2` eliminates :math:`\psi_1`, and yields the following equation for :math:`\psi_1`:

  .. math::
    \nabla^2 q_1 -F_2 q_1 -F_1 q_2 = \nabla^2 \left( \nabla^2 \psi_1 \right)
                                    - \left( F_1 + F_2 \right) \nabla^2 \psi_1.
    :label: eq:toy-model_qg_2d_helmholz_eqn

  This is a two-dimensional Helmholz equation, which can be solved for :math:`\nabla^2 \psi_1`. The Laplacian can then be inverted to determine :math:`psi_1`. Once :math:`\psi_1` and :math:`\nabla^2 \psi_1` are known, the streamfunction on level 2 can be determined by substitution into equation :eq:`eq:toy-model_qg_q_1`.

  Solution of the Helmholz equation and inversion of the Laplacian are achieved using an FFT-based method. Applying a Fourier transform in the east-west direction to equation :eq:`eq:toy-model_qg_2d_helmholz_eqn` gives a set of independent equations for each wavenumber. In the case of the five-point discrete Laplacian, these are tri-diagonal matrix equations, which can be solved using the standard (Thomas) algorithm.

References
^^^^^^^^^^

Fandry, C.B. and L.M. Leslie, 1984: A Two-Layer Quasi-Geostrophic Model of Summer Trough Formation in the Australian Subtropical Easterlies.  J.A.S., 41, pp807-817.

Lorenz, E., 1996: Predictability: a problem partly solved. Seminar on Predictability, 4-8 September 1995, volume 1, pages 1–18, European Centre for Medium Range Weather Forecasts, Reading, England. ECMWF.

Pedlosky, J., 1979: Geophysical Fluid Dynamics. Springer-Verlag.

