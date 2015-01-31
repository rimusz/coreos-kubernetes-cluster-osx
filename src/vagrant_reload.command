#!/bin/bash

#  vagrant_up.command
#  CoreOS Kubernetes Cluster for OS X
#
#  Created by Rimantas on 01/04/2014.
#  Copyright (c) 2014 Rimantas Mocevicius. All rights reserved.

function pause(){
read -p "$*"
}

cd ~/coreos-k8s-cluster/control
vagrant reload
#
cd ~/coreos-k8s-cluster/workers
vagrant reload

# path to the bin folder where we store our binary files
export PATH=$PATH:${HOME}/coreos-k8s-cluster/bin

# kubernetes master
export KUBERNETES_MASTER=http://172.17.15.101:8080

# set etcd endpoint
export ETCDCTL_PEERS=http://172.17.15.101:4001
echo ""
etcdctl --no-sync ls / --recursive
echo ""

# set fleetctl endpoint
export FLEETCTL_ENDPOINT=http://172.17.15.101:4001
echo "fleetctl list-machines :"
fleetctl list-machines

echo ""
echo "CoreOS Kubernetes Cluster was reloaded !!!"
echo ""
pause 'Press [Enter] key to continue...'
