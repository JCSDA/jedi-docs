.. _BennartzScatIndex:

BennartzScatIndex
--------------------------------------------------------------------------------------

This ObsFunction calculates a scattering index based on observations from
two satellite microwave channels.

An offset is computed which varies with satellite zenith angle as

.. math::
  \text{Offset = bennartz_coeff_1 + bennartz_coeff_2*sensor_zenith_angle}

A scattering index is then computed as the difference between two channel
brightness temperatures (BTs) minus the offset:

.. math::
  \text{S.I. = BT(channel_89ghz) - BT(channel_150ghz) - Offset}

Typically channels such as 89 GHz and 150 GHz are chosen where the
sensitivity to scattering by ice particles increases with frequency.

Required parameters:
~~~~~~~~~~~~~~~~~~~~

channel_89ghz
  Channel number corresponding to 89 GHz (or nearby frequency depending on
  sensor channel specification) e.g. MHS channel 1 at 89 GHz.

channel_150ghz
  Channel number corresponding to 150 GHz (or nearby frequency depending on
  sensor channel specification) e.g. MHS channel 2 at 157 GHz.

bennartz_coeff_1
  First coefficient used to compute scattering index offset

bennartz_coeff_2
  Second coefficient used to compute scattering index offset

Optional parameters:
~~~~~~~~~~~~~~~~~~~~

apply_bias
  Name of the bias correction group used to apply correction to ObsValue

  Default (missing optional parameter) applies no bias correction

Reference:
~~~~~~~~~~

R. Bennartz.
Precipitation analysis using the Advanced Microwave Sounding Unit in
support of nowcasting applications.
Meteorol. Appl. 9, 177-189 (2002).
DOI:10.1017/S1350482702002037

Example yaml:
~~~~~~~~~~~~~

Here is an example using this ObsFunction inside the Bounds Check filter for
ATMS. The brightness_temperature filter variables are rejected if the output
value of this ObsFunction is larger than the example maxvalue = -1.0.

.. code-block:: yaml

  - filter: Bounds Check
    filter variables:
    - name: brightness_temperature
      channels: 1-7, 16-22
    where:
    - variable:
        name: land_sea@MetaData
      is_in: 0  # land=0, sea=1, ice=2
    test variables:
    - name: BennartzScatIndex@ObsFunction
      options:
        channel_89ghz: 16    # ATMS 89.5 GHz channel
        channel_150ghz: 17   # ATMS 165.5 GHz channel
        bennartz_coeff_1: 0.158
        bennartz_coeff_2: 0.0163
        apply_bias: ObsBias
    maxvalue: -1.0
    action:
      name: reject
