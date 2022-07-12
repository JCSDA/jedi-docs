
Doxygen
=======

We at JEDI use `Doxygen <http://www.doxygen.nl/>`_ for generating man pages, inheritance diagrams, call trees and other types of html documentation that is linked to specific blocks of source code such as classes, functions, and subroutines.  For generating web-based manuals, guides, and tutorials we use :doc:`Sphinx <getting-started-with-sphinx>`.

Doxygen is open-source software that was developed by Dimitri van Heesch and is distributed under the GNU General Public License.  For further information on the project see `the Doxygen home page <http://www.doxygen.nl/>`_ and for extensive documentation on how to use it see:

    `The Doxygen User Manual <http://www.doxygen.nl/manual/index.html>`_

In what follows we give practical tips on how to use Doxygen within the context of JEDI.

.. note::

   **The most important part of this document are the instructions on how to add Doxygen documentation to** :ref:`C++ <doxygen-Cpp>` **and** :ref:`Fortran <doxygen-Fortran>` **code**

Don't worry about the details of how to use :ref:`Doxywizard <wizard>`.  This is optional.  Doxygen configuration files are included with most JEDI bundles and if you want to see the output you can just :ref:`enable the Doxygen build when you build the bundle and view output with a normal web browser <view-doxygen>`.

Also, as the project proceeds, the JEDI team will provide web pages where you can view the Doxygen html output for current develop branches and prior releases.  Stay tuned to this site for further details.

**All we ask is that you document any code that you add.**

.. _install-doxygen:

Installing Doxygen
------------------

Doxygen is included in the JEDI containers and may already be installed on your system. To check whether it is already installed in your environment, just type this at the command line:

.. code-block:: bash

  doxygen --help

If it is not already installed, you can obtain executable binary files for Mac OS X, Linux, and Windows through the
`Doxygen web page <http://www.doxygen.nl/download.html>`_ or you can download the source code from
`GitHub <https://github.com/doxygen/doxygen>`_ and build it yourself.

Alternatively, if you have a Mac, you can install Doxygen with :doc:`Homebrew <homebrew>`

.. code-block:: bash

  brew install doxygen # (Mac only)

.. _graphviztab:

Depending on how you install Doxygen, you may be prompted for optional add-ons,
including **Doxywizard** and **Graphviz**.  We recommend that you **say yes to both**.
`Doxywizard <http://www.doxygen.nl/manual/doxywizard_usage.html>`_ is a convenient Graphical User
Interface (GUI) for configuring and running Doxygen and `Graphviz <https://www.graphviz.org/>`_ is
a plotting package that will enable you to generate inheritance diagrams and call trees.

In particular, Graphviz includes an interpreter for the `DOT <https://graphviz.gitlab.io/_pages/doc/info/lang.html>`_ graphical display language.
A dot interpreter might already be installed on your system.
For example, if you installed doxygen via Homebrew or if you use the JEDI container,
you may not need to install anything else.  To check, try running:

.. code-block:: bash

  dot --help

If it's not already there you can install Graphviz using the executable binaries available from their
`download site <https://www.graphviz.org/download/>`_ or you can install it explicitly with
:doc:`Homebrew <homebrew>`:

.. code-block:: bash

  brew install graphviz # (Mac only)

.. _doxygen-Cpp:

Documenting C++ source code
---------------------------

There are `several ways <https://www.doxygen.nl/manual/docblocks.html#specialblock>`_ to include Doxygen documentation in C++ source files.  We recommend the Qt style, as illustrated in this example:

