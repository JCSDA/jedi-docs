## Minimum steps for working with JEDI natively on Mac OS

Tested on *MacOS 10.15.7 (Catalina).*

### Basic tools

Use homebrew to install the basic required tools:
```
boost
cmake
eigen
gcc
git
git-lfs
lmod
openssl@1.1
wget
```

Make sure the proper line for initializing lmod is included in your `.bashrc` or `.zshrc` file.
While editing the file, add the following lines in preparation for the next step:
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

In the past I used to work with `mpich` installed from homebrew but it doesn't seem to work anymore.
If any modules are already loaded, clear them with `module purge` before proceeding. Then from the `buildscripts` directory, run:
```bash
./setup_modules.sh mac
```

If you have errors with the compiler when running the script, you may need to set the following environment variable. (Probably Catalina-specific)
```bash
export CPATH=/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include/
```

Now you can go to the second step and build the JEDI stack itself. You need to edit `buildscripts/config/choose_modules.sh` to select the components you want. For this minimum configuration, I chose:

```bash
export       STACK_BUILD_SZIP=Y
export       STACK_BUILD_ZLIB=Y
export       STACK_BUILD_HDF5=Y
export    STACK_BUILD_PNETCDF=Y
export     STACK_BUILD_NETCDF=Y
export      STACK_BUILD_NCCMP=Y
export    STACK_BUILD_ECBUILD=Y
export   STACK_BUILD_GSL_LITE=Y
```
and set everything else to `N`. You will need more if you want to run the ioda converters (requires bufr...) or MPAS (PIO...).

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
before running `./setup_modules.sh mac`:
```bash
STACK_BUILD_LAPACK
STACK_BUILD_BUFR
STACK_BUILD_JSON
STACK_BUILD_JSON_SCHEMA_VALIDATOR
```

To your shell setup script, add the following:
```bash
module use <path>/<to>/jedi-stack/modulefiles/apps
```

Then you can load a set of jedi modules with the command:
```bash
module load jedi/clang-mpich
```

Now clear your `CMakeCache.txt` from your build directory and try to build again.

**Troubleshooting 2** If, when building a bundle, you get an error containing wording like `...your binary is not an allowed client of /usr/lib/libcrypto.dylib`,
it means that the linker is trying to link to the macOS OpenSSL libraries (which is not allowed) instead of the homebrew-installed openssl libraries.
One solution to this problem is to add the option `-DOPENSSL_ROOT_DIR=/usr/local/opt/openssl` to your `ecbuild` command for the bundle.
