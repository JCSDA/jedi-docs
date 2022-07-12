.. _top-vader-howto:

How To Use VADER
================

Models instantiate and call the VADER methods within their implementation of the ``oops::VariableChange`` interface (the class specified in the model's TRAITS file). Note that VADER does not replace this class, instead it is called from this class. A model that already has a JEDI interface will, at a high level, just insert the call to VADER into its ``changeVar`` method immediately before its existing ``changeVar`` implementation. With the call to VADER's ``changeVar`` method in place, the model code will no longer need to perform the transformations that VADER is able to do. As VADER gains more implemented variable changes, there will be less that the model needs to do in its own code.

In order to pass model fields to and from VADER, ``Fields`` and ``FieldSets`` from Atlas are used. (This is similar to the interface models use with SABER repository methods.) The methods ``toFieldSet`` and ``fromFieldSet``, which are defined in the OOPS ``State`` interface, are used to convert the model State to and from an Atlas FieldSet.  *Note:* The Atlas FieldSet that is passed to and from VADER must contain BOTH the input and the desired output fields.

When a model calls Vader's ``changeVar`` method, passing the input/output Fieldset and the list of desired output variables, Vader's algorithm will analyze how it can produce the maximum number of the requested output variables, given the inputs it was provided and the variable-change algorithms (usually called "recipes") that it currently has at its disposal.

* **Workflow to call Vader's changeVar method**

.. image:: VaderDiagram.jpg
   :align: center

For an example, here is a link to the `fv3-jedi code that implements this process. <https://github.com/JCSDA-internal/fv3-jedi/blob/757af51af83446b9b86bb2ebfb2b6e821c9b875e/src/fv3jedi/VariableChange/VariableChange.cc#L54-L99>`_

