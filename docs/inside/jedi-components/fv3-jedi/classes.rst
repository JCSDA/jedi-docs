  .. _top-fv3-jedi-classes:

.. _classes:

Classes and Configuration
=========================

This page describes the classes that are implemented in FV3-JEDI. It explains in broad terms what they are responsible for, how they are implemented and explains the configuration options that are available for controlling their behavior.


.. _fieldmetadata:

FieldMetadata
-------------

FV3-JEDI has default fields defined in the system. The fields are first set in the FieldMetadata class, then any field that has been set can be instantiated at any point in the system by adding the name of that field to the variable list. When selecting the variable the user can choose from one of the long name, short name or IO name described below.

Using the definition of the field :code:`ud` as an example, the complete set of metadata for a field is as follows:

.. code:: cpp

   longName = "u_component_of_native_D_grid_wind";
   shortName = "ud";
   units = "ms-1";
   kind = "double";
   tracer = "false";
   horizontalStaggerLocation = "northsouth";
   levels = "full";
   space = "vector";


:code:`longName` is a string providing the long name for the variable, typically using the standard (CF) name. The main effect of this choice is how each field is named in the prints of State and Increment in the log files.

:code:`shortName` is a string with the name that FV3-JEDI uses internally to interact with the Field. The Field class detailed below provides a number of methods for obtaining a field and this is value that is used to access the field. Note that you can also use the long name to interact with the field within the FV3-JEDI code.

:code:`units` is a string representing the units of the field.

:code:`kind` is a string giving the precision of the variable. It can be :code:`double` or :code:`integer`. If the field is integer it is not actually stored as an integer but the flag allows for special treatment where necessary. A special interpolation scheme is used for integer fields for example.

:code:`tracer` is boolean flag that can be set to :code:`true` or :code:`false`.

:code:`horizontalStaggerLocation` is a string representing the position within the horizontal grid cell that the field is stored. The options are :code:`center`, :code:`northsouth`, :code:`eastwest` or :code:`corner`.

:code:`levels` is a string providing the number of layers for the field. Values can be :code:`full`, meaning the field is stored at the mid-point of each layer, :code:`half` meaning it stored at the model levels or :code:`halfplusone` meaning it is stored also at an additional level above the top of the domain. Alternatively, it can be an integer representing the vertical dimension. Surface variables would be "1".

:code:`space` is a string representing the kind of data the field encompasses. Valid choices are :code:`magnitude`, :code:`vector` or :code:`direction`. This choice is important when it comes to how a field gets interpolated. Fields that are vectors require special attention when doing interpolation and fields that are a direction are interpolated using nearest neighbor.


Users can add and overwrite part of these default fields metadata by setting :code:`field metadata override` in the geometry subsection of the yaml. They do not have to make changes to the source code.

For example:

.. code:: yaml

   geometry:
     [...]
     field metadata override: Data/fieldmetadata/gfs-restart.yaml


With the content of :code:`gfs-restart.yaml` being a list of fields to be modified:

.. code:: yaml

   field meta data:

   - long name: u_component_of_native_D_grid_wind
     io name: u

   - long name: smc
     io file: surface


The following fieldmetadata can be modified:
:code:`long name` is mandatory, to say which variable you are overriding the other metadata of. However :code:`long name` itself cannot be overridden since it's the anchor to everything else.

:code:`io name` is a string giving the name of the field in the file from which it is being read and written to. This might take different values for different models or different kinds of files

:code:`units` is a string to provide the units

:code:`io file` is a string which provides some optional metadata that can be used to make decisions about which file a variable is read from and to.

:code:`interpolation type` is a string whose values can be "integer", "nearest" or "default". The default is integer if "kind" is integer, nearest if "space" is "direction" and default in all other cases.


.. _geometry:

Geometry
--------

