# jedi-docs

This repository is for all [JEDI documentation](https://jointcenterforsatellitedataassimilation-jedi-docs.readthedocs-hosted.com) that doesn't have a logical home in a code repository.

## Testing updates

You can test updates to the documentation by loading `jedi-tools-env` and running `make html` from `jedi-docs/docs`.

```
cd docs
module load jedi-tools-env
make html
open _build/html/index.html
```

## Writing documentation

Here are a few important standards to follow when writing (or editing) documentation.


1. Linking to other pages in the documentation is encouraged. Sphinx provides
   many ways of doing this, and the best way is to use the `:ref:` directive.
   The `:ref:` directive is very flexible and creates a link to any reference
   handle specified as `.. _my-handle:`. The reference handle can be put
   anywhere within a `.rst` file and the link will resolve to the
   exact location of the handle. Write the pre-rendered link in this format:
   :ref:\`my-handle\`. Typically, the handle should be placed above a title
   or heading in which case the title/heading will appear as the hyperlinked
   text in the rendered documentation. You may also specify your own text
   for the hyperlink.

   Please **do not** link to another page using the relative path to the target
   `.rst` file as files can be moved.

