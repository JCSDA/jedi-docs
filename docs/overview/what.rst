What is JEDI?
=============

An accurate weather forecast depends on two fundamental ingredients.  First, you need comprehensive observations; to predict what the weather will be like tomorrow you need to know what it is like today (or more precisely, the current and past state of the atmosphere and ocean).  Second, you need a reliable computer model that can take today's weather and predict how it is likely to change in the near future based on established physical, chemical, environmental, and biological principles.

JEDI brings these two fundamental ingredients together within the scientific discipline of Data Assimilation (DA).

The long term objective of JEDI is to provide a unified data assimilation framework for research and operational use, for different components of the Earth system, and for different applications, with the objective of reducing or avoiding redundant work within the community and increasing efficiency of research and of the transition from development teams to operations.

JEDI is a community effort.  The :doc:`code management structure <../working-practices/index>` welcomes engagement from the wider scientific community while remaining tightly controlled for operational use.

The :doc:`organization structure <governance>` provides clear roles for developers, reviewers and the governance body as well as guidelines for interactions between those roles, thus ensuring efficiency of the continuous development process.

Who uses JEDI?
--------------

A reliable and efficient data assimilation system is an integral part of any forecast framework for Earth system prediction.  Potential users of JEDI thus include any government agencies, universities, and private companies that are engaged in operational weather forecasting.  This includes `JCSDA partners <https://jcsda.org/partners>`_ NOAA, NASA, the US Navy, and the US Air Force.

But JEDI is not just for forecasters.  Modern science is built upon the conviction that observation is the ultimate arbiter: the viability of any scientific theory rests on its ability to predict future events.  Thus, data assimilation also plays an integral role in scientific research.  New physical, chemical, and biological models must be validated by comparing their predictions with observations.  Such comparisons continually produce new insights into how our world works.

Thus, JEDI serves as a testbed and proving ground for any scientific researchers who are interested in improving our understanding of the Earth's atmosphere, oceans, and biosphere.  This includes those working to develop improved models, improved DA algorithms, and improved observation operators.  This again spans a variety of academic, government, and private institutions.

The multi-faceted capabilities of JEDI can also be leveraged to promote Research-to-Operations (R2O) and Operations-to-Research (O2R) workflows.  Researchers developing improved components can validate them using the same software framework that is used for operations, thus accelerating implementation.  Conversely, algorithm improvements that produce more accurate forecasts can be readily adopted by the research community for further investigation into the reasons for their success.

JEDI can be used to support leading-edge research investigations that leverage the world's most powerful supercomputers and the world's most sophisticated atmospheric and oceanic models.  But, you can also run JEDI on your laptop.  JEDI comes with several :doc:`idealized models <../jedi-components/oops/toy-models/index>` that can be used to investigate new approaches or just to learn about data assimilation.  And, low-resolution configurations can be used to even run some leading-edge models on a laptop.

The future of weather forecasting and of atmospheric and oceanic research lies in the hands of current graduate students.  Continuing progress relies on their ability to master the subtle science of data assimilation.  Students and teachers can use JEDI to help them cultivate that ability as they interactively explore the fundamental principles and procedures that underlie Earth system prediction.

Why should I use JEDI?
----------------------

Modern software development is a collaborative activity.  Developers work in teams to produce new features and work across teams to integrate them.  These teams are often spread over different cities or countries and their member may never physically meet.  Nevertheless, work needs to be coordinated efficiently to avoid wasted effort.

Over the past few decades, the software industry has met this challenge with innovative strategies and tools. Agile software development approaches such as `Scrum <https://www.scrum.org/>`_ now dominate the industry, emphasizing early and continuous delivery of functional software, capable self-organizing teams, and continual attention and response to the needs of the user community.  Meanwhile, cloud platforms such as `GitHub <https:://github.com>`_ have greatly facilitated collaboration, code management, and code distribution across continents and time zones.

It is the objective of JEDI to leverage these modern software engineering practices for the benefit of the weather forecasting community.  The JEDI development environment is built upon the GitHub ecosystem (git, GitHub and `ZenHub <https://www.zenhub.com/>`_) and the :doc:`git flow <../developer/practices/gitflow>` workflow.  GitHub is a version management, collaboration, and distribution tool with online interface and ZenHub is a agile management and issue tracking tool that links with GitHub repositories. These tools are all cross connected to form an ecosystem that has become an industry standard. They provide the means for easy access and fast engagement while still allowing proper control at all levels.

For further details on various aspects of the JEDI development environment see :doc:`Working Practices <../working-practices/index>`.  :doc:`Specific guidelines for developers <../developer/practices/index>` are also provided to help developers follow these working practices.

JEDI not only leverages modern software development practices, it also exploits modern software engineering tactics through a generic, object-oriented design.  DA applications are implemented using abstract classes and templates that are readily extensible to accommodate new models, new algorithms, and new observations.

This modern approach to software development and design underlies JEDI's versatility without sacrificing efficiency.  And, it promotes the collaborative approach that is necessary to maintain a unified, innovative forecast system as a service and an asset to the atmospheric and oceanic science community.