  .. _top-fv3-jedi-classes:

.. _classes:

Classes and Configuration
=========================

This page describes the classes that are implemented in FV3-JEDI. It explains in broad terms what they are responsible for, how they are implemented and explains the configuration options that are available for controlling their behavior.

.. _geometry:

Geometry
--------

The Geometry class is responsible for creating and storing the FV3 cubed-sphere grid structure. It accomplishes the generation of the FV3 grid by calling the routine :code:`fv_control_init` that lives within the FV3 model. The code is provided with three interfaces to :code:`fv_control_init` to cover the way it is handled in the current version of FV3, legacy versions of FV3 and GEOS. It will automatically build the correct version depending on the choice of model that FV3-JEDI is built with.

FV3 routines like :code:`fv_control_init` expect there to be a file called :code:`input.nml` present in the run directory. This file controls many aspects of the way in which FV3 behaves, from the resolution and processor layout to whether the dynamical core is hydrostatic. In forecasts involving FV3 this file is typically static and is placed into the directory ahead of time. For data assimilation applications, where there are often multiple resolutions involved, it is not possible to have a static :code:`input.nml` file. Instead the file is dynamically created or versions of it are moved in and out of the directory as needed during the runs. The source code will handle the placement and removal of :code:`input.nml` but the user is responsible for which file is used or how it is created.

In order to use an already constructed :code:`input.nml` file the user can provide :code:`nml_file` in the geometry config as follows:

.. code:: yaml

   geometry:
     nml_file: Data/fv3files/input_gfs_c12_p12.nml

Note that the file can be located somewhere other than the run directory. As the code is running the file will be linked into the run directory and the link destroyed when no longer needed. In order to dynamically generate :code:`input.nml` the user can input the spereate parts of the file as follows:

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
| :code:`npz`              | The number of vertical layers                         |
+--------------------------+-------------------------------------------------------+
| :code:`niles`            | The number of faces of the cube (6 for global domain) |
+--------------------------+-------------------------------------------------------+

The above example will generate a cubed sphere grid with 13 grid points along each face of the cube sphere; in FV3 nomenclature this would be referred to as a 'C12' grid, i.e. with 12 cells along each side of the cube face. Most fields live at grid centers and these would have 12x12x6 values. The processor layout on each face is 1,1 meaning a total of 6 processors are needed. Note that 6 is the minimum number of processors that FV3 can be used with. If the layout was changed to :code:`layout: [1,2]` then the number of required processors would be 12.

The variable :code:`io_layout` tells the system how many 'tile' files to write. In almost all cases this is set to :code:`io_layout: [1,1]`, which is the default. This choice results in 6 files being written or read, one per face of the cube. Note that the choice must match any restart files being read. If there are 6 files they cannot be read by 12 processors, say.

Above is the minimal information that needs to be inside :code:`input.nml` in order to properly generate the geometry. After :code:`fv_control_init` has been called there exists a much larger data structure that also contains model fields. The relevant geometry fields are extracted and it is deallocated. Later on when the model is initialized a more extensive version of :code:`input.nml` is required in order to run the forecast.

The geometry configuration needs to contain a number of other things in addition to the what is required to generate :code:`input.nml`. These are shown below:

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

Since the Geometry needs to call FV3, which in turn calls methods in the FMS library, it is necessary to initialize the FMS library. This is done only once and during the first call to Geometry. The initialze of FMS requires an :code:`input.nml` file like the initialize of FV3 needs. The configuration :code:`nml_file_mpp` is where this file is provided, an example of which is available in the repository.

The :code:`trc_file` provides a list of tracers that the model will use. Though this is not explicitly part of the Geometry this needs to be provided for FV3 and FMS to run. Inside these libraries the tracer variables are set as global variables and so have to be selected during the first call to the initialize steps, which occurs in the Geometry class rather than the Model class.

The :code:`akbk` variable provides a path to a file containing the coefficients which define the hybrid sigma-pressure vertical coordinate used in FV3. Files are provided with the repository containing :code:`ak` and :code:`bk` for some common choices of vertical resolution for GEOS and GFS.

