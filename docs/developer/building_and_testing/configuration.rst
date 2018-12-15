JEDI Configuration Files
========================

File Format
-------------

Configuration files are files that control the execution of specific applications.  They specify input parameters, control flags, file names, tolerance thresholds, and other configuration details that are used by JEDI to run tests, forecasts, DA, and other applications.

Configuration files for most JEDI tests are located in the :code:`test/testinput` directory of each JEDI repository.  The configuration files in the :code:`ufo`, :code:`ioda`, and :code:`fv3-jedi` repositories are particularly useful as illustrative examples for constructing configuration files in other repositories.

Configuration (often abbreviated as config) files in JEDI may be written either in `YAML <https://yaml.org>`_ or in `JSON <https://www.json.org>`_;  JEDI uses the parser from ECMWF's `eckit library <https://github.com/ecmwf/eckit>`_ to read these files and this parser can process both formats.  However, we recommend using **YAML** because it is generally more user-friendly; YAML is easier to read and, unlike JSON, it allows the user to include comments.

As an example, consider the configuration file for the :code:`test_ufo_radiosonde_opr` unit test (also used for several other tests), which is located in the :code:`ufo` repository as :code:`test/testinput/radiosonde.yaml`:

.. _yaml-file:

.. code:: yaml

    ---
    test_framework_runtime_config: "--log_level=test_suite"
    window_begin: '2018-04-14T21:00:00Z'
    window_end: '2018-04-15T03:00:00Z'
    LinearObsOpTest:
      testiterTL: 12
      toleranceTL: 1.0e-9
      toleranceAD: 1.0e-11
    Observations:
      ObsTypes:
      - ObsType: Radiosonde
        ObsData:
          ObsDataIn:
            obsfile: Data/sondes_obs_2018041500_m.nc4
          ObsDataOut:
            obsfile: Data/sondes_obs_2018041500_m_out.nc4
        variables:
        - air_temperature
        - eastward_wind
        - northward_wind
        GeoVaLs:
          norm: 8471.883687854357
          random: 0
          filename: Data/sondes_geoval_2018041500_m.nc4
          window_begin: '2018-04-14T21:00:00Z'
          window_end: '2018-04-15T03:00:00Z'
        ObsFilters:
        - Filter: Background Check
          variable: air_temperature
          threshold: 3.0
        rmsequiv: 118.81431
        tolerance: 1.0e-03  # in % so that corresponds to 10^-5
        ObsBias: {}

We refer the user to the `YAML Documentation <https://yaml.org/spec/1.2/spec.html>`_ for a comprehensive description of the syntax but we'll give a brief overview here.

The first thing to note is that indentation matters.  Items are organized into a heirarchy, with the top-level objects beginning in the leftmost column and subsidiary components of these objects indented accordingly.  The number of spaces is not important; two is sufficient to define the scope of an item and its contents.

The beginning of a YAML document is indicated by three dashes :code:`---`, which may or may not be preceded by directives.  Each line typically contains a key-value pair separated by a colon and a space.  The key is generally a string and the value may be either a string or a number.  This is used to assign values to variables.  For example, the **window_begin** object is set to a value of '2018-04-14T21:00:00Z' and the **LinearObsOpTest.toleranceTL** variable is set to a value of 1.0e-9.  Note that we have used a period to represent the heirarchy of items; **toleranceTL** is a component of **LinearObsOpTest**.  Note also that the values may be interpreted in different ways.  For example, the **window_begin** value is written as a string in the yaml file but it is interpreted as a :code:`util::DateTime` object when it is read into JEDI.

Objects with muliple values (sequences in YAML) are indicated as indended lists with one item per line and each item delineated by a dash.  For example, **Observations.ObsTypes.Radiosonde.variables** is equated to a list of items, namely ["air_temperature", "eastward_wind", "northward_wind"].  Comments are preceded by a :code:`#` sign as seen for **Observations.ObsTypes.Radiosonde.tolerance**.

Lists or sequences may also be identified with brackets :code:`{}`.  This is illustrated in the above file with the example of **Observations.ObsTypes.Radiosonde.ObsBias**, which is here identified as a list, albeit an empty one.

.. _config-cpp:

C++ Usage
-----------

