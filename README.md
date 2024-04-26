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