The optional argument :code:`do_write_geom` tells the code to write the longitude and latitude values to a netCDF file. This file can be ingested in the multi-grid Poisson solver or used to plot the grid points.

The argument :code:`interp_method` determines the interpolation method to be used in the system. The options are 'bump' to use the interpolation method provided with BUMP/SABER or 'barycent' to use the unstructured interpolation method from OOPS.

The list of :code:`fieldsets` provide yaml files detailing the fields that the system will be able to allocate. The contents of these files are described in :ref:`fieldmetadata`. This process is undertaken in the Geometry because it involves things like the number of model levels when setting the metadata. Further, the constructors for States and Increments do not necessarily recvieve configuration so setting the FieldMetadata there would not be straightforward.

FV3-JEDI does not only support the global FV3 Geometry. It can also be used to generate nested and regional domains. The regional domain cannot be generated on the fly and has to be read from a file. FV3 will search a directory that can be provided in the config for this file. The directory is provided as follows:

.. code:: yaml

   geometry:
     fv3_input_dir: Data/inputs/lam_cmaq/INPUT

Note that when providing :code:`fv3_input_dir` it is not necessary to include the :code:`input.nml` file, either dynamically or by linking.

Nested grids can be constructed by providing an :code:`input.nml` that sets up a nested grid through the :code:`nml_file` or by dynamically generating the :code:`input.nml` with the following additional options:

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

In the above :code:`nested` tells the sytem to setup a nested grid. Quantities :code:`do_schmidt`, :code:`target_lat`, :code:`target_lon` and :code:`stretch_fac` tell FV3 to do a stretching and where to center the higher resolution region.

.. _fieldmetadata:

FieldMetadata
-------------

FV3-JEDI does not have any hard-wired fields in the system and adding a new field does not involve any changes to the source code. Instead the fields that can instantiated are first set by in the FieldMetadata class. Any field that has its metadata set in FieldMetadata can be instantiated at any point in the system by adding the name of that field to the variable list.

The complete set of potential metadata for a field is as follows:

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

:code:`FieldName` is a string with the name that FV3-JEDI uses internally to interact with the Field. The Field class detailed below provides a number of methods for obtaining a field and this is value that is used to access the field.

:code:`FieldIONames` is string giving the name of the field in the file from which it is being read and written to. This might take different values for different models or different kinds of files.

:code:`Kind` is a string giving the precision of the variable. It can be :code:`double` [default] or :code:`integer`. If the field is integer it is not actually stored as an integer but the flag allows for special treatment where necessary. A special interpolation scheme is used for integer fields for example.

:code:`Levels` is a string providing the number of layers for the field. Values can be :code:`full` [default], meaning the field is stored at the mid point of each layer, or :code:`half` meaning it is stored at the model levels. Alternatively it can be an integer representing the vertical dimension. Surface variables would be "1".

:code:`LongName` is a string providing the long name for the variable, typically using the standard name. The main effect of this choice is in the long name written to the output. LongName is automatically prepended with :code:`increment_of_` when the field being created is part of the increment.

:code:`Space` is a string representing the kind of data the field encompasses. Valid choices are :code:`magnitude` [default], :code:`vector` or :code:`direction`. This choice is important when it comes to how a field gets interpolated. Fields that are vectors require special attention when doing interpolation and fields that are a direction are interpolated using nearest neighbor.

:code:`StaggerLoc` is a string representing the position within the horizontal grid cell that the field is stored. The options are :code:`center` [default], :code:`northsouth`, :code:`eastwest` or :code:`corner`.

:code:`Tracer` is boolean flag that can be set to :code:`true` or :code:`false` [default].

:code:`Units` is a string representing the units of the field.

:code:`IOFile` is a string which provides some optional metadata that can be used to make decisions about which file a variable is read from and to.

