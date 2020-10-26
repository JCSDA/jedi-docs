.. _top-fv3-jedi-visualization:

Visualization with FV3-JEDI
===========================

The FV3-JEDI system works with cubed-sphere fields and reads only cubed-sphere data from GFS and
GEOS output, as outlined in :ref:`io`. Visualization of cubed-sphere data is nontrivial since most
software for scientific visualization expects the field to be arranged on a latitude-longitude grid.

Data that is output in the GEOS format, and specifically by the file output under the configuration
key :code:`filename_bkgd` is readable by Panpoly, available from |panoply_link|. Panoply can
interpret and create plots of cubed-sphere fields directly. It has a simple GUI and a number of
useful features.

.. |panoply_link| raw:: html

   <a href="https://www.giss.nasa.gov/tools/panoply/"target="_blank">https://www.giss.nasa.gov/tools/panoply/</a>

The GFS data that is output in tile files is not straightforward to visualize and no software for
doing so is provided with FV3-JEDI or the FV3 models. In order to plot fields output by GFS it has
to first be converted to another format. That format can either be GEOS, and then use Panoply, or to
a longitude-latitude grid using the :code:`lonlat` type of output. FV3-JEDI is provided with a
convert state application in the bin directory. An example configuration
(:code:`convertstate_gfs_c2ll.yaml`) for driving the convert state application and converting GFS
output to longitude-latitude is provided in the testinput directory of the repository. In this
example the file :code:`gfs.bkg.lonlat.20180415_000000z.nc4` is output with all the fields on the
lon-lat grid. The executable :code:`fv3jedi_plot_field.x`, provided in the bin directory can be used
to to plot the field at a certain level. The following example plots the temperature field T at
layer 64.

.. code::

  fv3jedi_plot_field.x --inputfile gfs.bkg.lonlat.20180415_000000z.nc4 \
                       --fieldname T --layer 64 --showfig=true
