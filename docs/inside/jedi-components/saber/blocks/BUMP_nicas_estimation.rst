.. _BUMP_nicas_estimation:

Estimating NICAS parameters
---------------------------

This page is a practical guide to running a BUMP parameter estimation job: diagnosing
correlation or localization length-scales from an ensemble, building a NICAS operator, and
reusing the result. It is model-independent - the examples use a generic geometry, and the
places where your model matters are called out explicitly.

For what the underlying drivers do, see :ref:`BUMP_theoretical_overview`. For the SABER blocks
that consume the output, see :ref:`BUMP-SABER-blocks`.

What estimation does
********************

There are two separate pieces of machinery, and it is worth being clear that **you can run
either one on its own**:

* **HDIAG** samples the ensemble, bins pairs of points by their separation distance, fits a
  correlation function to the resulting curve, and gives you length-scales. Depending on the
  drivers you enable, these are correlation length-scales (:code:`cor_rh`, :code:`cor_rv`) or
  localization length-scales (:code:`loc_rh`, :code:`loc_rv`).
* **NICAS** builds the actual convolution operator from a pair of length-scales - whether those
  came from HDIAG or you specified them yourself.

So there are three useful jobs: diagnostics only, NICAS from length-scales you already know,
and the two chained together. All three are shown below.

.. note::

   There is no :code:`hdiag` SABER block and no separate estimation application. HDIAG is
   switched on **implicitly**, by the drivers you enable.
   Everything runs through the :code:`BUMP_NICAS` block's :code:`calibration` section.

What a model must provide
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

BUMP takes its vertical coordinate from a geometry field. The field is named by the fields
metadata key :code:`<variable>.vert_coord` if present, and otherwise defaults to a geometry
field called :code:`vert_coord`.

**The units of that field are the units of every vertical length-scale you configure or read
back.** Some model interfaces fill it with a physical depth or height in metres; others fill it
with the level index, in which case a vertical length-scale of :code:`2.0` means two model
levels and has nothing to do with metres. Check what your model interface puts in
:code:`vert_coord` before interpreting :code:`cor_rv` or setting a vertical length-scale by
hand. Horizontal length-scales are always in metres.

Running the estimation
**********************

Parameter estimation is run by the :ref:`ErrorCovarianceToolbox <ErrorCovarianceToolbox>` application. Each model builds
its own executable:

.. code-block:: bash

   mpiexec -n <ntasks> <model>_error_covariance_toolbox.x myconfig.yaml

:code:`quench_error_covariance_toolbox.x` uses QUENCH simplified model, useful for trying a
configuration out before pointing it at real data.

The top-level yaml has three sections:

.. code-block:: yaml

   geometry:
     <...>                            # model-specific geometry

   background:
     <...>                            # model-specific state; supplies the valid time
                                      # and, for some models, masks and coordinates

   background error:
     covariance model: SABER
     ensemble:                        # NOTE: here, not inside the saber block
       <...>
     saber central block:
       saber block name: BUMP_NICAS
       calibration:
         <...>                        # everything BUMP-specific goes in here

The ensemble lives at the :code:`background error` level. Four forms are accepted:

.. list-table::
   :widths: 35 65
   :header-rows: 1

   * - Key
     - Meaning
   * - :code:`ensemble`
     - A set of states; perturbations are formed by removing the ensemble mean.
   * - :code:`ensemble pert`
     - Increments read directly from disk; used as-is.
   * - :code:`ensemble base` + :code:`ensemble pairs`
     - Perturbations formed as the difference of two sets of states (useful, e.g. for NMC method).
   * - :code:`ensemble pert on other geometry` + :code:`ensemble geometry`
     - Increments read on a different geometry and interpolated.

Add :code:`iterative ensemble loading: true` at the same indentation level to read members
one at a time instead of holding the whole ensemble in memory. On a large grid this is
usually necessary.

.. note::

    Within the BUMP-specific section, :code:`ensemble sizes: total ensemble size` is filled in
    automatically from the number of members you listed. Set it by hand only when re-reading
    previously stored moments, where there is no member list to count.