How the FieldMetadata is provided is up to the user. There can be multiple files containing multiple FieldMetadata passed into the :code:`FieldSets` part of the Geometry configuration.

.. _stateincfield:

State / Increment / Field
-------------------------

The State and Increment classes in FV3-JEDI have a fair amount of overlap between them. The constructors are largely the same and they share a number methods, such as read and write and computing of norms. In order to simplify the code FV3-JEDI implements a Fields class at the Fortran level and both State and Increment inherit from the Fields base class.

The main data structure in the Fields class is an array of type Field (no 's'):

.. code:: fortran

  type :: fv3jedi_fields

    type(fv3jedi_field), allocatable :: fields(:)  ! Array of field

  endtype fv3jedi_fields

The only specialization the State and Increment add to the Fields class are methods specific to each.

The user interaction with the State and Increment classes extends to choosing which fields will actually be allocated and to provide paths to files that must be read or written to. The configuration as it relates to IO is discussed below in the IO section.

As an example for creating a State the variables are chosen in the configuration as:

.. code:: yaml

   state variables: [u,v,T,DELP]

The strings in the list of variables are the names of the Fields as they are in the file that is going to be read. The below example shows how the list of fields are allocated in the Fields class:

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

In this example the loop traverses the four variables in the list of :code:`state variables`. The first thing that is done is to call the FieldMetadata Fortran API and collect the metadata based on the variable name string, which is the one of the :code:`FieldIONames`.

**Field accessor functions**

The Fields and Field classes provide a number of accessor functions in order to obtain actual field data that can be used or manipulated.

Whenever using these accessor functions the string used to reference the field is the :code:`FieldName` and not the :code:`FieldIONames`. This it to ensure there is a consistent and predictable way of getting the field regardless of the way a variable is named in whatever file is being read. For example the file being read may have temperature stored as 't' while another file from a different model may have 'T'. In the yaml configuration file the user would choose either 't' or 'T' depending on which is in the file. In the source code this particular variable would only ever be accessed using 't', which is the :code:`FieldName` for temperature.

There are three accessor functions, :code:`has_field`, :code:`get_field` and :code:`put_field` and each function has several interfaces.

The function :code:`has_field` queries whether a field with a particular :code:`FieldName` is present. An example of the interface is show below. This code snippet shows two possible interfaces to :code:`has_field`, where the array of fields is passed explicitly and where it is called from the class. Optionally the index in the array can be returned from the method.

.. code:: fortran

   ! Check whether state fields contain temperature
   have_t = has_field(state%fields, 't', t_index)

   ! Check whether state fields contain temperature
   have_t = state%has_field('t')

The subroutine :code:`get_field` can be used to return the field data with a particular :code:`FieldName`, aborting if the field is not present. The method can return the field in three different formats, as a pointer to the array, a copy of the array or as a pointer to the entire field type. The below shows these three ways of using the method:

.. code:: fortran

   ! Get a pointer to the field data
   real(kind=kind_real), pointer :: t(:,:,:)
   call state%get_field('t', t)

   ! Get a copy of the field data
   real(kind=kind_real), allocatable :: t(:,:,:)
   call state%get_field('t', t)

   ! Get a pointer to the field structure
   type(fv3jedi_field), pointer :: t
   call state%get_field('t', t)

Like the :code:`has_field` method, the :code:`get_field` method can be used by passing the array of field, :code:`call get_field(state%fields, 't', t)`.

The third accessor function is :code:`put_field`, which has the exact same interfaces as :code:`get_field` except it overwrites the internal field data with the input data.

Note that FV3-JEDI only supports rank 3 fields. Fields that are surface quantities simply have size 1 in the third dimension. Quantities such as tracers are stored as individual rank 3 arrays and not in one large array. Performing processes on tracers, for example to remove negative values, can be achieved using the :code:`tracer` flag in the FieldMetadata.


.. _io:

IO
--