The Geometry class is responsible for creating and storing the FV3 cubed-sphere grid structure. It accomplishes the generation of the FV3 grid by calling the routine :code:`fv_control_init` that lives within the FV3 model. The code is provided with three interfaces to :code:`fv_control_init` to cover the way it is handled in the current version of FV3, legacy versions of FV3 and GEOS.
It will automatically build the correct version depending on the choice of model that FV3-JEDI is built with.

FV3 routines like :code:`fv_control_init` expect there to be a file called :code:`input.nml` present in the run directory. This file controls many aspects of the way in which FV3 behaves, from the resolution and processor layout to whether the dynamical core is hydrostatic. In forecasts involving FV3 this file is typically static and is placed into the directory ahead of time. For data assimilation applications, where there are often multiple resolutions involved, it is not possible to have a static :code:`input.nml` file. Instead, the file is dynamically created or versions of it are moved in and out of the directory as needed during the runs. The source code will handle the placement and removal of :code:`input.nml` but the user is responsible for which file is used or how it is created.

In order to use an already constructed :code:`input.nml` file the user can provide :code:`namelist filename` in the geometry config as follows:

.. code:: yaml

   geometry:
     namelist filename: Data/fv3files/input_gfs_c12_p12.nml

Note that the file can be located somewhere other than the run directory.

In order to dynamically generate :code:`input.nml` the user can input the separate parts of the file as follows:

.. code:: yaml

   geometry:
     layout: [1,1]     # optional, default values are [1,1]
     io_layout: [1,1]  # optional, default values are [1,1]
     npx: 13
     npy: 13
     npz: 127
     ntiles: 6         # optional, default value is 6

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

The above example will generate a cubed sphere grid with 13 grid points along each face of the cube sphere; in FV3 nomenclature this would be referred to as a 'C12' grid, i.e., with 12 cells along each side of the cube face. Most fields live at grid centers and these would have 12x12x6 values.
The processor layout on each face is [1,1] meaning a total of 1x1x6 processors are needed. Note that 6 is the minimum number of processors that FV3 can be used with. If the layout was changed to :code:`layout: [1,2]` then the number of required processors would be 12.

The variable :code:`io_layout` tells the system how many 'tile' files to write when using FSM restarts. In almost all cases this is set to :code:`io_layout: [1,1]`, which is the default. This choice results in 6 files being written or read, one per face of the cube. Note that the choice must match any restart files being read. If there are 6 files they cannot be read by 12 processors.

Above is the minimal information that needs to be inside :code:`input.nml` in order to properly generate the geometry. After :code:`fv_control_init` has been called there exists a much larger data structure that also contains model fields. The relevant geometry fields are extracted and it is deallocated. Later on when the model is initialized a more extensive version of :code:`input.nml` is required in order to run the forecast.

The geometry configuration needs to contain a number of other things in addition to what is required to generate :code:`input.nml`. These are shown below:

.. code:: yaml

   geometry:
     fms initialization:
       namelist filename: Data/fv3files/fmsmpp.nml
       field table filename: Data/fv3files/field_table_gfdl
     akbk: Data/fv3files/akbk127.nc4
     field metadata override: Data/fieldmetadata/gfs-restart.yaml  # optional
     interpolation method: 'bump'  # optional, default value is 'barycent'
     write geom: true              # optional, default value is 'false'

Since the Geometry needs to call FV3, which in turn calls methods in the FMS library, it is necessary to initialize the FMS library. This is done only once and during the first call to Geometry. The initialize of FMS requires an :code:`input.nml` file like the initialize of FV3 needs.
The configuration :code:`fms initialization.namelist filename` is where this file is provided, an example of which is available in the repository.

The :code:`field table filename` provides a list of tracers that the model will use. Though this is not explicitly part of the Geometry this needs to be provided for FV3 and FMS to run. Inside these libraries the tracer variables are set as global variables and so have to be selected during the first call to the initialize steps, which occurs in the Geometry class rather than the Model class.

The :code:`akbk` variable provides a path to a file containing the coefficients which define the hybrid sigma-pressure vertical coordinate used in FV3. Files are provided with the repository containing :code:`ak` and :code:`bk` for some common choices of vertical resolution for GEOS and GFS.

