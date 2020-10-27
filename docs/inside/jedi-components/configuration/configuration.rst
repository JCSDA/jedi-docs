JEDI Configuration Files: Implementation
========================================

This document describes the practical implementation of JEDI configuration files, including how users can create and read them.  For an overview what these files contain see :doc:`JEDI Configuration Files: Content </using/building_and_running/config_content>`.

.. _config-format:

File Format
-----------

Configuration files are files that control the execution of specific applications.  They specify input parameters, control flags, file names, tolerance thresholds, and other configuration details that are used by JEDI to run tests, forecasts, DA, and other applications.

Configuration files for most JEDI tests are located in the :code:`test/testinput` directory of each JEDI repository.  The configuration files in the :code:`ufo`, :code:`ioda`, and :code:`fv3-jedi` repositories are particularly useful as illustrative examples for constructing configuration files in other repositories.

Configuration (often abbreviated as config) files in JEDI may be written either in `YAML <https://yaml.org>`_ or in `JSON <https://www.json.org>`_;  JEDI uses the parser from ECMWF's `eckit library <https://github.com/ecmwf/eckit>`_ to read these files and this parser can process both formats.  However, we recommend using **YAML** because it is generally more user-friendly; YAML is easier to read and, unlike JSON, it allows the user to include comments.  YAML files can end with the extension :code:`.yaml` or :code:`.yml`.  JSON files typically end with the extension :code:`.json`.

As an example, consider a configuration file similar to the one used in the :code:`test_qg_hofx` unit test, which is located in the :code:`oops` repository as :code:`qg/test/testinput/hofx.yaml`:

.. _yaml-file:

.. code-block:: yaml

    ---
    geometry:
      nx: 40
      ny: 20
      depths: [4500.0, 5500.0]  # a list of the depths used in model
    initial condition:
      date: 2010-01-01T00:00:00Z
      filename: Data/truth.fc.2009-12-15T00:00:00Z.P17D.nc
    model:
      name: QG
      tstep: PT1H
    forecast length: PT12H
    window begin: 2010-01-01T00:00:00Z
    window length: PT12H
    observations:
    - obs space:
        obs type: Stream
        obsdatain:
          obsfile: Data/truth.obs4d_12h.nc
        obsdataout:
          obsfile: Data/hofx.obs4d_12h.nc
      obs operator:
        obs type: Stream
      obs bias: {}
    - obs space:
        obs type: Wind
        obsdatain:
          obsfile: Data/truth.obs4d_12h.nc
        obsdataout:
          obsfile: Data/hofx.obs4d_12h.nc
      obs operator:
        obs type: Wind


Note that keys representing objects (single variables, vectors or more complex objects) are represented as lower case and entire words.  This is the preferred style but it is not currently followed by all JEDI repositories.

We refer the user to the `YAML Documentation <https://yaml.org/spec/1.2/spec.html>`_ for a comprehensive description of the syntax but we'll give a brief overview here.

The first thing to note is that indentation matters.  Items are organized into a hierarchy, with the top-level objects beginning in the leftmost column and subsidiary components of these objects indented accordingly.  The number of spaces is not important; two is sufficient to define the scope of an item and its contents.

The beginning of a YAML document can be indicated by three dashes :code:`---`, which may or may not be preceded by directives. Each line typically contains a key-value pair separated by a colon and a space.  The key is generally a string and the value may be either a string or a number.  This is used to assign values to variables.  For example, the **window begin** object is set to a value of '2010-01-01T00:00:00Z' and the **geometry.nx** variable is set to a value of 40.  Note that we have used a period to represent the hierarchy of items; **nx** is a component of **geometry**.  Note also that the values may be interpreted in different ways.  For example, the **window begin** value is written as a string in the yaml file but it is interpreted as a :code:`util::DateTime` object when it is read into JEDI.

Objects with multiple values (sequences in YAML) are indicated as indented lists with one item per line and each item delineated by a dash.  For example, **observations[0].obs space.simulated variables** is equated to a list of items, namely ["air_temperature", "eastward_wind", "northward_wind"].

Lists or sequences may also be identified with brackets :code:`{}` or :code:`[]`.  This is illustrated in the above file with the examples of **geometry.depths**, which here is identified as a list of floats, and **observations[0].obs bias**, an empty list.

Comments are preceded by a :code:`#` sign as seen for **geometry.depths**.

.. _config-cpp:

C++ Usage
---------

