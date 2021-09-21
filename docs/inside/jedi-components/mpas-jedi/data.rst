.. _top-mpas-jedi-data:

.. _test_files:

Test files
==========

This section describes the configuration and data files that accompany the repository. The configuration files
can be found in :code:`mpas-bundle/mpas-jedi/test/testinput` and :code:`mpas-bundle/mpas-jedi/test/testinput/namelists`.
The actual data files are downloaded from each test data repository (:code:`mpas-jedi-data` and :code:`ufo-data`) 
when :code:`mpas-bundle` is built or from UCAR DASH (for CRTM coefficients through :code:`mpas_get_crtm_test_data` test).
:code:`mpas_get_ufo_test_data` and :code:`mpas_get_mpas-jedi_test_data` tests also check if the necessary test data is
in place.

.. _yaml_files:

yaml configuration files
------------------------

The directory :code:`mpas-bundle/mpas-jedi/test/testinput` contains a number of yaml files for configuring
various tests and applications with a 480km MPAS mesh using MPAS-JEDI. These serve as examples
for users to configure their own applications.

**Data Assimilation Applications**

:code:`3denvar_bumploc_bumpinterp.yaml` is an example of pure 3DEnVar with a 5-member ensemble background error
covariance and diagnosed horizontal localization scales (see :code:`parameters_bumploc.yaml` below)
and using BUMP utilities for spatial interpolation of models fields.

:code:`3denvar_bumploc_unsinterp.yaml` is the same as :code:`3denvar_bumploc_bumpinterp.yaml`, except for using
an unstructured interpolation with barycentric weights, which is available from OOPS repository.

:code:`3denvar_2stream_bumploc_unsinterp.yaml` is the same as :code:`3denvar_bumploc_bumpinterp.yaml`, except for using
the two-stream state initialization method. More information about two-stream state initialization is available in the :ref:`geometry-mpas` class documentation.

:code:`3denvar_dual_resolution.yaml` is an example of pure 3DEnVar with a finer resolution state (at 384 km) and
coarse resolution increment (at 480 km).

:code:`3dfgat.yaml` is an example of the First Guess at Appropriate Time using three time slots.

:code:`3dvar.yaml` is a 3DVar example with the Identity background error covariance.

:code:`3dvar_bumpcov.yaml` and :code:`3dvar_bumpcov_rttovcpp.yaml` are 3DVar examples with the BUMP-estimated
univariate background error covariance. :code:`3dvar_bumpcov.yaml` uses the CRTM observation operator to simulate
the radiance observation, while :code:`3dvar_bumpcov_rttovcpp.yaml` uses the RTTOV observation operator.

:code:`3dhybrid_bumpcov_bumploc.yaml` is for hybrid-3DEnVar.

:code:`4denvar_bumploc.yaml` is the configuration for pure 4DEnVar with 5 ensemble members
at 3 time slots with BUMP used for covariance localization. :code:`4denvar_ID.yaml` is similar to
:code:`4denvar_bumploc.yaml` but without localization.

:code:`eda_3dhybrid.yaml` and :code:`eda_3dhybrid_1-4.yaml` performs a 5-member ensemble of hybrid-3DEnVar analyses.

**HofX Applications**

HofX takes the model and observation input and computes the model-counterpart of
observations using the forward observation operators implemented in UFO. Quality
control filters can optionally be applied in HofX applications. This type of
application could be used for verifying a model forecast against observations.

:code:`hofx3d.yaml` uses a model state pre-generated from the separate MPAS forecast application.

:code:`hofx3d_rttovcpp.yaml` is the same as :code:`hofx3d.yaml`, except for using the RTTOV observation operator only.

:code:`hofx.yaml` includes the step of the model forecast.

:code:`enshofx.yaml` and :code:`enshofx_1-5.yaml` are used to execute a 5-member ensemble of hofx applications.
This test is currently disabled.

**Estimate background error covariances and localization using BUMP**

:code:`parameters_bumpcov.yaml` is for estimating the static background error covariance from 5-member ensemble samples.

:code:`parameters_bumploc.yaml` is for estimating the ensemble localization lengthscales:from 5-member ensemble samples.

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

:code:`getvalues_bumpinterp.yaml` and :code:`getvalues_unsinterp.yaml`: Unit test for the GetValues class using
BUMP utilities and unstructured interpolation from OOPS for spatial interpolation of model fields, respectively.

:code:`lineargetvalues.yaml`: Unit test for the LinearGetValues class.

:code:`convertstate_bumpinterp.yaml` and :code:`convertstate_unsinterp.yaml`: Application test to convert the state between
two geometries with different resolutions using BUMP interpolation or unstructured interpolation, respectively.

