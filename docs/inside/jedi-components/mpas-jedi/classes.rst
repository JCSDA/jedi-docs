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
The MPAS-Model subroutine :code:`mpas_init` is used to initialize pointers to two MPAS-Model derived
types, :code:`domain_type` and :code:`core_type`. The :code:`domain_type` and its underlying components facilitate the operations described by most other classes in MPAS-JEDI.

Inheritance from MPAS-Model
"""""""""""""""""""""""""""

Every MPAS-JEDI application requires a :code:`Geometry` object and must adhere to the requirements of :code:`mpas_init`.  That subroutine requires there to be several files present in the run directory. They are as follows:

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
only provide information relating to their usage in the MPAS-JEDI :code:`Geometry` class.

While the names :code:`namelist.atmosphere` and :code:`streams.atmosphere` are
hard-coded in MPAS-Atmosphere, the names of those files can be configured at run-time in MPAS-JEDI, as
explained in the :ref:`nml-stream-file-mpas-geom` configuration element descriptions.  This change is
needed because dual-mesh data assimilation requires that those names are specified independently for each
of the MPAS-Model meshes.

:code:`config_block_decomp_file_prefix.npe` is the graph partition file for the MPAS-Model mesh. The
:code:`npe` suffix refers to the number of processors over which the MPAS-Model mesh is decomposed.
:code:`config_block_decomp_file_prefix` is set in :code:`namelist.atmosphere` under
:code:`&decomposition`. So far MPAS-JEDI applications have followed the naming conventions for
the MPAS-Atmosphere uniform meshes, "x1.init.nCells.graph.info.part", where nCells is the number of
horizontal columns (e.g., 40962 for the 120 km mesh).

The number of processors used for the top-level generic MPAS-JEDI application is equal to the
number of ranks in the global MPI communicator. The number of processors available to a particular
:code:`Geometry` object is determined by how the MPAS-JEDI application splits the global communicator.
Only a few applications split the global communicator (e.g., EDA, EnsHofX, 4DEnVar). An EDA application
with 4 simultaneous analyses will divide the global communicator by 4, for example, while a 4DEnVar
application with 3 assimilation sub-windows will divide the global communicator by 3.  The
:code:`Geometry` object's communicator is passed to :code:`mpas_init`, which instantiates the
MPAS-Model mesh. Up to this point, MPAS-JEDI has only been tested in situations where the MPAS-Model
mesh uses all available ranks in a :code:`Geometry` object's communicator. The user must ensure that the 
number of processors available to the potentially split communicator corresponds to one of the graph
partition files available for the MPAS-Model mesh used in that application. There is no configuration
element in the YAML file to select the number of processors utilized.

Presently, it is only possible to build MPAS-JEDI for use with double floating point precision.
Therefore, static lookup tables such as :code:`RRTMG_LW_DATA` must be provided in double precision.

Configuration
"""""""""""""

There are four run-time options available to users in MPAS-JEDI :code:`geometry` sections of the YAML
file. An example for a 240km mesh is given below, although there is no requirement for the names of
the :code:`nml_file` and :code:`streams_file` to follow any particular format, such as including a
date or a mesh-spacing.

.. code:: yaml

 geometry:
   nml_file: "./namelist.atmosphere_2018041500_240km"
   streams_file: "./streams.atmosphere_240km"
   deallocate non-da fields: true
   interpolation type: unstructured

.. _nml-stream-file-mpas-geom:

nml_file and streams_file
^^^^^^^^^^^^^^^^^^^^^^^^^

The :code:`nml_file` and :code:`streams_file` specify the `namelist.atmosphere` and
`streams.atmosphere` files, respectively, which are used to initialize the MPAS-A mesh and
additional model fields that are used to initialize MPAS-A physical quantities.  Some of those physical
quantities may not be be needed for MPAS-JEDI applications, which will be discussed later in the context
of the :code:`deallocate non-da fields` option.  For most MPAS-JEDI applications, it suffices to use the
default namelist and streams file names, again `namelist.atmosphere` and `streams.atmosphere`,
respectively.  One specific case where the default names cannot be used is a dual-mesh ``Variational`` application.

For ``Variational`` applications, the :code:`geometry` configuration is provied in two places, under
:code:`cost function` and within each of the :code:`iterations` vector members under
:code:`variational`. The :code:`cost function.geometry` configuration specifies the fine mesh used
for background and analysis states, and the :code:`variational.iterations[:].geometry`
configurations specify the coarse meshes for the inner loop increments and ensemble input states
(i.e., for EnVar). With that freedom of configurability, each outer loop iteration of the
variational minimization can potentially use a different mesh in the inner loop. Note that for
EnVar applications, using unique coarse meshes in each outer iteration requires users to provide
ensemble states on those multiple meshes. For a single-mesh ``Variational`` application, the
:code:`cost function.geometry` and :code:`variational.iterations[:].geometry` are identical. As an
example, for a dual-mesh application with the above 240-km mesh being used for the outer loop's fine
mesh, the first inner loop might use a 480-km coarse mesh, in which case
:code:`variational.iterations[0].geometry` would look like

.. code:: yaml

 variational:
   iterations:
   - geometry:
       nml_file: "./namelist.atmosphere_2018041500_480km"
       streams_file: "./streams.atmosphere_480km"
       deallocate non-da fields: true
       interpolation type: unstructured

In this particular example, the pimary difference between ``streams.atmosphere_240km`` and
``streams.atmosphere_480km`` is the MPAS state file that is used to intialize their respective model
meshes. The 240km file would include a section that looks like

.. code:: xml

  <immutable_stream name="restart"
                    type="input;output"
                    filename_template="restart.240km.$Y-$M-$D_$h.$m.$s.nc"
                    input_interval="initial_only"
                    clobber_mode="overwrite" />

where  the prefix to :code:`filename_template` is given as `restart.240km.`. The
:code:`filename_template` also contains date substitution strings, so that the date in the filename
must correspond to the :code:`config_start_time` option in :code:`namelist.atmosphere_2018041500_240km`.
The respective 480km :code:`streams_file` would have an entry that looks like

.. code:: xml

  <immutable_stream name="restart"
                    type="input;output"
                    filename_template="restart.480km.$Y-$M-$D_$h.$m.$s.nc"
                    input_interval="initial_only"
                    clobber_mode="overwrite" />

using a :code:`filename_template` prefix of `restart.480km.`, or whatever prefix the user prefers.
There are also differences in the 240-km and 480-km :code:`nml_file`'s, which are primarily related
to settings that are mesh-specific.  For example, :code:`config_block_decomp_file_prefix`, which is
desribed earlier in this section of the documentation.

Although the above discussion shows how to handle restart files in an MPAS-JEDI application, using
full restart files, uses significant disk space in cycling workflows.  For such
purposes, there is another model initialization approach we call "2-stream" that is available in both
MPAS-JEDI and MPAS-Model, as distributed with mpas-bundle.  For purposes of definition, it is important
to understand that MPAS-Model uses the term "stream" to define the flow of data in and out of the model
from and to files stored on the hard disk. Each stream can be defined as an input stream, an output
stream, or both an input and an output stream. The "restart" stream is conveniently defined as both input
and output, meaning that all of the same fields are read and written through that stream.

The 2-stream approach defines two unique input streams, and saves significant disk space in cycling
workflows by splitting out time-invariant fields into an input stream called "static" and keeping only
time-varying fields in the input stream simply named "input".  The "static" input stream includes the mesh, some of surface input variables (:code:`landmask`, :code:`shdmin`, :code:`albedo12m`, etc.) and
parameters for gravity wave drag over orography. Because those fields ("static") are time-invariant,
they are stored in a single file that does not require multiple copies across workflow cycles. The
"input" input stream reads all of the fields needed for a cold-start forecast. The "input"
input stream is efficient for replacing the "restart" stream as the sole input stream in cycling
workflows, because the "restart" stream includes physical tendency and other fields needed for a perfect 
restart to within machine/IO precision that are inconsequential in cycling. In order to use the 2-stream
input, one needs to modify the :code:`streams_file` in both the forecast step and in all MPAS-JEDI
applications (e.g., ``HofX``, ``Variational``) as follows, using the quasi-uniform 120km mesh as an
example,

.. code:: xml

    <immutable_stream name="static"
                      type="input"
                      filename_template="static.40962.nc"
                      io_type="pnetcdf,cdf5"
                      input_interval="initial_only" />
    <immutable_stream name="input"
                      type="input"
                      filename_template="init.40962.$Y-$M-$D_$h.$m.$s.nc"
                      io_type="pnetcdf,cdf5"
                      input_interval="initial_only" />

The "input" input stream is used to read the forecast initial state in MPAS-Model (above) and the
fields needed to initialize the MPAS-JEDI :code:`Geometry` in all MPAS-JEDI applications.
Hoever, it is important to note that the fields intialized in the :code:`Geometry` object are not the
same as the background :code:`State` object that feeds ``Variational`` and ``HofX`` applications.
The fields in the :code:`Geometry` object are only placeholders or templates for the fields that will
eventually be read in the :code:`State::read` method.  The :code:`State::read` and :code:`State::write`
(used for analysis output) methods use the "output" output stream, whose fields are entirely described
at run-time. This is achieved by adding an input/output stream to the :code:`streams_file` that includes 
a :code:`file name` element giving a hard-coded name for a file that lists all fields to be read/written , i.e. `stream_list.atmosphere.output` in the example below

.. code:: xml

    <stream name="output"
            type="input;output"
            io_type="pnetcdf,cdf5"
            filename_template="history.$Y-$M-$D_$h.$m.$s.nc"
            clobber_mode="overwrite"
            input_interval="initial_only"
            output_interval="none" >
            <file name="stream_list.atmosphere.output"/>
    </stream>


Although the above example "output" stream gives a :code:`filename_template` with the "history." prefix, 
the actual filenames for input and output is generated within :code:`State::read` and
:code:`State::write` methods respectively. Those methods use the :code:`filename` specified in the YAML
for each applicable :code:`State` object.
 
In addition to the fields that are used for cold-start forecasts, there are other fields that are needed
exclusively in the :code:`State` objects of MPAS-JEDI applications, including analysis variables and
fixed fields needed for CRTM or other observation operators.  Because those extra fields can undergo IO
through the :code:`State` class, completely bypassing the hard-coded streams in MPAS-A's
:code:`Registry.xml`, it is useful to codify them in a unique output stream so that forecasts preceeding
an MPAS-JEDI application will write all the necessary fields. Thus, the MPAS-A code distributed with
mpas-bundle has an additional "da_state" output stream defined in :code:`Registry.xml`. That stream should be added to the :code:`streams.atmosphere` file used to configure the forecast as follows

.. code:: xml

    <immutable_stream name="da_state"
                      type="output"
                      clobber_mode="truncate"
                      filename_template="mpasout.$Y-$M-$D_$h.$m.$s.nc"
                      io_type="pnetcdf,cdf5"
                      output_interval="0_06:00:00" />

The :code:`output_interval` and :code:`clobber_mode` should be modified to fit the user's application.
For a working example of using 2-stream input in MPAS-JEDI, users are referred to the
:doc:`JEDI-MPAS HofX tutorial <../../../learning/tutorials/level2/hofx-mpas>`. Part 4 of that tutorial
shows how to read a file with an "mpasout." prefix that was written using the "da_state" output stream.
The same file is used both for the "input" input stream and for the :code:`State::read` method.

Finally, there are two namelist settings of which MPAS-JEDI users ought to be aware. When the "restart"
stream is used, :code:`config_do_restart` should be set to :code:`true` in the :code:`nml_file` during
all MPAS-JEDI applications and during the MPAS-A forecast.  For 2-stream input, :code:`config_do_restart`
should be set to :code:`false`.  When conducting cycled forecast and data assimilation workflows,
:code:`config_do_DAcycling` should be set to :code:`true`, which forces MPAS-A to re-initialize the
coupled prognostic model fields from the MPAS-JEDI analysis fields.  The analysis fields are described
in more detail in the :ref:`stateinc` class descriptions.

deallocate non-da fields
^^^^^^^^^^^^^^^^^^^^^^^^

The :code:`geometry.deallocate non-da fields` option is used to reduce physical memory usage in 3D
JEDI applications that do not require time-integration of the MPAS-Model, i.e., applications that
do not utilize the :code:`Model` class. This setting controls deallocation of those unused fields,
which are allocated in a the :code:`domain_type` object that is created in :code:`mpas_init`. Refer
to the fortran-level :code:`Geometry` class source code for detailed information about which fields
are deallocated.

interpolation type
^^^^^^^^^^^^^^^^^^

The :code:`geometry.interpolation type` setting is optional, and allows flexibilty in dual-mesh
applications, where interpolation is performed between the two meshes. Valid settings are
:code:`bump` or :code:`unstructured`, which refer to two different interpolation implementations
in saber and oops, respectively.


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
                   theta, rho, u, qv, pressure, landmask, xice, snowc, skintemp, ivgtyp, isltyp,
                   qc, qi, qr, qs, qg, cldfrac,
                   snowh, vegfra, t2m, q2m, u10, v10, lai, smois, tslb, pressure_p]
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
following strings: :code:`qc`, :code:`qi`, :code:`qr`, :code:`qs`,
and :code:`qg` for cloud, ice, rain, snow, and graupel, respectively.
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
     - surface_pressure        # surface pressure [ Pa ]
     - qc                      # mixing ratio for cloud water [ kg / kg ]
     - qi                      # mixing ratio for cloud ice [ kg / kg ]
     - qr                      # mixing ratio for rain water [ kg / kg ]
     - qs                      # mixing ratio for snow [ kg / kg ]
     - qg                      # mixing ratio for graupel [ kg / kg ]

The latter five hydrometeor variables are optional. These variables are chosen because fewer variable changes are required for implementing (1) the multivariate background error covariance and (2) the simulation of observation equivalent quantities from analysis variables.

We have chosen :code:`stream_function` and :code:`velocity_potential` for the momentum control variables in the B matrix. Thus, the wind transform from stream function and velocity potential to zonal and meridional winds is implemented in :code:`control2analysis`.

.. code:: yaml

   variable change: Control2Analysis
   input variables: [stream_function, velocity_potential, temperature, spechum, surface_pressure]        # control variables
   output variables: [uReconstructZonal, uReconstructMeridional, temperature, spechum, surface_pressure] # analysis variables

We can also choose the pseudo relative humidity, :code:`relhum`, as an optional moisture control variable. The pseudo relative humidity is defined as a specific humidity normalized by saturation specific humidity (of background temperature and pressure). For this, variable transform from pseudo relative humidity to specific himidity is implemented in :code:`control2analysis`.

.. code:: yaml

   variable change: Control2Analysis
   input variables: [stream_function, velocity_potential, temperature, relhum, surface_pressure]         # control variables
   output variables: [uReconstructZonal, uReconstructMeridional, temperature, spechum, surface_pressure] # analysis variables

A YAML example for this linear variable change can be found in CTest :code:`mpas-jedi/test/testinput/linvarcha.yaml` or :code:`mpas-jedi/test/covariance/yamls/3dvar.yaml`

Analysis to Model Variable Change
"""""""""""""""""""""""""""""""""
After getting the analysis increment for :code:`[uReconstructZonal, uReconstructMeridional, temperature, spechum, surface_pressure]` from the minimization of cost function, the full field analysis state is calculated in :code:`+=` (add increment) method of :code:`State` class. In this method, the MPAS model variables :code:`[index_qv, pressure, theta, rho, u]` are also updated. The full-field pressure :code:`pressure` is obtained by integrating the hydrostatic equation from the surface. The dry potential temperature :code:`theta` is then calculated from :code:`temperature` and :code:`pressure`, and dry air density :code:`rho` is derived using the equation of state. The edge normal wind :code:`u` is incrementally updated by using :code:`subroutine uv_cell_to_edges`, originally from MPAS DART.