Input/Output (IO) in FV3-JEDI appears in its own directory, although it is not technically its own interface class. The methods read and write are part of State and Increment (Fields) but are also designed to be accessible from other parts of the code and are currently called by by the :ref:`pseudo` and also by the :ref:`a2m` variable change. The IO methods do not interact with the State and Increment objects, only the Fields base class.

There are two IO classes provided, named :code:`io_geos` and :code:`io_gfs`. The former is for interacting with cube sphere history files and restarts as output by the GEOS model. The latter is for interacting with restarts for the GFS/UFS model. The class to use is controlled by the configuration as follows:

.. code:: yaml

  # Read a GEOS file
  statefile:
    filetype: geos

  # Read a GFS file
  statefile:
    filetype: gfs

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

For GEOS the code chooses which file to write a particular Field into based on the case, with upper case FieldIONames going into restart files, as predetermined by the model, and lower case going to the file input as :code:`filename_bkgd`. The file :code:`filename_crtm` covers a small number of special case variables, these variables are needed by the CRTM but not available from GEOS.

GEOS can write cube sphere files in two ways, one is with a dimension of the variables being the tile number, where tile is synonymous with cube face. The other is to write with the 6 tiles concatenated to make give a dimensions of nx by 6*nx. FV3-JEDI assumes that the files include the tile dimension but it can also work with files with concatenated tiles, by setting :code:`tiledim` to false.

It is possible to skip the ingest of the meta data from the files by setting :code:`geosingestmeta:false`.

The default behavior for all the IO is to clobber the file being written to, that is to say that any existing file is completely overwritten. By setting :code:`clobber:false` this can be overridden so that and fields in the file that FV3-JEDI is not attempting to write remain in tact.

The FV3 model does not use surface pressure as a prognostic variable, instead using :code:`delp` the 'thickness' of the model layers, measured in Pascals. Since surface pressure is commonly used in data assimilation applications a convenience has been added to the IO routines where surface pressure can be a field even when only pressure thickness is in the file. In some cases surface pressure might actually be included in the file and pressure thickness not, in these cases the flag :code:`psinfile:true` can be used to read surface pressure instead of deriving it.

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

Whereas with GEOS the file used to write a variable is determined by case, for GFS it is determined by a flag in the :ref:`fieldmetadata`. Listed above are the potential file names for the restarts used in GFS. For example there is :code:`filename_core`, this is file that all fields whose :ref:`fieldmetadata` uses :code:`IOFile: core` will be written to. All the other filenames in the configuration refer to other restarts used by GFS that group certain fields. The restarts include one text file :code:`filename_cplr: coupler.res` that contains metadata for the restart. Note that reading this coupler file can be disabled with :code:`skip coupler file: false` when it is not available and FV3-JEDI does not need the date and time information. The keys :code:`filename_cold`, :code:`filename_orog` and :code:`filename_phys` are included for completeness but are used infrequently. The files referenced by these keys files do not contain fields the data assimilation system would normally interact with. The fields more typically used are contained in the files referenced with :code:`filename_core`, which contains the main dynamics fields; :code:`filename_trcr`, which contains the tracers; :code:`filename_sfcd`, which contains the surface fields and :code:`filename_sfcw`, which contains the surface winds.

Similarly to GEOS, and described above, GFS offers the ability to convert from pressure thickness to surface pressure automatically during the read. The behavior can be turned off and surface pressure read directly from the file using the flag :code:`psinfile:true`.

By default when the output for GFS is written the files are prepended with the date so they might look like, for example, "20200101_00000.fv_core.res.tile1.nc". This can be turned off with :code:`prepend files with date: false`.

.. _getvalues:

GetValues and LinearGetValues
-----------------------------

The GetValues and LinearGetValues methods are responsible for interpolating the cube sphere fields to the observation locations set by the observation operators. The fields that come into the methods are cube sphere versions of the fields that the observation operator requests. All the routines in these methods are generic and the user has little interaction with them. The only choices that can affect the behavior is in the :ref:`geometry`, where the user can choose the interpolation method to be used throughout the system. Note that it is not expected that this choice will be available in the long term and exists now primarily to test different interpolation schemes. The kind of interpolation is also impacted by the :ref:`fieldmetadata`. Scaler real fields are interpolated using the interpolation method set in the geometry configuration. Other kinds of fields, such as integer valued fields are interpolated with custom and hardwired methods.

