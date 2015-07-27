#!/bin/bash

#  coreos-vagrant.command
#  CoreOS Kubernetes Cluster for OS X
#
#  Created by Rimantas on 01/04/2014.
#  Copyright (c) 2014 Rimantas Mocevicius. All rights reserved.

export PATH=/usr/local/bin

# pass first argument - up, halt ...
cd ~/coreos-k8s-cluster/control
vagrant $1

cd ~/coreos-k8s-cluster/workers
vagrant $1
