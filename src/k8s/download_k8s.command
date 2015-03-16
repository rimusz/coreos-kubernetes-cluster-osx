#!/bin/bash

#  download_k8s.command
#  CoreOS Kubernetes Cluster for OS X
#
#  Created by Rimantas on 01/04/2014.
#  Copyright (c) 2014 Rimantas Mocevicius. All rights reserved.

function pause(){
read -p "$*"
}

# download latest version of kubectl for OS X
K8S_VERSION=$(curl --insecure -sS https://get.k8s.io | grep release= | cut -f2 -d"=")
echo "Downloading kubectl $K8S_VERSION for OS X"
../wget https://storage.googleapis.com/kubernetes-release/release/$K8S_VERSION/bin/darwin/amd64/kubectl
chmod 755 kubectl

# download latest version of k8s for CoreOS
# master
../wget -N -P ./master https://storage.googleapis.com/kubernetes-release/release/$K8S_VERSION/bin/linux/amd64/kube-apiserver
../wget -N -P ./master https://storage.googleapis.com/kubernetes-release/release/$K8S_VERSION/bin/linux/amd64/kube-controller-manager
../wget -N -P ./master https://storage.googleapis.com/kubernetes-release/release/$K8S_VERSION/bin/linux/amd64/kube-scheduler
../wget -N -P ./master http://storage.googleapis.com/k8s/kube-register
tar czvf master.tgz -C master .
rm -f ./master/*

# nodes
../wget -N -P ./nodes https://storage.googleapis.com/kubernetes-release/release/$K8S_VERSION/bin/linux/amd64/kubelet
../wget -N -P ./nodes https://storage.googleapis.com/kubernetes-release/release/$K8S_VERSION/bin/linux/amd64/kube-proxy
tar czvf nodes.tgz -C nodes .
rm -f ./nodes/*

#
echo "Download has finished !!!"
pause 'Press [Enter] key to continue...'
