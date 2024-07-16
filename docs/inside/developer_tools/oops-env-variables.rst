.. _oops-env-vars:

OOPS ENVIRONMENT VARIABLES
==========================

There are several environment variables users can set to enable more (or all) prints available.

More prints for PE 0
--------------------

Exporting one or both of these environment variables before running an application (ctest or executable) will print :code:`OOPS_DEBUG` and :code:`OOPS_TRACE` statements **for the PEs displayed in :code:`OOPS_INFO` only**. The default for this is PE 0.
:code:`OOPS_TRACE` gives you information about which part of the code you are currently running, :code:`OOPS_DEBUG` is typically used when you are debugging a precise part of the code.

.. code-block:: bash

    export OOPS_TRACE=1
    export OOPS_DEBUG=1

If you want to get rid of these DEBUG and TRACE prints, you will need to unset these variables or set them to 0.

More info prints for all PEs
----------------------------

You can export the variable :code:`OOPS_INFO` to a list of PEs you wish to see the output log for.
NOTE that you cannot disable the log output for PE 0.
Lines in the log file will be preceded by :code:`[n]` for PEs > 0.

This will output the log for PEs 0 and 1:

.. code-block:: bash

    export OOPS_INFO=1


This will output the log for PEs 0, 2 to 5 and 9:

.. code-block:: bash

    export OOPS_INFO=2-5,9

This will output the log for all the PEs:

.. code-block:: bash

    export OOPS_INFO=-1

If you use :code:`OOPS_DEBUG=1` and :code:`OOPS_TRACE=1` in combination with :code:`OOPS_INFO!=0`, DEBUG and TRACE will use the setting from INFO.

You can unset :code:`OOPS_INFO` or export it to 0 to go back to the default behavior.


More prints for all PEs
-----------------------

You can export one or both of :code:`OOPS_DEBUG` and :code:`OOPS_TRACE` to -1. This will will print :code:`OOPS_DEBUG` and :code:`OOPS_TRACE` statements **for all the PEs in your application**.
Lines in the log file will be preceded by :code:`OOPS_TRACE[n]` and :code:`OOPS_DEBUG[n]` for PEs > 0.
The log will get crowded very fast and lines might start to overlap each other.

.. code-block:: bash

    export OOPS_TRACE=-1
    export OOPS_DEBUG=-1


Redirect output to log files for each PE
----------------------------------------

Outputting many PEs in the same log quickly gets impossible to read as lines overlap each other and are difficult to parse.
Setting any of these 3 environment variables to more than one PE is better used in combination with redirecting the individual logs to different output files.

JEDI executables allow for two arguments to be passed: a yaml file for the input parameters and a second, optional file where the output will be written.
If you provide the executable a second argument and have any of :code:`OOPS_INFO`, :code:`OOPS_TRACE` or :code:`OOPS_DEBUG` != 0, output logs will be written out for each PE.
For example:

.. code-block:: bash

    export OOPS_INFO=-1  # Will output the INFO log for all PEs
    export OOPS_TRACE=1  # OOPS_TRACE log follows the same PEs as OOPS_INFO
    export OOPS_DEBUG=1  # OOPS_DEBUG log follows the same PEs as OOPS_INFO

    mpirun -n 4 $JEDI_BUILD/bin/qg_eda.x $JEDI_BUILD/oops/qg/test/testinput/eda_3dfgat.yaml qg_eda_output.log

    > ls ./
    > qg_eda_output.log		qg_eda_output.log.000001	qg_eda_output.log.000002	qg_eda_output.log.000003


Note that this doesn't work with :code:`ctest` commands.

Other debugging tools and more information about the use of these variables is available here: :doc:`Unit testing </inside/testing/unit_testing>`
