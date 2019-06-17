################################
Forking and cloning repositories
################################

GitHub and similar tools allow for cloning or forking repositories.
Cloning is used by developers that have push permission to the official repository.
In this case, the developers are asked to follow the
`git flow <../developer/developer_tools/getting-started-with-gitflow.html>`_ methodology.
Forking is used by developers that do not have push permission to the official repository.
Developers working in a forked repository are free to use the workflow of their choice, but
we would recommend git-flow.

In the context of a unified data assimilation and forecasting system, we recommend the forking mechanism.

In practice, each developer will work on their own fork of the repository and clone from
that work for editing code.
Each developer can push to their own work freely (it is recommended to push often).
Developers issue a pull request when contributions are ready to be merged in the
central repository.
It is possible for developers to pull branches from each other’s repositories and
collaborate on a common feature.
They can also share a branch on the central repository if the branch is pulled there
by someone with sufficient permissions.
This should be used for features that require interactions between more than a few developers.

In the collaborative context of a unified data assimilation and forecasting system, an
advantage of the forking approach is that in can be used in a recursive manner.
A central repository should be agreed between all the partners.
From there, each partner can create a fork, preferably with automatic syncing.
Within each partner organisation, each developer then forks their organisation’s fork
as their central repository.
For large partner organisations, it is even possible to add another level by team,
group or division.

A common concern for operational codes is safety.
In the proposed model, operational users can have their own fork of the repositories
they require.
For compiling the code, a clone of that repository is created on a local disk.
If the fork and clone are synced manually nothing can happen until the operational
user actively pulls new changes.
Even if synced automatically, users can add their own tag or use a specific commit to
prevent accidental changes.
The operational clones can be located inside firewalls and on backed-up disks as
required by operational guidelines.
GitHub exists as a cloud based service but it is possible to install it on an
organisation’s own server (`GitHub Enterprise <https://enterprise.github.com/home>`_),
thus the fork itself can be inside a protected network as well.