.. _HDIAG-only:

Running HDIAG (diagnostics only)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The simplest useful job, and the one to start with. It answers "what are my ensemble's
length-scales?" without committing to an operator, and it is much cheaper than building NICAS.

.. code-block:: yaml

   saber central block:
     saber block name: BUMP_NICAS
     calibration:
       io:
         data directory: path_to_bump_directory
         files prefix: my_bump_files
       drivers:
         multivariate strategy: univariate  # one diagnostic per variable
         compute moments: true              # required for any HDIAG job
         compute covariance: true
         compute correlation: true
         write diagnostics: true            # -> my_bump_files_diag.nc
         write diagnostics in yaml: true    # -> my_bump_files_diag.yaml (easy to plot)
         compute nicas: false               # diagnostics only
       sampling:
         computation grid size: 1000        # Sc1: where correlations are measured
         diagnostic grid size: 200          # Sc2: where local diagnostics are stored
         distance classes: 15
         distance class width: 200.0e3      # in m; see "Choosing the sampling parameters"
         reduced levels: 11                 # moving window of levels, NOT the level count
         local diagnostic: true             # produce a map rather than one global profile
         averaging length-scale: 1000.0e3   # radius over which local statistics are pooled
         max number of draws: 500000        # the default of 10000 is too small; see pitfalls
       diagnostics:
         target ensemble size: 30           # REQUIRED, and must be > 3
       output model files:
       - parameter: cor_rh
         file:
           <...>                            # model-specific output file configuration
       - parameter: cor_rv
         file:
           <...>
       - parameter: stddev
         file:
           <...>

Add :code:`compute localization: true` to also diagnose localization length-scales, and request
:code:`loc_rh` / :code:`loc_rv` in :code:`output model files`. Localization length-scales are
corrected for the sampling noise of a finite ensemble, so they are broader than the raw
correlation length-scales; :code:`diagnostics: target ensemble size` is the ensemble size they
are optimal for.

Constructing a NICAS operator from explicit length-scales
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

This option will build a NICAS operator from a user-provided set of explicit length-scales and
does not require an ensemble. See :ref:`BUMP-SABER-blocks` for the length-scale conventions and
the per-level :code:`profile:` form.

.. code-block:: yaml

   saber central block:
     saber block name: BUMP_NICAS
     calibration:
       io:
         data directory: path_to_bump_directory
         files prefix: my_bump_files
       drivers:
         multivariate strategy: duplicated  # one shared operator; groups are named "common"
         compute nicas: true
         write local nicas: true
       nicas:
         resolution: 8.0
         explicit length-scales: true
         horizontal length-scale:
         - groups: [common]
           value: 1000.0e3                  # metres
         vertical length-scale:
         - groups: [common]
           value: 0.5                       # units of the model's vert_coord field

Running HDIAG and NICAS construction together
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The full chain: diagnose the length-scales, then immediately build the operator from them.
Take the example in :ref:`HDIAG-only` and add the NICAS drivers:

.. code-block:: yaml

       drivers:
         multivariate strategy: univariate
         compute moments: true
         compute covariance: true
         compute correlation: true
         compute localization: true         # for a localization operator
         compute nicas: true
         write local nicas: true
       nicas:
         resolution: 8.0                    # no explicit length-scales -- HDIAG supplies them

Running in two steps instead is often better on a large grid: diagnostics are cheap and let
you inspect the length-scales before paying for the operator, and the sampling and moments can
be reused via :code:`overriding sampling file` and :code:`overriding moments file`.

BUMP YAML keys and vocabulary reference
***************************************

This is a reference for BUMP-specific jargon relevant to estimation. The exhaustive set, with defaults, is in
:code:`saber/src/saber/bump/BUMPParameters.h`.

The sampling subsets
^^^^^^^^^^^^^^^^^^^^

BUMP's log messages refer to these constantly, so they are worth knowing:

.. list-table::
   :widths: 15 35 50
   :header-rows: 1

   * - Name
     - Set by
     - What it is
   * - Sc0
     - The model geometry; the ``geometry`` section of the YAML
     - Every model grid point.
   * - Sc1
     - :code:`computation grid size`
     - The points where correlations are actually measured.
   * - Sc2
     - :code:`diagnostic grid size`
     - The points where a local diagnostic is stored - the knots of the length-scale map.
   * - Sc3
     - :code:`distance classes`, :code:`angular sectors`
     - The partner points paired with each Sc1 point at each separation.
   * - halo A / halo B
     - The computational grid partitioning
     - What an MPI task owns / what it owns plus what it borrows from neighbouring tasks.

:code:`drivers:` keys
^^^^^^^^^^^^^^^^^^^^^

.. list-table::
   :widths: 35 65
   :header-rows: 1

   * - Key
     - Description
   * - :code:`multivariate strategy`
     - :code:`univariate`, :code:`duplicated`, :code:`duplicated and weighted` or
       :code:`crossed`. Also determines the **group names** - see the pitfalls below.
   * - :code:`compute moments`
     - Accumulate the ensemble moments. Required for any HDIAG job, unless
       :code:`read moments` is used instead.
   * - :code:`compute covariance`, :code:`compute correlation`
     - Diagnose covariance / correlation. Either one enables HDIAG.
   * - :code:`compute localization`
     - Diagnose localization length-scales. Requires the two above.
   * - :code:`compute nicas`
     - Build the NICAS operator.
   * - :code:`write local nicas`, :code:`write global nicas`
     - Write the operator as one file per MPI task, or a single file.
   * - :code:`read local nicas`, :code:`read global nicas`
     - Read a previously written operator instead of building one.
   * - :code:`write diagnostics`
     - Write :code:`<files prefix>_diag.nc`.
   * - :code:`write diagnostics in yaml`
     - Also write :code:`<files prefix>_diag.yaml` - the fitted profiles in plain text.
   * - :code:`write diagnostics detail`
     - Per-component curves. Requires :code:`fit: number of components` greater than 1.
   * - :code:`write local sampling`, :code:`write moments`
     - Store the sampling / moments so a later run can reuse them.

:code:`sampling:` keys
^^^^^^^^^^^^^^^^^^^^^^

.. list-table::
   :widths: 35 65
   :header-rows: 1

   * - Key
     - Description
   * - :code:`computation grid size`
     - Number of Sc1 points (:math:`n_{c1}`). The main driver of memory and moment-computation cost.
   * - :code:`diagnostic grid size`
     - Number of Sc2 points (:math:`n_{c2}`), i.e. the resolution of the length-scale map.
   * - :code:`distance classes`
     - Number of separation bins.
   * - :code:`distance class width`
     - Width of each bin, in metres. Bins run from 0 to
       :code:`(distance classes - 1/2)` × :code:`distance class width`.
   * - :code:`angular sectors`
     - 1 for isotropic. Greater than 1 (and even) diagnoses anisotropy - see below.
   * - :code:`reduced levels`
     - A **moving window** of levels centred on each level on which vertical diagnostic are
       performed (not the number of levels, to save CPU and memory).
   * - :code:`local diagnostic`
     - :code:`true` gives a spatially varying map (but increases the cost); :code:`false`
       gives one global profile.
   * - :code:`averaging length-scale`
     - Radius, in metres, over which Sc1 statistics are pooled into each Sc2 diagnostic.
       Mutually exclusive with :code:`averaging latitude width`; exactly one must be set.
   * - :code:`max number of draws`
     - Cap on the random draws used to fill the Sc3 pairs. The default of 10000 is far too
       small on a real grid - see the pitfalls.

