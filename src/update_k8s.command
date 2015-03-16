#!/bin/bash

#  update_k8s.command
#  CoreOS Kubernetes Cluster for OS X
#
#  Created by Rimantas on 01/04/2014.
#  Copyright (c) 2014 Rimantas Mocevicius. All rights reserved.

function pause(){
read -p "$*"
}

#
cd ~/coreos-k8s-cluster/tmp

# download latest version of kubectl for OS X
cd ~/coreos-k8s-cluster/tmp
K8S_VERSION=$(curl --insecure -sS https://get.k8s.io | grep release= | cut -f2 -d"=")
echo "Downloading kubectl $K8S_VERSION for OS X"
~/coreos-k8s-cluster/bin/wget -N -P ~/coreos-k8s-cluster/bin https://storage.googleapis.com/kubernetes-release/release/$K8S_VERSION/bin/darwin/amd64/kubectl
chmod 755 ~/coreos-k8s-cluster/bin/kubectl
echo "kubectl was copied to ~/coreos-k8s-cluster/bin"
echo " "

# clean up tmp folder
rm -rf ~/coreos-k8s-cluster/tmp/*

# download latest version of k8s for CoreOS
# master
echo "Downloading latest version of k8s master services"
~/coreos-k8s-cluster/bin/wget -N -P ~/coreos-k8s-cluster/tmp https://storage.googleapis.com/kubernetes-release/release/$K8S_VERSION/bin/linux/amd64/kube-apiserver
~/coreos-k8s-cluster/bin/wget -N -P ~/coreos-k8s-cluster/tmp https://storage.googleapis.com/kubernetes-release/release/$K8S_VERSION/bin/linux/amd64/kube-controller-manager
~/coreos-k8s-cluster/bin/wget -N -P ~/coreos-k8s-cluster/tmp https://storage.googleapis.com/kubernetes-release/release/$K8S_VERSION/bin/linux/amd64/kube-scheduler
~/coreos-k8s-cluster/bin/wget -N -P ~/coreos-k8s-cluster/tmp http://storage.googleapis.com/k8s/kube-register
tar czvf master.tgz *
cp -f master.tgz ~/coreos-k8s-cluster/control/
# clean up tmp folder
rm -rf ~/coreos-k8s-cluster/tmp/*
echo " "

# nodes
echo "Downloading latest version of k8s node services"
~/coreos-k8s-cluster/bin/wget -N -P ~/coreos-k8s-cluster/tmp https://storage.googleapis.com/kubernetes-release/release/$K8S_VERSION/bin/linux/amd64/kubelet
~/coreos-k8s-cluster/bin/wget -N -P ~/coreos-k8s-cluster/tmp https://storage.googleapis.com/kubernetes-release/release/$K8S_VERSION/bin/linux/amd64/kube-proxy
tar czvf nodes.tgz *
cp -f nodes.tgz ~/coreos-k8s-cluster/workers/
# clean up tmp folder
rm -rf ~/coreos-k8s-cluster/tmp/*

# install k8s files on master
echo "Installing latest version of k8s master services"
cd ~/coreos-k8s-cluster/control
vagrant scp master.tgz /home/core/
vagrant ssh k8smaster-01 -c "sudo /usr/bin/mkdir -p /opt/bin && sudo tar xzf /home/core/master.tgz -C /opt/bin && sudo chmod 755 /opt/bin/* "
echo "Done with k8smaster-01 "
echo " "

# install k8s files on nodes
echo "Installing latest version of k8s node services"
cd ~/coreos-k8s-cluster/workers
vagrant scp nodes.tgz /home/core/
#
vagrant ssh k8snode-01 -c "sudo /usr/bin/mkdir -p /opt/bin && sudo tar xzf /home/core/nodes.tgz -C /opt/bin && sudo chmod 755 /opt/bin/* "
echo "Done with k8snode-01 "
echo " "
vagrant ssh k8snode-02 -c "sudo /usr/bin/mkdir -p /opt/bin && sudo tar xzf /home/core/nodes.tgz -C /opt/bin && sudo chmod 755 /opt/bin/* "
echo "Done with k8snode-02 "

# restart fleet units
echo "Restarting fleet units:"
# set fleetctl tunnel
export FLEETCTL_ENDPOINT=http://172.17.15.101:4001
export FLEETCTL_STRICT_HOST_KEY_CHECKING=false
cd ~/coreos-k8s-cluster/fleet
~/coreos-k8s-cluster/bin/fleetctl stop *.service
sleep 10
~/coreos-k8s-cluster/bin/fleetctl start *.service
#
sleep 10
echo " "
cd ~/coreos-k8s-cluster/fleet
fleetctl start *.service
echo "fleetctl list-units:"
fleetctl list-units
echo " "

echo "k8s update has finished !!!"
pause 'Press [Enter] key to continue...'
