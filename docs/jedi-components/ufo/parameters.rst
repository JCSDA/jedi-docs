.. _Parameter-classes:

Parameter classes
=================

The :code:`Parameter`, :code:`RequiredParameter` and :code:`OptionalParameter` class templates can be used to automate extraction of parameters from :code:`eckit::Configuration` objects storing values loaded from YAML files. Compared to calling :code:`eckit::Configuration` methods directly, this has the following advantages:

* It reduces code duplication (code using the :code:`eckit::Configuration` interface to build instances of specific types, such as :code:`util::DateTime` or :code:`std::map`, needs to be written only once)

* It makes it easy to find the full list of parameters accepted by a filter, observation operator etc., including their name, type, default value (if any) and accompanying documentation.

* In future, code written in this way will profit from automatic parameter validation (e.g. range checking, typo detection) and error reporting.

Basic example
-------------

To use the parameter classes in a new filter:

1. Define a new class storing all parameters accepted by the filter as :code:`Parameter`, :code:`RequiredParameter` or :code:`OptionalParameter` objects. The class needs to inherit from the :code:`Parameters` class. For example, suppose your filter can be configured using this YAML snippet:

   .. code:: yaml

      - Filter: My Filter
        radius_in_km: 150
        num_iterations: 10

   In other words, the filter takes two parameters: a floating-point number :code:`radius_in_km` and an integer :code:`num_iterations`. An appropriate  :code:`Parameters` subclass could look like this:

   .. code:: c++

      #include "oops/util/parameters/Parameter.h"
      #include "oops/util/parameters/Parameters.h"
      
      /// \brief My filter's parameters.
      class MyFilterParameters : public oops::Parameters {
      public:
        /// \brief Radius (in km).
        oops::Parameter<float> radiusInKm{"radius_in_km", 10.0f, this};

        /// \brief Number of iterations.
        oops::Parameter<int> numIterations{"num_iterations", 5, this};
      };
  

   Note that:

   * in the above example, the C++11 default member initializer syntax is used to initialize all member variables (this is not necessary, but it's convenient)

   * the first argument passed to the constructor of each :code:`Parameter` object is the name of the key in the YAML key/value pair from which that parameter's value will be extracted

   * the second argument is the default value of the parameter (to be used if the key specified in the first argument is not found in the YAML file)

   * the third argument should be set to the address of the :code:`Parameters` object holding all the individual parameters.

2. Add a member variable of type :code:`MyFilterParameters` to your filter class. To extract the parameter values from an :code:`eckit::Configuration` object into the :code:`radiusInKm` and :code:`numIterations` variables, call the :code:`deserialize()` method of :code:`MyFilterParameters`:

   .. code:: c++
 
      class MyFilter : public FilterBase {
       public:
        MyFilter(ioda::ObsSpace &obsdb, const eckit::Configuration &config,
                 boost::shared_ptr<ioda::ObsDataVector<int> > flags,
                 boost::shared_ptr<ioda::ObsDataVector<float> > obserr)
          : FilterBase(obsdb, config, std::move(flags), std::move(obserr))
        {
          parameters_.deserialize(config);
        } 
  
       private:			 		 
        MyFilterParameters parameters_;
      };

3. To access the values of the :code:`radius` and :code:`num_iterations` parameters in the filter's implementation, you can call the :code:`value()` method of the :code:`Parameter` objects. In most circumstances you can also use the :code:`Parameter` object as if it was the parameter value itself (omitting the call to :code:`value()`), since the :code:`Parameter<T>` class template overloads the conversion operator to :code:`const T&`. So the two following snippets are equivalent:

   .. code:: c++
   
      for (int i = 0; i < parameters_.numIterations.value(); ++i) {
        doIteration();
      }

   and 

   .. code:: c++
   
      for (int i = 0; i < parameters_.numIterations; ++i) {
        doIteration();
      }

Parameter nesting
-----------------

Even though in the preceding example we used parameters storing values of "primitive" types (:code:`int` or :code:`float`), it possible to store more complex values, such as strings, vectors, maps, dates and durations. It is also possible to nest parameters, i.e. store a subclass of :code:`Parameters` in a :code:`Parameter` object. For example, to load the following YAML snippet:

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
   public:
    oops::Parameter<float> min{"min", std::numeric_limits<float>::lowest(), this};
    oops::Parameter<float> max{"max", std::numeric_limits<float>::max(), this};
  };
  
  class LatLonRangeParameters : public oops::Parameters {
   public:
    oops::Parameter<RangeParameters> latitudes{"latitudes", {}, this};
    oops::Parameter<RangeParameters> longitudes{"longitudes", {}, this};
  };