.. code-block:: c

   // -----------------------------------------------------------------------------
   /*! \brief Example function
   *
   * \details **myfunction()** takes a and b as arguments and miraculously creates c.
   * I could add many more details here if I chose to do so.  I can even make a list:
   * * item 1
   * * item 2
   * * item 3
   *
   * \param[in] a this is one input parameter
   * \param[in] b this is another
   * \param[out] c and this is the output
   *
   * \author L. Skywalker (JCSDA)
   *
   * \date A long, long, time ago: Created
   *
   * \warning This isn't a real function!
   *
   */
   void myfunction(int& a, int& b, double& c) {
      [...]

Since these directives are located within comment blocks, they do not affect the compilation of the code.

A few things to note.  First, the documentation for a function or class comes in a Doxygen comment block immediately before the function or class is defined.  The Doxygen block begins with :code:`/*!` and ends with :code:`*/`.  Each line in between begins with :code:`*`.  Doxygen commands are indicated with :code:`\ ` or, alternatively, :code:`@`.  :code:`\brief` gives a brief description that will appear in html and other lists whereas :code:`\details` gives further details as would appear in a man page.  :code:`\param` describes the arguments of the function while multiple :code:`\author` and :code:`\date` items can provide a history, tracking the function's development.  :code:`\warning` provides useful usage tips to the user or developer.

These are only the essentials; there are many more...

   `Doxygen commands <http://www.doxygen.nl/manual/commands.html>`_

...described in the online manual.

Note also that Doxygen supports `Markdown <http://www.doxygen.nl/manual/markdown.html>`_ language features for further formatting of the output.  Examples of Markdown above include the asterisks in :code:`**myfunction()**` (bold type) and the bulleted list.

Doxygen also supports `latex <http://www.doxygen.nl/manual/formulas.html>`_ for including formulae in latex and html output.  Latex math mode is delimited by :code:`\f$` symbols as follows:

.. code-block:: c

   /*! ...
   * This is an equation: \f$\nu = \sqrt{y_2}\f$
   */

Note - if you are :ref:`configuring doxygen yourself <wizard>`, you must enable the :code:`USE_MATHJAX` option in order for latex formulae to compile.  If you are using the default Doxyfile provided with the repository, there is no need for any action on your part - Mathjax is already enabled.

.. _doxygen-Fortran:

Documenting Fortran source code
-------------------------------

Including Doxygen documentation in Fortran is similar to C++ as described :ref:`above <doxygen-Cpp>`, but with appropriate Fortran comment indicators.  Also, the Doxygen parameter descriptions can follow the argument declarations as demonstrated here:

.. code-block:: fortran

   ! -----------------------------------------------------------------------------
   !> \brief Example function
   !!
   !! \details **myfunction()** takes a and b as arguments and miraculously creates c.
   !! I could add many more details here if I chose to do so.  I can even make a list:
   !! * item 1
   !! * item 2
   !! * item 3
   !!
   !! \author L. Skywalker (JCSDA)
   !!
   !! \date A long, long, time ago: Created
   !!
   !! \warning This isn't a real function!
   !!

   subroutine myfunction(a, b, c)
      integer, intent(in)              :: a !< this is one input parameter
      integer, intent(in)              :: b !< this is another
      real(kind=kind_rea), intent(out) :: c !< and this is the output
      [...]

The Doxygen code block here begins with :code:`!>`, and subsequent lines begin with :code:`!!`.  The parameter definitions begin with :code:`!<`.  The supported Doxygen commands are the same as in C++.

.. _view-doxygen:

Running Doxygen and Viewing the Results
---------------------------------------

You may never need to run Doxygen yourself.  As noted :doc:`above <doxygen>`, the JEDI team plans to provide Doxygen-generated html output on public web sites for specific JEDI releases and for the current develop branches.  This is still in preparation.

But, if you have added Doxygen documentation to a feature branch that you are working on, you may want to see how it looks before doing a pull request.  This is straightforward to do.

If you are working with a particular :doc:`JEDI bundle </using/building_and_running/building_jedi>`, then it is likely that this bundle is equipped to build the Doxygen documentation.  Just edit the :code:`CMakeLists.txt` file in the top level of the bundle repository (e.g. **fv3-bundle**) and look for a code snippet that resembles this:

.. code-block:: bash

    # Build Doxygen documentation
    option(BUILD_UFO_BUNDLE_DOC "Build documentation" ON)

Just make sure this is set to :code:`ON`.

Then, proceed to :doc:`build jedi as normal, running ecbuild and make </using/building_and_running/building_jedi>` from a build directory :code:`<build-dir>` (this should be different than the location of the source code).  The Doxygen html output will then be located in a directory called :code:`<build-dir>/Documentation/html`.  Just load any of the html files in this directory into your browser and navigate the the Main Page using the menu at the top.

You can also run Doxygen manually, as follows

.. _doxy-build:

.. code-block:: bash

    mkdir -p <build-dir>/Documentation
    cd <build-dir>/Documentation
    ecbuild <path-to-config-file>
    doxygen

Then, as with the automated bundle build, the Doxygen-generated html output will be located in the directory :code:`<build-dir>/Documentation/html` and you can view it with a web browser by loading any of the html documents that you see there.

Note that these manual instructions are specifically for JEDI repositories.  In this case, the :code:`<path-to-config-file>` should point to a directory that includes a file called :code:`Doxyfile.in`.  Examples include the :code:`Documentation` subdirectories in the **fv3-bundle**, or **oops** repositories.  The ecbuild step :ref:`above <doxy-build>` converts this into a :code:`Doxyfile` with the proper path information.

Alternatively, If you create your own Doxyfile with :ref:`Doxywizard <wizard>` or with :code:`doxygen -g`, then you can skip the ecbuild step and just run the :code:`doxygen` command from the same directory as the Doxyfile (you could also specify the configuration file explicitly with the :code:`-g` option to doxygen).

Or, you can generate the html output and view it using the :code:`Run Doxygen` and :code:`Show HTML Output` buttons on the :ref:`Doxywizard <wizard>` GUI.

The JEDI source code already has some Doxygen documentation within it.  So, even before you add your own documentation, you can run Doxygen on a particular JEDI repo and view the results.  We currently use Doxygen to generate html files but :ref:`it can also be configured to produce man pages and latex output <wizard>`.

.. note::

   If you use a custom configuration file generated by Doxywizard or some other means, then the output will be located in whatever directory is specified by the :code:`OUTPUT_DIRECTORY` declaration in the Doxyfile.  This may be different than as described here.

After you load some html document from the Doxygen tree into your web browser, then you can use the menus to peruse the files, functions, namespaces, classes, etc.  Selecting **Classes-Class Hierarchy** will give you an inheritance diagram like this:

.. image:: images/doxygen_inheritance.png
    :height: 400px
    :align: center

Selecting a file from the **File List** will let you see the documentation for the functions and classes it contains, including call diagrams.  Here is an example of doxygen-generated documentation for a function - select the image for a closer look (note that most JEDI functions do not yet have this level of Doxygen documentation).

.. image:: images/doxygen_ex.png
    :height: 600px
    :align: center

This is only the beginning - we encourage you to dive in and explore! For futher details on what you find, consult the `Doxygen User Manual <http://www.doxygen.nl/manual/index.html>`_

.. _wizard:

Doxywizard and Customizing the Doxygen Build
--------------------------------------------

Most JEDI repositories contain a Doxyfile configuration file (typically in the :code:`docs` subdirectory) so there is no need for you to create a new one.  Still, there may be situations in which you'd like to change look or content of the Doxygen documentation.  You can either do this by editing the Doxyfile directly or using by using Doxywizard.

As mentioned :ref:`above <install-doxygen>`, `Doxywizard <http://www.doxygen.nl/manual/doxywizard_usage.html>`_ is a convenient Graphical User Interface (GUI) for configuring and running Doxygen.  It's often installed together with doxygen as an optional extension.

To configure and run Doxygen with Doxywizard, just start up the application and begin filling in the menu items as shown here:

.. image:: images/doxywizard_project.png
    :height: 600px
    :align: center

Take note in particular of **Step 1** at the top, namely specifying the directory from which Doxygen will run.  If you select **Save** when you exit Doxywizard, Doxygen will create a configuration file in this directory called **Doxyfile** that you can later load into Doxywizard (via the File-Open... menu item) or edit manually.  Then specify the source code directory and the destination directory (the project name is optional).

**Tip** Be sure you select the **Scan recursively** option when specifying the directory for the source code.

**Tip** We recommend that you place the Doxygen output in a directory outside of the JEDI repositories.  If you do select an output directory within the JEDI repos, please exclude it from your commits so your files are not uploaded to the main JEDI repos on GitHub.

After you finish filling in this Project page, select **Mode** from the Topics menu on the left.  Here make sure you select **All Entries** and **Include cross-referenced source code in the output**.  Also, you may wish to optimize for either C++ or Fortran output.

.. image:: images/doxywizard_mode.png
    :width: 300px
    :align: center

Then proceed to the **Output** menu item on the left and make sure **html** is selected.  Then select **Diagrams** and, if you installed GraphViz as described :ref:`above <graphviztab>`, select **use dot tool from the GraphViz package**.  And, select the diagrams that you'd like dot to generate:

.. image:: images/doxywizard_diagrams.png
    :width: 300px
    :align: center

There is one more thing you may need to do in order to get dot to work correctly.  Select the **Expert** menu item at the top of the window (between *Wizard* and *Run*) and scroll down the menu on the left to select **dot**.  First make sure the **HAVE_DOT** item is checked and then scroll down to specify the **dot path**, which is likely /usr/local/bin/dot.

.. image:: images/doxywizard_dot.png
    :height: 600px
    :align: center

That is sufficient to run Doxygen but you may wish to browse some of the other items on the **Expert** menu, particularly under **Build**.  When you're finished, select **Run** from the top menu to get to the run screen and then select the **Run doxygen** button on the upper left to run Doxygen.

.. image:: images/doxywizard_run.png
    :height: 600px
    :align: center

.. _nowizard:

Wait patiently for it to run - it may take a few tens of seconds, particularly if you asked to generate many graphs.

If you'd rather not use the Doxywizard GUI, you can do all of the above and more by creating the Doxyfile configuration file manually from the command line and then editing it directly to select the options you want.  To manually generate a Doxyfile, go to your directory of choice and type:

.. code-block:: bash

  doxygen -g

Then, after editing the file to specify your configuration options (including the source and output directories), just type this thereafter (from the directory that contains the Doxyfile):

.. code-block:: bash

  doxygen

To see the glorious abundance of configuration options, consult the `Doxygen Manual <https://www.doxygen.nl/manual/config.html>`_.

If you have any problems, try consulting the `Troubleshooting <https://www.doxygen.nl/manual/trouble.html>`_ section of the Doxygen manual or the `Doxygen tag <https://stackoverflow.com/questions/tagged/doxygen>`_ on Stack Overflow - or email Mark (`miesch@ucar.edu <miesch@ucar.edu>`_) or Steve (`stephenh@ucar.edu <stephenh@ucar.edu>`_).

To view the output as a man page, first make sure you have enabled the :code:`GENERATE_MAN` option by selecting it in the **Expert-Man** menu of Doxywizard or by editing the Doxyfile.  Then navigate to the :code:`man/man3` subdirectory of the output directory.  There you can type :code:`ls` to see what man pages are available to view.  These include files, namespaces, directories, and classes.  To view one, type e.g.

.. code-block:: bash

   man ./qg_fields.3

The :code:`.3` extension (and the :code:`man3` directory name) refers to section 3 of the :code:`man` organizational structure, which is typically reserved for `library functions <https://en.wikipedia.org/wiki/Man_page>`_.  You can change this by changing the Doxygen variable :code:`MAN_EXTENSION`.

In the future, we plan to maintain a central directory tree for the man pages that you will be able to include in your :code:`MANPATH`, thus avoiding the :code:`./` syntax above.  But this is still under development.
