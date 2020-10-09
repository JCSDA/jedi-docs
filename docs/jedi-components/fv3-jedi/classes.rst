  .. _top-fv3-jedi-classes:

.. _classes:

Classes and Configuration
=========================

This page describes the classes that are implemented in FV3-JEDI. It explains in broad terms what
they are responsible for, how they are implemented and explains the configuration options that are
available for controlling their behavior.

.. _geometry:

Geometry
--------

The Geometry class is responsible for creating and storing the FV3 cubed-sphere grid structure. It
accomplishes the generation of the FV3 grid by calling the routine :code:`fv_control_init` that
lives within the FV3 model. The code is provided with three interfaces to :code:`fv_control_init`
to cover the way it is handled in the current version of FV3, legacy versions of FV3 and GEOS.
It will automatically build the correct version depending on the choice of model that FV3-JEDI is
built with.

FV3 routines like :code:`fv_control_init` expect there to be a file called :code:`input.nml`
present in the run directory. This file controls many aspects of the way in which FV3 behaves, from
the resolution and processor layout to whether the dynamical core is hydrostatic. In forecasts
involving FV3 this file is typically static and is placed into the directory ahead of time. For
data assimilation applications, where there are often multiple resolutions involved, it is not
possible to have a static :code:`input.nml` file. Instead the file is dynamically created or
versions of it are moved in and out of the directory as needed during the runs. The source code will
handle the placement and removal of :code:`input.nml` but the user is responsible for which file is
used or how it is created.

In order to use an already constructed :code:`input.nml` file the user can provide :code:`nml_file`
in the geometry config as follows:

.. code:: yaml

   geometry:
     nml_file: Data/fv3files/input_gfs_c12_p12.nml

Note that the file can be located somewhere other than the run directory. As the code is running
the file will be linked into the run directory and the link destroyed when no longer needed. In
order to dynamically generate :code:`input.nml` the user can input the spereate parts of the file as
follows:

.. code:: yaml

   geometry:
     layout: [1,1]
     io_layout: [1,1]
     npx: 13
     npy: 13
     npz: 64
     ntiles: 6

The table below describes the role of each entry in the above Yaml

+--------------------------+-------------------------------------------------------+
| Configuration            | Description                                           |
+==========================+=======================================================+
| :code:`layout: [1,1]`    | The processor layout on each face of the cube         |
+--------------------------+-------------------------------------------------------+
| :code:`io_layout: [1,1]` | The processor layout for doing IO                     |
+--------------------------+-------------------------------------------------------+
| :code:`npx`              | The number of grid vertices in east-west direction    |
+--------------------------+-------------------------------------------------------+
| :code:`npy`              | The number of grid vertices in north-south direction  |
+--------------------------+-------------------------------------------------------+
| :code:`npz`              | The number of vertical levels                         |
+--------------------------+-------------------------------------------------------+
| :code:`niles`            | The number of faces of the cube (6 for global domain) |
+--------------------------+-------------------------------------------------------+

The above example will generate a cubed sphere grid with 13 grid points along each face of the
cube sphere; in FV3 nomenclature this would be referred to as a 'C12' grid, i.e. with 12 cells along
each side of the cube face. Most fields live at grid centers and these would have 12x12x6 values.
The processor layout on each face is 1,1 meaning a total of 6 processors are needed. Note that 6 is
the minimum number of processors that FV3 can be used with. If the layout was changed to
:code:`layout: [1,2]` then the number of required processors would be 12.

The variable :code:`io_layout` tells the system how many 'tile' files to write. In almost all
cases this is set to :code:`io_layout: [1,1]`, which is the default. This choice results in 6 files
being written or read, one per face of the cube. Note that the choice must match any restart files
being read. If there are 6 files they cannot be read by 12 processors, say.

Above is the minimal information that needs to be inside :code:`input.nml` in order to properly
generate the geometry. After :code:`fv_control_init` has been called there exists a much larger
data structure that also contains model fields. The relevant geometry fields are extracted and it is
deallocated. Later on when the model is initialized a more extensive version of :code:`input.nml`
is required in order to run the forecast.

The geometry configuration needs to contain a number of other things in addition to the what is
required to generate :code:`input.nml`. These are shown below:

.. code:: yaml

   geometry:
     nml_file_mpp: Data/fv3files/fmsmpp.nml
     trc_file: Data/fv3files/field_table
     akbk: Data/fv3files/akbk64.nc4
     do_write_geom: true
     interp_method: 'bump'
     fieldsets:
       - fieldset: Data/fieldsets/dynamics.yaml
       - fieldset: Data/fieldsets/ufo.yaml

