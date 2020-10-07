.. _Parameter-classes:

Parameter Classes
=================

.. _parameters-introduction:

Introduction
------------

Traditionally, code retrieving the values of options controlling the behavior of JEDI components from a configuration file has been written in an imperative style, making a series of calls to methods of the :code:`eckit::Configuration` class. For example, the geometry of a model defined on a (very coarse) lat-lon grid could be configured with the following section of a YAML file:

.. code:: yaml

    geometry:
      num lats: 5
      num lons: 10
      level altitudes in km: {0.5, 1, 2, 4, 8, 16}

and the implementation of the OOPS :code:`Geometry` interface for that model could retrieve the values of these options as follows:

.. code:: c++

    MyGeometry::MyGeometry(const eckit::Configuration &config, 
                           const eckit::mpi::Comm & comm) {
      int numLats = config.getInt("num lats");
      int numLons = config.getInt("num lons");
      std::vector<float> levels = config.getFloatVector("level altitudes in km");
      // ...
    }

An alternative, more declarative approach is now possible, in which the supported options are listed as member variables of a subclass of the :code:`Parameters` class. The values of all these options are then loaded from a :code:`Configuration` object into an instance of that subclass in single function call. This has the following advantages:

* It makes it easy to find the full list of parameters accepted by a given JEDI component, including their name, type, default value (if any) and accompanying documentation.

* It reduces code duplication (code using the :code:`eckit::Configuration` interface to build instances of specific complex types, such as :code:`util::DateTime` or :code:`std::map`, needs to be written only once).

* Most importantly, it makes it possible for errors in the configuration file (for example misspelled names of optional parameters, parameter values lying outside a specified range, and incorrect parameter value types) to be detected early (potentially even before a JEDI application is run, as described :ref:`below <validation>`) and their location pinpointed accurately. 

For example, the options recognized by :code:`MyGeometry` could be encapsulated in the following subclass of :code:`Parameters`:

.. code:: c++

  #include "oops/util/parameters/RequiredParameter.h"
  #include "oops/util/parameters/Parameters.h"
  
  /// \brief Parameters controlling my model's grid geometry.
  class MyGeometryParameters : public oops::Parameters {
    OOPS_CONCRETE_PARAMETERS(MyGeometryParameters, Parameters)
  public:
    /// \brief Grid size in the north-south direction.
    oops::RequiredParameter<int> numLats{"num lats", this};

    /// \brief Grid size in the east-west direction.
    oops::RequiredParameter<int> numLons{"num lons", this};

    /// \brief List of model level altitudes (in km).
    oops::RequiredParameter<std::vector<float>> levelAltitudesInKm{"level altitudes in km", this};
  };
  

Note that:

* In the above example, all member variables are initialized with the C++11 default member initializer syntax (this is not strictly necessary, but very convenient).

* The first argument passed to the constructor of each :code:`RequiredParameter` object is the name of the key in the YAML key/value pair from which that parameter's value will be extracted.

* The second argument is the address of the :code:`Parameters` object holding all the individual parameters.

* The parameter of the :code:`RequiredParameter` template indicates the type of the values that can be assigned to that parameter.