The optional argument :code:`write geom` tells the code to write the longitude and latitude values to a netCDF file. This file can be ingested in the multi-grid Poisson solver or used to plot the grid points.

The argument :code:`interpolation method` determines the interpolation method to be used in the system. The options are 'bump' to use the interpolation method provided with BUMP/SABER or 'barycent' to use the unstructured interpolation method from OOPS.

The :code:`field metadata override` optionally provides a yaml file overwriting some defaults fields that the system will be able to allocate. The contents of these files are described in :ref:`fieldmetadata`. This process is undertaken in the Geometry because it involves things like the number of model levels when setting the metadata. Further, the constructors for States and Increments do not necessarily receive configuration so setting the FieldMetadata there would not be straightforward.


FV3-JEDI does not only support the global FV3 Geometry. It can also be used to generate nested and regional domains. The regional domain cannot be generated on the fly and has to be read from files. Users need to provide the :code:`geometry.fms initialization.field table filename` as follow:

.. code:: yaml

   geometry:
     fms initialization:
       namelist filename: Data/fv3files/fmsmpp.nml
       field table filename: Data/fv3files/field_table_lam_cmaq
     namelist filename: Data/fv3files/input_lam_cmaq.nml
     akbk: Data/fv3files/akbk64.nc4
     field metadata override: Data/fieldmetadata/gfs-aerosol.yaml


Nested grids can be constructed by providing an :code:`input.nml` that sets up a nested grid through the :code:`geometry.namelist filename` or by dynamically generating the :code:`input.nml` with the following additional options:

.. code:: yaml

   geometry:
     layout: [1,1]
     io_layout: [1,1]
     npx: 13
     npy: 13
     npz: 127
     ntiles: 6
     nested: true
     do_schmidt: true
     target_lat: 39.50
     target_lon: -98.35
     stretch_fac: 2.0

In the above :code:`nested` tells the system to setup a nested grid. Quantities :code:`do_schmidt`, :code:`target_lat`, :code:`target_lon` and :code:`stretch_fac` tell FV3 to do a stretching and where to center the higher resolution region.


.. _stateincfield:

State / Increment / Fields
--------------------------

The State and Increment classes in FV3-JEDI have a fair amount of overlap between them. The constructors are largely the same and they share a number of methods, such as read and write and computing of norms. In order to simplify the code FV3-JEDI implements a Fields class at the Fortran level, and both State and Increment inherit from this Fields base class.

The main data structure in the Fields class is an array of type Field (no 's'):

.. code:: fortran

   type :: fv3jedi_fields

     type(fv3jedi_field), allocatable :: fields(:)             ! Array of fields

   endtype fv3jedi_fields

The only specialization the State and Increment add to the Fields class are methods specific to each.

The user interaction with the State and Increment classes extends to choosing which fields will actually be allocated and to provide paths to files that must be read or written to. The configuration as it relates to IO is discussed below in the :ref:`io` section.

As an example for creating a State, the variables are chosen in the configuration as:

.. code:: yaml

   state variables: [u,v,T,DELP]

The strings in the list of variables are the names of the Fields as they are in the file that is going to be read. The below example shows how the list of fields are allocated in the Fields class:

.. code:: fortran

   ! Allocate fields structure
   ! -------------------------
   self%nf = vars%nvars()
   allocate(self%fields(self%nf))

   ! Loop through and allocate actual fields
   ! ---------------------------------------
   fc = 0
   do var = 1, vars%nvars()

     ! Uptick counter
     fc=fc+1;

     ! Set this fields meta data
     call create_field(self%fields(fc), geom%fields%get_field(trim(vars%variable(var))), geom%f_comm)

   enddo


And the content of :code:`create_field`:

