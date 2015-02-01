#!/bin/bash

#  vagrant_control.command
#  CoreOS Kubernetes Cluster for OS X
#
#  Created by Rimantas on 01/04/2014.
#  Copyright (c) 2014 Rimantas Mocevicius. All rights reserved.

cd ~/coreos-k8s-cluster/control
vagrant ssh k8smaster-01 -- -A

