.. _ioda-format-hdf5:

HDF5
----

Reading HDF5 files
^^^^^^^^^^^^^^^^^^

To read an HDF5 file into an ``ObsSpace``, it is enough to set the ``obs space.obsdatain.engine`` option in the YAML configuration file to the HDF5 file path. For example,

.. code-block:: YAML

    obs space:
      obsdatain:
        engine:
          type: H5File
          obsfile: Data/testinput_tier_1/sondes_obs_2018041500_m.nc4

Note that the HDF5 file type is explicitly specified using the ``obs space.obsdatain.engine.type`` keyword with the value of ``H5File``.

Writing HDF5 files
^^^^^^^^^^^^^^^^^^

To write the contents of an ``ObsSpace`` to an HDF5 file at the end of the observation processing pipeline, use the ``obs space.obsdataout.engine`` option:

.. code-block:: YAML

    obs space:
      obsdataout:
        engine:
          type: H5File
          obsfile: Data/sondes_obs_2018041500_m_out.nc4

Again, note the explicit specification of an HDF5 output file using the ``obs space.obsdataout.engine.type`` keyword.
