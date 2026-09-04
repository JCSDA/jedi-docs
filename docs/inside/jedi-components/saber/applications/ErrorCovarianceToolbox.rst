.. _ErrorCovarianceToolbox:

The *ErrorCovarianceToolbox* Application
========================================

This application is the core application of SABER and is used for testing a background error matrix outside of a Variational application.

It is also used for covariance calibration (AKA training).

More precisely, this application:

- Creates a SABER error covariance;
- Runs a Dirac test (optional);
- Generates random samples through randomization (optional).

This is briefly detailed in the next sections.

Each model builds its own executable for this application, and it is run as:

.. code-block:: bash

   mpiexec -n <ntasks> <model>_error_covariance_toolbox.x myconfig.yaml

For a complete, model-independent worked example of using this application to estimate
correlation or localization length-scales from an ensemble and to build a NICAS operator, see
:ref:`BUMP_nicas_estimation`.

Creation of a SABER error covariance
------------------------------------

In addition of the mere creation of each SABER block in the SABER error covariance, this includes (for each SABER block):

- the **block calibration**, if yaml key :code:`calibration` is provided at the SABER block level (cf. :ref:`calibration`);
- an **adjoint test**, if :code:`adjoint test` is specified to :code:`true` at the SABER block level, or, otherwise, if :code:`adjoint test` is specified to :code:`true` at the covariance level; 
- an **inverse test**, if :code:`inverse test` is :code:`true` at the covariance level, unless :code:`skip inverse test` is :code:`true` at the block level;
- a **square root test** for the central block, if :code:`square-root test` is :code:`true` at the covariance level.

More information on SABER block testing is given in the :ref:`saber_block_testing` page.

.. _ECTB-dirac:

Dirac test
----------

The Dirac test applies the error covariance model to a Dirac input or to a sum of Dirac inputs. Mathematically,
this can be represented as:

.. math::
  :label: dirac-test

  B * \delta x_i \rightarrow \delta x_o

Where :math:`B` is the error covariance model, :math:`x_i` is the input dirac vector of all zeros and ones (typically with only a single one for a single dirac input), and :math:`x_o` is the output. Conceptually, this projects a column out of the **B**-matrix so the structure of the **B**-matrix can be quantitatively and qualitatively inspected.

This test is performed by the application if the :code:`dirac` key is given. The value of this key is the list of coordinates of the Dirac input(s).

The output increment is written to file if the :code:`dirac output` key is given.

If the :code:`diagnostic points` key is given, the output values at the Dirac points and at a set of diagnostic points are output to the Test log.

If the :code:`covariance profile` key is given, a 1D covariance profile is output to the Test log or written to file. 

Randomization
-------------

Randomization is used to generate random increments that are normally distributed, with zero mean and with the SABER covariance as covariance matrix.

Randomization runs if no Dirac test has been run or if the :code:`randomization size` key is given at the covariance level.

The output increments are written to file if the :code:`output states` and/or :code:`output increments` keys are given.
