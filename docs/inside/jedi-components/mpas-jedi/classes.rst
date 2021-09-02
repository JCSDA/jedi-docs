  .. _top-mpas-jedi-classes:

.. _classes-mpas:

Classes and Configuration
=========================

This page describes the classes that are implemented in MPAS-JEDI. It explains in broad terms what
they are responsible for, how they are implemented, and the configuration options that are
available for controlling their behavior.

The individual classes are the model-dependent building blocks of the model interface for the
generic applications that are implemented in OOPS. Each class is fully determined by information
either in the top-level application-specific YAML file or in one of the MPAS-Model configuration
files, such as :code:`namelist.atmosphere` and :code:`streams.atmosphere`.

Here we provide context-free configuration examples for individual classes. In general, YAML files
are hierarchical. The MPAS-JEDI YAML keys may be indented under some combination of parent YAML keys
that are not shown here. Users should refer to examples of full application YAML files in the
MPAS-JEDI ctests described in the :doc:`Test files </inside/jedi-components/mpas-jedi/data>` or within the tutorials.

.. _geometry-mpas:

Geometry
--------

The Geometry class is responsible for generating descriptors of the MPAS mesh and for associating
an MPI communicator passed down from the generic application with a particular Geometry object.
The MPAS-Model subroutine :code:`mpas_init` is used to initialize  pointers two MPAS-Model derived
types, :code:`domain_type` and :code:`core_type`. The :code:`domain_type` and its underlying components facilitate the operations described by most other classes in MPAS-JEDI.

