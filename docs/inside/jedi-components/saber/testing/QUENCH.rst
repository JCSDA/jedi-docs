.. _QUENCH:

QUENCH
======

`Quench hardening is a mechanical process in which steel and cast iron alloys are strengthened and hardened. Could be very useful to make sure a SABER is reliable...`

The **QUENCH** testbed is a very simple pseudo-model interfaced with OOPS, written in C++ and based on ATLAS objects. It does not forecast anything, but it implements the required classes to:

* generate an ensemble (randomization),
* run background error covariance estimation,
* run Dirac tests.

So it should be enough to test SABER blocks technically, and assess their behavior at low-resolution. The main advantage of **QUENCH** is the flexibility of its geometry specification, based on ATLAS grids. Absolutely no observations in **QUENCH**, wonderful.