Since the Geometry needs to call FV3, which in turn calls methods in the FMS library, it is
necessary to initialize the FMS library. This is done only once and during the first call to
Geometry. The initialze of FMS requires an :code:`input.nml` file like the initialize of FV3 needs.
The configuration :code:`nml_file_mpp` is where this file is provided, an example of which is
available in the repository.

The :code:`trc_file` provides a list of tracers that the model will use. Though this is not
explicitly part of the Geometry this needs to be provided for FV3 and FMS. Inside these libraries
the tracer variables are set as global variables and so has to be selected during the first call
to the initialize steps, which occurs in the Geometry class not the Model class.

The :code:`akbk` variable provides a path to a file containing the coefficients which define the
hybrid sigma-pressure vertical coordinate used in FV3. Files are provided with the repository
containing :code:`ak` and :code:`bk` for some common choices of vertical coordinate for GEOS and
GFS.

The optional argument :code:`do_write_geom` tells the code to write the longitude and latitude
values to a netCDF file. This file can be ingested in the multi-grid Poisson solver or used to
plot the grid points.

The argument :code:`interp_method` determines the interpolation method to be used in the system. The
options are 'bump' to use the interpolation method provided with BUMP/SABER or 'barycent' to use the
unstructured interpolation method from OOPS.

The list of :code:`fieldsets` provide yaml files detailing the fields that the system will be able
to allocate. The contents of these files are described below. This process is undertaken in the
Geometry because it involves things like the number of model levels when setting the metadata that
is required.

FV3-JEDI does not only support the global FV3 Geometry. It can also be used to generate nested and
regional domains. The regional domain cannot be generated on the fly and has to be read from a file.
FV3 will search a directory that can be provided in the config for this file. The directory is
provided as follows:

.. code:: yaml

   geometry:
     fv3_input_dir: Data/inputs/lam_cmaq/INPUT

Note that when providing :code:`fv3_input_dir` it is not necessary to include the :code:`input.nml`
file, either dynamically or by linking.

Nested grids can be constructed by providing an :code:`input.nml` that sets up a nested grid through
the :code:`nml_file` or by dynamically generating the :code:`input.nml` with the following
additional options:

.. code:: yaml

   geometry:
     layout: [1,1]
     io_layout: [1,1]
     npx: 13
     npy: 13
     npz: 64
     ntiles: 6
     nested: true
     do_schmidt: true
     target_lat: 39.50
     target_lon: -98.35
     stretch_fac: 2.0

In the above :code:`nested` tells the sytem to setup a nested grid. Quantities :code:`do_schmidt`,
:code:`target_lat`, :code:`target_lon` and :code:`stretch_fac` tell FV3 to do a stretching and where
to center the higher resolution region.

.. _fieldmetadata:

FieldMetadata
-------------

FV3-JEDI does not have any hard-wired fields in the system and adding a new field does not involve
any changes to the source code. Instead the fields that can instantiated are first set by in the
FieldMetadata class. Any field that has its metadata set in FieldMetadata can be instantiated at any
point of the system by adding the name of that field to the variable list.

The complete

.. code:: yaml

   Fields:
     - FieldName: ud
       FieldIONames: [u, ud, U]
       Kind: double
       Levels: full
       LongName: u_component_of_native_D_grid_wind
       Space: vector
       StaggerLoc: northsouth
       Tracer: false
       Units: ms-1
       IOFile: core

Below descries the role of each part of this configuration and the values they can take.

:code:`FieldName` is a string with the name that FV3-JEDI uses internally to interact with the
Field. The Field class detailed below provides a number of methods for obtaining a field and this is
value that is used to access the field.

:code:`FieldIONames` is strong giving the name of the field in the file from which it is being read
and written to. This might take different values for different models or different kinds of files.

:code:`Kind` is a string giving the precision of the variable. It can be :code:`double` [default] or
:code:`integer`.

:code:`Levels` is a string providing the number of levels for the field. Values can be :code:`full`
[default], meaning the field is stored at the mid point of each level, or :code:`half` meaning it is
stored at the level edges or it can be an integer representing the dimension in the vertical.
Surface variables would be 1.

:code:`LongName` is a string providing the long name for the variable, typically using the standard
name. The only effect of this choice is in the long name written to the output. LongName is
automatically prepended with :code:`increment_of_` when the field being created is part of the increment.

:code:`Space` is a string representing the kind of data the field encompasses. Valid choices are
:code:`magnitude` [default], :code:`vector` or :code:`direction`.

:code:`StaggerLoc` is a string representing the position within the horizontal grid cell that the
field is stored. The options are :code:`center` [default], :code:`northsouth`, :code:`eastwest` or
:code:`corner`.

:code:`Tracer` is boolean flag that can be set to :code:`true` or :code:`false` [default].

