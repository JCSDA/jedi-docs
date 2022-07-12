# Introduction

## Goals

The Joint Effort for Data assimilation Integration (JEDI) provides a programming interface to manipulate data used throughout the JEDI project. This Interface for Observation Data Access (IODA) is called extensively throughout the code wherever data is created, read, and written. This document provides structure to the data. It aims to address questions like: How are observation data arranged? How do I find a particular variable? What units should be used?

An important benefit of this convention is that users can write generic code to handle a wide variety of observation types. Separation of concerns is a key concept behind JEDI development. By creating a well-documented standard, we can compartmentalize the tasks of the UFO developers, model interface developers, data diagnosticians, and those working on observation ingest. To go even further, we aim to make our datasets as self-documenting as possible. Units, for example, are essential and these always “travel” with our variables in IODA files. The dimensions of every variable also have meaning and are documented. Some variables are categorical and rely on enumerated constants (i.e. special numbers). All such aspects need to be documented for users to create their datasets.

These conventions are inspired by the [Climate and Forecast (CF) Metadata Conventions](http://cfconventions.org/cf-conventions/cf-conventions.html). The CF Conventions are intended for use with Climate and Forecast data for the atmosphere, surface, and ocean. They have a particular emphasis on model variables. In many ways, the IODA conventions are a reflection of the broad space of observations and data assimilation. This space follows somewhat different rules. Reported quantities vary across instruments and may have subtle differences in meaning. Data are frequently expressed as point measurements at sequences of locations. Observation “locations” may cover wide areas with unusual geometries.

## How to read this document

This document is divided into a series of tables and two main explanatory pages.

The convention tables provide variable and attribute descriptions, units, data types, dimensions, and standardized names for all Observation Data in the JEDI system.

The first section describes the logical objects that you may encounter inside JEDI data. This includes groups, variables, and attributes. This chapter also describes IODA’s support for many different types of data (integers, floating point numbers, enumerations, and so on).

The second section describes how we organize our data into logical structures that end users and developers can use within downstream applications and codes. This organization encompasses both how we arrange the data &mdash; that is, how we collect variables into our group structure depending on whether the variable’s data are observed, a product of a forward operator, represents an estimate of observation error, et cetera &mdash; and how we describe the variables themselves (i.e. our choices of naming conventions, units, dimension meanings, and missing data). We describe how ObsSpaces and bias correction data are organized. As JEDI evolves, we will add details about other user-facing data structures.

## Procedure for updating these conventions

Just like with the CF Conventions, we recognize that the field is too vast for any one document to cover. Our ultimate goal is to describe all variables and class structures used within JEDI.

The JEDI data conventions are a living document that should always reflect the state of the JEDI codes. We expect that they will need frequent updates, particularly when describing new features and when assimilating new types of observations. We discuss conventions at a weekly meeting. Feel free to raise issues in the [IODA repository](https://github.com/JCSDA-internal/ioda/issues) or on the [JCSDA Forums](https://forums.jcsda.org/).

## Credits

These conventions would not have been possible without the contributions of many JCSDA stakeholders and the partnering agencies.

