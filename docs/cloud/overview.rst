AWS Overview
============

AWS stands for `Amazon Web Services <https://aws.amazon.com>`_, a major provider of cloud computing resources, including compute nodes, data storage, and other services such as machine learning and serverless back-end processing of web events(AWS Lambda).

Currently, AWS is the primary cloud provider for JCSDA.  So, if you want to run JEDI in the cloud, you will likely want to use AWS.

This is not to say that you cannot use other cloud providers.  If you have an allocation on any cloud provider, you can establish a JEDI-ready environment by means of our software containers or by building the `jedi-stack <https://github.com/JCSDA/jedi-stack>`_ yourself as described in our :doc:`Portability document <../developer/jedi_environment/portability>`.

However, if you plan to use JCSDA cloud computing resources, the documents in :doc:`this chapter <index>` are for you.

The first step is therefore to gain access to JCSDA cloud computing resources.  JEDI users share a single JCSDA account that you will need to be added to in order to launch AWS Elastic Compute Cloud (EC2) instances, create CloudFormation clusters, or access private data on AWS's Simple Storage Service (S3).

I you wish, **Please** `contact us <miesch@ucar.edu>`_ **to request access to JCSDA's AWS account**

If your request for access is granted, JCDSA staff will provide you with AWS login credentials that will allow you to access AWS resources either either through the web-based `AWS console <https://aws.amazon.com>`_ or through the `AWS command line interface <https://aws.amazon.com/cli>`_.  These credentials include a user name, a password, a secret access key, and an ID for that secret access key.

Though these credentials will allow you to create compute instances and clusters, they will not allow you to log into them.  For that **you will also need to create an ssh key pair**.  You can create an ssh key pair through the EC2 Dashboard on the AWS console or you can create a key pair seperately and then import it into AWS.  For instructions on how to do this, see the `AWS documentation <https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html>`_.

In the future we plan to allow selected users to run JEDI applications on the cloud through a web-based front end without the need for AWS login credentials.  However, this option is not yet available.
