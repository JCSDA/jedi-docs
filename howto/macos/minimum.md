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
```

Make sure the proper line for initializing lmod is included in your `.bashrc` or `.zshrc` file.
While you are doing this, you also want to define the `JEDI_OPT` environment variable:
```bash
export JEDI_OPT=/opt/modules
```
Note that in what follows only gfortran is used out of gcc.

### Install JEDI stack

```bash
git clone https://github.com/JCSDA/jedi-stack.git
```

Then you need to get into jedi-stack and edit two files. First, in `buildscripts/config/config_mac.sh`, you need to set the compiler and MPI versions you want to use. In my case I chose:

```bash
export JEDI_COMPILER="clang/12.0.0"
export JEDI_MPI="mpich/3.3.2"
```

In the past I used to work with `mpich` installed from homebrew but it doesn't seem to work anymore.
Then from the `buildscripts` directory, run:
```bash
./setup_modules.sh mac
```

Once this is done, you need to run the command (which can be included in your  `.bashrc` or `.zshrc`):
```bash
module use $JEDI_OPT/modulefiles/core
```

Now you can go to the second step and build the JEDI stack itself. You need to edit `buildscripts/config/choose_modules.sh` to select the components you want. For this minimum configuration, I chose:

```bash
export       STACK_BUILD_SZIP=Y
export       STACK_BUILD_ZLIB=Y
export       STACK_BUILD_HDF5=Y
export    STACK_BUILD_PNETCDF=Y
export     STACK_BUILD_NETCDF=Y
export      STACK_BUILD_NCCMP=Y
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
module load hdf5/1.12.0 netcdf/4.7.4 pnetcdf/1.12.1 nccmp/1.8.7.0
```

You are now ready for JEDI!

### Get and build JEDI

The last tool you need before JEDI itself is ecbuild. The easiest way is to clone the repository:
```bash
git clone https://github.com/JCSDA-internal/ecbuild.git
```
and make sure ecbuild/bin is in your `$PATH`. There is no need to compile or install anything.

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
