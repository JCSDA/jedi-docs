GPTL
====

The `General Purpose Timing Library (GPTL) <https://jmrosinski.github.io/GPTL/>`_ is an open-source profiling library for C/C++ and Fortran codes. The purpose of this document is to explain its use in JEDI.

Detailed `usage documentation and examples for the library proper are available <https://jmrosinski.github.io/GPTL/>`_ and the source code can be cloned from `GitHub <https://github.com/jmrosinski/GPTL.git>`_. A tar file of the latest release can also be `downloaded from GitHub <https://github.com/jmrosinski/GPTL/releases/tag/v8.0.3>`_.

JEDI-specific modifications for GPTL live in the OOPS repository. Enabling GPTL in JEDI currently requires user input to ecbuild via the following settings:

1. whether to enable GPTL support (:code:`-DENABLE_GPTL=ON`)

2. whether to enable function-based auto-profiling (:code:`-DENABLE_AUTOPROFILE=ON`; requires also :code:`-DENABLE_GPTL=ON`)

For example, to enable GPTL with autoprofiling you would enter:

.. code:: bash

    ecbuild -DENABLE_GPTL=ON -DENABLE_AUTOPROFILING=ON <path>/ufo-bundle

Based on these settings code will be enabled inside of OOPS to check at run-time for certain environment variable settings which specify desired behavior of the GPTL library.  To enable GPTL profiling you just set the :code:`OOPS_PROFILE` environment variable to 1 before running your application.  This is the same whether you run your application directly or through ctest.  For example, in :code:`bash`:

.. code:: bash

    export OOPS_PROFILE=1
    ctest -R test_qq_truth

The profiling output will be placed in :code:`timing.*` files located in the directory where the application is executed.  So, for the above example, this would be in the :code:`oops/qg/test` directory that branches from the build directory.

Output from rank 0 will be placed in a file called :code:`timing.000000`.  For parallel applications that use more than one MPI task and/or thread, there will also be a :code:`timing.summary` file that summarizes profiling results across tasks and threads.  You can print out results for other mpi tasks (>0) with the :code:`GPTLpr(<rank>)` function (see manual profiling examples below).  For further information including tips on how to interpret these output files, see the `GPTL documentation <https://jmrosinski.github.io/GPTL/>`_.

It is expected that the MPI auto-profiling capability provided by GPTL will be enabled for most apps wishing to utilize the GPTL library. This requires that the GPTL library be built with the :code:`configure` flag :code:`--enable-pmpi` (done by default in most JEDI stacks and containers). In this case GPTL will automatically intercept MPI calls from the invoking app and gather timing and data volume statistics for those calls. GPTL provides an additional run-time setting to automatically synchronize, and time the synchronization, prior to MPI collective and Recv calls. Enabling this synchronization is critical for apps with large load imbalance across MPI tasks. Otherwise it is easy to misinterpret reported MPI time as all due to communication and none due to synchronization. OOPS run-time environment variable :code:`OOPS_SYNC_MPI` is queried (0=no, 1=yes) to determine whether or not to apply this synchronization to MPI calls.

Function-based auto-profiling is facilitated by the compiler through use of compile-time flags. These flags for C/C++ and Fortran are the same for both GNU and Intel compilers (:code:`-finstrument-functions`), and are set automatically when ecbuild is passed :code:`-DENABLE_AUTOPROFILE=ON`. OOPS run-time environment variable :code:`$OOPS_PROFILE=1` also needs to be set in order to produce these statistics. In this case a dynamic call tree will be generated along with detailed statistics regarding number of times the function was called, total time, parent and children routines, and more. These results are reported for each MPI task, and have the name timing."number", where "number" represents the MPI rank in :code:`MPI_COMM_WORLD` of the process (or 0 when MPI is not active). This function-based auto-profiling can be especially useful to learn who calls who for a given app, and to get an idea which are the expensive routines. But, depending on the app there can be substantial overhead if some routines are called many times. So users should employ function-based auto-profiling with caution.

It is also possible to utilize GPTL via manual instrumentation. This is done through calls to :code:`GPTLstart("<label>")` and :code:`GPTLstop("<label>")` where :code:`<label>` is a user-defined label for that particular code section.  These calls can be mixed with auto-profiling as well if desired.  Just be sure that you include the correct header file.

For example, to manually profile a code section in C++, add the following lines:

.. code:: c++

    #include <gptl.h>

    <...>

    int ret;
    ret = GPTLstart("forecast")
    <...commands...>
    ret = GPTLstop("forecast")


To manually profile a code section in Fortran, add the following lines:

.. code:: Fortran

    use gptl

    <...>

    integer :: ret

    <...>

    ret = gptlstart("geometry setup")
    <...commands...>
    ret = gptlstop("geometry setup")

You can also create nested timing regions as described in the `GPTL documentation <https://jmrosinski.github.io/GPTL/>`_.

Another use case for GPTL within JEDI is when the user wants to know about memory usage as the program runs. Assuming ecbuild was passed :code:`-DENABLE_GPTL=ON`, setting the OOPS environment variable

.. code:: bash

    export OOPS_MEMUSAGE=1

enables this capability at run-time. Whenever the process resident set size (RSS) increases on function entry or exit (if :code:`OOPS_PROFILE=1`), or manual :code:`GPTLstart` or :code:`GPTLstop` calls, a message will be printed to :code:`stderr` indicating where the growth occurred and the new value of RSS.

For JEDI unit tests, :code:`stderr` is written to the test log file.  You can see the GPTL memory tracking by searching that file for the RSS string:

.. code:: bash

    $ grep -i rss Testing/Temporary/LastTest.log # from the build directory
    Begin _ZNSt14pointer_traitsIPKcE10pointer_toERS0_ RSS grew to    31.26 MB
    Begin _ZN4oops7LibOOPS8instanceEv RSS grew to    33.91 MB
    Begin qg_geom_mod_mp_init__ RSS grew to    34.98 MB
    Begin qg_projection_mod_mp_xy_to_lonlat_ RSS grew to    35.59 MB
    Begin _ZNSt6vectorINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcE RSS grew to        40.11 MB
    Begin _ZNSt6vectorINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcE RSS grew to        41.22 MB
    Begin _ZNSt14pointer_traitsIPcE10pointer_toERc RSS grew to    41.54 MB
    Begin _ZNSt6vectorISt10shared_ptrIN4oops8PostBaseINS1_5StateIN2qg8QgT RSS grew to        42.13 MB
    Begin qg_tools_mod_mp_ncerr_ RSS grew to    47.07 MB
    Begin qg_tools_mod_mp_ncerr_ RSS grew to    47.52 MB
    Begin qg_tools_mod_mp_ncerr_ RSS grew to    47.77 MB
    Begin qg_tools_mod_mp_ncerr_ RSS grew to    48.02 MB
    Begin _ZNSt6vectorINSt7__cxx1112basic_stringIcSt11char_traitsIcES@A RSS grew to        48.46 MB

Enabling this memory growth analysis feature can be very expensive when profiled routines are called many times. This is because gathering current memory usage stats on every function call is not cheap. So generally this feature is only employed absent other GPTL functionality.

Only the GPTL functions which can be enabled via OOPS environment variables have been described here. There are many others which can be set via function calls, and are described in the `GPTL documentation <https://jmrosinski.github.io/GPTL/>`_.
