#!/bin/bash

#  set_nev.command
#  CoreOS Kubernetes Cluster for OS X
#
#  Created by Rimantas on 01/04/2014.
#  Copyright (c) 2014 Rimantas Mocevicius. All rights reserved.

# create .env folder
mkdir -p ~/coreos-k8s-cluster/.env

# save App's Resouces folder
echo "$1" > ~/coreos-k8s-cluster/.env/resouces_path

# save App's version
echo "$2" > ~/coreos-k8s-cluster/.env/version

