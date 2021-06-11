.. _RONBAMErrInflate:

RONBAMErrInflate
======================================================================

This action calculates the observation error inflation factor (EIF) for 
GNSSRO NBAM operator.

The EIF is the square root of the observation number (those passed QCs) 
inside two adjacent model layers. When there is only one observation 
between the two layers, the inflation factor is one; otherwise the EIF
would be greater than one. 

EIF = sqrt(effective obs number)

Effective obs number is the RO observation number inside the model 
layer after QC.

Example:
--------

.. code-block:: yaml

  - filter: Background Check RONBAM
    filter variables:
    - name: bending_angle
    action:
      name: RONBAMErrInflate
