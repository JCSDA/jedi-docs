
Creating a New Filter
---------------------

If none of the filters described above meets your requirements, you may need to write a new one. If possible, make it generic (applicable to arbitrary observation types). The source code of UFO filters is stored in the :code:`ufo/src/ufo/filters` folder. You may find it useful to refer to the JEDI Academy tutorials on `writing <http://academy.jcsda.org/2020-02/pages/activities/day2b.html>`_ and `testing <http://academy.jcsda.org/2020-02/pages/activities/day4a.html>`_ a filter.

When writing a new filter, consider using the :ref:`Parameter-classes`
to automate extraction of filter parameters from YAML files.

Filter Tests
------------

All observation filters in UFO are tested with the :code:`ObsFilters` test from :code:`ufo/test/ufo/ObsFilters.h`. Each entry in the :code:`observations` list in a YAML file passed to this test should contain at least one of the following parameters:

- :code:`passedBenchmark`: Number of observations that should pass QC.
- :code:`passedObservationsBenchmark`: List of indices of observations that should pass QC.
- :code:`failedBenchmark`: Number of observations that should not pass QC.
- :code:`failedObservationsBenchmark`: List of indices of observations that should not pass QC.
- :code:`flaggedBenchmark`: Number of observations whose QC flag should be set to the value specified in the YAML option :code:`benchmarkFlag`. Useful to isolate the impact of a filter executed after other filters that also modify QC flags.
- :code:`failedObservationsBenchmark`: List of indices of observations whose QC flag should be set to the value specified in the YAML option :code:`benchmarkFlag`.
- :code:`compareVariables`: A list whose presence instructs the test to compare variables created by the filter with reference variables. Each element of the list should contain the following parameters:

  - :code:`test`: The variable to be tested.
  - :code:`reference`: The reference variable.

  By default, the comparison will succeed only if all entries in the compared variables are exactly equal. If the compared variables hold floating-point numbers and the :code:`absTol` option is set, the comparison will succeed if all entries differ by at most :code:`absTol`. Example:

  .. code-block:: yaml

    compareVariables:
      - test:
          name: eastward_wind@ObsValue
        reference:
          name: eastward_wind@TestReference
        absTol: 1e-5
      - test:
          name: northward_wind@ObsValue
        reference:
          name: northward_wind@TestReference
        absTol: 1e-5