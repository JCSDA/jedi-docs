.. _DrawObsErrorFromFile:

DrawObsErrorFromFile
====================
The `DrawObsErrorFromFile` obsfunction is a simple wrapper around the :ref:`DrawValueFromFile`
obsfunction, specifically tailored to derive the observation error values by interpolating an array loaded from a file,
representing the variance or covariance matrix (of which only the diagonal elements are taken into account), indexed
by coordinates whose names correspond to ObsSpace variables. This file can potentially contain a collection ("stack")
of such matrices.

Particularities of files representing variance or covariance
------------------------------------------------------------

In using `DrawObsErrorFromFile`, differently to :ref:`DrawValueFromFile`, we identify
our payload variable to have the group defined by the parameter :code:`group`. The default value of this is `ErrorVariance`.

For NetCDF, we additionally support pulling out the diagonals where the file contains a covariance matrix.
We identify whether the input NetCDF represents a covariance matrix by the presence of a `full = "true"`
attribute for our payload variable, then when true, we collapse the first dimension.

Example
.......
The following NetCDF metadata describes the dependence of a full covariance matrix (with rows and columns
corresponding to channel numbers) on multiple variables (`latitude_band@MetaData`,
`processing_center@MetaData` and `satellite_id@MetaData(index)`): ::

    netcdf mydata {
    dimensions:
      channel_number = 10 ;
      channel_number@MetaData = 10 ;
      index = 8 ;
    variables:
      float air_temperature@ErrorVariance(channel_number, channel_number@MetaData, index) ;
        air_temperature@ErrorVariance:coordinates = "latitude_band@MetaData \
            processing_center@MetaData satellite_id@MetaData" ;
        string air_temperature@ErrorVariance:full = "true" ;
      int index(index) ;
      int channel_number(channel_number) ;
      int channel_number@MetaData(channel_number@MetaData) ;
      int latitude_band@MetaData(index) ;
      int processing_center@MetaData(index) ;
      int satellite_id@MetaData(index) ;
    ...
    }

Notice how a channel_number* describes the outermost two dimensions.  The very outermost
dimension is collapsed and discarded after extracting the diagonal elements of the covariance
matrices, so its name can be arbitrary. This allows us to conform to CF conventions,
which forbids multiple axes of an array to be indexed by the same coordinate.
The name of the dimension that remains after the collapse needs to match a variable name or be
set to `channel_number@MetaData` if this dimension is indexed by channel numbers (which aren't
represented by an ObsSpace variable).

Now we illustrate how we might read and interpolate this data to derive our observation error.  This
also demonstrates specifying the :code:`channels` option, resulting in an implicit interpolation by
channel number:

.. code-block:: yaml

    - Filter: Perform Action
      filter variables:
      - name: air_temperature
        channels: &all_channels 1-3
      action:
        name: assign error
        error function:
          name: DrawObsErrorFromFile@ObsFunction
          channels: *all_channels
          options:
            file: <path-to-input>
            channels: *all_channels
            interpolation:
            - name: satellite_id@MetaData
              method: exact
            - name: processing_center@MetaData
              method: exact
            - name: latitude_band@MetaData
              method: nearest

The `DrawObsErrorFromFile` ObsFunction can read either standard deviations or variances from a file.
This is controlled by the :code:`dispersion measure` parameter which can take the value of either :code:`standard deviation` or :code:`variance` (the default).
