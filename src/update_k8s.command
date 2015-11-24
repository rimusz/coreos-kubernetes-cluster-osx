#!/bin/bash

#  update_k8s.command
#  CoreOS Kubernetes Cluster for OS X
#
#  Created by Rimantas on 01/04/2014.
#  Copyright (c) 2014 Rimantas Mocevicius. All rights reserved.

function pause(){
read -p "$*"
}

# get latest k8s version
function get_latest_version_number {
 local -r latest_url="https://storage.googleapis.com/kubernetes-release/release/stable.txt"
 curl -Ss ${latest_url}
}

K8S_VERSION=$(get_latest_version_number)

# download latest version of kubectl for OS X
echo "Downloading kubectl $K8S_VERSION for OS X"
~/coreos-k8s-cluster/bin/wget -N -P ~/coreos-k8s-cluster/control https://storage.googleapis.com/kubernetes-release/release/$K8S_VERSION/bin/darwin/amd64/kubectl
chmod a+x ~/coreos-k8s-cluster/control/kubectl
echo "kubectl was downloaded to ~/coreos-k8s-cluster/control"
echo " "

cd ~/coreos-k8s-cluster/tmp
# clean up tmp folder
rm -rf ~/coreos-k8s-cluster/tmp/*
# download latest version of k8s for CoreOS
# master
echo "Downloading k8s $K8S_VERSION master services"
bins=( kubectl kube-apiserver kube-scheduler kube-controller-manager )
for b in "${bins[@]}"; do
    curl -k -L https://storage.googleapis.com/kubernetes-release/release/$K8S_VERSION/bin/linux/amd64/$b > ~/coreos-k8s-cluster/tmp/$b
done
chmod a+x ~/coreos-k8s-cluster/tmp/*
tar czvf master.tgz *
cp -f master.tgz ~/coreos-k8s-cluster/control/
# clean up tmp folder
rm -rf ~/coreos-k8s-cluster/tmp/*
echo " "

# nodes
echo "Downloading k8s $K8S_VERSION node services"
bins=( kubectl kubelet kube-proxy )
for b in "${bins[@]}"; do
    curl -k -L https://storage.googleapis.com/kubernetes-release/release/$K8S_VERSION/bin/linux/amd64/$b > ~/coreos-k8s-cluster/tmp/$b
done
chmod a+x ~/coreos-k8s-cluster/tmp/*
tar czvf nodes.tgz *
cp -f nodes.tgz ~/coreos-k8s-cluster/workers/
# clean up tmp folder
rm -rf ~/coreos-k8s-cluster/tmp/*

# install k8s files on master
echo "Installing k8s $K8S_VERSION master services"
cd ~/coreos-k8s-cluster/control
vagrant scp master.tgz k8smaster-01:/home/core/
vagrant ssh k8smaster-01 -c "sudo /usr/bin/mkdir -p /opt/bin && sudo tar xzf /home/core/master.tgz -C /opt/bin && sudo chmod 755 /opt/bin/* "
echo "Done with k8smaster-01 "
echo " "

# install k8s files on nodes
echo "Installing k8s $K8S_VERSION node services"
cd ~/coreos-k8s-cluster/workers
vagrant scp nodes.tgz k8snode-01:/home/core/
vagrant scp nodes.tgz k8snode-02:/home/core/
#
vagrant ssh k8snode-01 -c "sudo /usr/bin/mkdir -p /opt/bin && sudo tar xzf /home/core/nodes.tgz -C /opt/bin && sudo chmod 755 /opt/bin/* "
echo "Done with k8snode-01 "
echo " "
vagrant ssh k8snode-02 -c "sudo /usr/bin/mkdir -p /opt/bin && sudo tar xzf /home/core/nodes.tgz -C /opt/bin && sudo chmod 755 /opt/bin/* "
echo "Done with k8snode-02 "
#

# generate kubeconfig file
~/coreos-k8s-cluster/bin/gen_kubeconfig 172.17.15.101
#

# restart fleet units
echo "Restarting fleet units:"
# set fleetctl tunnel
export FLEETCTL_ENDPOINT=http://172.17.15.101:2379
export FLEETCTL_DRIVER=etcd
export FLEETCTL_STRICT_HOST_KEY_CHECKING=false
cd ~/coreos-k8s-cluster/fleet
~/coreos-k8s-cluster/bin/fleetctl stop *.service
sleep 5
~/coreos-k8s-cluster/bin/fleetctl start *.service
#
sleep 8
echo " "
echo "fleetctl list-units:"
~/coreos-k8s-cluster/bin/fleetctl list-units
echo " "

# set kubernetes master
export KUBERNETES_MASTER=http://172.17.15.101:8080
echo Waiting for Kubernetes cluster to be ready. This can take a few minutes...
spin='-\|/'
i=1
until ~/coreos-k8s-cluster/bin/kubectl version | grep 'Server Version' >/dev/null 2>&1; do printf "\b${spin:i++%${#sp}:1}"; sleep .1; done
i=0
until ~/coreos-k8s-cluster/bin/kubectl get nodes | grep ' Ready' >/dev/null 2>&1; do i=$(( (i+1) %4 )); printf "\r${spin:$i:1}"; sleep .1; done
i=0
until ~/coreos-k8s-cluster/bin/kubectl get nodes | grep ' Ready' >/dev/null 2>&1; do i=$(( (i+1) %4 )); printf "\r${spin:$i:1}"; sleep .1; done
#
echo " "
echo "k8s nodes list:"
~/coreos-k8s-cluster/bin/kubectl get nodes
echo " "


echo "k8s update has finished !!!"
pause 'Press [Enter] key to continue...'
