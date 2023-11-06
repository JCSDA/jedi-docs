.. _SetSurfaceType:

SetSurfaceType
==============

Determine and output surface type for use with observation operator (e.g. RTTOV) based on GeoVaLs, observation report type and AAPP (ATOVS and AVHRR Pre-processing Package) classification, where available. 
Based on UK Met Office Ops_SatRad_SetSurfaceType procedure.

Required input variables:
~~~~~~~~~~~~~~~~~~~~~~~~~~

GeoVaLs
 |  :code:`GeoVaLs/surface_altitude`
 |  :code:`GeoVaLs/ice_area_fraction`

ObsSpace
  :code:`MetaData/latitude`
  
Optional input variables:
~~~~~~~~~~~~~~~~~~~~~~~~~~

GeoVaLs
  :code:`GeoVaLs/land_area_fraction` (required if UseModelLandFraction_ is true)

ObsSpace
 |  :code:`MetaData/landOrSeaQualifier` (required if UseReportSurface_ is true, variable name can be modified by SurfaceMetaDataName_)
 |  :code:`MetaData/heightOfSurface` (required if UseReportElevation_ is true)
 |  :code:`MetaData/surfaceClassAAPP` (required if UseAAPPSurfaceClass_ is true)
 |  :code:`MetaData/waterAreaFraction` (required if UseSurfaceWaterFraction_ is true)

Input parameters:
~~~~~~~~~~~~~~~~~~~~~~~~~~

.. _UseReportSurface:

UseReportSurface_
  | Use reported BUFR surface type. If the surface is classified as coast, the surface elevation and model orography are used to determine if it is most likely land or sea.
  | (default false)

.. _UseReportElevation:

UseReportElevation_
  | Use reported surface elevation. Otherwise, model orography is used instead.
  | (default false)

.. _UseAAPPSurfaceClass:

UseAAPPSurfaceClass_
  | Use additional surface type information derived by AAPP using radiances to reclassify surfaces.
  | (default false)

.. _UseSurfaceWaterFraction:

UseSurfaceWaterFraction_
  | Use reported Surface Water Fraction.
  | (default false)

.. _UseModelLandFraction:

UseModelLandFraction_
  | Use model land fraction in setting of the land-sea mask. If false, the Met Office OPS method using the model surface height is used instead.
  | (default false)

.. _SurfaceMetaDataName:

SurfaceMetaDataName_
  | Name of the variable storing the reported surface type
  | (default MetaData/landOrSeaQualifier)

MinLandFrac
  | Minimum land fraction for assignment of land surface type. Only used if UseModelLandFraction is set to true.
  | (default 0.5)

MinIceFrac
  | Minimum ice fraction required for assignment of sea-ice surface type.
  | (default 0.2)

MinWaterFrac
  | Minimum water fraction for assignment of sea surface type. Only used if UseSurfaceWaterFraction is set to true.
  | (default 0.99)

IceLimitHard
  | Latitude south of which sea-ice is assumed to be present regardless of model ice fraction. IceLimitHard is only specified for the Southern Hemisphere while IceLimitSoft is applied in both hemispheres. 
  | (default 72 [degrees latitude south])

IceLimitSoft
  | Latitude past which sea-ice is assumed when AAPP surface classification is present and valid (assuming UseAAPPSurfaceClass is true).
  | (default 55 [degrees latitude])

HighlandHeight
  | Height below which surface may be reclassified by AAPP surface classification as sea.
  | (default 1000 [metres])

SurfaceTypeLand
  | Observation operator land surface type value to map to. 
  | (default 0, RTTOV land surface value)

SurfaceTypeSea
  | Observation operator sea surface type value to map to. 
  | (default 1, RTTOV sea surface value)

SurfaceTypeSeaIce
  | Observation operator sea-ice surface type value to map to. 
  | (default 2, RTTOV sea-ice surface value)

HeightTolerance
  | Tolerance on the test for model surface altitude being equal to zero for determining the land-sea mask (Met Office OPS method only).
  | (default 0 [metres])

Notes
~~~~~~~~~~~~~~~~~~~~~~~~~
Only sea spots may be reclassified as sea-ice. Land points that may be
covered with ice are left as land. The assignment of sea-ice is
determined using a threshold on the model seaice fraction.

Required yaml parameters
^^^^^^^^^^^^^^^^^^^^^^^^^

ATMS Example (atms_qc_filters.yaml):

.. code-block:: yaml

  - filter: Variable Assignment
    assignments:
    - name: MetaData/landOrSeaQualifier
      function: 
        name: ObsFunction/SetSurfaceType
        options:
          UseReportSurface:        true  # non-default
          UseReportElevation:      true  # non-default
          UseAAPPSurfaceClass:     true  # non-default
          UseSurfaceWaterFraction: false # default
      type: int