.. code:: fortran

   subroutine create_field(self, fmd, comm)

     ! Copy metadata
     ! -------------
     self%long_name = fmd%long_name
     self%short_name = fmd%short_name
     self%units = fmd%units
     self%kind = fmd%kind
     self%tracer = fmd%tracer
     self%horizontal_stagger_location = fmd%horizontal_stagger_location
     self%npz = fmd%levels
     self%space = fmd%space
     self%io_name = fmd%io_name
     self%io_file = fmd%io_file
     self%interpolation_type = fmd%interpolation_type

   end subroutine create_field


In this example the loop traverses the four variables in the list of :code:`state variables`. The first thing that is done is to call the FieldMetadata Fortran API and collect the metadata based on the variable name string, which can be either :code:`longName`, :code:`shortName` or be overwritten by the user in :code:`io name` (see :ref:`fieldmetadata`).

**Field accessor functions**

The Fields and Field classes provide a number of accessor functions in order to obtain actual field data that can be used or manipulated.

Whenever using these accessor functions the string used to reference the field is the :code:`shortName` or :code:`longName` but not the :code:`io name`. This it to ensure there is a consistent and predictable way of getting the field regardless of the way a variable is named in whatever file is being read. For example, the file being read may have temperature stored as 't' while another file from a different model may have 'T'. In the yaml configuration file the user would choose either 't' or 'T' depending on which is in the file. In the source code this particular variable would only ever be accessed using 't', which is the :code:`shortName` for temperature. It could also be accessed with 'air_temperature', which is the :code:`longName`.

There are three accessor functions, :code:`has_field`, :code:`get_field` and :code:`put_field` and each function has several interfaces.

The function :code:`has_field` queries whether a field with a particular :code:`shortName` or :code:`longName` is present. An example of the interface is show below. This code snippet shows two possible interfaces to :code:`has_field`, where the array of fields is passed explicitly and where it is called from the class. Optionally the index in the array can be returned from the method.

.. code:: fortran

   ! Check whether state fields contain temperature
   have_temp = has_field(state%fields, 't', t_index)

   ! Check whether state fields contain temperature
   have_temp = state%has_field('t')

The subroutine :code:`get_field` can be used to return the field data with a particular :code:`shortName` or :code:`longName`, aborting if the field is not present. The method can return the field in three different formats, as a pointer to the array, a copy of the array or as a pointer to the entire field type. The below shows these three ways of using the method:

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

Input/Output (IO) in FV3-JEDI appears in its own directory, although it is not technically its own interface class. The methods read and write are part of State and Increment (Fields) but are also designed to be accessible from other parts of the code. The IO methods do not interact with the State and Increment objects, only the Fields base class.

There are three IO classes provided:
The :code:`CubeSphereHistory` is for interacting with cube sphere history files and restarts as output by the GEOS model.
The :code:`FV3Restart` is for interacting with restarts for the GFS/UFS model.
The :code:`LatLon` is for use with the latlon grid.


Which class to use is controlled by the configuration as follows:

.. code:: yaml

   # Read a GEOS file
   statefile:
     filetype: cube sphere history

   # Read a GFS file
   statefile:
     filetype: fms restart

   # Read a latlon file
   statefile:
     filetype: latlon


The below shows all the potential configuration for reading or writing a GEOS file.

.. code:: yaml

   statefile:
     datetime: 2020-12-15T00:00:00Z
     # Use GEOS IO
     filetype: cube sphere history
     provider: geos
     # Path where file is located
     datapath: Data/input/geos_c12/
     # Filenames for the different groups
     filenames: [geos.bkg.20201215_000000z.nc4, geos.bkg.crtmsrf.20201215_000000z.nc4]
     state variables: [ua,va,t,ps,q,qi,ql,qr,qs,o3ppmv,phis,vtype,stype,vfrac]
     tile is a dimension: [true, true]       # Optional, default is 'true'
     clobber existing files: [false, false]  # Optional, default is 'true'
     psinfile: false                         # Optional, default is 'false'

For GEOS the code writes all fields into a single file. During read the code will search for the field across the list of input files provided by the user.

