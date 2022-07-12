
.. _VT-potentialtemperature:

=====================
Potential Temperature 
=====================
Performs a variable conversion from temperature and pressure to potential temperature. 

:code:`Transform: PotentialTFromT`

.. code-block:: yaml

    obs filters:
    - filter: Variables Transform
    Transform: PotentialTFromT
    
**Observation parameters needed** (JEDI name)

- airTemperature (:math:`T`)
- pressure (:math:`P`)

The potential temperature (:math:`\theta`) is calculated as follows:

.. math::

 \theta = (P_{F}/P)^\kappa  \times T

where

.. math::
 \kappa = R_d / C_p

and :math:`P_{F}` is the reference surface pressure.

Note: the error on :math:`\theta` is set to the error on :math:`T` scaled by the conversion factor :math:`(P_{F}/P)^\kappa`.

**Filter optional parameters**

This filter allows the user to set specified names for input and output variables (defaults are IODA naming conventions):

- pressure variable (default: pressure)
- temperature variable (default: airTemperature)
- potential temperature variable (default: potentialTemperature)

