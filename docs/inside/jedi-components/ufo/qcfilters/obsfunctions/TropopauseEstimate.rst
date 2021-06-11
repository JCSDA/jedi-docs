.. _TropopauseEstimate:

TropopauseEstimate
===================================================================================

This obsfunction creates a first-guess estimate of the tropopause pressure that is based on latitude with
some adjustment for day-of-year.  An optional parameter can convert the final answer from pressure to
height using :code:`convert_p2z: true`.  The code in this method is crude and purely designed for estimating
the tropopause when lacking a model-derived estimate that may otherwise arrive via GeoVaLs.

To begin, the code assumes an equatorial belt of 15 degrees north and south of the equator then applyies a
linear transition toward the poles starting from 130 hPa and lowering to 370 hPa. To account for the seasons,
the so-called equator is shifted to be about one month delayed from actual solar solstice to mimic that
July (January) is typically hotter and has a corresponding higher tropopause than June (December) in the
northern (southern) hemisphere.


Options
^^^^^^^

:code:`convert_p2z: true` will use an ultra simple approximation of ICAO standard atmosphere from pressure
to height because the code is making a tropopause **estimate** only.

:code:`tropo_equator` is used to specify the pressure of the tropopause in the equatorial belt.

:code:`tropo_pole` is used to specify the pressure of the tropopause at the poles.


Example 1
^^^^^^^^^

The most useful example of this obsfunction is to reject satellite-derived atmospheric motion vectors (satwinds) data when their vertical level information implies they exist well above the tropopause since clouds (which are tracked to provide a motion vector) are not likely to occur in the clear air of the stratosphere.  This is handled by a :code:`Difference Check` filter in which the :code:`air_pressure@MetaData` is more than some threshold lower (higher altitude) than the supposed tropopause.

.. code-block:: yaml

    - filter: Difference Check
      filter variables:
      - name: eastward_wind
      - name: northward_wind
      reference: TropopauseEstimate@ObsFunction
      options:
        - tropo_equator: 13000         # 130 hPa
        - tropo_pole: 37000            # 370 hPa
      value: air_pressure@MetaData
      minvalue: -5000                  # 50 hPa above tropopause level, negative p-diff


Example 2
^^^^^^^^^

Another possible usage for this obsfunction is to inflate the observational error of water vapor (:code:`specific_humidity`) or satellite radiance data when above the tropopause where clouds are nearly impossible to form.