GEOS can write cube sphere files in two ways, one is with a dimension of the variables being the tile number, where tile is synonymous with cube face. The other is to write with the 6 tiles concatenated to give dimensions of nx by 6*nx. FV3-JEDI assumes that the files include the tile dimension but it can also work with files with concatenated tiles, by setting :code:`tile is a dimension: [false]`. Note that if you provided a list of files in :code:`filenames` you will need to provide a list of booleans in :code:`tile is a dimension`.

The default behavior for all the IO is to clobber the file being written to, that is to say that any existing file is completely overwritten. By setting :code:`clobber existing files: [false]` this can be overridden so that and fields in the file that FV3-JEDI is not attempting to write remain intact. Note that if you provided a list of files in :code:`filenames` you will need to provide a list of booleans in :code:`clobber existing files`.



The code below shows all the potential configuration for reading a GFS restart file:

.. code:: yaml

   statefile:
     # Use GFS IO
     filetype: fms restart
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
     psinfile: false                         # Optional, default is 'false'
     skip coupler file: false                # Optional, default is 'false'
     prepend files with date: true           # Optional, default is 'true'

For GFS restarts certain fields are expected to be in certain files. The mapping between file and field name is hardcoded but can be overridden using :code:`IOFile: core` in the :ref:`fieldmetadata` override. The restarts include one text file :code:`filename_cplr: coupler.res` that contains metadata for the restart. Note that reading this coupler file can be disabled with :code:`skip coupler file: false` when it is not available and FV3-JEDI does not need the date and time information.
The keys :code:`filename_cold`, :code:`filename_orog` and :code:`filename_phys` are included for completeness but are used infrequently. The files referenced by these keys files do not contain fields the data assimilation system would normally interact with.

The fields more typically used are contained in the files referenced with:
:code:`filename_core`, which contains the main dynamics fields;
:code:`filename_trcr`, which contains the tracers;
:code:`filename_sfcd`, which contains the surface fields;
:code:`filename_sfcw`, which contains the surface winds.

GFS offers the ability to convert from pressure thickness to surface pressure automatically during the read. The behavior can be turned off and surface pressure read directly from the file using the flag :code:`psinfile: true`.

By default, when the output for GFS is written the files are prepended with the date so they might look like, for example, "20200101_00000.fv_core.res.tile1.nc". This can be turned off with :code:`prepend files with date: false`.


.. _model:

Model
-----

The Model class is where FV3-JEDI interacts with the actual forecast model. FV3-JEDI is capable of using the forecast models in-core with data assimilation applications as well as interacting with the models through files. The choice whether to interact with the model in-core depends on the application being run. For example, there can be much benefit to being in-core for a multiple outer loop 4DVar data assimilation system or when running H(x) calculations. However, there is no benefit to including the model for a 3DVar application and indeed the model is never instantiated in those kinds of applications.

Other than in the IO routines, the code in the other classes is identical regardless of the underlying FV3-based model, whether it be GEOS or GFS. In the Model class the code depends heavily on the underlying model. Although all the models use FV3, they have differing infrastructure around them.

Instantiation of Model objects is controlled through a factory. The only thing limiting which can be compiled is the presence of the model itself and making sure that there are not multiple versions of FV3 being linked to. Which models can be built with is described in the :ref:`buildwithmodel` section. At run time the model that is used is chosen through the configuration key :code:`name` as follows:

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

The configuration needs to include the time step for the model, a path to a directory where UFS can be run from and the variables, which contains a list of fields within UFS that need to be accessed. The :code:`ufs_run_directory` is a directory that contains restarts, boundary conditions, configurations and any other files that are needed in order to run UFS. This directory is created ahead of making any forecasts involving UFS. During the run the system will change directory to the the :code:`ufs_run_directory`.

.. code:: yaml

   model:
     name: UFS
     tstep: PT1H
     ufs_run_directory: Data/ModelDirs/ufs/stc
     model variables: [u,v,ua,va,t,delp,q,qi,ql,o3mr,phis,
                       qls,qcn,cfcn,frocean,frland,varflt,ustar,bstar,
                       zpbl,cm,ct,cq,kcbl,tsm,khl,khu]


