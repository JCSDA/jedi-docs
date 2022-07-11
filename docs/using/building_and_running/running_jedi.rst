.. _run-jedi:

Running JEDI applications
=========================

There are several options when running JEDI applications executables:

- Run in application mode (most commonly used). The example below would run a :code:`Variational` JEDI application with the FV3 model, passing :code:`myconfig.yaml` to configure the application. Depending on the system, replace ``mpiexec`` with the correct launcher command (e.g. ``srun -n``) and submit the job through a batch script or in an interactive session.

.. code-block:: bash

     [mpiexec -nN] fv3jedi-var.x myconfig.yaml [output-file]

- Run in validate-only mode. The example below would verify that :code:`myconfig.yaml` is a valid configuration file for the :code:`Variational` JEDI application, but will not run the :code:`Variational` application.

.. code-block:: bash

     fv3jedi-var.x --validate-only myconfig.yaml

- Run in no-validate mode. The application will be run, but the configuration file will not be validated before running the application. Only recommended if the application was previously run with the same configuration file in :code:`--validate-only` mode. Configuration file validation produces user-friendly error messages if the configuration file is erroneous. Skipping validation in that case may produce error messages that are harder to understand.

.. code-block:: bash

     fv3jedi-var.x --no-validate myconfig.yaml [output-file]

- Run in generate schema mode. The example below will generate JSON schema for the :code:`Variational` application. JSON schema can be used e.g. in IDEs for validating and auto-completing keys in configuration files.

.. code-block:: bash

     fv3jedi-var.x --output-json-schema=myschema.schema
