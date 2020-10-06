JEDI Configuration Files: Implementation
========================================

This document describes the practical implementation of JEDI configuration files, including how users can create and read them.  For an overview what these files contain see :doc:`JEDI Configuration Files: Content <config_content>`.

.. _config-format:

File Format
-----------

Configuration files are files that control the execution of specific applications.  They specify input parameters, control flags, file names, tolerance thresholds, and other configuration details that are used by JEDI to run tests, forecasts, DA, and other applications.

Configuration files for most JEDI tests are located in the :code:`test/testinput` directory of each JEDI repository.  The configuration files in the :code:`ufo`, :code:`ioda`, and :code:`fv3-jedi` repositories are particularly useful as illustrative examples for constructing configuration files in other repositories.

Configuration (often abbreviated as config) files in JEDI may be written either in `YAML <https://yaml.org>`_ or in `JSON <https://www.json.org>`_;  JEDI uses the parser from ECMWF's `eckit library <https://github.com/ecmwf/eckit>`_ to read these files and this parser can process both formats.  However, we recommend using **YAML** because it is generally more user-friendly; YAML is easier to read and, unlike JSON, it allows the user to include comments.  YAML files can end with the extension :code:`.yaml` or :code:`.yml`.  JSON files typically end with the extension :code:`.json`.

As an example, consider a configuration file similar to the one used in the :code:`test_qg_hofx` unit test, which is located in the :code:`oops` repository as :code:`qg/test/testinput/hofx.yaml`:

.. _yaml-file:

.. code:: yaml

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
        obsdatain:
          obsfile: Data/truth.obs4d_12h.nc
        obsdataout:
          obsfile: Data/hofx.obs4d_12h.nc
        obs type: Stream
      obs operator:
        obs type: Stream
      obs bias: {}
    - obs space:
        obsdatain:
          obsfile: Data/truth.obs4d_12h.nc
        obsdataout:
          obsfile: Data/hofx.obs4d_12h.nc
        obs type: Wind
      obs operator:
        obs type: Wind


Note that keys representing objects (single variables, vectors or more complex objects) are represented as lower case and entire words.  This is the preferred style but it is not currently followed by all JEDI repositories.

We refer the user to the `YAML Documentation <https://yaml.org/spec/1.2/spec.html>`_ for a comprehensive description of the syntax but we'll give a brief overview here.

The first thing to note is that indentation matters.  Items are organized into a hierarchy, with the top-level objects beginning in the leftmost column and subsidiary components of these objects indented accordingly.  The number of spaces is not important; two is sufficient to define the scope of an item and its contents.

The beginning of a YAML document can be indicated by three dashes :code:`---`, which may or may not be preceded by directives. Each line typically contains a key-value pair separated by a colon and a space.  The key is generally a string and the value may be either a string or a number.  This is used to assign values to variables.  For example, the **window begin** object is set to a value of '2010-01-01T00:00:00Z' and the **geometry.nx** variable is set to a value of 40.  Note that we have used a period to represent the hierarchy of items; **nx** is a component of **geometry**.  Note also that the values may be interpreted in different ways.  For example, the **window begin** value is written as a string in the yaml file but it is interpreted as a :code:`util::DateTime` object when it is read into JEDI.

Objects with multiple values (sequences in YAML) are indicated as indented lists with one item per line and each item delineated by a dash.  For example, **observations[0].obs space.simulated variables** is equated to a list of items, namely ["air_temperature", "eastward_wind", "northward_wind"].

Lists or sequences may also be identified with brackets :code:`{}` or :code:`[]`.  This is illustrated in the above file with the examples of **geometry.depths**, which is a is here identified as a list of floats, and **observations[0].obs bias**, an empty list.

Comments are preceded by a :code:`#` sign as seen for **geometry.depths**.

.. _config-cpp:

C++ Usage
---------

As noted in the previous section, JEDI configuration files are read by means of the `eckit C++ library <https://github.com/ecmwf/eckit>`_ developed and distributed by the European Centre for Medium Range Weather Forecasting (ECMWF).

Configuration files are read into JEDI as :code:`eckit::Configuration` objects.  More specifically, :code:`eckit::Configuration` is the base class that is often accessed through its derived classes :code:`eckit::LocalConfiguration` and :code:`eckit::YAMLConfiguration`.  All of these classes are defined in the :code:`src/eckit/config` directory of the  `eckit repository <https://github.com/ecmwf/eckit>`_.

As described in our document on :doc:`JEDI Testing <unit_testing>` (see :ref:`Tests as Applications <test-apps>` in particular), JEDI applications are executed by passing an :code:`oops::Application` object to the :code:`execute()` method of an :code:`oops::Run` object.  The name of the configuration file (including path) is generally specified on the command line when running a JEDI executable and this file name is passed to the constructor of the :code:`oops::Run` object.  There is it used to create an :code:`eckit::Configuration` object which is passed to the Application when it is executed.  The :code:`eckit::Configuration` class contains a number of public methods that can be then used to query the config file and access its contents.