To load parameter values from an :code:`eckit::LocalConfiguration` object, it would be enough to call the :code:`deserialize()` method of the top-level :code:`Parameters` object, i.e. in this case an instance of :code:`LatLonRangeParameters`.

Parameters without default values
---------------------------------

Sometimes it is impossible or undesirable to specify meaningful default parameter values. There are two distinct scenarios:

- The parameter value must always be specified explicitly in the YAML file. In this case, the parameter should be encapsulated in a :code:`RequiredParameter<T>` object. An exception will then be thrown by the :code:`deserialize()` function if no key matching that parameter's name is found in the :code:`Configuration` object.

- The parameter can be omitted from the YAML file, but its absence must be detected and handled specially. This is what the :code:`OptionalParameter<T>` class template is for: instead of a value of type :code:`T` it stores a value of type :code:`boost::optional<T>`. This value is set to :code:`boost::none` if no key matching the parameter's name is found in the :code:`Configuration` object provided to the :code:`deserialize()` function.

As an example, a thinning filter might allow the user to optionally specify a variable storing observation priorities (with observations of higher priority more likely to be retained than those of lower priority). To this end, the name of that variable could be stored in an :code:`OptionalParameter<ufo::Variable>` object. On the other hand, the maximum number of observations to be retained could be stored in an instance of :code:`RequiredParameter<int>` if we wanted to force the user to always specify it explicitly:

.. code:: c++
  
  #include "oops/util/parameters/OptionalParameter.h"
  #include "oops/util/parameters/Parameters.h"
  #include "ufo/utils/parameters/ParameterTraitsVariable.h"

  class MyFilterParameters : public oops::Parameters {
   public:
    oops::OptionalParameter<ufo::Variable> priorityVariable{"priority_variable", this};
    oops::RequiredParameter<int> maxNumRetainedObs{"max_num_retained_obs", this};
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


Headers to include; adding support for new parameter types
----------------------------------------------------------

Inclusion of the :code:`Parameters.h`, :code:`Parameter.h`, :code:`RequiredParameter.h` and :code:`OptionalParameter.h` header files suffices to use parameter objects storing primitive types (:code:`int`, :code:`float` etc.), :code:`std::string`, :code:`std::vector`, :code:`std::map`, :code:`util::DateTime` and :code:`util::Duration` objects. Support for some less frequently used types, such as :code:`ufo::Variable`, can be enabled by including an appropriate :code:`ParameterTraits*.h` file, e.g. :code:`ufo/utils/parameters/ParameterTraitsVariable.h`.

As you may have guessed from the name of this file, the class template :code:`ParameterTraits<T>` is responsible for the deserialization of parameters of type :code:`T`. The generic implementation is suitable for primitive types, and the template has been specialized for other frequently used types such as those listed above. If none of them fit your needs and you want to extract values into instances of a different type, you will need to specialize :code:`ParameterTraits<T>` for that type. To do that, start from one of the existing specializations and adapt it to your requirements.

Future extensions
-----------------

In future, we hope to extend the parameter classes, adding support for:

* bounds checking

* typo detection (emission of warnings about unrecognized parameters encountered in YAML files).