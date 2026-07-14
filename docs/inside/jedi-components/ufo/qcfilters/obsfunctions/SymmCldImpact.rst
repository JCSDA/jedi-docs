.. _SymmCldImpact:

SymmCldImpact
==================

This obsfunction computes the Symmetric Cloud Impact (SCI) parameter for
cloud-affected infrared (IR) satellite radiances (can be potentially used for
microwave channels as well). The SCI provides a continuous, physically consistent
measure of scene cloudiness derived from both the observed and model background
brightness temperatures (BTs), with values near zero indicating clear-sky scenes
and increasing values reflecting progressively cloudier conditions.

The obsfunction supports two formulations, selected automatically based on the
options provided:

- **Harnish et al. (2016)**: used when :code:`btlim` is provided.
- **Okamoto et al. (2014)**: used when :code:`btlim` is not provided.

This obsfunction is used as input to :code:`ObsErrorModelRamp` to dynamically
scale observation errors according to scene cloudiness, assigning larger errors
to more heavily clouded scenes where representativeness errors are largest.

Harnisch et al. (2016) formulation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

For each channel, the SCI is computed as:

.. math::

   C_{\text{mod}} = \max(0, BT_{\text{lim}} - BT_{\text{background}})

   C_{\text{obs}} = \max(0, BT_{\text{lim}} - BT_{\text{observed,bc}})

   \text{SCI} = \frac{1}{2}(C_{\text{mod}} + C_{\text{obs}})

where :math:`BT_{\text{lim}}` is a prescribed channel-specific clear-sky reference
BT limit, :math:`BT_{\text{background}}` is the model-simulated BT including the
effects of clouds and precipitation as computed by the forward operator, and
:math:`BT_{\text{observed,bc}}` is the bias-corrected observed BT.
The :math:`\max(0, \cdot)` operator enforces the physical constraint that IR cloud
impacts must be negative (cooling).


Okamoto et al. (2014) formulation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

For each channel, the SCI is computed as:

.. math::

   C_{\text{mod}} = |BT_{\text{clr}} - BT_{\text{background}}|

   C_{\text{obs}} = |BT_{\text{clr}} - BT_{\text{observed,bc}}|

   \text{SCI} = \frac{1}{2}(C_{\text{mod}} + C_{\text{obs}})

where :math:`BT_{\text{clr}}` is the clear-sky brightness temperature from the
forward operator diagnostics, :math:`BT_{\text{background}}` is the all-sky
model-simulated BT, and :math:`BT_{\text{observed,bc}}` is the bias-corrected
observed BT. Optionally, the SCI can be scaled by a sigmoid function of the
observation-minus-background (O-B) departure to reduce the weight of heavily clouded scenes.


Options
^^^^^^^

:code:`channels` (required) specifies the list of channels for which SCI will be
computed.

:code:`btlim` (optional) specifies the per-channel clear-sky reference BT limits
:math:`BT_{\text{lim}}` in Kelvin, provided as a list in the same order as
:code:`channels`. When provided, the Harnish et al. (2016) formulation is used;
otherwise the Okamoto et al. (2014) formulation is used. These values are
instrument- and channel-specific and should be derived empirically following
Harnisch et al. (2016).

:code:`scale by omb` (optional, default: false) when true, scales the SCI by a
sigmoid function of the O-B departure. Only applies to the Okamoto et al. (2014) formulation.

:code:`sigmoid constant 1` (optional, default: 10.0) controls the slope of the
sigmoid function. Only applies to the Okamoto et al. (2014) formulation.

:code:`sigmoid constant 2` (optional, default: 10.0) controls the 50-percent value
of the sigmoid function. Only applies to the Okamoto et al. (2014) formulation.


Example: Situation-dependent observation error model (Harnish et al. 2016)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

In this application, :code:`SymmCldImpact` is used as the input variable to
:code:`ObsErrorModelRamp`, which maps the continuous SCI value to a piecewise linear
observation error using channel-specific minimum and maximum error bounds
(:code:`err0`, :code:`err1`) and SCI thresholds (:code:`x0`, :code:`x1`). The
following example shows the configuration for the Himawari-9 AHI sensor.

.. code-block:: yaml

    - filter: Perform Action
      <<: *multiIterationFilter
      filter variables:
      - name: brightnessTemperature
        channels: &channels 8-10,13
      action:
        name: assign error
        _symmetric cld: &ahi_himawari9
          x0: [0.5, 0.5, 0.5, 0.5]
          x1: [14.5, 19.0, 22.5, 36.50]
          err0: [2.8, 2.9, 2.5, 0.95]
          err1: [13.1, 16.7, 19.07, 32.70]
        error function:
          name: ObsFunction/ObsErrorModelRamp
          channels: *channels
          options:
            <<: *ahi_himawari9
            channels: *channels
            xvar:
              name: ObsFunction/SymmCldImpact
              channels: *channels
              options:
                channels: *channels
                btlim: [234.27, 244.75, 255.98, 292.99]

References
^^^^^^^^^^

Harnisch, F., M. Weissmann, and Á. Periáñez, 2016: Error model for the assimilation
of cloud-affected infrared satellite observations in an ensemble data assimilation
system. *Quart. J. Roy. Meteor. Soc.*, **142**, 1797–1808,
https://doi.org/10.1002/qj.2776.

Okamoto, K., McNally, A.P. and Bell, W., 2014: Progress towards the assimilation of
all-sky infrared radiances: an evaluation of cloud effects. *Quart. J. Roy. Meteor.
Soc.*, **140**, 1603–1614, https://doi.org/10.1002/qj.2242.