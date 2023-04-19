Print Filter Data utility
=========================

The :code:`Print Filter Data` utility enables the user to inspect the contents of the :code:`ObsFilterData` at any point in the
filter processing sequence. The utility will print a table of selected variables at the desired locations in the ObsSpace.
Any variable stored in the :code:`ObsFilterData` object can be printed.
Model-level data such as GeoVaLs, ObsDiagnostics and ObsBiasData are printed out on individual (user-configured) levels.
It is also possible to specify which channels to print for multi-channel data.

The utility should be instantiated in the same way as a normal filter. The configuration options and an example of its use are shown below.

If a requested variable is not in the :code:`ObsFilterData` then a warning will be printed at the start of the output.


Configuration options
---------------------

- :code:`variables`: List of variables to print.

  - :code:`variable`: Variable information (name and optional channels). The channels are listed in a separate row, labelled :code:`channels`, underneath the variable name. The channels should be specified as a comma-separated list. Ranges can be specified with the :code:`-` character.

  - :code:`levels`: Set of levels to be printed for multi-level data in the GeoVaLs, ObsDiagnostics and ObsBiasTerm groups. This should be specified as a comma-separated list. Ranges can be specified with the :code:`-` character. The default is an empty list (i.e. no values will be printed).

- :code:`message`: Message to print at the start of the output.

- :code:`summary`: Print summary of ObsFilterData? Default: :code:`true`.

- :code:`minimum location`: The filter data will be printed for all locations whose values are greater than or equal to this value. Default: 0.

- :code:`maximum location`: The filter data will be printed for all locations whose values are less than or equal to this value. If this is set to zero then it will be redefined as the total number of locations - 1. If the maximum location is less than the minimum location then an exception will be thrown. Default: 0.

- :code:`print only rank 0`: Only get and print data from rank 0. The precise consequence of this being set to :code:`true` depends on the ObsSpace distribution that is used. If this option is :code:`false`, data from all ranks are gathered and printed on rank 0. Default: false.

- :code:`maximum text width`: The maximum width (in characters) of the output text. Default: 120.

- :code:`column width`: The width of the columns (in characters) in the output table. Default: 20.

- :code:`where`: Conditions used to select locations where printing should be performed. If not specified, printing will be performed at all required locations.

- :code:`where operator`: Logical operator used to combine conditions used in the :code:`where` statement. The possible values are :code:`and` (the default) and :code:`or`. Note that it is possible to use the :code:`where operator` option without the :code:`where` statement. The option has no impact in that case.

- :code:`defer to post`: If set to :code:`true`, printing will occur after the obs operator has been invoked (even if the filter doesn't require any variables from the GeoVaLs or HofX groups).

- :code:`skip derived`:  If this option is :code:`true`, retrieval of a particular group name from the filter data will only consider that group. If this option is :code:`false`, the retrieval will first check for the same group prefixed with "Derived"; if such a group is present then the data from that will be retrieved. If the Derived group is not present, data from the original group will then be retrieved. Default: :code:`true`.


Example
-------

.. code-block:: yaml

  - filter: Print Filter Data
    message: Printing filter data after the Background Check has run.
    variables:
    - variable: MetaData/latitude
    - variable: MetaData/longitude
    - variable: MetaData/dateTime
    - variable: ObsValue/airTemperature
    - variable: DerivedObsValue/airTemperature
    - variable: ObsErrorData/airTemperature
    - variable: HofX/airTemperature
    - variable: QCflagsData/airTemperature
    - variable: GeoVaLs/air_temperature
      levels: 0, 1-3, 17
    - variable: ObsDiag/air_temperature_background_error
      levels: 0
    minimum location: 0
    maximum location: 8

