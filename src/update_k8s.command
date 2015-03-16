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

# download latest version of k8s for CoreOS
# master
~/coreos-k8s-cluster/bin/wget -N -P ~/coreos-k8s-cluster/tmp https://storage.googleapis.com/kubernetes-release/release/$K8S_VERSION/bin/linux/amd64/kube-apiserver
~/coreos-k8s-cluster/bin/wget -N -P ~/coreos-k8s-cluster/tmp https://storage.googleapis.com/kubernetes-release/release/$K8S_VERSION/bin/linux/amd64/kube-controller-manager
~/coreos-k8s-cluster/bin/wget -N -P ~/coreos-k8s-cluster/tmp https://storage.googleapis.com/kubernetes-release/release/$K8S_VERSION/bin/linux/amd64/kube-scheduler
~/coreos-k8s-cluster/bin/wget -N -P ~/coreos-k8s-cluster/tmp http://storage.googleapis.com/k8s/kube-register

# nodes
~/coreos-k8s-cluster/bin/wget -N -P ~/coreos-k8s-cluster/tmp https://storage.googleapis.com/kubernetes-release/release/$K8S_VERSION/bin/linux/amd64/kubelet
~/coreos-k8s-cluster/bin/wget -N -P ~/coreos-k8s-cluster/tmp https://storage.googleapis.com/kubernetes-release/release/$K8S_VERSION/bin/linux/amd64/kube-proxy

# copy 

echo "Update has finished !!!"
pause 'Press [Enter] key to continue...'
