.. _CloudFirstGuessMinimumResidual:

CloudFirstGuessMinimumResidual
-----------------------------------------------------------------------

This ObsFunction creates a cloud top pressure (ctp) and effective cloud amount (eca) estimate from satellite brightness temperatures.
The obs function is based on the science of Eyre, J.R. and Menzel, W.P. (1989) `Retrieval of Cloud Parameters from
Satellite Sounder Data: A Simulation Study` Journal of Applied Meteorology and Climatology, 28, 267-275.

An initial cloud amount (:math:`N_p`) at each pressure level is calculated.  This is then used to evaluate
the error weighted residual (:math:`J_p`) at each pressure level using the following formulas:

:math:`N^{num}_p = \sum_j \frac{[BT^{cld}_{j,p}-BT^{clr}_j][BT^{obs}_j-BT^{clr}_j]}{\sigma_j^2}`

:math:`N^{den}_p = \sum_{j} \frac{[BT^{cld}_{j,p}-BT^{clr}_j]^2}{\sigma_j^2}`

:math:`N_p = \frac{N^{num}_p}{N^{den}_p}`

:math:`J_p = \sum_{j}\left (\frac{\delta_{j,p}}{\sigma_j}\right)^2 = \sum_{j} \frac{[BT^{obs}_j-BT^{clr}_j]^2 - N_p^2[BT^{cld}_{j,p}-BT^{clr}_j]^2}{\sigma_j^2}`

where :math:`BT^{cld}_{j,p}` is the overcast brightness temperature in K for a given instrument channel (:math:`j`) and
pressure level (:math:`p`),  :math:`BT^{clr}_j` is the clear sky brightness temperature in K for instrument channel :math:`j`,
:math:`BT^{obs}_j` is the observed brightness temperature (bias corrected) in K for instrument channel :math:`j`, 
:math:`\sigma_j` is the error associated with instrument channel :math:`j`, :math:`N_p` is the effective cloud amount at pressure level :math:`p`,
:math:`\delta_{j,p}` is the residual at a given pressure level :math:`p` and instrument channel :math:`j` and :math:`J_p` is the summation of the
error weighted residual for all instrument channel at a given pressure level. The effective cloud amount is kept within bounds
of zero to one to make sure the values are physically realistic.

The lowest value of :math:`J_p` in a profile is selected as the
solution and this is the output of the function  The cloud top pressure (Pa) and 
effective cloud amount associated with the minimum value of :math:`J_p` are also written to the obs space.
The output location for these variables is set using the input parameters.

Input parameters:
~~~~~~~~~~~~~~~~~~~~~~~~~~

channels (required)
  A string of channel numbers to be used in the obs function.
output group (optional with default value = :code:`MetaData`)
  The group in the ObsSpace to write the cloud top pressure and effective cloud amount arrays to.
output name for cloud top pressure (optional with default value = :code:`initial_cloud_top_pressure`)
  The output variable name for the solution cloud top pressure.  The values are output in Pa.
output name for cloud fraction (optional with default value = :code:`initial_cloud_fraction`)
  The output variable name for the solution effective cloud amount.
minimum cloud top pressure (optional with default value = :code:`10000.0`)
  The minimum cloud top pressure, in Pa, which can be used to evaluate the minimum residual.  This prevents
  clouds being put too high in the atmosphere.
obs bias group (optional with default value = :code:`ObsBiasData`)
  The ObsSpace group to use to get the obervation bias.  This option should only be used when testing the ObsFunction and
  a suitable bias section is not present in the yaml.  The obs bias is written to ObsBiasData within the ObsFilterData when
  the bias section is included in the yaml.

Example configuration:
~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: yaml

    function:
      name: CloudFirstGuessMinimumResidual@ObsFunction
      options:
        channels: 1, 16, 24-26
        output group: CloudFirstGuess
        output name for cloud top pressure: initialCloudTopPressure
        output name for cloud top pressure: initialCloudFraction
        minimum cloud top pressure: 15000.0

In the above example, channels 1, 16, 24, 25 and 26 will be used in the evaluation.  The cloud top pressure will 
be written to :code:`CloudFirstGuss/initialCloudTopPressure` and the cloud effective amount will be written to 
:code:`CloudFirstGuss/initialCloudFraction`.  Only pressure levels with a pressure greater than 15000.0 Pa will be evaluated.

For further examples see the unit test yaml in ufo which can be found `here <https://github.com/JCSDA-internal/ufo/blob/develop/test/testinput/unit_tests/filters/obsfunctions/function_cloudfirstguess.yaml>`_.
