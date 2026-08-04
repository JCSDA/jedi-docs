.. _top-vader-recipe-relativehumidityat2mpercentagetofractiona:

2 m relative humidity percentage to fraction
============================================

* **Description**: Converts 2 m relative humidity from percentage units (0 to 100 when unsaturated) to fraction units (0 to 1 when unsaturated).
* **Name**: RelativeHumidityAt2mPercentageToFraction_A
* **Variable produced**: relative_humidity_at_2m
* **Input Variables**: relative_humidity_at_2m_percentage
* **Trajectory Variables**: relative_humidity_at_2m_percentage
* **Number of Levels**: Same as relative_humidity_at_2m_percentage
* **FunctionSpace**: Same as relative_humidity_at_2m_percentage
* **hasTLAD**: True
* **hasNL**: True
* **Required Configuration Variables**: None
* **Optional Parameters**: None

The transform is

.. math::

   \text{relative\_humidity\_at\_2m} = 0.01 \times \text{relative\_humidity\_at\_2m\_percentage}

and the TL/AD are the corresponding linear mappings.
