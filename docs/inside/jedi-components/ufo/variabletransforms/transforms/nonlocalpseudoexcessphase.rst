
.. _VT-nonlocalpseudoexcessphase:

===============================================
Non-Local Pseudo Excess Phase from Refractivity 
===============================================

This transform computes non-local pseudo excess phase from refractivity in GNSS RO observations.
This is typically used with the GnssroRefNLPEP2D forward operator.

---------------
Input Variables
---------------

- atmosphericRefractivity (N-units)
- geometric height (m)

----------------
Output Variables
----------------

- nonLocalPseudoExcessPhase (meters) 

------------------------
Configuration Parameters
------------------------

- ``group``: Group name where input refractivity observation is found (default: :code:`ObsValue`)
- ``refractivity variable``: Name of variable containing input refractivity observation (default: :code:`atmosphericRefractivity`)
- ``nlpep variable``: Name of variable containing the output non-local pseudo excess phase (default: :code:`nonLocalPseudoExcessPhase`)
- ``ray_path_gen_type``: Method for generating ray path. Must match the GnssroRefNLPEP2D forward operator and has same defaults.
- ``ray_length``: approximate length of ray path. Must match the GnssroRefNLPEP2D forward operator and has same defaults.
- ``res``: Horizontal resolution of nodes in ray path. Must match the GnssroRefNLPEP2D forward operator and has same defaults.
- ``top_2d``: Highest geometric height where 2D NLPEP is computed. Must match the GnssroRefNLPEP2D forward operator and has same defaults.
- ``n_horiz``: Number of nodes in the ray path. Must match the GnssroRefNLPEP2D forward operator and has same defaults. 

------------------
Example yaml block
------------------

.. code-block:: yaml

    obs filters:
    - filter: Variable Transforms
      Transform: NonLocalPseudoExcessPhase
      res: 11.0
      top_2d: 60.0
      n_horiz: 19
      group: "ObsValue"
      refractivity variable: "atmosphericRefractivity"
      nlpep variable: "nonLocalPseudoExcessPhase"

-------
Methods
-------

Iterates over all nodes in the ray path defined for each RO observation sample (tangent point).
Determines refractivity at the node of a ray as a function of geometric height by vertically 
interpolating from the observations at heights above the tangent point in the same Radio Occultation 
profile. It converts the refractivity :code:`N` to excess index of refraction :code:`n-1` and 
integrates it over the length of the ray segment associated with that node. 

If the refractivity for any node in a ray is missing, the non-local pseudo excess phase for the 
entire ray is set to missing.
