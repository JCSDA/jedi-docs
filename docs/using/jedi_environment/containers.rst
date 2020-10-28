.. _top-Containers:


.. _Software-Containers:

Software Containers
===================

A working definition of a sofware container is **A packaged user environment that can be "unpacked" and used across different systems, from laptops to cloud to HPC**.

So, given our overview of JEDI Portability and use cases, containers seem like an ideal fit.

From a JEDI perspective, the main purpose of containers is **Portability**: they provide a uniform computing environment (software tools, libraries, compilers, etc) across different systems.  So, users and developers can focus on working with the JEDI code without worrying about whether their version of cmake is up to date or whether or not NetCDF was configured with parallel HDF5 support (for example).

But containers offer other advantages as well, including the following.

**BYOE: Bring Your Own Environment**: Containers let JEDI masters pick and choose which software packages and versions to include and which configuration options will allow them to work optimally with the JEDI code.  So, there is no need for users and developers to deal with compatibility issues.

**Reproducibility**:  Like the JEDI code itself, containers can be tagged with public releases so that specific results such as forecasts/reanalyses or numerical experiments can be reproduced.  For example, a researcher can specify the version of JEDI and the version of the container that was used in a particular publication so that others can reproduce the results presented.  `Singularity <https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0177459>`_ takes particular care to ensure that results are reproducible.

**Workflow**: Containers enable new JEDI users to get up and running quickly.  They enable users to do code development on laptops and workstations, saving valuable HPC resources for production runs.  And, they allow for the optimal support of particular use cases.  For example, **development containers** include binary dependencies together with the compiler and MPI library that they were build with.  Users/developers would then download the JEDI source code from GitHub and compile it within the container.  By contrast, **application containers** include the compiled JEDI source code and dependencies, without the compilers themselves, ready to run (*plug and play*).  For a list of currently available containers, consult the `Containers page on the JCSDA Data Repository <http://data.jcsda.org/pages/containers.html>`_.

In contrast to virtual machines, containers do not include the necessary software to build an entire operating system.  Rather, they work with the host operating system to provide the desired functionality, including the libraries, applications, and other software tools that your code needs to run.  So containers generally require much less memory to store and to set up than virtual machines.  And, they are generally more efficient because they can interact with the hardware directly via the host kernal without the need for an intermediate interpretive layer called a `hypervisor <https://en.wikipedia.org/wiki/Hypervisor>`_.

.. _docker_overview:


Docker
------

The most popular container provider is `Docker <https://www.docker.com>`_.  This was introduced in 2013 and quickly became the industry standard, now supported by a wide variety of applications and computing platforms.  But Docker has a fatal design flaw that makes it unsuitable for High Performance Computing (HPC).  Namely, Docker containers run as a child process of a root daemon.  This poses severe security risks on HPC systems because it could allow users to escalate their access privileges.  This is unlikely to change because Docker was developed for business enterprise applications where this level of control is beneficial. `See Kurtzer et al (2017) for further discussion <https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0177459>`_.

By contrast, :doc:`Singularity <singularity>` and :doc:`Charliecloud <charliecloud>` were developed by HPC professionals for HPC applications.  Singularity in particular includes HPC features such as native support for MPI schedulers (e.g. slurm) and GPU compute cores.  Furthermore, both Singularity and Charliecloud containers can be built from Docker containers (or, more appropriately, from Docker images, which are multi-layered files that spawn Docker containers).  So, this justifies the workflow in the diagram shown :ref:`above <top-Containers>`: our JEDI Singulary and Charliecloud containers are both generated from a common Docker image.

However, there is one distinguishing feature of Docker is that is worth mentioning: it does not rely on the linux user namespaces and other features (for example, SetUID) that Singularity and Charliecloud require.  This is what makes it unsuitable for HPC since it achieves containerization instead by means of the root daemon.  However, these linux features are not yet supported by Mac OS and Windows.  So, in short, Docker can run natively on laptops and PCs running Mac OS or Windows whereas Singularity and Charliecloud cannot.  Our recommendation for these systems is to run Singularity or Charliecloud within a :doc:`Virtual Machine <vagrant>`.  Still, some advanced developers may wish to work with the JEDI docker image directly.  Since the image is publically hosted on the `Docker Hub <https://hub.docker.com/>`_, they are free to do so:

.. code-block:: bash

    docker pull jcsda/docker-<name>:latest

Where ``<name>`` specifies the compiler suite, mpi library, and container type (e.g. development, application, or tutorial).  For example, a name of ``gnu-openmpi-dev`` is used for the Docker image built with the gnu compiler suite and the openmpi mpi library.  For a list of currently available JEDI Docker containers, `go to Docker Hub <https://hub.docker.com>`_ and search for ``jcsda``.

Again, this is **not** the recommended practice.  The JEDI :doc:`Singularity <singularity>` and :doc:`CharlieCloud <charliecloud>` containers are better supported and  provide a more familiar working environment for most users and developers.   The recommended practice is therefore to first establish a linux environment on your laptop or PC using a virtual machine provider like :doc:`Vagrant <vagrant>` and then to run the JEDI :doc:`Singularity <singularity>` or :doc:`Charliecloud <charliecloud>` container there.

If you do decide to run the JEDI Docker containers directly, be sure to log in as the user jedi, for example:

.. code-block:: bash

    docker run -u jedi --rm -it jcsda/docker-<name>:latest


If you log in as root (the default) then the mpi tests will likely fail.

.. _available_containers:

Available Containers
--------------------

The public containers currently offered by jcsda include:

    - :code:`gnu-openmpi-tut`
    - :code:`gnu-openmpi-dev`
    - :code:`clang-mpich-dev`

Containers that include :code:`-dev` in their name are development containers as described :ref:`above <top-Containers>`.  This means that they contain the JEDI dependencies and compilers but not the JEDI code itself.

The ``gnu-openmpi-tut`` container is designed for use with the :doc:`JEDI Tutorials <../../learning/tutorials/index>`.

If you have it available, we recommend the use of Singularity.  To obtain the Singularity versions of these containers enter

.. code-block:: bash

   singularity pull library://jcsda/public/jedi-<name>

where :code:`<name>` is one of the items from the list above.

To obtain the Charliecloud versions of these containers, enter:

.. code-block:: bash

   wget http://data.jcsda.org/containers/ch-jedi-<name>.tar.gz


The docker versions of these containers are also available on the jcsda organization on `Docker Hub <https://hub.docker.com/>`_ as :code:`docker-<name>`.

For an up to date listing of all available JEDI singularity containers `go to the jcsda organization on the Sylabs cloud library web site <https://cloud.sylabs.io/library/jcsda>`_ and view the :code:`public` collection.

Similarly, for an up to date listing of all available JEDI docker containers, search the :code:`jcsda` organization on Docker Hub.

We also maintain Docker, Singularity, and Charliecloud development containers with Intel Parallel Studio 2020 but these are restricted access for proprietary reasons.  Contact the JEDI core team for further information.
