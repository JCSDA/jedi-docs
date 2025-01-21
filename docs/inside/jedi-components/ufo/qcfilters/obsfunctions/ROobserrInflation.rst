.. _RONBAMErrInflate:

RONBAMErrInflate
================

This action calculates the observation error inflation factor (EIF) and
returns the effective observation error for the GNSS RO NBAM operator.

The EIF is the square root of the number of observations (those that passed quality control procedures)
within two adjacent model layers. When there is only one observation
between the two layers, the inflation factor is one; otherwise the EIF
is greater than one.

EIF = sqrt(effective obs number)

The effective observation number is the number of RO observations within the model
layer after QC.

Example:
--------

.. code-block:: yaml

  - filter: Background Check RONBAM
    filter variables:
    - name: bendingAngle
    action:
      name: RONBAMErrInflate
