.. _jedi_containers:

.. _top-Containers:

Software Containers
===================

A working definition of a software container is
**A packaged user environment that can be "unpacked" and used across different
systems, from laptops to cloud to HPC**.

So, given our overview of JEDI Portability and use cases, containers seem like an ideal fit.

From a JEDI perspective, the main purpose of containers is **Portability**:
they provide a uniform computing environment (software tools, libraries,
compilers, etc) across different systems.  So, users and developers can focus
on working with the JEDI code without worrying about whether their version of
cmake is up to date or whether or not NetCDF was configured with parallel HDF5 support (for example).

But containers offer other advantages as well, including the following.

**BYOE: Bring Your Own Environment**: Containers let JEDI masters pick and
choose which software packages and versions to include and which configuration
options will allow them to work optimally with the JEDI code.  So, there is no
need for users and developers to deal with compatibility issues.

**Reproducibility**:  Like the JEDI code itself, containers can be tagged with
public releases so that specific results such as forecasts/reanalyses or
numerical experiments can be reproduced.  For example, a researcher can specify
the version of JEDI and the version of the container that was used in a
particular publication so that others can reproduce the results presented.
`Singularity <https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0177459>`_
takes particular care to ensure that results are reproducible.

**Workflow**: Containers enable new JEDI users to get up and running quickly.
They enable users to do code development on laptops and workstations, saving
valuable HPC resources for production runs.  And, they allow for the optimal
support of particular use cases.  For example, **development containers** include
binary dependencies together with the compiler and MPI library that they were
build with. Users/developers would then download the JEDI source code from
GitHub and compile it within the container. By contrast,
**application containers** include the compiled JEDI source code and
dependencies, without the compilers themselves, ready to run (*plug and play*).
For a list of currently available containers, consult
JCSDA `DockerHub page <https://hub.docker.com/u/jcsda/>`_ for Docker images
and JCSDA `Sylabs page <https://cloud.sylabs.io/library/jcsda>`_ for Singularity images.


In contrast to virtual machines, containers do not include the necessary software
to build an entire operating system. Rather, they work with the host operating
system to provide the desired functionality, including the libraries,
applications, and other software tools that your code needs to run.
So containers generally require much less memory to store and to set up than
virtual machines.  And, they are generally more efficient because they can
interact with the hardware directly via the host kernel without the need for an
intermediate interpretive layer called
a `hypervisor <https://en.wikipedia.org/wiki/Hypervisor>`_. However, one disadvantage of this is that containers are not entirely independent of the host system architecture. For instance, containers created on modern Apple M1 systems require a host OS that uses an `aarch64`/`amd64` architecture, they will not run on Intel-based systems (`x86_64`).

Docker
------

The most popular container provider is `Docker <https://www.docker.com>`_.
This was introduced in 2013 and quickly became the industry standard, now
supported by a wide variety of applications and computing platforms. But Docker
has a fatal design flaw that makes it unsuitable for High Performance Computing (HPC).
Namely, Docker containers run as a child process of a root daemon.
This poses severe security risks on HPC systems because it could allow users to
escalate their access privileges. This is unlikely to change because Docker was
developed for business enterprise applications where this level of control is
beneficial. `See Kurtzer et al (2017) for further discussion <https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0177459>`_.

By contrast, :doc:`Singularity <singularity>` was developed by HPC professionals
for HPC applications. Singularity includes HPC features such as native support
for MPI schedulers (e.g. slurm) and GPU compute cores.
Furthermore, Singularity can be built from Docker containers
(or, more appropriately, from Docker images, which are multi-layered files
that spawn Docker containers). JEDI Singulary containers are generated from a
common Docker image.

However, there is one distinguishing feature of Docker is that is worth mentioning:
it does not rely on the linux user namespaces and other features
(for example, SetUID) that Singularity requires. This is what makes it unsuitable
for HPC since it achieves containerization instead by means of the root daemon.
However, these linux features are not yet supported by macOS and Windows. So,
in short, Docker can run natively on laptops and PCs running macOS or Windows
whereas Singularity cannot.
Our recommendation for these systems is to use JEDI docker image directly.
The images are publicly hosted on the `Docker Hub <https://hub.docker.com/>`_.
Users can also use Singularity within a virtual machine such as :doc:`Vagrant <vagrant>`.

.. code-block:: bash

    docker pull jcsda/docker-<name>:latest

Where ``<name>`` specifies the compiler suite, mpi library, and container type
(e.g. development, application, or tutorial). For example, a name of ``gnu-openmpi-dev``
is used for the Docker image built with the gnu compiler suite and the openmpi mpi library.
For a list of currently available JEDI Docker containers, `go to Docker Hub <https://hub.docker.com>`_ and search for ``jcsda``.

After pulling the Docker image you can start and login a Docker container using the command below:

.. code-block:: bash

    docker run -it jcsda/docker-<name>:latest


The ``-it`` flag will start an interactive session for you and your prompt will
change when you are in the container.

If you log in as root (the default) then the mpi tests will likely fail. We have
created a :code:`nonroot` user in all of the JEDI containers. You can change
your user to :code:`nonroot` after logging into the container:

.. code-block:: bash

    su - nonroot

Or log into the container as :code:`nonroot` user.

.. code-block:: bash

    docker run -u nonroot --rm -it jcsda/docker-<name>:latest


Please note that all the data in a Docker container will be lost if container is deleted.
You can avoid this by creating a shared volume between the host machine and Docker.
To create a shared volume you can use :code:`-v` flag.

.. code-block:: bash

    docker run -it -v path/to/shared/folder/on/host:/home/nonroot/shared jcsda/docker-<name>:latest

You can find more information about Docker shared volume `here <https://docs.docker.com/storage/volumes/>`_.

Before starting the build of JEDI in the container you need to load the Spack modules:

.. code-block:: bash

   export jedi_cmake_ROOT=/opt/view
   source /etc/profile.d/z10_spack_environment.sh


.. _available_containers:

Available Containers
--------------------

The public containers currently offered by JCSDA include:

    - :code:`tutorial`
    - :code:`gnu-openmpi-dev`
    - :code:`clang-mpich-dev`

Containers that include :code:`-dev` in their name are development containers
as described :ref:`above <top-Containers>`.  This means that they contain the
JEDI dependencies and compilers but not the JEDI code itself.
The ``tutorial`` container is designed for use with the JEDI Tutorials.
