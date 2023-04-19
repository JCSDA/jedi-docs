.. _ProfileAverageObsPressure:

ProfileAverageObsPressure
-------------------------

When processing atmospheric profile data, the ObsSpace is extended in order to enable reported profiles to be averaged onto model levels before they are sent to the data
assimilation. During the ObsSpace extension procedure, all of the values of air pressure in each averaged profile are initialised to the first entry (i.e. the highest pressure) in the corresponding reported profile. The BackgroundErrorVertInterp operator, which relies on values of air pressure, will therefore not compute background errors correctly for most of the profile. This ObsFunction mitigates that problem by copying the column of GeoVaLs of air pressure located at the first entry in the reported profile into the averaged pressure. Due to the relatively low resolution of the background errors, any horizontal drift during the ascent is ignored. (There is a separate observation operator that computes H(x) values for each simulated variable in the averaged profiles, so a similar ObsFunction is not required in those cases.)

Parameters
----------

- :code:`model vertical coordinate`: Name of the model vertical coordinate.

- :code:`observation vertical coordinate`: Name of the observation vertical coordinate.

Example yaml
------------

.. code-block:: yaml

  - filter: Variable Assignment
    assignments:
      - name: MetaData/pressure
        type: float
        function:
          name: ObsFunction/ProfileAverageObsPressure
          options:
            model vertical coordinate: pressure
            observation vertical coordinate: MetaData/pressure
