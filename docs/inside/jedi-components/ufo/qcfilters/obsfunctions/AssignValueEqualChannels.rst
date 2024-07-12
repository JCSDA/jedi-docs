.. _AssignValueEqualChannels:

AssignValueEqualChannels
-----------------------------------------------------------------------

Creates a variable on a channel-by-channel basis, with its value conditional
on another variable.

This obs function was designed to address a need to create a "probability of gross error"
value, dependent on the QC values. That need is normally achieved using a
:ref:`Where <where-statement>` statement, but this does not currently work with channels.
Hence this function was created.

It works by being given an integer input variable, which contains any number of
channels.  If the input variable is equal to the test value, then the output is set
equal to the `assignEqual` value, otherwise it is given the `assignNotEqual` value.
The output is always a float.

Input parameters:
~~~~~~~~~~~~~~~~~~~~~~~~~~

variable (required)
  Gives the name and channels for the integer input variable to be tested.
testValue (optional, default 0)
  The value to test the input against.
assignEqual (optional, default 0.1)
  If the input is equal to the test, then assign the output to this value.
assignNotEqual (optional, default 1.0)
  If the input is not equal to the test, then assign the output to this value.

Example configuration:
~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: yaml

    - filter: Variable Assignment               # Set the probability of gross error, based on the QC flags
      assignments:
      - name: GrossErrorProbability/bendingAngle
        channels: 1-375
        type: float
        function:
          name: ObsFunction/AssignValueEqualChannels
          options:
            variable:
              name: QCflagsData/bendingAngle
              channels: 1-375
            testValue: 0
            assignEqual: 0.1
            assignNotEqual: 1.0