Variable Change from Reading MPAS file to Analysis Variable
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
As described in “state variables”, :code:`State::read` includes several variable changes. First, :code:`pressure_base` and :code:`pressure_p` (pressure perturbation) are read separately, and then added to the full fields :code:`pressure`. The water vapor mixing ratio :code:`index_qv` is read from the file, and converted to the specific humidity :code:`spechum`. The dry potential temperature :code:`theta` is read from the file, and converted to :code:`temperature`.
Because the reconstructed winds at the cell center, :code:`uReconstructZonal` and :code:`uReconstructMeridional`, are usually available in the MPAS file, they are directly read from the file.


Nonlinear and Linear Variable Change from Analysis to GeoVaLs Variable
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
The model interface interacts with UFO through Geophysical Variables at Locations, or
:code:`GeoVaLs`. Translating from model variables on the MPAS mesh to :code:`GeoVaLs` is a two-step
process divided into a variable change between the MPAS variable and the UFO variable, and an
interpolation from the MPAS mesh to the observation locations. The :code:`Model2GeoVars` and
:code:`LinearModel2GeoVars` classes are used to translate from the background state variables and
the increment variables in MPAS-JEDI to the UFO variables that occupy :code:`GeoVaLs`.  The variable
transforms are conducted across the entire model mesh one time for all observation operators.
Oftentimes a UFO variable identically matches an MPAS field variable, in which case an the identity
transform is applied in :code:`Model2GeoVars` and/or :code:`LinearModel2GeoVars`.

