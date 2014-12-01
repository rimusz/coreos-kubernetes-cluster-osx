#!/bin/bash

#  coreos-vagrant.command
#  CoreOS Kubernetes Cluster for OS X
#
#  Created by Rimantas on 01/04/2014.
#  Copyright (c) 2014 Rimantas Mocevicius. All rights reserved.


# pass first argument - up, halt ...
cd ~/coreos-kubernetes-cluster/servers/control
vagrant $1

cd ~/coreos-kubernetes-cluster/servers/nodes
vagrant $1