:code:`diagnostics:` and :code:`fit:` keys
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. list-table::
   :widths: 35 65
   :header-rows: 1

   * - Key
     - Description
   * - :code:`diagnostics: target ensemble size`
     - The ensemble size the localization diagnostics are computed for. By default, it is equal to
       the input ensemble size.
   * - :code:`diagnostics: gaussian approximation`
     - Use the Gaussian approximation for the asymptotic quantities. Worth trying if the
       localization diagnostics look unstable.
   * - :code:`diagnostics: localization option`
     - Select the localization calculation method among several options:

       - :code:`default`: optimal localization estimation described in equation (165) of `this note <https://github.com/benjaminmenetrier/covariance_filtering/blob/master/covariance_filtering.pdf>`_, might yield unstable results depending on the ensemble distribution.
       - :code:`from_squared_correlation`: squared correlation-based estimation described in equation (172) of `this note <https://github.com/benjaminmenetrier/covariance_filtering/blob/master/covariance_filtering.pdf>`_, significantly more stable.
       - :code:`nice_with_table` and :code:`nice_without_table` based on the NICE method of `Vishny et al. (2024) <https://agupubs.onlinelibrary.wiley.com/doi/full/10.1029/2024MS004417>`_, with or without pre-computed lookup tables.

   * - :code:`fit: number of components`
     - Number of Gaspari-Cohn functions summed to form the fitted function. Default 1.
   * - :code:`fit: horizontal filtering length-scale`
     - Smooths the fitted length-scale field spatially, in metres. Applied **after** the fit,
       so it compounds with :code:`averaging length-scale`, which pools **before** it.

:code:`nicas:` keys
^^^^^^^^^^^^^^^^^^^

.. list-table::
   :widths: 35 65
   :header-rows: 1

   * - Key
     - Description
   * - :code:`resolution`
     - Unitless. The number of points used to discretize the Gaspari-Cohn function from its
       origin to the limit of its support. Use at least 3; 4-8 if affordable.
   * - :code:`max horizontal grid size`
     - Upper bound on the NICAS subgrid size. Cost grows quadratically with
       :code:`resolution` and inversely with the length-scale, so if the theoretical grid size
       exceeds this bound a lower *effective* resolution is computed and printed in the log.
       If the effective resolution falls below 3 the run aborts, and you must lower
       :code:`resolution` or raise this bound.
   * - :code:`explicit length-scales`
     - :code:`true` to supply length-scales yourself rather than taking them from HDIAG.
   * - :code:`horizontal length-scale`, :code:`vertical length-scale`
     - Per-group :code:`value:` or per-level :code:`profile:`.
   * - :code:`filter mode`, :code:`filter resolution`
     - Build the operator as a low-pass filter rather than a covariance square root. In filter
       mode :code:`resolution` is ignored in favour of :code:`filter resolution`. Filter mode
       can be used e.g. for ensemble scale separation.
   * - :code:`same horizontal convolution`
     - Apply one horizontal operator level by level, with no vertical convolution. Much
       cheaper on a many-level grid, and the right choice for a purely horizontal filter.

Choosing the sampling parameters
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

:code:`computation grid size`, :code:`diagnostic grid size` and :code:`averaging length-scale`
are coupled, and guessing at them independently is the most common way to get a poor
length-scale map. The number of Sc1 points pooled into each Sc2 diagnostic is approximately

.. math::

   n_{\mathrm{pooled}} \approx n_{c1} \, \frac{\pi r^2}{A}

where :math:`r` is :code:`averaging length-scale` and :math:`A` is the area covered by the
valid points of your domain.

* Aim for :math:`n_{\mathrm{pooled}}` between 50 and 100. Below roughly 30 the per-Sc2 fits are
  noisy and the map looks speckled; above roughly 200 the extra samples no longer improve the
  fit. Choose :code:`computation grid size` to land in that range.
* Then choose :code:`diagnostic grid size` from the map resolution you want. The length-scale
  field has knots only at Sc2 points and is interpolated between them, and the pooling has
  already smoothed at scale :math:`r`, so Sc2 spacing much finer than :math:`r/2` buys nothing:
  :math:`n_{c2} \approx A / (r/2)^2`.
* :code:`distance class width` should be roughly twice the mean grid spacing. Bins narrower
  than the mesh can only draw partners from high latitudes, where converging meridians make the
  zonal spacing smaller - the result is a latitude-biased sample rather than an empty one, so
  nothing warns you.

