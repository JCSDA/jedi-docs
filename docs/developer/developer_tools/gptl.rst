GPTL
====

The `General Purpose Timing Library (GPTL) <https://jmrosinski.github.io/GPTL/>`_ is an open-source profiling library for C/C++ and Fortran codes. The purpose of this document is to explain its use in JEDI.

Detailed `usage documentation and examples for the library proper are available <https://jmrosinski.github.io/GPTL/>`_ and the source code can be cloned from `GitHub <https://github.com/jmrosinski/GPTL.git>`_. A tar file of the latest release can also be `downloaded from GitHub <https://github.com/jmrosinski/GPTL/releases/tag/v8.0.3>`_.

JEDI-specific modifications for GPTL live in the OOPS repository. Enabling GPTL in JEDI currently requires user input to ecbuild via the following settings:

1. whether to enable GPTL support (:code:`-DENABLE_GPTL=ON`)

2. whether to enable function-based auto-profiling (:code:`-DENABLE_AUTOPROFILE=ON`)

Based on these settings code will be enabled inside of OOPS to check at run-time for certain environment variable settings which specify desired behavior of the GPTL library.

It is expected that the MPI auto-profiling capability provided by GPTL will be enabled for most apps wishing to utilize the GPTL library. This requires that the GPTL library be built with the :code:`configure` flag :code:`--enable-pmpi`. In this case GPTL will automatically intercept MPI calls from the invoking app and gather timing and data volume statistics for those calls. GPTL provides an additional run-time setting to automatically synchronize, and time the synchronization, prior to MPI collective and Recv calls. Enabling this synchronization is critical for apps with large load imbalance across MPI tasks. Otherwise it is easy to misinterpret reported MPI time as all due to communication and none due to synchronization. OOPS run-time environment variable :code:`OOPS_SYNC_MPI` is queried (0=no, 1=yes) to determine whether or not to apply this synchronization to MPI calls.

GPTL also provides function-based auto-profiling, which is facilitated by the compiler through use of compile-time flags. These flags for C/C++ and Fortran are the same for both GNU and Intel compilers (:code:`-finstrument-functions`), and are set automatically when ecbuild is passed :code:`-DENABLE_AUTOPROFILE=ON`. OOPS run-time environment variable :code:`$OOPS_PROFILE=1` also needs to be set in order to produce these statistics. In this case a dynamic call tree will be generated along with detailed statistics regarding number of times the function was called, total time, parent and children routines, and more. These results are reported for each MPI task, and have the name timing."number", where "number" represents the MPI rank in :code:`MPI_COMM_WORLD` of the process (or 0 when MPI is not active). This function-based auto-profiling can be especially useful to learn who calls who for a given app, and to get an idea which are the expensive routines. But, depending on the app there can be substantial overhead if some routines are called many times. So users should employ function-based auto-profiling with caution.

It is also possible to utilize GPTL via manual instrumentation. This is done through calls to :code:`GPTLstart("whatever")` and :code:`GPTLstop("whatever")`. These calls can be mixed with auto-profiling as well if desired.

Another use case for GPTL within JEDI is when the user wants to know about memory usage as the program runs. Assuming ecbuild was passed :code:`-DENABLE_GPTL=YES`, setting OOPS environment variable :code:`$OOPS_MEMUSAGE=1` enables this capability at run-time. Whenever the process resident set size (RSS) increases on function entry or exit (if :code:`$OOPS_PROFILE=1`), or manual :code:`GPTLstart` or :code:`GPTLstop` calls, a message will be printed to :code:`stderr` indicating where the growth occurred and the new value of RSS. Enabling this memory growth analysis feature can be very expensive when profiled routines are called many times. This is because gathering current memory usage stats on every function call is not cheap. So generally this feature is only employed absent other GPTL functionality.

Only the GPTL functions which can be enabled via OOPS environment variables have been described here. There are many others which can be set via function calls, and are described in the `GPTL documentation <https://jmrosinski.github.io/GPTL/>`_.
