.. _top-mpas-jedi-data:

.. _test_files:

Test files
==========

This section describes the test files that accompany the repository. These can be found in
:code:`mpas-bundle/mpasjedi/test/`.

.. _yaml_files:

yaml configuration files
------------------------

:code:`Data/testinput` contains a number of yaml files for configuring various tests and applications
with a 480km MPAS mesh using MPAS-JEDI. These serve as examples for users to configure their
own applications.

**Data Assimilation Applications**

:code:`3denvar_bumploc.yaml` is an example of pure 3DEnVar with a 5-member ensemble background error
covariance and fixed vertical and horizontal localization scales.

:code:`3dfgat.yaml` is an example of the First Guess at Appropriate Time using three time slots.

:code:`3dvar.yaml` and :code:`3dvar_bumpcov.yaml` are 3DVar examples with the identity background
error covariance and the BUMP-estimated univariate background error covariance, respectively.

:code:`3dhybrid_bumpcov_bumploc.yaml` is for hybrid-3DEnVar.

:code:`4denvar_bumploc.yaml` is the configuration for pure 4DEnVar with 5 ensemble members
at 3 time slots with BUMP used for covariance localization. :code:`4denvar_ID.yaml` is similar to
:code:`4denvar_bumploc.yaml` but without localization.

:code:`eda_3dhybrid.yaml` and :code:`eda_3dhybrid_1-5.yaml` performs a 5-member ensemble of hybrid-3DEnVar analyses.

**HofX Applications**

HofX takes the model and observation input and computes the model-counterpart of
observations using the forward observation operators implemented in UFO. Quality
control filters can optionally be applied in HofX applications. This type of
application could be used for verifying a model forecast against observations.

:code:`hofx_nomodel.yaml` uses a model state pre-generated from the separate
MPAS forecast application.

:code:`hofx.yaml` includes the step of the model forecast.

:code:`enshofx.yaml` and :code:`enshofx_1-5.yaml` are used to execute a 5-member ensemble of hofx applications.

**Estimate background error covariances and localization using BUMP**

:code:`parameters_bumpcov.yaml` is for estimating the static background error covariance.

:code:`parameters_bumploc.yaml` is for estimating the ensemble localization lengthscales.

**Unit Tests and Other Applications**

:code:`geometry.yaml`: Unit test for the Geometry class.

:code:`model.yaml`: Unit test for the Model class.

:code:`state.yaml`: Unit test for the State class.

:code:`increment.yaml`: Unit test for the Increment class.

:code:`errorcovariance.yaml`: Unit test for the background error covariance class.

:code:`dirac_bumpcov.yaml`: Dirac test using the static background error covariance.

:code:`dirac_bumploc.yaml`: Dirac test using the ensemble background error covariance with localization.

:code:`dirac_noloc.yaml`: Dirac test using the ensemble background error covariance without localization.

:code:`linvarcha.yaml`: Unit test for the Linear Variable Change class.

:code:`forecast.yaml`: Run a MPAS model forecast inside JEDI.

:code:`getvalues.yaml`: Unit test for the GetValues class.

:code:`lineargetvalues.yaml`: Unit test for the LinearGetValues class.

:code:`gen_ens_pert_B.yaml`: Application test to generate the randomized perturbations based on the background error covariance, and then run a model forecast. This test is currently disabled.

.. TODO: Give some details on each unit test -- what's tested and how?

MPAS fixed input files
------------------------

After one runs :code:`ctest` after building the mpas-bundle, MPAS model-required static and
climatology files will appear under :code:`Data/`, including CAM_*.DBL, OZONE_*.TBL,
RRTMG_*, SOILPARM.TBL, GENPARM.TBL, VEGPARM.TBL.
These files are downloaded during the build phase of MPAS-Model. They appear in the ~mpasjedi/test
directory during the build phase of mpas-jedi. (See :code:`mpasjedi/test/CMakeLists.txt`.)

MPAS model grid (480km) partition file
:code:`x1.2562.graph.info.part.2` is also needed to test mpas-jedi with 2 processors.

MPAS model namelist examples (:code:`namelist.atmosphere`, :code:`namelist.atmosphere_2018041421`,
and :code:`namelist.atmosphere_2018041500`) and MPAS stream files
(:code:`streams.atmosphere`, :code:`stream_list.atmosphere.diagnostics`,
:code:`stream_list.atmosphere.output`, :code:`stream_list.atmosphere.surface`)
for controlling model I/O are also provided.

Users should consult the MPAS model's documentation (https://mpas-dev.github.io/)
to understand namelist settings.

Dynamic input files
-------------------

**Background**

When running data assimilation applications it is necessary to provide a background or restart state from
which to initialize the system. The files that are required of course depend on the model
but three global MPAS restart files (:code:`restart.2018-04-14_21.00.00.nc`,
:code:`restart.2018-04-15_00.00.00.nc`, and :code:`restart.2018-04-15_03.00.00.nc`) are included
with the repository in :code:`mpasjedi/test/` to serve as the background for different DA applications.
The number of files that are needed also depends on the application being executed.
Data assimilation with 4DEnVar requires backgrounds for every sub-window
while 3DVar/3DEnVar only requires one background at the middle of the window.

**Ensemble**

If running with ensemble applications (3D/4DEnVar or EDA) an ensemble must also be provided.
There are examples of the ensemble files included in :code:`mpasjedi/Data/480km/bg/ensemble/mem01-05`.
Five-member ensemble files are provided at three times to
support 4DEnVar applications.

.. _dynamic_output_files-mpas:

Dynamic output files
--------------------

When the system runs it will produce several types of output files. Directories need to be created
ahead of time in order to house this data.

**hofx**

When running either hofx or data assimilation applications it will produce hofx output containing
several quantities in observation space. An example of how this output is set is below. Note that in
the testing the files go to :code:`mpasjedi/test/Data/os`. In practice
users can specify the file name and select where they would like the data to be output.

.. code:: yaml

   obsdataout:
     obsfile: Data/os/hofxnm_sondes.nc4

**bump**

When running applications involving the B matrix Unstructured Mesh Package (BUMP) it will produce
statistics written to files that are read in when running the applications. Again the user can
choose where this data will be stored. In many cases these kinds of files produced by BUMP will be
static and not generated except when first setting up an experiment. The yaml snippet below shows
how the path and filenames for BUMP output are set.

.. code:: yaml

   bump:
     prefix: Data/bump/mpas_parametersbump_loc

**analysis**

When running a data assimilation application it will write out analysis file(s) to disk,
which is in the same MPAS netcdf format. The code below shows how to set the analysis file name.

.. code:: yaml

  output:
    filename: "Data/states/mpas.3denvar_bump.$Y-$M-$D_$h.$m.$s.nc"
