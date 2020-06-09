.. _eforks-top:

Treat ECMWF Forks as Forks
==========================

The JEDI project currently leverages several public software tools that are developed and distributed by the European Centre for Medium-Range Weather Forecasts (ECMWF).  This is achieved by maintaining forks of ECMWF GitHub repositories including
`ecbuild <https://github.com/ecmwf/ecbuild>`_,
`eckit <https://github.com/ecmwf/eckit>`_,
`fckit <https://github.com/ecmwf/fckit>`_,
`atlas <https://github.com/ecmwf/atlas>`_,
`odc <https://github.com/ecmwf/odc>`_, and
`pyodc <https://github.com/ecmwf/pyodc>`_


JEDI developers not only use these repositories, but they also actively contribute to them, adding features and identifying bugs.  If this development proceeds as with other JCSDA repositories, then the :code:`develop` and :code:`master` branches of the JCSDA forks could rapidly diverge from their upstream (ecmwf) counterparts.  If this occurs, then merging upstream developments into our JCSDA forks can become difficult, leading to code conflicts that take a substantial amount of time and effort to resolve.

In order to avoid this problem, we have decided to keep our develop and master branches exactly in sync with upstream. When we make a change to these repositories, we will submit a pull request to ecmwf so we can mutually agree on an approach to implement a particular feature or fix a particular bug. These features and bugfixes will then be transferred to our develop and master branches through daily synchronization of our forks with their upstream counterparts.

This means that JEDI developers should no use the develop branches of our ecmwf forks in bundles. Doing so may cause the build to break overnight as new changes from upstream are automatically merged in. Instead, developers are advised to use the :code:`release-stable` branches of eckit, fckit, atlas, odc, and py-odc in their ecbuild bundles. See `ufo-bundle <https://github.com/JCSDA/ufo-bundle>`_ for an example.

The intention is for the release-stable branch for each of the forks will follow slightly behind develop. As develop is continually updated, we will only merge the changes into :code:`release-stable` after we have tested them.

All tags/releases for the forks will also be kept up to date with ecmwf. For example the 1.11.6 tag of :code:`jcsda/eckit` will be identical to the 1.11.6 tag of :code:`ecmwf/eckit`, and similarly for the other repositories.

Occasionally we will want to merge particular features or bug fixes immediately (after passing jcsda code reviews) without waiting for upstream reviews to complete. In this case, we can merge specific branches directly into our release-stable branches. And, we can tag these with jcsda patch numbers. An example is the `1.10.1.jcsda2 tag of jcsda/eckit <https://github.com/JCSDA/eckit/releases/tag/1.10.1.jcsda2>`_. But, it is desirable to minimize these exceptions because they may ultimately lead to conflicts when :code:`develop` is merged into :code:`release-stable`.

Though the :code:`release-stable` branches are recommended for use with all bundles, containers and environment modules will use tagged versions of the forks both for stability reasons and for clarity; for example, if you were to find a release-stable module on an HPC system, you might not know when that was built and whether or not it has a particular feature you want to use.
