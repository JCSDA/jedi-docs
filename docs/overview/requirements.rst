############################
JEDI High Level Requirements
############################

As Earth observing systems constantly evolve and new systems are launched, equally 
continuous development to utilize the full potential of the data is necessary.
Data volumes are also increasing with time, requiring more and more efficient data
assimilation.
Given the cost of new observing systems, it is important that this process happens
quickly.
One goal of the JEDI framework is to enable efficient research in this area and accelerate the
transition from research to operations.

As weather and environmental forecasting progress, they are also evolving towards a
more comprehensive representation of the Earth system.
The framework will have to work with all components of the Earth system to enable
the evolution towards a fully coupled Earth system model.

In addition to changes in observing systems and models, data assimilation algorithms themselves are 
evolving and progressing to better exploit available data.
To accommodate this, our framework will include existing operational DA algorithms and facilitate exploration
of new DA science across domains and applications.
It is important to note that a unified system does not mean a single configuration to
be imposed on all partners, as each agency can use or develop different applications
within the framework.

The supercomputers where data assimilation systems are run are becoming more and more
complex, with more and possibly heterogeneous processing elements.
Using them efficiently is a growing concern in the community, with most centers
exploring ways to improve scalability of their forecasting models and data
assimilation systems.
The framework will  take scalability into account and facilitate adaptation
to new architectures.

Since requirements for operational and research uses are different the system will have to be flexible,
as well as easy for users to learn and test.
At the same time, it is imperative that it satisfies operational requirements for
robustness, efficiency, coding standards, and maintainability.