There is a list of ``GeoVars`` that are available in MPAS-JEDI in
code:`mpas-jedi/test/testinput/namelists/geovars.yaml`. As an example, consider the entry for
:code:`air_pressure`, which is the name of a UFO ``GeoVars``

.. code:: yaml

  - field name: air_pressure
    mpas template field: theta
    mpas identity field: pressure

Each such entry within the :code:`fields` vector must include the :code:`fields[i].field_name` and the :code:`fields[i].mpas template field`.  The :code:`fields[i].mpas template field` entry must be
the name of an MPAS-Model field that is present in the :code:`Geometry`'s :code:`domain_type` member
object. It is a field with the same shape as the UFO ``GeoVars`` in the sense that it has the same
number of vertical levels.  Each :code:`fields` member may also include the
:code:`fields[i].mpas template field` entry, which indicates that the specified MPAS-Model field and
the UFO ``GeoVars``are identical, even down to having the same units.  For such fields, of which there
are many, the :code:`Model2GeoVars` and/or :code:`LinearModel2GeoVars` classes utilize an identity
transform.  For each entry in `geovars.yaml` that does not have and :code:`mpas identity field`,
those classes must explicitly describe the transformation between MPAS-Model fields that are
available in the :code:`State` and the corresponding UFO ``GeoVars``


