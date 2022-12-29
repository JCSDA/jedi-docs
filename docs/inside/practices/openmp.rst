.. _openmp-top:

OpenMP Safety in JEDI and UFO
=============================

As a developer, one needs to be aware of thread safety if one wants to use OpenMP or pthreads within code. Most JEDI code uses MPI for parallel tasks, which is not an issue. Currently, there is no OpenMP code anywhere in JEDI with a small section in FMS. Some of the dependencies do use OpenMP within function calls however these would not be visible to our packages. If a problem existed within these dependencies, the best one could do was to notify the developers and await a fix. In most if not all cases we could build the package without OpenMP. This is best handled as bug fix reports on a case-by-case basis.

The harder task is to identify what functions within JEDI and UFO would be unsafe if called from within a multithreaded section of code. For a multithreaded function to be safe, there should be no stateful data (e.g. class member variables) that are not constant within each function of JEDI. This might be problematic for some functions (e.g. set variable value type functions) and if so these functions should be treated as not thread-safe and called serially. We are in the process of documenting which functions should be labeled thread-safe. In the meantime, a developer should treat all nonconstant member functions as unsafe unless that code can be shown otherwise. Functions that are constant with a class are of course thread-safe provided the data passed to the function is not changed or any changes are not visible to other threads.


