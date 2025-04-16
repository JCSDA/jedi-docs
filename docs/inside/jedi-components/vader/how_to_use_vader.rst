.. _top-vader-howto:

High-Level Overview of VADER
============================
An instance of VADER is created and provided with four critical pieces of information:

1. A list of **input variables**. These are the "From" variables that the model will pass to VADER.
2. A list of desired **output variables**. These are the "To" variables that the model wants VADER to produce.
3. A **list of "recipes"**. These are the variable change algorithms that VADER can use to produce the output variables from the input variables. This list of recipes is called the *cookbook*, and it is set when VADER is constructed.
4. A **FieldSet containing the input variables**.

An instance of VADER that will be performing linear variable changes will also be provided with a FieldSet containing fields to be used (or produce) the **trajectory variables** required by the recipes.


How To Use VADER
================

VADER was designed to be invoked within a model's implementations of the :code:`oops::VariableChange` and ``oops::LinearVariableChange`` interface classes (the classes specified in the model's TRAITS file). Note that VADER does not replace these classes, instead it is called *from* these classes as a helper.

Most methods used to invoke VADER's functionality correspond to the methods with the same name in these two OOPS interface classes. So, VADER's ``changeVar`` method should be called within the model's ``VariableChange`` class's ``changeVar`` method. In the model's ``LinearVariableChange`` interface class, VADER's ``changeVarTraj``, ``changeVarTL``, and ``changeVarAD`` methods should be called inside the interface methods of the same name.

In order to pass model fields to and from VADER, ``Fields`` and ``FieldSets`` from Atlas are used. (This is similar to the interface models use with SABER repository methods.) The methods ``toFieldSet`` and ``fromFieldSet``, which are defined in the OOPS ``State`` and ``Increment`` interfaces, are used to convert the model State/Increment to and from an Atlas FieldSet.

When a model calls Vader's ``changeVar`` method, passing the input/output Fieldset and the list of desired output variables, Vader's algorithm will analyze how it can produce the maximum number of the requested output variables, given the inputs it was provided and the variable-change algorithms (usually called "recipes") that it currently has at its disposal. In some cases, VADER will not have all the recipes required to produce all the desired variables. Consequently, the model may still need some of its own, model-specific, variable change code to finish the work that VADER cannot do. VADER's methods report back which variables VADER was able to produce, and the model's code must use this information to know which variable changes it still needs to do.

* **Workflow to call Vader's (non-linear) changeVar method**

.. image:: VaderDiagram.jpg
   :align: center

**Differences for linear variable changes**
The process to perform non-linear variable changes is simple because all the required information can be passed to Vader in the call to the ``changeVar`` method. However, for linear variable changes, more information must be provided and this is done via two different function calls. So the process to use Vader for linear variable changes has more steps:

1. The model must call the Vader's ``changeVarTraj`` method first, usually in the model's ``LinearVariableChange::changeVarTraj`` method. Here Vader receives the trajectory FieldSet and the list of desired output variables, i.e. the "To" variables. Vader stores this information in its instance, but does not do any more at this time.
2. The model must then also call Vader's ``initTLAD`` method before calling either Vader's ``changeVarTL`` or ``changeVarAD`` methods. This method provides Vader with the information about the "From" variables, and then Vader has all the information it needs to figure out which of the "To" variables it can produce. ``initTLAD`` can be called immediately after ``changeVarTraj`` if the "From" variables are known at that time, or it can be called just before the first call to Vader's ``changeVarTL`` or ``changeVarAD`` methods, when the "From" variables are definitely known. Vader provides a ``needsTLADInit`` method that clients can use to query whether Vader has already been fully initialized via ``initTLAD`` or not.
3. Finally, the model can call either the ``changeVarTL`` or ``changeVarAD`` methods, passing a FieldSet containing the required fields for those calls. These methods will perform the variable changes and return the modified FieldSet.

Here is a table showing how Vader receives its required information for both non-linear (``changeVar``) and linear (``changeVarTL``, and ``changeVarAD``) variable changes:

.. list-table:: 
   :header-rows: 1
   :widths: 20 37 43

   * - Information
     - Non-linear Variable Changes
     - Linear Variable Changes
   * - Input variables
     - List of fields in FieldSet passed to changeVar
     - oops::Variables passed to initTLAD
   * - Output variables
     - oops::Variables passed to changeVar
     - oops::Variables passed to changeVarTraj
   * - Input Fields
     - FieldSet passed to changeVar
     - FieldSet passed to changeVarTL and changeVarAD
   * - Trajectory Fields
     - Not applicable
     - FieldSet passed to changeVarTraj

For detailed, up-to-date examples of how to call VADER's methods, please see the fv3-jedi code:

- `VariableChange.cc <https://github.com/JCSDA/fv3-jedi/blob/develop/src/fv3jedi/VariableChange/VariableChange.cc>`_ (See the ``changeVar`` method.)
- `LinearVariableChange.cc <https://github.com/JCSDA/fv3-jedi/blob/develop/src/fv3jedi/LinearVariableChange/LinearVariableChange.cc>`_. (See the ``changeVarTraj``, ``changeVarTL``, and ``changeVarAD`` methods.)

For detailed, up-to-date descriptions of the parameters and return values for these VADER methods, please see the doxygen header block comments above the methods in the `vader source code <https://github.com/JCSDA/vader/blob/develop/src/vader/vader.cc>`_.

.. _vader_cookbook:

VADER's "Cookbook"
^^^^^^^^^^^^^^^^^^

An important concept to understand in order to use VADER is its **cookbook**. As mentioned earlier, the individual variable change algorithms that VADER can use are coded into classes called *recipes*. Each recipe produces one and only one variable. (The code for all the recipes is `here <https://github.com/JCSDA/vader/tree/develop/src/vader/recipes>`_.) When ``changeVar`` or ``initTLAD`` is called, VADER uses its recipe-search algorithm on *only the recipes that are in the cookbook* in order to attempt to create as many of the desired variables as possible. Models can define which recipes are in VADER's cookbook by passing the cookbook via an ``eckit::LocalConfiguration`` when VADER is constructed. If no cookbook is passed to the constructor, VADER will use a default cookbook. Since the default cookbook will get updated as new recipes are created, the advanatage of passing the cookbook as a parameter when VADER is constructed is that VADER's behavior is less likely to change at an unexpected time.

.. _vader_configvars:

VADER's Configuration Variables 
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Certain recipes require values, other than the ingredients, that must be provided by the model. For instance, the model's air pressure at the model top is required for some pressure-related recipes. When a recipe is executed it will generate an error if a needed value has not been provided to VADER. These values are passed to the VADER constructor via an ``eckit::LocalConfiguration`` object. (See the fv3-jedi code for an example of how to populate these values.) These values have been documented for the recipes which require them. If a recipe does not get used it is not necessary to populate these values.