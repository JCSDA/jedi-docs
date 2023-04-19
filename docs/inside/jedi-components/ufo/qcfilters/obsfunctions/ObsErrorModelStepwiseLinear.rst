.. _ObsErrorModelStepwiseLinear:

ObsErrorModelStepwiseLinear
=============================================================

This routine was designed to mimic the GSI fix-file of :code:`prepobs_errtable.txt`.
The function operates similarly to :code:`ObsErrorModelRamp`.  The input is a vector
of x-values (e.g. pressures) and corresponding vector of obserrors, using required
parameters of :code:`xvals` and :code:`errors` respectively. These vectors **must**
be the same length.  Interpolation in X-coordinate requires the value of X for which
the output, Y, is calculated using linear interpolation of obserrors between the steps.
Logically, the X-coordinate variable (using the required parameter :code:`xvar` and
associated :code:`name`) clearly matches the list of :code:`xvals`, and, although the
example shown (below) is pressure, it can easily be height/altitude or temperature or
another variable.  A diagram is used to help explain with the calculated value of
obsError shown as the asterisk corresonding to the observed value of p-star shown on
the X-axis.  Any observed value of :code:`xvar` less (or greater) than the endpoints
in the vector :code:`xvals` takes the constant value at the appropriate end of the
vector.  The list of :code:`xvals` **must** be given in either ascending or descending
order with no consecutive constant values, however the :code:`errors` vector may contain
any mixture, thereby permitting almost any functional form such as relatively high
ObsError near the surface, decreasing to lower (or constant) values in middle-atmosphere,
and increasing again in the upper atmosphere.

If the optional "scale_factor_var" exists, then the final output obserr is
calculated as a result of linear interpolation of errors times the scale_factor_var.
An example of such usage is RH obserror values between zero and one multiplied by
ObsValue/specificHumidity for final ObsError.

::


          + err_n                           o-----
          |                             /
          + err_n-1                  o
          |                       /
  obserr  *                     *
          |                  /
          |               /
     err2 +            o
          |          /
          |       /
     err1 +     o
          |--/
     err0 +-----+------+---------*---+------+------
          p_0, p_1,   p_2,...   p*  p_n-1,  p_n


There can also be times when it is useful to apply a scaling factor variable (optional yaml
parameter :code:`scale_factor_var`) to the ObsError calculated by this function.  The best
example is for :code:`specificHumidity` which is difficult to assign the exact number for
ObsError whereas Relative Humidity is easier, such as 20% RH ObsError applied between 400
and 200 hPa.  This is shown in Example 2 below.


Example 1
^^^^^^^^^

.. code-block:: yaml

       #### Example for air temperature assigned obserror by pressure (e.g., sonde data) ####

     - filter: Perform Action
       filter variables:
       - name: airTemperature
       action:
         name: assign error
         error function:
           name: ObsFunction/ObsErrorModelStepwiseLinear
           options:
             xvar:
               name: ObsValue/pressure
             xvals: [110000, 85000, 50000, 25000, 10000, 1]   #Pressure (Pa)
             errors: [1.1, 1.3, 1.8, 2.4, 4.0, 4.5]

In this example, the assignment of :code:`ObsError/airTemperature` will be 1.1 K (constant) for pressures greater than 1100 hPa (none really), linearly increasing from 1.1 K to 1.3 K for pressures between 1100 and 850 hPa, increasing again in the next step from 1.3 to 1.8 K going from pressure of 850 to 500 hPa, etc., until reaching 4.5K by 1 Pa and holding constant for any pressure lower than 1 Pa.

Example 2
^^^^^^^^^

.. code-block:: yaml

     - filter: Perform Action
       filter variables:
       - name: specificHumidity
       action:
         name: assign error
         error function:
           name: ObsFunction/ObsErrorModelStepwiseLinear
           options:
             scale_factor_var: ObsValue/specificHumidity
             xvar:
               name: ObsValue/sstationPressure
             xvals: [110000, 105000, 100000, 95000, 90000, 85000, 80000, 75000, 70000, 65000, 60000, 55000,
                      50000, 45000, 40000, 35000, 30000, 25000, 20000, 15000, 10000, 7500, 5000, 4000, 3000]
             errors: [.19455, .19062, .18488, .17877, .17342, .16976, .16777, .16696, .16605, .16522, .16637, .17086,
                      .17791, .18492, .18996, .19294, .19447, .19597, .19748, .19866, .19941, .19979, .19994, .19999, .2]

In this example, the list of errors is relative humidity as a scaling factor to the specific humidity variable since the two are so closely related.
