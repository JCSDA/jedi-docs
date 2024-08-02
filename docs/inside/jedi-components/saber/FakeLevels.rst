.. _FakeLevels:

FakeLevels
==========

The **FakeLevels** SABER block can be used for the convolution of 2D variables that
takes into account a vertical coordinate (e.g. orography for snow over mountains).
**FakeLevels** outer block extends and reduces the 2D field into a 3D field and applies
vertical convolution with a prescribed lengthscale, and can be used with any horizontal
convolution SABER block.
For more details and theoretical documentation refer to `Menetrier, 2024 <https://github.com/benjaminmenetrier/fake_levels_convolution/blob/develop/fake_levels_convolution.pdf>`_

The block can be configured to compute weights on the fly (and save them as needed),
or to read the precomputed weights.

Fake levels can be specified as a list of values, or by specifying the lowest and the highest
level and the number of levels (levels will be distributed evenly between the lowest and the highest).

An example configuration for computing the weights on the fly and saving them using a list of levels:

.. code-block:: yaml

  saber outer blocks:
  - saber block name: FakeLevels
    calibration:
      fake levels: [0.0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0]  # list of fake levels
      vertical length-scale: 0.6                                  # vertical correlation lengthscale
      output model files:                                         # save to model files
      - parameter: weight
        file:
          ...


The same can be achieved specifying the values for the lowest and the highest level and the number of levels:

.. code-block:: yaml

  saber outer blocks:
  - saber block name: FakeLevels
    calibration:
      number of fake levels: 11
      lowest fake level: 0.0
      highest fake level: 1.0
      vertical length-scale: 0.6


Note: in some cases the vertical coordinate used by this block may be different than the vertical coordinate used
by default by the other saber blocks. In this case one needs to explicitly specify which vertical coordinate **FakeLevels**
block needs to use:

.. code-block:: yaml

  saber outer blocks:
  - saber block name: FakeLevels
    fields metadata:
      totalSnowDepth:
        vert_coord: filtered_orography   # use this vertical coordinate for the above variable (only in FakeLevels block)
    calibration:
      number of fake levels: 40
      lowest fake level: -100.0
      highest fake level: 8900.0
      vertical length-scale: 700.0


An example of using precomputed weights (e.g. from the first example above):

.. code-block:: yaml

  saber outer blocks:
  - saber block name: FakeLevels
    read:
      number of fake levels: 11
      input model files:
      - parameter: weight
        file: ...


References
----------

Menetrier, 2024: https://doi.org/10.5281/zenodo.13151313
