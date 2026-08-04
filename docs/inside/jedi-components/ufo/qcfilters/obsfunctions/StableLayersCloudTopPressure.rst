.. _StableLayersCloudTopPressure:

StableLayersCloudTopPressure
============================

This ObsFunction calculates the most likely cloud top pressure based on the "Stable Layers" method developed at the Met Office.

There are five steps to the Stable Layers method. Firstly, each layer from the bottom of the
atmosphere up to the tropopause level undergoes up to three tests to see if it is a possible stable layer.
The first test compares the layer lapse rate :math:`\Gamma` to the saturated adiabatic lapse rate :math:`\Gamma_s`,
defined as:

:math:`\Gamma_s = \bigg(\frac{r_d T + L_c r_s}{c_p} \bigg) \bigg( p \Big(1 + \frac{L_c^2 r_s \epsilon}{c_p r_d T^2}\Big) \bigg)^{-1}`,

where

:math:`r_s = \frac{\epsilon e_s}{p - e_s}`

is the saturation mixing ratio,

:math:`e_s = e_0 \exp\bigg[\frac{L_c}{r_v} \big(\frac{1}{T_0} - \frac{1}{T}\big)\bigg]`

is the saturation vapour pressure as calculated by the Clausius-Clapeyron equation,
:math:`r_d` is the specific gas constant for dry air,
:math:`c_p` is the specific heat capacity of dry air at constant pressure,
:math:`L_c` is the latent heat of condensation,
:math:`\epsilon` is the ratio of the specific gas constants for dry air and water vapour,
:math:`e_0` is the saturation vapour pressure at 273.15 K,
:math:`r_v` is the specific gas constant for water vapour,
:math:`T_0 = 273.15 K` is the reference temperature, and :math:`T` and :math:`p`
are the temperature and pressure respectively of the level in question.

The test is passed if the layer lapse rate is less than the saturated adiabatic lapse rate, indicating
either absolute stability or a saturated neutral layer. The second and third tests are only conducted if the brightness temperature constraint is set to
true by the user. Both tests compare the bias corrected brightness
temperature to the brightness temperature of the level, and the tests are passed if the former
is not too much warmer/colder than the latter, where the limits are set by the parameters
:code:`temperature limit warm` and :code:`temperature limit cold`.

The second step involves allocating a weight for each layer that passes the stable layers
tests, corresponding to its calculated stability. Each stability weight is calculated as a product
of a lapse weight :math:`w_l`, a relative humidity weight :math:`w_{r}` and a brightness
temperature weight :math:`w_b` defined as:

:math:`w_{l} = \max(\min\big(\frac{\Gamma_s - \Gamma}{d_{\text{s}} \bar{T}}, 1\big),0)`,

:math:`w_{r} = \max(\min\big(\frac{RH}{d_{\text{rh}}} + d_{\text{off}}, 1\big), d_{\text{min}})`,

:math:`w_{b} = 1 - \frac{BT_{\text{corr}} - BT}{d_{T\pm}}`,

where
:math:`d_{\text{s}}` is the :code:`stable density`,
:math:`d_{\text{rh}}` is the :code:`relative humidity density as a fraction` (expressed as a fraction to match :math:`RH`),
:math:`d_{\text{off}}` is the :code:`relative humidity offset`,
:math:`d_{\text{min}}` is the :code:`relative humidity minimum`,
:math:`d_{T\pm}` is the :code:`temperature limit warm` or :code:`temperature limit cold` depending
on whether the bias corrected brightness temperature is warmer or colder than the brightness temperature
of the level,
:math:`RH` is the relative humidity of the level (expressed as a fraction),
:math:`BT_{\text{corr}}` is the bias corrected brightness temperature,
:math:`BT` is the brightness temperature of the level,
and
:math:`\bar{T}` is the calculated mean temperature of the layer.

If we are at the bottom of the atmosphere, the final stability weight, :math:`\omega` is calculated as:

:math:`\omega = w_{l} \times w_{r} \times w_{b}`.

If we are not at the bottom of the atmosphere, the final stability weight is calculated as:

:math:`\omega = w_{l} \times w_{r} \times w_{b} \times (1 - w_{l-})`,

where :math:`w_{l-}` is the lapse weight of the layer below. This has the outcome of penalising the
layer in consideration if the layer below has a high lapse weight. In either calculation, :math:`w_{b}` is only included in the product if the brightness temperature
constraint is set to true.

The third step involves finding the "true" cloud top pressure. Since the cloud top is unlikely
to fall directly on a model level, the cloud top pressure is calculated by fitting a quadratic
to the level with the highest weighting and its two neighbours and finding the maximum.
It can be shown that for three
points :math:`(\log(p_{-1}), w_{-1})`, :math:`(\log(p_{0}), w_{0})` and :math:`(\log(p_{1}), w_{1})`
the maximum of the quadratic is given by:

:math:`p_{\text{ct}} = p_{0} \exp\bigg( \frac{1}{2} \frac{(\log(p_{-1}/p_0))^2 (w_1 - w_0) - (\log(p_{1}/p_0))^2 (w_{-1} - w_0)}{(\log(p_{-1}/p_0)) (w_1 - w_0) - (\log(p_{1}/p_0)) (w_{-1} - w_0)}\bigg)`.

Here :math:`w_{0}` refers to the highest weighting and :math:`p_0` refers to the corresponding pressure level. The point :math:`p_{\text{ct}}` is taken as the most likely cloud top pressure.

The fourth step involves calculating the weighted standard deviation about the cloud top pressure.
This is calculated as:

:math:`\sigma = \sqrt{\frac{\sum_{i} w_i (p_i - p_{\text{ct}})^2}{\sum_{i} w_i}}`,

where the summation is done over all layers from the bottom of the atmosphere up to the tropopause.

The final step involves finding the overcast brightness temperature at the "true" cloud top
pressure by using linear interpolation. First, the model level directly above :math:`p_{\text{ct}}`
is found. We will refer to this level as
:math:`p_{i}`. Then the overcast brightness temperature is calculated as:

:math:`BT_{\text{ct}} = BT_{i+1} + \frac{BT_{i} - BT_{i+1}}{\log(p_{i}) - \log(p_{i+1})} (\log(p_{\text{ct}}) - \log(p_{i+1}))`.


Required input parameters to the ObsFunction include the tropopause level and the bias corrected brightness temperature.
There are several optional input parameters that control the stable layers tests as well as the
allocation of stability weights. These each have generic default values but it is
recommended that users consider altering them.

Required Parameters
^^^^^^^^^^^^^^^^^^^
:code:`channels` - a set of channel numbers to be used in the ObsFunction.

:code:`tropopause level` - integer values to set the tropopause level for each location.

:code:`corrected brightness temperature` - float value to set the bias corrected brightness temperature for each location.

Parameters
^^^^^^^^^^
:code:`where` - condition used to select locations at which ObsFunction should be applied. If not specified, all locations will be selected.

:code:`where operator` - operator used to combine successive where conditions at the same location. The available operators are :code:`and` and :code:`or`. The default is :code:`and`.

:code:`window channel` - integer value (default 9, based on SEVIRI channel numbering) to set the window channel number. This channel should be the same as the channel passed into :code:`corrected brightness temperature`.

:code:`brightness temperature constraint` - boolean (default false) to enable the brightness temperature constraint.

:code:`temperature limit warm` - float value (default 1.0 K) to set the maximum positive difference between the bias corrected brightness temperature and the level brightness temperature.

:code:`temperature limit cold` - float value (default -1.0 K) to set the maximum negative difference between the bias corrected brightness temperature and the level brightness temperature.

:code:`stable density` - float value (default 1.0) to control the lapse weight.

:code:`relative humidity density as a fraction` - float value (default 1.0) to control the rh weight, expressed as a fraction rather than a percentage to match the model units of relative humidity.

:code:`relative humidity offset` - float value (default 0.0) to control the rh weight.

:code:`relative humidity minimum` - float value (default 0.0) to set the minimum rh weight.

Example 1
^^^^^^^^^
The following example is the most basic use of this ObsFunction, as part of a :code:`Variable Assignment` filter.
This sets the required parameters of the channels, tropopause level, and bias corrected brightness
temperature, but uses the default values of the other parameters.
Output into the obs space is placed into the variable :code:`MetaData/pressureAtTopOfCloudStableLayers`.

.. code-block:: yaml

    - filter: Variable Assignment
      assignments:
        - name: MetaData/pressureAtTopOfCloudStableLayers
          type: float
          function:
            name: ObsFunction/StableLayersCloudTopPressure
            options:
              channels: 1, 3, 5, 9
              tropopause level: MetaData/TropHeight
              corrected brightness temperature: BiasCorrObsValue/brightnessTemperature_9

Example 2
^^^^^^^^^
This example makes use of the input parameters to allow the user to set the window channel, the
brightness temperature constraint, and the constants controlling the stable layers tests and allocated
stability weights.

.. code-block:: yaml

    - filter: Variable Assignment
      assignments:
        - name: MetaData/pressureAtTopOfCloudStableLayers
          type: float
          function:
            name: ObsFunction/StableLayersCloudTopPressure
            options:
              channels: 1, 3, 7, 9
              brightness temperature constraint: true
              window channel: 7
              tropopause level: MetaData/TropHeight
              corrected brightness temperature: BiasCorrObsValue/brightnessTemperature_7
              temperature limit warm: 5.0
              temperature limit cold: -10.0
              stable density: 0.1
              relative humidity density as a fraction: 0.8
              relative humidity offset: -0.1
              relative humidity minimum: 0.1
