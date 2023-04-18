.. _ObsFunctionStringManipulation:

ObsFunctionStringManipulation
-----------------------------------------------------------------

This obsFunction is designed to provide a means for manipulating strings. 
The current available string manipulations are:

  - string cut

Required input parameters:
~~~~~~~~~~~~~~~~~~~~~~~~~~

variable
  An array of the variable for string manipulation supplied as a vector of strings. 
  
string operation
  A key word which will set what type of string manipulation is to be carried out.
  
  - stringcut
      String cut will slice an input string from a given starting index for a set length. 

    *Required stringcut parameters*:

    For the stringcut option the following inputs are required

    startIndex
      An integer that will set what index to start the cut from (0 being far left)
  
    cutLength 
      An integer that will set the length of the string to cut from the startIndex. 

Example configuration:
~~~~~~~~~~~~~~~~~~~~~~

Here is an example for creating a new station_name variable from a ground based gnss station name processing name combination. In this example the :code:`MetaData/full_site_name` might look like AAAA-BBBB.  

.. code-block:: yaml

  - filter: Variable Assignment
    assignments:
    - name: MetaData/station_name
      type: string
      function:
        name: StringObsFunction/StringManipulation
        options:
          string operation: stringcut
          variable: [MetaData/full_site_name]
          startIndex: 0 
          cutLength: 4 
  
The output :code:`MetaData/station_name` would then look like AAAA. 