Inheritance from MPAS-Model
"""""""""""""""""""""""""""

Every MPAS-JEDI application requires a Geometry object and must adhere to the requirements of :code:`mpas_init`.  That subroutine requires there to be several files present in the run directory. They
are as follows:

* :code:`namelist.atmosphere`

* :code:`streams.atmosphere`

* :code:`stream_list.atmosphere.output`

* :code:`GENPARM.TBL`

* :code:`LANDUSE.TBL`

* :code:`OZONE_DAT.TBL`

* :code:`OZONE_LAT.TBL`

* :code:`OZONE_PLEV.TBL`

* :code:`SOILPARM.TBL`

* :code:`VEGPARM.TBL`

* :code:`CAM_ABS_DATA.DBL`

* :code:`CAM_AEROPT_DATA.DBL`

* :code:`RRTMG_LW_DATA.DBL`

* :code:`RRTMG_SW_DATA.DBL`

* :code:`config_block_decomp_file_prefix.npe`

Those files are described in more detail in the MPAS-Atmosphere documentation. Here we
only provide information relating their usage in the MPAS-JEDI Geometry class.

For the time being, the names :code:`namelist.atmosphere` and :code:`streams.atmosphere` are
hard-coded in MPAS-Atmosphere. The names of those files cannot be configured at run-time. However,
future implementation of dual-resolution data assimilation will necessitate that those names are
specified independently for each of the MPAS-Model meshes. Stay tuned for more details.

:code:`config_block_decomp_file_prefix.npe` is the graph partition file for the MPAS-Model mesh. The
:code:`npe` suffix refers to the number of processors over which the MPAS-Model mesh is decomposed.
:code:`config_block_decomp_file_prefix` is set in :code:`namelist.atmosphere` under
:code:`&decomposition`. So far MPAS-JEDI applications have followed the naming conventions for
the MPAS-Atmosphere uniform meshes, "x1.init.nCells.graph.info.part", where nCells is the number of
horizontal columns (e.g., 40962 for the 120 km mesh).

The number of processors used for the top-level generic MPAS-JEDI application is equal to the
number of ranks in the global MPI communicator. The number of processors available to a particular
Geometry object is determined by how the MPAS-JEDI application splits the global communicator. Only
a few applications split the global communicator (e.g., EDA, EnsHofX, 4DEnVar). An EDA application
with 4 simultaneous analyses will divide the global communicator by 4, for example, while a 4DEnVar
application with 3 assimilation sub-windows will divide the global communicator by 3.  The Geometry
communicator is passed to :code:`mpas_init`, which instantiates the MPAS-Model mesh. Up to this
point, MPAS-JEDI has only been tested in situations where the MPAS-Model mesh uses all available
ranks in the Geometry communicator. The user must ensure that the number of processors available to
the potentially split communicator corresponds to one of the graph partition files available for the
MPAS-Model mesh used in that application. There is no configuration element in the YAML file to
select the number of processors utilized.

Presently, it is only possible to build MPAS-JEDI for use with double floating point precision.
Therefore, static lookup tables such as :code:`RRTMG_LW_DATA` must be provided in double precision.

Configuration
"""""""""""""

There are two run-time options available to users in MPAS-JEDI :code:`geometry` sections of the YAML
file, which are as follows:

.. code:: yaml

 geometry:
   gridfname: ./restart.$Y-$M-$D_$h.$m.$s.nc
   deallocate non-da fields: false

gridfname
^^^^^^^^^

The :code:`gridfname` option is currently an unused placeholder. It is meant to allow the user to
specify which file is used in :code:`mpas_init` to initialize the MPAS-Atmosphere mesh fields that
are stored in the Geometry :code:`domain_type`. For the time being that run-time functionality is
achieved by specifying the :code:`filename_template` entry in :code:`streams.atmosphere` under
:code:`immutable_stream name="restart"`. For example,

.. code:: xml

  <immutable_stream name="restart"
                    type="input;output"
                    filename_template="restart.$Y-$M-$D_$h.$m.$s.nc"
                    input_interval="initial_only"
                    clobber_mode="overwrite" />

The prefix to :code:`filename_template`, which is given as "restart." in this example, can be
whatever string the user wishes as long as the actual file prefix matches. If the
:code:`filename_template` contains date substitution strings, then the actual file formatted date
must correspond to the :code:`config_start_time` option in :code:`namelist.atmosphere`.  MPAS-JEDI
utilizes the restart stream for initializing model states.  Therefore, :code:`config_do_restart`
should be set to :code:`true` in :code:`namelist.atmosphere` during all MPAS-JEDI applications.
Also, :code:`config_do_DAcycling` should be set to :code:`true` in order to force the coupled
MPAS-Model prognostic variables to be re-initialized from the MPAS-JEDI analysis variables
(**TODO**: add link to add increment variable transform).

We have only documented the usage of "restart" IO streams for MPAS-JEDI state initialization,
because that is the method used in all ctests and is the easiest for user introduction. There is
also a two-stream state initialization method implemented in the mpas-bundle version of MPAS-Model
that saves significant disk space in cycling workflows. The two-stream method utilizes a single
"static" IO stream that handles the time-invariant fields and a second set of "mpasin" and "mpasout"
IO streams that contains the time-varying fields. Consult with the MPAS-JEDI developers for more
information if you are facing disk space bottlenecks in your experiments due to large restart file
sizes.


deallocate non-da fields
^^^^^^^^^^^^^^^^^^^^^^^^

The :code:`deallocate non-da fields` option is used to reduce physical memory usage in 3D JEDI
applications that do not require time-integration of the MPAS-Model, i.e., applications that do not
utilize the :code:`Model` class. The fields that are not used in those time-invariant applications
are deallocated from the :code:`domain_type` that was created in :code:`mpas_init`. Refer to the
source code for detailed information about which fields are deallocated.

.. _stateinc:

State / Increment
-----------------

The State and Increment classes in MPAS-JEDI have a fair amount of overlap between them. The
constructors are largely the same and they share a number of methods, such as read, write, and
mathematical operations. In order to simplify the code, MPAS-JEDI contains shared subroutines for
both of those c++ classes in a fortran class called :code:`mpas_field` within :code:`mpas_field_utils_mod`.

Inheritance from MPAS-Model
"""""""""""""""""""""""""""

MPAS-JEDI leverages the MPAS-Model :code:`mpas_pool_type` to manage groupings of model fields.  That
paradigm eases iterations over model fields. When considering mathematical operations on fields with
different dimensions (i.e., 3D vs. 2D), special cases are handled using the
:code:`mpas_pool_iterator_type%nDims` attribute. This approach makes it easy to add new variables
to State and Increment objects at run-time without much additional code. New code is needed
when converting between MPAS-Model state variables, MPAS-JEDI analysis variables, and UFO GeoVaLs
variables.