.. _model:

Model
-----

The Model class is where FV3-JEDI interacts with the actual forecast model. FV3-JEDI is capable of using the forecast models in-core with data assimilation applications as well as interacting with the models through files. The choice whether to interact with the model in-core depends on the application being run. For example there can be much benefit to being in-core for a multiple outer loop 4DVar data assimilation system or when running H(x) calculations. However, there is no benefit to including the model for a 3DVar application and indeed the model is never instantiated in those kinds of applications.

Other than in the IO routines, the code in the other classes is identical regardless of the underlying FV3-based model, whether it be GEOS or GFS. In the Model class the code depends heavily on the underlying model, although all the models use FV3 they have differing infrastructure around them.

Instantiation of Model objects is controlled through a factory and the only thing limiting which can be compiled is the presence of the model itself and making sure that there are not multiple versions of FV3 being linked to. Which models can be built with is described in the :ref:`buildwithmodel` section. At run time the model that is used is chosen through the configuration key :code:`name` as follows:

.. code:: yaml

   # Instantiate the GEOS model object
   model:
     name: GEOS

.. code:: yaml

  # Instantiate the UFS model object
  model:
    name: UFS

The current options are GEOS, UFS, FV3LM and Pseudo

.. _geos:

GEOS
~~~~

The configuration for the GEOS model needs to include the time step for the model, a path to a directory where GEOS can be run from and the variables, which contains a list of fields within GEOS that need to be accessed. The :code:`geos_run_directory` is a directory that contains restarts, boundary conditions, configurations and any other files that are needed in order to run GEOS. This directory is created ahead of making any forecasts involving GEOS. During the run the system will change directory to the the :code:`geos_run_directory`.

.. code:: yaml

  model:
    name: GEOS
    tstep: PT30M
    geos_run_directory: Data/ModelRunDirs/GEOS/
    model variables: [U,V,PT,PKZ,PE,Q,QILS,QLLS,QICN,QLCN]


.. _ufs:

GFS/UFS
~~~~~~~

Interfacing FV3-JEDI to the UFS model through the NUOPC driver is an ongoing effort and all the features are not fully supported yet.

.. _pseudo:

Pseudo model
~~~~~~~~~~~~

The pseudo model can be used with GFS or GEOS. All this model does is read states from disk that are valid at the end of the time step being 'propagated'. The configuration for pseudo model is very similar to that described in :ref:`io`. However, when referring to a file instead of using, for example, :code:`filename_core: 20200101_000000.fv_core.res.nc` the correct syntax would be :code:`filename_core: %y%m%d_%h%m%d.fv_core.res.nc`. The system will pick the correct date for the file based on the time of the model.

Note that OOPS provides a generic pseudo model, which is demonstrated in the :code:`hofx_nomodel` test. The advantage of using the FV3-JEDI pseudo model is that the yaml only requires a single entry with templated date and time; in the OOPS pseudo model a list of states to read is provided. Another advantage is that in data assimilation applications involving the model, such as 4DVar, the application propagates the model through the window after the analysis in order to compute 'o minus a'. This second propagation of the model is not useful with any pseudo model and can be turned off in the FV3-JEDI pseudo model by specifying :code:`run stage check: 1` as shown in this example:

.. code:: yaml

   model:
     name: PSEUDO
     pseudo_type: geos
     datapath: Data/inputs/geos_c12
     filename_bkgd: geos.bkg.%yyyy%mm%dd_%hh%MM%ssz.nc4
     filename_crtm: geos.bkg.crtmsrf.%yyyy%mm%dd_%hh%MM%ssz.nc4
     run stage check: 1

.. _fv3core:

FV3 core model
~~~~~~~~~~~~~~

