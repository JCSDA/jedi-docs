#!/bin/bash
# © Copyright 2021 UCAR
# This software is licensed under the terms of the Apache Licence Version 2.0 which can be obtained at
# http://www.apache.org/licenses/LICENSE-2.0.

aws s3 cp --recursive _build/html s3://academy.jcsda.org/jedi-edu
