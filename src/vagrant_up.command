#!/bin/bash

#  vagrant_up.command
#  CoreOS Kubernetes Cluster for OS X
#
#  Created by Rimantas on 01/12/2014.
#  Copyright (c) 2014 Rimantas Mocevicius. All rights reserved.

cd ~/coreos-k8s-cluster/control
vagrant up
#
cd ~/coreos-k8s-cluster/workers
vagrant up

# path to the bin folder where we store our binary files
export PATH=${HOME}/coreos-k8s-cluster/bin:$PATH

# set kubernetes master
export KUBERNETES_MASTER=http://172.17.15.101:8080
echo "k8s minions list:"
kubectl get minions
echo " "

# set etcd endpoint
export ETCDCTL_PEERS=http://172.17.15.101:4001
echo "etcd cluster:"
etcdctl --no-sync ls /
echo ""

# set fleetctl endpoint
export FLEETCTL_ENDPOINT=http://172.17.15.101:4001
export FLEETCTL_STRICT_HOST_KEY_CHECKING=false
echo "fleetctl list-machines:"
fleetctl list-machines
echo " "
echo "fleetctl list-units:"
fleetctl list-units

cd ~/coreos-k8s-cluster/kubernetes

# open bash shell
/bin/bash