* The class definition begins with an invocation of the :code:`OOPS_CONCRETE_PARAMETERS` macro, which defines the move and copy constructors and assignment operators and the :code:`clone()` method in an appropriate way. The first argument to the macro must be the name of the surrounding class and the second, the name of its immediate base class. This macro should be invoked in each concrete subclass of :code:`Parameters` (otherwise a compilation error will occur).

  Abstract subclasses of :code:`Parameters` (those that don't need to be instantiated directly, but only serve as base classes for other classes) should invoke the :code:`OOPS_ABSTRACT_PARAMETERS` macro instead of :code:`OOPS_CONCRETE_PARAMETERS`.

The :code:`validateAndDeserialize()` method loads parameter values from a :code:`Configuration` object into a :code:`Parameters` object:

.. code:: c++

  MyGeometry::MyGeometry(const eckit::Configuration &config, 
                         const eckit::mpi::Comm & comm) {
    MyGeometryParameters params;
    params.validateAndDeserialize(config);
    // ...
  }

Since all parameters have been declared as *required*, this method will thrown an exception if any of them cannot be found in the :code:`Configuration` object. It is also possible to treat parameters as optional; this is discussed :ref:`below <optional-parameters>`.

The loaded values can be accessed by calling the :code:`value()` method of the :code:`RequiredParameter` object. In most circumstances you can also use a :code:`RequiredParameter` object as if it was the parameter value itself (omitting the call to :code:`value()`), since the :code:`RequiredParameter<T>` class template overloads the conversion operator to :code:`const T&`. So the two following snippets are equivalent:

.. code:: c++

  for (int i = 0; i < params.numLats.value(); ++i) {
    processZonalBand(i);
  }

and 

.. code:: c++

  for (int i = 0; i < params.numLats; ++i) {
    processZonalBand(i);
  }

Parameter Nesting
-----------------

In the preceding example, we have already seen that parameters can store not only values of "primitive" types (e.g. :code:`int`), but also more complex objects, such as vectors. Other supported types include strings, maps, dates, durations, and instances of :code:`oops::Variables` and :code:`ufo::Variable`. It is also possible to nest parameters, i.e. store a subclass of :code:`Parameters` in a :code:`Parameter` object. For example, to load the following YAML snippet:

.. code:: yaml

  latitudes:
    min: 30
    max: 60
  longitudes:
    min: 20
    max: 30
  
one could use the following code:

.. code:: c++

  class RangeParameters : public oops::Parameters {
    OOPS_CONCRETE_PARAMETERS(RangeParameters, Parameters)
   public:
    oops::RequiredParameter<float> min{"min", this};
    oops::RequiredParameter<float> max{"max", this};
  };
  
  class LatLonRangeParameters : public oops::Parameters {
    OOPS_CONCRETE_PARAMETERS(LatLonRangeParameters, Parameters)
   public:
    oops::RequiredParameter<RangeParameters> latitudes{"latitudes", this};
    oops::RequiredParameter<RangeParameters> longitudes{"longitudes", this};
  };

To load parameter values from a :code:`eckit::Configuration` object, it would be enough to call the :code:`validateAndDeserialize()` method of the top-level :code:`Parameters` object, i.e. in this case an instance of :code:`LatLonRangeParameters`.

.. _optional-parameters:

Optional Parameters
-------------------

Not all parameters are required; some are optional. There are two distinct scenarios:

- If the parameter's value is not specified in the configuration file, a default value is assumed. Such parameters are represented by instances of the :code:`Parameter` class template, with the default value passed to the second parameter of its constructor.

- The parameter can be omitted from the configuration file, but its absence must be detected and handled specially. This is what the :code:`OptionalParameter<T>` class template is for: instead of a value of type :code:`T` it stores a value of type :code:`boost::optional<T>`. This value is set to :code:`boost::none` if no key matching the parameter's name is found in the :code:`Configuration` object provided to the :code:`validateAndDeserialize()` function.

As an example, a thinning filter might allow the user to optionally specify a variable storing observation priorities (with observations of higher priority more likely to be retained than those of lower priority). To this end, the name of that variable could be stored in an :code:`OptionalParameter<ufo::Variable>` object. On the other hand, the maximum number of observations to be retained could be stored in an instance of :code:`Parameter<int>` if we wanted to provide a default:

.. code:: c++
  
  #include "oops/util/parameters/OptionalParameter.h"
  #include "oops/util/parameters/Parameters.h"
  #include "oops/util/parameters/Parameter.h"
  #include "ufo/utils/parameters/ParameterTraitsVariable.h"

  class MyFilterParameters : public oops::Parameters {
    OOPS_CONCRETE_PARAMETERS(MyFilterParameters, Parameters)
   public:
    oops::OptionalParameter<ufo::Variable> priorityVariable{"priority variable", this};
    oops::Parameter<int> maxNumRetainedObs{"max num retained obs", 10000, this};
  };

The :code:`priorityVariable` parameter would be used like this (assuming that :code:`parameters_` is an instance of :code:`MyFilterParameters` and :code:`obsdb_` an instance of :code:`ioda::ObsSpace`):

.. code:: c++
  
  // All observations have equal priorities...
  std::vector<int> priorities(obsdb_.nlocs(), 0);
  if (parameters_.priorityVariable.value() != boost::none) {
    // ... unless a priority variable has been specified.
    const ufo::Variable& var = *parameters_.priorityVariable.value();
    obsdb_.get_db(var.group(), var.variable(), priorities);
  }

Constraints
-----------

It is possible to restrict the allowed values of :code:`Parameter`, :code:`OptionalParameter` and :code:`RequiredParameter` objects by passing a vector of one or more shared pointers to constant :code:`ParameterConstraint` objects to their constructor. For convenience, functions returning shared pointers to new instances of subclasses of :code:`ParameterConstraint` representing particular constraint types have been defined. For example, the code below constrains the :code:`iterations` parameter to be positive:

.. code:: c++

  #include "oops/util/parameters/NumericConstraints.h"
  #include "oops/util/parameters/RequiredParameter.h"
  
  RequiredParameter<int> iterations{"iterations", this, {minConstraint(1)}};

If the value loaded from the configuration file does not meet this constraint, :code:`validateAndDeserialize()` will throw an exception. At present, four types of constraints are available: greater than or equal to (:code:`minConstraint()`), less than or equal to (:code:`maxConstraint()`), greater than (:code:`exclusiveMinConstraint()`), and less than (:code:`exclusiveMaxConstraint()`).

Polymorphic Parameters
----------------------

Polymorphic parameters represent branches of the configuration tree whose structure depends on the value of a particular keyword. For example, here is a YAML file listing the properties of some computer peripherals:

.. code:: yaml

    peripherals:
      - type: mouse
        num buttons: 2
      - type: printer
        max page width (mm): 240
        max page height (mm): 320

Clearly, the list of options that make sense for each item in the :code:`peripherals` list depends on
the value of the :code:`type` keyword. This means that a separate :code:`Parameters` subclass is needed to represent the options supported by each peripheral type, and the decision which of these classes should be instantiated can only be taken at runtime, when a configuration file is loaded. 

The structure of the above YAML file could be represented with the following subclasses of :code:`Parameters`:

.. code:: c++

    class PeripheralParameters : public Parameters {
      OOPS_ABSTRACT_PARAMETERS(PeripheralParameters, Parameters)
     public:
      RequiredParameter<std::string> type{"type", this};
    };

    class PrinterParameters : public PeripheralParameters {
      OOPS_CONCRETE_PARAMETERS(PrinterParameters, PeripheralParameters)
     public:
      RequiredParameter<int> maxPageWidth{"max page width", this};
      RequiredParameter<int> maxPageHeight{"max page height", this};
    };

    class MouseParameters : public PeripheralParameters {
      OOPS_CONCRETE_PARAMETERS(MouseParameters, PeripheralParameters)
     public:
      Parameter<int> numButtons{"num buttons", 3, this};
    };

    class PeripheralParametersWrapper : public Parameters {
      OOPS_CONCRETE_PARAMETERS(PeripheralParametersWrapper, Parameters)
     public:
      RequiredPolymorphicParameter<PeripheralParameters, PeripheralFactory>
        peripheral{"type", this};
    };

    class ComputerParameters : public Parameters {
      OOPS_CONCRETE_PARAMETERS(ComputerParameters, Parameters)
     public:
      Parameter<std::vector<PeripheralParametersWrapper>> peripherals{
        "peripherals", {}, this};
    };

Each item in the :code:`peripherals` list is represented by a :code:`RequiredPolymorphicParameter<PeripheralParameters, PeripheralFactory>` object. This object holds a pointer to an instance of a subclass of the :code:`PeripheralParameters` abstract base class; whether it is an instance of :code:`PrinterParameters` or :code:`MouseParameters` is determined at runtime depending on the value of the :code:`type` key. This is done by the :code:`PeripheralFactory::createParameters()` static function (not shown in the above code snippet), which is expected to take the string loaded from the :code:`type` key and return a unique pointer to a new instance of the subclass of :code:`PeripheralParameters` identified by that string. The :code:`PeripheralFactory` class would typically be used also to create objects representing the peripherals themselves. 

:code:`RequiredPolymorphicParameter` has counterparts suitable for representing optional polymorphic parameters: :code:`OptionalPolymorphicParameter` and :code:`PolymorphicParameter`. These templates behave similarly to :code:`OptionalParameter` and :code:`Parameter`; in particular, :code:`PolymorphicParameter` makes it possible to set a default value of the key (`type` in the above example) used to select the concrete :code:`Parameters` subclass instantiated at runtime.

In JEDI, polymorphic parameters are used, for example, to handle options controlling models and variable changes. 

Conversion to :code:`Configuration` Objects
-------------------------------------------

The :code:`Parameters::toConfiguration()` method can be called to convert a :code:`Parameters` object to a :code:`Configuration` object. A typical use case is passing options to Fortran code. As mentioned in :ref:`config-fortran`, JEDI defines a Fortran interface to :code:`Configuration` objects, but there is currently no Fortran interface to :code:`Parameters` objects, so conversion to a :code:`Configuration` object is the easiest way to pass the values of multiple parameters to Fortran.

Copying :code:`Parameters` Objects
----------------------------------

Concrete subclasses of :code:`Parameters` whose definition contains an invocation of the :code:`OOPS_CONCRETE_PARAMETERS()` macro provide a copy constructor that can be used to copy instances of these objects. In addition, both the :code:`OOPS_CONCRETE_PARAMETERS(className, baseClassName)` and :code:`OOPS_ABSTRACT_PARAMETERS(className, baseClassName)` macros define a :code:`clone()` method returning a :code:`unique_ptr<className>` holding a deep copy of the object on which it is called. This method can be called to clone an instance of a subclass of :code:`Parameters` accessed through a pointer to an abstract base class (e.g. :code:`PeripheralParameters` from the example above).

.. _validation:

Validation
----------

We have referred multiple times to the :code:`validateAndDeserialize()` function taking a reference to a  :code:`Configuration` object. As you may already have guessed, it wraps calls to two separate functions: :code:`validate()` and :code:`deserialize()`. The latter populates the member variables of a :code:`Parameters` object with values loaded from the input :code:`Configuration` object. The former checks if the contents of the :code:`Configuration` object are correct: for example, if all the mandatory parameters are present, if there are any keys whose names do not match the names of any parameters (and thus potentially have been misspelled), and if the values of all keys have the expected types and meet all imposed constraints. Under the hood, this is done by constructing a `JSON schema <https://json-schema.org>`_ defining the expected structure of a JSON/YAML file section that can be loaded into the :code:`Parameters` object, and checking if the contents of the :code:`Configuration` object conform to that schema. This check is performed using an `external library <https://github.com/pboettch/json-schema-validator>`_, so it is only enabled if this library was available when building JEDI.

Delegating the validity check to a JSON Schema validator has multiple advantages:

* It makes it easier to detect certain types of errors (in particular misspelled names of optional keys).

* If the JSON schema defining the expected structure of entire configuration files taken by a particular JEDI application is exported to a text file, an external validator can be used to check the input files even before the application is run (or before a batch job is submitted to an HPC machine).

* The same text file can be used to enable JSON/YAML syntax checking and autocompletion in editors such as Visual Studio Code.

At this stage, :code:`Parameters` subclasses representing the top-level options from the configuration files taken by JEDI applications have not yet been defined, so JSON schemas defining the structure of these files cannot be generated yet. This is an area of active development.

OOPS Interfaces Supporting :code:`Parameters`
---------------------------------------------

Implementations of some OOPS interfaces, such as :code:`Model`, :code:`LinearModel`, and :code:`Geometry`, can opt to provide a constructor taking a const reference to a subclass of :code:`Parameters` representing the collection of options recognized by the implementation, instead of a constructor taking a const reference to an :code:`eckit::Configuration` object. Such implementations need to typedef :code:`Parameters_` to the name of the appropriate :code:`Parameters` subclass. For example, in the example discussed in the :ref:`Introduction <parameters-introduction>`, the :code:`MyGeometry` class declaration would have looked like this:

.. code:: c++

  class MyGeometry {
   public:
    MyGeometry(const eckit::Configuration & config, const eckit::Comm & comm);
    // ...
  };

But we could also declare it like this:

.. code:: c++
 
  class MyGeometry {
   public:
    typedef MyGeometryParameters Parameters_;
    MyGeometry(const MyGeometryParameters & params, const eckit::Comm & comm);
    // ...
  };

The constructor would then receive a :code:`MyGeometryParameters` object already populated with values loaded from the configuration file, without a need to call :code:`validateAndDeserialize()` separately.

OOPS interfaces that support implementations with such constructors are identified in their documentation. It is envisaged that in future such constructors will be supported by all OOPS interfaces.

Headers to Include; Adding Support for New Parameter Types
----------------------------------------------------------

Inclusion of the :code:`Parameter.h`, :code:`RequiredParameter.h` and :code:`OptionalParameter.h` header files suffices to use parameter objects storing values of type :code:`int`, :code:`size_t`, :code:`float`, :code:`double,` :code:`bool`, :code:`std::string`, :code:`std::vector`, :code:`std::map`, :code:`util::DateTime`, :code:`util::Duration`, and :code:`eckit::LocalConfiguration`. Support for some less frequently used types, such as :code:`ufo::Variable` and :code:`oops::Variables`, can be enabled by including an appropriate :code:`ParameterTraits*.h` file, e.g. :code:`ufo/utils/parameters/ParameterTraitsVariable.h`.

As you may have guessed from the name of this file, the class template :code:`ParameterTraits<T>` is responsible for the loading of values of type :code:`T` into parameter objects (as well as their storage in :code:`Configuration` objects and JSON schema generation). This template has been specialized for frequently used types such as those listed above. If none of them fit your needs and you want to extract values into instances of a different type, you will need to specialize :code:`ParameterTraits<T>` for that type. To do that, start from one of the existing specializations and adapt it to your requirements.