FV3-JEDI interfaces to the standalone version of the FV3 dynamical core. This is used primarily for testing purposes and particularly to test applications that need an evolving and rewindable model without the long run times and complexity of the model with full physics and complex infrastructure. Below shows an example configuration for the stand alone model:

.. code:: yaml

  model:
    name: FV3LM
    nml_file: Data/fv3files/input_gfs_c12.nml
    trc_file: Data/fv3files/field_table
    tstep: PT15M
    model variables: [u,v,ua,va,T,DELP,sphum,ice_wat,liq_wat,o3mr,phis]

Similar to the Geometry the Model needs an :code:`input.nml` and :code:`field_table` file to be present in the directory so these are passed in through the model configuration. Additionally it is necessary to provide the time step and list of variables that the model will provide.

.. _linearmodel:

LinearModel
-----------

.. _linearnonlinearvarchanges:

FV3-JEDI ships with a linearized version of the FV3 dynamical core named FV3-JEDI-LINEARMODEL. Note that the linear model comes in a separate repository though it builds only as part of FV3-JEDI. The linear model is a global model only and does not currently support regional and nested domains.

An example of the configuration is shown below.

.. code:: yaml

  linear model:

    # Name of the LinearModel in the factory
    name: FV3JEDITLM

    # FV3 required files
    nml_file: Data/fv3files/input_geos_c12.nml
    trc_file: Data/fv3files/field_table
    nml_file_pert: Data/fv3files/inputpert_4dvar.nml

    # Time step
    tstep: PT1H

    # Run the dynamical core component
    lm_do_dyn: 1

    # Run the turbulence core component
    lm_do_trb: 1

    # Run the convection and microphysics components
    lm_do_mst: 1

    # Variables in the linear model
    tlm variables: [u,v,t,delp,q,qi,ql,o3ppmv]

The linear model requires the same :code:`input.nml` and :code:`field_table` files that the nonlinear version of FV3 needs. In addition is needs an :code:`inputpert.nml` file, which is provided through the :code:`nml_file_pert` keyword. The different components of the linearized model can be turned on and off with the :code:`lm_do_` keywords. The three components are the dynamical core, the turbulence scheme and the linearized moist physics.

.. _varchanges:

Linear and nonlinear Variable Changes
-------------------------------------

FV3-JEDI has a number of linear and nonlinear variable changes which are used to transform between increments or states with different sets of variables. These variable changes are used to go between different components of the system where different variables might be required.

Variable changes are constructed using factories so are chosen through the configuration. Some variable changes require additional configuration and some require nothing additional. The details of each configuration is outlined below.

Many of the variable changes take on the same general format structure, outlined in the following steps.

1. The first step is to copy all the variables that are present in both input and output states and increments.

  .. code:: fortran

      ! Array of variables that cannot be obtained from input
      character(len=field_clen), allocatable :: fields_to_do(:)

      ! Copy fields that are the same in both
      call copy_subset(xin%fields, xout%fields, fields_to_do)

The :code:`copy_subset` routine identifies the variables in both and copies the data from input to output. Optionally it returns a list of variables that are in the output that are not in the input, i.e. the list of variables that need to be derived from the inputs.

2. The second step is to prepare all the potential output variables that might be needed. The below provides and example of how temperature could be prepared from various inputs:

  .. code:: fortran

      logical :: have_t
      real(kind=kind_real), pointer     :: pt (:,:,:)
      real(kind=kind_real), pointer     :: pkz(:,:,:)
      real(kind=kind_real), pointer     :: tv (:,:,:)
      real(kind=kind_real), pointer     :: q  (:,:,:)
      real(kind=kind_real), allocatable :: t  (:,:,:)

      have_t = .false.
      if (xin%has_field('tv') .and. xin%has_field('q')) then
        allocate(t(geom%isc:geom%iec,geom%jsc:geom%jec,1:geom%npz))
        call xin%get_field('tv', tv)
        call xin%get_field('q', q)
        call tv_to_t(geom, tv, q, t)
        have_t = .true.
      else if (xin%has_field('pt') .and. xin%has_field('pkz')) then
        allocate(t(geom%isc:geom%iec,geom%jsc:geom%jec,1:geom%npz))
        call xin%get_field('pt', pt)
        call xin%get_field('pkz', pkz)
        call pt_to_t(geom, pkz, pt, t)
        have_t = .true.
      end if

