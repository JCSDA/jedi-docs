
.. _VT-gnssrorefractivitygradient:

================================================
Refractivity Vertical Gradient from Refractivity 
================================================

This transform computes the vertical derivative of refractivity
with respect to height in a GNSS RO profile. It can optionally
compute categorical values for ducting and near-ducting conditions.

This is typically used with the GnssroRefNLPEP2D forward operator.
It is used for diagnostic purposes only.

---------------
Input Variables
---------------

- atmosphericRefractivity (N-units)
- height (m), typically a geometric height

----------------
Output Variables
----------------

- atmosphericRefractivityGradient (N-units/meter)
- sampleDuctingFlag (nondim, integer 0 - 6)
- profileDuctingFlag (nondim, integer 0 - 6) 

------------------------
Configuration Parameters
------------------------

- ``group``: Group name where input refractivity observation is found (default: :code:`ObsValue`)
- ``refractivity variable``: Name of variable containing input refractivity observation (default: :code:`atmosphericRefractivity`)
- ``height variable``: Name of variable containing the input height (default: :code:`height`)
- ``grad variable``: Name of variable containing the output refractivity gradient (default: :code:`atmosphericRefractivityGradient`)
- ``min super refraction``: Lowest fraction of 1/Rearth consider to be super-refracting (default: :code:`0.5`) 
- ``calculate ducting flag``: Boolean to control computation and output of a categorical value indicating near-ducting and ducting conditions for each computed gradient. Default is false. Output variable is named :code:`sampleDuctingFlag`.
- ``calculate profile ducting flag``: Boolean to control computation and output of a categorical value indicating near-ducting and ducting conditions the most extreme sample in a RO profile. All levels in a single profile get the same value. Default is false. Output variable is named :code:`profileDuctingFlag`.

------------------
Example yaml block
------------------

.. code-block:: yaml

    obs filters:
    - filter: Variable Transforms
      Transform: GnssroRefractivityGradient
      group: "ObsValue"
      min super refraction: 0.5
      calculate ducting flag: true
      calculate profile ducting flag: true

-------
Methods
-------

Iterate over all levels in each RO profile, computing dN/dz using the difference in refractivity
and height between adjacent levels. dN/dz is set to missing for the topmost level.

If the ducting flag outputs are enabled, bin the absolute value of dN/dz values into the following categories:

- 0 if abs(dN/dz) < :code:`min super refraction` * 1/Re
- 1 if abs(dN/dz) >= :code:`min super refraction` * 1/Re and < 0.6/Re
- 2 if abs(dN/dz) >= 0.6/Re and < 0.7/Re
- 3 if abs(dN/dz) >= 0.7/Re and < 0.8/Re
- 4 if abs(dN/dz) >= 0.8/Re and < 0.9/Re
- 5 if abs(dN/dz) >= 0.9/Re and < 1.0/Re
- 6 if abs(dN/dz) >= 1.0/Re

Here, Re is the radius of the earth in meters.
