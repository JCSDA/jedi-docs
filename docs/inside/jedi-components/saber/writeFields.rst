.. _write_fields:

Write Fields
============

The :code:`write fields` block writes the content of an :code:`oops::FieldSet3D`
to a NetCDF file. This block will not have any other affect on the
:code:`oops::FieldSet3D` passed through it.

Writing the contents of a :code:`oops::FieldSet3D` can be a useful debugging tool,
and this feature is also used in spectral applications to write out ensemble members
that have been filtered and interpolated onto a non-model grid.

The block can write output when it is constructed (it can write out the background (bg)
and/or the first guess (fg) given to the block's constructor). It can also write output
when it applies its adjoint multiply method (:code:`WriteFields::multiplyAD`), applies
its forward multiply method (:code:`WriteFields::multiply`), or when it applies its left
inverse multiply method (:code:`WriteFields::leftInverseMultiply`).

The block keeps a counter of each individual file type was written (i.e., bg's, fg's,
multiplyAD, multiply, leftInverseMultiply) and appends the counter to the name of the
written file.

Example :code:`write fields` block:

.. code-block:: yaml

  saber block name: write fields
    # save netCDF file: True       # (OPTIONAL) parameter with default of 'True'
    # field names: {fld1, fld2}    # (OPTIONAL) list of fields to write out.
                                   # If not present, all fields get written
    output path: </path/to/output> # (REQUIRED) path to directory where
                                   # output files will be written
    xb filename: background   # (OPTIONAL) will write background given 
                              # to constructor with filename "background_1.nc"
    fg filename: firstGuess   # (OPTIONAL) will write first guess given 
                              # to constructor with filename "firstGuess_1.nc"
    multiply fset filename: fset_multiply   # (OPTIONAL) writes fieldSet
                                            # passed to multiply()
    multiplyad fset filename: fset_multiplyAD   # (OPTIONAL) writes fieldSet
                                                # passed to multiplyAD()
    left inverse fset filename: fset_left_inv_multiply # (OPTIONAL) writes fieldSet
                                                       # passed to leftInverseMultiply()
