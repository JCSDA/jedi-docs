.. _ObsErrorModelHumidity:

ObsErrorModelHumidity
==============
This routine was designed to mimic the way GSI observer code (i.e., setupq.f90)
assigns observation error for specific humidity observations in two steps.
The first step is to interpolate errors from GSI error table (i.e., :code:`prepobs_errtable.txt`)
to observation pressure with parameters and routines similar to those from
:ref:`ObsErrorModelStepwiseLinear`. The second step is to scale the errors
with saturation specific humidity estimated from model fields because humidity
errors from :code:`prepobs_errtable.txt` are for relative humidity observations.
Forecast temperature and pressure fields are required for the computation of saturation
specific humidity.

This obs function is designed **solely for the error assignment of specific humidity observations**. 
When used in a filter, please make sure :code:`filter variables` only contains the
variable name for specific humidity.

The required yaml parameters, :code:`xvar`, :code:`xvals`, and :code:`errors`, 
and their usages in this obs function are the same as in :ref:`ObsErrorModelStepwiseLinear`.
A slight expansion of the usage is to allow size-1 lists of :code:`xvals` and :code:`errors` 
to accommodate the situation of fixed input error. Inputing a size-1 list of :code:`errors` 
is equivalent to specifying a fixed error with :code:`error parameter`. 

This obs function also contains two optional parameters, :code:`Method` and :code:`Formulation`,
which are used to specify the method and/or formulation for computing saturation specific humidity.
If not specified, the default method/formulation will be used.


Example yaml
------------

.. code-block:: yaml

  - filter: Perform Action
    filter variables:
    - name: specific_humidity
    action:
      name: assign error
      error function:
        name: ObsErrorModelHumidity@ObsFunction
        options:
          xvar:
            name: MetaData/air_pressure
          xvals: [85000, 50000, 25000]   #Pressure (Pa)
          errors: [0.18, 0.19, 0.2]      #RH error
          Method: UKMO
