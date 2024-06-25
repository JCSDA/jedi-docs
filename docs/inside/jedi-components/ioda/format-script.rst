.. _ioda-format-script:

Script
------

The script backend allows you to run python scripts in order to generate any ObsGroup object you want. In order to use
it there are 2 pieces.

The ioda configuration file has to be configured as follows. The args section can list any number of arguments that
you want, but the python script has to take these as arguments to the create_obs_group function. The types need to be
consistent as well.

.. code-block:: yaml

  time window:
    begin: "2018-01-01T00:00:00Z"
    end: "2022-01-01T00:00:00Z"

  observations:
  - obs space:
      name: "THE LINE"
      simulated variables: ['lineData']
      obsdatain:
        engine:
          type: script
          script file: "make_a_line.py"
          args:
            varname: "lineData"
            start: 0
            stop: 10


The following is an example of the script file itself. Basically it consists of a python function called
**create_obs_group** that takes the arguments that were configured in the yaml file. Arguments in the python function
that have default values are optional in the YAML file. The argument types are validated as far as it is possible to do
so. Python 3 style type indications are supported and the types are inferred from defaulted objects. The only other rule
is that the function has to return an ObsGroup object.

.. code-block:: python

  import numpy as np
  from pyioda import ioda_obs_space as ioda_ospace

  def create_obs_group(varname, start, stop:int, fillvalue=-999):
      print ("Creating ObsGroup with variable: ", varname)

      if (step == 0):
          step = (stop - start) / 100

      numLocs = int((stop - start) / step)

      datetime = np.array(["2020-01-01"]*numLocs, dtype=np.dtype('datetime64[s]'))
      lat = np.linspace(-89, 89, numLocs)
      lon = np.linspace(-179, 179, numLocs)
      data = np.linspace(start, stop, numLocs)

      # Create the dimensions
      dims = {'Location': data.shape[0]}

      # Create the IODA ObsSpace
      obsspace = ioda_ospace.ObsSpace("test.nc", mode='w', dim_dict=dims, is_memory_file=True)

      # Create the global attributes
      obsspace.write_attr('MyGlobal_str', 'My Global String Data')
      obsspace.write_attr('MyGlobal_int', [1, 2, 3, 4, 5, 6, 7, 8, 9, 10])

      # Create the variables
      obsspace.create_var('MetaData/dateTime', dtype=datetime.dtype, fillval=fillvalue) \
          .write_attr('long_name', 'Timestamp') \
          .write_data(datetime)

      obsspace.create_var('MetaData/latitude', dtype=lat.dtype, fillval=fillvalue) \
          .write_attr('units', 'degrees_north') \
          .write_attr('long_name', 'Latitude') \
          .write_attr('valid_range', [-90.0, 90.0]) \
          .write_data(lat)

      obsspace.create_var('MetaData/longitude', dtype=lon.dtype, fillval=fillvalue) \
          .write_attr('units', 'degrees_east') \
          .write_attr('long_name', 'Longitude') \
          .write_attr('valid_range', [-180.0, 180.0]) \
          .write_data(lon)

      obsspace.create_var(f'ObsValue/{varname}', dtype=data.dtype, dim_list=['Location'], fillval=fillvalue) \
          .write_attr('units', 'imaginary') \
          .write_attr('long_name', 'My line') \
          .write_data(data)

      return obsspace.obsgroup
