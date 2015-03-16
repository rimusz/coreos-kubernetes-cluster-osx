#!/bin/bash

#  vagrant_up.command
#  CoreOS Kubernetes Cluster for OS X
#
#  Created by Rimantas on 01/12/2014.
#  Copyright (c) 2014 Rimantas Mocevicius. All rights reserved.

cd ~/coreos-k8s-cluster/control
machine_status=$(vagrant status | grep -o -m 1 'not created')

if [ "$machine_status" = "not created" ]
then
    vagrant up --provider virtualbox
    #
    cd ~/coreos-k8s-cluster/workers
    vagrant up --provider virtualbox

    # Add vagrant ssh key to ssh-agent
    ssh-add ~/.vagrant.d/insecure_private_key

    # install k8s files on master
    cd ~/coreos-k8s-cluster/control
    vagrant scp master.tgz /home/core/
    vagrant ssh k8smaster-01 -c "sudo /usr/bin/mkdir -p /opt/bin && sudo tar xzf /home/core/master.tgz -C /opt/bin && sudo chmod 755 /opt/bin/* && ls -alh /opt/bin "
    echo "Done with k8smaster-01 "
    echo " "

    # install k8s files on nodes
    cd ~/coreos-k8s-cluster/workers
    vagrant scp nodes.tgz /home/core/
    #
    vagrant ssh k8snode-01 -c "sudo /usr/bin/mkdir -p /opt/bin && sudo tar xzf /home/core/nodes.tgz -C /opt/bin && sudo chmod 755 /opt/bin/* && ls -alh /opt/bin "
    echo "Done with k8snode-01 "
    echo " "
    vagrant ssh k8snode-02 -c "sudo /usr/bin/mkdir -p /opt/bin && sudo tar xzf /home/core/nodes.tgz -C /opt/bin && sudo chmod 755 /opt/bin/* && ls -alh /opt/bin "
    echo "Done with k8snode-02 "
else
    vagrant up
    #
    cd ~/coreos-k8s-cluster/workers
    vagrant up
fi

# path to the bin folder where we store our binary files
export PATH=${HOME}/coreos-k8s-cluster/bin:$PATH

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
cd ~/coreos-k8s-cluster/fleet
fleetctl start *.service
echo "fleetctl list-units:"
fleetctl list-units
echo " "

sleep 5

# set kubernetes master
export KUBERNETES_MASTER=http://172.17.15.101:8080
echo "k8s nodes list:"
kubectl get nodes
echo " "

cd ~/coreos-k8s-cluster/kubernetes

# open bash shell
/bin/bash