As noted in the previous section, JEDI configuration files are read by means of the `eckit C++ library <https://github.com/ecmwf/eckit>`_ developed and distributed by the European Centre for Medium Range Weather Forecasting (ECMWF).  ECMWF also offers a Fortran interface to eckit called `fckit <https://github.com/ecmwf/fckit>`_ that we will discuss :ref:`below <config-fortran>`.

Configuration files are read into JEDI as :code:`eckit::Configuration` objects.  More specifically, :code:`eckit::Configuration` is the base class that is often accessed through its derived classes :code:`eckit::LocalConfiguration` and :code:`eckit::YAMLConfiguration`.  All of these classes are defined in the :code:`src/eckit/config` directory of the  `eckit repository <https://github.com/ecmwf/eckit>`_.

As described in our document on :doc:`JEDI Testing <unit_testing>` (see :ref:`Tests as Applications <test-apps>` in particular), JEDI applications are executed by passing an :code:`oops::Application` object to the :code:`execute()` method of an :code:`oops::Run` object.  The name of the configuration file (including path) is generally specified on the command line when running a JEDI executable and this file name is passed to the constructor of the :code:`oops::Run` object.  There is it used to create an :code:`eckit::Configuration` object which is passed to the Application when it is executed.  The :code:`eckit::Configuration` class containes a number of public methods that can be then used to query the config file and access its contents.

To illustrate how this works, let's return to our :code:`test_ufo_radiosonde_opr` example introduced in the previous section.  The configuration file for that test is called :code:`test/testinput/radiosonde.yaml`.  In this example, our Application happens to be a Test object since :code:`oops::Test` is a subclass (child) of :code:`oops:Application`.  So, the configuration file is passed from the command line to the :code:`oops::Run` object and then to the Application as an argument (of type :code:`eckit::Configuration`) to the :code:`oops::Test::execute()` method.  This general approach is similar to other Applications.

What happens next is more specific to the Test Application but it serves to illustrate how to manipulate and access the config file as an :code:`eckit::Configuration` object.  Here is a code segment from the :code:`oops::Test::execute()` method as defined in the :code:`oops/src/oops/runs/Test.h` file: 

.. _config-cpp-seg1:

.. code:: c++

    int Test::execute(const eckit::Configuration & config) const {

    // Setup configuration for tests
      test::TestEnvironment::getInstance().setup(config);

    // Extract the runtime config for the tests from the config file.
      std::string args = config.getString("test_framework_runtime_config");

    [...]

Here the Configuration object that is passed as an argument (config) is used to create and initialize a :code:`TestEnvironment` object.  This is used later to facilitate access to the config file for the test suite as we will see below.  However, the config file can also be accessed directly through the public methods of the :code:`eckit::Configuration` object itself.  This is demonstrated by the :code:`config.getString()` example :ref:`above <config-cpp-seg1>`.  This sets the string variable :code:`args` equal to the value of :code:`--log_level=test_suite` as specified in the first line of the :ref:`YAML file <yaml-file>`.

If you trace the flow of the :code:`test_radiosonde_opr` executable, you'll soon come to the heart of the test suite, which is defined in :code:`oops/src/test/interface/ObsOperator.h`.  To understand the full structure of this file we refer you to our page on :doc:`JEDI Testing <unit_testing>`.  For our purposes here, we will pick up the action in the :code:`test::testSimulateObs()` function template, which is one of the tests called by :code:`test_ufo_radiosonde_opr`:

.. _config-cpp-seg2:

.. code:: c++

    template <typename MODEL> void testSimulateObs() {

        [...]

        const eckit::LocalConfiguration obsconf(TestEnvironment::config(), "Observations");
        std::vector<eckit::LocalConfiguration> conf;
        obsconf.get("ObsTypes", conf);	  

This illustrates an important point, namely that new configuration objects are constructed through the derived (child) class of :code:`eckit::LocalConfiguration` rather than the base class of :code:`eckit::Configuration` (whose constructors are protected).  The constructor shown here takes two arguments.  The first is the output of the :code:`TestEnvironment::config()` method.  This returns a copy of the Configuration object that was used to create and initialize the :code:`test::TestEnvironment` object itself, as shown :ref:`above <config-cpp-seg1>`.  The second argument is a string that serves to extract a component of that Configuration, in particular, everything contained under the **Observations** section of the :ref:`YAML file <yaml-file>`.  This component is placed in the **LocalConfiguration** object **obsconf**. 

YAML and JSON objects are heirarchical and self-similar.  So, the **Observations** component of the YAML file can be treated as a self-contained YAML object in its own right, with its own components.  Configuration objects are the same way.  One can define an :code:`eckit::Configuration` object that includes the contents of the entire YAML file, as is the case for :code:`TestEnvironment::config()`, or one can define an :code:`eckit::Configuration` object that contains only a particular component of the top-level YAML structure, as is the case for :code:`obsconf`.  Remember that **LocalConfiguration** objects *are* **Configuration** objects since the former is a child (derived class) of the latter.

It's tempting to think of **LocalConfiguration** objects as components of **Configuration** objects but this is incorrect.  One could in principle have an :code:`eckit::LocalConfiguration` object refer to the YAML file as a whole and a :code:`eckit::Configuration` object refer to a single section, though this is rarely done.  The **Local** in **LocalConfiguration** refers to a local component of the JEDI code, not a local section of the YAML file.  You can create, access, and even change :code:`eckit::LocalConfiguration` objects in a way that is not possible with :code:`eckit::Configuration` objects.  In short, **LocalConfiguration** objects are local instantiations of **Configuration** objects that you can use to access the configuration file.

Variables, parameters, and other settings in the config file can be read by means of the various **get()** methods of the :code:`eckit::Configuration` class.  This is typically done for the top-level of the YAML/JSON heirarchy that is contained in the Configuration object.  Two examples are shown :ref:`above <config-cpp-seg1>`.  Since the :code:`TestEnvironment::config()` object contains the entire YAML file, the top level of the heirarchy includes the top-level components of the :ref:`YAML file <yaml-file>`, namely the variables **test_framework_runtime_config**, **window_begin**, and **window_end**, as well as the multi-component YAML objects **LinearObsOpTest** and **Observations**.  The first of these top-level variables is read using the :code:`config.getString()` method and placed into the local variable :code:`args`.

In the second example shown :ref:`above <config-cpp-seg2>`, the :code:`obsconf` object only contains the **Observations** section of the YAML file.  At the top level of this section is **ObsTypes**, which is itself a vector of configuration objects.  Our example :ref:`YAML file <yaml-file>` only includes one item in **ObsTypes**, namely **Radiosonde**, but other Applications may include more.  Since **ObsTypes** can include multiple components, the **ObsType: Radiosonde** declaration in the YAML file is preceded by a dash: :code:`- ObsType: Radiosonde` (recall that this indicates a sequence or list in YAML).  So, in order to read this component of the YAML file, :ref:`the second code segment above <config-cpp-seg2>` first defines the variable **conf** as a vector of **LocalConfiguration** objects.  Then it uses the :code:`eckit::Configuration::get()` method to read it from the YAML file.

Note another feature of the Configuration class highlighted in the two examples above.  One uses a specific **getString()** method to retrieve a string, the other uses a generic **get()** interface to retrieve a vector of **LocalConfiguration** objects.  Both options are available.  For further details see the :ref:`Summary of Configuration Methods <config-methods>` below.

The :code:`eckit::Configuration` class also has a few more methods that are extremely useful for querying the configuration file.  The first is **has()**, which accepts one string argument (:code:`std::string`) and returns a Boolean :code:`true` or :code:`false` depending on whether or not an item of that name exists in the Configuration file (at the level represented by the Configuration object).  The second is **keys()**, which returns the items at a particular level of the YAML/JSON heirarchy.

.. MSM: Include an example here of how to use has() and keys() in the testSimulateObs() function

.. _config-methods:

Summary of Configuration Methods
---------------------------------

In this section we summarize some of the most useful public methods available in the :code:`eckit::Configuration` class and, by extension, the :code:`eckit::LocalConfiguration` class.

Available methods for querying the configuration file include:

.. code:: c++

    virtual bool has(const std::string &name) const;
    std::vector<std::string> keys() const;	  

Available methods for reading specific data types include:

.. code:: c++

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

.. code:: c++

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

`fckit <https://github.com/ecmwf/fckit>`_ offers much of the same functionality for accessing configuration files and objects as eckit.  It accomplishes this by means of Fortran interfaces to public C++ methods of :code:`eckit::Configuration` and :code:`eckit::LocalConfiguration` objects.