.. _getvalues-mpas:

GetValues and LinearGetValues
-----------------------------

After the model variable fields are converted to ``GeoVars``, the
:code:`GetValues` and :code:`LinearGetValues` classes are responsible for interpolating the
`GeoVars` from the MPAS unstructured Voronoi mesh to the observation locations requested by the UFO
observation operators. Currently OOPS instructs :code:`GetValues` and :code:`LinearGetValues` to
carry out interpolation for each observation opterator independently, in a serial loop.  The
interpolation weights are calculated only once for each observation operator in an ``HofX``
application and only once per outer iteration in a ``Variational`` application.

There are two alorithms that can be used for the horizontal interpolation, one from the BUMP library
and another from the OOPS repository. The latter is referred to as "unstructured interpolation",
even though both algorithms are technically generlized for unstructured meshes. In MPAS-JEDI, the
user can choose the interpolation algorithm via the
:code:`observations[:].get values.interpolation type` configuration element under each observation
type in the YAML. For example,

.. code:: yaml

  observations:
  - get values:
      interpolation type: unstructured
    obs space:
      name: Radiosonde
      obsdatain:
        obsfile: sondes_obs_2018041500_m.nc4
      obsdataout:
        obsfile: obsout_sondes.nc4
      simulated variables: [air_temperature, eastward_wind, northward_wind, specific_humidity]
    obs operator:
      name: VertInterp
    obs error:
      covariance model: diagonal

The valid values of :code:`get values.interpolation type` in MPAS-JEDI are `unstructured` and
`bump`, where `bump` is the default value.  Both interpolation algorithms have pros and cons, and
are subject to further improvement.

Somewhat different interpolation methods are used depending upon the data-type of the field.
Barycentric weights (`unstructured`) or mesh triangulation (`bump`) are used for scalar real
fields, while a form of nearest neighbor interpolation is used for integer fields.  Integer fields
are which are primarily associated with surface quantities, such as vegetation and soil types.
MPAS-JEDI has two ctests that exercsie the OOPS interfaces of the GetValues and LinearGetValues
classes. The two tests are configured with the :code:`getvalues.yaml` and
:code:`lineargetvalues.yaml` YAML files.
