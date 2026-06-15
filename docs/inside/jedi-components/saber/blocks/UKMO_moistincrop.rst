.. _ukmo_moistincrop:

Moisture Incrementing Operator
==============================

The Moisture Incrementing Operator (MIO) is a linear variable change distributing specific total water and temperature increments into water vapour, cloud liquid water and cloud ice increments, as described in :cite:`Migliorini2018`.

The **mo_super_mio** outer block
--------------------------------
The **mo_super_mio** is a super SABER outer block that combines the **mo_moistincrop** outer block (described below) with the **mo_air_temperature** outer block, which is required by **mo_moistincrop** to calculate air temperature increments from Exner and potential temperature increments as well as to perform the left-inverse and adjoint of these calculations. Optionally it is also possible to use the **mo_super_mio** block with an ensemble of forecast perturbations to generate calibration coefficients for the moisture incrementing operator.

Example yaml
------------

.. code-block:: yaml

    saber outer blocks:
    - saber block name: mo_super_mio
      moisture incrementing operator file: testdata/MIO_coefficients.nc
      calibration: # Optional
        coefficient filling value: median
        output file: testdata/error_covariance_training_spectralb_mio/MIO_coefficients_new.nc

The :code:`calibration` section is needed to perform the direct calibration of the MIO block, and allows to input the :code:`coefficient filling value` specifying the calibration coefficient to use for the MIO when no calibration data are available for a given model level and total relative humidity bin. The output netcdf file with new calibration coefficients can be specified in :code:`output file`. 

The **mo_moistincrop** outer block
----------------------------------
This block calculates the specific humidity, the cloud liquid water and the cloud ice increments from specific total water and temperature increments :cite:`Migliorini2018`, as well as the left-inverse and adjoint transformations.
This block cannot be calibrated on its own, but only as part of the **mo_super_mio** block, in which it is nested. During the calibration of the **mo_super_mio** block, the **mo_moistincrop** block performs the calculations that are necessary to generate a netcdf file with the MIO calibration coefficients -- for a given model level and total relative humidity bin -- when the calibration option is present in the **mo_super_mio** yaml file.