.. _pseudo:

Pseudo model
~~~~~~~~~~~~

The pseudo model can be used with GFS or GEOS. All this model does is read states from disk that are valid at the end of the time step being 'propagated'. The configuration for pseudo model is very similar to that described in :ref:`io`. However, when referring to a file instead of using, for example, :code:`filename_core: 20200101_000000.fv_core.res.nc` the correct syntax would be :code:`filename_core: %yyyy%mm%dd.%hh%MM%ss.fv_core.res.nc`. The system will pick the correct date for the file based on the time of the model.

Note that OOPS provides a generic pseudo model, which is demonstrated in the :code:`hofx_nomodel` test. The advantage of using the FV3-JEDI pseudo model is that the yaml only requires a single entry with templated date and time; in the OOPS pseudo model a list of states to read is provided. Another advantage is that in data assimilation applications involving the model, such as 4DVar, the application propagates the model through the window after the analysis in order to compute 'o minus a'. This second propagation of the model is not useful with any pseudo model and can be turned off in the FV3-JEDI pseudo model by specifying :code:`run stage check: true` as shown in this example:

.. code:: yaml

   model:
     name: PSEUDO
     filetype: cube sphere history
     provider: geos
     datapath: Data/inputs/geos_c12
     filenames: [geos.bkg.%yyyy%mm%dd_%hh%MM%ssz.nc4, geos.bkg.crtmsrf.%yyyy%mm%dd_%hh%MM%ssz.nc4]
     run stage check: true
     tstep: PT1H
     model variables: [u,v,ua,va,t,delp,q,qi,ql,o3ppmv,phis,
                       qls,qcn,cfcn,frocean,frland,varflt,ustar,bstar,
                       zpbl,cm,ct,cq,kcbl,tsm,khl,khu,frlake,frseaice,vtype,
                       stype,vfrac,sheleg,ts,soilt,soilm,u10m,v10m]


.. _fv3core:

FV3 core model
~~~~~~~~~~~~~~

FV3-JEDI interfaces to the standalone version of the FV3 dynamical core. This is used primarily for testing purposes and particularly to test applications that need an evolving and rewindable model without the long run times and complexity of the model with full physics and complex infrastructure.
Below shows an example configuration for the standalone model:

.. code:: yaml

   model:
     name: FV3LM
     use internal namelist: true
     tstep: PT15M
     lm_do_dyn: 1     # Run the dynamical core component
     lm_do_trb: 0     # Run the turbulence core component
     lm_do_mst: 0     # Run the convection and microphysics components
     model variables: [u,v,T,DELP,sphum,ice_wat,liq_wat,o3mr,phis]


Similar to the Geometry, the Model needs an :code:`input.nml` and :code:`field_table` file to be provided so these are passed in through the model configuration. Setting :code:`use internal namelist: true` makes the Model use the same files as the geometry. The user needs to set a value for the different :code:`lm_do_` settings, and it is also necessary to provide the time step and list of variables that the model will provide.


.. _linearmodel:

TLM
---

.. _linearnonlinearvarchanges:

FV3-JEDI ships with a linearized version of the FV3 dynamical core named FV3-JEDI-LINEARMODEL. Note that the linear model comes in a separate repository though it builds only as part of FV3-JEDI. The linear model is a global model only and does not currently support regional and nested domains.

An example of the configuration is shown below.

.. code:: yaml

   linear model:
     name: FV3JEDITLM   # Name of the LinearModel in the factory
     # FV3 required files
     namelist filename: Data/fv3files/input_gfs_c12.nml
     linear model namelist filename: Data/fv3files/inputpert_4dvar.nml
     tstep: PT15M     # Time step
     lm_do_dyn: 1     # Run the dynamical core component
     lm_do_trb: 0     # Run the turbulence core component
     lm_do_mst: 0     # Run the convection and microphysics components
     # Variables in the linear model
     tlm variables: [u,v,T,DELP,sphum,ice_wat,liq_wat,o3mr]
     trajectory:
       model variables: [u,v,T,DELP,sphum,ice_wat,liq_wat,o3mr]


