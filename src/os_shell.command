#!/bin/bash

#  os_shell.command
#  CoreOS Kubernetes Cluster for OS X
#
#  Created by Rimantas on 01/12/2014.
#  Copyright (c) 2014 Rimantas Mocevicius. All rights reserved.

# path to the bin folder where we store our binary files
export PATH=$PATH:${HOME}/coreos-k8s-cluster/bin

# set kubernetes master
export KUBERNETES_MASTER=http://172.17.15.101:8080
echo "k8s minions list:"
kubectl get minions
echo " "

# set etcd endpoint
export ETCDCTL_PEERS=http://172.17.15.101:4001
echo "etcd cluster:"
etcdctl --no-sync ls / --recursive
echo ""

# set fleetctl endpoint
export FLEETCTL_ENDPOINT=http://172.17.15.101:4001
echo "fleetctl list-machines :"
fleetctl list-machines

# open bash shell
/bin/bash
