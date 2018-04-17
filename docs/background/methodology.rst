#########################################
JEDI General Methodology
#########################################

The `requirements for JEDI <requirements.html>`_ are diverse and many aspects are
very complex in themselves or together.
However, over the last decade or two, software development technology has advanced
significantly, making routine the use of complex software in everyday life.
Most recently, communication technology has also progressed to a level where working
on the same project across the country has become common practice in the
software industry.
Together, these technologies make the goals set forward feasible.

The key concept in modern software development for complex systems is the separation
of concerns.
In a well-designed architecture, teams can develop different aspects in parallel
without interfering with other teams’ work and without breaking the components
they are not working on.
Scientists can be more efficient focusing on their area of expertise without
having to understand all aspects of the system.
This is similar to the concept of modularity.
However, modern techniques (such as Object Oriented programming) extend this concept
and, just as importantly, enforce it automatically and uniformly throughout a code.

In order to facilitate collaborative work, modern software development tools have
been and will continue to be used.
These tools include version control, bug and feature development tracking,
automated regression testing and provide utilities for exchanging this information.
This is essential for working across agencies, possibly in different parts of the
country, and will be used both for initial development and long term
evolution and maintenance.

Having tools available, the first task will be to define interfaces between
the components of the system.
These interfaces will be generic and abstract.
This task will benefit from the experience of other similar projects (e.g. OOPS at ECMWF).
Based on these interfaces, high level model-agnostic applications will be
progressively developed.

Once high level abstract interfaces are defined, existing codes will be progressively
adapted to the new interfaces.
Existing software will be modified to call the refactored parts to prevent divergence
and maintain a continuously functioning system.
A subset of interfaces that should be implemented first will be defined so that some
applications can start using the new interfaces before everything is complete. 

For operational applications, it must be ensured that the application of these principles
will not adversely impact their ability to implement the code or negatively impact efficiency.
