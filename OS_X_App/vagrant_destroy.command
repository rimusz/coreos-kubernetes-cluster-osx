#!/bin/bash

#  vagrant_destroy.command
#  CoreOS Kubernetes Cluster for OS X
#
#  Created by Rimantas on 01/04/2014.
#  Copyright (c) 2014 Rimantas Mocevicius. All rights reserved.

function pause(){
read -p "$*"
}

cd ~/coreos-kubernetes-cluster/servers/nodes
vagrant destroy
#
cd ~/coreos-kubernetes-cluster/servers/control
vagrant destroy

pause 'Press [Enter] key to continue...'
