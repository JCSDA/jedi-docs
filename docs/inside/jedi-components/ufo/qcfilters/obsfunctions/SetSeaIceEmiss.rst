.. _SetSeaIceEmiss:

SetSeaIceEmiss
==============
From Fast Models for Land Surface Emissivity report [Hewison and English (1999)]:

This is a semi-empirical model that uses Fresnel’s formulae to calculate the specular reflectivity of a dielectric surface, whose permittivity can be described by a single Debye relaxation, neglecting the ionic conductivity term, as this is negligible for frequencies above 20GHz.
Determine and output surface type for use with observation operator (e.g. RTTOV) based on GeoVaLs, observation report type and AAPP (ATOVS and AVHRR Pre-processing Package) classification, where available. 
Based on UK Met Office Ops_SatRad_SeaIceEmiss procedure.

Required input variables:
~~~~~~~~~~~~~~~~~~~~~~~~~~

GeoVaLs
  :code:`ice_area_fraction@GeoVaLs`

ObsSpace
  :code:`sensor_zenith_angle@MetaData`
  :code:`surface_class@MetaData`
  :code:`surface_type@MetaData`

Input parameters:
~~~~~~~~~~~~~~~~~~~~~~~~~~

.. _polarization_index:

polarization index_
  | Array of polarization indices for each instrument channel to be calculated.
  | 0 corresponds to the average of the vertical and horizontal polarization
  | 1 corresponds to 'nominal vertical at nadir, rotating with view angle'
  | 2 corresponds to 'nominal horizontal at nadir, rotating with view angle'
  | 3 corresponds to 'vertical'
  | 4 corresponds to 'horizontal'
  
  | See yaml example for an appropriate array to use for a combined AMSU-A/B instrument (20 channels).
                      
.. _channel_frequency:

channel frequency_
  | Array of channel frequencies, in GHz, to be used in the emmisivity calculation.
  | See yaml example for an appropriate array to use for a combined AMSU-A/B instrument (20 channels).

.. _orbit_height:

orbit height_
  | Nominal satellite height, in km. Used for satellite viewing angle calculation.

Required yaml parameters
^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: yaml

  - filter: Variable Assignment
    assignments:
    - name: SeaIceEmiss@MetaData
      function:
        name: SetSeaIceEmiss@ObsFunction
        channels: *channels
        options:
         channels: *channels
          polarization index: [1, 1, 1, 1, 2,
                               2, 1, 2, 2, 2,
                               2, 2, 2, 2, 1,
                               1, 1, 1, 1, 1]
          channel frequency: [23.8,  31.4,  50.3,   52.8,   53.596,
                              54.4,  54.94, 55.5,   57.29,  57.29,
                              57.29, 57.29, 57.29,  57.29,  89.0,
                              89.0, 150.0,  183.31, 183.31, 183.31]
          orbit height: 827.0 #RTTOV coefficient nominal satellite height (km)
      type: float

