
.. _VT-radfrompcscores:

==============================================
Convert principal component scores to radiance
==============================================
Perform a transformation from principal component (PC) scores to spectral radiance.

:code:`Transform: SatRadianceFromPCScores`

.. code-block:: yaml

  obs pre filters:
  ### PC scores to spectral radiance (W / (m^2.sr.m^-1))
  - filter: Variable Transforms
    Transform: SatRadianceFromPCScores
    destination variable:
      name: radiance
      channels: *all_channels
    reconstruction operator file: ./iasi_pcscores_reconstructor.nc4
    operator data group: PCScores # default
    operator channel group: MetaData # default
    number of principal components: 300
    principal component scores variable: MetaData/principalComponentScore
    reconstruction scaling factor: 0.5 # default value

**Parameters**

The following parameters are required:

* :code:`destination variable` defines the ObsSpace variable :code:`name` for the reconstructed
  radiances together with an associated list of :code:`channels` - this destination variable is
  written to the :code:`DerivedObsValue` group.
* :code:`reconstruction operator file` provides a path to a netCDF file containing the PC scores
  reconstruction operator (file format is detailed below).
* :code:`number of principal components` defines the total number of PCs used in the reconstruction
  (this number should match the component dimension in the reconstruction operator file).
* :code:`principal component scores variable` is the base name of the :code:`ufo::Variable`
  containing the observation PC scores - if the variable is :code:`MetaData/principalComponentScore`
  then the obs space should contain variables numbered :code:`MetaData/principalComponentScore1`,
  :code:`MetaData/principalComponentScore2`, ..., up to the number of PCs.

The following parameters are optional with default values:

* :code:`operator data group` specifies the name of the group in the reconstruction operator file
  containing the operator itself - by default this group name is :code:`PCScores`.
* :code:`operator channel group` specifies the name of the group in the reconstruction operator
  file containing the variable which describes the reconstruction operator channel numbers - by
  default this group name is :code:`MetaData`.
* :code:`reconstruction scaling factor` is a scalar multiplier which ensures the output spectral
  radiance units are :math:`W / (m^{2}.sr.m^{-1})` - by default this scaling factor is 0.5.
* :code:`operator mean data group` is the name of the group in the reconstrction operator file
  containing a mean value which may be part of the reconstructed radiance operator depending upon
  the data provider. By default this is an empty string and a value of zero is added to the
  product of the PCscores and MetaData/principalComponentScore. 

**Reconstruction operator file**

The netCDF file containing the PC scores reconstruction operator has the following format:

* The operator itself is a two-dimensional variable in a group with name specified by the
  :code:`operator data group` parameter, where its first dimension is principal component and its
  second dimension is channel.
* The sensor channel numbers associated with the operator should be the sole variable in a
  group with name specified by the :code:`operator channel group` parameter, by convention the
  variable in this group is named :code:`sensorChannelNumber`.

An example file format follows:

.. code-block:: bf

   netcdf {
   dimensions:
       Channel = 8461 ;
       Component = 300 ;
   variables:
       int Channel(Channel) ;
       int Component(Component) ;
   group: MetaData {
   variables:
       int sensorChannelNumber(Channel) ;
   } // group MetaData
   group: PCScores {
   variables:
       float reconstructionOperator(Component, Channel) ;
   } // group PCScores
   }

**Observation ingest**

The ObsSpace should be initialised with a :code:`Channel` dimension which matches the channel
list to be reconstructed. A :code:`read from yaml` method for assigning channel numbers from an
ODB query is provided (see :ref:`ioda-format-odb-channel-indices`).

**Method**

The reconstruction method follows the convention associated with Eumetsat v2.01 eigenvectors for
IASI. Reconstructed radiances :math:`{\mathbf{r^\prime}}` are computed as the matrix multiplication
of the reconstruction operator :math:`{\mathbf{R}}` (dimensions number of components by number of
channels) with PC scores :math:`{\mathbf{p}}` (dimensions number of components by number of
observation locations):

.. math::

   {\mathbf{r^\prime}} = 0.5 {\mathbf{R}}^{T} {\mathbf{p}}

where the default scaling factor of 0.5 has been applied.

Eumetsat provide three separate reconstruction operator matrices for the three IASI spectral bands.
Here, the matrices have been combined so that a single reconstruction operator matrix covering the
whole spectrum is used.

Instruments such as Meteosat Third Generation - Infrared Sounder (MTG-IRS) require a mean value added as part of the 
reconstruction process as follows:

.. math::

   {\mathbf{r^\prime}} = 1.0 {\mathbf{R}}^{T} {\mathbf{p}} + {\mathbf{\overline r}}

where a specified scaling factor of 1.0 is applied and a mean value of :math:`{\mathbf{\overline r}}` is present
in the operator file, and whose group is specified using :code:`operator mean data group`.
