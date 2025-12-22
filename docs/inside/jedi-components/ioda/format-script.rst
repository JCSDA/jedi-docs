.. _ioda-format-script:

Script Backend
--------------

IODA Configuration
~~~~~~~~~~~~~~~~~~

The script backend allows you to run Python scripts to generate any ObsGroup object. To use it, there are two parts.

The IODA configuration must include the following section. The `args` mapping can list any number of key/value pairs,
which the Python script must accept as parameters in the ``create_obs_group`` function with matching types. The
values may be ints, floats, strs, or lists and dicts of these types.

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
            interval: [0, 10]

Python Script
~~~~~~~~~~~~~

The script must be a valid Python file defining a function called ``create_obs_group``. It should accept the parameters
from the config and an optional dictionary parameter ``env``. The function must return an `ioda.ObsGroup` instance.
Below is a basic example:

.. code-block:: python

   import numpy as np
   from pyioda import ioda

   def create_obs_group(varname:str, interval:list, env:dict=None) -> ioda.ObsGroup:
       start, stop = interval
       numLocs = int((stop - start) / 100)
       the_line = np.linspace(start, stop, numLocs)

       g = ioda.Engines.HH.createMemoryFile(name = "the_line.hdf5",
                                            mode = ioda.Engines.BackendCreateModes.Truncate_If_Exists)

       dims = [ioda.NewDimensionScale.int32('Location', numLocs, ioda.Unlimited, numLocs)]
       og = ioda.ObsGroup.generate(g, dims)

       p1 = ioda.VariableCreationParameters()
       p1.compressWithGZIP()
       p1.setFillValue.float(-999)

       var = og.vars.create(f'ObsVal/{varname}', ioda.Types.float,
                            scales=[og.vars.open('Location')], params=p1)
       var.atts.create('units', ioda.Types.str).writeVector.str([''])
       var.writeNPArray.float(the_line)

       return og

Env argument
~~~~~~~~~~~~

The MPI communicator name, begin time, and end time are provided in the optional ``env`` dictionary, which includes:

* ``comm_name``: MPI communicator identifier
* ``start_time``: start of the time window
* ``end_time``: end of the time window

Examples
~~~~~~~~

The following examples use the script backend to wrap a BUFR reader.

Here is an example of the IODA configuration file that might be used in the following examples:

.. code-block:: yaml

  ---
  time window:
    begin: "2018-04-14T21:00:00Z"
    end: "2023-12-15T03:00:00Z"

  observations:
  - obs space:
      name: "MHS"
      simulated variables: ['antennaTemperature']
      obsdatain:
        engine:
          type: script
          script file: "testinput/mhs_reader.py"
          args:
            input_path: "Data/testinput_tier_1/gdas.t18z.1bmhs.tm00.bufr_d"
            category: "metop-b"


Serial Example
~~~~~~~~~~~~~~

.. code-block:: python

  import bufr
  from pyioda.ioda.Engines.Bufr import Encoder

  def create_obs_group(input_path, category, env):
      YAML_PATH = "./bufr_mhs_mapping.yaml"

      container = bufr.Parser(input_path, YAML_PATH).parse()
      data = Encoder(YAML_PATH).encode(container)

      return data[(category, )]


Parallel Example
~~~~~~~~~~~~~~~~

.. code-block:: python

  import bufr
  from pyioda.ioda.Engines.Bufr import Encoder

  def create_obs_group(input_path, category, env):
      YAML_PATH = "./bufr_mhs_mapping.yaml"

      comm = bufr.mpi.Comm(env["comm_name"])
      container = bufr.Parser(input_path, YAML_PATH).parse(comm)

      container.all_gather(comm) # Gather data from all ranks to all ranks

      data = Encoder(YAML_PATH).encode(container)

      return data[(category, )]