Cost scales as :math:`n_{c1}` for memory, :math:`n_{c1} n_{c2}` for the averaging, and
:math:`n_{c2}` for the fitting, which performs a nonlinear minimisation per Sc2 point, per
level, per component.

Neither :code:`computation grid size` nor :code:`diagnostic grid size` can exceed the number of
candidate points, which BUMP reports early in the log::

   Decimate full grid, at least    10000 points required,   91600 valid points found

Reusing the output
******************

Switch :code:`calibration:` to :code:`read:` and replace the :code:`compute` drivers with
:code:`read` ones:

.. code-block:: yaml

   saber central block:
     saber block name: BUMP_NICAS
     read:
       io:
         data directory: path_to_bump_directory
         files prefix: my_bump_files
       drivers:
         multivariate strategy: duplicated  # must match the run that wrote the files
         read local nicas: true

.. warning::

   Anything that shaped the stored operator must be restated identically when reading it -
   :code:`multivariate strategy`, :code:`filter mode` and :code:`same horizontal convolution`
   in particular. Only the construction-side keys drop away.

Common pitfalls
***************

:code:`max number of draws` is too small by default, and fails silently
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

BUMP fills the Sc3 pair slots by drawing uniformly random points over the domain and binning
them by distance. The probability that a random point lands in the ring of radius :math:`r` and
width :math:`dc` is :math:`r \, dc / 2R^2` - of order :math:`10^{-5}` for a first class of a few
tens of kilometres. With the default cap of 10000 draws the loop exits with most of the
**short-distance** slots unfilled.

Unfilled slots are quietly masked out. There is no warning, and the progress bar reaches 100%
regardless of whether the slots were filled, so the run looks healthy. Because the starved
classes are exactly the ones that constrain the fit, the length-scale comes out fitted on the
tail of the curve: biased long and noisy.

The best way to confirm the diagnosis of this issue is to check the ``..._diag.nc`` file. If the
raw correlation/localization curves are missing for many bins at the beginning of the curve, then
:code:`max number of draws` is indeed too small.

Set the value of :code:`max number of draws` to:

.. math::

    f (1/p) \ln(n_{c1} n_{c3} n_{c4})

with :math:`p` the probability above, and :math:`f` is a fudge factor of 2-5. Do **not** simply
set it to a very large value: the loop performs one MPI :code:`allgather` per draw, so an
over-large value becomes the run time.

.. note::

   With :code:`angular sectors` greater than 1 the loop can never reach its completion
   condition and always consumes the full :code:`max number of draws`. Choose the value
   deliberately in that case.

:code:`reduced levels` is a window, not a count
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

It is a moving window of levels centred on each level. Setting it equal to the number of model
levels asks BUMP to correlate the top of the model with the bottom, which is rarely meaningful
and is expensive: memory scales as :code:`reduced levels` × number of levels, and with
:code:`iterative ensemble loading: true` four large moment arrays are allocated rather than two.

On a 75-level grid, setting :code:`reduced levels` to 75 rather than to 11 can cost several GB
per MPI task. **The symptom is a job that appears to hang** - it is
thrashing while it allocates and fills the moment arrays. Set it to cover the vertical
structure you expect, plus a margin.

Group names might depend on :code:`multivariate strategy`
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Group names can be specified in the :code:`model` section, for instance like:

.. code-block:: yaml

   saber central block:
     saber block name: BUMP_NICAS
     read:
       model:
         groups:
         - group name: my_first_group
           variables: [var1, var2]
         - group name: my_second_group
           variables: [var3]

However by default, the group names depend on the :code:`multivariate strategy`:

* For :code:`univariate` and :code:`crossed`: one group per variable, the group name being the variable name.
* For :code:`duplicated` and :code:`duplicated and weighted`: a single group for all variables, named "common".

This is important to specify group-specific parameters like explicit length-scales. A mismatch aborts with::

   rh is missing for <variable name>