State
"""""

State objects are defined uniquely by three keys in the yaml file:

.. code:: yaml

 state variables: [temperature, spechum, uReconstructZonal, uReconstructMeridional, surface_pressure,
                   theta, rho, u, index_qv, pressure, landmask, xice, snowc, skintemp, ivgtyp, isltyp,
                   snowh, vegfra, u10, v10, lai, smois, tslb, pressure_p]
 filename: mpasout.2018-04-15_00.00.00.nc
 date: 2018-04-15T00:00:00Z


state variables
^^^^^^^^^^^^^^^

The :code:`state variables` key determine which MPAS-Model fields (e.g., :code:`field1DReal`,
:code:`field2DReal`, etc...) will comprise the State object's stored data.  This key, which is used
during the constructor of the State object, affects all down-stream operations with this State
object.  All fields that are needed by the applicable portion of a generic application must be
listed here.

Although the user specifies which :code:`state variables` are created and operated on within
an mpas-jedi application using the yaml file, the fields for which IO is conducted are specified in
:code:`stream_list.atmosphere.output`.  The list of variables there does not need to exactly match
the list in the yaml. However, the user should be aware that :code:`State::read` and
:code:`State::write` will attempt to read and write all fields listed in
:code:`stream_list.atmosphere.output`.  There are three MPAS-JEDI fields that are derived directly
from MPAS-Model fields within the read method, :code:`spechum`, :code:`pressure`, and
:code:`temperature`.  None of those need to be listed within :code:`stream_list.atmosphere.output`,
but only a warning and not an error will result if they are included.

filename
^^^^^^^^

The :code:`filename` key determines which file is associated with IO during calls to the read and
write methods from within a generic application. The filename may or may not contain any of the
date-time placeholders recognized by MPAS-Model (i.e., :code:`$Y`, :code:`$M`, :code:`$D`,
:code:`$h`, :code:`$m`, :code:`$s`).  For example, :code:`'$Y-$M-$D_$h:$m:$s'`.  All of the
date-time placeholders will be replaced with quantities associated with the valid date for this
State.

date
^^^^

The :code:`date` key has two purposes.  During the read method, this ISO8601-formatted date-time is
used to tell the generic application the valid date for this State. Secondly, it may be used to
subsitute the actual date components into the :code:`filename` as described above, but only during
the :code:`State::read` method. The :code:`State::write` method is not subject to this YAML key,
because the generic application determines the valid date of the output State.


Increment
"""""""""

The Increment class differs from the State class in that it is primarily used to conduct
mathematical operations. Often an Increment object is constructed by taking the difference between
two State objects or by copying a subset of fields from a single State. That is why only the fields
for which such a difference is calculated need be specified in the YAML. For example, an Increment
object with the MPAS-JEDI standard analysis variables is defined with

.. code:: yaml

 analysis variables: [temperature, spechum, uReconstructZonal, uReconstructMeridional, surface_pressure]

The correct specification of :code:`state variables` and :code:`analysis variables` is
application-dependent.  Hydrometeor fields are added to State and Increment objects with the
following strings: :code:`index_qc`, :code:`index_qi`, :code:`index_qr`, :code:`index_qs`,
:code:`index_qg`, :code:`index_qh` for cloud, ice, rain, snow, graupel, and hail, respectively.
However, hydrometeor fields are only updated in an MPAS-JEDI variational application when assimilating observations that are sensitive to them. Users should refer to existing ctests and tutorials as
examples.

Linear and Nonlinear Variable Changes
-------------------------------------

MPAS-JEDI has a single linear variable change, :code:`control2analysis`, which is used for the multivariate background error covariance. Also, there are the Fortran subroutines for nonlinear and linear variable transforms though they are not the form of separate C++ classes.


.. _control2analysis:

