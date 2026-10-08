.. _ModelHeightAdjustedAirTemperature:

ModelHeightAdjustedAirTemperature
=================================

The :code:`ModelHeightAdjustedAirTemperature` ObsFunction adjusts a surface observation Temperature value
from station height to model height using a temperature lapse rate correction.

The adjustment formula is:

.. math::

   T_{\text{adjusted}} = T_{\text{obs}} + \Gamma \times (Z_{\text{station}} - Z_{\text{model}})

where :math:`\Gamma` is the lapse rate (K/m), :math:`Z_{\text{station}}` is the observation station
height, and :math:`Z_{\text{model}}` is the model height (with optional offset applied).

Two lapse rate schemes are supported:

- **constant** (default): Uses a fixed lapse rate. When the :code:`temperature lapse rate in K/km`
  parameters block is provided, the :code:`value` parameter specifies the rate in K/km. When the parameters block is
  omitted entirely, the standard lapse rate from :code:`Constants::Lclr` (unit: K/m) is used.
- **local**: Computes the lapse rate from the model temperature profile between two specified
  model levels near the surface, with optional bounds clamping.

.. note::

   Internally, JEDI uses lapse rates in units of K/m. However, to improve readability and reduce
   the risk of typos, the YAML configuration accepts lapse rate values in **K/km**. The conversion
   to K/m is performed automatically in JEDI.

Options
-------

* :code:`elevation` *(required)*: The station elevation variable in units of meters.
  (e.g. :code:`MetaData/stationElevation`).
* :code:`observed temperature variable` *(optional, default:* :code:`ObsValue/airTemperatureAt2M` *)*:
  The observation temperature variable to adjust, specified in :code:`group/variable` format
  (e.g. :code:`ObsValue/airTemperature`).

* :code:`model height` *(optional)*: A nested block configuring the model reference height.
  If omitted, defaults to terrain height with no offset.

  * :code:`from` *(optional, default: "terrain")*: Either :code:`"terrain"` (model orography
    from :code:`GeoVaLs/height_above_mean_sea_level_at_surface`) or :code:`"lowestModelLevel"`
    (height of the lowest model level from :code:`GeoVaLs/height_above_mean_sea_level`).
  * :code:`offset in meters` *(optional, default: 0.0)*: A constant offset (in meters) added to
    the model height before computing the adjustment. This can be used, for example, to account
    for the fact that station observations are typically a few meters above the terrain.

* :code:`temperature lapse rate in K/km` *(optional)*: A nested block configuring the lapse rate.
  If omitted entirely, the standard lapse rate (:code:`Constants::Lclr`) is used.

  * :code:`scheme` *(optional, default: "constant")*: Either :code:`"constant"` or :code:`"local"`.
  * :code:`value` *(optional, default: 6.5)*: Constant lapse rate value in K/km. Used when
    :code:`scheme` is :code:`"constant"`.
  * :code:`level1` *(optional, default: 1)*: Lower model level index (1-based, counted from the
    surface). Used when :code:`scheme` is :code:`"local"`.
  * :code:`level2` *(optional, default: 2)*: Upper model level index (1-based, counted from the
    surface). Used when :code:`scheme` is :code:`"local"`.
  * :code:`bounds` *(optional)*: If specified, clamp the computed local lapse rate to the given
    range. Contains:

    * :code:`minvalue` *(required)*: Minimum allowed lapse rate in K/km.
    * :code:`maxvalue` *(required)*: Maximum allowed lapse rate in K/km.

Required GeoVaLs
----------------

* :code:`GeoVaLs/height_above_mean_sea_level_at_surface` — required when :code:`model height`
  :code:`from` is :code:`"terrain"` (default).
* :code:`GeoVaLs/height_above_mean_sea_level` — required when :code:`model height` :code:`from`
  is :code:`"lowestModelLevel"`, or when lapse rate :code:`scheme` is :code:`"local"`.
* :code:`GeoVaLs/air_temperature` — required when lapse rate :code:`scheme` is :code:`"local"`.

These are requested automatically via :code:`requiredVariables()` and do not need additional YAML
configuration.

Examples
--------

**Default behaviour** (terrain height, standard lapse rate :code:`Constants::Lclr`, backward-compatible):

.. code-block:: yaml

   - filter: Variable Assignment
     assignments:
     - name: DerivedObsValue/airTemperatureAt2M
       type: float
       function:
         name: ObsFunction/ModelHeightAdjustedAirTemperature
         options:
           elevation:
             name: MetaData/stationElevation

**Constant lapse rate with custom value** (e.g. 5.0 K/km):

.. code-block:: yaml

   - filter: Variable Assignment
     assignments:
     - name: DerivedObsValue/airTemperatureAt2M
       type: float
       function:
         name: ObsFunction/ModelHeightAdjustedAirTemperature
         options:
           elevation:
             name: MetaData/stationElevation
           temperature lapse rate in K/km:
             scheme: constant
             value: 5.0

**Using lowest model level with an offset**:

.. code-block:: yaml

   - filter: Variable Assignment
     assignments:
     - name: DerivedObsValue/airTemperatureAt2M
       type: float
       function:
         name: ObsFunction/ModelHeightAdjustedAirTemperature
         options:
           elevation:
             name: MetaData/stationElevation
           model height:
             from: lowestModelLevel
             offset in meters: 2.0

**Custom observed temperature variable**:

.. code-block:: yaml

   - filter: Variable Assignment
     assignments:
     - name: DerivedObsValue/airTemperatureAt2M
       type: float
       function:
         name: ObsFunction/ModelHeightAdjustedAirTemperature
         options:
           elevation:
             name: MetaData/stationElevation
           observed temperature variable: ObsValue/airTemperatureAt2M

**Local lapse rate** computed between model levels 1 and 10 (counted from surface), with bounds:

.. code-block:: yaml

   - filter: Variable Assignment
     assignments:
     - name: DerivedObsValue/airTemperatureAt2M
       type: float
       function:
         name: ObsFunction/ModelHeightAdjustedAirTemperature
         options:
           elevation:
             name: MetaData/stationElevation
           temperature lapse rate in K/km:
             scheme: local
             level1: 1
             level2: 10
             bounds:
               minvalue: 0.5
               maxvalue: 10.0

Notes
-----

- Level indices are 1-based and counted from the surface upward (level 1 is the first model level
  above the surface).
- When using :code:`"local"` mode, if the height difference between the two levels is less than 1 m,
  the standard lapse rate (:code:`Constants::Lclr`) is used as a fallback to avoid numerical
  instability.
- When :code:`bounds` are specified, the computed local lapse rate is clamped to
  :code:`[minvalue, maxvalue]` before applying the adjustment.
- When the :code:`model height` block is omitted, the model terrain height
  (:code:`GeoVaLs/height_above_mean_sea_level_at_surface`) is used with zero offset.
- The :code:`offset in meters` value is added to the model height before computing the height
  difference :math:`Z_{\text{station}} - Z_{\text{model}}`.