Note that variables that are not necessarily needed to provide another variable are typically pointers. Variables that are obtained one of multiple ways are typically allocatable arrays. The boolean variable :code:`have_t` determines that a variable, in this case temperature, is now available.

3. The third step is to loop through the output variables that could not be copied and attempt to get them from the prepared variables.

  .. code:: fortran

       ! Loop over the fields not found in the input state and work through cases
       do f = 1, size(fields_to_do)

         ! Get output field name
         select case (trim(fields_to_do(f)))

         ! Temperature case
         case ("t")

           ! Abort if field not obtainable and otherwise put into data
           if (.not. have_t) call field_fail(fields_to_do(f))
           call xout%put_field(trim(fields_to_do(f)),  t)

         end select

       end do

If the variable has not been prepared the variable change will fail, otherwise the :code:`put_field` will overwrite the field data with the prepared variable.

.. _a2m:

Analysis2Model
~~~~~~~~~~~~~~

The analysis to model variable change is used to transform between the background variables (the variables that will be analyzed) and the variables used to drive the model.

In some cases the model variables can be quite extensive and the user may wish to save memory by limiting the number of variables included in the background and written to the analysis file. The nonlinear analysis to model variable change has the ability to read a variable from file if it is not available from the inputs. The configuration is the same as used in the IO routines, with both GFS and GEOS IO available in the variable change.

.. code:: yaml

    variable change: Analysis2Model

    filetype: gfs
    datapath: Data/inputs/gfs_c12/bkg/
    filename_core: 20180415.000000.fv_core.res.nc
    filename_trcr: 20180415.000000.fv_tracer.res.nc
    filename_sfcd: 20180415.000000.sfc_data.nc
    filename_sfcw: 20180415.000000.fv_srf_wnd.res.nc
    filename_cplr: 20180415.000000.coupler.res

The linear analysis to model variable change is used to transform between the analysis increment and the linear model. The linear version does not require any configuration.

.. _cstart:

ColdStartWinds
~~~~~~~~~~~~~~

The cold start winds variable change is specific to the GFS model. GFS cold starts are obtained when re-gridding from different grids or resolutions. In this variable transform the cold start winds are converted to the D-Grid winds needed to drive the FV3 model. There is no configuration for this variable change, except to choose to use it through the factory. There is only a nonlinear version of the variable change.

.. _c2a:

Control2Analysis
~~~~~~~~~~~~~~~~

The control to analysis variable change converts from the control variables (here the variables used in the B matrix) to the analysis variables. In the variational assimilation algorithm only the linear version of this variable change is needed but a nonlinear version is provided to the purpose of training the covariance model.

For the NWP applications the control variables are typically stream function and velocity potential while the analysis variables are winds. To transform between stream function and wind requires a straightforward derivative operator but the inverse transforms require the use of a Poisson solver to solve the inverse Laplacian after transforming from winds to vorticity and divergence.
A Finite Element Mesh Poisson Solver (FEMPS) is provided as part of FV3-BUNDLE and is linked to in the variable transform. When converting without using FEMPS no configuration is required. When using FEMPS the configuration options are show below:

.. code:: yaml

   variable change: Control2Analysis

   # Number of iterations of the Poisson solver
   femps_iterations: 50

   # Number of grids in the multigrid heirachy
   femps_ngrids: 6

   # Number of levels per processor (-1 to automatically distribute)
   femps_levelprocs: -1

   # Path containing geometry files for the multigrid
   femps_path2fv3gridfiles: Data/femps

More extensive documentation about FEMPS will be added soon.

.. _geosr2b:

GEOSRstToBkg
~~~~~~~~~~~~

The GEOSRstToBkg variable change is specific to the GEOS model and is used to convert from GEOS restart file like variables to so-called background like variables. Restart variables include D-Grid winds, potential temperature and pressure the to the kappa while background variables are A-Grid winds, temperature and surface pressure.

Currently this variable change works slightly differently to the others in that you need to specify, through the configuration, which variables need to be transformed. The choices are made with the key :code:`do_` as show below:

.. code:: yaml

  variable change: GeosRst2Bkg
  do_clouds: true
  do_wind: true
  do_temperature: true
  do_pressure: true
  pres_var: delp

The keyword :code:`pres_var` controls which pressure variable in the background is used to determine the pressure variables in the restart.

.. _m2g:

Model2GeoVaLs
~~~~~~~~~~~~~

The Model2GeoVaLs variable change is used between running the model and calling the observation operator. It transforms between the model variables and the variables called for by each observation operator.

There is also a linear version of this variable change that is used before and after calling the linearized observation operators.

The user does not interact with the Model2GeoVaLs through the configuration. However, it is often necessary to modify the source code in this variable change when adding a new variable to the UFO or starting to use an observation operator that has not been used in FV3-JEDI before and requires a variable not previously prepared.

.. _nmcbal:

NMCBalance
~~~~~~~~~~

The NMC balance variable change is used to convert between the variables needed by the B matrix and the analysis variables by the method used in the GSI. In this case there is only a linear version of the variable change and any coefficients are assumed to have been precomputed.

The NMC balance acts only on a Gaussian grid so the method includes interpolation to the Gaussian grid and back to the cube sphere as part of the transform.

Some configuration is required in order to use the NMC balance variable change, shown below:

.. code:: yaml

  variable change: NMCBalance

  # Number of processors in the x direction
  layoutx: 3

  # Number of processors in the y direction
  layouty: 2

  # Number of halo points in the x direction
  hx: 1

  # Number of halo points in the y direction
  hy: 1

  # Path to file containing the vertical balance coefficients
  path_to_nmcbalance_coeffs: Data/inputs/nmcbalance/global_berror.l64y192.nc

  # Optionally read the lon/lat from the file, other wise generate Gaussian grid
  read_latlon_from_nc: 0

Note that the user is responsible for choosing an appropriate processor layout for the Gaussian grid that should give the same number of processors as used in the main FV3-JEDI :ref:`geometry`. The user can also specify the number of halo points. It's also possible to obtain the longitude and latitude values of the Gaussian grid from file instead of computing them.

.. _vertremap:

VertRemap
~~~~~~~~~

The vertical remapping variable change is used primarily in conjunction with the :ref:`cstart` variable change in order to convert from cold start variables to to warm start variables. It can also be used to do a straightforward remapping when necessary, for example when the surface pressure has changed.

The configuration for the transform is quite extensive but most is related to initializing the FV3 data structure and is similar to what is used in the :ref:`geometry`. Since the methods make calls into FV3 it is necessary to initialize an FV3 structure to pass in. In addition the user can specify whether the inputs are cold starts, which have specific variable names, controlled by the Data/fieldsets/cold_start_npz.yaml files. This would be set to false in the case that the variable change is not being used for cold starts and is being used as part of some other applications. The final thing that needs to be specified is the source of inputs, which is a string controlling how the transform behaves internally in FV3; this is unlikely to be changed from the default values.

.. code:: yaml

  # Name of variable change in the factory
  variable change: VertRemap

  # Is the variable change being used in the context of remapping cold starts
  input is cold starts: true

  # Configuration to initialize FV3
  trc_file: Data/fv3files/field_table_cold_starts
  layout: [1,1]
  io_layout: [1,1]
  npx: 13
  npy: 13
  npz: 127
  ntiles: 6
  hydrostatic: false
  nwat: 6

  # Type of inputs to the variable change
  source of inputs: FV3GFS GAUSSIAN NETCDF FILE