To illustrate how this works, let's return to our :code:`test_qg_hofx` example introduced in the previous section.  The configuration file for that test is called :code:`qg/test/testinput/hofx.yaml`.  In this example, our Application happens to be a HofX object since :code:`oops::HofX` is a subclass (child) of :code:`oops:Application`.  So, the configuration file is passed from the command line to the :code:`oops::Run` object and then to the Application as an argument (of type :code:`eckit::Configuration`) to the :code:`oops::Test::execute()` method.  This general approach is similar to other Applications.

What happens next is more specific to the HofX Application but it serves to illustrate how to manipulate and access the config file as an :code:`eckit::Configuration` object.  Here is a example code segment from the :code:`oops::HofX::execute()` method as defined in the :code:`oops/src/oops/runs/HofX.h` file:

.. _config-cpp-seg1:

.. code:: C++

    int Test::execute(const eckit::Configuration & config) const {

    // Setup configuration for tests
      test::TestEnvironment::getInstance().setup(config);

    // If you need to extract some information from the config file
      std::string args = config.getString("window begin");

    [...]

Here the Configuration object that is passed as an argument (config) is used to create and initialize a :code:`TestEnvironment` object.  This is used later to facilitate access to the config file for the test suite as we will see below.  However, the config file can also be accessed directly through the public methods of the :code:`eckit::Configuration` object itself.  This is demonstrated by the :code:`config.getString()` example :ref:`above <config-cpp-seg1>`.  This sets the string variable :code:`args` equal to the value of :code:`window begin` as specified in the first line of the :ref:`YAML file <yaml-file>`.

If you trace the flow of the :code:`test_radiosonde_opr` executable, you'll soon come to the heart of the test suite, which is defined in :code:`oops/src/test/interface/ObsOperator.h`.  To understand the full structure of this file we refer you to our page on :doc:`JEDI Testing <unit_testing>`.  For our purposes here, we will pick up the action in the :code:`test::testSimulateObs()` function template, which is one of the tests called by :code:`test_ufo_radiosonde_opr`:

.. _config-cpp-seg2:

.. code:: C++

    template <typename MODEL> void testSimulateObs() {

        [...]
        // Example 1
        const eckit::LocalConfiguration obsconf(TestEnvironment::config(), "observations");

        // Example 2
        std::vector<eckit::LocalConfiguration> conf;
        TestEnvironment::config().get("observations", conf);


This illustrates an important point, namely that new configuration objects are constructed through the derived (child) class of :code:`eckit::LocalConfiguration` rather than the base class of :code:`eckit::Configuration` (whose constructors are protected).  The constructor shown in example 1 takes two arguments.  The first is the output of the :code:`TestEnvironment::config()` method.  This returns a copy of the Configuration object that was used to create and initialize the :code:`test::TestEnvironment` object itself, as shown :ref:`above <config-cpp-seg1>`.  The second argument is a string that serves to extract a component of that Configuration, in particular, everything contained under the **observations** section of the :ref:`YAML file <yaml-file>`.  This component is placed in the **LocalConfiguration** object **obsconf**.

YAML and JSON objects are hierarchical and self-similar.  So, the **observations** component of the YAML file can be treated as a self-contained YAML object in its own right, with its own components.  Configuration objects are the same way.  One can define an :code:`eckit::Configuration` object that includes the contents of the entire YAML file, as is the case for :code:`TestEnvironment::config()`, or one can define an :code:`eckit::Configuration` object that contains only a particular component of the top-level YAML structure, as is the case for :code:`obsconf`.  Remember that **LocalConfiguration** objects *are* **Configuration** objects since the former is a child (derived class) of the latter.

It's tempting to think of **LocalConfiguration** objects as components of **Configuration** objects but this is incorrect.  One could in principle have an :code:`eckit::LocalConfiguration` object refer to the YAML file as a whole and a :code:`eckit::Configuration` object refer to a single section, though this is rarely done.  The **Local** in **LocalConfiguration** refers to a local component of the JEDI code, not a local section of the YAML file.  You can create, access, and even change :code:`eckit::LocalConfiguration` objects in a way that is not possible with :code:`eckit::Configuration` objects.  In short, **LocalConfiguration** objects are local instantiations of **Configuration** objects that you can use to access the configuration file.

Variables, parameters, and other settings in the config file can be read by means of the various **get()** methods of the :code:`eckit::Configuration` class.  Paths are relative to the top-level of the YAML/JSON hierarchy that is contained in the Configuration object.  Two examples are shown :ref:`above <config-cpp-seg1>`.  Since the :code:`TestEnvironment::config()` object contains the entire YAML file, the top level of the hierarchy includes the top-level components of the :ref:`YAML file <yaml-file>`, namely the variables **window_begin** and **window_end**, as well as the multi-component YAML object **observations**.  The first of these top-level variables is read using the :code:`config.getString()` method and placed into the local variable :code:`args`.  One could access other levels of the hierarchy using periods as separators, for example:

.. code:: C++

    std::cout << "The TL tolerance is: " << TestEnvironment::config().getDouble("linear obs operator test.tolerance TL") << std::endl;

In the second example shown :ref:`above <config-cpp-seg2>`, the :code:`obsconf` object only contains the **observations** section of the YAML file.  At the top level of this section is **ObsTypes**, which is itself a vector of configuration objects.  Our example :ref:`YAML file <yaml-file>` only includes one item in **ObsTypes**, namely **Radiosonde**, but other Applications may include more.  Since **ObsTypes** can include multiple components, the **ObsType: Radiosonde** declaration in the YAML file is preceded by a dash: :code:`- ObsType: Radiosonde` (recall that this indicates a sequence or list in YAML).  So, in order to read this component of the YAML file, :ref:`the second code segment above <config-cpp-seg2>` first defines the variable **conf** as a vector of **LocalConfiguration** objects.  Then it uses the :code:`eckit::Configuration::get()` method to read it from the YAML file.

Note another feature of the Configuration class highlighted in the two examples above.  One uses a specific **getString()** method to retrieve a string, the other uses a generic **get()** interface to retrieve a vector of **LocalConfiguration** objects.  Both options are available.  For further details see the :ref:`Summary of Configuration Methods <config-methods>` below.

The :code:`eckit::Configuration` class also has a few more methods that are extremely useful for querying the configuration file.  The first is **has()**, which accepts one string argument (:code:`std::string`) and returns a Boolean :code:`true` or :code:`false` depending on whether or not an item of that name exists in the Configuration file (at the level represented by the Configuration object).  The second is **keys()**, which returns the items at a particular level of the YAML/JSON hierarchy.

As an example of how to use these query functions, we could place the following code after the :ref:`code segment above from the testSimulateObs() function <config-cpp-seg2>`:

.. code:: bash

  std::string obstype = conf[0].getString("ObsType");
  std::cout << obstype << " Keys: " << conf[0].keys() << std::endl;
  if(conf[0].has("variables")) {
    std::vector<std::string> vars = conf[0].getStringVector("variables");
    std::cout << obstype << " Variables " << vars << std::endl;
  } else {
    std::cout << obstype << " Warning: Observations variables not specified in config file " << std::endl;
  }
  if(conf[0].has("Output")) {
    const eckit::LocalConfiguration outconf(conf[0], "Output");
    std::string outfile = outconf.getString("filename");
    std::cout << obstype << " Output file: " << outfile << std::endl;
  } else {
    std::cout << obstype << " Warning: Observations Output not specified in config file " << std::endl;
  }


Given the :ref:`YAML file above <yaml-file>`, the output of this would be:

.. code:: bash

    Radiosonde Keys: [GeoVaLs,ObsBias,ObsData,ObsFilters,ObsType,rmsequiv,tolerance,variables]
    Radiosonde Variables: [air_temperature,eastward_wind,northward_wind]
    Radiosonde Warning: Observations Output not specified in config file

This example illustrates again the stylistic principle noted :ref:`above <yaml-file>`; YAML/JSON keys that represent single variables or vectors are rendered in lower case while those that represent configuration objects in their own right are rendered in `CamelCase <https://en.wikipedia.org/wiki/Camel_case>`_.

.. _config-methods:

Summary of C++ Configuration Methods
------------------------------------

In this section we summarize some of the most useful public methods available in the :code:`eckit::Configuration` class and, by extension, the :code:`eckit::LocalConfiguration` class.

Available methods for querying the configuration file include:

.. code:: C++

    virtual bool has(const std::string &name) const;
    std::vector<std::string> keys() const;

Available methods for reading specific data types include:

.. code:: C++

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

Available generic interfaces for the **get()** method include:

.. code:: C++

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

ECMWF also offers a Fortran interface to eckit called `fckit <https://github.com/ecmwf/fckit>`_ that provides Fortran interfaces to many of the :code:`eckit::Configuration` methods described in our :ref:`Summary of Configuration Methods <config-methods>` above.

However, JEDI does not currently use these fckit interfaces for accessing config files.  Instead, JEDI defines its own Fortran interfaces to C++ :code:`oops::Configuration` objects.  These are defined in the file :code:`oops/src/oops/util/config_mod.F90` and they currently include the following Fortran subroutines:

.. code:: Fortran

    logical function config_element_exists(c_dom,query)
    integer function config_get_int(c_dom,query,idefault)
    real(kind=kind_real) function config_get_real(c_dom,query,rdefault)
    function config_get_string(c_dom,length,query,sdefault)
    function config_get_string_vector(c_dom, length, query)

The first argument in each of these routines (:code:`c_dom`) is a pointer to the :code:`eckit::Configuration` object in C++ that provides access to the config file as :ref:`described above <config-cpp>`.  These, like other interfaces in JEDI, use the intrinsic :code:`ISO_C_BINDING` Fortran module to pass information between C++ and Fortran.   Within this framework, :code:`c_dom` is declared as a pointer of type :code:`c_ptr`, with an :code:`intent(in)` attribute.

The :code:`query` argument in the subroutines above is the name of the variable one wishes to retrieve from the config file (rendered as type :code:`character(*)`).  The :code:`config_get_real()`, :code:`config_get_int()`, and :code:`config_get_string()` routines also include an optional default value to be used if the variable in question is not found in the config file. The two string functions also require the user to specify the length of the string to retrieve, which is passed as an integer :code:`length` argument.  In the case of the string vector, this refers to the length (number of characters) of each element of the vector; the number of elements is determined automatically by querying the config file.

As an example of how these Fortran interfaces are used, we'll consider a code segment from the :code:`atmprofile_setup_()` routine in the file :code:`ufo/src/ufo/atmosphere/atmprofile/ufo_atmprofile_mod.F90`.  This routine is called during the execution of the :code:`test_ufo_radiosonde_opr` test that we have been considering throughout this document.  It's function is to set up the Fortran counterpart of the C++ :code:`ufo::ObsAtmProfile` object that contains the Radiosonde observation operator.

.. code:: Fortran

    subroutine atmprofile_setup_(self, c_conf)
      use config_mod
      implicit none
      class(ufo_atmprofile), intent(inout) :: self
      type(c_ptr), intent(in)    :: c_conf

      integer :: ii

      !> Size of variables
      self%nvars = size(config_get_string_vector(c_conf, max_string, "variables"))
      !> Allocate varout: variables in the observation vector
      allocate(self%varout(self%nvars))
      !> Read variable list and store in varout
      self%varout = config_get_string_vector(c_conf, max_string, "variables")

      [...]


The first thing to note is that this routine uses the :code:`config_mod` module in oops, which contains the configuration interface, as described above.  One must also :code:`use iso_c_binding`, which defines :code:`c_ptr` and other data types (in this example, this declaration is done at the :code:`ufo_atmprofile_mod` module level).

The setup routine then calls :code:`config_get_string_vector()` twice; once to determine the number of variables listed in the config file and a second time to actually read the data.  The first call is used to allocate the Fortran string vector that will contain the data.  The length of each string buffer is set equal to the parameter :code:`max_string`, which is also defined in the :code:`config_mod` module.

Note that the various :code:`config_get*()` routines retrieve data relative to the the top level of the :code:`eckit::Configuration` object referred to by :code:`c_conf`.  As discussed :ref:`above <config-cpp>`, each section of the YAML or JSON file can be rendered as self-contained :code:`eckit::Configuration` object and the appropriate section of the config file is generally extracted in C++ and passed to the Fortran routines.  In this example, the :code:`c_conf` pointer points to the :code:`ObsType: Radiosonde` section of the :ref:`YAML file <yaml-file>`, as defined by the :code:`conf[0]` object in :ref:`the testSimulateObs() code segment above <config-cpp-seg2>`.

We could add the following code segment to the subroutine above to illustrate a few other features of the Fortran configuration interface:

.. code:: Fortran

  if (config_element_exists(c_conf,"GeoVaLs")) then
     write(*,*) "Radiosonde GeoVaLs Norm = ",config_get_real(c_conf,"GeoVaLs.norm",1.0_kind_real)
  endif

Here we see that :code:`config_element_exists()` is an interface to the :code:`eckit::Configuration::has()` method discussed :ref:`above <config-cpp>` that returns a Boolean :code:`true` or :code:`false` and that can be used to check if a variable exists in the config file.  Furthermore, the period acts as a separator that can be used to access any level of the YAML/JSON hierarchy that is at or below the level defined by :code:`c_conf`.  Here we use it to access the :code:`norm` element of the :code:`Observations.ObsTypes[0].GeoVaLs.norm` item of the :ref:`original YAML file <yaml-file>`.  We also included a default value of unity to be used if the :code:`config_get_real()` routine failed to find this variable in the config file.  But, in our example, the variable exists and the output is:

.. code:: bash

    Radiosonde GeoVaLs Norm =    8471.8836878543570