The linear model requires the same :code:`input.nml` file that the nonlinear version of FV3 needs. In addition is needs an :code:`inputpert.nml` file, which is provided through the :code:`linear model namelist filename` keyword. The different components of the linearized model can be turned on and off with the :code:`lm_do_` keywords. The three components are the dynamical core, the turbulence scheme and the linearized moist physics.

The forecast model outputs a lot of variables and not all of them are required in the trajectory of the linear model. The :code:`trajectory.model variables` contains the list of variables output from the model that are passed to the linear model for it to populate its trajectory.

.. _obsloc:

ObsLocalization
---------------

The different ObsLocalization methods are controlled through a factory.

For now there is one in the fv3-jedi repository: the vertical Brasnett 99 observation space localization for snow DA.


.. _varchanges:

LinearVariableChange and nonlinear VariableChange
-------------------------------------------------

FV3-JEDI has a number of linear and nonlinear variable changes which are used to transform between increments or states with different sets of variables. These variable changes are used to go between different components of the system where different variables might be required.

Variable changes are constructed using factories, so are chosen through the configuration. Some variable changes require additional configuration and some require nothing additional. The details of each configuration is outlined below.

Many of the variable changes take on the same general format structure, outlined in the following steps.

1. The first step is to copy all the variables that are present in both input and output states and increments.

  .. code:: fortran

     ! Array of variables that cannot be obtained from input
     character(len=field_clen), allocatable :: fields_to_do(:)

     ! Copy fields that are the same in both
     call copy_subset(xin%fields, xout%fields, fields_to_do)

The :code:`copy_subset` routine identifies the variables in both and copies the data from input to output. Optionally it returns a list of variables that are in the output that are not in the input, i.e., the list of variables that need to be derived from the inputs.

2. The second step is to prepare all the potential output variables that might be needed. The below provides an example of how temperature could be prepared from various inputs:

  .. code:: fortran

     ! Temperature
     logical :: have_temp
     real(kind=kind_real), pointer     ::    pt(:,:,:)     ! Potential temperature
     real(kind=kind_real), allocatable ::   pkz(:,:,:)     ! Pressure ^ kappa
     real(kind=kind_real), allocatable ::     t(:,:,:)     ! Temperature

     have_temp = .false.
     if (xana%has_field('pt')) then
       allocate(t(geom%isc:geom%iec,geom%jsc:geom%jec,1:geom%npz))
       call xana%get_field('pt', pt)
       if (xana%has_field('pkz')) then
         call xana%get_field('pkz', pkz)
         have_temp = .true.
       elseif (have_pres) then
         allocate( pkz(geom%isc:geom%iec,geom%jsc:geom%jec,1:geom%npz))
         call ps_to_pkz(geom, ps, pkz)
         have_temp = .true.
       endif
       if (have_temp) call pt_to_t(geom, pkz, pt, t)
     endif

Note that variables that are not necessarily needed to provide another variable are typically pointers. Variables that are obtained one of multiple ways are typically allocatable arrays. The boolean variable :code:`have_temp` determines that a variable, in this case temperature, is now available.

3. The third step is to loop through the output variables that could not be copied and attempt to get them from the prepared variables.

  .. code:: fortran

     ! Loop over the fields not found in the input state and work through cases
     ! ------------------------------------------------------------------------
     do f = 1, size(fields_to_do)

       call xctl%get_field(trim(fields_to_do(f)),  field_ptr)

       select case (trim(fields_to_do(f)))

       ! Temperature case
       case ("t")

         if (.not. have_temp) call field_fail(fields_to_do(f))
         field_ptr = t

       end select

     end do

If the variable has not been prepared the variable change will fail, otherwise the :code:`field_ptr = t` will overwrite the field data with the prepared variable.


.. _basevarchange:

Base
~~~~
All the different Variable Change expand the VariableChangeBase class.
The base class holds the :code:`variable change name` key and initiates the Variable Change factory.


.. _a2m:

Analysis2Model
~~~~~~~~~~~~~~

The analysis to model variable change is used to transform between the background variables (the variables that will be analyzed) and the variables used to drive the model.

.. code:: yaml

   variable change:
     variable change name: Analysis2Model

The linear analysis to model variable change is used to transform between the analysis increment and the linear model. The linear version does not require any configuration.


.. _cstart:

ColdStartWinds
~~~~~~~~~~~~~~

The cold start winds variable change is specific to the GFS model. GFS cold starts are obtained when re-gridding from different grids or resolutions. In this variable transform the cold start winds are converted to the D-Grid winds needed to drive the FV3 model. There is no configuration for this variable change, except to choose to use it through the factory. There is only a nonlinear version of the variable change.

.. code:: yaml

   variable change:
     variable change name: ColdStartWinds


.. _c2a:

Control2Analysis
~~~~~~~~~~~~~~~~

The control to analysis variable change converts from the control variables (here the variables used in the B matrix) to the analysis variables. In the variational assimilation algorithm only the linear version of this variable change is needed but a nonlinear version is provided to the purpose of training the covariance model.

For the NWP applications the control variables are typically stream function and velocity potential while the analysis variables are winds. To transform between stream function and wind requires a straightforward derivative operator but the inverse transforms require the use of a Poisson solver to solve the inverse Laplacian after transforming from winds to vorticity and divergence.
A Finite Element Mesh Poisson Solver (FEMPS) is provided as part of FV3-BUNDLE and is linked to in the variable transform. When converting without using FEMPS no configuration is required. When using FEMPS the configuration options are show below:

.. code:: yaml

   variable change:
     variable change name: Control2Analysis
     femps_iterations: 50      # Number of iterations of the Poisson solver
     femps_ngrids: 2           # Number of grids in the multigrid heirachy
     femps_levelprocs: -1      # Number of levels per processor (-1 to automatically distribute)
     femps_path2fv3gridfiles: Data/femps   # Path containing geometry files for the multigrid


.. _geosr2b:

GEOSRstToBkg
~~~~~~~~~~~~

The GEOSRstToBkg variable change is specific to the GEOS model and is used to convert from GEOS restart file like variables to so-called background like variables. Restart variables include D-Grid winds, potential temperature and pressure the to the kappa while background variables are A-Grid winds, temperature and surface pressure.

Currently this variable change works slightly differently to the others in that you need to specify, through the configuration, which variables need to be transformed. The choices are made with the key :code:`do_` as show below:

.. code:: yaml

   variable change:
     variable change name: GeosRst2Bkg
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


.. _vertremap:

VertRemap
~~~~~~~~~

The vertical remapping variable change is used primarily in conjunction with the :ref:`cstart` variable change in order to convert from cold start variables to warm start variables. It can also be used to do a straightforward remapping when necessary, for example when the surface pressure has changed.

The configuration for the transform is quite extensive but most is related to initializing the FV3 data structure and is similar to what is used in the :ref:`geometry`. Since the methods make calls into FV3, it is necessary to initialize an FV3 structure to pass in. In addition, the user can specify whether the inputs are cold starts, which have specific variable names. This would be set to false in the case where the variable change is not being used for cold starts and is being used as part of some other applications. The final thing that needs to be specified is the source of inputs, which is a string controlling how the transform behaves internally in FV3; this is unlikely to be changed from the default values.

.. code:: yaml

   # Name of variable change in the factory
   variable change:
     variable change name: VertRemap
     # Is the variable change being used in the context of remapping cold starts?
     input is cold starts: true
     # Configuration needed to initialize FV3
     npx: 13
     npy: 13
     npz: 127
     nwat: 6
     hydrostatic: false
     source of inputs: FV3GFS GAUSSIAN NETCDF FILE # Type of inputs to the variable change
