.. _top-fv3-jedi-data:

.. _data_files:

Data files
==========

The below describes the static data files that accompany the repository. These can be found in
fv3-jedi/test/Data/

.. _static_data_files:

Static data files
-----------------


**fieldsets**

Data/fieldsets contains a number of files for controlling the fields that can be instantiated in
FV3-JEDI, desribed in :ref:`fieldmetadata`. The fields in these files are designed to serve as an
example and include all the fields used in the ctest suite executed in FV3-JEDI. As the system
evolves and more models are added and used it is anticipated that these FieldSet files will be more
tailored to the specific model rather than with the catch all way they are currently constructed.

The file :code:`dynamics.yaml` contains the main dynamic fields used in the system and is where a
new field for the global NWP could be added. The file :code:`ufo.yaml` contains all the fields that
UFO can potentially request from the model. FV3-JEDI calls a variable transform operation where it
converts between the model fields and the UFO fields before performing the interpolation to
observation locations. In order to complete the variable transform, FV3-JEDI first creates a state
with the fields requested from the observation operator, if there are fields that are not already
part of :code:`dynamics.yaml` they are included via :code:`ufo.yaml`.


**fv3files**

There are a number of fixed 'fv3files' needed by FV3-JEDI, most of which are used by the
:ref:`geometry` class and some by the :ref:`model` and :ref:`linearmodel`.

The file :code:`akbkx.nc4`, where :code:`x` is the number of vertical levels, contains the
coefficients for creating the vertical coordinate. The directory also includes
:code:`generate_akbk.py`, which can be used to generate a :code:`akbk.nc4` file that can be read by
FV3-JEDI geometry.

The file :code:`field_table` contains and example of the tracers that are to be used. The fields
contained in this file are only important if running forecasts in-core with FV3-JEDI but it has to
contain at least one field to avoid any failures when making calls into the FV3 model routines that
provide the geometry.

The file :code:`fmsmpp.nml` is used only to initialize the FMS library.

Files like :code:`input_gfs_c12_p12.nml` provide example files for initializing the Geometry as well
as the standalone dynamical core model.

Files like :code:`inputpert_4dvar.nml` are used to initialize the :ref:`linearmodel`.


**femps**

FV3-JEDI requires with the Finite Element Mesh Poisson Solver (FEMPS), which is used to convert wind
fields to stream function and velocity potential. This solver involves a multigrid method and for
simpliciity the grid heirarchy is initialized by reading longitude and latitude from files. Some
examples of these files are provided with the repository and can be generated for other resolutions
by running the geometry test with the :code:`do_write_geom` flag set to true.

.. _dynamic_input_files:

Dynamic input files
-------------------

**Background**

When running data assimilation applications it is necessary to provide backgrounds or restarts from
which to initialize the system. The files that are required of course depends on the model
but some examples are included with the repository in Data/inputs for global NWP with GEOS and GFS,
global aerosol with GEOS and GFS, regional NWP with GFS and regional aerosol with GFS. The kinds of
files that are needed also depends on the application being executed. Data assimilation with 4DEnVar
requires backgrounds for every sub-window requested while 4DVar only requires one background at the
beginning of the window and 3DVar only requires one background at the middle of the window.

**Ensemble**

If running with ensemble applications an ensemble must also be provided. There are examples of the
ensemble files included in Data/input/ for several models. Ensemble fields are provided hourly to
support 4DEnVar applications.

.. _dynamic_output_files:

Dynamic output files
--------------------

When the system runs it will produce several types of output file. Directories need to be created
ahead of time in order to house this data.

**hofx**

When running either hofx or data assimilation applications it will produce hofx output containing
several statistics for the observations. An example of how this output is set is below. Note that in
the testing the files go to Data/hofx which is a directory created ahead of the tests. In practice
users can select where they would like the data to be output.

.. code:: yaml

   obsdataout:
     obsfile: Data/hofx/aircraft_4denvar-gfs_2018041500_m.nc4


**bump**

When running applications involving the B matrix Unstructured Mesh Package (BUMP) it will produce
statistics written to file that are read in when running the applications. Again the user can
choose where this data will be stored. In many cases these kinds of files produced by BUMP will be
static and not generated except when first setting up an experiment. The below yaml snippet shows
how the path and filenames for BUMP output is set.

.. code:: yaml

   bump:
     prefix: Data/bump/fv3jedi_bumpparameters_nicas_gfs

**analysis**

When running a data assimilation or forecast application it will need to write model fields to disk.
In the testing these are written to directories called forecast and analysis. The below shows how to
control where the analysis files are written. The key :code:`first` says how far into the window the
first output is and :code:`frequency` the time step between output.

.. code:: yaml

  output:
    datapath: Data/analysis/
    first: PT0H
    frequency: PT3H