:code:`Units` is a string representing the units of the field.

:code:`IOFile` is a string which provides some optional metadata that can be used to make decisions
about which file a variable is read from and to.

How the FieldMetadata is provided is up to the user. There can be multiple files containing multiple
FieldMetadata passed into the :code:`FieldSets` part of the Geometry configuration.

.. _stateincfield:

State / Increment / Field
-------------------------

The State and Increment classes in FV3-JEDI have a fair amount of overlap between them. The
constructors are largely identical and they share a number methods, such as read and write and
computing of norms. In order to simplify the code FV3-JEDI implements a Field class at the Fortran
level and both State and Increment are made up of collection of and array of type Field.

The user does not interact with the State and Increment classes except to choose which fields will
actually be allocated and to provide paths to files that must be read or written to. The
configuration as it relates to IO is discussed below in the IO section.

The variables are chosen in the configuration as follows:

.. code:: yaml

   state variables: [u,v,T,DELP]

The strings in the list of state variables are the names of the Fields as they are in the file that
is going to be read.

.. code:: fortran

   ! Allocate fields
   allocate(self%fields(vars%nvars()))

   ! Loop over the fields to be allocated
   do var = 1, vars%nvars()

     ! Get the FieldMetadata for this field
     fmd = geom%fields%get_field(trim(vars%variable(var)))

     ! Allocate the field
     fc=fc+1;
     call self%fields(fc)%allocate_field(geom%isc, geom%iec, geom%jsc, geom%jec, &
                                         fmd%levels, &
                                         short_name   = trim(fmd%field_io_name), &
                                         long_name    = trim(fmd%long_name), &
                                         fv3jedi_name = trim(fmd%field_name), &
                                         units        = fmd%units, &
                                         io_file      = trim(fmd%io_file), &
                                         space        = trim(fmd%space), &
                                         staggerloc   = trim(fmd%stagger_loc), &
                                         tracer       = fmd%tracer, &
                                         integerfield = trim(fmd%array_kind)=='integer')

   enddo

In this example the loop traverses the four variables in the list of :code:`state variables`. The
first thing that is done is to call the FieldMetadata object and collect the metadata based on the
variable name string, which is the one of the :code:`FieldIONames`.

**Field accessor functions**

The Field class provides a number of accessor functions in order to obtain fields. Whenever using
these accessor functions the string used to reference the field is the :code:`FieldName` and not the
:code:`FieldIONames`. This it to ensure there is a consistent and predictable way of getting the
field.

Several common function are descibed below.

It is possible to check whether the state or increment contains a particular field with
:code:`has_field`:

.. code:: fortran

   ! Check whether state fields contain temperature
   have_t = has_field(state%fields, 't', t_index)

It is possible to obtain a pointer to the entire field object using :code:`pointer_field`:

.. code:: fortran

   type(fv3jedi_field), pointer :: t(:,:,:)

   ! Get a pointer to the temperature field
   call pointer_field(state%fields, 't', t)

It is possible to obtain a pointer to the array part of the field :code:`pointer_field_array`:

.. code:: fortran

   real(kind=kind_real), pointer :: t(:,:,:)

   ! Get pointer to array part of the field
   call pointer_field_array(state%fields, 't', t)

It is possible to allocate an array and copy the array part of the field into that array using
:code:`allocate_copy_field_array`:

.. code:: fortran

   type(fv3jedi_field), allocatable :: t(:,:,:)

   ! Copy temperature field to local array
   call allocate_copy_field_array(state%fields, 't', t)


.. _io:

IO
--

Input/Output (IO) in FV3-JEDI appears in its own directory, although it is not technically its own
interface class. The methods read and write are part of State and Increment but are also designed to be
accessible from other parts of the code and are currently called by by the :ref:`pseudo` and also by
the :ref:`a2m` variable change. The IO methods do not interact with the State and Increment objects,
only the Fields.

There are two IO classes provided, named :code:`io_geos` and :code:`io_gfs`. The former is for
interacting with cube sphere states History and restarts as output by the GEOS model. The latter is
for interacting with restarts for the GFS model. The class to use is controlled by the configuration
as follows:

.. code:: yaml

  statefile:
    filetype: geos # or gfs

The below shows all the potential configuration for reading or writing a GEOS file.

.. code:: yaml

  statefile:
    # Use GEOS IO
    filetype: geos
    # Path where file is located
    datapath: Data/inputs/geos_c12
    # Filenames for the five groups
    filename_bkgd: geos.bkg.20180414_210000z.nc4
    filename_crtm: geos.bkg.crtmsrf.20180414_210000z.nc4
    filename_core: fvcore_internal_rst
    filename_mois: moist_internal_rst
    filename_surf: surf_import_rst
    # Do the netCDF files use an extra dimension for the tile [true]
    tiledim: true
    # Ingest the metadata [true]
    geosingestmeta: false
    # Clobber the files, i.e. overwrite them with new files [true]
    clobber: false
    # Set whether the variable ps is in the file [false] (affects input only)
    psinfile: false