:code:`rtpp.yaml` : Application test for relaxation to prior perturbation (RTPP) inflation.

:code:`gen_ens_pert_B.yaml`: Application test to generate the randomized perturbations based on the background error covariance, and then run a model forecast. This test is currently disabled.

MPAS fixed input files
------------------------

When the mpas-bundle is built, MPAS model-required static and climatology files are downloaded and placed
under :code:`~build/_deps/mpas_data-src/atmosphere/physics_wrf/files/`, including CAM_*.DBL, OZONE_*.TBL, RRTMG_*,
SOILPARM.TBL, GENPARM.TBL, VEGPARM.TBL. They are copied in the :code:`~build/mpas-jedi/test` directory
during the build phase of mpas-jedi. (See :code:`mpas-bundle/mpas-jedi/test/CMakeLists.txt`.)

MPAS model grid (480km) partition file
:code:`x1.2562.graph.info.part.2` is also needed to test mpas-jedi with 2 processors.

MPAS model namelist examples (:code:`384km/namelist.atmosphere_2018041500`, :code:`480km_2stream/namelist.atmosphere_2018041500`,
:code:`480km/namelist.atmosphere_2018041421`, and :code:`480km/namelist.atmosphere_2018041500`) and MPAS stream files
(:code:`384km/streams.atmosphere`, :code:`480km_2stream/streams.atmosphere`, :code:`480km/streams.atmosphere`,
:code:`stream_list.atmosphere.diagnostics`, :code:`stream_list.atmosphere.output`, :code:`stream_list.atmosphere.surface`)
for controlling model I/O are also provided under `mpas-bundle/mpas-jedi/test/namelists` directory.

Users should consult the MPAS model's documentation (https://mpas-dev.github.io/)
to understand namelist settings.

Dynamic input files
-------------------

When running data assimilation (or other) applications, it is necessary to provide a background or restart state from
which to initialize the system. The files that are required of course depend on the applications.
:code:`mpas-bundle/mpas-jedi-data/testinput_tier_1` includes the dynamic input files required for Tier 1 ctest.

**Background**

For most ctests, a single global MPAS restart file (:code:`480km/bg/restart.2018-04-14_21.00.00.nc` or
:code:`480km/bg/restart.2018-04-15_00.00.00.nc`) serves as the background state. For 4DEnVar test, three files
(including :code:`480km/bg/restart.2018-04-15_03.00.00.nc`) are used to represent the time-dependent background state.

:code:`384km/init/x1.4002.init.2018-04-15_00.00.00.nc` is used as the fine resolution background state for dual-resolution test.

To test the two-stream state initialization method, :code:`480km_2stream/mpasout.2018-04-15_00.00.00.nc` and
:code:`480km_2stream/x1.2562.init.2018-04-14_18.00.00.nc` are included to provide the time-dependent and time-independent
variables, respectively.

**Ensemble**

If running with ensemble applications (3D/4DEnVar or EDA) an ensemble must also be provided.
There are examples of the ensemble files included in :code:`480km/bg/ensemble/mem01-05`.
Five-member ensemble files are provided at three times to support 4DEnVar applications.

.. _dynamic_output_files-mpas:

Dynamic output files
--------------------

When the system runs it will produce several types of output files. Directories need to be created
ahead of time in order to house this data.

**hofx**

When running either hofx or data assimilation applications it will produce hofx output containing
several quantities in observation space. An example of how this output is set is below. Note that in
the testing the files go to :code:`~build/mpas-jedi/test/Data/os`. In practice
users can specify the file name and select where they would like the data to be output.

.. code:: yaml

   obsdataout:
     obsfile: Data/os/hofxnm_sondes.nc4

**bump**

When estimating the background error-related parameters with BUMP (:code:`parameters_bumpcov.yaml`
or :code:`parameters_bumploc.yaml` above), it will write out the statistics to files under :code:`~build/mpas-jedi/test/Data/bump`. 
In many cases these kinds of files produced by BUMP will be static and not generated except when first setting up an experiment.
When running applications involving BUMP, the user can choose where this data is stored.
The yaml snippet below shows how the path and filenames for BUMP output are set.

.. code:: yaml

   bump:
     prefix: Data/bump/mpas_parametersbump_loc

**analysis**

When running a data assimilation application it will write out analysis file(s) to disk,
which is in the same MPAS netcdf format. The code below shows how to set the analysis file name.

.. code:: yaml

  output:
    filename: "Data/states/mpas.3denvar_bump.$Y-$M-$D_$h.$m.$s.nc"