As noted in the previous section, JEDI configuration files are read by means of the `eckit C++ library <https://github.com/ecmwf/eckit>`_ developed and distributed by the European Centre for Medium Range Weather Forecasting (ECMWF).

Configuration files are read into JEDI as :code:`eckit::Configuration` objects.  More specifically, :code:`eckit::Configuration` is the base class that is often accessed through its derived classes :code:`eckit::LocalConfiguration` and :code:`eckit::YAMLConfiguration`.  All of these classes are defined in the :code:`src/eckit/config` directory of the  `eckit repository <https://github.com/ecmwf/eckit>`_.

As described in our document on :doc:`JEDI Testing <../../../inside/testing/unit_testing>` (see :ref:`Tests as Applications <test-apps>` in particular), JEDI applications are executed by passing an :code:`oops::Application` object to the :code:`execute()` method of an :code:`oops::Run` object.  The name of the configuration file (including path) is generally specified on the command line when running a JEDI executable and this file name is passed to the constructor of the :code:`oops::Run` object.  There is it used to create an :code:`eckit::Configuration` object which is passed to the Application when it is executed.  The :code:`eckit::Configuration` class contains a number of public methods that can be then used to query the config file and access its contents.

To illustrate how this works, let's return to our :code:`test_qg_hofx` example introduced in the previous section.  The configuration file for that test is called :code:`qg/test/testinput/hofx.yaml`.  In this example, our Application happens to be a HofX object and :code:`oops::HofX` is a subclass (child) of :code:`oops:Application`.  So, the configuration file is passed from the command line to the :code:`oops::Run` object and then to the Application as an argument (of type :code:`eckit::Configuration`) to the :code:`oops::HofX::execute()` method.  This general approach is similar to other Applications.

What happens next is more specific to the HofX Application but it serves to illustrate how to manipulate and access the config file as an :code:`eckit::Configuration` object.  Here is an example code segment from the :code:`oops::HofX::execute()` method as defined in the :code:`oops/src/oops/runs/HofX.h` file:

.. _config-cpp-seg1:

.. code-block:: C++

    int execute(const eckit::Configuration & fullConfig) const {

      // Example 1
      const util::Duration winlen(fullConfig.getString("window length"));
      const util::DateTime winbgn(fullConfig.getString("window begin"));
      const util::DateTime winend(winbgn + winlen);
      Log::info() << "Observation window from " << winbgn << " to " << winend << std::endl;

      // Example 2
      const eckit::LocalConfiguration geometryConfig(fullConfig, "geometry");


    [...]

Here the :code:`Configuration` object can also be accessed directly through the public methods of the :code:`eckit::Configuration` object itself.  This is demonstrated by the :code:`fullConfig.getString()` in Example 1 :ref:`above <config-cpp-seg1>`.  This sets the duration :code:`winlen` equal to the value of **window length** as specified in the first line of the :ref:`YAML file <yaml-file>`.

The example 2 illustrates an important point, namely that new configuration objects are constructed through the derived (child) class of :code:`eckit::LocalConfiguration` rather than the base class of :code:`eckit::Configuration` (whose constructors are protected).  The constructor shown in Example 2 :ref:`above <config-cpp-seg1>` takes two arguments.  The first is :code:`fullConfig`, the configuration passed to the :code:`oops::HofX::execute()` method.  The second argument is a string that serves to extract a component of that Configuration, in particular, everything contained under the **geometry** section of the :ref:`YAML file <yaml-file>`.  This component is placed in the :code:`LocalConfiguration` object :code:`geometryConfig`.

YAML and JSON objects are hierarchical and self-similar.  So, the **geometry** component of the YAML file can be treated as a self-contained YAML object in its own right, with its own components.  Configuration objects are the same way.  One can define an :code:`eckit::Configuration` object that includes the contents of the entire YAML file, as is the case for :code:`fullConfig`, or one can define an :code:`eckit::Configuration` object that contains only a particular component of the top-level YAML structure, as is the case for :code:`geometryConfig`.  Remember that :code:`LocalConfiguration` objects *are* :code:`Configuration` objects since the former is a child (derived class) of the latter.

It's tempting to think of :code:`LocalConfiguration` objects as components of :code:`Configuration` objects but this is incorrect.  One could in principle have an :code:`eckit::LocalConfiguration` object refer to the YAML file as a whole and a :code:`eckit::Configuration` object refer to a single section, though this is rarely done.  The **Local** in LocalConfiguration refers to a local component of the JEDI code, not a local section of the YAML file.  You can create, access, and even change :code:`eckit::LocalConfiguration` objects in a way that is not possible with :code:`eckit::Configuration` objects.  In short, :code:`LocalConfiguration` objects are local instantiations of :code:`Configuration` objects that you can use to access the configuration file.

Variables, parameters, and other settings in the config file can be read by means of the various :code:`get` methods of the :code:`eckit::Configuration` class.  Paths are relative to the top-level of the YAML/JSON hierarchy that is contained in the Configuration object.  Two examples are shown :ref:`above <config-cpp-seg1>`.  Since the :code:`fullConfig` object contains the entire YAML file, the top level of the hierarchy includes the top-level components of the :ref:`YAML file <yaml-file>`, for example the variables **window begin** and **window length**, as well as the multi-component YAML object **observations**.  The first of these top-level variables is read using the :code:`config.getString()` method and placed into the local variable :code:`winlen`.  One could access other levels of the hierarchy using periods as separators, for example:

.. code-block:: C++

    std::cout << "The nx component of the geometry is: " << fullConfig.getInt("geometry.nx") << std::endl;

If you trace the flow of the :code:`test_qg_hofx` executable, you'll soon come to the heart of oops.  To understand the full structure of this file we refer you to our page on :doc:`Applications in OOPS<../../jedi-components/oops/applications/applications>`.  For our purposes here, we will pick up the action in the :code:`oops::HofX::execute()` and templated :code:`ObsSpaces<OBS>::ObsSpaces` functions, which are called when executing :code:`test_qg_hofx`:

.. _config-cpp-seg2:

.. code-block:: C++

    template <typename OBS>
    ObsSpaces<OBS>::ObsSpaces(const eckit::Configuration & conf, [...]) {

        [...]

        // Example 3
        std::vector<eckit::LocalConfiguration> typeconfs;
        conf.get("observations", typeconfs);

In the Example 3 shown :ref:`above <config-cpp-seg2>`, the :code:`typeconfs` object only contains the **observations** section of the YAML file.  **observations** is itself a vector of configuration objects.  Our example :ref:`YAML file <yaml-file>` includes 2 items in **observations**, namely **obs space.obs type: Wind** and **obs space.obs type: Stream**, and other Applications may include more.  Since **observations** can include multiple components, each declaration in the YAML file is preceded by a dash: :code:`- obs space:` (recall that this indicates a sequence or list in YAML).  So, in order to read this component of the YAML file, :ref:`Example 3 <config-cpp-seg2>` first defines the variable :code:`typeconfs` as a vector of :code:`LocalConfiguration` objects.  Then it uses the :code:`eckit::Configuration::get()` method to read it from the YAML file.

Note another feature of the :code:`Configuration` class highlighted in the examples above.  One uses a specific :code:`getString()` method to retrieve a string, the other uses a generic :code:`get()` interface to retrieve a vector of :code:`LocalConfiguration` objects.  Both options are available.  For further details see the :ref:`Summary of Configuration Methods <config-methods>` below.

The :code:`eckit::Configuration` class also has a few more methods that are extremely useful for querying the configuration file.  The first is :code:`eckit::Configuration::has()` which accepts one string argument (:code:`std::string`) and returns a Boolean :code:`true` or :code:`false` depending on whether or not an item of that name exists in the Configuration file (at the level represented by the Configuration object).  The second is :code:`eckit::Configuration::keys()`, which returns the items at a particular level of the YAML/JSON hierarchy.

As an example of how to use these query functions, we could place the following code after the :ref:`code segment above from the ObsSpaces() function <config-cpp-seg2>`:

.. code-block:: bash

  std::string obstype = typeconfs[0].getString("obs space.obs type");
  std::cout << obstype << " Keys: " << typeconfs[0].keys() << std::endl;
  if(typeconfs[0].has("variables")) {
    std::vector<std::string> vars = typeconfs[0].getStringVector("variables");
    std::cout << obstype << " Variables " << vars << std::endl;
  } else {
    std::cout << obstype << " Warning: Observations variables not specified in config file " << std::endl;
  }
  if(typeconfs[0].has("obs space.obsdataout")) {
    const eckit::LocalConfiguration outconf(typeconfs[0], "obs space.obsdataout");
    std::string outfile = outconf.getString("obsfile");
    std::cout << obstype << " Output file: " << outfile << std::endl;
  } else {
    std::cout << obstype << " Warning: Observations Output not specified in config file " << std::endl;
  }


Given the :ref:`YAML file above <yaml-file>`, the output of this would be:

.. code-block:: bash

    Stream Keys: [obs operator,obs space]
    Stream Warning: Observations variables not specified in config file
    Stream Output file: Data/hofx.obs4d_12h.nc

This example illustrates again the stylistic principle noted :ref:`above <yaml-file>`; YAML/JSON keys are rendered in lower case.

Some JEDI components no longer use :code:`Configuration` objects directly, but instead access information read from configuration files through subclasses of the :code:`Parameters` class. Each such subclass defines member variables corresponding to individual YAML/JSON keys relevant to a given component of JEDI. This approach makes it easier to detect and report errors in input configuration files (for example, misspelled key names, out-of-range values), and its use is likely to become more widespread as JEDI evolves. For more information about :code:`Parameters`, see :doc:`Parameter Classes <parameters>`.

.. _config-methods:

Summary of C++ Configuration Methods
------------------------------------

In this section we summarize some of the most useful public methods available in the :code:`eckit::Configuration` class and, by extension, the :code:`eckit::LocalConfiguration` class.

Available methods for querying the configuration file include:

.. code-block:: C++

    virtual bool has(const std::string &name) const;
    std::vector<std::string> keys() const;

Available methods for reading specific data types include:

.. code-block:: C++

    bool getBool(const std::string &name) const;
    int getInt(const std::string &name) const;
    long getLong(const std::string &name) const;
    std::size_t getUnsigned(const std::string &name) const;
    std::int32_t getInt32(const std::string &name) const;
    std::int64_t getInt64(const std::string &name) const;
    float getFloat(const std::string &name) const;
    double getDouble(const std::string &name) const;
    std::string getString(const std::string &name) const;
    std::vector<int> getIntVector(const std::string &name) const;
    std::vector<long> getLongVector(const std::string &name) const;
    std::vector<std::size_t> getUnsignedVector(const std::string &name) const;
    std::vector<std::int32_t> getInt32Vector(const std::string &name) const;
    std::vector<std::int64_t> getInt64Vector(const std::string &name) const;
    std::vector<float> getFloatVector(const std::string &name) const;
    std::vector<double> getDoubleVector(const std::string &name) const;
    std::vector<std::string> getStringVector(const std::string &name) const;
    LocalConfiguration getSubConfiguration(const std::string &name) const;
    std::vector<LocalConfiguration> getSubConfigurations(const std::string &name) const;


Each of these methods also has a version that accepts a second argument (of the same type as the return value) that will be used as a default value in the event that the item in question is not found in the configuration file.

Available generic interfaces for the :code:`get()` method include:

.. code-block:: C++

    virtual bool get(const std::string &name, std::string &value) const;
    virtual bool get(const std::string &name, bool &value) const;
    virtual bool get(const std::string &name, int &value) const;
    virtual bool get(const std::string &name, long &value) const;
    virtual bool get(const std::string &name, long long &value) const;
    virtual bool get(const std::string &name, std::size_t &value) const;
    virtual bool get(const std::string &name, float &value) const;
    virtual bool get(const std::string &name, double &value) const;
    virtual bool get(const std::string &name, std::vector<int> &value) const;
    virtual bool get(const std::string &name, std::vector<long> &value) const;
    virtual bool get(const std::string &name, std::vector<long long> &value) const;
    virtual bool get(const std::string &name, std::vector<std::size_t> &value) const;
    virtual bool get(const std::string &name, std::vector<float> &value) const;
    virtual bool get(const std::string &name, std::vector<double> &value) const;
    virtual bool get(const std::string &name, std::vector<std::string> &value) const;
    bool get(const std::string &name, std::vector<LocalConfiguration>&) const;
    bool get(const std::string &name, LocalConfiguration&) const;

The Boolean return value reflects whether or not these items are found in the config file.

.. _config-fortran:

Fortran Usage
---------------

ECMWF also offers a Fortran interface to eckit called `fckit <https://github.com/ecmwf/fckit>`_ that provides Fortran interfaces to many of the :code:`eckit::Configuration` methods described in our :ref:`Summary of Configuration Methods <config-methods>` above. The ones used in JEDI are :code:`get_size` and :code:`get_or_die`.

A reference to the :code:`eckit::Configuration` C++ object is required to provide access to the config file as :ref:`described above <config-cpp>` when using Fortran routines.  These, like other interfaces in JEDI, use the intrinsic :code:`ISO_C_BINDING` Fortran module to pass information between C++ and Fortran.   Within this framework, :code:`c_conf` is declared as a pointer of type :code:`c_ptr`, with :code:`value` and :code:`intent(in)` attribute.

As an example of how this C++ configuration is passed to Fortran, we'll consider a code segment from the :code:`qg_geom_setup_c()` routine in the file :code:`qg/model/qg_geom_interface.F90`.  This routine would be called during the execution of the :code:`test_qg_hofx` test that we have been considering throughout this document.  Its function is to set up the Fortran configuration, then call the routine that sets up the Fortran geometry of the model.

.. code-block:: Fortran

    subroutine qg_geom_setup_c(c_key_self,c_conf) bind(c,name='qg_geom_setup_f90')

      ! Passed variables
      integer(c_int),intent(inout) :: c_key_self !< Geometry
      type(c_ptr),value,intent(in) :: c_conf     !< Configuration

      ! Local variables
      type(fckit_configuration) :: f_conf
      type(qg_geom),pointer :: self

      ! Interface
      f_conf = fckit_configuration(c_conf)

      [...]

      ! Call Fortran
      call qg_geom_setup(self,f_conf)

    end subroutine qg_geom_setup_c

One must declare :code:`use iso_c_binding`, which defines :code:`c_ptr` and other data types (in this example, this declaration is done above the lines of code copied here). This then allows to create a fortran configuration object by calling the constructor :code:`f_conf = fckit_configuration(c_conf)`. It is important to notice that the c_conf passed here is a LocalConfiguration object, namely the one we constructed in :ref:`Example 2 by reading the geometry in geometryConfig <config-cpp-seg1>`


We'll now consider a code segment from the :code:`qg_geom_setup()` routine in the file :code:`qg/model/qg_geom_mod.F90`.  Its function is to set up the Fortran counterpart of the C++ :code:`oops::GeometryQG` object that contains the geometry of the model.

.. code-block:: Fortran

    subroutine qg_geom_setup(self,f_conf)

      ! Passed variables
      type(qg_geom),intent(inout) :: self            !< Geometry
      type(fckit_configuration),intent(in) :: f_conf !< FCKIT configuration

      ! Local variables
      [...]
      real(kind_real),allocatable :: real_array(:),depths(:)

      ! Get horizontal resolution data
      call f_conf%get_or_die("nx",self%nx)
      call f_conf%get_or_die("ny",self%ny)
      self%nz = f_conf%get_size("depths")

      allocate(depths(self%nz))
      call f_conf%get_or_die("depths",real_array)
      depths = real_array


Since we are now working with the LocalConfiguration :code:`geometryConfig` and not the :code:`fullConfig`, the keys at the top levels are now **nx**, **ny** and **depths**. So, we can directly request **nx** instead of **geometry.nx**. If needed, the period still acts as a separator that can be used to access any level of the YAML/JSON hierarchy.

The geometry setup routine calls both :code:`get_or_die()` and :code:`get_size()`, to read the data in **nx**, **ny** and **depths**. The function :code:`get_or_die()` allows the direct allocation of parameters such as :code:`self%nx` or :code:`self%ny`. These two parameters are members of the geometry and are declared as integers, so the value read from the keys **nx** and **ny** will be interpreted as an integer. If :code:`self%nx` had been declared as a string, the value read from the key **nx** would be interpreted as a string by :code:`get_or_die()`.

In the case of **depths**, since it is an array we first need to know its size by calling :code:`get_size()`. In the case of our example this would return 2, and the size is immediately used to allocate an array of the proper shape. We can then call :code:`get_or_die()` to fill this array.

We could add the following code segment to the subroutine above to illustrate a few other features of the Fortran configuration interface:

.. code-block:: Fortran

  integer :: ii

  if f_conf%has("levels") then
    call get_or_die("levels", ii)
    write() "The model uses ", ii, " levels"
  else
    write(*,*) "WARNING: The models doesn't use levels"
  endif


Here we see that :code:`eckit::Configuration::has()` returns a Boolean :code:`true` or :code:`false` and that can be used to check if a variable exists in the config file. In our example, the variable doesn't exist and the output is:

.. code-block:: text

    WARNING: The models don't use levels

