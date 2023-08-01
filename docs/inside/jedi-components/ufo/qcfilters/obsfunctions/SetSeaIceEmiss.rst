.. _SetSeaIceEmiss:

SetSeaIceEmiss
==============
From the internal Met Office report, "Fast Models for Land Surface Emissivity" (Hewison & English, 1999):

  This is a semi-empirical model that uses Fresnel’s formulae to calculate the specular reflectivity (emissivity) of a dielectric surface, whose permittivity can be 
  described by a single Debye relaxation, neglecting the ionic conductivity term, as this is negligible for frequencies above 20 GHz.

A more detailed description is contained in `Airborne retrievals of snow and ice surface emissivity at millimeter wavelengths <https://doi.org/10.1109/36.774700>`_ (Hewison & English, 1999).

This obsfunction requires observation Metadata (surface classification) from the ATOVS and AVHRR Pre-processing Package (AAPP) and returns an emissivity for applicable ice profiles. 

Based on UK Met Office Ops_SatRad_SeaIceEmiss procedure.

Required input variables:
~~~~~~~~~~~~~~~~~~~~~~~~~~

GeoVaLs
  :code:`GeoVaLs/ice_area_fraction`
ObsSpace
  :code:`MetaData/sensorZenithAngle`
  :code:`MetaData/surfaceClassAAPP`
  :code:`MetaData/surfaceQualifier`

Input parameters:
~~~~~~~~~~~~~~~~~~~~~~~~~~

.. _`polarization index`:

`polarization index`_ *(required)*
  | Vector of (integer) polarization indices for each instrument channel to be calculated.
  | 0 corresponds to the average of the vertical and horizontal polarization
  | 1 corresponds to 'nominal vertical at nadir, rotating with view angle'
  | 2 corresponds to 'nominal horizontal at nadir, rotating with view angle'
  | 3 corresponds to 'vertical'
  | 4 corresponds to 'horizontal'
  
  | See yaml example for an appropriate array to use for a combined AMSU-A/B instrument (20 channels).
                      
.. _`channel frequency`:

`channel frequency`_ *(required)*
  | Vector of channel frequencies (float), in GHz, to be used in the emissivity calculation.
  | See yaml example for an appropriate array to use for a combined AMSU-A/B instrument (20 channels).

.. _`orbit height`:

`orbit height`_ *(required)*
  | Nominal satellite height, in km (scalar float). Used for satellite viewing angle calculation.

Example YAML
^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: yaml

  - filter: Variable Assignment
    assignments:
    - name: SeaIceEmiss@MetaData
      function:
        name: SetSeaIceEmiss@ObsFunction
        channels: &channels 1-20
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
          orbit height: 827.0
      type: float

