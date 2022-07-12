## Minimum steps for working with JEDI natively on Mac OS

Tested on *MacOS 10.15.7 (Catalina).*
**Note:** Some steps of this process require administrator privileges for the Mac. If you do not have administrator privileges, you will need to work closely with someone who does, both for the initial installation and for ongoing jedi-stack maintenance. You might instead consider [installing vagrant](https://jointcenterforsatellitedataassimilation-jedi-docs.readthedocs-hosted.com/en/latest/using/jedi_environment/vagrant.html) and then using the [JEDI Singularity containers](https://jointcenterforsatellitedataassimilation-jedi-docs.readthedocs-hosted.com/en/latest/using/jedi_environment/singularity.html) for JEDI on your Mac, as this will be an easier environment to maintain without administrator privileges.

### Basic tools

Use homebrew to install the basic required tools:
```
coreutils
boost
cmake
eigen
gcc
git
git-lfs
gpatch
lmod
openssl@1.1
wget
```

Note that some bundles (e.g. `fv3-bundle`) require OpenMP. If you need that, also install `libomp` using homebrew.

Make sure to add the appropriate `lmod` init script to your shell as described on the [lmod homebrew formula page](https://formulae.brew.sh/formula/lmod).

While editing your shell initialization file for the `lmod` init script, also add the following lines in preparation for the next step:
```bash
export JEDI_OPT=/opt/modules
module use $JEDI_OPT/modulefiles/core
```

### Install JEDI stack

```bash
git clone https://github.com/jcsda-internal/jedi-stack.git
```

(Note that in what follows only gfortran is used from the `brew`-installed `gcc` package.)

Within the cloned jedi-stack repository, edit `buildscripts/config/config_mac.sh`. You need to set the compiler and MPI versions you want to use. In my case I chose:

```bash
export JEDI_COMPILER="clang/12.0.0"
export JEDI_MPI="mpich/3.3.2"
```

Note: this document is written with these compiler/mpi selections assumed, as well as other default settings in `config_mac.sh`. You will need to modify these instructions if you make edits to that file.

If any modules are already loaded, clear them with `module purge` before proceeding. Then from the `buildscripts` directory, run:
```bash
./setup_modules.sh mac
```

If you have errors with the compiler when running the script, you may need to set the following environment variable. (Probably Catalina-specific)
```bash
export CPATH=/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include/
```

Now you can go to the second step and build the JEDI stack itself. You need to edit `buildscripts/config/choose_modules.sh` to select the components you want. The `choose_modules.sh` file has been organized with a minimal jedi-stack section at the top, so you should set all the variables in that section to `Y`, except for those corresponding to packages that you have already installed using homebrew above or that have been provided by MacOS (LAPACK). So only the following packages from the "Minimal JEDI Stack" section should be set to "N":
- CMAKE
- GITLFS
- LAPACK
- EIGEN3

Note: You will need more modules selected if you want to run certain bundles. Some additional requirements include:
- For `mpas-bundle`: PIO
- For `soca-science`: NCO

Then from the `buildscripts` directory, run:
```bash
./build_stack.sh mac
```

All the selected modules can now be loaded:
```bash
module load jedi-clang/12.0.0
module load jedi-mpich/3.3.2
module load hdf5 netcdf pnetcdf nccmp ecbuild
```

You are now ready for JEDI!

### Get and build JEDI

You can now choose the bundle you want to work with, the example below is with fv3-bundle:
```bash
git clone https://github.com/JCSDA/fv3-bundle.git
```

Then build and run ctest:
```bash
cd /path/to/build/directory
ecbuild -DOPENSSL_ROOT_DIR=/usr/local/opt/openssl /path/to/fv3-bundle
make -j4
ctest
```

**Note:** In reality I don't clone a bundle. I have a directory that contains all the repos I'm interested in, and in the same directory a `CMakeLists.txt` (the only file that matters in a bundle repo) that contains all the repos and where I comment or uncomment the repos I want at a given time. This way I have only one copy of each repo, and can work with any application (bundle) I am interested in, including more than one model at the same time. When I want to add a repo I just add it to the `CMakeLists.txt` and ecbuild will get it for me. I include `eckit` in my bundle because it's only built the first time so it's not a big burden and I like to have the code just there when I'm looking for a function I want to use.

**Troubleshooting 1:** Some people have had problems with compiler `unknown argument` errors when building some bundles after loading
the modules "individually" as described above. If this happens to you, try this additional setup:

In addition to the `STACK_BUILD` variables listed above, also set the following variables to `Y` in `choose_modules.sh`
before running `./build_stack.sh mac`:
```bash
STACK_BUILD_JSON
STACK_BUILD_JSON_SCHEMA_VALIDATOR
```

To your shell setup script, add the following:
```bash
module use <path>/<to>/jedi-stack/modulefiles/apps
```

Edit the `<path>/<to>/jedi-stack/modulefiles/apps/jedi/clang-mpich.lua` file to remove the `load("lapack")` line.

Then you can load a set of jedi modules with the command:
```bash
module load jedi/clang-mpich
```

Now clear your `CMakeCache.txt` from your build directory and try to build again.

**Troubleshooting 2** If, when building a bundle, you get an error containing wording like `...your binary is not an allowed client of /usr/lib/libcrypto.dylib`,
it means that the linker is trying to link to the macOS OpenSSL libraries (which is not allowed) instead of the homebrew-installed openssl libraries.
One solution to this problem is to add the option `-DOPENSSL_ROOT_DIR=/usr/local/opt/openssl` to your `ecbuild` command for the bundle.

**Troubleshooting 3**
Some people have encountered errors like this while building the jedi-stack:
```bash
sudo: 4294967295: invalid value
sudo: error initializing audit plugin sudoers_audit
```
This appears to be an [intermittent, unresolved MacOS issue](https://discussions-cn-prz.apple.com/en/thread/252518458). Try, try again.
