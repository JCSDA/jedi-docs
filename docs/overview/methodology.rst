########################
JEDI General Methodology
########################

The `requirements for JEDI <requirements.html>`_ are diverse and many aspects are
very complex in themselves or together. The key concept in modern software development for 
such complex systems is the separation of concerns.
In a well-designed architecture, teams can develop different aspects in parallel
without interfering with other teams’ work and without breaking the components
they are not working on.
Scientists can also work more efficiently by focusing on their area of expertise without
having to understand all aspects of the system.
Modern techniques (such as Object Oriented programming) extend this concept
and, just as importantly, enforce it automatically and uniformly throughout a code.
This system architecture also allows teams to be spread all across the country or the world while still working on the same project.

In order to facilitate collaborative work in this environment, JEDI uses modern software development tools like version control, bug and feature development tracking,
and automated regression testing. Utilities are also provided for exchanging this information.
This is essential for working across agencies and will be used both for initial development and long term
evolution and maintenance.

With these tools and teams established, the first task is to define interfaces between
the components of the system.
These interfaces will be generic and abstract.
This task will benefit from the experience of other similar projects (e.g. OOPS at ECMWF).
Based on these interfaces, high level model-agnostic applications will be
progressively developed.

Once high level abstract interfaces are defined, existing codes can be progressively
adapted to the new interfaces.
Existing software will be modified to call the refactored parts to prevent divergence
and maintain a continuously functioning system.
A subset of interfaces that should be implemented first will be defined so that some
applications can start using the new interfaces before everything is complete.

For operational applications, the application of these principles
must not adversely impact their ability to implement the code or negatively impact efficiency.
