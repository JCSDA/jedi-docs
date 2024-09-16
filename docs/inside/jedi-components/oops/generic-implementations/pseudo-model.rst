.. _top-oops-pseudo-model:

Pseudo-model
============

Pseudo-model is a generic model implementation for model interfaces that read their data from file rather than connecting to a forecast model. :code:`PseudoModel` can be used for any :code:`MODEL` which has implemented basic components such as the :code:`Geometry` and :code:`State`.

The state configuration depends upon the implementation in the particular model in use, however, for compatibility with the Pseudo-model, it must include a specification of the validity datetime of that state, and each state in the state list must be seperated by a single time step of size :code:`tstep`.

Here is an example configuration for a :doc:`4D H(x)<../applications/hofx>` application (:code:`HofX4D`):

.. code-block:: yaml

  #.
  #.
  #.
  forecast length: P3D
  time window:
    begin: 2023-06-01T00:00:00Z
    length: P4D
  initial condition:
    date: 2023-06-02T00:00:00Z
    state variables: [ sea_surface_temperature ]
  model:
    name: PseudoModel
    tstep: P1D
    states:
      - date: 2023-06-02T00:00:00Z
        state variables: [ sea_surface_temperature ]
        #.
        #.
        #.
      - date: 2023-06-03T00:00:00Z
        state variables: [ sea_surface_temperature ]
        #.
        #.
        #.
  #.
  #.
  #.

To specify many states and to reduce redundant information, the state can also be specified using a template:

.. code-block:: yaml

  #.
  #.
  #.
  model:
    name: PseudoModel
    tstep: P1D
    states from template:
      start datetime: 2023-06-02T00:00:00Z
      number of states: 2
      pattern: "@numerical_counter@"
      start: 1
      except: [2, 3]
      zpad: 1
      template:
        state variables: [ sea_surface_temperature ]
        data field: "special-number-@numerical_counter@"
        #.
        #.
        #.
  #.
  #.
  #.

Each state is generated from the :code:`template` section. The date is constructed from :code:`start datetime` and :code:`model:tstep` to create a list of :code:`number of states` state configuration entries. There is also the facility to substitute a pattern into the state template. The pattern is specified using:
  * :code:`start`: for the starting value
  * :code:`zpad`: the number of zeros to left-pad the pattern
  * :code:`except`: values of the pattern to skip over
  * :code:`pattern`: the string to replace with the pattern value
  