Control2Analysis
""""""""""""""""

This linear variable change converts the control variables (which is used in the B matrix) to the analysis variables. For various variational applications of MPAS-JEDI, we have chosen the following set of analysis variables.

.. code:: yaml

     analysis variables:
     - uReconstructZonal       # zonal wind at cell center [ m / s ]
     - uReconstructMeridional  # meridional wind at cell center [ m / s ]
     - temperature             # temperature [ K ]
     - spechum                 # specific humidity [ kg / kg ]
     - index_qc                # mixing ratio for cloud water [ kg / kg ]
     - index_qi                # mixing ratio for cloud ice [ kg / kg ]
     - index_qr                # mixing ratio for rain water [ kg / kg ]
     - index_qs                # mixing ratio for snow [ kg / kg ]
     - index_qg                # mixing ratio for graupel [ kg / kg ]

The latter five hydrometeor variables are optional. These variables are chosen because fewer variable changes are required for implementing (1) the multivariate background error covariance and (2) the simulation of observation equivalent quantities from analysis variables.

We have chosen :code:`stream_function` and :code:`velocity_potential` for the momentum control variables in the B matrix. Currently the wind transform from stream function and velocity potential to zonal and meridional winds is the only variable change included in :code:`control2analysis`. Two formulas are directly implemented on the MPAS's native grids and by default :code:`wind_cvt_method: 1` is used. Note that :code:`wind_cvt_method: 2` only works for serial computations on a single processor.

.. code:: yaml

   variable change: Control2Analysis
   wind_cvt_method: 1
   input variables: [stream_function, velocity_potential, temperature, spechum, surface_pressure]        # control variables
   output variables: [uReconstructZonal, uReconstructMeridional, temperature, spechum, surface_pressure] # analysis variables

A YAML example for this linear variable change can be found in CTest :code:`mpasjedi/test/testinput/linvarcha.yaml` or :code:`mpasjedi/test/covariance/yamls/3dvar.yaml`

Analysis to Model Variable Change
"""""""""""""""""""""""""""""""""
After getting the analysis increment for :code:`[uReconstructZonal, uReconstructMeridional, temperature, spechum, surface_pressure]` from the minimization of cost function, the full field analysis state is calculated in :code:`+=` (add increment) method of :code:`State` class. In this method, the MPAS model variables :code:`[index_qv, pressure, theta, rho, u]` are also updated. The full-field pressure :code:`pressure` is obtained by integrating the hydrostatic equation from the surface. The dry potential temperature :code:`theta` is then calculated from :code:`temperature` and :code:`pressure`, and dry air density :code:`rho` is derived using the equation of state. The edge normal wind :code:`u` is incrementally updated by using :code:`subroutine uv_cell_to_edges`, originally from MPAS DART.


Variable Change from Reading MPAS file to Analysis Variable
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
As described in “state variables”, :code:`State::read` includes several variable changes. First, :code:`pressure_base` and :code:`pressure_p` (pressure perturbation) are read separately, and then added to the full fields :code:`pressure`. The water vapor mixing ratio :code:`index_qv` is read from the file, and converted to the specific humidity :code:`spechum`. The dry potential temperature :code:`theta` is read from the file, and converted to :code:`temperature`.
Because the reconstructed winds at the cell center, :code:`uReconstructZonal` and :code:`uReconstructMeridional`, are usually available in the MPAS file, they are directly read from the file.


Nonlinear and Linear Variable Change from Analysis to GeoVaLs Variable
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
The model interface interacts with UFO through :code:`GeoVaLs` in :code:`GetValues` and :code:`LinearGeValues` classes. Here, :code:`GeoVaLs` represents the column at the observation locations for required variables. If the variables required by observation operator is different from the variables in MPAS-JEDI, the nonlinear or linear variable changes are executed. There are the fortran subroutines :code:`convert_mpas_field2ufo`, :code:`convert_mpas_field2ufoTL`, and :code:`convert_mpas_field2ufoAD`, which are included in :code:`GetValues::fillGeoVaLs`, :code:`LinearGetValues::fillGeoVaLsTL`, and :code:`LinearGetValues::fillGeoVaLsAD`.

.. _getvalues-mpas:

GetValues and LinearGetValues
-----------------------------

The GetValues and LinearGetValues classes are responsible for interpolating the model-space fields
to the observation variables and locations requested by the observation operators. For MPAS-JEDI, the
position of the fields that come into the methods are defined by the MPAS-Model unstructured Voronoi mesh.
They are horizontally interpolated to the observation locations requested by the observation operators. If necessary
for the operator interface, variable changes are also performed.

There are two methods that can be used for the horizontal interpolation, one from the BUMP library and another in
the OOPS repository that is referred to as "unstructured interpolation." The chosen interpolation method can
be configured from the YAML via the :code:`Geometry` class. The default method is unstructured interpolation since
it appears faster and requires less memory in many situations.
(**TO DO !!!**: the wording here may need to be modified as we continue implementing and testing unstructured interpolation.)

Somewhat different interpolation methods are used depending upon the field type.
Scalar real fields are interpolated using barycentric weighted interpolation, and integer fields use a form of
nearest neighbor interpolation.

In MPAS-JEDI, we have implemented two ctests for testing the OOPS interfaces of the GetValues and LinearGetValues
classes. :code:`getvalues.yaml` and :code:`lineargetvalues.yaml` are the input files for those tests.
