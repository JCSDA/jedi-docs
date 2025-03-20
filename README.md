# jedi-docs

This is the [JEDI documentation](https://jointcenterforsatellitedataassimilation-jedi-docs.readthedocs-hosted.com) repository for users and developers of JEDI.

To make updates:
1. Edit docs directly in github by clicking the "pen" icon on an already
   existing page. This is best for making small edits/additions/changes.
   When ready, make a Pull Request by clicking the green "Commit changes..."
   button.
2. Clone the repository, make a branch, and commit/push your changes. This
   is recommended for larger changes (like adding new pages). Please test
   the changes in your branch before making a Pull Request (see section on
   [Testing updates](#testing-updates) since the build will catch more errors
   & warnings than the CI especially on equation and code-block rendering.

## Testing updates

You can test updates to the documentation by loading `jedi-tools-env` and running `make html` from `jedi-docs/docs`.

```
cd docs
module load jedi-tools-env
make html
open _build/html/index.html
```

## Tips on writing documentation

The jedi-docs are written in reStructuredText (reST) markup plaintext files and are
built by [Sphinx](https://www.sphinx-doc.org/en/master/). For an introduction and
reference for reST see the [reStructuredText Primer](https://www.sphinx-doc.org/en/master/usage/restructuredtext/basics.html) in the
Sphinx documentation.

Here are a few important standards to follow when writing (or editing) documentation.

1. Linking to other pages in the documentation is encouraged. Sphinx provides
   many ways of doing this, and the best way is to use the `:ref:` directive.
   The `:ref:` directive is very flexible and creates a link to any reference
   handle specified as `.. _my-handle:`. The reference handle can be put
   anywhere within a `.rst` file and the link will resolve to the
   exact location of the handle. Write the pre-rendered link in this format:
   :ref:\`my-handle\`. Typically, the handle should be placed above a title
   or heading in which case the title/heading will appear as the hyperlinked
   text in the rendered documentation. You may also specify your own custom
   text for the hyperlink with the syntax: :ref:\`CustomText \<my-handle\>\`

   Please **do not** link to another page using the relative path to the target
   `.rst` file as files can be moved.