The same naming is used for the netCDF groups inside :code:`<files prefix>_nicas`, so building
with one strategy and reading with another might give :code:`NetCDF: No group found`. A simple solution is to
use the :code:`alias` key in the :code:`io` section. For instance if the NICAS file was created for the variable
:code:`air_horizontal_streamfunction` with the :code:`univariate` strategy, and is read with the :code:`duplicated` strategy:

.. code-block:: yaml

   saber central block:
     saber block name: BUMP_NICAS
     read:
       io:
         alias:
         - in code: common
           in file: air_horizontal_streamfunction


Vertical length-scales may be auto-filled
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

With :code:`explicit length-scales: true`, a group that has a horizontal length-scale but no
vertical one gets a vertical length-scale of zero, with a warning in the log. That is usually
what you want for a purely horizontal operator. Note the auto-fill only applies once the
horizontal length-scale has matched a real group, so a group-name error surfaces as a complaint
about :code:`rh` rather than :code:`rv`.

Every :code:`output model files` entry needs its own :code:`file:` block
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

BUMP passes the :code:`file:` sub-configuration straight to the model's writer. A missing
:code:`file:` key yields an *empty* configuration rather than an error, so the failure surfaces
later and further away, as the model writer complaining about whichever key it happens to read
first.

In particular, do not use a YAML merge key to share a common block - :code:`<<: *anchor`
splices the keys in beside :code:`parameter:`, leaving :code:`file:` absent. Write each entry
out in full, and give each parameter a distinct output file, or they will overwrite each other.

Translating abort messages
^^^^^^^^^^^^^^^^^^^^^^^^^^

BUMP's namelist checks report the internal Fortran variable rather than the yaml key:

.. list-table::
   :widths: 55 45
   :header-rows: 1

   * - Abort message
     - What to set
   * - :code:`new_mom or load_mom required for new_hdiag`
     - :code:`drivers: compute moments` (or :code:`read moments`)
   * - :code:`ne should be larger than 3`
     - :code:`diagnostics: target ensemble size`
   * - :code:`fit_ncmp should be larger than 1 for write_hdiag_detail`
     - :code:`fit: number of components`, or drop
       :code:`drivers: write diagnostics detail`
   * - :code:`local_rad or local_dlat should be positive`
     - :code:`sampling: averaging length-scale` (or :code:`averaging latitude width`)
   * - :code:`local_rad and local_dlat cannot be positive at the same time`
     - set exactly one of the two
   * - :code:`rh is missing for <name>`
     - the :code:`groups:` names under
       :code:`nicas: horizontal length-scale` do not match the strategy
   * - :code:`nc1 should be larger than 2`
     - :code:`sampling: computation grid size`
   * - :code:`nc3 should be positive`
     - :code:`sampling: distance classes`
   * - :code:`dc should be positive`
     - :code:`sampling: distance class width`
   * - :code:`nl0r should be positive`
     - :code:`sampling: reduced levels`
   * - :code:`ens_nsub should be a divider of ens_ne`
     - :code:`ensemble sizes: sub-ensembles` must divide the ensemble size

Going further
*************

**Anisotropy.** Set :code:`sampling: angular sectors` to an even number greater than 1. Pairs
are then binned by bearing as well as distance, and the fit produces a horizontal tensor
instead of a single radius, available as the output parameters :code:`cor_rh1`,
:code:`cor_rh2` and :code:`cor_rhc`. An equivalent isotropic :code:`cor_rh` is still written, so
results stay comparable with an isotropic run. Note that this multiplies the number of pair
slots to fill.

**Multi-component fits.** Set :code:`fit: number of components` to 2 or 3 to fit a sum of
Gaspari-Cohn functions rather than a single one, which captures a sharp near-origin peak that
one function cannot. The components are fitted greedily: the first is fitted to the raw curve,
its contribution is subtracted, and the next is fitted to the residual. Outputs become
per-component, so each :code:`output model files` entry needs a :code:`component:` index, and
:code:`cor_a` gives the amplitudes. NICAS itself consumes only one component, selected by
:code:`nicas: overriding component in file`, so a multi-component fit is primarily a
diagnostic tool.
