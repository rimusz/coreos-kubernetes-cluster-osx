#!/bin/bash

#  vagrant_node1.command
#  CoreOS Kubernetes Cluster for OS X
#
#  Created by Rimantas on 01/04/2014.
#  Copyright (c) 2014 Rimantas Mocevicius. All rights reserved.

cd ~/coreos-k8s-cluster/workers
vagrant ssh k8snode-01 -- -A