For GEOS the code chooses which file to write a particular Field into based on the case, with upper
case FieldIONames going into restart files, as predetermined by the model, and lower case going to
the file input as :code:`filename_bkgd`. The file :code:`filename_crtm` covers a small number of
special case variables, these variables are needed by the CRTM but no available from GEOS.

GEOS can write cube sphere files in two ways, one is with a dimension of the variables being the
tile number, where tile is synonymous with face. The other is to write with the 6 tiles
concatenated to make give a dimensions of nx by 6*nx. FV3-JEDI assumes that the files include the
tile dimension but it can also work with files with concatenated tiles, by setting :code:`tiledim`
to false.

It is possible to skip the ingest of the meta data from the files by setting
:code:`geosingestmeta:false`.

The default behavior for all the IO is to clobber the file being written to, that is to say that any
existing file is completely overwritten. By setting :code:`geosingestmeta:false` this can be
overridden so that and fields in the file that FV3-JEDI is not attempting to write remain in tact.

The FV3 model does not use surface pressure as a prognostic variable, instead using :code:`delp` the
'thickness' of the model levels measured in Pascals. Since surface pressure is commonly used in data
assimilation applications a convenience has been added to the IO routines where surface pressure can
be a field even when only pressure thickness is in the file. In some cases surface pressure might
actually be included in the file and pressure thickness not, in these cases the flag
:code:`psinfile:true` can be used to read surface pressure instead of deriving it.

The below shows all the potential configuration for reading a GFS restart file:

.. code:: yaml

   statefile:
     # Use GFS IO
     filetype: gfs
     # Path where file is located
     datapath: Data/inputs/gfs_c12/bkg/
     # GFS restart files that can be read/written
     filename_core: fv_core.res.nc
     filename_trcr: fv_tracer.res.nc
     filename_sfcd: sfc_data.nc
     filename_sfcw: fv_srf_wnd.res.nc
     filename_cplr: coupler.res
     filename_spec: gridspec.nc
     filename_phys: phy_data.nc
     filename_orog: oro_data.nc
     filename_cold: gfs_data.nc
     # Set whether surface pressure is in the file [false] (affects input only)
     psinfile: false
     # Skip reading the coupler.res file [false]
     skip coupler file: false
     # Add the date the beginning of the files [true]
     prepend files with date: true

Whereas with GEOS the file used to write a variable is determined by case, for GFS it is determined
by a flag in the :ref:`fieldmetadata`. Listed above are the potential file names for the restarts
used in GFS. For example there is :code:`filename_core`, this is file that all fields whose
:ref:`fieldmetadata` uses :code:`IOFile: core` will be written to. All the other filenames in the
configuration refer to other restarts used by GFS that group certain fields. The restarts include
one text file :code:`filename_cplr: coupler.res` that contains metadata for the restart. Note that
reading this coupler file can be disabled with :code:`skip coupler file: false` when it is not
available and FV3-JEDI does not need the date and time information

Similarly to GEOS, and described above, GFS offers the ability to convert from pressure thickness to
surface pressure automatically during the read. The behavior can be turned off and surface pressure
read directly from the file using the flag :code:`psinfile:true`.

By defailt when the output for GFS is written the files are prepended with the date so they might
look like, for example, "20200101_00000z.fv_core.res.tile1.nc". This can be turned off with
:code:`prepend files with date: false`.

.. _getvalues:

GetValues
---------



.. _lineargetvalues:

LinearGetValues
---------------

.. _model:

Model
-----

.. _geos:

GEOS
~~~~

.. _ufs:

GFS/UFS
~~~~~~~

.. _pseudo:

Pseudo model
~~~~~~~~~~~~

.. _fv3core:

FV3 core model
~~~~~~~~~~~~~~


.. _linearmodel:

LinearModel
-----------

.. _linearnonlinearvarchanges:

Linear and nonlinear Variable Changes
-------------------------------------

.. _a2m:

Analysis2Model
~~~~~~~~~~~~~~

ColdStartWinds
~~~~~~~~~~~~~~

Control2Analysis
~~~~~~~~~~~~~~~~

GEOSRstToBkg
~~~~~~~~~~~~

Model2GeoVaLs
~~~~~~~~~~~~~

NMCBalance
~~~~~~~~~~

VertRemap
~~~~~~~~~
