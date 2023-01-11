.. _top-vader-howto:

How To Use VADER
================

VADER was designed to be invoked within a model's implementations of the :code:`oops::VariableChange` and ``oops::LinearVariableChange`` interface classes (the classes specified in the model's TRAITS file). Note that VADER does not replace these classes, instead it is called *from* these classes as a helper.

The methods used to invoke VADER's functionality correspond to the methods with the same name in these two OOPS interface classes. So, VADER's ``changeVar`` method should be called within the model's ``VariableChange`` class's ``changeVar`` method. In the model's ``LinearVariableChange`` interface class, VADER's ``changeVarTraj``, ``changeVarTL``, and ``changeVarAD`` methods should be called inside the interface methods of the same name.

In order to pass model fields to and from VADER, ``Fields`` and ``FieldSets`` from Atlas are used. (This is similar to the interface models use with SABER repository methods.) The methods ``toFieldSet`` and ``fromFieldSet``, which are defined in the OOPS ``State`` and ``Increment`` interfaces, are used to convert the model State/Increment to and from an Atlas FieldSet.

When a model calls Vader's ``changeVar`` method, passing the input/output Fieldset and the list of desired output variables, Vader's algorithm will analyze how it can produce the maximum number of the requested output variables, given the inputs it was provided and the variable-change algorithms (usually called "recipes") that it currently has at its disposal. In some cases, VADER will not have all the recipes required to produce all the desired variables. Consequently, the model may still need some of its own, model-specific, variable change code to finish the work that VADER cannot do. VADER's methods report back which variables VADER was able to produce, and the model's code must use this information to know which variable changes it still needs to do.

* **Workflow to call Vader's changeVar method**

.. image:: VaderDiagram.jpg
   :align: center

For detailed, up-to-date examples of how to call VADER's methods, please see the fv3-jedi code:

- `VariableChange.cc <https://github.com/JCSDA/fv3-jedi/blob/develop/src/fv3jedi/VariableChange/VariableChange.cc>`_ (See the ``changeVar`` method.)
- `LinearVariableChange.cc <https://github.com/JCSDA/fv3-jedi/blob/develop/src/fv3jedi/LinearVariableChange/LinearVariableChange.cc>`_. (See the ``changeVarTraj``, ``changeVarTL``, and ``changeVarAD`` methods.)

For detailed, up-to-date descriptions of the parameters and return values for these VADER methods, please see the doxygen header block comments above the methods in the `vader source code <https://github.com/JCSDA/vader/blob/develop/src/vader/vader.cc>`_.

.. _vader_cookbook:

VADER's "Cookbook"
^^^^^^^^^^^^^^^^^^

An important concept to understand in order to use VADER is its **cookbook**. As mentioned earlier, the individual variable change algorithms that VADER can use are coded into classes called *recipes*. Each recipe produces one and only one variable. (The code for all the recipes is `here <https://github.com/JCSDA/vader/tree/develop/src/vader/recipes>`_.) When ``changeVar`` or ``changeVarTraj`` is called, VADER uses its recipe-search algorithm on *only the recipes that are in the cookbook* in order to attempt to create as many of the desired variables as possible. Models can define which recipes are in VADER's cookbook by passing the cookbook as a parameter when VADER is constructed. If no cookbook is passed to the constructor, VADER will use a default cookbook. Since the default cookbook will get updated as new recipes are created, the advanatage of passing the cookbook as a parameter when VADER is constructed is that VADER's behavior is less likely to change at an unexpected time.
